/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-request.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
 * 
 * maia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

internal abstract class Maia.XcbRequest : Object
{
    // static properties
    private static TaskOnce s_QueryTask;
    private static TaskOnce s_CommitTask;

    // properties
    private unowned XcbWindow m_Window;
    private Xcb.VoidCookie?   m_Cookie = null;

    // accessors
    [CCode (notify = false)]
    public virtual XcbWindow window {
        get {
            return m_Window;
        }
        construct set {
            m_Window = value;
        }
    }

    [CCode (notify = false)]
    public Xcb.VoidCookie? cookie {
        get {
            return m_Cookie;
        }
        set {
            m_Cookie = value;
        }
    }

    // methods
    public XcbRequest (XcbWindow inWindow)
    {
        GLib.Object (window: inWindow);
    }

    ~XcbRequest ()
    {
        cookie = null;
        parent = null;
    }

    private void
    start_query_task ()
    {
        audit (GLib.Log.METHOD, "start query task");

        lock (s_QueryTask)
        {
            if (s_QueryTask == null)
            {
                s_QueryTask = new TaskOnce (() => {
                    audit (GLib.Log.METHOD, "process query requests");

                    s_QueryTask.lock ();
                    {
                        while (s_QueryTask.childs.nb_items > 0)
                        {
                            unowned Object? child = s_QueryTask.childs.at (0);
                            if (child != null)
                            {
                                child.ref ();
                                ((XcbRequest)child).query_finish ();
                                child.unref ();
                            }
                        }
                    }
                    s_QueryTask.unlock ();
                }, Task.Priority.NORMAL + 1);

                s_QueryTask.finished.connect (() => {
                    lock (s_QueryTask)
                    {
                        s_QueryTask.lock ();
                        s_QueryTask = null;
                    }
                });

                s_QueryTask.parent = Application.self;
            }
        }

        parent = s_QueryTask;
    }

    private void
    start_commit_task ()
    {
        audit (GLib.Log.METHOD, "start commit task");

        lock (s_CommitTask)
        {
            if (s_CommitTask == null)
            {
                s_CommitTask = new TaskOnce (() => {
                    audit (GLib.Log.METHOD, "process commit requests");

                    s_CommitTask.lock ();
                    {
                        while (s_CommitTask.childs.nb_items > 0)
                        {
                            unowned Object? child = s_CommitTask.childs.at (0);
                            if (child != null)
                            {
                                child.ref ();
                                unowned XcbRequest request = (XcbRequest)child;

                                request.on_commit ();
                                if (request.cookie != null)
                                    start_query_task ();

                                child.unref ();
                            }
                        }
                    }
                    s_CommitTask.unlock ();
                }, Task.Priority.NORMAL - 1);

                s_CommitTask.finished.connect (() => {
                    lock (s_CommitTask)
                    {
                        s_CommitTask.lock ();
                        s_CommitTask = null;
                    }
                });

                s_CommitTask.parent = Application.self;
            }
        }

        parent = s_CommitTask;
    }

    protected virtual void
    on_reply ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);
        parent = null;
    }

    protected virtual void
    on_commit ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);
        parent = null;
    }

    protected void
    query_finish ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

        if (m_Cookie != null)
        {
            debug (GLib.Log.METHOD, "Flush query");

            on_reply ();
            m_Cookie = null;
        }
        else
        {
            parent = null;
        }
    }

    public virtual void
    query ()
    {
        if (s_QueryTask == null || parent != s_QueryTask)
        {
            audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

            if (parent == null)
                start_query_task ();
        }
    }

    public virtual void
    commit ()
    {
        if (s_CommitTask == null || parent != s_CommitTask)
        {
            audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

            start_commit_task ();
        }
    }
}
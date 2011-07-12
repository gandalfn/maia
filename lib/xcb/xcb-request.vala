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

        TaskOnce query_task = (TaskOnce)GLib.AtomicPointer.get (&s_QueryTask);

        do
        {
            if (query_task == null)
            {
                query_task = new TaskOnce (() => {
                    audit (GLib.Log.METHOD, "process query requests");

                    Token token = Token.get_for_object (s_QueryTask);
                    while (s_QueryTask.nb_childs > 0)
                    {
                        unowned Object? child = s_QueryTask.first ();
                        if (child != null)
                        {
                            child.ref ();
                            ((XcbRequest)child).query_finish ();
                            child.unref ();
                        }
                    }
                    Object.atomic_compare_and_exchange (&s_QueryTask, query_task, null);
                    token.release ();
                }, Task.Priority.NORMAL + 1);

                if (Object.atomic_compare_and_exchange (&s_QueryTask, null, query_task))
                {
                    query_task.parent = Application.self;
                }
            }

            Token token = Token.get_for_object (query_task);
            query_task = (TaskOnce)GLib.AtomicPointer.get (&s_QueryTask);
            if (query_task != null)
            {
                parent = query_task;
            }
            token.release ();
        } while (query_task == null);
    }

    private void
    start_commit_task ()
    {
        audit (GLib.Log.METHOD, "start commit task");

        TaskOnce commit_task = (TaskOnce)GLib.AtomicPointer.get (&s_CommitTask);

        do
        {
            if (commit_task == null)
            {
                commit_task = new TaskOnce (() => {
                    audit (GLib.Log.METHOD, "process commit requests");

                    Token token = Token.get_for_object (s_CommitTask);
                    while (s_CommitTask.nb_childs > 0)
                    {
                        unowned Object? child = s_CommitTask.first ();
                        if (child != null)
                        {
                            child.ref ();
                            unowned XcbRequest request = (XcbRequest)child;

                            request.on_commit ();
                            if (request.cookie != null)
                                request.start_query_task ();

                            child.unref ();
                        }
                    }
                    Object.atomic_compare_and_exchange (&s_CommitTask, commit_task, null);
                    token.release ();
                }, Task.Priority.NORMAL - 1);

                if (Object.atomic_compare_and_exchange (&s_CommitTask, null, commit_task))
                {
                    commit_task.parent = Application.self;
                }
            }

            Token token = Token.get_for_object (commit_task);
            commit_task = (TaskOnce)GLib.AtomicPointer.get (&s_CommitTask);
            if (commit_task != null)
            {
                parent = commit_task;
            }
            token.release ();
        } while (commit_task == null);
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
        unowned TaskOnce query_task = (TaskOnce)GLib.AtomicPointer.get (&s_QueryTask);
        if (query_task == null || parent != query_task)
        {
            audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

            if (parent == null)
                start_query_task ();
        }
    }

    public virtual void
    commit ()
    {
        unowned TaskOnce commit_task = (TaskOnce)GLib.AtomicPointer.get (&s_CommitTask);
        if (commit_task == null || parent != commit_task)
        {
            audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

            start_commit_task ();
        }
    }

    public virtual void
    cancel ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);
        parent = null;
        m_Cookie = null;
    }
}
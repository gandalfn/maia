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
    private static TaskOnce s_Commiter = null;

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
        parent = null;
    }

    protected virtual void
    on_reply ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);
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
    }

    public virtual void
    query ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

        if (parent != null)
        {
            debug (GLib.Log.METHOD, "Flush commit");

            m_Window.xcb_desktop.flush (true);
            on_commit ();
        }
    }

    public virtual void
    commit ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

        query_finish ();

        if (s_Commiter == null)
        {
            s_Commiter = new TaskOnce (() => {
                debug (GLib.Log.METHOD, "");

                unowned XcbRequest? prev = null;
                unowned XcbDesktop? desktop = null;
                int n = s_Commiter.childs.nb_items;
                int index = 0;
                for (int cpt = 0; cpt < n; ++cpt)
                {
                    unowned XcbRequest? request = s_Commiter.childs.at (index) as XcbRequest;
                    if (request == prev)
                    {
                        ++index;
                        request = s_Commiter.childs.at (index) as XcbRequest;
                    }
                    if (request != null)
                    {
                        request.ref ();
                        {
                            request.on_commit ();
                            if (desktop == null)
                            {
                                desktop = request.m_Window.xcb_desktop;
                            }
                        }
                        request.unref ();
                        prev = request;
                    }
                }

                if (desktop != null) desktop.flush ();
            });

            s_Commiter.finished.connect (() => {
                s_Commiter = null;
            });

            s_Commiter.parent = Application.self;
        }
        if (!(this in s_Commiter.childs))
        {
            parent = s_Commiter;
        }
    }
}
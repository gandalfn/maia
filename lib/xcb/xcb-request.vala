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
    public XcbWindow window {
        get {
            return m_Window;
        }
    }

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
        m_Window = inWindow;
    }

    protected virtual void
    on_reply ()
    {
    }

    protected virtual void
    on_commit ()
    {
        debug (GLib.Log.METHOD, "");
        parent = null;
    }

    protected void
    query_finish ()
    {
        if (m_Cookie != null)
        {
            on_reply ();
            m_Cookie = null;
        }
    }

    public abstract void query ();

    public virtual void
    commit ()
    {
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
                        request.on_commit ();
                        if (desktop == null)
                        {
                            desktop = request.m_Window.xcb_desktop;
                        }
                    }
                    prev = request;
                }

                if (desktop != null) desktop.flush ();
            });

            s_Commiter.finished.connect (() => {
                s_Commiter = null;
            });

            s_Commiter.parent = Dispatcher.self () == null ? Application.get ().dispatcher : Dispatcher.self ();
        }
        parent = s_Commiter;
    }
}
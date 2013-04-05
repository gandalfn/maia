/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-application.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
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

internal class Maia.XcbApplication : Application
{
    // properties
    private Xcb.Connection m_Connection;
    private int            m_DefaultScreen;
    private XcbAtoms       m_Atoms;
    private Dispatcher     m_EventDispatcher;

    // accessors
    public Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public override unowned Workspace? default_workspace {
        get {
            return this[m_DefaultScreen];
        }
    }

    // static methods
    static construct
    {
        Any.delegate (typeof (Window), typeof (XcbWindow));
    }

    // methods
    public XcbApplication (string? inDisplay)
    {
        GLib.Object (id: GLib.Quark.from_string (inDisplay));

        // create the xcb connection and get default screen
        m_Connection = new Xcb.Connection (inDisplay, out m_DefaultScreen);

        // fetch atoms
        m_Atoms = new XcbAtoms (this);

        // create workspaces
        int cpt = 0;
        foreach (unowned Xcb.Screen screen in m_Connection.roots)
        {
            new XcbWorkspace (this, screen, cpt);
            cpt++;
        }

        // create event dispatcher
        m_EventDispatcher = new Dispatcher.thread ();
        XcbEventDispatcher event_dispatcher = new XcbEventDispatcher (m_EventDispatcher, m_Connection);
        m_EventDispatcher.add (event_dispatcher);

        // connect on main dispatcher run
        dispatcher.running.connect (() => {
            m_EventDispatcher.run ();
        });
    }

    ~XcbApplication ()
    {
        m_EventDispatcher.stop ();
    }

    public override string
    to_string ()
    {
        string ret = "";

        foreach (Object child in this)
        {
            ret += child.to_string ();
        }

        return ret;
    }

    public void
    request_check (Xcb.VoidCookie inCookie, owned XcbVoidCookie.Callback inCallback)
    {
        new XcbVoidCookie (this, inCookie, (owned)inCallback);
    }
}

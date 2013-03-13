/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-desktop.vala
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

internal class Maia.XcbDesktop : DesktopProxy
{
    // properties
    private Xcb.Connection m_Connection       = null;
    private int            m_DefaultScreenNum = 0;
    private XcbAtoms       m_Atoms            = null;

    // accessors
    public Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public override int default_workspace {
        get {
            return m_DefaultScreenNum;
        }
    }

    public XcbAtoms atoms {
        get {
            return m_Atoms;
        }
    }

    // methods
    construct
    {
        // Get name
        string? name = GLib.Quark.to_string (id);

        // Open connection
        m_Connection = new Xcb.Connection (name, out m_DefaultScreenNum);
        if (m_Connection == null)
        {
            error ("Error on open display %s", name);
        }
        m_Connection.prefetch_maximum_request_length ();

        // Get atoms
        m_Atoms = new XcbAtoms (this);

        // Create cookies queue
        m_Cookies = new Set<XcbCookie> ();

        // Create screen collection
        if (m_Connection.roots.length <= 0)
        {
            error ("Error on create screen list %s", name);
        }

        int cpt = 0;
        foreach (unowned Xcb.Screen? screen in m_Connection.roots)
        {
            debug (GLib.Log.METHOD, "create xcb workspace %i", cpt);
            Workspace workspace = new Workspace (delegator as Desktop);
            XcbWorkspace proxy = workspace.delegate_cast<XcbWorkspace> ();
            proxy.init (screen, cpt);
            cpt++;
        }
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

    public override void
    flush ()
    {
        m_Connection.flush ();
    }
}

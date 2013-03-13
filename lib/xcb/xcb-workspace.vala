/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-workspace.vala
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

internal class Maia.XcbWorkspace : Workspace
{
    // properties
    private XcbWindow m_Root;

    // accessors
    public unowned Xcb.Screen screen { get; construct; default = null; }

    public XcbWindow root {
        get {
            if (m_Root == null)
            {
                m_Root = new XcbWindow (screen.root);
                m_Root.parent = this;
            }
            return m_Root;
        }
    }

    // methods
    public XcbWorkspace (XcbApplication inApplication, Xcb.Screen inScreen, int inNum)
    {
        GLib.Object (id: inNum, parent: inApplication, screen: inScreen);
    }

    protected override void
    delegate_construct ()
    {
        // create events
        create_window_event = new XcbCreateWindowEvent (this);
        destroy_window_event = new XcbDestroyWindowEvent (this);
    }
}

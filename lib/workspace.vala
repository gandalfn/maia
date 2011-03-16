/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * workspace.vala
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

public class Maia.Workspace : View
{
    // properties
    private unowned WorkspaceProxy m_Proxy;

    // accessors
    public uint num {
        get {
            return m_Proxy.num;
        }
    }

    public override Region geometry {
        get {
            return m_Proxy.geometry;
        }
    }

    public override DamageEvent damage_event {
        get {
            return m_Proxy.damage_event;
        }
    }

    public CreateWindowEvent create_window_event {
        get {
            return m_Proxy.create_window_event;
        }
    }

    public Window root {
        get {
            return m_Proxy.root;
        }
    }

    // methods
    public Workspace (Desktop inDesktop)
    {
        audit (GLib.Log.METHOD, "Create workspace");

        GLib.Object (parent: inDesktop);

        m_Proxy = delegate_cast<WorkspaceProxy> ();
    }

    public override bool
    can_append_child (Object inChild)
    {
        return inChild is Window; 
    }

    public void
    create_window (Window inWindow, Region inGeometry)
    {
        m_Proxy.create_window (inWindow, inGeometry);
    }
}
/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-input.vala
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

internal class Maia.XcbInput : Input
{
    // properties
    private unowned Xcb.Connection m_Connection;
    private uint                   m_EventMask;

    // accessors
    public unowned Workspace? workspace {
        get {
            unowned Workspace? ret = null;
            for (unowned Object? p = parent; p != null; p = p.parent)
            {
                if (p is Workspace)
                {
                    ret = (Workspace)p;
                    break;
                }
            }

            return ret;
        }
    }

    public Xcb.Connection? connection {
        get {
            if (m_Connection == null)
            {
                m_Connection = (workspace.parent as XcbApplication).connection;
            }
            return m_Connection;
        }
    }

    public uint event_mask {
        get {
            return m_EventMask;
        }
        set {
            m_EventMask = value;
        }
    }

    // methods
    public XcbInput (Xcb.Window inWindow)
    {
        GLib.Object (id: inWindow);
    }

    ~XcbInput ()
    {
        // Destroy xcb window
        if (id > 0)
        {
            ((Xcb.Window)id).destroy(connection);
            id = 0;
        }
    }

    protected override void
    delegate_construct ()
    {
        Log.debug (GLib.Log.METHOD, "delegate construct");

        if (id == 0)
        {
            create ();
        }
    }

    private void
    create ()
    {
        Log.debug (GLib.Log.METHOD, "Create Xcb Input");

        // Create window
        id = Xcb.Window (connection);

        // Get window size
        Graphic.Rectangle extents = geometry.extents;

        // Fix window size
        if (extents.size.width == 0) extents.size.width = 100;
        if (extents.size.height == 0) extents.size.height = 100;

        // Create window
        Xcb.VoidCookie cookie = ((Xcb.Window)id).create_checked (connection,
                                                                 Xcb.COPY_FROM_PARENT,
                                                                 (workspace as XcbWorkspace).screen.root,
                                                                 (int16)extents.origin.x,
                                                                 (int16)extents.origin.y,
                                                                 (uint16)extents.size.width,
                                                                 (uint16)extents.size.height,
                                                                 0, Xcb.WindowClass.INPUT_ONLY,
                                                                 (workspace as XcbWorkspace).screen.root_visual);

        (workspace.parent as XcbApplication).request_check (cookie, (c) => {
            if (c.error != null)
                Log.warning (GLib.Log.METHOD, "Error on create input");
            else
                Log.debug (GLib.Log.METHOD, "Input has been created successfully");
        });
    }
}

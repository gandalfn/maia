/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window.vala
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

internal class Maia.XcbWindow : WindowProxy
{
    // properties
    private XcbDesktop m_XcbDesktop;
    private Xcb.Window m_XcbWindow;
    private Region     m_Geometry;

    // accessors
    public Xcb.Window xcb_window {
        get {
            return m_XcbWindow;
        }
    }

    public override Region geometry {
        get {
            return m_Geometry;
        }
    }

    // methods
    ~XcbWindow ()
    {
        // Destroy xcb window
        m_XcbWindow.destroy (m_XcbDesktop.connection);
        m_XcbDesktop.connection.flush ();
    }

    public void
    foreign (Xcb.Window inWindow)
    {
        m_XcbWindow = inWindow;
        m_XcbDesktop = (parent.parent as Desktop).delegate_cast<XcbDesktop> ();

        Xcb.GetGeometryCookie cookie = m_XcbWindow.get_geometry (m_XcbDesktop.connection);
        Xcb.GetGeometryReply reply = cookie.reply (m_XcbDesktop.connection, null);
        m_Geometry = new Region.raw_rectangle (reply.x, reply.y,
                                               reply.width + (reply.border_width * 2),
                                               reply.height + (reply.border_width * 2));
    }

    public void
    create (Region inGeometry)
    {
        m_Geometry = inGeometry;
        XcbWorkspace xcb_workspace = (parent as Workspace).delegate_cast<XcbWorkspace> ();
        m_XcbDesktop = (parent.parent as Desktop).delegate_cast<XcbDesktop> ();
        m_XcbWindow = Xcb.Window (m_XcbDesktop.connection);

        m_XcbDesktop.connection.create_window (Xcb.CopyFromParent, 
                                               m_XcbWindow, xcb_workspace.xcb_screen.root,
                                               (int16)inGeometry.clipbox.origin.x,
                                               (int16)inGeometry.clipbox.origin.y, 
                                               (uint16)inGeometry.clipbox.size.width,
                                               (uint16)inGeometry.clipbox.size.height,
                                               0, Xcb.WindowClass.INPUT_OUTPUT, 
                                               xcb_workspace.xcb_screen.root_visual, 
                                               Xcb.CW.BACK_PIXEL, 
                                               { xcb_workspace.xcb_screen.black_pixel });

        m_XcbWindow.change_attributes (m_XcbDesktop.connection,
                                       Xcb.CW.EVENT_MASK,
                                       { Xcb.EventMask.EXPOSURE });

        m_XcbDesktop.connection.flush ();
    }

    public override void
    show ()
    {
        m_XcbWindow.map (m_XcbDesktop.connection);

        m_XcbDesktop.connection.flush ();
    }

    public override void
    hide ()
    {
        //m_XcbWindow.unmap (m_XcbDesktop.connection);
    }
}
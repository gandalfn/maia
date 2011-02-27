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
    private Xcb.Window m_XcbWindow = 0;
    private bool       m_Foreign = false;
    private Region     m_Geometry;

    // events
    private XcbDamageEvent m_DamageEvent;
    private XcbDeleteEvent m_DeleteEvent;

    public override DamageEvent damage_event {
        get {
            return m_DamageEvent;
        }
    }

    public override DeleteEvent delete_event {
        get {
            return m_DeleteEvent;
        }
    }

    // accessors
    public Xcb.Window xcb_window {
        get {
            return m_XcbWindow;
        }
    }

    public XcbDesktop xcb_desktop {
        get {
            return m_XcbDesktop;
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
        if (!m_Foreign && m_XcbWindow > 0)
            destroy ();
    }

    private void
    set_wm_protocols ()
    {
        Xcb.Atom[] atoms = { m_XcbDesktop.atoms[XcbAtomType.WM_DELETE_WINDOW] };
        m_XcbWindow.change_property (m_XcbDesktop.connection, Xcb.PropMode.REPLACE,
                                     m_XcbDesktop.atoms[XcbAtomType.WM_PROTOCOLS],
                                     Xcb.AtomType.ATOM, 32, 1, atoms);
    }

    public void
    foreign (Xcb.Window inWindow)
    {
        m_XcbWindow = inWindow;
        m_Foreign = true;
        m_XcbDesktop = (parent.parent as Desktop).delegate_cast<XcbDesktop> ();

        Xcb.GetGeometryCookie cookie = m_XcbWindow.get_geometry (m_XcbDesktop.connection);
        Xcb.GetGeometryReply reply = cookie.reply (m_XcbDesktop.connection, null);
        m_Geometry = new Region.raw_rectangle (reply.x, reply.y,
                                               reply.width + (reply.border_width * 2),
                                               reply.height + (reply.border_width * 2));

        m_DamageEvent = new XcbDamageEvent (this);
        m_DeleteEvent = new XcbDeleteEvent (this);
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

        m_DamageEvent = new XcbDamageEvent (this);
        m_DeleteEvent = new XcbDeleteEvent (this);

        m_XcbWindow.change_attributes (m_XcbDesktop.connection,
                                       Xcb.CW.EVENT_MASK,
                                       { m_DamageEvent.mask | m_DeleteEvent.mask });

        set_wm_protocols ();

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
        m_XcbDesktop.connection.flush ();
    }

    public override void
    destroy ()
    {
        m_XcbWindow.destroy(m_XcbDesktop.connection);
        m_XcbDesktop.connection.flush ();
        m_XcbWindow = 0;
    }
}
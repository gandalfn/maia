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
    private unowned XcbDesktop m_XcbDesktop;
    private Xcb.Window         m_XcbWindow = 0;
    private bool               m_Foreign = false;
    private Region             m_Geometry;

    private XcbWindowAttributes      m_Attributes;
    private XcbWindowICCCMProperties m_ICCCMProperties;
    private XcbWindowEWMHProperties  m_EWMHProperties;

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

    public XcbWindowAttributes attributes {
        get {
            return m_Attributes;
        }
    }

    public XcbWindowICCCMProperties icccm {
        get {
            return m_ICCCMProperties;
        }
    }

    [CCode (notify = false)]
    public override Window.HintType hint_type {
        get {
            return m_EWMHProperties.hint_type;
        }
        set {
            m_EWMHProperties.hint_type = value;
        }
    }

    // methods
    ~XcbWindow ()
    {
        // Destroy xcb window
        if (!m_Foreign && m_XcbWindow > 0)
            destroy ();
    }

    public void
    foreign (Xcb.Window inWindow)
    {
        m_XcbWindow = inWindow;
        m_Foreign = true;
        m_XcbDesktop = (parent.parent as Desktop).delegate_cast<XcbDesktop> ();

        Xcb.GetGeometryCookie cookie = m_XcbWindow.get_geometry (m_XcbDesktop.connection);
        Xcb.GetGeometryReply reply = cookie.reply (m_XcbDesktop.connection);
        if (reply != null)
        {
            m_Geometry = new Region.raw_rectangle (reply.x, reply.y,
                                                   reply.width + (reply.border_width * 2),
                                                   reply.height + (reply.border_width * 2));
        }

        // Create attributes fetcher
        m_Attributes = new XcbWindowAttributes (this);

        // Create ICCCM properties fetcher
        m_ICCCMProperties = new XcbWindowICCCMProperties (this);

        // Create EWMH properties fetcher
        m_EWMHProperties = new XcbWindowEWMHProperties (this);

        // Query attributes
        m_Attributes.query ();

        // Query iccm properties
        m_ICCCMProperties.query ();

         // Query ewmh properties
        m_EWMHProperties.query ();

        // Create events
        m_DamageEvent = new XcbDamageEvent (this);
        m_DeleteEvent = new XcbDeleteEvent (this);
    }

    public void
    create (Region inGeometry)
    {
        // Get properties
        m_Geometry = inGeometry;
        XcbWorkspace xcb_workspace = (parent as Workspace).delegate_cast<XcbWorkspace> ();
        m_XcbDesktop = (parent.parent as Desktop).delegate_cast<XcbDesktop> ();
        m_XcbWindow = Xcb.Window (m_XcbDesktop.connection);

        // Create xcb window
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

        // Create attributes fetcher
        m_Attributes = new XcbWindowAttributes (this);

        // Create ICCCM properties fetcher
        m_ICCCMProperties = new XcbWindowICCCMProperties (this);

        // Create EWMH properties fetcher
        m_EWMHProperties = new XcbWindowEWMHProperties (this);

        // Create events
        m_DamageEvent = new XcbDamageEvent (this);
        m_DeleteEvent = new XcbDeleteEvent (this);

        // Set ICCCM properties
        m_ICCCMProperties.delete_event = true;
        m_ICCCMProperties.take_focus = true;
        m_ICCCMProperties.name = name;

        // Set EWMH properties
        m_EWMHProperties.hint_type = Window.HintType.NORMAL;
        m_EWMHProperties.name = name;

        // Commit requests
        m_Attributes.commit ();
        m_ICCCMProperties.commit ();
        m_EWMHProperties.commit ();

        // Flush connection
        m_XcbDesktop.flush ();
    }

    public override void
    show ()
    {
        m_XcbWindow.map (m_XcbDesktop.connection);
        m_XcbDesktop.flush ();
    }

    public override void
    hide ()
    {
        m_XcbWindow.unmap (m_XcbDesktop.connection);
        m_XcbDesktop.flush ();
    }

    public override void
    destroy ()
    {
        m_XcbWindow.destroy(m_XcbDesktop.connection);
        m_XcbDesktop.flush ();
        m_XcbWindow = 0;
    }
}
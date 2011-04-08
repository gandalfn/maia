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
    public XcbDesktop xcb_desktop {
        get {
            return m_XcbDesktop;
        }
    }

    [CCode (notify = false)]
    public override Region geometry {
        get {
            return m_Geometry;
        }
        set {
            if (id == 0 && !(delegator as Window).is_foreign)
            {
                create (value);
            }
            else if (id != 0)
            {
                m_Geometry = value;
            }
        }
    }

    public uint event_mask { get; set; }

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

    // methods
    construct
    {
        debug ("Maia.XcbWindow.construct", "construct %s", (delegator as Window).is_foreign.to_string ());

        // Get xcb desktop
        m_XcbDesktop = ((delegator as Window).workspace.parent as Desktop).proxy as XcbDesktop;

        // If window is foreign create it with id
        if ((delegator as Window).is_foreign)
        {
            foreign (delegator.id);
        }
    }

    ~XcbWindow ()
    {
        // Destroy xcb window
        if (!(delegator as Window).is_foreign && id > 0)
            destroy ();

        // Unset request parent to cancel any pendings
        m_Attributes.parent = null;
        m_ICCCMProperties.parent = null;
        m_EWMHProperties.parent = null;
    }

    private void
    foreign (Xcb.Window inWindow)
    {
        audit (GLib.Log.METHOD, "xid 0x%lx", inWindow);
        Xcb.GetGeometryCookie cookie = ((Xcb.Window)id).get_geometry (m_XcbDesktop.connection);
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

    private void
    create (Region inGeometry)
    {
        // Get properties
        m_Geometry = inGeometry;
        XcbWorkspace xcb_workspace = (delegator as Window).workspace.proxy as XcbWorkspace;
        Xcb.Window window = Xcb.Window (m_XcbDesktop.connection);

        // Create xcb window
        m_XcbDesktop.connection.create_window (Xcb.CopyFromParent, 
                                               window, xcb_workspace.xcb_screen.root,
                                               (int16)inGeometry.clipbox.origin.x,
                                               (int16)inGeometry.clipbox.origin.y, 
                                               (uint16)inGeometry.clipbox.size.width,
                                               (uint16)inGeometry.clipbox.size.height,
                                               0, Xcb.WindowClass.INPUT_OUTPUT, 
                                               xcb_workspace.xcb_screen.root_visual, 
                                               Xcb.CW.BACK_PIXEL, 
                                               { xcb_workspace.xcb_screen.black_pixel });
        id = window;
        audit (GLib.Log.METHOD, "xid 0x%lx", window);

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
        ((Xcb.Window)id).map (m_XcbDesktop.connection);
        m_XcbDesktop.flush ();
    }

    public override void
    hide ()
    {
        ((Xcb.Window)id).unmap (m_XcbDesktop.connection);
        m_XcbDesktop.flush ();
    }

    public override void
    destroy ()
    {
        ((Xcb.Window)id).destroy(m_XcbDesktop.connection);
        m_XcbDesktop.flush ();
        id = 0;
    }
}
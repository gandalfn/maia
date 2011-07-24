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
    private uint               m_EventMask;

    private XcbWindowAttributes      m_Attributes;
    private XcbWindowGeometry        m_GeometryProperty;
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

    [CCode (notify = false)]
    public uint event_mask {
        get {
            return m_EventMask;
        }
        set {
            m_EventMask = value;
            on_property_changed ("event-mask");
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

    // methods
    construct
    {
        debug ("Maia.XcbWindow.construct", "construct %s", ((Window)delegator).is_foreign.to_string ());

        // Get xcb desktop
        m_XcbDesktop = (((Window)delegator).workspace.parent as Desktop).proxy as XcbDesktop;

        // If window is foreign create it with id
        if (((Window)delegator).is_foreign)
        {
            foreign (delegator.id);
        }
    }

    ~XcbWindow ()
    {
        // Unset request parent to cancel any pendings
        m_GeometryProperty = null;
        m_Attributes = null;
        m_ICCCMProperties = null;
        m_EWMHProperties = null;

        // Destroy xcb window
        if (!(delegator as Window).is_foreign && id > 0)
        {
            ((Xcb.Window)id).destroy(m_XcbDesktop.connection);
            id = 0;
        }
    }

    private void
    foreign (Xcb.Window inWindow)
    {
        audit (GLib.Log.METHOD, "xid 0x%lx", inWindow);

        // Create geometry fetcher
        m_GeometryProperty = new XcbWindowGeometry (this);

        // Create attributes fetcher
        m_Attributes = new XcbWindowAttributes (this);

        // Create ICCCM properties fetcher
        m_ICCCMProperties = new XcbWindowICCCMProperties (this);

        // Create EWMH properties fetcher
        m_EWMHProperties = new XcbWindowEWMHProperties (this);

        // Query geometry
        m_GeometryProperty.query ();

        // Query attributes
        m_Attributes.query ();

        // Query iccm properties
        m_ICCCMProperties.query ();

         // Query ewmh properties
        m_EWMHProperties.query ();

        // Create events
        m_DamageEvent = new XcbDamageEvent (this);
        m_DeleteEvent = new XcbDeleteEvent (this);

        // Flush connection
        m_XcbDesktop.flush ();
    }

    private void
    create (Region inGeometry)
    {
        // Get properties
        m_Geometry = inGeometry;
        unowned XcbWorkspace xcb_workspace = (XcbWorkspace)((Window)delegator).workspace.proxy;
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

        // Create geometry fetcher
        m_GeometryProperty = new XcbWindowGeometry (this);

        // Create attributes fetcher
        m_Attributes = new XcbWindowAttributes (this);

        // Create ICCCM properties fetcher
        m_ICCCMProperties = new XcbWindowICCCMProperties (this);

        // Create EWMH properties fetcher
        m_EWMHProperties = new XcbWindowEWMHProperties (this);

        // Create events
        m_DamageEvent = new XcbDamageEvent (this);
        m_DeleteEvent = new XcbDeleteEvent (this);

        // Set geometry property
        m_GeometryProperty.area = m_Geometry;

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
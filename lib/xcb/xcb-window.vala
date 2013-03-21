/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window.vala
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

internal class Maia.XcbWindow : Window
{
    // properties
    private unowned Xcb.Connection m_Connection;
    private uint                   m_EventMask;
    private bool                   m_Visible = false;
    private Graphic.Cairo.Device   m_BackBuffer;
    private Graphic.Cairo.Device   m_FrontBuffer;

    // accessors
    public override bool visible {
        get {
            return m_Visible;
        }
        set {
            if (m_Visible != value)
            {
                m_Visible = value;
                if (m_Visible)
                {
                    ((Xcb.Window)id).map (connection);
                    m_FrontBuffer = new Graphic.Cairo.Device (new Cairo.XcbSurface (m_Connection,
                                                                                    ((Xcb.Drawable)id),
                                                                                    (workspace as XcbWorkspace).visual,
                                                                                    (int)geometry.extents.size.width,
                                                                                    (int)geometry.extents.size.height));
                    if (double_buffered)
                    {
                        m_BackBuffer = new Graphic.Cairo.Device (new Cairo.Surface.similar (m_FrontBuffer.surface,
                                                                                            Cairo.Content.COLOR_ALPHA,
                                                                                            (int)geometry.extents.size.width,
                                                                                            (int)geometry.extents.size.height));
                    }
                }
                else
                {
                    ((Xcb.Window)id).unmap (connection);
                    m_FrontBuffer = null;
                    m_BackBuffer = null;
                }
            }
        }
    }

    public override Graphic.Device? device {
        get {
            return double_buffered ? m_BackBuffer : m_FrontBuffer;
        }
    }

    public override Graphic.Device? front_device {
        get {
            return m_FrontBuffer;
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
    public XcbWindow (Xcb.Window inWindow)
    {
        GLib.Object (id: inWindow);
    }

    ~XcbWindow ()
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
        Log.debug (GLib.Log.METHOD, "Create Xcb Window");

        // Create window
        id = Xcb.Window (connection);

        // Get window size
        Graphic.Rectangle extents = geometry.extents;

        // Fix window size
        if (extents.size.width == 0) extents.size.width = 100;
        if (extents.size.height == 0) extents.size.height = 100;

        // Create window
        Xcb.VoidCookie cookie = ((Xcb.Window)id).create (connection,
                                                         Xcb.COPY_FROM_PARENT,
                                                         (workspace as XcbWorkspace).screen.root,
                                                         (int16)extents.origin.x,
                                                         (int16)extents.origin.y,
                                                         (uint16)extents.size.width,
                                                         (uint16)extents.size.height,
                                                         0, Xcb.WindowClass.INPUT_OUTPUT,
                                                         (workspace as XcbWorkspace).screen.root_visual,
                                                         Xcb.Cw.BACK_PIXEL,
                                                         { (workspace as XcbWorkspace).screen.white_pixel });

        (workspace.parent as XcbApplication).request_check (cookie, (c) => {
            if (c.error != null)
                Log.warning (GLib.Log.METHOD, "Error on create window");
            else
                Log.debug (GLib.Log.METHOD, "Window has been created successfully");
        });
    }

    public override void
    paint (Graphic.Context inContext, Graphic.Region inArea)
    {
        base.paint (inContext, inArea);

        m_Connection.flush ();
    }

    public override void
    swap_buffer (Graphic.Region? inArea = null)
    {
        base.swap_buffer (inArea);

        m_Connection.flush ();
    }
}

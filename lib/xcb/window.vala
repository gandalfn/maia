/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.Window : Maia.Window, Maia.Graphic.Device
{
    // properties
    private bool            m_Realized = false;
    private Pixmap          m_BackBuffer = null;
    private Graphic.Surface m_FrontBuffer = null;

    // accessors
    public string backend {
        get {
            return "xcb/drawable";
        }
    }

    public global::Xcb.Connection connection {
        get {
            return Maia.Xcb.application.connection;
        }
    }

    public int screen_num { get; set; default = 0; }

    public override Graphic.Surface? surface {
        get {
            return m_BackBuffer != null ? m_BackBuffer.surface : null;
        }
    }

    // methods
    public Window (string inName, int inWidth, int inHeight)
    {
        base (inName, inWidth, inHeight);
    }

    ~Window ()
    {
        ((global::Xcb.Window)id).destroy (Maia.Xcb.application.connection);
    }

    internal override void
    delegate_construct ()
    {
        screen_num = Maia.Xcb.application.default_screen;
        id = global::Xcb.Window (Maia.Xcb.application.connection);

        visible = false;
    }

    internal override void
    on_resize ()
    {
        base.on_resize ();
        
        if (m_Realized)
        {
            // Create back buffer
            m_BackBuffer = new Pixmap (this, 24, (int)size.width, (int)size.height);

            // Destroy front buffer
            m_FrontBuffer = null;
        }
    }

    internal override void
    on_show ()
    {
        if (!m_Realized)
        {
            unowned global::Xcb.Screen screen = Maia.Xcb.application.connection.roots[screen_num];
            uint32 mask = global::Xcb.Cw.BACK_PIXEL |
                          global::Xcb.Cw.EVENT_MASK;
            uint32[] values = { screen.black_pixel,
                                global::Xcb.EventMask.EXPOSURE           |
                                global::Xcb.EventMask.STRUCTURE_NOTIFY   |
                                global::Xcb.EventMask.SUBSTRUCTURE_NOTIFY };

            // Create window
            ((global::Xcb.Window)id).create_checked (Maia.Xcb.application.connection,
                                                     global::Xcb.COPY_FROM_PARENT, screen.root,
                                                     (int16)position.x, (int16)position.y,
                                                     (uint16)size.width, (uint16)size.height, 0,
                                                     global::Xcb.WindowClass.INPUT_OUTPUT,
                                                     screen.root_visual, mask, values);

            m_Realized = true;
        }

        // Map window
        ((global::Xcb.Window)id).map (Maia.Xcb.application.connection);

        if (m_BackBuffer == null)
        {
            // Create back buffer
            m_BackBuffer = new Pixmap (this, 24, (int)size.width, (int)size.height);
        }

        if (m_FrontBuffer == null)
        {
            // Create front buffer
            m_FrontBuffer = new Graphic.Surface.from_device (this, (int)size.width, (int)size.height);
        }

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        // Destroy back and front buffer
        m_BackBuffer = null;
        m_FrontBuffer = null;

        if (m_Realized)
        {
            // Unmap window
            ((global::Xcb.Window)id).unmap (Maia.Xcb.application.connection);
        }

        base.on_hide ();
    }

    

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (m_Realized)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            if (m_FrontBuffer == null)
            {
                uint32[] values = { (uint32)geometry.extents.size.width, (uint32)geometry.extents.size.height };

                uint8 mask = global::Xcb.ConfigWindow.WIDTH |
                             global::Xcb.ConfigWindow.HEIGHT;

                ((global::Xcb.Window)id).configure (Maia.Xcb.application.connection, mask, values);

                // Create front buffer
                m_FrontBuffer = new Graphic.Surface.from_device (this, (int)geometry.extents.size.width, (int)geometry.extents.size.height);

                damage ();
            }
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        base.paint (inContext, inArea);

        // Swap buffer
        if (m_FrontBuffer != null && m_BackBuffer != null)
        {
            var ctx = m_FrontBuffer.context;
            ctx.clip_region(inArea);
            ctx.pattern = m_BackBuffer.surface;
            ctx.paint ();
        }

        // Flush all pendings operations
        connection.flush ();
    }
}

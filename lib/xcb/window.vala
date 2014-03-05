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
    private global::Xcb.Window m_Window;
    private uint8              m_Depth = 0;
    private bool               m_Realized = false;
    private Pixmap             m_BackBuffer = null;
    private Graphic.Surface    m_FrontBuffer = null;
    private double             m_Offset = 0.0;

    // accessors
    public string backend {
        get {
            return "xcb/window";
        }
    }

    public global::Xcb.Connection connection {
        get {
            return Maia.Xcb.application.connection;
        }
    }

    public int screen_num { get; set; default = 0; }

    public uint32 xid {
        get {
            return m_Window;
        }
    }

    public override Graphic.Surface? surface {
        get {
            return m_BackBuffer != null ? m_BackBuffer.surface : null;
        }
    }

    private bool is_mapped {
        get {
            bool ret = false;

            // Get window state
            global::Xcb.GenericError? err = null;
            var reply = m_Window.get_attributes (connection).reply (connection, out err);
            if (err == null)
            {
                ret = reply.map_state == global::Xcb.MapState.VIEWABLE;
            }

            return ret;
        }
    }

    private uint8 depth {
        get {
            if (m_Depth == 0)
            {
                // Get window state
                global::Xcb.GenericError? err = null;
                var reply = m_Window.get_attributes (connection).reply (connection, out err);
                if (err == null)
                {
                    unowned global::Xcb.Screen screen = connection.roots[screen_num];

                    foreach (unowned global::Xcb.Depth? depth in screen)
                    {
                        foreach (unowned global::Xcb.Visualtype? visual in depth)
                        {
                            if (visual.visual_id == reply.visual)
                            {
                                m_Depth = depth.depth;
                                return m_Depth;
                            }
                        }
                    }
                }
                else
                {
                    Log.error (GLib.Log.METHOD, Log.Category.MAIN, "error on get window attributes");
                }
            }

            return m_Depth;
        }
    }

    // methods
    public Window (string inName, int inWidth, int inHeight)
    {
        base (inName, inWidth, inHeight);
    }

    ~Window ()
    {
        m_Window.destroy (Maia.Xcb.application.connection);
    }

    internal override void
    delegate_construct ()
    {
        screen_num = Maia.Xcb.application.default_screen;
        m_Window = global::Xcb.Window (Maia.Xcb.application.connection);

        damage_event     = new Core.Event ("damage",     ((int)m_Window).to_pointer ());
        geometry_event   = new Core.Event ("geometry",   ((int)m_Window).to_pointer ());
        visibility_event = new Core.Event ("visibility", ((int)m_Window).to_pointer ());
        delete_event     = new Core.Event ("delete",     ((int)m_Window).to_pointer ());
        destroy_event    = new Core.Event ("destroy",    ((int)m_Window).to_pointer ());
        mouse_event      = new Core.Event ("mouse",      ((int)m_Window).to_pointer ());
        keyboard_event   = new Core.Event ("keyboard",   ((int)m_Window).to_pointer ());

        scroll_event.connect (on_scroll);

        visible = false;
    }

    private bool
    on_scroll (Scroll inScroll, Graphic.Point inPosition)
    {
        if (inScroll == Scroll.UP)
            m_Offset++;
        else if (inScroll == Scroll.DOWN)
            m_Offset--;

        damage ();

        return true;
    }

    internal override void
    on_show ()
    {
        Graphic.Size item_size = size;

        if (!m_Realized)
        {
            unowned global::Xcb.Screen screen = Maia.Xcb.application.connection.roots[screen_num];
            uint32 mask = global::Xcb.Cw.BACK_PIXEL |
                          global::Xcb.Cw.EVENT_MASK;
            uint32[] values = { screen.black_pixel,
                                global::Xcb.EventMask.EXPOSURE            |
                                global::Xcb.EventMask.STRUCTURE_NOTIFY    |
                                global::Xcb.EventMask.SUBSTRUCTURE_NOTIFY |
                                global::Xcb.EventMask.BUTTON_PRESS        |
                                global::Xcb.EventMask.BUTTON_RELEASE      |
                                global::Xcb.EventMask.KEY_PRESS           |
                                global::Xcb.EventMask.KEY_RELEASE         |
                                global::Xcb.EventMask.POINTER_MOTION };

            // Create window
            m_Window.create_checked (Maia.Xcb.application.connection,
                                     global::Xcb.COPY_FROM_PARENT, screen.root,
                                     (int16)position.x, (int16)position.y,
                                     (uint16)item_size.width, (uint16)item_size.height, 0,
                                     global::Xcb.WindowClass.INPUT_OUTPUT,
                                     screen.root_visual, mask, values);

            // Set properties
            global::Xcb.Atom[] properties = { Xcb.application.atoms[AtomType.WM_DELETE_WINDOW],
                                              Xcb.application.atoms[AtomType.WM_TAKE_FOCUS] };
            m_Window.change_property (Xcb.application.connection, global::Xcb.PropMode.REPLACE,
                                      Xcb.application.atoms[AtomType.WM_PROTOCOLS], global::Xcb.AtomType.ATOM,
                                      32, (void[]?)properties);

            m_Realized = true;
        }

        // Get window state
        if (!is_mapped)
        {
            // Map window
            m_Window.map (Maia.Xcb.application.connection);
        }

        if (m_BackBuffer == null)
        {
            // Create back buffer
            m_BackBuffer = new Pixmap (this, depth, (int)item_size.width, (int)item_size.height);
        }

        if (m_FrontBuffer == null)
        {
            // Create front buffer
            m_FrontBuffer = new Graphic.Surface.from_device (this, (int)item_size.width, (int)item_size.height);
        }

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        if (m_Realized)
        {
            // Destroy back and front buffer
            m_BackBuffer = null;
            m_FrontBuffer = null;

            if (is_mapped)
            {
                // Unmap window
                m_Window.unmap (Maia.Xcb.application.connection);
            }
        }

        base.on_hide ();
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Size ret = base.size_request (inSize);

        if (m_Realized)
        {
            // Size has change
            if (m_BackBuffer == null || !m_BackBuffer.size.equal (ret))
            {
                // Create back buffer
                m_BackBuffer = new Pixmap (this, depth, (int)ret.width, (int)ret.height);

                // Destroy front buffer
                m_FrontBuffer = null;
            }
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        // Resize front buffer
        if (m_FrontBuffer == null)
        {
            m_FrontBuffer = new Graphic.Surface.from_device (this,
                                                             (int)geometry.extents.size.width,
                                                             (int)geometry.extents.size.height);
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        base.paint (inContext, inArea);

        // Swap buffer
        if (m_FrontBuffer != null)
        {
            var ctx = m_FrontBuffer.context;
            ctx.save ();
            {
                ctx.operator = Graphic.Operator.SOURCE;
                ctx.clip_region(inArea);
                ctx.pattern = inContext.surface;
                ctx.pattern.transform.translate (0, m_Offset);
                ctx.paint ();
                ctx.pattern.transform.translate (0, -m_Offset);
            }
            ctx.restore ();
        }

        // Flush all pendings operations
        connection.flush ();
    }

    internal override bool
    on_grab_pointer (Item inItem)
    {
        bool ret = base.on_grab_pointer (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_pointer_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
            m_Window.grab_pointer (connection, true,
                                   global::Xcb.EventMask.EXPOSURE            |
                                   global::Xcb.EventMask.STRUCTURE_NOTIFY    |
                                   global::Xcb.EventMask.SUBSTRUCTURE_NOTIFY |
                                   global::Xcb.EventMask.BUTTON_PRESS        |
                                   global::Xcb.EventMask.BUTTON_RELEASE      |
                                   global::Xcb.EventMask.POINTER_MOTION,
                                   global::Xcb.GrabMode.ASYNC,
                                   global::Xcb.GrabMode.ASYNC,
                                   m_Window, global::Xcb.NONE, global::Xcb.CURRENT_TIME);
        }

        return ret;
    }

    internal override void
    on_ungrab_pointer (Item inItem)
    {
        base.on_ungrab_pointer (inItem);

        if (grab_pointer_item == null)
        {
            connection.ungrab_pointer (global::Xcb.CURRENT_TIME);
        }
    }

    internal override void
    on_set_pointer_cursor (Cursor inCursor)
    {
        uint32 mask = global::Xcb.Cw.CURSOR;
        uint32[] values = { create_cursor (connection, inCursor) };
        m_Window.change_attributes (connection, mask, values);
    }

    internal override void
    on_move_pointer (Graphic.Point inPosition)
    {
        var item_size = size_requested.is_empty () ? size : size_requested;
        m_Window.warp_pointer (connection, m_Window, 0, 0, (uint16)item_size.width, (uint16)item_size.height, (int16)inPosition.x, (int16)inPosition.y);
        connection.flush ();
    }
}

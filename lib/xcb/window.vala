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
    // types
    private class Sibling
    {
        private unowned Window? m_Window;
        private unowned Window? m_Sibling;

        public Sibling (Window inWindow, Window inSibling)
        {
            m_Window = inWindow;
            m_Sibling = inSibling;

            m_Sibling.notify["visible"].connect (on_sibling_event);
            m_Sibling.repair.connect (on_sibling_event);

            m_Sibling.weak_ref (on_sibling_destroyed);
        }

        ~Sibling ()
        {
            if (m_Sibling is Window)
            {
                m_Sibling.notify["visible"].disconnect (on_sibling_event);
                m_Sibling.repair.disconnect (on_sibling_event);
                m_Sibling.weak_unref (on_sibling_destroyed);
            }
        }

        private void
        on_sibling_destroyed ()
        {
            m_Window.m_Siblings.remove (this);

            if (m_Window.area != null)
            {
                m_Window.m_WindowDamaged = m_Window.area.copy ();
            }
        }

        private void
        on_sibling_event ()
        {
            if (m_Window.area != null)
            {
                m_Window.m_WindowDamaged = m_Window.area.copy ();
            }
        }
    }
    // properties
    private  global::Xcb.Window   m_Window;
    private  global::Xcb.Colormap m_Colormap = global::Xcb.NONE;
    internal Graphic.Rectangle    m_WindowGeometry;
    private  Graphic.Region       m_WindowDamaged;
    private  uint8                m_Depth = 0;
    private  bool                 m_Realized = false;
    private  Pixmap               m_BackBuffer = null;
    private  Graphic.Surface      m_FrontBuffer = null;
    private  Core.EventListener   m_ParentVisibilityListener = null;
    private  Core.Array<Sibling>  m_Siblings = null;

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

    public uint32 visual {
        get {
            return Maia.Xcb.application.find_visual_from_depth (screen_num, depth);
        }
    }

    internal override uint8 depth {
        get {
            if (m_Depth == 0)
            {
                // Get window state
                unowned global::Xcb.Screen screen = connection.roots[screen_num];

                foreach (unowned global::Xcb.Depth? depth in screen)
                {
                    foreach (unowned global::Xcb.Visualtype? visual in depth)
                    {
                        if (visual.visual_id == screen.root_visual)
                        {
                            m_Depth = depth.depth;
                            return m_Depth;
                        }
                    }
                }
            }

            return m_Depth;
        }
        set {
            m_Depth = value;
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

            if (m_Realized)
            {
                // Get window state
                global::Xcb.GenericError? err = null;
                var reply = m_Window.get_attributes (connection).reply (connection, out err);
                if (err == null)
                {
                    ret = reply.map_state == global::Xcb.MapState.VIEWABLE;
                }

                if (ret && application.have_unmap (this))
                    ret = false;
                else if (!ret && application.have_map (this))
                    ret = true;
            }

            return ret;
        }
    }

    // methods
    public Window (string inName, int inWidth, int inHeight)
    {
        base (inName, inWidth, inHeight);
    }

    ~Window ()
    {
        Log.debug ("~Window", Log.Category.MAIN, "");


        if (m_Colormap != global::Xcb.NONE)
        {
            m_Colormap.free (connection);
        }

        Maia.Xcb.application.unregister_window (this);
        m_Window.destroy (Maia.Xcb.application.connection);
    }

    private void
    on_main_window_changed ()
    {
        if (m_Realized && window != null)
        {
            // Check if window is not already reparented
            var reply = m_Window.query_tree (connection).reply (connection);

            if (reply == null || reply.parent != ((Window)window).xid)
            {
                // push reparent
                application.push_request (new ReparentRequest (this));
            }
        }

        m_ParentVisibilityListener = null;

        if (window != null && foreign == 0)
        {
            // listen parent visibility
            m_ParentVisibilityListener = window.visibility_event.subscribe (on_parent_visibility_changed);
        }
    }

    private void
    on_parent_visibility_changed (Core.EventArgs? inArgs)
    {
        if (m_Realized && visible && visible != window.visible && foreign == 0)
        {
            if (window.visible)
                application.push_request (new MapRequest (this));
            else
                application.push_request (new UnmapRequest (this));
        }
    }

    private void
    on_device_transform_changed ()
    {
        // Clear backbuffer on device transform changed
        if (m_BackBuffer != null)
        {
            m_BackBuffer.clear ();
        }
    }

    private void
    paint_sibling (Graphic.Context inContext, Window inWindow, Graphic.Point inPosition, Graphic.Rectangle inArea) throws Graphic.Error
    {
        if (inWindow is Window && inWindow != this && inWindow.surface != null)
        {
            // Connect onto sibling
            m_Siblings.insert (new Sibling (this, inWindow));
            Graphic.Rectangle area = Graphic.Rectangle (0, 0, inWindow.surface.size.width, inWindow.surface.size.height);
            area.intersect (inArea);
            if (!area.is_empty ())
            {
                inWindow.surface.flush ();
                inContext.pattern = inWindow.surface;
                inContext.pattern.transform = new Graphic.Transform.init_translate (inPosition.x, inPosition.y);
                inContext.paint ();
                inContext.pattern.transform = new Graphic.Transform.identity ();

                foreach (unowned Window child in inWindow.query_tree ())
                {
                    var child_area = area;
                    child_area.translate (child.position.invert ());

                    var pos = inPosition;
                    pos.translate (child.position.invert ());

                    paint_sibling (inContext, child, pos, child_area);
                }
            }
        }
    }

    private void
    flush_buffer (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_WindowDamaged != null && !m_WindowDamaged.is_empty ())
        {
            var damaged_area = m_WindowDamaged.copy ();

            // Add device transform to damage
            var matrix = device_transform.matrix;
            matrix.x0 = 0;
            matrix.y0 = 0;
            damaged_area.transform (new Graphic.Transform.from_matrix (matrix));

            // Add window transform to damage
            damaged_area.transform (transform);

            // Swap buffer
            if (m_BackBuffer != null)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"$name swap buffer: $(damaged_area.extents) $(transform.matrix) $(device_transform.matrix)");

                inContext.save ();
                {
                    // Clip damaged region
                    inContext.clip_region (damaged_area);

                    // We have a parent window
                    if (window != null && depth == 32)
                    {
                        m_Siblings.clear ();

                        inContext.operator = Graphic.Operator.CLEAR;
                        inContext.paint ();

                        inContext.operator = Graphic.Operator.OVER;

                        // Paint parent content into background
                        paint_sibling (inContext, (Window)window, position, Graphic.Rectangle (position.x, position.y, m_WindowGeometry.size.width, m_WindowGeometry.size.height));
                    }

                    // Swap buffer
                    inContext.surface.flush ();
                    inContext.pattern = m_BackBuffer.surface;
                    inContext.paint ();
                }
                inContext.restore ();
            }

            // Flush all pendings operations
            Maia.Xcb.application.sync ();

            m_WindowDamaged = null;
        }
    }

    internal override void
    delegate_construct ()
    {
        // Get screen num
        screen_num = Maia.Xcb.application.default_screen;

        // Get foreign xid if set
        if (foreign != 0)
        {
            m_Window = foreign;
            m_Realized = true;
        }

        // Generate window xid
        if (m_Window == global::Xcb.NONE)
        {
            m_Window = global::Xcb.Window (Maia.Xcb.application.connection);
        }

        // Create event
        damage_event     = new Core.Event ("damage",     ((int)m_Window).to_pointer ());
        geometry_event   = new Core.Event ("geometry",   ((int)m_Window).to_pointer ());
        visibility_event = new Core.Event ("visibility", ((int)m_Window).to_pointer ());
        delete_event     = new Core.Event ("delete",     ((int)m_Window).to_pointer ());
        destroy_event    = new Core.Event ("destroy",    ((int)m_Window).to_pointer ());
        mouse_event      = new Core.Event ("mouse",      ((int)m_Window).to_pointer ());
        keyboard_event   = new Core.Event ("keyboard",   ((int)m_Window).to_pointer ());

        // window is hidden by default
        visible = false;

        // set main window has this window
        window = this;

        // connect onto window changed
        notify["window"].connect (on_main_window_changed);

        // connect onto device transform changed
        notify["device-transform"].connect (on_device_transform_changed);

        // create siblings windows
        m_Siblings = new Core.Array<Sibling> ();

        // register has known windows
        Maia.Xcb.application.register_window (this);
    }

    internal override void
    on_move ()
    {
        base.on_move ();

        if (m_Realized && foreign == 0)
        {
            var reply = m_Window.get_geometry (connection).reply (connection);
            if (reply != null)
            {
                var item_position = position;

                if (reply.x != item_position.x || reply.y != item_position.y)
                {
                    application.push_request (new MoveRequest (this, item_position));
                }
            }
        }
    }

    internal override void
    on_resize ()
    {
        if (m_Realized && geometry != null && foreign == 0)
        {
            var reply = m_Window.get_geometry (connection).reply (connection);
            if (reply != null)
            {
                var item_size = geometry.extents.size;
                item_size.transform (device_transform);

                if ((uint32)(reply.width  + (reply.border_width * 2)) != (uint32)GLib.Math.ceil (item_size.width) ||
                    (uint32)(reply.height + (reply.border_width * 2)) != (uint32)GLib.Math.ceil (item_size.height))
                {
                    application.push_request (new ResizeRequest (this, item_size));
                }
            }
        }

        base.on_resize ();
    }

    internal override void
    on_mouse_event (Core.EventArgs? inArgs)
    {
        unowned MouseEventArgs? mouse_args = inArgs as MouseEventArgs;

        if (mouse_args != null)
        {
            var pos = mouse_args.position;
            base.on_mouse_event (new MouseEventArgs (mouse_args.flags, mouse_args.button, pos.x, pos.y));
        }
    }

    internal override void
    on_show ()
    {
        var item_size = size;
        item_size.transform (device_transform);
        m_WindowGeometry = Graphic.Rectangle (position.x, position.y, item_size.width, item_size.height);

        if (!m_Realized)
        {
            // Get current screen
            unowned global::Xcb.Screen screen = Maia.Xcb.application.connection.roots[screen_num];

            // Prepare window properties
            uint32 mask = global::Xcb.Cw.BACK_PIXMAP;
            uint32[] values = { global::Xcb.BackPixmap.NONE };

            mask |= global::Xcb.Cw.BACKING_STORE;
            values += global::Xcb.BackingStore.ALWAYS;

            mask |= global::Xcb.Cw.SAVE_UNDER;
            values += 1;

            uint32 event_mask = global::Xcb.EventMask.EXPOSURE            |
                                global::Xcb.EventMask.STRUCTURE_NOTIFY    |
                                global::Xcb.EventMask.BUTTON_PRESS        |
                                global::Xcb.EventMask.BUTTON_RELEASE      |
                                global::Xcb.EventMask.KEY_PRESS           |
                                global::Xcb.EventMask.KEY_RELEASE         |
                                global::Xcb.EventMask.POINTER_MOTION;

            if (visual != screen.root_visual)
            {
                mask |= global::Xcb.Cw.BORDER_PIXEL;
                values += 0;

                mask |= global::Xcb.Cw.EVENT_MASK;
                values += event_mask;

                // Create colormap for window rendering
                m_Colormap = global::Xcb.Colormap (connection);
                m_Colormap.create (connection, global::Xcb.ColormapAlloc.NONE, screen.root, visual);

                mask |= global::Xcb.Cw.COLORMAP;
                values += m_Colormap;
            }
            else
            {
                mask |= global::Xcb.Cw.EVENT_MASK;
                values += event_mask;
            }

            // Create window
            var cookie = m_Window.create_checked (connection,
                                                  depth, window != null ? ((Window)window).xid : screen.root,
                                                  (int16)GLib.Math.floor (m_WindowGeometry.origin.x),
                                                  (int16)GLib.Math.floor (m_WindowGeometry.origin.y),
                                                  (uint16)GLib.Math.ceil (double.max (1, m_WindowGeometry.size.width)),
                                                  (uint16)GLib.Math.ceil (double.max (1, m_WindowGeometry.size.height)),
                                                  0,
                                                  global::Xcb.WindowClass.INPUT_OUTPUT,
                                                  visual, mask, values);

            if (connection.request_check (cookie) != null)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "Error on create window");
            }
            else
            {
                if (window == null)
                {
                    // Set properties
                    global::Xcb.Atom[] properties = { Xcb.application.atoms[AtomType.WM_DELETE_WINDOW],
                                                      Xcb.application.atoms[AtomType.WM_TAKE_FOCUS] };
                    m_Window.change_property (connection, global::Xcb.PropMode.REPLACE,
                                              Xcb.application.atoms[AtomType.WM_PROTOCOLS],
                                              global::Xcb.AtomType.ATOM,
                                              32, (void[]?)properties);

                    ulong[] mwm_hints = { 2, 1, 0, 0, 0 };
                    m_Window.change_property (connection, global::Xcb.PropMode.REPLACE,
                                              Xcb.application.atoms[AtomType._MOTIF_WM_HINTS],
                                              Xcb.application.atoms[AtomType._MOTIF_WM_HINTS],
                                              32, (void[]?)mwm_hints);
                }

                // set window damaged area
                m_Realized = true;
            }
        }

        // Get window state
        if (!is_mapped && foreign == 0)
        {
            // Map window
            application.push_request (new MapRequest (this));
        }

        m_BackBuffer = null;
        m_FrontBuffer = null;

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        if (m_Realized && foreign == 0)
        {
            // Destroy back and front buffer
            m_BackBuffer = null;
            m_FrontBuffer = null;

            if (is_mapped)
            {
                // Unmap window
                application.push_request (new UnmapRequest (this));
            }
        }

        m_WindowGeometry = Graphic.Rectangle (0, 0, 0, 0);

        base.on_hide ();
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

    internal override bool
    on_grab_keyboard (Item inItem)
    {
        bool ret = base.on_grab_keyboard (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_keyboard_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
            m_Window.grab_keyboard (connection, true,
                                    global::Xcb.CURRENT_TIME,
                                    global::Xcb.GrabMode.ASYNC,
                                    global::Xcb.GrabMode.ASYNC);
        }

        return ret;
    }

    internal override void
    on_ungrab_keyboard (Item inItem)
    {
        base.on_ungrab_keyboard (inItem);

        if (grab_keyboard_item == null)
        {
            connection.ungrab_keyboard (global::Xcb.CURRENT_TIME);
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
        var item_size = size;
        item_size.transform (device_transform);

        m_Window.warp_pointer (connection, m_Window, 0, 0, (uint16)GLib.Math.ceil (item_size.width), (uint16)GLib.Math.ceil (item_size.height), (int16)inPosition.x, (int16)inPosition.y);
        connection.flush ();
    }

    internal override void
    on_grab_focus (Item? inItem)
    {
        base.on_grab_focus (inItem);

        // an item has focus set window has keyboard focus
        if (inItem != null)
        {
            m_Window.set_input_focus (connection, global::Xcb.InputFocus.PARENT, global::Xcb.CURRENT_TIME);
        }
        else
        {
            ((global::Xcb.Window)global::Xcb.NONE).set_input_focus (connection, global::Xcb.InputFocus.PARENT, global::Xcb.CURRENT_TIME);
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (!inAllocation.extents.is_empty () && visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            base.update (inContext, inAllocation);

            var window_size = geometry.extents.size;
            window_size.transform (device_transform);

            // Size has change
            if (m_BackBuffer == null ||
                (uint32)GLib.Math.ceil (m_BackBuffer.size.width) != (uint32)GLib.Math.ceil (window_size.width) ||
                (uint32)GLib.Math.ceil (m_BackBuffer.size.height) != (uint32)GLib.Math.ceil (window_size.height))
            {
                // Create back buffer
                m_BackBuffer = new Pixmap (this, depth, (int)GLib.Math.ceil (window_size.width), (int)GLib.Math.ceil (window_size.height));
            }

            // Destroy front buffer
            m_FrontBuffer = null;

            var reply = m_Window.get_geometry (connection).reply (connection);
            if (reply != null)
            {
                if ((uint32)(reply.width + (reply.border_width * 2)) != (uint32)GLib.Math.ceil (window_size.width) ||
                    (uint32)(reply.height + (reply.border_width * 2)) != (uint32)GLib.Math.ceil (window_size.height))
                {
                    // Push window resize
                    application.push_request (new ResizeRequest (this, window_size));
                }
            }

            // Set window geometry
            m_WindowGeometry = Graphic.Rectangle (geometry.extents.origin.x, geometry.extents.origin.y, window_size.width, window_size.height);
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            // Paint content
            base.paint (inContext, inArea);

            // Add swap damaged
            if (m_WindowDamaged != null)
                m_WindowDamaged.union_ (inArea);
            else
                m_WindowDamaged = inArea.copy ();
        }
        inContext.restore ();
    }

    internal override void
    swap_buffer ()
    {
        // Flush all pending request
        flush ();

        if (m_WindowDamaged != null && geometry != null)
        {
            // Resize front buffer
            if (m_FrontBuffer == null)
            {
                m_FrontBuffer = new Graphic.Surface.from_device (this,
                                                                 (int)GLib.Math.ceil (m_WindowGeometry.size.width),
                                                                 (int)GLib.Math.ceil (m_WindowGeometry.size.height));
            }

            try
            {
                if (m_FrontBuffer != null)
                {
                    var ctx = m_FrontBuffer.context;

                    ctx.operator = Graphic.Operator.SOURCE;

                    // Flush buffer under front buffer
                    flush_buffer (ctx);
                }
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, "Error on window swap buffer: %s", err.message);
            }
        }
    }

    internal override void
    flush ()
    {
        application.flush ();
    }

    internal int
    compare_xcb (Window inOther)
    {
        return (int)(m_Window - inOther.m_Window);
    }

    internal int
    compare_with_xid (uint32 inXid)
    {
        return (int)(m_Window - inXid);
    }

    public Core.Array<unowned Window>
    query_tree ()
    {
        Core.Array<unowned Window> ret = new Core.Array<unowned Window> ();

        var reply = m_Window.query_tree (connection).reply (connection);
        if (reply != null)
        {
            for (int cpt = 0; cpt < reply.children_len; ++cpt)
            {
                var window = Maia.Xcb.application.lookup_window (reply.children[cpt]);
                if (window != null)
                {
                    ret.insert (window);
                }
            }
        }

        return ret;
    }
}

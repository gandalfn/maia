/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view.vala
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

internal class Maia.Xcb.View : Drawable
{
    // types
    private delegate void DestroyFunc ();

    private class Sibling
    {
        private unowned View? m_View;
        private unowned View? m_Sibling;

        public Sibling (View inView, View inSibling)
        {
            m_View = inView;
            m_Sibling = inSibling;

            m_Sibling.updated.connect (on_sibling_updated);

            m_Sibling.weak_ref (on_sibling_destroyed);
        }

        ~Sibling ()
        {
            if (m_Sibling != null)
            {
                m_Sibling.updated.disconnect (on_sibling_updated);
                m_Sibling.weak_unref (on_sibling_destroyed);
            }
        }

        private void
        on_sibling_destroyed ()
        {
            m_Sibling = null;

            if (m_View is View && m_View.is_mapped)
            {
                var view_size = m_View.size;
                view_size.transform (m_View.device_transform);
                m_View.damaged = new Graphic.Region (Graphic.Rectangle (0, 0, view_size.width, view_size.height));
            }

            m_View.m_Siblings.remove (this);
        }

        private void
        on_sibling_updated ()
        {
            if (m_Sibling != null && m_View.is_mapped)
            {
                var view_size = m_View.size;
                view_size.transform (m_View.device_transform);
                m_View.damaged = new Graphic.Region (Graphic.Rectangle (0, 0, view_size.width, view_size.height));
            }
        }
    }

    public class Iterator
    {
        // properties
        private Core.Array<unowned View>    m_Childs;
        private Core.Iterator<unowned View> m_Iterator;

        internal Iterator (View inView)
        {
            m_Childs = new Core.Array<unowned View> ();

            var reply = ((global::Xcb.Window)inView.xid).query_tree (inView.connection).reply (inView.connection);
            if (reply != null)
            {
                for (int cpt = 0; cpt < reply.children_len; ++cpt)
                {
                    var view = Maia.Xcb.application.lookup_view (reply.children[cpt]);
                    if (view != null)
                    {
                        m_Childs.insert (view);
                    }
                }
            }

            m_Iterator = m_Childs.iterator ();
        }

        public bool
        next ()
        {
            return m_Iterator.next ();
        }

        public unowned View?
        @get ()
        {
            return m_Iterator.@get ();
        }
    }

    // properties
    private Graphic.Transform    m_Transform = new Graphic.Transform.identity ();
    private Graphic.Transform    m_DeviceTransform = new Graphic.Transform.identity ();
    private unowned View?        m_Parent;
    private global::Xcb.Colormap m_Colormap = global::Xcb.NONE;
    private Graphic.Point        m_Position;
    private bool                 m_Foreign = false;
    private bool                 m_Realized = false;
    private Pixmap               m_BackBuffer = null;
    private Graphic.Surface      m_FrontBuffer = null;
    private Core.Array<Sibling>  m_Siblings = null;
    private unowned DestroyFunc? m_Func = null;

    // signals
    public signal void mapped ();
    public signal void updated ();

    // accessors
    public override string backend {
        get {
            return "xcb/window";
        }
    }

    public override uint8 depth {
        get {
            if (base.depth == 0)
            {
                // Get window state
                unowned global::Xcb.Screen screen = connection.roots[screen_num];

                foreach (unowned global::Xcb.Depth? depth in screen)
                {
                    foreach (unowned global::Xcb.Visualtype? visual in depth)
                    {
                        if (visual.visual_id == screen.root_visual)
                        {
                            base.depth = depth.depth;
                            return depth.depth;
                        }
                    }
                }
            }

            return base.depth;
        }
        set {
            base.depth = value;
        }
    }

    public unowned Pixmap? backbuffer {
        get {
            return m_BackBuffer;
        }
    }

    public override Graphic.Surface? surface {
        get {
            return m_BackBuffer != null ? m_BackBuffer.surface : null;
        }
    }

    public View? parent {
        get {
            return m_Parent;
        }
        set {
            if (m_Parent != value)
            {
                if (m_Parent != null)
                {
                    m_Parent.mapped.disconnect (on_parent_mapped);
                    m_Parent.m_Func = null;
                }

                m_Parent = value;

                if (m_Parent != null)
                {
                    m_Parent.mapped.connect (on_parent_mapped);
                    m_Parent.m_Func = on_parent_destroyed;
                }

                // clear siblings
                m_Siblings.clear ();

                on_parent_mapped ();
            }
        }
    }

    public bool is_mapped {
        get {
            bool ret = false;

            if (m_Realized)
            {
                // Get window state
                global::Xcb.GenericError? err = null;
                var reply = ((global::Xcb.Window)xid).get_attributes (connection).reply (connection, out err);
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

    public bool realized {
        get {
            return m_Realized;
        }
    }

    public Graphic.Point position {
        get {
            return m_Position;
        }
        set {
            if (!m_Position.equal (value))
            {
                m_Position = value;

                if (m_Realized && !m_Foreign)
                {
                    var reply = ((global::Xcb.Window)xid).get_geometry (connection).reply (connection);
                    if (reply != null)
                    {
                        if (reply.x != m_Position.x || reply.y != m_Position.y)
                        {
                            application.push_request (new MoveRequest (this));
                        }
                    }
                }
            }
        }
    }

    public override Graphic.Size size {
        get {
            return base.size;
        }
        set {
            if (!base.size.equal (value))
            {
                base.size = Graphic.Size (double.max (1, value.width), double.max (1, value.height));

                resize ();
            }
        }
        default = Graphic.Size (0, 0);
    }

    public Graphic.Transform device_transform {
        get {
            return m_DeviceTransform;
        }
        set {
            m_DeviceTransform = value;

            resize ();
        }
    }

    public Graphic.Transform transform {
        get {
            return m_Transform;
        }
        set {
            m_Transform = value;

            resize ();
        }
    }

    public Graphic.Region damaged { get; set; default = null; }

    public bool managed { get; set; default = true; }

    // methods
    construct
    {
        // create siblings windows
        m_Siblings = new Core.Array<Sibling> ();

        // register has known windows
        Maia.Xcb.application.register_view (this);
    }

    public View (int inWidth, int inHeight)
    {
        global::Xcb.Window win = global::Xcb.Window (Maia.Xcb.application.connection);
        GLib.Object (xid: win, size: Graphic.Size (inWidth, inHeight));
    }

    public View.foreign (uint32 inForeign)
    {
        GLib.Object (xid: inForeign);
        m_Foreign = true;
        m_Realized = true;
    }

    ~View ()
    {
        if (m_Func != null)
        {
            m_Func ();
        }

        if (m_Parent != null)
        {
            m_Parent.mapped.disconnect (on_parent_mapped);
            m_Parent.m_Func = null;
        }

        m_BackBuffer = null;
        m_FrontBuffer = null;

        if (m_Colormap != global::Xcb.NONE)
        {
            m_Colormap.free (connection);
        }

        Maia.Xcb.application.unregister_view (this);
        if (!m_Foreign)
        {
            ((global::Xcb.Window)xid).destroy (Maia.Xcb.application.connection);
        }
    }

    private void
    on_parent_destroyed ()
    {
        m_Parent = null;

        m_Siblings.clear ();

        on_parent_mapped ();
    }

    private void
    on_parent_mapped ()
    {
        if (m_Realized)
        {
            // Check if window is not already reparented
            var reply = ((global::Xcb.Window)xid).query_tree (connection).reply (connection);

            if (m_Parent == null || reply == null || reply.parent != m_Parent.xid)
            {
                // push reparent
                application.push_request (new ReparentRequest (this));
            }
        }
    }

    private void
    resize ()
    {
        if (m_Realized && !m_Foreign && !size.is_empty ())
        {
            var view_size = size;
            view_size.transform (device_transform);

            if (m_BackBuffer == null ||
                (uint32)GLib.Math.ceil (m_BackBuffer.size.width) != (uint32)GLib.Math.ceil (view_size.width) ||
                (uint32)GLib.Math.ceil (m_BackBuffer.size.height) != (uint32)GLib.Math.ceil (view_size.height))
            {
                m_BackBuffer = new Pixmap (screen_num, depth, (int)view_size.width, (int)view_size.height);
            }

            m_FrontBuffer = null;

            var reply = ((global::Xcb.Window)xid).get_geometry (connection).reply (connection);
            if (reply != null)
            {
                if ((uint32)(reply.width  + (reply.border_width * 2)) != (uint32)GLib.Math.ceil (view_size.width) ||
                    (uint32)(reply.height + (reply.border_width * 2)) != (uint32)GLib.Math.ceil (view_size.height))
                {
                    application.push_request (new ResizeRequest (this));
                }
            }
        }
    }

    private void
    paint_sibling (Graphic.Context inContext, View inView, Graphic.Point inPosition, Graphic.Rectangle inArea) throws Graphic.Error
    {
        if (inView is View && inView != this && inView.surface != null)
        {
            // Connect onto sibling
            m_Siblings.insert (new Sibling (this, inView));
            Graphic.Rectangle area = Graphic.Rectangle (0, 0, inView.surface.size.width, inView.surface.size.height);
            area.intersect (inArea);
            if (!area.is_empty ())
            {
                inView.surface.flush ();
                inContext.pattern = inView.surface;
                inContext.pattern.transform = new Graphic.Transform.init_translate (inPosition.x, inPosition.y);
                inContext.paint ();
                inContext.pattern.transform = new Graphic.Transform.identity ();

                foreach (unowned View child in inView)
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
        if (damaged != null && !damaged.is_empty ())
        {
            var damaged_area = damaged.copy ();

            // Add device transform to damage
            var matrix = device_transform.matrix;
            matrix.x0 = 0;
            matrix.y0 = 0;
            damaged_area.transform (new Graphic.Transform.from_matrix (matrix));

            damaged_area.transform (transform);

            // Swap buffer
            if (m_BackBuffer != null)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"$xid swap buffer: $(damaged_area.extents) $(transform.matrix)");

                inContext.save ();
                {
                    // Clip damaged region
                    inContext.clip_region (damaged_area);

                    // We have a parent
                    if (parent != null && depth == 32)
                    {
                        m_Siblings.clear ();

                        inContext.operator = Graphic.Operator.CLEAR;
                        inContext.paint ();

                        inContext.operator = Graphic.Operator.OVER;

                        var view_size = size;
                        view_size.transform (device_transform);

                        // Paint parent content into background
                        paint_sibling (inContext, parent, position, Graphic.Rectangle (position.x, position.y, view_size.width, view_size.height));
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

            damaged = null;
        }
    }

    public void
    show ()
    {
        var view_size = size;
        view_size.transform (device_transform);

        if (!m_Realized && !m_Foreign)
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
            var cookie = ((global::Xcb.Window)xid).create_checked (connection,
                                                                   depth,
                                                                   parent != null && parent.m_Realized ? parent.xid : screen.root,
                                                                   (int16)GLib.Math.floor (position.x),
                                                                   (int16)GLib.Math.floor (position.y),
                                                                   (uint16)GLib.Math.ceil (double.max (1, view_size.width)),
                                                                   (uint16)GLib.Math.ceil (double.max (1, view_size.height)),
                                                                   0,
                                                                   global::Xcb.WindowClass.INPUT_OUTPUT,
                                                                   visual, mask, values);
            global::Xcb.GenericError? err = connection.request_check (cookie);
            if (err != null)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, @"Error on create window $(err.error_code)");
            }
            else
            {
                if (parent == null && managed)
                {
                    // Set properties
                    global::Xcb.Atom[] properties = { Xcb.application.atoms[AtomType.WM_DELETE_WINDOW],
                                                      Xcb.application.atoms[AtomType.WM_TAKE_FOCUS] };
                    ((global::Xcb.Window)xid).change_property (connection, global::Xcb.PropMode.REPLACE,
                                                               Xcb.application.atoms[AtomType.WM_PROTOCOLS],
                                                               global::Xcb.AtomType.ATOM,
                                                               32, (void[]?)properties);

                    ulong[] mwm_hints = { 2, 1, 0, 0, 0 };
                    ((global::Xcb.Window)xid).change_property (connection, global::Xcb.PropMode.REPLACE,
                                                               Xcb.application.atoms[AtomType._MOTIF_WM_HINTS],
                                                               Xcb.application.atoms[AtomType._MOTIF_WM_HINTS],
                                                               32, (void[]?)mwm_hints);
                }

                // set window damaged area
                m_Realized = true;

                // send mapped signal
                mapped ();
            }
        }

        // Get window state
        if (!is_mapped)
        {
            // Map window
            application.push_request (new MapRequest (this));
        }

        m_BackBuffer = null;
        m_FrontBuffer = null;

        // Launch resize to create buffer is size is set
        resize ();
    }

    public void
    hide ()
    {
        if (m_Realized)
        {
            // Destroy back and front buffer
            m_BackBuffer = null;
            m_FrontBuffer = null;

            if (is_mapped)
            {
                // Unmap window
                application.push_request (new UnmapRequest (this));

                application.flush ();
            }
        }
    }

    public void
    grab_pointer ()
    {
        ((global::Xcb.Window)xid).grab_pointer (connection, true,
                                                global::Xcb.EventMask.EXPOSURE            |
                                                global::Xcb.EventMask.STRUCTURE_NOTIFY    |
                                                global::Xcb.EventMask.SUBSTRUCTURE_NOTIFY |
                                                global::Xcb.EventMask.BUTTON_PRESS        |
                                                global::Xcb.EventMask.BUTTON_RELEASE      |
                                                global::Xcb.EventMask.POINTER_MOTION,
                                                global::Xcb.GrabMode.ASYNC,
                                                global::Xcb.GrabMode.ASYNC,
                                                (global::Xcb.Window)xid, global::Xcb.NONE, global::Xcb.CURRENT_TIME);
    }

    public void
    ungrab_pointer ()
    {
        connection.ungrab_pointer (global::Xcb.CURRENT_TIME);
    }

    public void
    grab_keyboard ()
    {
        ((global::Xcb.Window)xid).grab_keyboard (connection, true,
                                                 global::Xcb.CURRENT_TIME,
                                                 global::Xcb.GrabMode.ASYNC,
                                                 global::Xcb.GrabMode.ASYNC);
    }

    public void
    ungrab_keyboard ()
    {
        connection.ungrab_keyboard (global::Xcb.CURRENT_TIME);
    }

    public void
    set_pointer_cursor (Cursor inCursor)
    {
        uint32 mask = global::Xcb.Cw.CURSOR;
        uint32[] values = { create_cursor (connection, inCursor) };
        ((global::Xcb.Window)xid).change_attributes (connection, mask, values);

        connection.flush ();
    }

    public void
    move_pointer (Graphic.Point inPosition)
    {
        var view_size = size;
        view_size.transform (device_transform);

        ((global::Xcb.Window)xid).warp_pointer (connection, (global::Xcb.Window)xid, 0, 0,
                                                (uint16)GLib.Math.ceil (view_size.width),
                                                (uint16)GLib.Math.ceil (view_size.height),
                                                (int16)inPosition.x, (int16)inPosition.y);
        connection.flush ();
    }

    public void
    swap_buffer ()
    {
        // Flush all pending request
        application.flush ();

        if (damaged != null)
        {
            // Resize front buffer
            if (m_FrontBuffer == null)
            {
                var view_size = size;
                view_size.transform (device_transform);

                m_FrontBuffer = new Graphic.Surface.from_device (this,
                                                                 (int)GLib.Math.ceil (view_size.width),
                                                                 (int)GLib.Math.ceil (view_size.height));
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

    public int
    compare (View inOther)
    {
        return (int)(xid - inOther.xid);
    }

    public int
    compare_with_xid (uint32 inXid)
    {
        return (int)(xid - inXid);
    }

    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }
}

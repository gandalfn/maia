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
                    unowned View? view = Maia.Xcb.application.lookup_view (reply.children[cpt]);
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
    private unowned View?        m_TransientFor = null;
    private global::Xcb.Colormap m_Colormap = global::Xcb.NONE;
    private bool                 m_OverrideRedirect = false;
    private bool                 m_Foreign = true;
    private bool                 m_Realized = true;
    private Pixmap               m_BackBuffer = null;
    private Graphic.Surface      m_FrontBuffer = null;
    private Core.Array<Sibling>  m_Siblings = null;
    private unowned DestroyFunc? m_Func = null;
    private Graphic.Range?       m_FrameExtents = null;

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

    public bool override_redirect {
        get {
            return m_OverrideRedirect;
        }
        set {
            if (m_OverrideRedirect != value)
            {
                m_OverrideRedirect = value;
                if (m_Realized && !m_Foreign)
                {
                    application.push_request (new OverrideRedirectRequest (this, m_OverrideRedirect));
                }
            }
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

    public View? transient_for {
        get {
            return m_TransientFor;
        }
        set {
            if (m_TransientFor != value)
            {
                m_TransientFor = value;

                if (m_Realized)
                {
                    if (m_TransientFor != null)
                    {
                        global::Xcb.Window xtoplevel = ((global::Xcb.Window)(m_TransientFor.xid));

                        while (true)
                        {
                            var reply = xtoplevel.query_tree (connection).reply (connection);
                            if (reply.root != reply.parent)
                            {
                                xtoplevel = reply.parent;

                                var reply_prop = xtoplevel.get_property (connection, false, Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE], global::Xcb.AtomType.ATOM, 0, 1).reply (connection);
                                if (reply_prop != null && ((global::Xcb.Atom[]?)reply_prop.@value)[0] == Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE_NORMAL])
                                {
                                    break;
                                }
                            }
                            else
                            {
                                break;
                            }
                        }
                        global::Xcb.Window[] properties = { xtoplevel };
                        ((global::Xcb.Window)xid).change_property<global::Xcb.Window> (connection, global::Xcb.PropMode.REPLACE,
                                                                                       Xcb.application.atoms[AtomType.WM_TRANSIENT_FOR],
                                                                                       global::Xcb.AtomType.WINDOW,
                                                                                       32, properties);
                        ((global::Xcb.Window)xid).change_property<global::Xcb.Window> (connection, global::Xcb.PropMode.REPLACE,
                                                                                       Xcb.application.atoms[AtomType.WM_CLIENT_LEADER],
                                                                                       global::Xcb.AtomType.WINDOW,
                                                                                       32, properties);
                        global::Xcb.Atom[] states = { Xcb.application.atoms[AtomType._NET_WM_STATE_MODAL] };
                        ((global::Xcb.Window)xid).change_property<global::Xcb.Atom> (connection, global::Xcb.PropMode.REPLACE,
                                                                                     Xcb.application.atoms[AtomType._NET_WM_STATE],
                                                                                     global::Xcb.AtomType.ATOM,
                                                                                     32, states);
                        global::Xcb.Atom[] types = { Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE_DIALOG] };
                        ((global::Xcb.Window)xid).change_property<global::Xcb.Atom> (connection, global::Xcb.PropMode.REPLACE,
                                                                                     Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE],
                                                                                     global::Xcb.AtomType.ATOM,
                                                                                     32, types);
                    }
                    else
                    {
                        ((global::Xcb.Window)xid).delete_property (connection, Xcb.application.atoms[AtomType.WM_TRANSIENT_FOR]);
                        ((global::Xcb.Window)xid).delete_property (connection, Xcb.application.atoms[AtomType.WM_CLIENT_LEADER]);
                        ((global::Xcb.Window)xid).delete_property (connection, Xcb.application.atoms[AtomType._NET_WM_STATE]);
                        ((global::Xcb.Window)xid).delete_property (connection, Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE]);
                    }
               }
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
            Graphic.Point ret = Graphic.Point (0, 0);

            var reply = ((global::Xcb.Window)xid).get_geometry (connection).reply (connection);
            if (reply != null)
            {
                ret.x = reply.x + (decorated ? frame_extents.min.x : 0);
                ret.y = reply.y + (decorated ? frame_extents.min.y : 0);
            }

            return ret;
        }
        set {
            Graphic.Point pt = value;
            pt.x -= decorated ? frame_extents.min.x : 0;
            pt.y -= decorated ? frame_extents.min.y : 0;
            if (!position.equal (pt))
            {
                if (m_Realized && !m_Foreign)
                {
                    application.push_request (new MoveRequest (this, pt));
                }
            }
        }
    }

    public Graphic.Point root_position {
        get {
            Graphic.Point p = Graphic.Point (0, 0);
            if (m_Realized)
            {
                var reply = ((global::Xcb.Window)xid).translate_coordinates (connection,
                                                                             screen.xscreen.root,
                                                                             0, 0).reply (connection);
                if (reply != null)
                {
                    p.x = (double)reply.dst_x;
                    p.y = (double)reply.dst_y;
                }
            }

            return p;
        }
    }

    public override Graphic.Size size {
        get {
            Graphic.Size ret = Graphic.Size (0, 0);

            var reply = ((global::Xcb.Window)xid).get_geometry (connection).reply (connection);
            if (reply != null)
            {
                ret.width = reply.width   + (reply.border_width * 2);
                ret.height = reply.height + (reply.border_width * 2);
            }

            try
            {
                ret.transform (new Graphic.Transform.invert (m_DeviceTransform));
            }
            catch (GLib.Error err)
            {
            }

            return ret;
        }
        set {
            resize (Graphic.Size (double.max (1, value.width), double.max (1, value.height)));
        }
        default = Graphic.Size (0, 0);
    }

    public unowned Graphic.Range? frame_extents {
        get {
            if (m_FrameExtents == null)
            {
                var reply_prop = ((global::Xcb.Window)xid).get_property (connection, false,
                                                                         Xcb.application.atoms[AtomType._NET_FRAME_EXTENTS],
                                                                         global::Xcb.AtomType.CARDINAL, 0, 4).reply (connection);

                if (reply_prop != null)
                {
                    m_FrameExtents = Graphic.Range (((uint32[]?)reply_prop.@value)[0], ((uint32[]?)reply_prop.@value)[2],
                                                    ((uint32[]?)reply_prop.@value)[1], ((uint32[]?)reply_prop.@value)[3]);
                }
                else
                {
                    m_FrameExtents = Graphic.Range (0, 0, 0, 0);
                }
            }
            return m_FrameExtents;
        }
    }

    public Graphic.Transform device_transform {
        get {
            return m_DeviceTransform;
        }
        set {
            var old_size = size;
            m_DeviceTransform = value;

            resize (old_size);
        }
    }

    public Graphic.Transform transform {
        get {
            return m_Transform;
        }
        set {
            var old_size = size;
            m_Transform = value;

            resize (old_size);
        }
    }

    public Graphic.Region damaged { get; set; default = null; }

    public bool decorated { get; set; default = true; }

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
        m_Foreign = false;
        m_Realized = false;
    }

    public View.foreign (uint32 inForeign)
    {
        GLib.Object (xid: inForeign);
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
        m_Parent = null;

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
    resize (Graphic.Size inSize)
    {
        if (m_Realized && !m_Foreign && !inSize.is_empty ())
        {
            var view_size = inSize;
            view_size.transform (device_transform);

            if (m_BackBuffer == null ||
                (uint32)GLib.Math.ceil (m_BackBuffer.size.width) != (uint32)GLib.Math.ceil (view_size.width) ||
                (uint32)GLib.Math.ceil (m_BackBuffer.size.height) != (uint32)GLib.Math.ceil (view_size.height))
            {
                m_BackBuffer = new Pixmap.from_drawable (this, (int)GLib.Math.ceil (view_size.width), (int)GLib.Math.ceil (view_size.height));
            }

            m_FrontBuffer = null;

            var current_size = size;
            if ((uint32)GLib.Math.ceil (current_size.width) != (uint32)GLib.Math.ceil (inSize.width) ||
                (uint32)GLib.Math.ceil (current_size.height) != (uint32)GLib.Math.ceil (inSize.height))
            {
                application.push_request (new ResizeRequest (this, view_size));
                application.flush ();
                application.sync ();
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
                inContext.pattern = inView.surface;
                inContext.pattern.transform = new Graphic.Transform.init_translate (inPosition.x, inPosition.y);
                inContext.paint ();
                inContext.pattern.transform = new Graphic.Transform.identity ();

                foreach (unowned View child in inView)
                {
                    if (child != this)
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
#if MAIA_DEBUG
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"$xid swap buffer: $(damaged_area.extents) $(transform.matrix)");
#endif

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
                    inContext.pattern = m_BackBuffer.surface;
                    inContext.paint ();
                }
                inContext.restore ();
            }

            // Flush all pendings operations
            connection.flush ();

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

            if (m_OverrideRedirect)
            {
                mask |= global::Xcb.Cw.OVERRIDE_REDIRECT;
                values += 1;
            }

            uint32 event_mask = global::Xcb.EventMask.PROPERTY_CHANGE     |
                                global::Xcb.EventMask.EXPOSURE            |
                                global::Xcb.EventMask.STRUCTURE_NOTIFY    |
                                global::Xcb.EventMask.BUTTON_PRESS        |
                                global::Xcb.EventMask.BUTTON_RELEASE      |
                                global::Xcb.EventMask.KEY_PRESS           |
                                global::Xcb.EventMask.KEY_RELEASE         |
                                global::Xcb.EventMask.POINTER_MOTION      |
                                global::Xcb.EventMask.POINTER_MOTION_HINT;

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
                    ((global::Xcb.Window)xid).change_property<global::Xcb.Atom> (connection, global::Xcb.PropMode.REPLACE,
                                                                                 Xcb.application.atoms[AtomType.WM_PROTOCOLS],
                                                                                 global::Xcb.AtomType.ATOM,
                                                                                 32, properties);

                    ulong[] mwm_hints = { 2, decorated ? 1 : 0, 0, 0, 0 };
                    ((global::Xcb.Window)xid).change_property<ulong> (connection, global::Xcb.PropMode.REPLACE,
                                                                      Xcb.application.atoms[AtomType._MOTIF_WM_HINTS],
                                                                      Xcb.application.atoms[AtomType._MOTIF_WM_HINTS],
                                                                      32, mwm_hints);

                    properties = { Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE_NORMAL] };
                    ((global::Xcb.Window)xid).change_property<global::Xcb.Atom> (connection, global::Xcb.PropMode.REPLACE,
                                                                                 Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE],
                                                                                 global::Xcb.AtomType.ATOM,
                                                                                 32, properties);
                }

                if (m_TransientFor != null)
                {
                    global::Xcb.Window xtoplevel = ((global::Xcb.Window)(m_TransientFor.xid));

                    while (true)
                    {
                        var reply = xtoplevel.query_tree (connection).reply (connection);
                        if (reply.root != reply.parent)
                        {
                            xtoplevel = reply.parent;

                            var reply_prop = xtoplevel.get_property (connection, false, Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE], global::Xcb.AtomType.ATOM, 0, 1).reply (connection);
                            if (reply_prop != null && ((global::Xcb.Atom[]?)reply_prop.@value)[0] == Xcb.application.atoms[AtomType._NET_WM_WINDOW_TYPE_NORMAL])
                            {
                                break;
                            }
                        }
                        else
                        {
                            break;
                        }
                    }
                    global::Xcb.Window[] properties = { xtoplevel };
                    ((global::Xcb.Window)xid).change_property<global::Xcb.Window> (connection, global::Xcb.PropMode.REPLACE,
                                                                                   Xcb.application.atoms[AtomType.WM_TRANSIENT_FOR],
                                                                                   global::Xcb.AtomType.WINDOW,
                                                                                   32, properties);
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

        // Launch resize to create buffer if size is set
        resize (size);
    }

    public void
    hide ()
    {
        if (m_Realized)
        {
            // Destroy back and front buffer
            m_BackBuffer = null;
            m_FrontBuffer = null;

            // Unmap window
            application.push_request (new UnmapRequest (this));

            // Flush all pendings operation on unmap since the application does not flush if window is not visible
            application.flush ();
        }
    }

    public void
    grab_pointer (bool inConfineTo = true)
    {
        ((global::Xcb.Window)xid).grab_pointer (connection, true,
                                                global::Xcb.EventMask.BUTTON_PRESS        |
                                                global::Xcb.EventMask.BUTTON_RELEASE      |
                                                global::Xcb.EventMask.POINTER_MOTION,
                                                global::Xcb.GrabMode.ASYNC,
                                                global::Xcb.GrabMode.ASYNC,
                                                inConfineTo ? (global::Xcb.Window)xid : global::Xcb.NONE,
                                                global::Xcb.NONE, global::Xcb.CURRENT_TIME);
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

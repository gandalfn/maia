/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * item.vala
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

public abstract class Maia.Item : Core.Object, Drawable, Manifest.Element
{
    // static properties
    internal static GLib.Quark s_ChainVisibleCount;
    internal static GLib.Quark s_MainWindow;
    internal static GLib.Quark s_CanvasWindow;
    internal static GLib.Quark s_PopupWindow;
    internal static GLib.Quark s_CountHide;

    // class properties
    internal class uint mc_IdButtonPressEvent;
    internal class uint mc_IdButtonReleaseEvent;
    internal class uint mc_IdMotionEvent;
    internal class uint mc_IdScrollEvent;

    // properties
    private bool              m_NeedUpdate = true;
    private bool              m_IsPackable = false;
    private bool              m_IsMovable = false;
    private bool              m_IsResizable = false;
    private bool              m_Visible = true;
    private Graphic.Region    m_Geometry = null;
    private Graphic.Point     m_Position = Graphic.Point (0, 0);
    private Graphic.Size      m_Size = Graphic.Size (0, 0);
    private Graphic.Size      m_SizeRequested = Graphic.Size (0, 0);
    private Graphic.Transform m_Transform = new Graphic.Transform.identity ();
    private Graphic.Transform m_TransformToItemSpace = new Graphic.Transform.identity ();
    private Graphic.Transform m_TransformToRootSpace = new Graphic.Transform.identity ();
    private Graphic.Transform m_TransformToWindowSpace = new Graphic.Transform.identity ();

    // accessors
    /**
     * {@inheritDoc}
     */
    [CCode (notify = false)]
    public override unowned Core.Object? parent {
        get {
            return base.parent;
        }
        construct set {
            ref ();
            if (parent != null)
            {
                parent.notify["root"].disconnect(on_parent_root_changed);
                parent.notify["window"].disconnect(on_parent_window_changed);
            }

            base.parent = value;

            // connect onto root change on parent
            if (parent != null)
            {
                parent.notify["root"].connect(on_parent_root_changed);
                parent.notify["window"].connect(on_parent_window_changed);

                if (parent is DrawingArea && !(this is Arrow) && !(this is Toolbox))
                {
                    not_dumpable_attributes.remove ("position");
                }
            }

            // If item is root do not connect on position change
            if (parent == null)
                notify["position"].disconnect (on_move);
            else
                notify["position"].connect (on_move);

            // Send root change notification
            GLib.Signal.emit_by_name (this, "notify::root");
            GLib.Signal.emit_by_name (this, "notify::window");
            unref ();
        }
    }

    /**
     * The name of item
     */
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    internal abstract string tag { get; }

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    /**
     * Indicate if item can be packed in grid
     */
    public bool is_packable {
        get {
            return m_IsPackable;
        }
    }

    /**
     * Indicate if item can be moved
     */
    public bool is_movable {
        get {
            return m_IsMovable;
        }
        set {
            m_IsMovable = value;
        }
        default = false;
    }

    /**
     * Indicate if item can be resized
     */
    public bool is_resizable {
        get {
            return m_IsResizable;
        }
        set {
            m_IsResizable = value;
        }
        default = false;
    }

    /**
     * Whether or not the item can be focused
     */
    public virtual bool can_focus  { get; set; default = false; }

    /**
     * Whether the item has the focus.
     */
    public bool         have_focus { get; set; default = false; }

    /**
     * Whether the item is visible.
     */
    [CCode (notify = false)]
    public bool visible {
        get {
            return m_Visible;
        }
        set {
            if (m_Visible != value)
            {
                m_Visible = value;

                if (!m_Visible)
                {
                    on_hide ();
                }
                else
                {
                    on_show ();
                }

                on_visible_changed ();

                GLib.Signal.emit_by_name (this, "notify::visible");
            }
        }
        default = true;
    }

    [CCode (notify = false)]
    internal Graphic.Region geometry {
        get {
            return m_Geometry;
        }
        set {
            if (m_Geometry != value || (m_Geometry != null && !m_Geometry.equal (value)))
            {
                // Check if geometry has been changed (not set)
                bool old_not_empty = (m_Geometry != null);

                m_Geometry = value;

                // New geometry
                if (m_Geometry != null)
                {
                    calculate_transform_to_item_space ();
                    calculate_transform_to_root_space ();
                    calculate_transform_to_window_space ();
                }

                // Send notify geometry signal only if geometry has been changed
                // not when the geometry has been set
                if (old_not_empty)
                {
                    GLib.Signal.emit_by_name (this, "notify::geometry");
                }
            }
        }
    }

    [CCode (notify = false)]
    internal Graphic.Region damaged { get; set; default = null; }

    internal virtual Graphic.Transform transform {
        get {
            return m_Transform;
        }
        set {
            if (m_Transform != null)
            {
                m_Transform.changed.disconnect (on_transform_changed);
            }

            damage ();
            m_Transform = value;
            damage ();

            if (m_Transform != null)
            {
                m_Transform.changed.connect (on_transform_changed);
            }

            if (m_Geometry != null)
            {
                calculate_transform_to_item_space ();
                calculate_transform_to_root_space ();
                calculate_transform_to_window_space ();
            }
        }
        default = new Graphic.Transform.identity ();
    }

    [CCode (notify = false)]
    public Graphic.Point position {
        get {
            Graphic.Point transformed_position;
            Graphic.Size transformed_size;
            get_transformed_position_and_size (out transformed_position, out transformed_size);
            return transformed_position;
        }
        set {
            if (!m_Position.equal (value))
            {
                m_Position = value;

                GLib.Signal.emit_by_name (this, "notify::position");
            }
        }
    }

    [CCode (notify = false)]
    public Graphic.Size size {
        get {
            // Item not visible empty size
            if (!visible)
            {
                // Unset need update
                m_NeedUpdate = false;

                return Graphic.Size (0, 0);
            }
            // Item need update check for size_request
            else if (m_NeedUpdate)
            {
                // Launch size request
                notify["size"].disconnect (on_resize);
                m_SizeRequested = size_request (m_Size);
                notify["size"].connect (on_resize);

                // Unset need update
                m_NeedUpdate = false;
            }
            // Otherwise keep the last size calculated
            else {}

            return m_SizeRequested;
        }
        set {
            if (!m_Size.equal (value))
            {
                // Set new size
                m_Size = value;

                // Mark size needs to be recalculated on next get
                need_update = true;

                // Hide property in manifest dump if size is empty
                if (!m_Size.is_empty ())
                {
                    not_dumpable_attributes.remove ("size");
                }
                else
                {
                    not_dumpable_attributes.insert ("size");
                }

                // Send size notify
                GLib.Signal.emit_by_name (this, "notify::size");
            }
        }
    }

    [CCode (notify = false)]
    public bool need_update {
        get {
            return m_NeedUpdate;
        }
        set {
            if (m_NeedUpdate != value)
            {
                m_NeedUpdate = value;

                // Only emit need update notify if switch on true
                if (m_NeedUpdate) GLib.Signal.emit_by_name (this, "notify::need-update");
            }
        }
    }

    public uint            layer                { get; set; default = 0; }
    public Graphic.Pattern fill_pattern         { get; set; default = null; }
    public Graphic.Pattern stroke_pattern       { get; set; default = null; }
    public Graphic.Pattern background_pattern   { get; set; default = null; }
    public double          line_width           { get; set; default = 1.0; }

    public string          chain_visible        { get; set; default = null; }

    public bool            pointer_over         { get; set; default = false; }

    [CCode (notify = false)]
    public Window window {
        get {
            unowned Window? ret = null;

            // Check if item is under popup
            unowned Core.Object? popup = get_qdata<unowned Core.Object?> (s_PopupWindow);

            for (unowned Core.Object? item = popup ?? parent; ret == null && item != null; item = item.parent)
            {
                // If item is under popup chain up on it
                popup = item.get_qdata<unowned Core.Object?> (s_PopupWindow);
                if (popup != null)
                {
                    item = popup;
                }

                // Get the window id of item
                ret = item.get_qdata<unowned Window?> (s_MainWindow);
            }

            // this is the last window check if window is plug in canvas
            if (ret == null)
            {
                ret = get_qdata<unowned Window?> (s_CanvasWindow);
            }

            return ret;
        }
        set {
            if (get_qdata<unowned Window?> (s_MainWindow) != value)
            {
                set_qdata<unowned Window> (s_MainWindow, value);
                GLib.Signal.emit_by_name (this, "notify::window");
            }
        }
    }

    public Window toplevel {
        get {
            unowned Window? ret = window;

            while (ret.window != null)
            {
                if (ret.get_qdata<unowned Window?> (s_CanvasWindow) == ret.window)
                    break;
                ret = ret.window;
            }

            return ret;
        }
    }

    // signals
    public signal bool grab_pointer (Item inItem);
    public signal void ungrab_pointer (Item inItem);
    public signal bool grab_keyboard (Item inItem);
    public signal void ungrab_keyboard (Item inItem);

    public signal bool button_press_event (uint inButton, Graphic.Point inPosition);
    public signal bool button_release_event (uint inButton, Graphic.Point inPosition);
    public signal bool motion_event (Graphic.Point inPosition);
    public signal bool scroll_event (Scroll inScroll, Graphic.Point inPosition);
    public signal void key_press_event (Key inKey, unichar inChar);
    public signal void key_release_event (Key inKey, unichar inChar);

    [Signal (run = "first")]
    public virtual signal void
    grab_focus (Item? inItem)
    {
        if (parent is Item)
        {
            if (inItem == null)
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab focus");
            else
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);
            ((Item)parent).grab_focus (inItem);
        }
    }

    [Signal (run = "first")]
    public virtual signal void
    set_pointer_cursor (Cursor inCursor)
    {
        if (parent is Item)
        {
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"set cursor $inCursor");
            ((Item)parent).set_pointer_cursor (inCursor);
        }
    }

    [Signal (run = "first")]
    public virtual signal void
    move_pointer (Graphic.Point inPosition)
    {
        if (parent is Item)
        {
            var point = convert_to_parent_item_space (inPosition);

            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"$name move pointer $point");

            ((Item)parent).move_pointer (point);
        }
    }

    [Signal (run = "first")]
    public virtual signal void
    scroll_to (Item inItem)
    {
        if (parent is Item)
        {
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll to %s", inItem.name);
            ((Item)parent).scroll_to (inItem);
        }
    }

    // static methods
    static construct
    {
        // create quarks
        s_ChainVisibleCount = GLib.Quark.from_string ("MaiaChainVisibleShowCount");
        s_CountHide         = GLib.Quark.from_string ("MaiaCountHide");
        s_MainWindow        = GLib.Quark.from_string ("MaiaMainWindow");
        s_CanvasWindow      = GLib.Quark.from_string ("MaiaCanvasWindow");
        s_PopupWindow       = GLib.Quark.from_string ("MaiaPopupWindow");

        // register attribute bind
        Manifest.AttributeBind.register_transform_func (typeof (Item), "width", attribute_bind_width);
        Manifest.AttributeBind.register_transform_func (typeof (Item), "height", attribute_bind_height);

        // get mouse event id
        mc_IdButtonPressEvent   = GLib.Signal.lookup ("button-press-event", typeof (Item));
        mc_IdButtonReleaseEvent = GLib.Signal.lookup ("button-release-event", typeof (Item));
        mc_IdMotionEvent        = GLib.Signal.lookup ("motion-event", typeof (Item));
        mc_IdScrollEvent        = GLib.Signal.lookup ("scroll-event", typeof (Item));
    }

    static void
    attribute_bind_width (Manifest.AttributeBind inAttributeBind, ref GLib.Value outValue)
        requires (outValue.holds (typeof (double)))
    {
        if (inAttributeBind.owner is Item)
        {
            unowned Item item = (Item)inAttributeBind.owner;
            outValue = item.geometry != null ? item.geometry.extents.size.width : item.size.width;
        }
    }

    static void
    attribute_bind_height (Manifest.AttributeBind inAttributeBind, ref GLib.Value outValue)
        requires (outValue.holds (typeof (double)))
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "%s", inAttributeBind.get ());

        if (inAttributeBind.owner is Item)
        {
            unowned Item item = (Item)inAttributeBind.owner;
            double val = item.geometry != null ? item.geometry.extents.size.height : item.size.height;
            outValue = val;
        }
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("tag");
        not_dumpable_attributes.insert ("name");
        not_dumpable_attributes.insert ("geometry");
        not_dumpable_attributes.insert ("allocate-on-child-add-remove");
        not_dumpable_attributes.insert ("damaged");
        not_dumpable_attributes.insert ("is-packable");
        not_dumpable_attributes.insert ("size-requested");
        not_dumpable_attributes.insert ("page-break-position");
        not_dumpable_attributes.insert ("pointer-over");
        not_dumpable_attributes.insert ("can-focus");
        not_dumpable_attributes.insert ("have-focus");
        not_dumpable_attributes.insert ("position");
        not_dumpable_attributes.insert ("size");
        not_dumpable_attributes.insert ("transform");
        not_dumpable_attributes.insert ("need-update");
        not_dumpable_attributes.insert ("window");

        // check if object is packable
        m_IsPackable = this is ItemPackable;

        // check if object is movable
        m_IsMovable = this is ItemMovable;

        // check if object is resizable
        m_IsResizable = this is ItemResizable;

        // connect to mouse events
        button_press_event.connect (on_button_press_event);
        button_release_event.connect (on_button_release_event);
        motion_event.connect (on_motion_event);
        scroll_event.connect (on_scroll_event);

        // connect to damage event
        damage.connect (on_damage);

        // connect to trasnform events
        m_Transform.changed.connect (on_transform_changed);
        notify["transform"].connect (on_transform_changed);

        // reorder object on layer change
        notify["layer"].connect (reorder);

        if (m_IsPackable)
        {
            // reorder object on row change
            notify["row"].connect (reorder);
            // reorder object on column change
            notify["column"].connect (reorder);
        }

        // connect on move and resize
        notify["position"].connect (on_move);
        notify["size"].connect (on_resize);
    }

    ~Item ()
    {
        // send ungrab pointer
        ungrab_pointer (this);

        // send ungrab keyboard
        ungrab_keyboard (this);
    }

    private void
    on_parent_root_changed ()
    {
        calculate_transform_to_window_space ();

        GLib.Signal.emit_by_name (this, "notify::root");
    }

    private void
    on_parent_window_changed ()
    {
        calculate_transform_to_window_space ();

        GLib.Signal.emit_by_name (this, "notify::window");
    }

    private void
    get_transformed_position_and_size (out Graphic.Point outPosition, out Graphic.Size outSize)
    {
        Graphic.Rectangle rect = Graphic.Rectangle (0, 0, m_Size.width, m_Size.height);
        if (transform.matrix.xy != 0 || transform.matrix.yx != 0)
        {
            var center = Graphic.Point(m_Size.width / 2.0, m_Size.height / 2.0);
            rect.translate (center.invert ());
            rect.transform (transform);
            rect.translate (center);
        }
        else
        {
            rect.transform (transform);
        }

        rect.translate (m_Position);

        outPosition = rect.origin;
        outSize = rect.size;
    }

    private void
    on_visible_changed ()
    {
        if (chain_visible != null)
        {
            string[] item_names = chain_visible.split(",");

            foreach (unowned string item_name in item_names)
            {
                unowned Item? item = find (GLib.Quark.from_string (item_name.strip ())) as Item;

                if (item != null)
                {
                    // Get show count
                    int count = item.get_qdata<int> (s_ChainVisibleCount);
                    int count_hide = item.get_qdata<int> (s_CountHide);

                    if (visible)
                    {
                        if (!item.visible)
                        {
                            count_hide--;
                            if (count_hide < 0) count_hide = 0;
                            if (count_hide == 0)
                            {
                                item.visible = true;
                            }
                            item.set_qdata<int> (Item.s_CountHide, count_hide);
                        }

                        count++;
                        item.set_qdata(s_ChainVisibleCount, count.to_pointer());
                    }
                    else
                    {
                        count--;
                        if (count < 0) count = 0;
                        item.set_qdata(s_ChainVisibleCount, count.to_pointer());
                        if (count == 0)
                        {
                            if (item.visible)
                            {
                                item.visible = false;
                                count_hide++;
                                item.set_qdata<int> (Item.s_CountHide, count_hide);
                            }
                        }
                    }
                }
            }
        }
    }

    private void
    on_move_resize ()
    {
        // if item was moved
        if (geometry != null && parent != null && parent is Item)
        {
            // keep old geometry
            Graphic.Region old_geometry = geometry.copy ();

            // reset item geometry
            if ((!m_IsMovable && !m_IsResizable))
            {
                need_update = true;
            }
            else
            {
                var item_size = size;
                geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, item_size.width, item_size.height));
            }

            // damage parent
            (parent as Item).damage (old_geometry);
        }
        else if (geometry != null)
        {
            need_update = true;
        }
    }

    private void
    on_transform_changed ()
    {
        need_update = true;

        // Do not dump transform if is identity
        if (!transform.matrix.is_identity ())
        {
            not_dumpable_attributes.remove ("transform");
        }
        else
        {
            not_dumpable_attributes.insert ("transform");
        }
    }

    private void
    draw (Graphic.Context inContext, Graphic.Region? inArea) throws Graphic.Error
    {
        on_draw (inContext, inArea);
    }

    private void
    calculate_transform_to_item_space ()
    {
        // clear transform
        m_TransformToItemSpace.init ();

        // add parent transform
        for (unowned Core.Object? object = this; object != null; object = object.parent)
        {
            unowned Item? item = object as Item;
            if (item != null && item != this && !(item is Popup))
            {
                m_TransformToItemSpace.prepend (item.m_TransformToItemSpace);
                break;
            }

            // If item is under popup chain up on it
            unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
            if (popup != null)
            {
                object = popup;
            }
        }

        // add transform
        var this_transform = new Graphic.Transform.identity ();
        try
        {
            Graphic.Matrix matrix = transform.matrix;
            matrix.invert ();
            Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
            this_transform.append (item_transform);
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on calculate transform to item %s space: %s", name, err.message);
        }

        // Ignore translation of item without geometry or window managed by application
        // the position of this last is the position under desktop
        if (geometry != null && (!(this is Window) || !(parent is Application)))
        {
            Graphic.Point pos = geometry.extents.origin.invert ();
            Graphic.Transform item_translate = new Graphic.Transform.identity ();
            item_translate.translate (pos.x, pos.y);
            this_transform.append (item_translate);
        }

        m_TransformToItemSpace.prepend (this_transform);
    }

    private void
    calculate_transform_to_root_space ()
    {
        // clear transform
        m_TransformToRootSpace.init ();

        // add parent transform
        for (unowned Core.Object? object = this; object != null; object = object.parent)
        {
            unowned Item? item = object as Item;
            if (item != null && item != this && !(item is Popup))
            {
                m_TransformToRootSpace.append (item.m_TransformToRootSpace);
                break;
            }

            // If item is under popup chain up on it
            unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
            if (popup != null)
            {
                object = popup;
            }
        }

        // add transform
        var this_transform = new Graphic.Transform.identity ();

        // Ignore translation of item without geometry or window managed by application
        // the position of this last is the position under desktop
        if (geometry != null && (!(this is Window) || !(parent is Application)))
        {
            Graphic.Point pos = geometry.extents.origin;
            Graphic.Transform item_translate = new Graphic.Transform.identity ();
            item_translate.translate (pos.x, pos.y);
            this_transform.append (item_translate);
        }

        Graphic.Matrix matrix = transform.matrix;
        Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
        this_transform.append (item_transform);

        m_TransformToRootSpace.append (this_transform);
    }

    private void
    calculate_transform_to_window_space ()
    {
        // clear transform
        m_TransformToWindowSpace.init ();

        // add parent transform
        if (!(this is Window))
        {
            for (unowned Core.Object? object = this; object != null; object = object.parent)
            {
                unowned Item? item = object as Item;
                if (item != null && item != this && !(item is Popup))
                {
                    m_TransformToWindowSpace.append (item.m_TransformToWindowSpace);

                    // add transform
                    var parent_transform = new Graphic.Transform.identity ();

                    // Ignore translation of item without geometry or window managed by application
                    // the position of this last is the position under desktop
                    if (geometry != null && !(item is Window))
                    {
                        Graphic.Point pos = item.geometry.extents.origin;
                        Graphic.Transform item_translate = new Graphic.Transform.identity ();
                        item_translate.translate (pos.x, pos.y);
                        parent_transform.append (item_translate);
                    }

                    Graphic.Matrix matrix = item.transform.matrix;
                    Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                    parent_transform.append (item_transform);

                    m_TransformToWindowSpace.append (parent_transform);

                    break;
                }

                // If item is under popup chain up on it
                unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
                if (popup != null)
                {
                    object = popup;
                }
            }
        }
    }

    private bool
    on_child_grab_pointer (Item inItem)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
        return grab_pointer (inItem);
    }

    private void
    on_child_ungrab_pointer (Item inItem)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", inItem.name);
        ungrab_pointer (inItem);
    }

    private bool
    on_child_grab_keyboard (Item inItem)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab keyboard %s", inItem.name);
        return grab_keyboard (inItem);
    }

    private void
    on_child_ungrab_keyboard (Item inItem)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab keyboard %s", inItem.name);
        ungrab_keyboard (inItem);
    }

    private void
    on_child_geometry_changed (GLib.Object inObject, GLib.ParamSpec? inProperty)
    {
        on_child_resized ((Drawable)inObject);
    }

    private void
    on_child_need_update (GLib.Object inObject, GLib.ParamSpec? inProperty)
    {
        bool child_need_update = ((Item)inObject).need_update;
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"$name: $(((Item)inObject).name) need update $child_need_update");
        need_update |= child_need_update;
    }

    protected virtual void
    on_draw (Graphic.Context inContext, Graphic.Region? inArea) throws Graphic.Error
    {
        if (visible && geometry != null && damaged != null && !damaged.is_empty ())
        {
            var damaged_area = damaged.copy ();
            if (inArea != null)
            {
                damaged_area.intersect (inArea);
            }

            if (!damaged_area.is_empty ())
            {
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, "item %s damaged draw %s %s", name, damaged.extents.to_string (), area.extents.to_string ());

                inContext.operator = Graphic.Operator.OVER;
                inContext.save ();
                {
                    inContext.translate (geometry.extents.origin);
                    inContext.line_width = line_width;

                    if (transform.matrix.xy != 0 || transform.matrix.yx != 0)
                    {
                        var center = Graphic.Point(geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);

                        inContext.translate (center);
                        inContext.transform = transform;
                        inContext.translate (center.invert ());
                    }
                    else
                        inContext.transform = transform;

                    inContext.clip_region (damaged_area);

                    paint (inContext, damaged_area);

                    //inContext.pattern = new Graphic.Color (1, 0, 0, 0.6);
                    //var path = new Graphic.Path.from_region (damaged_area);
                    //inContext.stroke (path);
                }
                inContext.restore ();

                repair (damaged_area);
            }
        }
    }

    protected virtual void
    on_child_resized (Drawable inChild)
    {
        if (inChild.geometry == null)
        {
            geometry = null;
        }
    }

    protected virtual void
    on_damage (Graphic.Region? inArea = null)
    {
        if (visible)
        {
            // Damage all childs
            foreach (unowned Core.Object child in this)
            {
                if (child is Item && (child as Item).visible && (child as Drawable).geometry != null)
                {
                    unowned Item item = (Item)child;

                    var area = area_to_child_item_space (item, inArea);
                    if (!area.is_empty () && (item.damaged == null || item.damaged.is_empty () || item.damaged.contains_rectangle (area.extents) != Graphic.Region.Overlap.IN))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "damage child %s %s", (child as Item).name, area.extents.to_string ());

                        item.damage_area (area);
                    }
                }
            }
        }
    }

    protected virtual void
    on_child_damaged (Drawable inChild, Graphic.Region? inArea)
    {
        if (inChild.geometry != null)
        {
            Graphic.Region damaged_area;

            if (inArea == null)
            {
                damaged_area = inChild.geometry.copy ();
            }
            else
            {
                damaged_area = inChild.area_to_parent_item_space (inArea);
            }

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

            // damage item
            damage (damaged_area);
        }
    }

    protected virtual void
    on_show ()
    {
        // Mark has need to check size
        need_update = true;

        // Damage item for redraw
        damage ();
    }

    protected virtual void
    on_hide ()
    {
        // Remove all damaged area
        repair ();

        // Unset geometry
        geometry = null;
    }

    protected virtual void
    on_move ()
    {
        on_move_resize ();
    }

    protected virtual void
    on_resize ()
    {
        on_move_resize ();
    }

    protected virtual bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (visible && area != null)
        {
            ret = inPoint in area;
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
        }
        else if (can_focus && inButton == 1)
        {
            grab_focus (this);
        }
        else
        {
            grab_focus (null);
        }

        return ret;
    }

    protected virtual bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (visible && area != null)
        {
            ret = inPoint in area;
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
        }

        return ret;
    }

    protected virtual bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = false;
        if (visible && area != null)
        {
            ret = inPoint in area;
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
        }

        if (pointer_over != ret)
        {
            pointer_over = ret;
        }

        return ret;
    }

    protected virtual bool
    on_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return this is ItemResizable && parent is DrawingArea;
    }

    protected virtual Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Point transformed_position;
        Graphic.Size transformed_size;
        get_transformed_position_and_size (out transformed_position, out transformed_size);

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "%s size request: %s", name, transformed_size.to_string ());
        return transformed_size;
    }

    protected void
    paint_background (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        if (background_pattern != null)
        {
            inContext.save ();
            unowned Graphic.Image? image = background_pattern as Graphic.Image;
            if (image != null)
            {
                Graphic.Size image_size = image.size;
                double scale = double.max (image_size.width / area.extents.size.width,
                                           image_size.height / area.extents.size.height);
                var transform = new Graphic.Transform.identity ();
                transform.scale (scale, scale);
                inContext.translate (Graphic.Point ((area.extents.size.width - (image_size.width / scale)) / 2,
                                                    (area.extents.size.height - (image_size.height / scale)) / 2));
                image.transform = transform;
                inContext.pattern = background_pattern;
            }
            else
            {
                inContext.pattern = background_pattern;
            }

            inContext.paint ();
            inContext.restore ();
        }
    }

    protected abstract void paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error;



    internal override bool
    can_append_child (Core.Object inChild)
    {
        return inChild is Item || inChild is ToggleGroup || inChild is Model;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        if (can_append_child (inObject))
        {
            if (inObject is Drawable)
            {
                // On child resize
                inObject.notify["geometry"].connect (on_child_geometry_changed);

                // Connect under child damage
                ((Drawable)inObject).damage.connect (on_child_damaged);
            }

            if (inObject is Item)
            {
                // On child need update
                ((Item)inObject).notify["need-update"].connect (on_child_need_update);

                // Connect under child  grab/ungrab pointer
                ((Item)inObject).grab_pointer.connect (on_child_grab_pointer);
                ((Item)inObject).ungrab_pointer.connect (on_child_ungrab_pointer);

                // Connect under child  grab/ungrab keyboard
                ((Item)inObject).grab_keyboard.connect (on_child_grab_keyboard);
                ((Item)inObject).ungrab_keyboard.connect (on_child_ungrab_keyboard);
            }

            if (inObject is Manifest.Element)
            {
                // Item has theme and child has not theme (if in parsing the theme has been before add)
                if (manifest_theme != null && ((Manifest.Element)inObject).manifest_theme != manifest_theme)
                {
                    // Apply theme of parent
                    ((Manifest.Element)inObject).manifest_theme = manifest_theme;
                    try
                    {
                        manifest_theme.apply (((Manifest.Element)inObject));
                    }
                    catch (GLib.Error err)
                    {
                        Log.error (GLib.Log.METHOD, Log.Category.CANVAS_LAYOUT, @"Error on apply theme to child of $name: $(err.message)");
                    }
                }
            }

            need_update = true;
            geometry = null;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject.parent == this)
        {
            if (inObject is Drawable)
            {
                // Get id signal geoemtry
                inObject.notify["geometry"].disconnect (on_child_geometry_changed);

                // Disconnect from child damage
                ((Drawable)inObject).damage.disconnect (on_child_damaged);
            }

            if (inObject is Item)
            {
                // Disconnect from child need update
                ((Item)inObject).notify["need-update"].disconnect (on_child_need_update);

                // Disconnect from child  grab/ungrab pointer
                ((Item)inObject).grab_pointer.disconnect (on_child_grab_pointer);
                ((Item)inObject).ungrab_pointer.disconnect (on_child_ungrab_pointer);

                // Disconnect from child  grab/ungrab keyboard
                ((Item)inObject).grab_keyboard.disconnect (on_child_grab_keyboard);
                ((Item)inObject).ungrab_keyboard.disconnect (on_child_ungrab_keyboard);
            }

            base.remove_child (inObject);

            need_update = true;
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override int
    compare (Core.Object inOther)
    {
        int ret =  0;

        if (inOther is Item)
        {
            // Always item non packable first
            if (!((Item)this).is_packable && ((Item)inOther).is_packable)
                return -1;
            if (((Item)this).is_packable && !((Item)inOther).is_packable)
                return 1;

            // If items are packables
            if (((Item)this).is_packable && ((Item)inOther).is_packable)
            {
                // order item by row
                ret = (int)((ItemPackable)this).row - (int)((ItemPackable)inOther).row;

                // if on same row order by column
                if (ret == 0)
                {
                    ret = (int)((ItemPackable)this).column - (int)((ItemPackable)inOther).column;
                }
            }

            // on same row and column order item by layer
            if (ret == 0)
            {
                ret = (int)layer - (int)((Item)inOther).layer;
            }
        }
        else
        {
            // Non item always first
            ret = 1;
        }

        // on same row, column and layer order by id
        if (ret == 0)
        {
            ret = base.compare (inOther);
        }

        return ret;
    }

    internal virtual string
    dump_childs (string inPrefix)
    {
        string ret = "";

        // dump childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Manifest.Element)
            {
                ret += inPrefix + (child as Manifest.Element).dump (inPrefix) + "\n";
            }
        }

        return ret;
    }

    internal virtual string
    dump_characters (string inPrefix)
    {
        string ret = "";

        // dump characters
        if (characters != null)
        {
            ret += inPrefix + "[\n";
            ret += inPrefix + "\t" + characters + "\n";
            ret += inPrefix + "]\n";
        }

        return ret;
    }

    internal override string
    to_string ()
    {
        return dump ("");
    }

    internal virtual void
    on_read_manifest (Manifest.Document inDocument) throws Core.ParseError
    {
    }

    /**
     * Update the allocated geometry of item
     *
     * @param inContext graphic context where the allocation is valid
     * @param inAllocation graphic region allocated to widget
     *
     * @throws Graphic.Error if something goes wrong
     */
    public virtual void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "update %s: %s", name, inAllocation.extents.to_string ());

            geometry = inAllocation;

            damage_area ();
        }
    }

    /**
     * Convert a root point to item coordinate space
     *
     * @param inRootPoint point to convert
     *
     * @return Graphic.Point in item coordinate space
     */
    public Graphic.Point
    convert_to_item_space (Graphic.Point inRootPoint)
    {
        var point = inRootPoint;
        point.transform (m_TransformToItemSpace);

        return point;
    }

    /**
     * Convert a point in item coordinate space to root coordinate space
     *
     * @param inPoint point to convert
     *
     * @return Graphic.Point in root coordinate space
     */
    public Graphic.Point
    convert_to_root_space (Graphic.Point inPoint)
    {
        var point = inPoint;
        point.transform (m_TransformToRootSpace);

        return point;
    }


    /**
     * Convert a point in item coordinate space to item window coordinate space
     *
     * @param inPoint point to convert
     *
     * @return Graphic.Point in window coordinate space
     */
    public Graphic.Point
    convert_to_window_space (Graphic.Point inPoint)
    {
        var point = inPoint;
        point.transform (m_TransformToWindowSpace);

        return point;
    }
}

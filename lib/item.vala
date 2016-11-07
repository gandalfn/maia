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
    internal static GLib.Quark s_ThemeDumpQuark;

    // class properties
    internal class uint mc_IdButtonPressEvent;
    internal class uint mc_IdButtonReleaseEvent;
    internal class uint mc_IdMotionEvent;
    internal class uint mc_IdScrollEvent;

    // properties
    private bool                       m_NeedUpdate = true;
    private bool                       m_IsPackable = false;
    private bool                       m_IsMovable = false;
    private bool                       m_IsResizable = false;
    private bool                       m_IsSelectable = false;
    private bool                       m_Visible = true;
    private Graphic.Region             m_Geometry = null;
    private Graphic.Region             m_Area = null;
    private Graphic.Point              m_Position = Graphic.Point (0, 0);
    private bool                       m_BlockOnMoveResize = false;
    private Graphic.Size               m_Size = Graphic.Size (0, 0);
    private Graphic.Size               m_SizeRequested = Graphic.Size (0, 0);
    private Graphic.Transform          m_Transform = new Graphic.Transform.identity ();
    private Graphic.Transform          m_TransformToItemSpace = new Graphic.Transform.identity ();
    private Graphic.Transform          m_TransformToRootSpace = new Graphic.Transform.identity ();
    private Graphic.Transform          m_TransformToWindowSpace = new Graphic.Transform.identity ();
    private Graphic.Transform          m_TransformFromWindowSpace = new Graphic.Transform.identity ();
    private Core.Notification.Observer m_TransformObserver = null;
    private Core.Notification.Observer m_DamageObserver = null;
    private Gesture                    m_Gesture = null;

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

            if (visible && m_Geometry != null)
            {
                calculate_transform_to_item_space ();
                calculate_transform_to_root_space ();
                calculate_transform_to_window_space ();
                calculate_transform_from_window_space ();
            }

            // Send root change notification
            GLib.Signal.emit_by_name (this, "notify::root");
            notify_property ("window");

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

    public abstract string tag { get; }

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
     * Indicate if item can be selected
     */
    public bool is_selectable {
        get {
            return m_IsSelectable;
        }
        set {
            m_IsSelectable = value;
        }
        default = false;
    }

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

                if (m_Visible && m_Geometry != null)
                {
                    calculate_transform_to_item_space ();
                    calculate_transform_to_root_space ();
                    calculate_transform_to_window_space ();
                    calculate_transform_from_window_space ();
                }

                if (!m_Visible)
                {
                    on_hide ();
                }
                else
                {
                    on_show ();
                }

                on_visible_changed ();

                notify_property ("visible");
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
                Graphic.Size old_size = Graphic.Size (0, 0);
                if (old_not_empty)
                {
                    old_size = m_Geometry.extents.size;
                }

                m_Geometry = value;
                m_Area = null;

                // New geometry
                if (visible && m_Geometry != null)
                {
                    calculate_transform_to_item_space ();
                    calculate_transform_to_root_space ();
                    calculate_transform_to_window_space ();
                    calculate_transform_from_window_space ();
                }

                // Send notify geometry signal only if geometry has been changed
                // not when the geometry has been set
                if (old_not_empty)
                {
                    notify_property ("geometry");
                }
            }
        }
    }

    internal Graphic.Region? area {
        owned get {
            Graphic.Region ret = null;

            if (geometry != null)
            {
                if (m_Area == null)
                {
                    m_Area = geometry.copy ();
                    m_Area.translate (geometry.extents.origin.invert ());

                    if (transform.have_rotate)
                    {
                        var t = transform.copy ();
                        t.apply_center_rotate (geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);
                        m_Area.transform (new Graphic.Transform.from_matrix (t.matrix_invert));
                        m_Area.translate (ret.extents.origin.invert ());
                    }
                    else
                    {
                        m_Area.transform (new Graphic.Transform.from_matrix (transform.matrix_invert));
                    }
                }

                ret = m_Area.copy ();
            }

            return ret;
        }
    }

    [CCode (notify = false)]
    internal Graphic.Region damaged { get; set; default = null; }

    [CCode (notify = false)]
    internal virtual Graphic.Transform transform {
        get {
            return m_Transform;
        }
        set {
            if (m_TransformObserver != null)
            {
                m_TransformObserver.parent = null;
                m_TransformObserver = null;
            }

            damage.post ();
            m_Transform = value;
            m_Area = null;
            damage.post ();

            if (m_Transform != null)
            {
                m_TransformObserver = m_Transform.changed.add_object_observer (on_transform_changed);
            }

            if (visible && m_Geometry != null)
            {
                calculate_transform_to_item_space ();
                calculate_transform_to_root_space ();
                calculate_transform_to_window_space ();
                calculate_transform_from_window_space ();
            }

            notify_property ("transform");
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

                // If item is not root send on_move
                if (parent != null && !m_BlockOnMoveResize)
                {
                    on_move ();
                }

                if (m_Position.x == 0 && m_Position.y == 0)
                {
                    not_dumpable_attributes.insert ("position");
                }
                else
                {
                    not_dumpable_attributes.remove ("position");
                }

                notify_property ("position");
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
                m_BlockOnMoveResize = true;
                m_SizeRequested = size_request (m_Size);
                m_BlockOnMoveResize = false;

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

                // Call resize
                if (!m_BlockOnMoveResize)
                {
                    on_resize ();
                }

                // Send size notify
                notify_property ("size");
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
                if (m_NeedUpdate) notify_property ("need-update");
            }
        }
    }

    public uint             layer                { get; set; default = 0; }
    public StatePatterns    fill_pattern         { get; set; }
    public StatePatterns    stroke_pattern       { get; set; }
    public StatePatterns    background_pattern   { get; set; }
    public double           line_width           { get; set; default = 1.0; }
    public Graphic.LineType line_type            { get; set; default = Graphic.LineType.CONTINUE; }

    public State            state                { get; set; default = State.NORMAL; }

    public string           chain_visible        { get; set; default = null; }

    public bool             pointer_over         { get; set; default = false; }

    [CCode (notify = false)]
    public unowned Window? window {
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
                set_qdata<unowned Window?> (s_MainWindow, value);
                notify_property ("window");
            }
        }
    }

    public unowned Window? toplevel {
        get {
            unowned Window? ret = window;

            while (ret != null && ret.window != null)
            {
                if (ret.get_qdata<unowned Window?> (s_CanvasWindow) == ret.window)
                    break;
                ret = ret.window;
            }

            return ret;
        }
    }

    // signals
    [HasEmitter]
    public signal bool grab_pointer (Item inItem);
    [HasEmitter]
    public signal void ungrab_pointer (Item inItem);
    [HasEmitter]
    public signal bool grab_keyboard (Item inItem);
    [HasEmitter]
    public signal void ungrab_keyboard (Item inItem);

    [HasEmitter]
    public signal bool button_press_event (uint inButton, Graphic.Point inPosition);
    [HasEmitter]
    public signal bool button_release_event (uint inButton, Graphic.Point inPosition);
    [HasEmitter]
    public signal bool motion_event (Graphic.Point inPosition);
    [HasEmitter]
    public signal bool scroll_event (Scroll inScroll, Graphic.Point inPosition);
    [HasEmitter]
    public signal void key_press_event (Modifier inModifier, Key inKey, unichar inChar);
    [HasEmitter]
    public signal void key_release_event (Modifier inModifier, Key inKey, unichar inChar);

    [HasEmitter, Signal (run = "first")]
    public virtual signal void
    grab_focus (Item? inItem)
    {
        if (parent is Item)
        {
#if MAIA_DEBUG
            if (inItem == null)
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab focus");
            else
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);
#endif
            ((Item)parent).grab_focus (inItem);
        }
    }

    [HasEmitter, Signal (run = "first")]
    public virtual signal void
    set_pointer_cursor (Cursor inCursor)
    {
        if (parent is Item)
        {
#if MAIA_DEBUG
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"set cursor $inCursor");
#endif
            ((Item)parent).set_pointer_cursor (inCursor);
        }
    }

    [HasEmitter, Signal (run = "first")]
    public virtual signal void
    move_pointer (Graphic.Point inPosition)
    {
        if (parent is Item)
        {
            var point = convert_to_parent_item_space (inPosition);

#if MAIA_DEBUG
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"$name move pointer $point");
#endif

            ((Item)parent).move_pointer (point);
        }
    }

    [HasEmitter, Signal (run = "first")]
    public virtual signal void
    scroll_to (Item inItem)
    {
        if (parent is Item)
        {
#if MAIA_DEBUG
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll to %s", inItem.name);
#endif
            ((Item)parent).scroll_to (inItem);
        }
    }

    // notifications
    public Gesture.Notification gesture {
        get {
            return m_Gesture.notification;
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
        s_ThemeDumpQuark    = GLib.Quark.from_string ("MaiaItemThemeDumped");

        // register attribute bind
        Manifest.AttributeBind.register_transform_func (typeof (Item), "width", attribute_bind_width);
        Manifest.AttributeBind.register_transform_func (typeof (Item), "height", attribute_bind_height);

        // register attibutes transforms
        Manifest.Attribute.register_transform_func (typeof (Graphic.Glyph.Alignment), attribute_to_alignment);
        Manifest.Attribute.register_transform_func (typeof (Graphic.Glyph.WrapMode), attribute_to_wrap_mode);
        Manifest.Attribute.register_transform_func (typeof (Graphic.Glyph.EllipsizeMode), attribute_to_ellipsize_mode);
        Manifest.Attribute.register_transform_func (typeof (Placement), attribute_to_placement);

        GLib.Value.register_transform_func (typeof (Graphic.Glyph.Alignment), typeof (string), alignment_to_string);
        GLib.Value.register_transform_func (typeof (Graphic.Glyph.WrapMode), typeof (string), wrap_mode_to_string);
        GLib.Value.register_transform_func (typeof (Graphic.Glyph.EllipsizeMode), typeof (string), ellipsize_mode_to_string);
        GLib.Value.register_transform_func (typeof (Placement), typeof (string), placement_to_string);

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
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "%s", inAttributeBind.get ());
#endif

        if (inAttributeBind.owner is Item)
        {
            unowned Item item = (Item)inAttributeBind.owner;
            outValue = item.geometry != null ? item.geometry.extents.size.height : item.size.height;
        }
    }

    static void
    attribute_to_alignment (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Graphic.Glyph.Alignment.from_string (inAttribute.get ());
    }

    static void
    attribute_to_placement (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Placement.from_string (inAttribute.get ());
    }

    static void
    placement_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Placement)))
    {
        Placement val = (Placement)inSrc;

        outDest = val.to_string ();
    }

    static void
    alignment_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Glyph.Alignment)))
    {
        Graphic.Glyph.Alignment val = (Graphic.Glyph.Alignment)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_wrap_mode (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Graphic.Glyph.WrapMode.from_string (inAttribute.get ());
    }

    static void
    wrap_mode_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Glyph.WrapMode)))
    {
        Graphic.Glyph.WrapMode val = (Graphic.Glyph.WrapMode)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_ellipsize_mode (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Graphic.Glyph.EllipsizeMode.from_string (inAttribute.get ());
    }

    static void
    ellipsize_mode_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Glyph.EllipsizeMode)))
    {
        Graphic.Glyph.EllipsizeMode val = (Graphic.Glyph.EllipsizeMode)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("tag");
        not_dumpable_attributes.insert ("name");
        not_dumpable_attributes.insert ("state");
        not_dumpable_attributes.insert ("geometry");
        not_dumpable_attributes.insert ("allocate-on-child-add-remove");
        not_dumpable_attributes.insert ("damaged");
        not_dumpable_attributes.insert ("is-movable");
        not_dumpable_attributes.insert ("is-resizable");
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

        // check if object is selectable
        m_IsSelectable = this is ItemMovable || this is ItemResizable;

        // create state patterns
        stroke_pattern     = new StatePatterns ();
        fill_pattern       = new StatePatterns ();
        background_pattern = new StatePatterns ();

        // connect to state changed
        notify["state"].connect (on_state_changed);

        // connect to mouse events
        button_press_event.connect (on_button_press_event);
        button_release_event.connect (on_button_release_event);
        motion_event.connect (on_motion_event);
        scroll_event.connect (on_scroll_event);

        // connect to damage event
        m_DamageObserver = damage.add_object_observer (on_damage_notification);

        notify["root"].connect (on_visible_changed);
        notify["chain-visible"].connect (on_visible_changed);

        // connect to trasnform events
        m_TransformObserver = m_Transform.changed.add_object_observer (on_transform_changed);
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

        // create gesture
        m_Gesture = new Gesture (this);
        m_Gesture.notification.add_object_observer (on_gesture_notification);
    }

    ~Item ()
    {
        // send ungrab pointer
        ungrab_pointer (this);

        // send ungrab keyboard
        ungrab_keyboard (this);

        // Remove item from chain visible
        if (chain_visible != null)
        {
            string[] item_names = chain_visible.split(",");

            foreach (unowned string item_name in item_names)
            {
                GLib.Quark search_id = GLib.Quark.from_string (item_name.strip ());
                if (search_id != 0)
                {
                    // First search in child
                    unowned Item? item = find (search_id) as Item;
                    if (item == null)
                    {
                        // Search in parents
                        for (unowned Core.Object? p = parent; item == null && p != null; p = p.parent)
                        {
                            unowned Item? parent_item = p as Item;
                            if (parent_item != null)
                            {
                                item = parent_item.find (search_id) as Item;
                            }
                        }
                    }

                    if (item != null)
                    {
                        // Get show count
                        unowned Core.Set<void*>? count = item.get_qdata<unowned Core.Set<void*>> (s_ChainVisibleCount);
                        if (count != null)
                        {
                            int count_hide = item.get_qdata<int> (s_CountHide);
                            count.remove (this);

                            if (count.length == 0)
                            {
                                if (item.visible)
                                {
                                    item.visible = false;
                                    count_hide++;
                                    item.set_qdata<int> (Item.s_CountHide, count_hide);
                                    item.not_dumpable_attributes.insert ("visible");
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private void
    on_state_changed ()
    {
        damage.post ();
    }

    private void
    on_gesture_notification (Core.Notification inNotification)
    {
        on_gesture (inNotification as Gesture.Notification);
    }

    private void
    on_damage_notification (Core.Notification inNotification)
    {
        on_damage ((inNotification as Drawable.DamageNotification).area);
    }

    private void
    on_child_damaged_notification (Core.Notification inNotification)
    {
        unowned Drawable.DamageNotification notification = inNotification as Drawable.DamageNotification;

        on_child_damaged (notification.drawable, notification.area);
    }

    private void
    on_parent_root_changed ()
    {
        GLib.Signal.emit_by_name (this, "notify::root");
    }

    private void
    on_parent_window_changed ()
    {
        geometry = null;
        need_update = true;
        notify_property ("window");
    }

    private void
    get_transformed_position_and_size (out Graphic.Point outPosition, out Graphic.Size outSize)
    {
        Graphic.Rectangle rect = Graphic.Rectangle (0, 0, m_Size.width, m_Size.height);

        if (transform.have_rotate)
        {
            var t = transform.copy ();
            t.apply_center_rotate (m_Size.width / 2.0, m_Size.height / 2.0);
            rect.transform (t);
        }
        else
        {
            rect.transform (transform);
        }

        rect.origin = m_Position;

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
                GLib.Quark search_id = GLib.Quark.from_string (item_name.strip ());
                if (search_id != 0)
                {
                    // First search in child
                    unowned Item? item = find (search_id) as Item;
                    if (item == null)
                    {
                        // Search in parents
                        for (unowned Core.Object? p = parent; item == null && p != null; p = p.parent)
                        {
                            unowned Item? parent_item = p as Item;
                            if (parent_item != null)
                            {
                                item = parent_item.find (search_id) as Item;
                            }
                        }
                    }

                    if (item != null)
                    {
                        // Get show count
                        unowned Core.Set<void*>? count = item.get_qdata<unowned Core.Set<void*>> (s_ChainVisibleCount);
                        if (count == null)
                        {
                            Core.Set<void*> new_count = new Core.Set<void*> ();
                            new_count.compare_func = Core.direct_compare;
                            count = new_count;
                            item.set_qdata<Core.Set<void*>> (s_ChainVisibleCount, new_count);
                        }
                        int count_hide = item.get_qdata<int> (s_CountHide);

                        if (visible)
                        {
                            if (!(this in count))
                            {
                                if (!item.visible)
                                {
                                    count_hide--;
                                    if (count_hide < 0) count_hide = 0;
                                    if (count_hide == 0)
                                    {
                                        item.visible = true;
                                        item.not_dumpable_attributes.remove ("visible");
                                    }
                                    item.set_qdata<int> (Item.s_CountHide, count_hide);
                                }

                                count.insert (this);
                            }
                        }
                        else if (this in count)
                        {
                            count.remove (this);
                            if (count.length == 0)
                            {
                                if (item.visible)
                                {
                                    item.visible = false;
                                    count_hide++;
                                    item.set_qdata<int> (Item.s_CountHide, count_hide);
                                    item.not_dumpable_attributes.insert ("visible");
                                }
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
        if (geometry != null && parent != null && parent is DrawingArea && (m_IsMovable || m_IsResizable))
        {
            damage.post ();
            geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));
            repair_area ();
            damage.post ();
        }
        else if (geometry != null)
        {
            need_update = true;
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
            if (item != null && item != this)
            {
                m_TransformToItemSpace.prepend (item.m_TransformToItemSpace.link ());
                break;
            }

            // If item is under popup chain up on it
            unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
            if (popup != null)
            {
                object = popup;
            }
        }

        if (visible)
        {
                    // add transform
            var this_transform = new Graphic.Transform.identity ();
            try
            {
                Graphic.Transform item_transform = new Graphic.Transform.invert (transform);
                this_transform.append (item_transform);
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on calculate transform to item %s space: %s", name, err.message);
            }

            // Ignore translation of item without geometry or window managed by application
            // the position of this last is the position under desktop
            if (geometry != null && !(parent is Application))
            {
                Graphic.Point pos = geometry.extents.origin.invert ();
                Graphic.Transform item_translate = new Graphic.Transform.init_translate (pos.x, pos.y);
                this_transform.append (item_translate);
            }

            m_TransformToItemSpace.prepend (this_transform);
        }
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
            if (item != null && item != this)
            {
                m_TransformToRootSpace.append (item.m_TransformToRootSpace.link ());
                break;
            }

            // If item is under popup chain up on it
            unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
            if (popup != null)
            {
                object = popup;
            }
        }

        if (visible)
        {
                    // add transform
            var this_transform = new Graphic.Transform.identity ();

            // Ignore translation of item without geometry or window managed by application
            // the position of this last is the position under desktop
            if (geometry != null && !(parent is Application))
            {
                Graphic.Point pos = geometry.extents.origin;
                Graphic.Transform item_translate = new Graphic.Transform.init_translate (pos.x, pos.y);
                this_transform.append (item_translate);
            }

            Graphic.Transform item_transform = transform.copy ();
            this_transform.append (item_transform);

            m_TransformToRootSpace.append (this_transform);
        }
    }

    private void
    calculate_transform_to_window_space ()
    {
        // clear transform
        m_TransformToWindowSpace.init ();

        // add parent transform
        if (!(this is Window))
        {
            // add parent transform
            for (unowned Core.Object? object = this; object != null; object = object.parent)
            {
                unowned Item? item = object as Item;
                if (item != null && item != this)
                {
                    m_TransformToWindowSpace.append (item.m_TransformToWindowSpace.link ());
                    break;
                }

                // If item is under popup chain up on it
                unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
                if (popup != null)
                {
                    object = popup;
                }
            }

            if (visible)
            {
                // add transform
                var this_transform = new Graphic.Transform.identity ();

                // Ignore translation of item without geometry or window managed by application
                // the position of this last is the position under desktop
                if (!(parent is Application))
                {
                    Graphic.Point pos = geometry != null ? geometry.extents.origin : position;
                    Graphic.Transform item_translate = new Graphic.Transform.init_translate (pos.x, pos.y);
                    this_transform.append (item_translate);
                }

                Graphic.Transform item_transform = transform.copy ();
                if (transform.have_rotate)
                {
                    Graphic.Size item_size = geometry != null ? geometry.extents.size : size;
                    item_transform.apply_center_rotate (item_size.width / 2.0, item_size.height / 2.0);
                }
                this_transform.append (item_transform);

                m_TransformToWindowSpace.append (this_transform);
            }
        }
        else
        {
            m_TransformToWindowSpace.append (transform.copy ());
        }
    }

    private void
    calculate_transform_from_window_space ()
    {
        // clear transform
        m_TransformFromWindowSpace.init ();

        // add parent transform
        if (!(this is Window))
        {
            // add parent transform
            for (unowned Core.Object? object = this; object != null; object = object.parent)
            {
                unowned Item? item = object as Item;
                if (item != null && item != this && !(item is Window))
                {
                    m_TransformFromWindowSpace.prepend (item.m_TransformFromWindowSpace.link ());
                    break;
                }

                // If item is under popup chain up on it
                unowned Core.Object? popup = object.get_qdata<unowned Core.Object?> (s_PopupWindow);
                if (popup != null)
                {
                    object = popup;
                }
            }

            if (visible)
            {
                // add transform
                var this_transform = new Graphic.Transform.identity ();
                try
                {
                    Graphic.Transform item_transform = new Graphic.Transform.invert (transform);
                    this_transform.append (item_transform);
                }
                catch (Graphic.Error err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on calculate transform from window %s space: %s", name, err.message);
                }

                // Ignore translation of item without geometry or window managed by application
                // the position of this last is the position under desktop
                if (geometry != null && !(parent is Application))
                {
                    Graphic.Point pos = geometry.extents.origin.invert ();
                    Graphic.Transform item_translate = new Graphic.Transform.init_translate (pos.x, pos.y);
                    this_transform.append (item_translate);
                }

                m_TransformFromWindowSpace.prepend (this_transform);
            }
        }
        else
        {
            try
            {
                m_TransformFromWindowSpace.append (new Graphic.Transform.invert (transform));
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on calculate transform from window %s space: %s", name, err.message);
            }
        }
    }

    private bool
    on_child_grab_pointer (Item inItem)
    {
#if MAIA_DEBUG
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
#endif
        return grab_pointer (inItem);
    }

    private void
    on_child_ungrab_pointer (Item inItem)
    {
#if MAIA_DEBUG
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", inItem.name);
#endif
        ungrab_pointer (inItem);
    }

    private bool
    on_child_grab_keyboard (Item inItem)
    {
#if MAIA_DEBUG
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab keyboard %s", inItem.name);
#endif
        return grab_keyboard (inItem);
    }

    private void
    on_child_ungrab_keyboard (Item inItem)
    {
#if MAIA_DEBUG
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab keyboard %s", inItem.name);
#endif
        ungrab_keyboard (inItem);
    }

    private void
    on_child_geometry_changed (GLib.Object inObject, GLib.ParamSpec? inProperty)
    {
        on_child_resized ((Drawable)inObject);
    }

    private void
    on_child_need_update_changed (GLib.Object inObject, GLib.ParamSpec? inProperty)
    {
        on_child_need_update (inObject as Item);
    }

    protected virtual void
    on_transform_changed ()
    {
        need_update = true;
        geometry = null;

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
#if MAIA_DEBUG
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"item $(name) damaged draw $(damaged.extents) $(area.extents)");
#endif

                inContext.operator = Graphic.Operator.OVER;
                inContext.save ();
                {
                    inContext.line_width = line_width;
                    inContext.dash = line_type.to_dash (line_width);

                    inContext.translate (geometry.extents.origin);
                    if (transform.have_rotate)
                    {
                        var item_area = area;
                        // TODO: Fix rotate transform calculation
                        inContext.translate (Graphic.Point (-geometry.extents.size.width / 2.0, -geometry.extents.size.height / 2.0));
                        inContext.transform = transform;
                        inContext.translate (Graphic.Point (-item_area.extents.size.width, item_area.extents.size.height / 4.0));
                    }
                    else
                    {
                        inContext.transform = transform;
                    }

                    // TODO: Fix rotate transform calculation
                    if (!transform.have_rotate) inContext.clip_region (damaged_area);

                    paint (inContext, damaged_area);
                }
                inContext.restore ();

                repair.post (damaged_area);
            }
        }
    }

    protected virtual void
    on_child_need_update (Item inChild)
    {
        bool child_need_update = inChild.need_update;
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"$name: $(inChild.name) need update $child_need_update");
#endif
        need_update |= child_need_update;
    }

    protected virtual void
    on_child_resized (Drawable inChild)
    {
        if (inChild.geometry == null)
        {
            need_update = true;
            geometry = null;

            notify_property ("geometry");
        }
    }

    protected virtual void
    on_gesture (Gesture.Notification inNotification)
    {
    }

    protected virtual void
    on_damage_area (Graphic.Region inArea)
    {
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

                    var child_damaged_area = area_to_child_item_space (item, inArea);
                    if (!child_damaged_area.is_empty ())
                    {
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"damage child $(item.name) $(child_damaged_area.extents)");
#endif

                        item.damage_area (child_damaged_area);
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
            Graphic.Region child_damaged_area;

            if (inArea == null)
            {
                child_damaged_area = inChild.geometry.copy ();
            }
            else
            {
                child_damaged_area = inChild.area_to_parent_item_space (inArea);
            }

#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"child $((inChild as Item).name) damaged, damage $(child_damaged_area.extents)");
#endif

            // damage item
            m_DamageObserver.block = true;
            damage.post (child_damaged_area);
            m_DamageObserver.block = false;
        }
    }

    protected virtual void
    on_show ()
    {
        // Mark has need to check size
        need_update = true;

        // notify geometry
        notify_property ("geometry");
    }

    protected virtual void
    on_hide ()
    {
        // Remove all damaged area
        repair.post ();

        // Mark has need to check size
        need_update = true;

        // Unset geometry
        if (geometry != null)
        {
            geometry = null;
        }
        else
        {
            // notify geometry
            notify_property ("geometry");
        }
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
        else if (inButton == 1 && this is ItemFocusable && (this as ItemFocusable).can_focus)
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

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "%s size request: %s", name, transformed_size.to_string ());
#endif
        return transformed_size;
    }

    protected void
    paint_background (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        if (background_pattern[state] != null)
        {
            inContext.save ();
            unowned Graphic.Image? image = background_pattern[state] as Graphic.Image;
            if (image != null)
            {
                var item_area = area;
                Graphic.Size image_size = image.size;
                double scale = double.max (image_size.width / item_area.extents.size.width,
                                           image_size.height / item_area.extents.size.height);
                var transform = new Graphic.Transform.identity ();
                transform.scale (scale, scale);
                inContext.translate (Graphic.Point ((item_area.extents.size.width - (image_size.width / scale)) / 2,
                                                    (item_area.extents.size.height - (image_size.height / scale)) / 2));
                image.transform = transform;
                inContext.pattern = background_pattern[state];
            }
            else
            {
                inContext.pattern = background_pattern[state];
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
                ((Drawable)inObject).damage.add_object_observer (on_child_damaged_notification);
            }

            if (inObject is Item)
            {
                // On child need update
                ((Item)inObject).notify["need-update"].connect (on_child_need_update_changed);

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
                if (manifest_theme != null && ((Manifest.Element)inObject).manifest_theme == null)
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
            if (geometry != null)
            {
                geometry = null;
            }
            else
            {
                notify_property ("geometry");
            }
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
                ((Drawable)inObject).damage.remove_observer (on_child_damaged_notification);
            }

            if (inObject is Item)
            {
                // Disconnect from child need update
                ((Item)inObject).notify["need-update"].disconnect (on_child_need_update_changed);

                // Disconnect from child  grab/ungrab pointer
                ((Item)inObject).grab_pointer.disconnect (on_child_grab_pointer);
                ((Item)inObject).ungrab_pointer.disconnect (on_child_ungrab_pointer);

                // Disconnect from child  grab/ungrab keyboard
                ((Item)inObject).grab_keyboard.disconnect (on_child_grab_keyboard);
                ((Item)inObject).ungrab_keyboard.disconnect (on_child_ungrab_keyboard);
            }

            base.remove_child (inObject);

            need_update = true;

            if (geometry != null)
            {
                geometry = null;
            }
            else
            {
                notify_property ("geometry");
            }
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

        // dump theme if any
        bool theme_dump = manifest_theme != null && !manifest_theme.get_qdata<bool> (s_ThemeDumpQuark) && (parent == null || (parent as Manifest.Element).manifest_theme != manifest_theme);
        if (theme_dump)
        {
            ret += inPrefix + manifest_theme.dump (inPrefix) + "\n";
            manifest_theme.set_qdata<bool> (s_ThemeDumpQuark, theme_dump);
        }

        // dump childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Manifest.Element)
            {
                ret += inPrefix + (child as Manifest.Element).dump (inPrefix) + "\n";
            }
        }

        if (theme_dump)
        {
            manifest_theme.set_qdata<bool> (s_ThemeDumpQuark, false);
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

    internal unowned Graphic.Transform?
    to_window_transform ()
    {
        return m_TransformToWindowSpace;
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
#if MAIA_DEBUG
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "update %s: %s", name, inAllocation.extents.to_string ());
#endif

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

    /**
     * Convert a point in window coordinate space to item coordinate space
     *
     * @param inPoint point to convert
     *
     * @return Graphic.Point in item coordinate space
     */
    public Graphic.Point
    convert_from_window_space (Graphic.Point inPoint)
    {
        var point = inPoint;
        point.transform (m_TransformFromWindowSpace);

        return point;
    }
}

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
    static GLib.Quark s_ChainVisibleCount;
    internal static GLib.Quark s_CountHide;

    // class properties
    internal class uint mc_IdButtonPressEvent;
    internal class uint mc_IdButtonReleaseEvent;
    internal class uint mc_IdMotionEvent;
    internal class uint mc_IdScrollEvent;

    // properties
    private bool              m_IsPackable = false;
    private bool              m_IsMovable = false;
    private bool              m_IsResizable = false;
    private bool              m_Visible = true;
    private Graphic.Region    m_Geometry = null;
    private Graphic.Point     m_Position = Graphic.Point (0, 0);
    private Graphic.Size      m_Size = Graphic.Size (0, 0);
    private Graphic.Size      m_SizeRequested = Graphic.Size (0, 0);
    private Graphic.Transform m_Transform = new Graphic.Transform.identity ();
    private Graphic.Transform m_TransformToItemSpace = null;
    private Graphic.Transform m_TransformToRootSpace = null;

    // accessors
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
            }

            base.parent = value;

            // connect onto root change on parent
            if (value != null)
            {
                parent.notify["root"].connect(on_parent_root_changed);

                if (parent is DrawingArea && !(this is Arrow) && !(this is Toolbox))
                {
                    not_dumpable_attributes.remove ("position");
                }
            }

            // Update transform matrix
            m_TransformToItemSpace = get_transform_to_item_space ();
            m_TransformToRootSpace = get_transform_to_root_space ();

            // If item is root do not connect on position change
            if (value == null)
                notify["position"].disconnect (on_move);
            else
                notify["position"].connect (on_move);


            // Send root change notification
            GLib.Signal.emit_by_name (this, "notify::root");
            unref ();
        }
    }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public abstract string tag { get; }

    internal string characters { get; set; default = null; }
    internal string manifest_path { get; set; default = null; }
    internal Core.Set<Manifest.Style> manifest_styles { get; set; default = null; }

    public bool is_packable {
        get {
            return m_IsPackable;
        }
    }

    public bool is_movable {
        get {
            return m_IsMovable;
        }
        set {
            m_IsMovable = value;
        }
        default = false;
    }

    public bool is_resizable {
        get {
            return m_IsResizable;
        }
        set {
            m_IsResizable = value;
        }
        default = false;
    }

    public virtual bool can_focus  { get; set; default = false; }
    public bool         have_focus { get; set; default = false; }

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
            }
        }
        default = true;
    }

    public bool allocate_on_child_add_remove { get; construct set; default = true; }

    internal Graphic.Region geometry {
        get {
            return m_Geometry;
        }
        set {
            if (m_Geometry != value || m_Geometry == null || !m_Geometry.equal (value))
            {
                m_Geometry = value;
                if (m_Geometry == null)
                {
                    request_child_resize ();
                }
                else
                {
                    m_TransformToItemSpace = get_transform_to_item_space ();
                    m_TransformToRootSpace = get_transform_to_root_space ();
                }
            }
        }
    }

    internal Graphic.Region damaged      { get; set; default = null; }
    internal Graphic.Transform transform {
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

            // Update transform matrix
            m_TransformToItemSpace = get_transform_to_item_space ();
            m_TransformToRootSpace = get_transform_to_root_space ();
        }
        default = new Graphic.Transform.identity ();
    }

    public Graphic.Point position {
        get {
            Graphic.Point transformed_position;
            Graphic.Size transformed_size;
            get_transformed_position_and_size (out transformed_position, out transformed_size);
            return transformed_position;
        }
        set {
            m_Position = value;

            // Update transform matrix
            m_TransformToItemSpace = get_transform_to_item_space ();
            m_TransformToRootSpace = get_transform_to_root_space ();
        }
    }

    public Graphic.Size size {
        get {
            notify["size"].disconnect (on_resize);
            m_SizeRequested = ((this is Popup) || visible) ? size_request (m_Size) : Graphic.Size (0, 0);
            notify["size"].connect (on_resize);
            return m_SizeRequested;
        }
        set {
            m_Size = value;
            if (!m_Size.is_empty ())
            {
                not_dumpable_attributes.remove ("size");
            }
            else
            {
                not_dumpable_attributes.insert ("size");
            }
        }
    }

    public Graphic.Size size_requested {
        get {
            return ((this is Popup) || visible) ? m_SizeRequested : Graphic.Size (0, 0);
        }
    }

    public uint            layer                { get; set; default = 0; }
    public Graphic.Pattern fill_pattern         { get; set; default = null; }
    public Graphic.Pattern stroke_pattern       { get; set; default = null; }
    public Graphic.Pattern background_pattern   { get; set; default = null; }
    public double          line_width           { get; set; default = 1.0; }

    public string          chain_visible        { get; set; default = null; }

    public bool            pointer_over         { get; set; default = false; }

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
        GLib.Signal.emit_by_name (this, "notify::root");

        m_TransformToItemSpace = get_transform_to_item_space ();
        m_TransformToRootSpace = get_transform_to_root_space ();
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
                unowned Item? item = find_in_parents (GLib.Quark.from_string (item_name.strip ())) as Item;

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
            if (!m_IsMovable && !m_IsResizable && !(this is Popup))
            {
                geometry = null;
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
            geometry = null;
        }
    }

    private void
    on_transform_changed ()
    {
        // reset item geometry
        if (!m_IsMovable && !m_IsResizable)
        {
            geometry = null;
        }
        else
        {
            geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));
        }

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

    private Graphic.Transform
    get_transform_to_item_space ()
    {
        // Get stack of items
        GLib.SList<unowned Item> list = new GLib.SList<unowned Item?> ();
        for (unowned Core.Object? item = this; item != null; item = item.parent)
        {
            if (item is Item)
            {
                list.append (item as Item);
            }
        }

        // Apply transform invert foreach item
        Graphic.Transform ret = new Graphic.Transform.identity ();
        foreach (unowned Item item in list)
        {
            try
            {
                Graphic.Matrix matrix = item.transform.matrix;
                matrix.invert ();
                Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                ret.add (item_transform);
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on calculate transform to item %s space: %s", name, err.message);
            }

            if (item.geometry != null)
            {
                Graphic.Point pos = item.geometry.extents.origin.invert ();
                Graphic.Transform item_translate = new Graphic.Transform.identity ();
                item_translate.translate (pos.x, pos.y);
                ret.add (item_translate);
            }
        }

        return ret;
    }

    private Graphic.Transform
    get_transform_to_root_space ()
    {
        // Get stack of items
        GLib.SList<unowned Item> list = new GLib.SList<unowned Item?> ();
        for (unowned Core.Object? item = this; item != null; item = item.parent)
        {
            if (item is Item)
            {
                list.prepend (item as Item);
            }
        }

        // Apply transform foreach item
        Graphic.Transform ret = new Graphic.Transform.identity ();
        foreach (unowned Item item in list)
        {
            if (item.geometry != null)
            {
                Graphic.Point pos = item.geometry.extents.origin;
                Graphic.Transform item_translate = new Graphic.Transform.identity ();
                item_translate.translate (pos.x, pos.y);
                ret.add (item_translate);
            }

            Graphic.Matrix matrix = item.transform.matrix;
            Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
            ret.add (item_transform);
        }

        return ret;
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
    on_child_geometry_changed (GLib.Object inObject, GLib.ParamSpec inProperty)
    {
        on_child_resized ((Drawable)inObject);
    }

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
                // Connect under child  grab/ungrab pointer
                ((Item)inObject).grab_pointer.connect (on_child_grab_pointer);
                ((Item)inObject).ungrab_pointer.connect (on_child_ungrab_pointer);

                // Connect under child  grab/ungrab keyboard
                ((Item)inObject).grab_keyboard.connect (on_child_grab_keyboard);
                ((Item)inObject).ungrab_keyboard.connect (on_child_ungrab_keyboard);
            }

            if (inObject is Item && !allocate_on_child_add_remove)
            {
                var item_size = ((Item)inObject).size;
                var item_position = ((Item)inObject).position;
                ((Item)inObject).geometry = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, item_size.width, item_size.height));
                ((Item)inObject).damage ();
            }
            else
            {
                geometry = null;
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
                ((Drawable)inObject).damage.disconnect (on_child_damaged);
            }

            if (inObject is Item)
            {
                // Disconnect from child  grab/ungrab pointer
                ((Item)inObject).grab_pointer.disconnect (on_child_grab_pointer);
                ((Item)inObject).ungrab_pointer.disconnect (on_child_ungrab_pointer);

                // Disconnect from child  grab/ungrab keyboard
                ((Item)inObject).grab_keyboard.disconnect (on_child_grab_keyboard);
                ((Item)inObject).ungrab_keyboard.disconnect (on_child_ungrab_keyboard);
            }

            base.remove_child (inObject);

            if (!allocate_on_child_add_remove)
            {
                damage ();
            }
            else
            {
                geometry = null;
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
            if (inOther is Popup)
                return -1;
            if (this is Popup)
                return 1;
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

        // dump styles
        if (parent == null)
        {
            foreach (unowned Manifest.Style style in manifest_styles)
            {
                ret += style.dump (inPrefix);
            }
        }

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

    protected virtual void
    on_child_resized (Drawable inChild)
    {
        // Child need update request resize
        if (inChild.geometry == null && geometry != null)
        {
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "reset size %s", name);
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

                    item.damage.disconnect (on_child_damaged);

                    var area = area_to_child_item_space (item, inArea);
                    if (!area.is_empty () && (item.damaged == null || item.damaged.is_empty () || item.damaged.contains_rectangle (area.extents) != Graphic.Region.Overlap.IN))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "damage child %s %s", (child as Item).name, area.extents.to_string ());

                        item.damage (area);
                    }

                    item.damage.connect (on_child_damaged);
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
        geometry = null;
        damage ();
    }

    protected virtual void
    on_hide ()
    {
        repair ();
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
        else if (can_focus)
        {
            grab_focus (this);
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

        return false;
    }

    protected virtual void
    request_child_resize ()
    {
        // notify child to request an update
        foreach (unowned Core.Object child in this)
        {
            if (child is Drawable)
            {
                child.notify["geometry"].disconnect (on_child_geometry_changed);
                ((Drawable)child).geometry = null;
                child.notify["geometry"].connect (on_child_geometry_changed);
            }
        }
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
        if (geometry == null)
        {
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "update %s: %s", name, inAllocation.extents.to_string ());

            geometry = inAllocation;

            damage ();
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
}

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
    static GLib.Quark s_ChildGeometryQuark;

    // class properties
    internal class uint mc_IdButtonPressEvent;
    internal class uint mc_IdButtonReleaseEvent;
    internal class uint mc_IdMotionEvent;

    // properties
    private bool              m_IsPackable;
    private bool              m_Visible = true;
    private Graphic.Region    m_Geometry = null;
    private Graphic.Point     m_Position = Graphic.Point (0, 0);
    private Graphic.Size      m_Size = Graphic.Size (0, 0);
    private Graphic.Transform m_TransformToItemSpace = null;
    private Graphic.Transform m_TransformToRootSpace = null;

    // accessors
    [CCode (notify = false)]
    public override Core.Object? parent {
        get {
            return base.parent;
        }
        construct set {
            base.parent = value;

            m_TransformToItemSpace = get_transform_to_item_space ();
            m_TransformToRootSpace = get_transform_to_root_space ();
        }
    }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public abstract string tag { get; }

    internal string characters { get; set; default = null; }

    public bool is_packable {
        get {
            return m_IsPackable;
        }
    }

    public bool have_focus { get; set; default = false; }

    public bool visible {
        get {
            return m_Visible;
        }
        set {
            if (m_Visible != value)
            {
                if (m_Visible)
                {
                    m_Visible = value;
                    repair ();
                }
                else
                {
                    m_Visible = value;
                    damage ();
                }
            }
        }
        default = true;
    }

    public virtual Graphic.Point origin {
        get {
            if (m_Geometry != null)
            {
                return m_Geometry.extents.origin;
            }

            return Graphic.Point (0, 0);
        }
    }

    public Graphic.Region geometry {
        get {
            return m_Geometry;
        }
        protected set {
            m_Geometry = value;
            if (m_Geometry == null)
            {
                // notify child to request an update
                foreach (unowned Core.Object child in this)
                {
                    if (child is Drawable)
                    {
                        ((Drawable)child).geometry = null;
                    }
                }
            }
            else
            {
                m_TransformToItemSpace = get_transform_to_item_space ();
                m_TransformToRootSpace = get_transform_to_root_space ();
            }
        }
    }

    public Graphic.Region damaged      { get; protected set; default = null; }
    public Graphic.Transform transform { get; set; default = new Graphic.Transform.identity (); }

    public uint page { get; set; default = 0; }

    public Graphic.Point position {
        get {
            Graphic.Point transformed_position;
            Graphic.Size transformed_size;
            get_transformed_position_and_size (out transformed_position, out transformed_size);
            return transformed_position;
        }
        set {
            m_Position = value;
        }
    }

    public Graphic.Size size {
        get {
            notify["size"].disconnect (on_move_resize);
            Graphic.Size ret = size_request (m_Size);
            notify["size"].connect (on_move_resize);
            return ret;
        }
        set {
            m_Size = value;
        }
    }

    public uint            layer        { get; set; default = 0; }
    public Graphic.Pattern fill_color   { get; set; default = null; }
    public Graphic.Pattern stroke_color { get; set; default = null; }
    public Graphic.Pattern background   { get; set; default = null; }
    public double          line_width   { get; set; default = 1.0; }

    // signals
    public signal void grab_focus (Item? inItem);
    public signal bool grab_pointer ();
    public signal void ungrab_pointer ();
    public signal bool grab_keyboard ();
    public signal void ungrab_keyboard ();

    public signal bool button_press_event (uint inButton, Graphic.Point inPosition);
    public signal bool button_release_event (uint inButton, Graphic.Point inPosition);
    public signal bool motion_event (uint inButton, Graphic.Point inPosition);
    public signal void key_press_event (Key inKey, unichar inChar);
    public signal void key_release_event (Key inKey, unichar inChar);


    // static methods
    static construct
    {
        // create quarks
        s_ChildGeometryQuark = GLib.Quark.from_string ("MaiaGroupChildGeometry");

        // get mouse event id
        mc_IdButtonPressEvent = GLib.Signal.lookup ("button-press-event", typeof (Item));
        mc_IdButtonReleaseEvent = GLib.Signal.lookup ("button-release-event", typeof (Item));
        mc_IdMotionEvent = GLib.Signal.lookup ("motion-event", typeof (Item));
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("name");
        not_dumpable_attributes.insert ("origin");
        not_dumpable_attributes.insert ("geometry");
        not_dumpable_attributes.insert ("damaged");
        not_dumpable_attributes.insert ("is-packable");

        // check if object is packable
        m_IsPackable = this is ItemPackable;

        // connect to mouse events
        button_press_event.connect (on_button_press_event);
        button_release_event.connect (on_button_release_event);
        motion_event.connect (on_motion_event);

        // connect to damage event
        damage.connect (on_damage);

        // connect to trasnform events
        transform.changed.connect (on_transform_changed);
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
        notify["position"].connect (on_move_resize);
        notify["size"].connect (on_move_resize);
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
    on_move_resize ()
    {
        // if item was moved
        if (geometry != null && parent != null && parent is Item)
        {
            // keep old geometry
            Graphic.Region old_geometry = geometry.copy ();
            // reset item geometry
            geometry = null;
            // damage parent
            (parent as Item).damage (old_geometry);
        }
        else
        {
            geometry = null;
        }
    }

    private void
    on_transform_changed ()
    {
        geometry = null;
    }

    private void
    draw (Graphic.Context inContext) throws Graphic.Error
    {
        if (visible && geometry != null && damaged != null && !damaged.is_empty ())
        {
            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, "item %s damaged draw", name);
            inContext.operator = Graphic.Operator.OVER;
            inContext.save ();
            {
                inContext.translate (geometry.extents.origin);
                inContext.line_width = line_width;
                inContext.clip_region (damaged);

                if (transform.matrix.xy != 0 || transform.matrix.yx != 0)
                {
                    var center = Graphic.Point(geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);

                    inContext.translate (center);
                    inContext.transform = transform;
                    inContext.translate (center.invert ());
                }
                else
                    inContext.transform = transform;

                paint (inContext);
            }
            inContext.restore ();
            repair ();
        }
    }

    private void
    on_damage (Graphic.Region? inArea = null)
    {
        if (visible)
        {
            // Damage all childs
            foreach (unowned Core.Object child in this)
            {
                if (child is Item && (child as Item).visible && (child as Drawable).geometry != null)
                {
                    (child as Item).damage.disconnect (on_child_damaged);
                    if (inArea == null)
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "damage child %s", (child as Item).name);
                        (child as Item).damage (null);
                    }
                    else
                    {
                        var area = damaged.copy ();
                        area.intersect ((child as Drawable).geometry);
                        area.translate ((child as Drawable).geometry.extents.origin.invert ());
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "damage child %s %s", (child as Item).name, area.extents.to_string ());
                        (child as Item).damage (area);
                    }
                    (child as Item).damage.connect (on_child_damaged);
                }
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
                list.prepend (item as Item);
            }
        }

        // Apply transform invert foreach item
        Graphic.Transform ret = new Graphic.Transform.identity ();
        foreach (unowned Item item in list)
        {
            Graphic.Point pos = item.origin.invert ();
            Graphic.Transform item_translate = new Graphic.Transform.identity ();
            item_translate.translate (pos.x, pos.y);
            item_translate.parent = ret;

            try
            {
                Graphic.Matrix matrix = item.transform.matrix;
                matrix.invert ();
                Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                item_transform.parent = ret;
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on calculate transform to item %s space: %s", name, err.message);
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
            Graphic.Point pos = item.origin;
            Graphic.Transform item_translate = new Graphic.Transform.identity ();
            item_translate.translate (pos.x, pos.y);
            item_translate.parent = ret;

            Graphic.Matrix matrix = item.transform.matrix;
            Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
            item_transform.parent = ret;
        }

        return ret;
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
                damaged_area = inArea.copy ();
                damaged_area.transform (inChild.transform);
                damaged_area.translate (inChild.geometry.extents.origin);
            }

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

            // damage item
            damage (damaged_area);
        }
    }

    private void
    on_child_grab_focus (Item? inItem)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);
        grab_focus (inItem);
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
                ulong id = inObject.notify["geometry"].connect (() => {
                    // Child need update request resize
                    if (((Item)inObject).geometry == null && geometry != null)
                    {
                        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "reset size %s", name);
                        geometry = null;
                    }
                });

                // Save child id signal
                inObject.set_qdata<ulong> (s_ChildGeometryQuark, id);

                // Connect under child damage
                ((Drawable)inObject).damage.connect (on_child_damaged);
            }

            if (inObject is Item)
            {
                // Connect under child grab focus
                ((Item)inObject).grab_focus.connect (on_child_grab_focus);
            }

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
                ulong id = inObject.get_qdata<ulong> (s_ChildGeometryQuark);
                if (id != 0)
                {
                    GLib.SignalHandler.disconnect (inObject, id);
                }

                // Disconnect from child damage
                ((Drawable)inObject).damage.disconnect (on_child_damaged);
            }

            if (inObject is Item)
            {
                // Disconnect from child grab
                ((Item)inObject).grab_focus.disconnect (on_child_grab_focus);            }

            geometry = null;
        }

        base.remove_child (inObject);
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
        else if (inOther is ToggleGroup)
        {
            // Toggle group always first
            ret = 1;
        }

        // on same row, column and layer order by id
        if (ret == 0)
        {
            ret = base.compare (inOther);
        }

        return ret;
    }

    internal override string
    to_string ()
    {
        return dump ();
    }

    protected virtual bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (geometry != null)
        {
            ret = inPoint in geometry.extents.size;
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
        }

        return ret;
    }

    protected virtual bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (geometry != null)
        {
            ret = inPoint in geometry.extents.size;
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
        }

        return ret;
    }

    protected virtual bool
    on_motion_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (geometry != null)
        {
            ret = inPoint in geometry.extents.size;
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
        }

        return ret;
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

    protected abstract void paint (Graphic.Context inContext) throws Graphic.Error;

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

    public Graphic.Point
    convert_to_child_item_space (Item inChild, Graphic.Point inPoint)
    {
        // Transform point to item coordinate space
        Graphic.Point point = inPoint;
        point.translate (inChild.origin.invert ());

        try
        {
            var matrix = inChild.transform.matrix;
            matrix.invert ();
            var child_transform = new Graphic.Transform.from_matrix (matrix);

            point.transform (child_transform);
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "%s error on convert %s to child %s item space: %s",
                          name, inPoint.to_string (), inChild.name, err.message);
        }

        return point;
    }

    public Graphic.Point
    convert_to_item_space (Graphic.Point inRootPoint)
    {
        var point = inRootPoint;
        point.transform (m_TransformToItemSpace);

        return point;
    }

    public Graphic.Point
    convert_to_root_space (Graphic.Point inPoint)
    {
        var point = inPoint;
        point.transform (m_TransformToRootSpace);

        return point;
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawing-area.vala
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

public class Maia.DrawingArea : Group, ItemPackable, ItemFocusable
{
    // types
    private enum SelectedItemState
    {
        NONE,
        SELECTED,
        MOVING,
        MOVED,
        RESIZING
    }

    // static properties
    private static GLib.Quark s_QuarkRotateItem;

    // properties
    private uint              m_SelectedOldLayer = 0;
    private unowned Item?     m_SelectedItem = null;
    private SelectedItemState m_SelectedItemState = SelectedItemState.NONE;
    private Graphic.Point     m_LastPointerPosition;
    private FocusGroup        m_FocusGroup = null;
    public Graphic.Path       m_AnchorPath;

    // accessors
    internal override string tag {
        get {
            return "DrawingArea";
        }
    }

    internal bool   can_focus   { get; set; default = true; }
    internal bool   have_focus  { get; set; default = false; }
    internal int    focus_order { get; set; default = -1; }
    internal FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    [CCode (notify = false)]
    public unowned Item? selected  {
        get {
            return m_SelectedItem;
        }
        set {
            // Selected has changed
            if (m_SelectedItem != value)
            {
                // Damage the old selected item
                if (m_SelectedItem != null)
                {
                    m_SelectedItem.state = State.NORMAL;
                    m_SelectedItem.layer = m_SelectedOldLayer;
                    if (m_SelectedItem is Arrow)
                    {
                        unowned Arrow arrow = (Arrow)m_SelectedItem;
                        if (arrow.linked_item != null)
                        {
                            // Search linked item
                            unowned Item? item = find (GLib.Quark.from_string (arrow.linked_item)) as Item;
                            if (item != null)
                            {
                                item.damage.post ();
                                arrow.damage.post ();
                            }
                        }
                    }
                    else
                    {
                        m_SelectedItem.damage.post ();
                    }
                }

                m_SelectedItemState = SelectedItemState.NONE;
                m_SelectedItem = value;

                // Set selected item have focus
                grab_focus (m_SelectedItem);

                // Damage the new selected item
                if (m_SelectedItem != null)
                {
                    m_SelectedItem.state = State.ACTIVE;
                    m_SelectedOldLayer = m_SelectedItem.layer;
                    if (!(m_SelectedItem is Shape))
                    {
                        m_SelectedItem.layer = ((Item)last ()).layer + 1;
                    }
                    m_SelectedItemState = SelectedItemState.SELECTED;

                    if (m_SelectedItem is Arrow)
                    {
                        unowned Arrow arrow = (Arrow)m_SelectedItem;
                        if (arrow.linked_item != null)
                        {
                            // Search linked item
                            unowned Item? item = find (GLib.Quark.from_string (arrow.linked_item)) as Item;
                            if (item != null)
                            {
                                item.damage.post ();
                                arrow.damage.post ();
                            }
                        }
                    }
                    else
                    {
                        m_SelectedItem.damage.post ();
                    }
                }
            }
            // selected has not changed update selected item state
            else if (m_SelectedItem != null)
            {
                set_selected_item_state ();
            }
        }
        default = null;
    }

    public double        anchor_size                { get; set; default = 12.0; }
    public double        selected_border            { get; set; default = 5.0; }
    public double        selected_border_line_width { get; set; default = 1.0; }
    public Graphic.Color selected_border_color      { get; set; default = new Graphic.Color (0, 0, 0); }

    /**
     * Touchscreen mode
     */
    public bool touchscreen_mode { get; set; default = false; }

    // static methods
    static construct
    {
        s_QuarkRotateItem = GLib.Quark.from_string ("MaiaDrawingAreaRotateItem");

        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("selected");
    }

    public DrawingArea (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    create_anchor_path ()
    {
        if (selected_border > 0 && selected != null && m_SelectedItemState > SelectedItemState.SELECTED)
        {
            double asize = anchor_size + selected_border / 2;
            double arrow_size = anchor_size / 6;
            Graphic.Size item_size = selected.size;
            item_size.resize (anchor_size + selected_border, anchor_size + selected_border);

            switch (m_SelectedItemState)
            {
                case SelectedItemState.MOVED:
                case SelectedItemState.MOVING:
                    // Create anchor
                    string pathVert = "m %2$g,0 l -%3$g,%3$g m %3$g,-%3$g l %3$g,3 m -%3$g,-%3$g l 0,%1$g l -%3$g,-3 m %3$g,%3$g l %3$g,-%3$g".printf (asize, asize / 2, arrow_size);
                    string pathHoriz = "m 0,%2$g l %3$g,-%3$g m -%3$g,%3$g l %3$g,%3$g m -%3$g,-%3$g l %1$g,0 l -%3$g,-%3$g m %3$g,%3$g l -%3$g,%3$g".printf (asize, asize / 2, arrow_size);

                    m_AnchorPath = new Graphic.Path ();
                    m_AnchorPath.parse ("M 0,0 %s M 0,0 %s". printf (pathVert, pathHoriz));
                    break;

                case SelectedItemState.RESIZING:
                    string pathVert = "m %2$g,%3$g l -%3$g,%3$g m %3$g,-%3$g l %3$g,%3$g m -%3$g,-%3$g l 0,%1$g l -%3$g,-%3$g m %3$g,%3$g l %3$g,-%3$g". printf (asize - arrow_size , asize / 2, arrow_size);
                    string pathHoriz = "m %3$g,%2$g l %3$g,-%3$g m -%3$g,%3$g l %3$g,%3$g m -%3$g,-%3$g l %1$g,0 l -%3$g,-%3$g m %3$g,%3$g l -%3$g,%3$g". printf (asize - arrow_size, asize / 2, arrow_size);
                    string pathTopLeft = "m %2$g,%1$g l -%3$g,-%3$g m %3$g,%3$g l %3$g,-%3$g m -%3$g,%3$g q 0,-%2$g %2$g,-%2$g l -%3$g,-%3$g m %3$g,%3$g l -%3$g,%3$g".printf (asize, asize / 2, arrow_size);
                    string pathTopRight = "m 0,%1$g l %2$g,-%2$g m -%2$g,%2$g l %2$g,%2$g m -%2$g,-%2$g q %1$g,0 %1$g,%1$g l -%2$g,-%2$g m %2$g,%2$g l %2$g,-%2$g".printf (asize / 2, arrow_size);
                    string pathBottomRight = "m %1$g,0 l -%2$g,%2$g m %2$g,-%2$g l %2$g,%2$g m -%2$g,-%2$g q 0,%1$g -%1$g,%1$g l %2$g,%2$g m -%2$g,-%2$g l %2$g,-%2$g".printf (asize / 2, arrow_size);
                    string pathBottomLeft = "m %1$g,0 l -%2$g,%2$g m %2$g,-%2$g l %2$g,%2$g m -%2$g,-%2$g q 0,%1$g %1$g,%1$g l -%2$g,-%2$g m %2$g,%2$g l -%2$g,%2$g".printf (asize / 2, arrow_size);

                    string topLeft = "M 0,0 %1$s ".printf (pathTopLeft);
                    string top = "M %1$g,0 %2$s ".printf (item_size.width / 2, pathVert);
                    string topRight = "M %1$g,0 %2$s ".printf (item_size.width + arrow_size, pathTopRight);
                    string right = "M %1$g,%2$g %3$s ".printf (item_size.width + arrow_size, item_size.height / 2, pathHoriz);
                    string bottomRight = "M %1$g,%2$g %3$s ".printf (item_size.width + arrow_size, item_size.height + arrow_size, pathBottomRight);
                    string bottom = "M %1$g,%2$g %3$s ".printf (item_size.width / 2, item_size.height + arrow_size, pathVert);
                    string bottomLeft = "M 0,%1$g %2$s ".printf (item_size.height + arrow_size, pathBottomLeft);
                    string left = "M 0,%1$g %2$s ".printf (item_size.height / 2, pathHoriz);

                    m_AnchorPath = new Graphic.Path ();
                    m_AnchorPath.parse (topLeft + top + topRight + right + bottomRight + bottom + bottomLeft + left);
                    break;
            }
        }
    }

    private void
    set_selected_item_state ()
    {
        if (m_SelectedItemState == SelectedItemState.SELECTED && m_SelectedItem.is_movable)
        {
            m_SelectedItemState = SelectedItemState.MOVING;
            m_AnchorPath = null;

            // Grab pointer and set invisible
            grab_pointer (this);
            if (!touchscreen_mode)
            {
                set_pointer_cursor (Cursor.BLANK_CURSOR);
            }
        }
        else if ((m_SelectedItemState == SelectedItemState.SELECTED || m_SelectedItemState == SelectedItemState.MOVING) && m_SelectedItem.is_resizable)
        {
            if (m_SelectedItemState == SelectedItemState.SELECTED)
            {
                // Grab pointer and set invisible
                grab_pointer (this);
                set_pointer_cursor (Cursor.BLANK_CURSOR);
            }

            if (!touchscreen_mode)
            {
                m_SelectedItemState = SelectedItemState.RESIZING;
            }
            m_AnchorPath = null;
        }
        else
        {
            m_SelectedItemState = SelectedItemState.SELECTED;
            m_AnchorPath = null;

            // Ungrab pointer and restore cursor
            ungrab_pointer (this);
            if (!touchscreen_mode)
            {
                set_pointer_cursor (Cursor.TOP_LEFT_ARROW);
            }
        }

        // Damage item
        m_SelectedItem.damage.post ();
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        if (inObject == m_SelectedItem)
        {
            m_SelectedItemState = SelectedItemState.NONE;
            m_SelectedItem = null;
            grab_focus (null);
        }
    }

    internal override void
    on_child_need_update (Item inChild)
    {
        if (inChild is Arrow && inChild.need_update && inChild.geometry != null)
        {
            var child_position = inChild.position;
            var child_size = inChild.size;

            inChild.damage.post ();
            inChild.geometry = new Graphic.Region (Graphic.Rectangle (child_position.x, child_position.y, child_size.width, child_size.height));
            inChild.repair.post ();
            inChild.damage.post ();
        }
    }

    internal override void
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

            // damaged child is the selected item
            if (inChild == (Drawable)selected || (inChild is Item && selected is Arrow && (selected as Arrow).linked_item == (inChild as Item).name))
            {
                // calculate item geometry with border
                var child_area_pos = inChild.geometry.extents.origin;
                child_area_pos.translate (Graphic.Point (-selected_border * 2.0, -selected_border * 2.0));
                var child_area_size = inChild.geometry.extents.size;
                child_area_size.resize (selected_border * 4.0, selected_border * 4.0);

                // If item is movable add anchor size
                if ((selected.is_movable || selected.is_resizable) && !(selected is Shape))
                {
                    Graphic.Point anchor_border = Graphic.Point (anchor_size, anchor_size);
                    child_area_pos.translate (anchor_border.invert ());
                    child_area_size.resize (anchor_size * 2.0, anchor_size * 2.0);
                }

                var border_area = new Graphic.Region (Graphic.Rectangle ((double)(int)child_area_pos.x, (double)(int)child_area_pos.y,
                                                                         GLib.Math.floor (child_area_size.width + child_area_pos.x) - (double)(int)child_area_pos.x,
                                                                         GLib.Math.floor (child_area_size.height + child_area_pos.y) - (double)(int)child_area_pos.y));

                // subtract child geometry to have border area
                border_area.subtract (inChild.geometry);
                damaged_area.union_ (border_area);
            }

            // damage item
            damage.post (damaged_area);
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (area != null)
        {
            ret = inPoint in area;
        }

        if (m_SelectedItemState > SelectedItemState.SELECTED && inButton == 1)
        {
            set_selected_item_state ();
            ret = false;
        }
        else if (!ret)
        {
            selected = null;
            GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
        }
        else if (inButton == 1)
        {
            m_LastPointerPosition = inPoint;

            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_press_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        ret = false;
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);

                        // Set the selected item
                        if (item.is_movable || item.is_resizable || item.is_selectable)
                        {
                            selected = item;
                        }

                        break;
                    }
                }

                child = child.prev ();
            }

            if (ret)
            {
                selected = null;
                grab_focus (this);
            }
        }
        else
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_press_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        ret = false;
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
            }
        }

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = false;

        if (m_SelectedItem != null && m_SelectedItemState > SelectedItemState.SELECTED)
        {
            ret = true;
            switch (m_SelectedItemState)
            {
                case SelectedItemState.MOVING:
                    m_SelectedItemState = SelectedItemState.MOVED;
                    m_LastPointerPosition = inPoint;
                    break;

                case SelectedItemState.MOVED:
                    if (selected.is_movable)
                    {
                        var offset = inPoint;
                        offset.subtract (m_LastPointerPosition);
                        m_LastPointerPosition = inPoint;
                        ((ItemMovable)selected).move (offset);
                    }
                    break;

                case SelectedItemState.RESIZING:
                    if (selected.is_resizable)
                    {
                        var offset = inPoint;
                        offset.subtract (m_LastPointerPosition);
                        m_LastPointerPosition = inPoint;
                        ((ItemResizable)selected).resize (offset);

                        m_AnchorPath = null;
                    }
                    break;
            }
        }
        else
        {
            ret = base.on_motion_event (inPoint);
        }

        return ret;
    }

    internal override bool
    on_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        bool ret = false;

        if (m_SelectedItem != null && m_SelectedItemState == SelectedItemState.RESIZING)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_SelectedItem.convert_to_child_item_space (m_SelectedItem, inPoint);

            // Point under selected item
            if (m_SelectedItem.scroll_event (inScroll, point))
            {
                int rotate = 0;

                switch (inScroll)
                {
                    case Scroll.UP:
                    case Scroll.LEFT:
                        rotate = 5;
                        ret = true;
                        break;

                    case Scroll.DOWN:
                    case Scroll.RIGHT:
                        rotate = -5;
                        ret = true;
                        break;
                }
                if (ret)
                {
                    foreach (unowned Core.Object child in m_SelectedItem.transform)
                    {
                        int is_rotate = child.get_qdata<int> (s_QuarkRotateItem);
                        if (is_rotate != 0)
                        {
                            unowned Graphic.Transform? rotate_transform = child as Graphic.Transform;
                            rotate += rotate_transform.get_qdata<int> (s_QuarkRotateItem);
                            rotate_transform.parent = null;
                            break;
                        }
                    }

                    rotate %= 360;

                    if (rotate != 0)
                    {
                        var t = new Graphic.Transform.init_rotate ((double)rotate * 2.0 * GLib.Math.PI / 360.0);
                        t.set_qdata<int> (s_QuarkRotateItem, rotate);
                        m_SelectedItem.transform.add (t);
                    }
                }
            }
        }

        GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Arrow)
            {
                unowned Arrow arrow = (Arrow)child;

                if (arrow.visible)
                {
                    arrow.draw (inContext, area_to_child_item_space (arrow, inArea));

                    if (arrow == selected && arrow.linked_item != null)
                    {
                        // Search linked item
                        unowned Item? item = find (GLib.Quark.from_string (arrow.linked_item), false) as Item;
                        if (item != null)
                        {
                            // Clip area whithout linked item area
                            var clip_area = arrow.geometry.copy ();
                            var item_geometry = item.geometry.copy ();
                            item_geometry.translate (Graphic.Point (-selected_border / 2.0, -selected_border / 2.0));
                            var item_size = item_geometry.extents.size;
                            item_size.resize (selected_border, selected_border);
                            item_geometry.resize (item_size);
                            clip_area.subtract (item_geometry);

                            // Draw arrow selected rectangle
                            var path = new Graphic.Path ();
                            var start_arrow = arrow.start;
                            var end_arrow = arrow.end;

                            double width = start_arrow.x - end_arrow.x;
                            double height = start_arrow.y - end_arrow.y;

                            double angle = GLib.Math.atan2 (height, width);

                            var arrow_transform = new Graphic.Transform.identity ();
                            arrow_transform.translate (start_arrow.x, start_arrow.y);
                            arrow_transform.rotate (angle);
                            arrow_transform.translate (-start_arrow.x, -start_arrow.y);
                            path.rectangle (start_arrow.x - GLib.Math.sqrt (GLib.Math.pow (width, 2) + GLib.Math.pow (height, 2)),
                                            start_arrow.y - selected_border - arrow.arrow_width / 2.0,
                                            GLib.Math.sqrt (GLib.Math.pow (width, 2) + GLib.Math.pow (height, 2)) + selected_border * 2.0,
                                            (selected_border * 2) + arrow.arrow_width,
                                            selected_border * 2, selected_border * 2);

                            inContext.save ();
                            {
                                inContext.clip_region (clip_area);
                                inContext.transform = arrow_transform;
                                inContext.dash = { 2, 2 };
                                inContext.line_width = selected_border_line_width;
                                inContext.pattern = selected_border_color;
                                inContext.stroke (path);
                            }
                            inContext.restore ();

                            // Create mask for item selected area
                            var mask = new Graphic.Surface.similar (inContext.surface, (int)geometry.extents.size.width, (int)geometry.extents.size.height);
                            mask.clear ();
                            mask.context.operator = Graphic.Operator.SOURCE;
                            var path_item = new Graphic.Path ();

                            path_item.rectangle (item.geometry.extents.origin.x - selected_border / 2.0,
                                                 item.geometry.extents.origin.y - selected_border / 2.0,
                                                 item.geometry.extents.size.width + selected_border,
                                                 item.geometry.extents.size.height + selected_border,
                                                 selected_border, selected_border);

                            mask.context.dash = { 2, 2 };
                            mask.context.line_width = selected_border_line_width;
                            mask.context.pattern = new Graphic.Color (0, 0, 0, 1);
                            mask.context.stroke (path_item);

                            mask.context.transform = arrow_transform;
                            mask.context.pattern = new Graphic.Color (0, 0, 0, 0);
                            mask.context.fill (path);

                            inContext.pattern = selected_border_color;
                            inContext.mask (mask);
                        }
                    }
                }
            }
            else if (child is Item)
            {
                unowned Item item = (Item)child;

                if (item.visible)
                {
                    var child_damaged_area = area_to_child_item_space (item, inArea);
                    if (!child_damaged_area.is_empty ())
                    {
                        item.draw (inContext, child_damaged_area);

                        if (item == selected && (item.is_movable || item.is_resizable) && !(item is Shape))
                        {
                            if (m_SelectedItemState > SelectedItemState.SELECTED)
                            {
                                inContext.save ();
                                {
                                    inContext.translate (item.geometry.extents.origin);
                                    inContext.translate (Graphic.Point (selected_border + anchor_size, selected_border + anchor_size).invert ());
                                    if (m_AnchorPath == null) create_anchor_path ();
                                    inContext.pattern = selected_border_color;
                                    inContext.stroke (m_AnchorPath);
                                }
                                inContext.restore ();
                            }

                            var path = new Graphic.Path ();
                            path.rectangle (item.geometry.extents.origin.x - selected_border / 2.0,
                                            item.geometry.extents.origin.y - selected_border / 2.0,
                                            item.geometry.extents.size.width + selected_border,
                                            item.geometry.extents.size.height + selected_border,
                                            selected_border, selected_border);

                            inContext.dash = { 2, 2 };
                            inContext.line_width = selected_border_line_width;
                            inContext.pattern = selected_border_color;
                            inContext.stroke (path);
                        }
                    }
                }
            }
        }
    }
}

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

public class Maia.DrawingArea : Group, ItemPackable
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

    // properties
    private uint              m_SelectedOldLayer = 0;
    private unowned Item?     m_SelectedItem = null;
    private SelectedItemState m_SelectedItemState = SelectedItemState.NONE;
    private Graphic.Point     m_LastPointerPosition;
    public Graphic.Path       m_AnchorPath;

    // accessors
    internal override string tag {
        get {
            return "DrawingArea";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

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
                    m_SelectedItem.layer = m_SelectedOldLayer;
                    m_SelectedItem.damage ();
                }

                m_SelectedItemState = SelectedItemState.NONE;
                m_SelectedItem = value;

                // Set selected item have focus
                grab_focus (m_SelectedItem);

                // Damage the new selected item
                if (m_SelectedItem != null)
                {
                    m_SelectedOldLayer = m_SelectedItem.layer;
                    m_SelectedItem.layer = ((Item)last ()).layer + 1;
                    m_SelectedItemState = SelectedItemState.SELECTED;
                    m_SelectedItem.damage ();
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
            set_pointer_cursor (Cursor.BLANK_CURSOR);
        }
        else if ((m_SelectedItemState == SelectedItemState.SELECTED || m_SelectedItemState == SelectedItemState.MOVING) && m_SelectedItem.is_resizable)
        {
            if (m_SelectedItemState == SelectedItemState.SELECTED)
            {
                // Grab pointer and set invisible
                grab_pointer (this);
                set_pointer_cursor (Cursor.BLANK_CURSOR);
            }

            m_SelectedItemState = SelectedItemState.RESIZING;
            m_AnchorPath = null;
        }
        else
        {
            m_SelectedItemState = SelectedItemState.SELECTED;
            m_AnchorPath = null;

            // Ungrab pointer and restore cursor
            ungrab_pointer (this);
            set_pointer_cursor (Cursor.TOP_LEFT_ARROW);
        }

        // Damage item
        m_SelectedItem.damage ();
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
                damaged_area = inArea.copy ();
                damaged_area.transform (inChild.transform);
                damaged_area.translate (inChild.geometry.extents.origin);
            }

            // damaged child is the selected item
            if (inChild == selected)
            {
                // Add border to damage area
                damaged_area.translate (Graphic.Point (-selected_border, -selected_border));
                var area_size = damaged_area.extents.size;
                area_size.resize (selected_border * 2.0, selected_border * 2.0);

                // If item is movable add anchor size
                if (selected.is_movable || selected.is_resizable)
                {
                    Graphic.Point anchor_border = Graphic.Point (anchor_size + selected_border_line_width,
                                                                 anchor_size + selected_border_line_width);
                    damaged_area.translate (anchor_border.invert ());
                    area_size.resize (anchor_border.x * 2.0, anchor_border.y * 2.0);
                }

                damaged_area.resize (area_size);
            }

            // damage item
            damage (damaged_area);
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (geometry != null)
        {
            ret = inPoint in geometry.extents.size;
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
                    Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_press_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        ret = false;
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);

                        // Set the selected item;
                        selected = item;

                        break;
                    }
                }

                child = child.prev ();
            }

            if (ret)
            {
                selected = null;
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

        if (m_SelectedItem != null && m_SelectedItemState == SelectedItemState.RESIZING &&
            geometry != null && inPoint in geometry)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_SelectedItem.convert_to_child_item_space (m_SelectedItem, inPoint);

            // Point under selected item
            if (m_SelectedItem.scroll_event (inScroll, point))
            {
                switch (inScroll)
                {
                    case Scroll.UP:
                    case Scroll.LEFT:
                        m_SelectedItem.damage ();
                        m_SelectedItem.transform.rotate (5 * 2 * GLib.Math.PI / 360);
                        m_SelectedItem.damage ();
                        ret = true;
                        break;

                    case Scroll.DOWN:
                    case Scroll.RIGHT:
                        m_SelectedItem.damage ();
                        m_SelectedItem.transform.rotate (-5 * 2 * GLib.Math.PI / 360);
                        m_SelectedItem.damage ();
                        ret = true;
                        break;
                }
            }
        }

        GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        if (background != null)
        {
            inContext.save ();
            unowned Graphic.Image? image = background as Graphic.Image;
            if (image != null)
            {
                Graphic.Size image_size = image.size;
                double scale = double.max (geometry.extents.size.width / image_size.width,
                                           geometry.extents.size.height / image_size.height);
                image_size.width *= scale;
                image_size.height *= scale;
                image.size = image_size;

                inContext.pattern = background;
                inContext.translate (Graphic.Point ((geometry.extents.size.width - image_size.width) / 2, (geometry.extents.size.height - image_size.height) / 2));
            }
            else
            {
                inContext.pattern = background;
            }
            inContext.paint ();
            inContext.restore ();
        }

        // paint childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Item)
            {
                Item item = (Item)child;

                item.draw (inContext);

                if (item == selected)
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

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
    // properties
    private unowned Item? m_ItemSelected = null;
    private unowned Item? m_ItemInMove = null;
    private Graphic.Point m_LastPointerPosition;

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
            return m_ItemSelected;
        }
        set {
            if (m_ItemSelected != value)
            {
                // Damage the old selected item
                if (m_ItemSelected != null)
                {
                    m_ItemSelected.damage ();
                }

                m_ItemSelected = value;

                // Set selected item have focus
                grab_focus (m_ItemSelected);

                // Damage the new selected item
                if (m_ItemSelected != null)
                {
                    m_ItemSelected.damage ();
                }
            }
        }
        default = null;
    }

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

        if (!ret)
        {
            selected = null;
            GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
        }
        else if (m_ItemInMove != null)
        {
            m_ItemInMove = null;
            ungrab_pointer (this);
            set_pointer_cursor (Cursor.TOP_LEFT_ARROW);
            ret = false;
            GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
        }
        else
        {
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
                        if (selected == item && item is ItemMovable)
                        {
                            m_ItemInMove = item;
                            m_LastPointerPosition = inPoint;
                            grab_pointer (this);
                            set_pointer_cursor (Cursor.BLANK_CURSOR);
                        }

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

        if (m_ItemInMove != null)
        {
            ret = true;
            var offset = inPoint;
            offset.subtract (m_LastPointerPosition);
            m_LastPointerPosition = inPoint;
            ((ItemMovable)m_ItemInMove).move (offset);
        }
        else
        {
            ret = base.on_motion_event (inPoint);
        }

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

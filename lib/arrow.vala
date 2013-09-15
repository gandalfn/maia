/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * arrow.vala
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

public class Maia.Arrow : Item, ItemMovable
{
    // properties
    private string m_LinkedItem = null;

    // accessors
    internal override string tag {
        get {
            return "Arrow";
        }
    }

    internal override string characters { get; set; default = null; }

    public Graphic.Point start { get; set; default = Graphic.Point (0, 0); }
    public Graphic.Point end {
        get {
            if (linked_item != null && parent is DrawingArea)
            {
                // Search linked item
                unowned Item? item = parent.find (GLib.Quark.from_string (linked_item)) as Item;
                if (item != null)
                {
                    var item_pos = item.position;
                    var item_size = item.size_requested;

                    return Graphic.Point (item_pos.x + (item_size.width / 2), item_pos.y + (item_size.height / 2));
                }
            }

            return Graphic.Point (0, 0);
        }
    }
    public string linked_item {
        get {
            return m_LinkedItem;
        }
        set {
            if (m_LinkedItem != null)
            {
                unowned Item? item = parent.find (GLib.Quark.from_string (m_LinkedItem)) as Item;
                if (item != null)
                {
                    item.notify["size"].disconnect (on_linked_item_geometry_changed);
                    item.notify["position"].disconnect (on_linked_item_geometry_changed);
                }
            }

            m_LinkedItem = value;

            if (m_LinkedItem != null)
            {
                unowned Item? item = parent.find (GLib.Quark.from_string (m_LinkedItem)) as Item;
                if (item != null)
                {
                    item.notify["size"].connect (on_linked_item_geometry_changed);
                    item.notify["position"].connect (on_linked_item_geometry_changed);
                }
            }
        }
        default = null;
    }
    public double arrow_width { get; set; default = 10; }
    public double arrow_angle { get; set; default = GLib.Math.PI / 6; }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("position");
        not_dumpable_attributes.insert ("size");
        not_dumpable_attributes.insert ("end");

        // Set default stroke color
        stroke_pattern = new Graphic.Color (0, 0, 0);

        // Connect onto start changed
        notify["start"].connect (on_linked_item_geometry_changed);
    }

    public Arrow (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_linked_item_geometry_changed ()
    {
        update_size (true);
    }

    private void
    update_size (bool inDamage)
    {
        if (linked_item != null && parent is DrawingArea)
        {
            // Search linked item
            unowned Item? item = parent.find (GLib.Quark.from_string (linked_item)) as Item;
            if (item != null)
            {
                var item_pos = item.position;
                var item_size = item.size_requested;

                var start_area = Graphic.Point (double.min (item_pos.x + (item_size.width / 2), start.x),
                                                double.min (item_pos.y + (item_size.height / 2), start.y));

                var end_area = Graphic.Point (double.max (item_pos.x + (item_size.width / 2), start.x),
                                              double.max (item_pos.y + (item_size.height / 2), start.y));

                start_area.translate (Graphic.Point (-arrow_width, -arrow_width));
                end_area.translate (Graphic.Point (arrow_width, arrow_width));
                var area_size = Graphic.Size (end_area.x - start_area.x, end_area.y - start_area.y);
                if (!size_requested.equal (area_size))
                {
                    if (inDamage) damage ();
                    position = start_area;
                    size = area_size;
                    if (inDamage)
                    {
                        damage ();
                        item.damage ();
                    }
                }
            }
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        update_size (false);

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        // Search linked item
        unowned Item? item = parent.find (GLib.Quark.from_string (linked_item)) as Item;
        if (item != null)
        {
            inContext.save ();
            {
                // Clip area whithout linked item area
                var area = geometry.copy ();
                area.subtract (item.geometry);
                area.translate (area.extents.origin.invert ());
                var clip = new Graphic.Path.from_region (area);
                inContext.clip (clip);

                // Draw line
                var line = new Graphic.Path ();

                var start_point = start;

                var end_point = Graphic.Point (item.geometry.extents.origin.x + item.geometry.extents.size.width / 2,
                                               item.geometry.extents.origin.y + item.geometry.extents.size.height / 2);

                start_point.translate (geometry.extents.origin.invert ());
                end_point.translate (geometry.extents.origin.invert ());

                // Calculate arrow positions
                double angle = GLib.Math.atan2 (start_point.y - end_point.y, start_point.x - end_point.x) + GLib.Math.PI;

                Graphic.Point arrow_point_1 = Graphic.Point (start_point.x + arrow_width * GLib.Math.cos (angle - arrow_angle),
                                                             start_point.y + arrow_width * GLib.Math.sin (angle - arrow_angle));
                Graphic.Point arrow_point_2 = Graphic.Point (start_point.x + arrow_width * GLib.Math.cos (angle + arrow_angle),
                                                             start_point.y + arrow_width * GLib.Math.sin (angle + arrow_angle));

                line.move_to (end_point.x, end_point.y);
                line.line_to (start_point.x, start_point.y);
                inContext.line_width = line_width;
                inContext.pattern = stroke_pattern;
                inContext.stroke (line);

                var arrow = new Graphic.Path ();
                arrow.move_to (start_point.x, start_point.y);
                arrow.line_to (arrow_point_1.x, arrow_point_1.y);
                arrow.line_to (arrow_point_2.x, arrow_point_2.y);
                arrow.line_to (start_point.x, start_point.y);
                inContext.fill (arrow);
            }
            inContext.restore ();
        }
    }

    internal void
    move (Graphic.Point inOffset)
    {
        if (parent != null && parent is DrawingArea)
        {
            unowned DrawingArea drawing_area = (DrawingArea)parent;

            if (drawing_area.geometry != null)
            {
                // translate the current start
                var new_position = start;
                new_position.translate (inOffset);

                var drawing_area_geometry = drawing_area.geometry.copy ();
                drawing_area_geometry.translate (drawing_area.geometry.extents.origin.invert ());
                drawing_area_geometry.translate (Graphic.Point (drawing_area.selected_border + drawing_area.anchor_size,
                                                                drawing_area.selected_border + drawing_area.anchor_size));
                drawing_area_geometry.resize (Graphic.Size (drawing_area_geometry.extents.size.width - (drawing_area.selected_border * 2.0) - drawing_area.anchor_size,
                                                            drawing_area_geometry.extents.size.height - (drawing_area.selected_border * 2.0) - drawing_area.anchor_size));


                new_position.x = double.max (new_position.x, drawing_area_geometry.extents.origin.x);
                new_position.x = double.min (new_position.x, drawing_area_geometry.extents.size.width);
                new_position.y = double.max (new_position.y, drawing_area_geometry.extents.origin.y);
                new_position.y = double.min (new_position.y, drawing_area_geometry.extents.size.height);

                start = new_position;
            }
        }
    }
}

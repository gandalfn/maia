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
    private unowned Item? m_LinkedItem = null;

    // accessors
    internal override string tag {
        get {
            return "Arrow";
        }
    }

    public Graphic.Point start { get; set; default = Graphic.Point (0, 0); }
    public Graphic.Point end {
        get {
            if (m_LinkedItem != null && parent is DrawingArea)
            {
                // Search linked item
                var item_pos = m_LinkedItem.position;
                var item_size = m_LinkedItem.size;

                return Graphic.Point (item_pos.x + (item_size.width / 2), item_pos.y + (item_size.height / 2));
            }

            return Graphic.Point (0, 0);
        }
    }
    public string linked_item {
        owned get {
            return m_LinkedItem != null ? m_LinkedItem.name : null;
        }
        set {
            if (m_LinkedItem != null)
            {
                m_LinkedItem.notify["visible"].disconnect (on_linked_item_visible_changed);
                m_LinkedItem.notify["size"].disconnect (update_size);
                m_LinkedItem.notify["position"].disconnect (update_size);
                m_LinkedItem.notify["layer"].disconnect (on_linked_item_layer_changed);
            }

            if (value != null)
            {
                m_LinkedItem = parent.find (GLib.Quark.from_string (value), false) as Item;
            }
            else
            {
                m_LinkedItem = null;
            }

            if (m_LinkedItem != null)
            {
                m_LinkedItem.notify["visible"].connect (on_linked_item_visible_changed);
                m_LinkedItem.notify["size"].connect (update_size);
                m_LinkedItem.notify["position"].connect (update_size);
                m_LinkedItem.notify["layer"].connect (on_linked_item_layer_changed);

                visible = m_LinkedItem.visible;
                layer = m_LinkedItem.layer + 1;
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
        notify["start"].connect (update_size);
    }

    public Arrow (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_linked_item_visible_changed ()
    {
        visible = m_LinkedItem.visible;
    }

    private void
    on_linked_item_layer_changed ()
    {
        layer = m_LinkedItem.layer + 1;
    }

    private void
    update_size ()
    {
        if (m_LinkedItem != null && parent is DrawingArea)
        {
            var item_pos = m_LinkedItem.position;
            var item_size = m_LinkedItem.size;

            var start_area = Graphic.Point (double.min (item_pos.x + (item_size.width / 2), start.x),
                                            double.min (item_pos.y + (item_size.height / 2), start.y));

            var end_area = Graphic.Point (double.max (item_pos.x + (item_size.width / 2), start.x),
                                          double.max (item_pos.y + (item_size.height / 2), start.y));

            start_area.translate (Graphic.Point (-arrow_width, -arrow_width));
            end_area.translate (Graphic.Point (arrow_width, arrow_width));
            var area_size = Graphic.Size (end_area.x - start_area.x, end_area.y - start_area.y);

            position = start_area;
            size = area_size;
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
        update_size ();

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        if (m_LinkedItem != null)
        {
            inContext.save ();
            {
                // Clip area whithout linked item area
                var clip_area = geometry.copy ();
                clip_area.subtract (m_LinkedItem.geometry);
                clip_area.translate (geometry.extents.origin.invert ());

                inContext.clip_region (clip_area);

                // Draw line
                var line = new Graphic.Path ();

                var start_point = start;

                var end_point = Graphic.Point (m_LinkedItem.geometry.extents.origin.x + m_LinkedItem.geometry.extents.size.width / 2,
                                               m_LinkedItem.geometry.extents.origin.y + m_LinkedItem.geometry.extents.size.height / 2);

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

                if (m_LinkedItem == null || m_LinkedItem.geometry == null || !(new_position in m_LinkedItem.geometry))
                {
                    start = new_position;
                }
            }
        }
    }
}

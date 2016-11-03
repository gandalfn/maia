/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * item-movable.vala
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

public interface Maia.ItemMovable : Item
{
    // methods
    public virtual void
    move (Graphic.Point inOffset)
    {
        if (parent != null && parent is DrawingArea)
        {
            unowned DrawingArea? drawing_area = (DrawingArea)parent;

            if (drawing_area.geometry != null)
            {
                // translate the current position
                var new_position = position;
                new_position.translate (inOffset);

                var new_area = Graphic.Rectangle (new_position.x, new_position.y, size.width, size.height);

                // check if item is not outside parent
                var drawing_area_geometry = drawing_area.area;
                drawing_area_geometry.translate (Graphic.Point (drawing_area.selected_border + drawing_area.anchor_size,
                                                                drawing_area.selected_border + drawing_area.anchor_size));
                drawing_area_geometry.resize (Graphic.Size (drawing_area_geometry.extents.size.width - (drawing_area.selected_border * 2.0) - drawing_area.anchor_size,
                                                            drawing_area_geometry.extents.size.height - (drawing_area.selected_border * 2.0) - drawing_area.anchor_size));

                if (drawing_area_geometry.contains_rectangle (new_area) != Graphic.Region.Overlap.IN)
                {
                    new_area.clamp (drawing_area_geometry.extents);
                }

                // set new position
                position = new_area.origin;
            }
        }
    }
}

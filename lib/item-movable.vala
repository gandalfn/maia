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
    internal static string
    get_anchor_path (double inAnchorBorder)
    {
        // Create anchor
        string pathVert = "m %2$g,0 l -3,3 m 3,-3 l 3,3 m -3,-3 l 0,%1$g l -3,-3 m 3,3 l 3,-3".printf (inAnchorBorder, inAnchorBorder / 2);
        string pathHoriz = "m 0,%2$g l 3,-3 m -3,3 l 3,3 m -3,-3 l %1$g,0 l -3,-3 m 3,3 l -3,3".printf (inAnchorBorder, inAnchorBorder / 2);

        return "M 0,0 %1$g M 0,0 %2$g". printf (pathVert, pathHoriz);
    }

    public void
    move (Graphic.Point inOffset)
    {
        if (parent != null && parent is DrawingArea)
        {
            unowned DrawingArea drawing_area = (DrawingArea)parent;

            if (drawing_area.geometry != null)
            {
                // translate the current position
                var new_position = position;
                new_position.translate (inOffset);

                var area = Graphic.Rectangle (new_position.x, new_position.y, size.width, size.height);

                // check if item is not outside parent
                var drawing_area_geometry = drawing_area.geometry.copy ();
                drawing_area_geometry.translate (drawing_area.geometry.extents.origin.invert ());
                if (drawing_area_geometry.contains_rectangle (area) != Graphic.Region.Overlap.IN)
                {
                    area.clamp (drawing_area_geometry.extents);
                }

                position = area.origin;
            }
        }
    }
}

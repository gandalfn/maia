/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * point.vala
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

[CCode (has_type_id = false)]
public struct Maia.Graphic.Point
{
    /**
     * x position
     */
    public double x;

    /**
     * y position
     */
    public double y;

    /**
     * Transform the point by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Transform inTransform)
    {
        double new_x, new_y;
        unowned Matrix matrix = inTransform.matrix;

        new_x = (matrix.xx * x + matrix.xy * y) + matrix.x0;
        new_y = (matrix.yx * x + matrix.yy * y) + matrix.y0;

        x = new_x;
        y = new_y;
    }

    /**
     * Returns the string representation of point
     *
     * @return string representation of point
     */
    public string
    to_string ()
    {
        return "%f,%f".printf (x, y);
    }
}

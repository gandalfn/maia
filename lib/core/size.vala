/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * size.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public struct Maia.Size
{
    public double width;
    public double height;

    /**
     * Check if size is empty.
     *
     * @return true if size is empty
     */
    public bool
    is_empty ()
    {
        return width <= 0 || height <= 0;
    }

    /**
     * Transform the size by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Transform inTransform)
    {
        double new_width, new_height;
        unowned Matrix matrix = inTransform.matrix;

        new_width = (matrix.xx * width + matrix.xy * height);
        new_height = (matrix.yx * width + matrix.yy * height);

        width = new_width;
        height = new_height;
    }

    /**
     * Returns the string representation of size
     *
     * @return string representation of size
     */
    public string
    to_string ()
    {
        return width.to_string () + "," + height.to_string ();
    }
}
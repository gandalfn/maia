/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * size.vala
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
public struct Maia.Graphic.Size
{
    // properties
    public double width;
    public double height;

    // methods
    public Size (double inWidth, double inHeight)
    {
        width = inWidth;
        height = inHeight;
    }

    /**
     * Affect size from inOther
     *
     * @param inOther size
     */
    public void
    @set (Size inOther)
    {
        width = inOther.width;
        height = inOther.height;
    }

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
     * Compare size with inOther size
     *
     * @param inOther size to compare to
     *
     * @return true if size are equal false otherwise
     */
    public bool
    compare (Size inOther)
    {
        return width == inOther.width && height == inOther.height;
    }

    /**
     * Returns the string representation of size
     *
     * @return string representation of size
     */
    public string
    to_string ()
    {
        return "%f,%f".printf (width, height);
    }
}

/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * rectangle.vala
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

[Compact]
public class Maia.Rectangle
{
    /**
     * Origin of rectangle
     */
    public Point origin;

    /**
     * Size of rectangle
     */
    public Size size;

    /**
     * Create a new rectangle from raw values
     *
     * @param inX x coordinate of rectangle
     * @param inY y coordinate of rectangle
     * @param inWidth width of rectangle
     * @param inHeight height of rectangle
     */
    public Rectangle (double inX, double inY, double inWidth, double inHeight)
    {
        origin = { inX, inY };
        size = { inWidth, inHeight };
    }

    /**
     * Create a new rectangle from a pixman box
     *
     * @param inBox a pixman box
     */
    internal Rectangle.pixman_box (Pixman.Box32 inBox)
    {
        double x = ((Pixman.Fixed)inBox.x1).to_double ();
        double y = ((Pixman.Fixed)inBox.y1).to_double ();
        double width = ((Pixman.Fixed)inBox.x2 - (Pixman.Fixed)inBox.x1).to_double ();
        double height = ((Pixman.Fixed)inBox.y2 - (Pixman.Fixed)inBox.y1).to_double ();

        origin = { x, y };
        size = { width, height };
    }

    /**
     * Create a new rectangle from string attribute
     *
     * @param inValue rectangle string attribute
     */
    public Rectangle.from_string (string inValue)
    {
        string[] val = inValue.split (",");
        if (val.length >= 4)
        {
            origin = { double.parse (val[0]), double.parse (val[1]) };
            size = { double.parse (val[2]), double.parse (val[3]) };
        }
    }

    /**
     * Check if rectangle is empty
     *
     * @return true is rectangle is empty
     */
    public bool
    is_empty ()
    {
        return size.is_empty ();
    }

    /**
     * Transform the rectangle by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Maia.Transform inTransform)
    {
        origin.transform (inTransform);
        size.transform (inTransform);
    }

    /**
     * Return string representation of rectangle
     *
     * @return string representation of rectangle
     */
    public string
    to_string ()
    {
        return origin.to_string () + "," + size.to_string ();
    }

    /**
     * Returrn the pixman box representation of rectangle
     *
     * @return Pixman Box
     */
    internal Pixman.Box32 []
    to_pixman_box ()
    {
        Pixman.Box32[] boxes = new Pixman.Box32 [1];

        boxes[0].x1 = Pixman.Fixed.double(origin.x);
        boxes[0].y1 = Pixman.Fixed.double(origin.y);
        boxes[0].x2 = Pixman.Fixed.double(origin.x + size.width);
        boxes[0].y2 = Pixman.Fixed.double(origin.y + size.height);

        return boxes;
    }
}
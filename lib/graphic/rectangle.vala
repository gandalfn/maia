/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * rectangle.vala
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

public struct Maia.Graphic.Rectangle
{
    // properties
    /**
     * Origin of rectangle
     */
    public Point origin;

    /**
     * Size of rectangle
     */
    public Size size;

    // static methods
    internal static void
    rectangle_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Rectangle)))
    {
        Rectangle val = (Rectangle)inSrc;

        outDest = val.to_string ();
    }

    internal static void
    string_to_rectangle (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
        requires ((string)inSrc != null)
    {
        string val = (string)inSrc;

        outDest = Rectangle.from_string (val);
    }

    // methods
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
     * Calculates the intersection of rectangle with inRect.
     *
     * @param inRect rectangle to intersect to
     */
    public void
    intersect (Rectangle inRect)
    {
        double x1 = origin.x;
        double y1 = origin.y;
        double x2 = x1 + size.width;
        double y2 = y1 + size.height;

        double ox1 = inRect.origin.x;
        double oy1 = inRect.origin.y;
        double ox2 = ox1 + inRect.size.width;
        double oy2 = oy1 + inRect.size.height;

        origin.x = double.max (x1, ox1);
        origin.y = double.max (y1, oy1);
        size.width = double.max (0, double.min (x2, ox2) - origin.x);
        size.height = double.max (0, double.min (y2, oy2) - origin.y);
    }

    /**
     * Calculates the union of rectangle with inRect.
     *
     * @param inRect rectangle to intersect to
     */
    public void
    union_ (Rectangle inRect)
    {
        double x1 = origin.x;
        double y1 = origin.y;
        double x2 = x1 + size.width;
        double y2 = y1 + size.height;

        double ox1 = inRect.origin.x;
        double oy1 = inRect.origin.y;
        double ox2 = ox1 + inRect.size.width;
        double oy2 = oy1 + inRect.size.height;

        origin.x = double.min (x1, ox1);
        origin.y = double.min (y1, oy1);
        size.width = double.max (x2, ox2) - origin.x;
        size.height = double.max (y2, oy2) - origin.y;
    }

    /**
     * Transform the rectangle by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Transform inTransform)
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
}

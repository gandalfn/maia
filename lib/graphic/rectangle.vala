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
     * Copy rectangle
     *
     * @return a new rectangle was the copy of this
     */
    public Rectangle
    copy ()
    {
        return Rectangle (origin.x, origin.y, size.width, size.height);
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
     * Translates rectangle by inOffset
     *
     * @param inOffset Amount to translate
     */
    public void
    translate (Point inOffset)
    {
        origin.translate (inOffset);
    }

    /**
     * Transform the rectangle by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Transform inTransform)
    {
        double x1 = origin.x;
        double y1 = origin.y;
        double x2 = x1 + size.width;
        double y2 = y1 + size.height;
        Point quad[4];

        if (inTransform.matrix.xy == 0 && inTransform.matrix.yx == 0)
        {
            if (inTransform.matrix.xx != 1)
            {
                quad[0].x = x1 * inTransform.matrix.xx;
                quad[1].x = x2 * inTransform.matrix.xx;
                if (quad[0].x < quad[1].x)
                {
                    x1 = quad[0].x;
                    x2 = quad[1].x;
                }
                else
                {
                    x1 = quad[1].x;
                    x2 = quad[0].x;
                }
            }
            if (inTransform.matrix.x0 != 0.0)
            {
                x1 += inTransform.matrix.x0;
                x2 += inTransform.matrix.x0;
            }

            if (inTransform.matrix.yy != 1)
            {
                quad[0].y = y1 * inTransform.matrix.yy;
                quad[1].y = y2 * inTransform.matrix.yy;
                if (quad[0].y < quad[1].y)
                {
                    y1 = quad[0].y;
                    y2 = quad[1].y;
                }
                else
                {
                    y1 = quad[1].y;
                    y2 = quad[0].y;
                }
            }
            if (inTransform.matrix.y0 != 0)
            {
                y1 += inTransform.matrix.y0;
                y2 += inTransform.matrix.y0;
            }
        }
        else
        {
            quad[0].x = x1;
            quad[0].y = y1;
            quad[0].transform (inTransform);

            quad[1].x = x2;
            quad[1].y = y1;
            quad[1].transform (inTransform);

            quad[2].x = x1;
            quad[2].y = y2;
            quad[2].transform (inTransform);

            quad[3].x = x2;
            quad[3].y = y2;
            quad[3].transform (inTransform);

            double min_x = quad[0].x, max_x = quad[0].x;
            double min_y = quad[0].y, max_y = quad[0].x;

            for (int i = 1; i < 4; i++)
            {
                if (quad[i].x < min_x)
                    min_x = quad[i].x;
                if (quad[i].x > max_x)
                    max_x = quad[i].x;

                if (quad[i].y < min_y)
                    min_y = quad[i].y;
                if (quad[i].y > max_y)
                    max_y = quad[i].y;
            }

            x1 = min_x;
            y1 = min_y;
            x2 = max_x;
            y2 = max_y;
        }

        origin.x = x1;
        origin.y = y1;
        size.width = x2 - x1;
        size.height = y2 - y1;
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
     * Checks whether inPoint is contained in rectangle.
     *
     * @param inPoint the point to check
     *
     * @return ``true`` if inPoint is contained in rectangle, ``false`` if it is not.
     */
    public bool
    contains (Point inPoint)
    {
        return inPoint.x >= origin.x && inPoint.x <= origin.x + size.width &&
               inPoint.y >= origin.y && inPoint.y <= origin.y + size.height;
    }
}

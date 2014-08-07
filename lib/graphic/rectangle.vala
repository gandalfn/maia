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
        return size.is_empty () || origin.x + size.width <= 0 || origin.y + size.height <= 0;
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
     * Resize rectangle by inSize
     *
     * @param inSize Amount to resize
     */
    public void
    resize (Graphic.Size inSize)
    {
        size.resize (inSize.width, inSize.height);
    }

    /**
     * Transform the rectangle by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Transform inTransform)
    {
        double min_x = double.MAX, min_y = double.MAX, max_x = double.MIN, max_y = double.MIN;

        var lines = get_border_lines ();
        for (int cpt = 0; cpt < 4; ++cpt)
        {
            lines[cpt].transform (inTransform);

            min_x = double.min (lines[cpt].begin.x, min_x);
            min_x = double.min (lines[cpt].end.x, min_x);
            min_y = double.min (lines[cpt].begin.y, min_y);
            min_y = double.min (lines[cpt].end.y, min_y);
            max_x = double.max (lines[cpt].begin.x, max_x);
            max_x = double.max (lines[cpt].end.x, max_x);
            max_y = double.max (lines[cpt].begin.y, max_y);
            max_y = double.max (lines[cpt].end.y, max_y);
        }

        origin.x = min_x;
        origin.y = min_y;
        size.width = max_x - min_x;
        size.height = max_y - min_y;
    }

    /**
     * Reverse transform the rectangle by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    reverse_transform (Transform inTransform)
    {
        if (inTransform.have_rotate)
        {
            var center = Point (origin.x + (size.width / 2.0), origin.y + (size.height / 2.0));
            var t = inTransform.copy ();
            t.apply_center_rotate (center.x, center.y);

            Point quad[4];
            quad[0] = origin;
            quad[1] = Point (origin.x + size.width, origin.y);
            quad[2] = Point (origin.x + size.width, origin.y + size.height);
            quad[3] = Point (origin.x, origin.y + size.height);

            for (int cpt = 0; cpt < 4; ++cpt)
            {
                quad[cpt].transform (new Transform.from_matrix (t.matrix));
            }

            var top = Line (origin.x, origin.y, origin.x + size.width, origin.y);
            var bottom = Line (origin.x, origin.y + size.height, origin.x + size.width, origin.y + size.height);
            var left = Line (origin.x, origin.y, origin.x, origin.y + size.height);
            var right = Line (origin.x + size.width, origin.y, origin.x + size.width, origin.y + size.height);

            Line line[4];
            for (int cpt = 0; cpt < 4; ++cpt)
            {
                line[cpt] = Line (center.x, center.y, quad[cpt].x, quad[cpt].y);
            }

            Point final[4];
            if (line[0].intersect (top, out final[0]))
            {
                line[1].intersect (right,  out final[1]);
                line[2].intersect (bottom, out final[2]);
                line[3].intersect (left,   out final[3]);
            }
            else if (line[0].intersect (left, out final[0]))
            {
                line[1].intersect (top,    out final[1]);
                line[2].intersect (right,  out final[2]);
                line[3].intersect (bottom, out final[3]);
            }
            else if (line[0].intersect (bottom, out final[0]))
            {
                line[1].intersect (left,  out final[1]);
                line[2].intersect (top,   out final[2]);
                line[3].intersect (right, out final[3]);
            }
            else if (line[0].intersect (right, out final[0]))
            {
                line[1].intersect (bottom, out final[1]);
                line[2].intersect (left,   out final[2]);
                line[3].intersect (top,    out final[3]);
            }

            double min_x = final[0].x, max_x = final[0].x;
            double min_y = final[0].y, max_y = final[0].x;

            for (int cpt = 1; cpt < 4; ++cpt)
            {
                if (final[cpt].x < min_x)
                    min_x = final[cpt].x;
                if (final[cpt].x > max_x)
                    max_x = final[cpt].x;

                if (final[cpt].y < min_y)
                    min_y = final[cpt].y;
                if (final[cpt].y > max_y)
                    max_y = final[cpt].y;
            }

            origin.x = min_x;
            origin.y = min_y;
            size.width = max_x - min_x;
            size.height = max_y - min_y;

            transform (new Transform.from_matrix (t.matrix_invert));
        }
        else
        {
            transform (new Transform.from_matrix (inTransform.matrix_invert));
        }
    }

    /**
     * Forces a rectangle must be into the inRectangle
     *
     * @param inRectangle where the rectangle must be in
     */
    public void
    clamp (Rectangle inRectangle)
    {
        double ax1 = origin.x;
        double ay1 = origin.y;
        double ax2 = origin.x + size.width;
        double ay2 = origin.y + size.height;

        double bx1 = inRectangle.origin.x;
        double by1 = inRectangle.origin.y;
        double bx2 = inRectangle.origin.x + inRectangle.size.width;
        double by2 = inRectangle.origin.y + inRectangle.size.height;

        if (ax2 > bx2)
            ax1 -= ax2 - bx2;

        if (ay2 > by2)
            ay1 -= ay2 - by2;

        if (ax1 < bx1)
            ax1 += bx1 - ax1;

        if (ay1 < by1)
            ay1 += by1 - ay1;

        if (ax2 > bx2)
            ax2 = bx2;

        if (ay2 > by2)
            ay2 = by2;

        origin.x = ax1;
        origin.y = ay1;
        size.width = ax2 - ax1;
        size.height = ay2 - ay1;
    }

    /**
     * Get border lines which compose rectangle
     *
     * @return array of lines which compose rectangle
     */
    public Line[]
    get_border_lines ()
    {
        Line[] ret = {};

        ret += Line (origin.x, origin.y, origin.x + size.width, origin.y);
        ret += Line (origin.x + size.width, origin.y, origin.x + size.width, origin.y + size.height);
        ret += Line (origin.x + size.width, origin.y + size.height, origin.x, origin.y + size.height);
        ret += Line (origin.x, origin.y + size.height, origin.x, origin.y);

        return ret;
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

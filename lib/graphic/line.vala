/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * line.vala
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

public struct Maia.Graphic.Line
{
    // constant
    const double EPSILON = 1.0e-5;

    // properties
    /**
     * Begin of line
     */
    public Point begin;

    /**
     * End of line
     */
    public Point end;

    // methods
    /**
     * Create a new line from raw values
     *
     * @param inBeginX x coordinate of line begin
     * @param inBeginY y coordinate of line begin
     * @param inEndX x coordinate of line end
     * @param inEndY y coordinate of line end
     */
    public Line (double inBeginX, double inBeginY, double inEndX, double inEndY)
    {
        begin = { inBeginX, inBeginY };
        end = { inEndX, inEndY };
    }

    /**
     * Copy line
     *
     * @return a new line was the copy of this
     */
    public Line
    copy ()
    {
        return Line (begin.x, begin.y, end.x, end.y);
    }

    /**
     * Center of line
     *
     * @return the center point of line
     */
    public Graphic.Point
    center ()
    {
        return Graphic.Point ((begin.x + end.x) / 2.0, (begin.y + end.y) / 2.0);
    }

    /**
     * Length of line
     */
    public double
    length ()
    {
        Graphic.Point diff = Graphic.Point (begin.x - end.x, begin.y - end.y);
        return GLib.Math.sqrt ((diff.x * diff.x) + (diff.y * diff.y));
    }

    /**
     * Calculates the point of intersection of line with inLine.
     *
     * @param inLine line to intersect to
     * @param outIntersect point of intersect of two lines
     *
     * @return ``true`` if lines intersect ``false`` otherwize
     */
    public bool
    intersect (Line inLine, out Point? outIntersect = null)
    {
        double denom = ((inLine.end.y - inLine.begin.y) * (end.x - begin.x)) -
                        ((inLine.end.x - inLine.begin.x) * (end.y - begin.y));

        double nume_a = ((inLine.end.x - inLine.begin.x) * (begin.y - inLine.begin.y)) -
                         ((inLine.end.y - inLine.begin.y) * (begin.x - inLine.begin.x));

        double nume_b = ((end.x - begin.x) * (begin.y - inLine.begin.y)) -
                         ((end.y - begin.y) * (begin.x - inLine.begin.x));


        /* Are the line coincident? */
        if (GLib.Math.fabs (nume_a) < EPSILON && GLib.Math.fabs (nume_b) < EPSILON && GLib.Math.fabs (denom) < EPSILON)
        {
            outIntersect = Graphic.Point ((begin.x + end.x) / 2.0,  (begin.y + end.y) / 2.0);
            return true;
        }

        /* Are the line parallel */
        if (GLib.Math.fabs (denom) < EPSILON)
        {
            outIntersect = Graphic.Point (0, 0);
            return false;
        }

        /* Is the intersection along the the segments */
        double mua = nume_a / denom;
        double mub = nume_b / denom;

        if (mua < 0 || mua > 1 || mub < 0 || mub > 1)
        {
            outIntersect = Graphic.Point (0, 0);
            return false;
        }
        outIntersect = Graphic.Point (begin.x + mua * (end.x - begin.x), begin.y + mua * (end.y - begin.y));

        return true;
    }

    /**
     * Transform the line by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Transform inTransform)
    {
        begin.transform (inTransform);
        end.transform (inTransform);
    }


    /**
     * Return string representation of line
     *
     * @return string representation of line
     */
    public string
    to_string ()
    {
        return begin.to_string () + "," + end.to_string ();
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * range.vala
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

public struct Maia.Graphic.Range
{
    // properties
    /**
     * minimum of range
     */
    public Point min;

    /**
     * maximum of range
     */
    public Point max;

    // methods
    /**
     * Create a new range from raw values
     *
     * @param inXMin x minimum
     * @param inYMin y minimum
     * @param inXMax x maximum
     * @param inYMax x maximum
     */
    public Range (double inXMin, double inYMin, double inXMax, double inYMax)
    {
        min = { inXMin, inYMin };
        max = { inXMax, inYMax };
    }

    /**
     * Get size of range
     */
    public Size
    size ()
    {
        return Graphic.Size (max.x - min.x, max.y - min.y);
    }

    /**
     * Check if range is empty
     *
     * @return true is range is empty
     */
    public bool
    is_empty ()
    {
        return size ().is_empty ();
    }

    /**
     * Return string representation of range
     *
     * @return string representation of range
     */
    public string
    to_string ()
    {
        return min.to_string () + "," + max.to_string ();
    }

    /**
     * Checks whether inPoint is contained in range.
     *
     * @param inPoint the point to check
     *
     * @return ``true`` if inPoint is contained in range, ``false`` if it is not.
     */
    public bool
    contains (Point inPoint)
    {
        return inPoint.x >= min.x && inPoint.x <= max.x &&
               inPoint.y >= min.y && inPoint.y <= max.y;
    }

    /**
     * Clamp range from inPoint
     *
     * @param inPoint to clamp range
     */
    public void
    clamp (Point inPoint)
    {
        min.x = double.min (min.x, inPoint.x);
        max.x = double.max (max.x, inPoint.x);

        min.y = double.min (min.y, inPoint.y);
        max.y = double.max (max.y, inPoint.y);
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * region.vala
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

public abstract class Maia.Graphic.Region : GLib.Object
{
    // types
    public enum Overlap
    {
        IN,
        OUT,
        PART
    }

    [Compact]
    public class Iterator
    {
        // properties
        internal weak Region m_Region;
        internal int         m_Index;

        // methods
        internal Iterator (Region inRegion)
        {
            m_Region = inRegion;
            m_Index = -1;
        }

        public bool
        next ()
        {
            m_Index++;

            return m_Index < m_Region.length;
        }

        public Rectangle
        get ()
        {
            return m_Region[m_Index];
        }
    }

    [CCode (has_target = false)]
    internal delegate Region CreateFunc (Rectangle? inExtents);

    // static properties
    private static CreateFunc s_CreateRegion = null;

    // accessors
    public abstract Rectangle extents { get; }
    public abstract int length { get; }

    // static methods
    internal static void
    set_create_func (CreateFunc inFunc)
    {
        s_CreateRegion = inFunc;
    }

    /**
     * Allocates a new region object containing inExtents.
     *
     * @param inExtents a Rectangle or ``null`` to create empty region
     */
    public static Region?
    create (Rectangle? inExtents = null)
        requires (s_CreateRegion != null)
    {
        return s_CreateRegion (inExtents);
    }

    // methods
    /**
     * Checks whether region is empty.
     *
     * @return ``true`` if region is empty, ``false`` if it isn't.
     */
    public abstract bool is_empty ();

    /**
     * Translates region by inOffset
     *
     * @param inOffset Amount to translate
     */
    public abstract void translate (Point inOffset);

    /**
     * Transform region
     *
     * @param inTransform transformation to apply to region
     */
    //public abstract void transform (Transform inTransform);

    /**
     * Checks whether inPoint is contained in region.
     *
     * @param inPoint the point to check
     *
     * @return ``true`` if inPoint is contained in region, ``false`` if it is not.
     */
    public abstract bool contains (Point inPoint);

    /**
     * Returns the rectangle at the specified index in this region.
     *
     * @param inIndex zero-based index of the rectangle to be returned
     *
     * @return the Rectangle at the specified index in the region
     */
    public abstract new Rectangle @get (int inIndex);

    /**
     * Returns a Iterator that can be used for simple iteration of region rectangles.
     *
     * @return a Iterator that can be used for simple iteration of region rectangles
     */
    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    /**
     * Allocates a new region object copying the area from this.
     *
     * @return A newly allocated Region
     */
    public abstract Region copy ();

    /**
     * Compares whether this is equivalent to inOther.
     *
     * @param inOther another Region
     *
     * @return ``true`` if both regions contained the same coverage, ``false`` if it is not
     */
    public abstract bool equal (Region inOther);

    /**
     * Computes the union of this with inOther and places the result in this
     *
     * @param inOther another Region
     */
    public abstract void union_ (Region inOther);

    /**
     * Computes the intersection of this with inOther and places the result in this
     *
     * @param inOther another Region
     */
    public abstract void intersect (Region inOther);

    /**
     * Subtracts inOther from this and places the result in this
     *
     * @param inOther another Region
     */
    public abstract void subtract (Region inOther);

    /**
     * Computes the exclusive difference of this with inOther and places the result
     * in this. That is, this will be set to contain all areas that are either in
     * this or in inOther, but not in both.
     *
     * @param inOther another Region
     */
    public abstract void xor (Region inOther);

    /**
     * Checks whether inRect is inside, outside or partially contained in region
     *
     * @param inRect a Rectangle
     *
     * @return Overlap.IN if inRect is entirely inside region, Overlap.OUT if inRect
     * is entirely outside region, or Overlap.PART if inRect is partially inside
     * and partially outside region.
     */
    public abstract Overlap contains_rectangle (Rectangle inRect);
}

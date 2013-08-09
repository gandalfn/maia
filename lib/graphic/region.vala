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

public class Maia.Graphic.Region : Core.Any
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


    // accessors
    public virtual Rectangle extents { get; construct set; }

    public virtual int length {
        get {
            return 0;
        }
    }

    // static methods
    static construct
    {
        Log.debug ("Region.static_construct", Log.Category.GRAPHIC_GEOMETRY, "Register transform functions");
        Manifest.AttributeScanner.register_transform_func (typeof (Region), attributes_to_region);
    }

    internal static void
    attributes_to_region (Manifest.AttributeScanner inScanner, out GLib.Value outDest) throws Manifest.Error
    {
        Rectangle rect = Rectangle (0, 0, 0, 0);
        int cpt = 0;
        foreach (unowned Core.Object child in ((Core.Object)inScanner))
        {
            switch (cpt)
            {
                case 0:
                    rect.origin.x = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 1:
                    rect.origin.y = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 2:
                    rect.size.width = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 3:
                    rect.size.height = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;
            }
            cpt++;
            if (cpt > 3) break;
        }

        Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_GEOMETRY, "transform to %s", rect.to_string ());

        outDest = new Region (rect);
    }

    // methods
    /**
     * Allocates a new region object containing inExtents.
     *
     * @param inExtents a Rectangle or ``null`` to create empty region
     */
    public Region (Rectangle? inExtents = null)
    {
        GLib.Object (extents: inExtents == null ? Rectangle (0, 0, 0, 0) : inExtents);
    }

    /**
     * Checks whether region is empty.
     *
     * @return ``true`` if region is empty, ``false`` if it isn't.
     */
    public virtual bool
    is_empty ()
    {
        return true;
    }

    /**
     * Translates region by inOffset
     *
     * @param inOffset Amount to translate
     */
    public virtual void
    translate (Point inOffset)
    {
    }

    /**
     * Transform region
     *
     * @param inTransform transformation to apply to region
     */
    public virtual void
    transform (Transform inTransform)
    {
    }

    /**
     * Checks whether inPoint is contained in region.
     *
     * @param inPoint the point to check
     *
     * @return ``true`` if inPoint is contained in region, ``false`` if it is not.
     */
    public virtual bool
    contains (Point inPoint)
    {
        return false;
    }

    /**
     * Returns the rectangle at the specified index in this region.
     *
     * @param inIndex zero-based index of the rectangle to be returned
     *
     * @return the Rectangle at the specified index in the region
     */
    public virtual new Rectangle
    @get (int inIndex)
    {
        return Rectangle (0, 0, 0, 0);
    }

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
    public virtual Region
    copy ()
    {
        return new Region ();
    }

    /**
     * Compares whether this is equivalent to inOther.
     *
     * @param inOther another Region
     *
     * @return ``true`` if both regions contained the same coverage, ``false`` if it is not
     */
    public virtual bool
    equal (Region inOther)
    {
        return false;
    }

    /**
     * Computes the union of this with inOther and places the result in this
     *
     * @param inOther another Region
     */
    public virtual void
    union_ (Region inOther)
    {
    }

    /**
     * Computes the union of this with inRectangle and places the result in this
     *
     * @param inRectangle rectangle
     */
    public virtual void
    union_with_rect (Rectangle inRectangle)
    {
    }

    /**
     * Computes the intersection of this with inOther and places the result in this
     *
     * @param inOther another Region
     */
    public virtual void
    intersect (Region inOther)
    {
    }

    /**
     * Subtracts inOther from this and places the result in this
     *
     * @param inOther another Region
     */
    public virtual void
    subtract (Region inOther)
    {
    }

    /**
     * Computes the exclusive difference of this with inOther and places the result
     * in this. That is, this will be set to contain all areas that are either in
     * this or in inOther, but not in both.
     *
     * @param inOther another Region
     */
    public virtual void
    xor (Region inOther)
    {
    }

    /**
     * Checks whether inRect is inside, outside or partially contained in region
     *
     * @param inRect a Rectangle
     *
     * @return Overlap.IN if inRect is entirely inside region, Overlap.OUT if inRect
     * is entirely outside region, or Overlap.PART if inRect is partially inside
     * and partially outside region.
     */
    public virtual Overlap
    contains_rectangle (Rectangle inRect)
    {
        return Overlap.OUT;
    }

    /**
     * Resize region
     *
     * @param inSize new region size
     */
    public virtual void
    resize (Size inSize)
    {
    }
}

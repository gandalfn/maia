/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-region.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.Region : Object
{
    private Pixman.Region32 m_Region;

    /**
     * Indicate if region is empty
     */
    public bool is_empty {
        get {
            bool ret = false;

            if (!m_Region.not_empty ())
                ret = true;
            else
                ret = clipbox.is_empty ();

            return ret;
        }
    }

    /**
     * The smallest rectangle which includes the entire region
     */
    public Rectangle clipbox {
        owned get {
            return new Rectangle.pixman_box (m_Region.extents);
        }
    }

    /**
     * Creates a new empty Region.
     */
    public Region ()
    {
        m_Region.init ();
    }

    /**
     * Creates a new region containing the area rectangle.
     *
     * @param inRectangle initial rectangle
     */
    public Region.rectangle (Rectangle inRectangle)
    {
        Pixman.Box32 box = inRectangle.to_pixman_box ();

        m_Region.init_rects (box, 1);
    }

    /**
     * Creates a new region containing the area rectangle.
     *
     * @param inX area x
     * @param inY area y
     * @param inWidth area width
     * @param inHeight area height
     */
    public Region.raw_rectangle (int inX, int inY, uint inWidth, uint inHeight)
    {
        Rectangle rect = new Rectangle (inX, inY, inWidth, inHeight);

        Pixman.Box32 box = rect.to_pixman_box ();

        m_Region.init_rects (box, 1);
    }

    ~Region ()
    {
        m_Region.fini ();
    }

    private inline void 
    compress (Region s, Region t, uint dx, bool xdir, bool grow)
    {
        uint shift = 1;

        s.m_Region.copy (m_Region);

        while (dx != 0)
        {
            if ((dx & shift) != 0)
            {
                if (xdir) 
                    offset (-(int) shift,0);
                else 
                    offset (0, -(int) shift);

                if (grow) 
                    union (s);
                else 
                    intersect (s);
                dx -= shift;
                if (dx == 0) break;
            }
            t.m_Region.copy (s.m_Region);
            if (xdir) 
                s.offset (-(int) shift,0);
            else 
                s.offset (0, -(int) shift);

            if (grow) 
                s.union (t);
            else 
                s.intersect (t);
            shift <<= 1;
        }
    }

    /**
     * Copy a region
     *
     * @return region copied
     */
    public Region? 
    copy ()
    {
        Region region = new Region ();

        if (!region.m_Region.copy (m_Region))
            region = null;

        return region;
    }

    /**
     * Subtract a region
     *
     * @param inOther region to subtract
     */
    public void 
    subtract (Region inOther)
    {
        m_Region.subtract (m_Region, inOther.m_Region);
    }

    /**
     * Union with a region
     *
     * @param inOther region to union with
     */
    public inline void 
    union (Region inOther)
    {
        m_Region.union (m_Region, inOther.m_Region);
    }

    /**
     * Union with a rectangle area
     *
     * @param inRect rectangle to union with
     */
    public void 
    union_with_rect (Rectangle inRect)
    {
        Region other = new Region.rectangle (inRect);

        union (other);
    }

    /**
     * Intersect with another region
     *
     * @param inOther region to intersect to
     */
    public void 
    intersect (Region inOther)
    {
        m_Region.intersect (m_Region, inOther.m_Region);
    }

    /**
     * Add an offset to region
     *
     * @param inDx x offset to add at region
     * @param inDy y offset to add at region
     */
    public inline void 
    offset (int inDx, int inDy)
    {
        Pixman.Box32[] boxes = m_Region.rectangles ();

        m_Region.extents.x1 += ((Pixman.int)inDx).to_fixed ();
        m_Region.extents.x2 += ((Pixman.int)inDx).to_fixed ();
        m_Region.extents.y1 += ((Pixman.int)inDy).to_fixed ();
        m_Region.extents.y2 += ((Pixman.int)inDy).to_fixed ();

        if (m_Region.get_extents () != boxes)
        {
            for (int cpt = 0; cpt < boxes.length; ++cpt)
            {
                boxes[cpt].x1 += ((Pixman.int)inDx).to_fixed ();
                boxes[cpt].x2 += ((Pixman.int)inDx).to_fixed ();
                boxes[cpt].y1 += ((Pixman.int)inDy).to_fixed ();
                boxes[cpt].y2 += ((Pixman.int)inDy).to_fixed ();
            }
        }
    }

    /**
     * Resize region
     *
     * @param inWidth new region width
     * @param inHeight new region height
     */
    public void 
    resize (uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        int dx = ((Pixman.Fixed)(m_Region.extents.x2 - 
                                 m_Region.extents.x1)).to_int () - (int)inWidth;
        int dy = ((Pixman.Fixed)(m_Region.extents.y2 - 
                                 m_Region.extents.y1)).to_int () - (int)inHeight;

        if (dx != 0 || dy != 0)
        {
            Region s = new Region ();
            Region t = new Region ();

            bool grow = (dx < 0);
            if (grow) dx = -dx;
            if (dx != 0) compress (s, t, (uint) dx, true, grow);
            if (grow) dx = -dx;

            grow = (dy < 0);
            if (grow) dy = -dy;
            if (dy != 0) compress (s, t, (uint) dy, false, grow);
            if (grow) dy = -dy;

            offset (dx <= 0 ? -dx : 0, dy <= 0 ? -dy : 0);
        }
    }

    /**
     * Check if the region cover the same area than inOther
     *
     * @param inOther region to compare to
     *
     * @return true if region cover the same area
     */
    public bool
    equal (Region inOther)
    {
        Rectangle tclipbox = clipbox;
        Rectangle oclipbox = inOther.clipbox;

        return tclipbox.origin.x == oclipbox.origin.x && 
               tclipbox.origin.y == oclipbox.origin.y &&
               tclipbox.size.width == oclipbox.size.width && 
               tclipbox.size.height == oclipbox.size.height;
    }

    /**
     * Convert to string format
     *
     * @return string representation
     */
    public string
    to_string ()
    {
        bool first = false;
        string ret = "";

        foreach (Rectangle rect in this)
        {
            if (!first)
            {
                ret += rect.to_string ();
                first = true;
            }
            else
            {
                ret += " " + rect.to_string ();
            }
        }

        return ret;
    }

    /**
     * Returns a Iterator that can be used for simple iteration over a
     * region.
     *
     * @return a Iterator that can be used for simple iteration over a
     *         region
     */
    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    public class Iterator
    {
        private Pixman.Box32[] m_Boxes;
        private int m_Index = -1;

        internal Iterator (Region inRegion)
        {
            m_Boxes = inRegion.m_Region.rectangles ();
        }

        /**
         * Advances to the next rectangle in the region.
         *
         * @return true if the iterator has a next rectangle
         */
        public bool
        next ()
        {
            if (m_Index < m_Boxes.length)
                m_Index++;

            return (m_Index < m_Boxes.length);
        }

        /**
         * Returns the current rectangle in the iteration.
         *
         * @return the current rectangle in the iteration
         */
        public Rectangle?
        get ()
        {
            if (m_Index < 0 || m_Index >= m_Boxes.length)
                return null;

            return new Rectangle.pixman_box (m_Boxes[m_Index]);
        }
    }
}
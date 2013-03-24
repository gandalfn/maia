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

internal class Maia.Graphic.CairoRegion : Maia.Graphic.Region
{
    // properties
    private global::Cairo.Region m_Region;

    // accessors
    /**
     * {@inheritDoc}
     */
    public override Rectangle extents {
        get {
            return ((CairoRectangle)m_Region.get_extents ()).to_rectangle ();
        }
        construct set {
            m_Region = new global::Cairo.Region.rectangle (CairoRectangle (value));
        }
    }

    /**
     * {@inheritDoc}
     */
    public override int length {
        get {
            return m_Region.num_rectangles ();
        }
    }

    internal CairoRegion.region (global::Cairo.Region inRegion)
    {
        m_Region = inRegion.copy ();
    }

    private inline void
    compress (CairoRegion s, CairoRegion t, uint dx, bool xdir, bool grow)
    {
        uint shift = 1;

        s.m_Region = m_Region.copy ();

        while (dx != 0)
        {
            if ((dx & shift) != 0)
            {
                if (xdir)
                    translate (Point (-(int) shift, 0));
                else
                    translate (Point (0, -(int) shift));

                if (grow)
                    union_ (s);
                else
                    intersect (s);
                dx -= shift;
                if (dx == 0) break;
            }
            t.m_Region = s.m_Region.copy ();
            if (xdir)
                s.translate (Point (-(int) shift,0));
            else
                s.translate (Point (0, -(int) shift));

            if (grow)
                s.union_ (t);
            else
                s.intersect (t);
            shift <<= 1;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    is_empty ()
    {
        return m_Region.is_empty ();
    }

    /**
     * {@inheritDoc}
     */
    public override new Rectangle
    @get (int inIndex)
    {
        return ((CairoRectangle)m_Region.get_rectangle (inIndex)).to_rectangle ();
    }

    /**
     * {@inheritDoc}
     */
    public override Region
    copy ()
    {
        return new CairoRegion.region (m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    translate (Point inOffset)
    {
        m_Region.translate (Fixed.from_double (inOffset.x), Fixed.from_double (inOffset.y));
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    contains (Point inPoint)
    {
        return m_Region.contains_point (Fixed.from_double (inPoint.x), Fixed.from_double (inPoint.y));
    }

    /**
     * {@inheritDoc}
     */
    public override Region.Overlap
    contains_rectangle (Rectangle inRect)
    {
        return (Region.Overlap)m_Region.contains_rectangle (CairoRectangle (inRect));
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    equal (Region inOther)
    {
        return m_Region.equal (((CairoRegion)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    union_ (Region inOther)
    {
        m_Region.union (((CairoRegion)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    intersect (Region inOther)
    {
        m_Region.intersect (((CairoRegion)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    subtract (Region inOther)
    {
        m_Region.subtract (((CairoRegion)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    xor (Region inOther)
    {
        m_Region.xor (((CairoRegion)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    resize (Size inSize)
        requires (!inSize.is_empty ())
    {
        int dx = (int)extents.size.width - (int)inSize.width;
        int dy = (int)extents.size.height - (int)inSize.height;

        if (dx != 0 || dy != 0)
        {
            Region s = new Region ();
            Region t = new Region ();

            bool grow = (dx < 0);
            if (grow) dx = -dx;
            if (dx != 0) compress ((CairoRegion)s, (CairoRegion)t, (uint) dx, true, grow);
            if (grow) dx = -dx;

            grow = (dy < 0);
            if (grow) dy = -dy;
            if (dy != 0) compress ((CairoRegion)s, (CairoRegion)t, (uint) dy, false, grow);
            if (grow) dy = -dy;

            translate (Point (dx <= 0 ? -dx : 0, dy <= 0 ? -dy : 0));
        }
    }
}

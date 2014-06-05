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

internal class Maia.Cairo.Region : Graphic.Region
{
    // properties
    private global::Cairo.Region m_Region;

    // accessors
    /**
     * {@inheritDoc}
     */
    public override Graphic.Rectangle extents {
        get {
            return ((Rectangle)m_Region.get_extents ()).to_rectangle ();
        }
        construct set {
            m_Region = new global::Cairo.Region.rectangle (Rectangle (value));
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

    internal Region.region (global::Cairo.Region inRegion)
    {
        m_Region = inRegion.copy ();
    }

    private inline void
    remove_small_rects ()
    {
        global::Cairo.RectangleInt[] rects = {};

        Fixed one = Fixed.from_int (1);
        for (int cpt = 0; cpt < m_Region.num_rectangles (); ++cpt)
        {
            var rect = m_Region.get_rectangle (cpt);

            if (rect.width <= one || rect.height <= one)
            {
                rects += rect;
            }
        }

        foreach (var rect in rects)
        {
            m_Region.subtract_rectangle (rect);
        }
    }

    private inline void
    compress (Region s, Region t, uint dx, bool xdir, bool grow)
    {
        uint shift = 1;

        s.m_Region = m_Region.copy ();

        while (dx != 0)
        {
            if ((dx & shift) != 0)
            {
                if (xdir)
                    translate (Graphic.Point (-(int) shift, 0));
                else
                    translate (Graphic.Point (0, -(int) shift));

                if (grow)
                    union_ (s);
                else
                    intersect (s);
                dx -= shift;
                if (dx == 0) break;
            }
            t.m_Region = s.m_Region.copy ();
            if (xdir)
                s.translate (Graphic.Point (-(int) shift,0));
            else
                s.translate (Graphic.Point (0, -(int) shift));

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
        return m_Region.is_empty () || extents.is_empty ();
    }

    /**
     * {@inheritDoc}
     */
    public override new Graphic.Rectangle
    @get (int inIndex)
    {
        return ((Rectangle)m_Region.get_rectangle (inIndex)).to_rectangle ();
    }

    /**
     * {@inheritDoc}
     */
    public override Graphic.Region
    copy ()
    {
        return new Region.region (m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    translate (Graphic.Point inOffset)
    {
        m_Region.translate (Fixed.from_double (inOffset.x), Fixed.from_double (inOffset.y));
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    contains (Graphic.Point inPoint)
    {
        return m_Region.contains_point (Fixed.from_double (inPoint.x), Fixed.from_double (inPoint.y));
    }

    /**
     * {@inheritDoc}
     */
    public override Graphic.Region.Overlap
    contains_rectangle (Graphic.Rectangle inRect)
    {
        return (Graphic.Region.Overlap)m_Region.contains_rectangle (Rectangle (inRect));
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    equal (Graphic.Region inOther)
    {
        return m_Region.equal (((Region)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    union_ (Graphic.Region inOther)
    {
        m_Region.union (((Region)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    union_with_rect (Graphic.Rectangle inRectangle)
    {
        m_Region.union_rectangle (Rectangle (inRectangle));
    }

    /**
     * {@inheritDoc}
     */
    public override void
    intersect (Graphic.Region inOther)
    {
        m_Region.intersect (((Region)inOther).m_Region);
        remove_small_rects ();
    }

    /**
     * {@inheritDoc}
     */
    public override void
    subtract (Graphic.Region inOther)
    {
        m_Region.subtract (((Region)inOther).m_Region);
        remove_small_rects ();
    }

    /**
     * {@inheritDoc}
     */
    public override void
    xor_ (Graphic.Region inOther)
    {
        m_Region.xor (((Region)inOther).m_Region);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    resize (Graphic.Size inSize)
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
            if (dx != 0) compress (s, t, (uint) dx, true, grow);
            if (grow) dx = -dx;

            grow = (dy < 0);
            if (grow) dy = -dy;
            if (dy != 0) compress (s, t, (uint) dy, false, grow);
            if (grow) dy = -dy;

            translate (Graphic.Point (dx <= 0 ? -dx : 0, dy <= 0 ? -dy : 0));
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void
    transform (Graphic.Transform inTransform)
    {
        Graphic.Matrix matrix = inTransform.matrix;

        if (matrix.xx == 1 && matrix.yx == 0 && matrix.xy == 0 && matrix.yy == 1 && matrix.x0 == 0 && matrix.y0 == 0)
            return;

        global::Cairo.Region transformed = new global::Cairo.Region ();
        foreach (unowned Graphic.Rectangle rect in this)
        {
            rect.transform (inTransform);
            transformed.union_rectangle (Rectangle (rect));
        }
        m_Region = transformed.copy ();
    }
}

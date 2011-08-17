/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cairo-graphic-paint.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

internal class Maia.CairoGraphicPaint : GraphicPaint
{
    // properties
    private unowned CairoGraphicContext m_Context;

    // accessors
    public override GraphicContext context {
        get {
            return m_Context;
        }
    }

    public override GraphicFillRule fill_rule { 
        get {
            return m_Context.context.get_fill_rule () == Cairo.FillRule.EVEN_ODD ? 
                   GraphicFillRule.EVENODD : GraphicFillRule.NONZERO; 
        }
        set {
            if (value == GraphicFillRule.EVENODD)
                m_Context.context.set_fill_rule (Cairo.FillRule.EVEN_ODD);
            else
                m_Context.context.set_fill_rule (Cairo.FillRule.WINDING);
        }
    }

    public override double line_width { 
        get {
            return m_Context.context.get_line_width ();
        }
        set {
            m_Context.context.set_line_width (value);
        }
    }

    // methods
    public CairoGraphicPaint (CairoGraphicContext inContext)
    {
        m_Context = inContext;
    }

    public override void 
    fill () throws GraphicError
    {
        m_Context.context.fill_preserve ();
        m_Context.status ();
    }

    public override void 
    stroke () throws GraphicError
    {
        m_Context.context.stroke ();
        m_Context.status ();
    }

    public override void 
    paint () throws GraphicError
    {
        m_Context.context.paint ();
        m_Context.status ();
    }
}

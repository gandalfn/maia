/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * graphic-paint.vala
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

public enum Maia.GraphicFillRule
{
    NONZERO,
    EVENODD
}

public abstract class Maia.GraphicPaint : Object
{
    // accessors
    public abstract GraphicContext  context    { get; }
    public abstract GraphicFillRule fill_rule  { get; set; }
    public abstract double          line_width { get; set; }

    // methods
    public virtual void
    fill () throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    stroke () throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    paint () throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }
}
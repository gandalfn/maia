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

[CCode (has_type_id = false)]
internal struct Maia.Cairo.Rectangle : global::Cairo.RectangleInt
{
    // methods
    public Rectangle (Graphic.Rectangle inRect)
    {
        x = Fixed.from_double (inRect.origin.x);
        y = Fixed.from_double (inRect.origin.y);
        width = Fixed.from_double (inRect.size.width);
        height = Fixed.from_double (inRect.size.height);
    }

    public inline Graphic.Rectangle
    to_rectangle ()
    {
        return Graphic.Rectangle (((Fixed)x).to_double (), ((Fixed)y).to_double (),
                                  ((Fixed)width).to_double (), ((Fixed)height).to_double ());
    }
}

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
        double x1 = GLib.Math.floor (inRect.origin.x);
        double y1 = GLib.Math.floor (inRect.origin.y);
        double x2 = GLib.Math.floor (inRect.origin.x + inRect.size.width + 0.5);
        double y2 = GLib.Math.floor (inRect.origin.y + inRect.size.height + 0.5);
        x = Fixed.from_double (x1);
        y = Fixed.from_double (y1);
        width = Fixed.from_double (x2 - x1);
        height = Fixed.from_double (y2 - y1);
    }

    public inline Graphic.Rectangle
    to_rectangle ()
    {
        double x1 = GLib.Math.floor (((Fixed)x).to_double ());
        double y1 = GLib.Math.floor (((Fixed)y).to_double ());
        double x2 = GLib.Math.floor (((Fixed)x).to_double () + ((Fixed)width).to_double () + 0.5);
        double y2 = GLib.Math.floor (((Fixed)y).to_double () + ((Fixed)height).to_double () + 0.5);

        return Graphic.Rectangle (x1, y1, x2 - x1, y2 - y1);
    }
}

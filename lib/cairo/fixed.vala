/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * fixed.vala
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

[SimpleType, IntegerType (rank = 6), CCode (has_type_id = false)]
internal struct Maia.Graphic.Fixed : int32
{
    // constants
    const Fixed e = 1;

    // static methods
    public static inline Fixed
    from_int (int inVal)
    {
        return (Fixed)(inVal << 16);
    }

    public static inline Fixed
    from_double (double inVal)
    {
        return (Fixed)(inVal * 65536.0);
    }

    // methods
    public inline int
    to_int ()
    {
        return (int)(this >> 16);
    }

    public inline double
    to_double ()
    {
        return (double)this / (double)from_int (1);
    }
}
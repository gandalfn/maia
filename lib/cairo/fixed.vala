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
 *
 * See: http://stereopsis.com/FPU.html
 */

[SimpleType, IntegerType (rank = 6), CCode (has_type_id = false)]
internal struct Maia.Cairo.Fixed : int32
{
    const int32 s_Frac = 8;
    const double s_Magic = ((1LL << (52 - s_Frac)) * 1.5);
#if BIG_INDIAN
    const int s_Mantisse = 1;
#else
    const int s_Mantisse = 0;
#endif

    // static methods
    public static inline Fixed
    from_int (int inVal)
    {
        return (Fixed)(inVal << s_Frac);
    }

    public static inline Fixed
    from_double (double inVal)
    {
        double val = inVal + s_Magic;
        void* ptr = &val;
        Fixed* tab = (Fixed*)ptr;
        return tab[s_Mantisse];
    }

    // methods
    public inline double
    to_double ()
    {
        return (double)this / (double)from_int (1);
    }
}

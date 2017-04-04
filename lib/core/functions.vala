/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * functions.vala
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

namespace Maia.Core
{
    // constants
    const double MM_PER_INCH = 25.4;

    // Delegates
    [CCode (has_target = false)]
    public delegate int    CompareFunc<V>         (V inA, V inB);
    [CCode (has_target = false)]
    public delegate int    ValueCompareFunc<V, A> (V inV, A inA);
    public delegate bool   ForeachFunc<V>         (V inData);

    // static methods
    public static inline int
    direct_compare (void* inA, void* inB)
    {
        return (int)((ulong)inA - (ulong)inB);
    }

    public static inline int
    uint32_compare (uint32 inA, uint32 inB)
    {
        return (int)(inA - inB);
    }

    public static inline int
    double_compare (double inA, double inB)
    {
        return ((int)(inA * 65535.0) - (int)(inB * 65535.0));
    }

    public static inline CompareFunc<V>
    get_compare_func_for<V> ()
    {
        CompareFunc<V> func = (CompareFunc<V>)direct_compare;

        if (typeof (V) == typeof (string))
            func = (CompareFunc<V>)GLib.strcmp;
        else if (typeof (V) == typeof (Pair))
            func = (CompareFunc<V>)Pair.compare;
        else if (typeof (V).is_a (typeof (Object)))
            func = (CompareFunc<V>)Object.compare;
        else if (typeof (V) == typeof (uint32))
            func = (CompareFunc<V>)uint32_compare;
        else if (typeof (V) == typeof (double))
            func = (CompareFunc<V>)double_compare;

        return func;
    }

    public static inline double
    convert_mm_to_pixel (double inVal, double inDpi = 96)
    {
        return convert_inch_to_pixel (inVal / MM_PER_INCH);
    }

    public static inline double
    convert_inch_to_pixel (double inVal, double inDpi = 96)
    {
        return inVal * inDpi;
    }
}

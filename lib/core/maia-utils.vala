/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offarray: 4; tab-width: 4 -*- */
/*
 * maia-utils.vala
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

namespace Maia
{
    // Types
    [CCode (has_target = false)]
    public delegate bool   EqualFunc<V>      (V inA, V inB);
    [CCode (has_target = false)]
    public delegate int    CompareFunc<V>    (V inA, V inB);
    [CCode (has_target = false)]
    public delegate string ToStringFunc<V>   (V inValue);
    [CCode (has_target = false)]
    public delegate V      AccumulateFunc<V> (V inA, V inB);

    // Methods
    static string
    long_to_string (long a)
    {
        return a.to_string ();
    }

    static string
    double_to_string (long a)
    {
        return a.to_string ();
    }

    public static int
    direct_compare (void* inA, void* inB)
    {
        return (long)inA > (long)inB ? 1 : ((long)inA < (long)inB ? -1 : 0);
    }

    static bool
    bool_accumulator (bool inA, bool inB)
    {
        return inA | inB;
    }

    static int
    int_accumulator (int inA, int inB)
    {
        return inA + inB;
    }

    static uint
    uint_accumulator (uint inA, uint inB)
    {
        return inA + inB;
    }

    static long
    long_accumulator (long inA, long inB)
    {
        return inA + inB;
    }

    static ulong
    ulong_accumulator (ulong inA, ulong inB)
    {
        return inA + inB;
    }

    static float
    float_accumulator (float inA, float inB)
    {
        return inA + inB;
    }

    static double
    double_accumulator (double inA, double inB)
    {
        return inA + inB;
    }

    static string
    string_accumulator (string inA, string inB)
    {
        return inA + inB;
    }

    public static EqualFunc<V>
    get_equal_func_for<V> ()
    {
        EqualFunc<V> func = (EqualFunc<V>)GLib.direct_equal;

        if (typeof (V) == typeof (string))
            func = (EqualFunc<V>)GLib.str_equal;
        else if (typeof (V).is_a (typeof (Object)))
            func = (EqualFunc<V>)Object.equals;

        return func;
    }

    public static CompareFunc<V>
    get_compare_func_for<V> ()
    {
        CompareFunc<V> func = (CompareFunc<V>)direct_compare;

        if (typeof (V) == typeof (string))
            func = (CompareFunc<V>)GLib.strcmp;
        else if (typeof (V).is_a (typeof (Object)))
            func = (CompareFunc<V>)Object.compare;

        return func;
    }

    public static ToStringFunc<V>
    get_to_string_func_for<V> ()
    {
        ToStringFunc<V> func = null;

        if (typeof (V) == typeof (string))
            func = (ToStringFunc<V>)string.dup;
        else if (typeof (V) == typeof (int) || typeof (V) == typeof (uint) ||
                 typeof (V) == typeof (long) || typeof (V) == typeof (ulong))
            func = (ToStringFunc<V>)long_to_string;
        else if (typeof (V) == typeof (float) || typeof (V) == typeof (double))
            func = (ToStringFunc<V>)double_to_string;
        else if (typeof (V).is_a (typeof (Object)))
            func = (ToStringFunc<V>)Object.to_string;

        return func;
    }

    public static AccumulateFunc<V>
    get_accumulator_func_for<V> ()
    {
        AccumulateFunc<V> func = null;

        if (typeof (V) == typeof (bool))
            func = (AccumulateFunc<V>)bool_accumulator;
        else if (typeof (V) == typeof (int))
            func = (AccumulateFunc<V>)int_accumulator;
        else if (typeof (V) == typeof (uint))
            func = (AccumulateFunc<V>)uint_accumulator;
        else if (typeof (V) == typeof (long))
            func = (AccumulateFunc<V>)long_accumulator;
        else if (typeof (V) == typeof (ulong))
            func = (AccumulateFunc<V>)ulong_accumulator;
        else if (typeof (V) == typeof (float))
            func = (AccumulateFunc<V>)float_accumulator;
        else if (typeof (V) == typeof (double))
            func = (AccumulateFunc<V>)double_accumulator;
        else if (typeof (V) == typeof (string))
            func = (AccumulateFunc<V>)string_accumulator;

        return func;
    }
}
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

namespace Maia
{
    // Delegates
    [CCode (has_target = false)]
    public delegate string ToStringFunc<V>        (V inValue);
    [CCode (has_target = false)]
    public delegate V      FromStringFunc<V>      (string inStr);
    [CCode (has_target = false)]
    public delegate int    CompareFunc<V>         (V inA, V inB);
    [CCode (has_target = false)]
    public delegate int    ValueCompareFunc<V, A> (V inV, A inA);
    [CCode (has_target = false)]
    public delegate V      AccumulateFunc<V>      (V inA, V inB);
    public delegate bool   ForeachFunc<V>         (V inData);
    public delegate void   EndIterateFunc         ();

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

    static inline string
    type_to_string (GLib.Type inType)
    {
        return inType.name ().dup ();
    }

    static inline bool
    bool_accumulator (bool inA, bool inB)
    {
        return inA | inB;
    }

    static inline int
    int_accumulator (int inA, int inB)
    {
        return inA + inB;
    }

    static inline uint
    uint_accumulator (uint inA, uint inB)
    {
        return inA + inB;
    }

    static inline long
    long_accumulator (long inA, long inB)
    {
        return inA + inB;
    }

    static inline ulong
    ulong_accumulator (ulong inA, ulong inB)
    {
        return inA + inB;
    }

    static inline float
    float_accumulator (float inA, float inB)
    {
        return inA + inB;
    }

    static inline double
    double_accumulator (double inA, double inB)
    {
        return inA + inB;
    }

    static inline string
    string_accumulator (string inA, string inB)
    {
        return inA + inB;
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

        return func;
    }

    public static inline ToStringFunc<V>
    get_to_string_func_for<V> ()
    {
        ToStringFunc<V> func = null;

        if (typeof (V) == typeof (string))
            func = (ToStringFunc<V>)string.dup;
        else if (typeof (V) == typeof (int))
            func = (ToStringFunc<V>)int.to_string;
        else if (typeof (V) == typeof (uint))
            func = (ToStringFunc<V>)uint.to_string;
        else if (typeof (V) == typeof (long))
            func = (ToStringFunc<V>)long.to_string;
        else if (typeof (V) == typeof (ulong))
            func = (ToStringFunc<V>)ulong.to_string;
        else if (typeof (V) == typeof (float))
            func = (ToStringFunc<V>)float.to_string;
        else if (typeof (V) == typeof (double))
            func = (ToStringFunc<V>)double.to_string;
        else if (typeof (V) == typeof (GLib.Type))
            func = (ToStringFunc)type_to_string;
        else if (typeof (V) == typeof (Pair))
            func = (ToStringFunc<V>)Pair.to_string;
        else if (typeof (V) == typeof (uint32))
            func = (ToStringFunc<V>)uint32.to_string;
        else if (typeof (V).is_a (typeof (Object)))
            func = (ToStringFunc<V>)Object.to_string;

        return func;
    }

    public static inline FromStringFunc<V>
    get_from_string_func_for<V> ()
    {
        FromStringFunc<V> func = null;

        if (typeof (V) == typeof (string))
            func = (FromStringFunc<V>)string.dup;
        else if (typeof (V) == typeof (int))
            func = (FromStringFunc<V>)int.parse;
        else if (typeof (V) == typeof (uint))
            func = (FromStringFunc<V>)int.parse;
        else if (typeof (V) == typeof (long))
            func = (FromStringFunc<V>)long.parse;
        else if (typeof (V) == typeof (ulong))
            func = (FromStringFunc<V>)long.parse;
        else if (typeof (V) == typeof (float))
            func = (FromStringFunc<V>)double.parse;
        else if (typeof (V) == typeof (double))
            func = (FromStringFunc<V>)double.parse;

        return func;
    }

    public static inline AccumulateFunc<V>
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

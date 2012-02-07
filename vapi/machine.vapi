/* -*- Mode: Vala; indent-tabs-mode: null; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * machine.h
 * Copyright (C) Nicolas Bruguier 2011 <gandalfn@club-internet.fr>
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

[CCode (cheader_filename = "machine.h")]
namespace Machine
{
    namespace CPU
    {
        public void pause();
    }

    namespace Memory
    {
        namespace Fence
        {
            public static void strict_load ();
            public static void load ();
            public static void strict_load_depends ();
            public static void load_depends ();
            public static void strict_store ();
            public static void store ();
            public static void strict_memory ();
            public static void memory ();
        }

        namespace Volatile
        {
            [CCode (cname = "volatile guint")]
            public struct uint : global::uint {
            }
        }

        namespace Atomic
        {
            [CCode (cname = "void*", default_value = "NULL")]
            public struct Pointer
            {
                [CCode (cname = "machine_memory_atomic_load_ptr")]
                public void* get ();

                [CCode (cname = "machine_memory_atomic_store_ptr")]
                public void set (void* inVal);

                [CCode (cname = "machine_memory_atomic_fas_ptr")]
                public void* fetch_and_store (void* inVal);

                [CCode (cname = "machine_memory_atomic_faa_ptr")]
                public void* fetch_and_add (void* inVal);

                [CCode (cname = "machine_memory_atomic_inc_ptr")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_ptr")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_ptr")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_ptr")]
                public bool compare_and_swap (void* inCompare, void* inSet);

                [CCode (cname = "machine_memory_atomic_cas_ptr_value")]
                public bool compare_and_swap_value (void* inCompare, void* inSet, out void* outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_ptr")]
                public static unowned Pointer? cast (void* inV);
            }

            [CCode (cname = "char", default_value = "0")]
            public struct char
            {
                [CCode (cname = "machine_memory_atomic_load_char")]
                public global::char get ();

                [CCode (cname = "machine_memory_atomic_store_char")]
                public void set (global::char inVal);

                [CCode (cname = "machine_memory_atomic_fas_char")]
                public global::char fetch_and_store (global::char inVal);

                [CCode (cname = "machine_memory_atomic_faa_char")]
                public global::char fetch_and_add (global::char inVal);

                [CCode (cname = "machine_memory_atomic_inc_char")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_char")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_char")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_char")]
                public bool compare_and_swap (global::char inCompare, global::char inSet);

                [CCode (cname = "machine_memory_atomic_cas_char_value")]
                public bool compare_and_swap_value (global::char inCompare, global::char inSet, out global::char outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_char")]
                public static unowned char? cast (void* inV);
            }

            [CCode (cname = "int", default_value = "0")]
            public struct int
            {
                [CCode (cname = "machine_memory_atomic_load_int")]
                public global::int get ();

                [CCode (cname = "machine_memory_atomic_store_int")]
                public void set (global::int inVal);

                [CCode (cname = "machine_memory_atomic_fas_int")]
                public global::int fetch_and_store (global::int inVal);

                [CCode (cname = "machine_memory_atomic_faa_int")]
                public global::int fetch_and_add (global::int inVal);

                [CCode (cname = "machine_memory_atomic_inc_int")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_int")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_int")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_int")]
                public bool compare_and_swap (global::int inCompare, global::int inSet);

                [CCode (cname = "machine_memory_atomic_cas_int_value")]
                public bool compare_and_swap_value (global::int inCompare, global::int inSet, out global::int outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_int")]
                public static unowned int? cast (void* inV);
            }

            [CCode (cname = "unsigned int", default_value = "0")]
            public struct uint
            {
                [CCode (cname = "machine_memory_atomic_load_uint")]
                public global::uint get ();

                [CCode (cname = "machine_memory_atomic_store_uint")]
                public void set (global::uint inVal);

                [CCode (cname = "machine_memory_atomic_fas_uint")]
                public global::uint fetch_and_store (global::uint inVal);

                [CCode (cname = "machine_memory_atomic_faa_uint")]
                public global::uint fetch_and_add (global::uint inVal);

                [CCode (cname = "machine_memory_atomic_inc_uint")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_uint")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_uint")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_uint")]
                public bool compare_and_swap (global::uint inCompare, global::uint inSet);

                [CCode (cname = "machine_memory_atomic_cas_uint_value")]
                public bool compare_and_swap_value (global::uint inCompare, global::uint inSet, out global::uint outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_uint")]
                public static unowned uint? cast (void* inV);
            }

            [CCode (cname = "guint8", default_value = "0")]
            public struct uint8
            {
                [CCode (cname = "machine_memory_atomic_load_8")]
                public global::uint8 get ();

                [CCode (cname = "machine_memory_atomic_store_8")]
                public void set (global::uint8 inVal);

                [CCode (cname = "machine_memory_atomic_fas_8")]
                public global::uint8 fetch_and_store (global::uint8 inVal);

                [CCode (cname = "machine_memory_atomic_faa_8")]
                public global::uint8 fetch_and_add (global::uint8 inVal);

                [CCode (cname = "machine_memory_atomic_inc_8")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_8")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_8")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_8")]
                public bool compare_and_swap (global::uint8 inCompare, global::uint8 inSet);

                [CCode (cname = "machine_memory_atomic_cas_8_value")]
                public bool compare_and_swap_value (global::uint8 inCompare, global::uint8 inSet, out global::uint8 outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_8")]
                public static unowned uint8? cast (void* inV);
            }

            [CCode (cname = "guint16", default_value = "0")]
            public struct uint16
            {
                [CCode (cname = "machine_memory_atomic_load_16")]
                public global::uint16 get ();

                [CCode (cname = "machine_memory_atomic_store_16")]
                public void set (global::uint16 inVal);

                [CCode (cname = "machine_memory_atomic_fas_16")]
                public global::uint16 fetch_and_store (global::uint16 inVal);

                [CCode (cname = "machine_memory_atomic_faa_16")]
                public global::uint16 fetch_and_add (global::uint16 inVal);

                [CCode (cname = "machine_memory_atomic_inc_16")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_16")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_16")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_16")]
                public bool compare_and_swap (global::uint16 inCompare, global::uint16 inSet);

                [CCode (cname = "machine_memory_atomic_cas_16_value")]
                public bool compare_and_swap_value (global::uint16 inCompare, global::uint16 inSet, out global::uint16 outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_16")]
                public static unowned uint16? cast (void* inV);
            }

            [CCode (cname = "guint32", default_value = "0")]
            public struct uint32
            {
                [CCode (cname = "machine_memory_atomic_get_32")]
                public global::uint32 get ();

                [CCode (cname = "machine_memory_atomic_set_32")]
                public void set (global::uint32 inVal);

                [CCode (cname = "machine_memory_atomic_fas_32")]
                public global::uint32 fetch_and_store (global::uint32 inVal);

                [CCode (cname = "machine_memory_atomic_faa_32")]
                public global::uint32 fetch_and_add (global::uint32 inVal);

                [CCode (cname = "machine_memory_atomic_inc_32")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_32")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_32")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_32")]
                public bool compare_and_swap (global::uint32 inCompare, global::uint32 inSet);

                [CCode (cname = "machine_memory_atomic_cas_32_value")]
                public bool compare_and_swap_value (global::uint32 inCompare, global::uint32 inSet, out global::uint32 outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_32")]
                public static unowned uint32? cast (void* inV);
            }

            [CCode (cname = "guint64", default_value = "0")]
            public struct uint64
            {
                [CCode (cname = "machine_memory_atomic_load_64")]
                public global::uint64 get ();

                [CCode (cname = "machine_memory_atomic_store_64")]
                public void set (global::uint64 inVal);

                [CCode (cname = "machine_memory_atomic_fas_64")]
                public global::uint64 fetch_and_store (global::uint64 inVal);

                [CCode (cname = "machine_memory_atomic_faa_64")]
                public global::uint64 fetch_and_add (global::uint64 inVal);

                [CCode (cname = "machine_memory_atomic_inc_64")]
                public void inc ();

                [CCode (cname = "machine_memory_atomic_dec_64")]
                public void dec ();

                [CCode (cname = "machine_memory_atomic_neg_64")]
                public void neg ();

                [CCode (cname = "machine_memory_atomic_cas_64")]
                public bool compare_and_swap (global::uint64 inCompare, global::uint64 inSet);

                [CCode (cname = "machine_memory_atomic_cas_64_value")]
                public bool compare_and_swap_value (global::uint64 inCompare, global::uint64 inSet, out global::uint64 outOldValue);

                [CCode (cname = "machine_memory_atomic_cast_64")]
                public static unowned uint64? cast (void* inV);
            }
        }
    }
}

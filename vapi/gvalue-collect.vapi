/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * gvalue-collect.vapi
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

namespace GLib
{
    public struct ValueCollect
    {
        [CCode (cname = "G_VALUE_COLLECT", cheader_filename = "glib-object.h,gobject/gvaluecollector.h")]
        public static void get (ref GLib.Value val, va_list list, int flags, ref string error);
    }

    [Compact]
    [CCode (cname="GVariant", ref_function = "g_variant_ref", unref_function = "g_variant_unref", ref_sink_function = "g_variant_ref_sink", type_id = "G_TYPE_VARIANT", marshaller_type_name = "VARIANT", param_spec_function = "g_param_spec_variant", get_value_function = "g_value_get_variant", set_value_function = "g_value_set_variant", take_value_function = "g_value_take_variant", type_signature = "v")]
    public class VariantFixed : Variant {
        [CCode (cname = "g_variant_new_fixed_array", simple_generics = true)]
        public static unowned Variant @new<T> (VariantType? element_type, [CCode (array_length_type = "gsize")] T[] elements, size_t element_size);

        [CCode (cname = "g_variant_get_fixed_array", simple_generics = true, array_length_pos = 0.1, array_length_type = "gsize")]
        public unowned T[] @get<T> (size_t element_size);
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * value.vala
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
    public class Value
    {
        private static bool s_SimpleTypeRegistered = false;

        // static methods
        private static void
        register_simple_type ()
        {
            register_transform_funcs (typeof (bool),   string_to_bool,   bool_to_string);
            register_transform_funcs (typeof (int),    string_to_int,    int_to_string);
            register_transform_funcs (typeof (uint),   string_to_uint,   uint_to_string);
            register_transform_funcs (typeof (long),   string_to_long,   long_to_string);
            register_transform_funcs (typeof (ulong),  string_to_ulong,  ulong_to_string);
            register_transform_funcs (typeof (double), string_to_double, double_to_string);

            s_SimpleTypeRegistered = true;
        }

        private static void
        double_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (double)))
        {
            double val = (double)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_double (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = double.parse (val);
        }

        private static void
        int_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (int)))
        {
            int val = (int)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_int (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = int.parse (val);
        }

        private static void
        uint_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (uint)))
        {
            uint val = (uint)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_uint (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = (uint)int.parse (val);
        }

        private static void
        long_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (long)))
        {
            long val = (long)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_long (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = long.parse (val);
        }

        private static void
        ulong_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (ulong)))
        {
            ulong val = (ulong)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_ulong (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = (ulong)long.parse (val);
        }

        private static void
        bool_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (bool)))
        {
            bool val = (bool)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_bool (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = bool.parse (val);
        }

        public static void
        register_transform_funcs (GLib.Type inType, GLib.ValueTransform inFromString, GLib.ValueTransform inToString)
        {
            GLib.Value.register_transform_func (typeof (string), inType, inFromString);
            GLib.Value.register_transform_func (inType, typeof (string), inToString);
        }

        public static GLib.Value
        from_string (Type inType, string inValue)
        {
            if (inType.is_classed () && inType.class_peek () == null)
                inType.class_ref ();
            else if (!s_SimpleTypeRegistered)
                register_simple_type ();

            GLib.Value val = GLib.Value (inType);
            GLib.Value str = inValue;
            str.transform (ref val);

            return val;
        }
    }
}

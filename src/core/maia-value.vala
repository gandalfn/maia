/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-value.vala
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

namespace Maia.Value
{
    private static bool s_SimpleTypeRegistered = false;

    internal static void
    register_simple_type ()
    {
        GLib.Value.register_transform_func (typeof (string), typeof (double),
                                            (ValueTransform)string_to_double);
        GLib.Value.register_transform_func (typeof (double), typeof (string),
                                            (ValueTransform)double_to_string);

        GLib.Value.register_transform_func (typeof (string), typeof (int),
                                            (ValueTransform)string_to_int);
        GLib.Value.register_transform_func (typeof (int), typeof (string),
                                            (ValueTransform)int_to_string);

        s_SimpleTypeRegistered = true;
    }

    static void 
    double_to_string (GLib.Value inSrc, out GLib.Value outDest) 
        requires (inSrc.holds (typeof (double)))
    {
        double val = (double)inSrc;

        outDest = val.to_string ();
    }

    static void 
    string_to_double (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
        requires ((string)inSrc != null)
    {
        string val = (string)inSrc;

        outDest = val.to_double ();
    }

    static void 
    int_to_string (GLib.Value inSrc, out GLib.Value outDest) 
        requires (inSrc.holds (typeof (int)))
    {
        int val = (int)inSrc;

        outDest = val.to_string ();
    }

    static void 
    string_to_int (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
        requires ((string)inSrc != null)
    {
        string val = (string)inSrc;

        outDest = val.to_int ();
    }

    public static GLib.Value
    from_string (Type inType, string inValue)
    {
        if (inType.is_classed ())
            inType.class_ref ();
        else if (!s_SimpleTypeRegistered)
            register_simple_type ();

        GLib.Value val = GLib.Value (inType);
        GLib.Value str = inValue;
        str.transform (ref val);

        return val;
    }
}
/*
 * byte-field.vala
 * Copyright (C) Nicolas Bruguier 2010-2015 <gandalfn@club-internet.fr>
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

internal class Maia.Protocol.ByteField : Field
{
    // accessors
    internal override Field.Type field_type {
        get {
            return Field.Type.BYTE;
        }
    }

    internal override string @default {
        set {
            base.@default = value ?? "0";
        }
    }

    // static methods
    static construct
    {
        GLib.Value.register_transform_func (typeof (string), typeof (uchar),  string_to_uchar);
    }

    private static void
    string_to_uchar (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = val.to_utf8()[0];
    }

    // methods
    public ByteField (string inName, bool inRepeated, string? inDefault)
    {
        base (inName, inRepeated, inDefault);
    }

    internal override GLib.Variant
    get_variant (int inIndex)
        requires (inIndex < m_Values.length)
    {
        return new GLib.Variant.byte ((uchar)m_Values[inIndex]);
    }

    internal override void
    set_variant (int inIndex, GLib.Variant inVariant)
        requires (inIndex < m_Values.length)
        requires (inVariant.get_type ().equal (field_type.to_variant_type ()))
    {
        m_Values[inIndex] = (uchar)inVariant.get_byte ();
    }

    internal override string
    to_string ()
    {
        string ret = "";

        if (repeated) ret += "a";
        ret += "y";

        return ret;
    }
}

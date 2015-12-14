/*
 * bool-field.vala
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

internal class Maia.Protocol.BoolField : Field
{
    // accessors
    public override Field.Type field_type {
        get {
            return Field.Type.BOOLEAN;
        }
    }

    // static methods
    static construct
    {
        GLib.Value.register_transform_func (typeof (string), typeof (bool),   string_to_bool);
    }

    private static void
    string_to_bool (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = bool.parse (val);
    }

    // methods
    public BoolField (string inName, bool inRepeated, string? inDefault) throws ProtocolError
    {
        base (inName, inRepeated, inDefault);
    }

    public override BufferChild
    copy () throws ProtocolError
    {
        Field field = new BoolField (name, repeated, null);
        field.m_Values = {};
        foreach (unowned GLib.Value? val in m_Values)
        {
            GLib.Value field_val = create_value ();
            val.copy (ref field_val);
            field.m_Values += val;
        }
        return field;
    }

    internal override void
    set_default (string? inDefault)
    {
        base.set_default (inDefault ?? "false");
    }

    internal override GLib.Variant
    get_variant (int inIndex)
        requires (inIndex < m_Values.length)
    {
        return new GLib.Variant.boolean ((bool)m_Values[inIndex]);
    }

    internal override void
    set_variant (int inIndex, GLib.Variant inVariant)
        requires (inIndex < m_Values.length)
        requires (inVariant.get_type ().equal (field_type.to_variant_type ()))
    {
        m_Values[inIndex] = inVariant.get_boolean ();
    }

    internal override string
    to_string ()
    {
        string ret = "";

        if (repeated) ret += "a";
        ret += "b";

        return ret;
    }
}

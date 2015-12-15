/*
 * message-field.vala
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

internal class Maia.Protocol.MessageField : Field
{
    // accessors
    public Message message { get; construct; default = null; }

    internal override Field.Type field_type {
        get {
            return Field.Type.MESSAGE;
        }
    }

    internal override string @default {
        set {
        }
    }

    // methods
    public MessageField (string inName, bool inRepeated, Message inMessage, string? inDefault)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), repeated: inRepeated, message: inMessage, default: inDefault);
    }

    protected override GLib.Value
    create_value ()
    {
        GLib.Value ret = GLib.Value (field_type.to_gtype ());
        ret = message.copy ();
        return ret;
    }

    internal override BufferChild
    copy ()
    {
        Field field = new MessageField (name, repeated, message, null);
        field.m_Values = {};
        foreach (unowned GLib.Value? val in m_Values)
        {
            field.add_value (val);
        }
        return field;
    }

    internal override GLib.Variant
    get_variant (int inIndex)
        requires (inIndex < m_Values.length)
    {
        return ((Message)m_Values[inIndex]).serialize;
    }

    internal override void
    set_variant (int inIndex, GLib.Variant inVariant)
        requires (inIndex < m_Values.length)
        requires (inVariant.get_type ().is_tuple ())
    {
        ((Message)m_Values[inIndex]).serialize = inVariant;
    }

    internal override string
    to_string ()
    {
        string ret = "";

        if (repeated) ret += "a";
        ret += message.to_string ();

        return ret;
    }
}

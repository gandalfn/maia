/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * message.vala
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

public class Maia.Protocol.Message : Core.Object, BufferChild
{
    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public GLib.Variant serialize {
        owned get {
            GLib.Variant[] childs = {};

            foreach (unowned Core.Object? child in this)
            {
                unowned Field? field = child as Field;
                if (field != null)
                {
                    childs += field.serialize;
                }
            }

            return new GLib.Variant.tuple (childs);
        }
        set {
            int cpt = 0;
            foreach (unowned Core.Object? child in this)
            {
                unowned Field? field = child as Field;
                if (field != null)
                {
                    field.serialize = value.get_child_value (cpt);
                    cpt++;
                }
            }
        }
    }

    // methods
    public Message (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
    }

    private Field
    create_field (string inType, string? inRule, string inName, string? inOptions) throws ProtocolError
    {
        Field.Type type = Field.Type.from_string (inType);
        bool repeated = inRule != null && inRule == "repeated";

        string? default_value = null;
        if (inOptions != null)
        {
            try
            {
                GLib.Regex re = new GLib.Regex ("""^default[^=]*=\s*(["']?)([^'"]*)\1$""");
                if (re.match (inOptions))
                {
                    string[] v = re.split (inOptions);

                    default_value = v[2].strip();
                }
                else
                {
                    throw new ProtocolError.INVALID_OPTION (@"Invalid field options $(inOptions)");
                }
            }
            catch (GLib.Error err)
            {
                throw new ProtocolError.INVALID_OPTION (@"Invalid field options $(inOptions): $(err.message)");
            }
        }

        Field field = null;
        if (type == Field.Type.MESSAGE)
        {
            unowned Message? msg = buffer[inType];
            if (msg == null)
            {
                throw new ProtocolError.INVALID_TYPE (@"Invalid field type $(inType)");
            }
            field = GLib.Object.new (type.to_field_gtype (), id: GLib.Quark.from_string (inName), repeated: repeated, message: msg, default: default_value) as Field;
        }
        else
        {
            field = GLib.Object.new (type.to_field_gtype (), id: GLib.Quark.from_string (inName), repeated: repeated, default: default_value) as Field;
        }

        if (field == null)
        {
            throw new ProtocolError.INVALID_TYPE (@"Invalid field type $(inType)");
        }

        return field;
    }

    public BufferChild
    copy ()
    {
        Message msg = new Message (name);
        foreach (unowned Core.Object child in this)
        {
            unowned Field? childField = child as Field;
            if (childField != null)
            {
                msg.add (childField.copy ());
            }
            else
            {
                unowned Message? childMsg = child as Message;
                if (childMsg != null)
                {
                    msg.add (childMsg.copy ());
                }
            }
        }
        return msg;
    }

    internal void
    read_buffer (Buffer inBuffer) throws Core.ParseError, ProtocolError
    {
        foreach (Core.Parser.Token token in inBuffer)
        {
            switch (token)
            {
                case Core.Parser.Token.START_ELEMENT:
                    Message msg = new Message (inBuffer.message);
                    add (msg);
                    msg.read_buffer (inBuffer);
                    break;

                case Core.Parser.Token.ATTRIBUTE:
                    Field field = create_field (inBuffer.attribute_type, inBuffer.attribute_rule, inBuffer.attribute_name, inBuffer.attribute_options);
                    add (field);
                    break;

                case Core.Parser.Token.END_ELEMENT:
                    return;
            }
        }
    }

    internal override string
    to_string ()
    {
        string ret = "(";

        foreach (unowned Core.Object? child in this)
        {
            ret += @"$child";
        }

        ret += ")";

        return ret;
    }

    internal unowned Message?
    get_message (string inName)
    {
        string[] split = inName.split (".");

        unowned Message? msg = find (GLib.Quark.from_string (split[0]), false) as Message;
        if (msg != null && split.length > 1)
        {
            msg = msg.get_message (string.joinv(".", split[1:split.length]));
        }

        return msg;
    }

    public new bool
    contains (string inName)
    {
        unowned Field? field = find (GLib.Quark.from_string (inName), false) as Field;
        return field != null;
    }

    public new GLib.Value?
    @get (string inName, int inIndex = 0)
    {
        unowned Field? field = find (GLib.Quark.from_string (inName), false) as Field;
        GLib.return_val_if_fail (field != null, null);

        return field[inIndex];
    }

    public new void
    @set (string inName, int inIndex, GLib.Value inValue)
    {
        unowned Field? field = find (GLib.Quark.from_string (inName), false) as Field;
        GLib.return_if_fail (field != null);

        field[inIndex] = inValue;
    }

    public int
    add_value (string inName, GLib.Value inValue)
    {
        unowned Field? field = find (GLib.Quark.from_string (inName), false) as Field;
        GLib.return_val_if_fail (field != null, -1);

        return field.add_value (inValue);
    }
}

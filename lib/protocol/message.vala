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

    // methods
    public Message (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
    }

    public Message
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
    read_buffer (Buffer inBuffer) throws Core.ParseError
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
                    Field.Rule rule = Field.Rule.from_string (inBuffer.attribute_rule);
                    Field.Type type = Field.Type.from_string (inBuffer.attribute_type);
                    string? default_value = null;
                    if (inBuffer.attribute_options != null)
                    {
                        if (rule != Field.Rule.OPTIONAL)
                        {
                            throw new Core.ParseError.PARSE (@"Invalid field options for a not optional field $(inBuffer.attribute_options)");
                        }
                        try
                        {
                            GLib.Regex re = new GLib.Regex ("""^default[^=]*=\s*(["']?)([^'"]*)\1$""");
                            if (re.match (inBuffer.attribute_options))
                            {
                                string[] v = re.split (inBuffer.attribute_options);

                                default_value = v[2].strip();
                            }
                            else
                            {
                                throw new Core.ParseError.PARSE (@"Invalid field options $(inBuffer.attribute_options)");
                            }
                        }
                        catch (GLib.Error err)
                        {
                            throw new Core.ParseError.PARSE (@"Invalid field options $(inBuffer.attribute_options): $(err.message)");
                        }
                    }
                    Field field = new Field (rule, type, inBuffer.attribute_name, default_value);
                    if (type == Field.Type.MESSAGE)
                    {
                        Message? msg = buffer[inBuffer.attribute_type];
                        if (msg == null)
                        {
                            throw new Core.ParseError.PARSE (@"Invalid field type $(inBuffer.attribute_type)");
                        }
                        field.set ((owned)msg);
                    }
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

    internal GLib.Variant?
    to_variant ()
    {
        GLib.Variant[] childs = {};

        foreach (unowned Core.Object? child in this)
        {
            unowned BufferChild? bufferChild = child as BufferChild;
            if (bufferChild != null)
            {
                GLib.Variant? val = bufferChild.to_variant ();
                if (val != null)
                {
                    childs += val;
                }
            }
        }

        return new GLib.Variant.tuple (childs);
    }

    internal void
    set_variant (GLib.Variant inVariant)
        requires (inVariant.get_type ().is_tuple ())
    {
        int cpt = 0;
        foreach (unowned Core.Object? child in this)
        {
            unowned BufferChild? bufferChild = child as BufferChild;
            if (bufferChild != null)
            {
                bufferChild.set_variant (inVariant.get_child_value (cpt));
                cpt++;
            }
        }
    }

    public new unowned Field?
    @get (string inName)
    {
        return find (GLib.Quark.from_string (inName), false) as Field;
    }
}

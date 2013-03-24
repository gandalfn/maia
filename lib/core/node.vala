/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * node.vala
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

public abstract class Maia.Node : Object
{
    // static properties
    private static SpinLock                s_Lock;
    private static ulong                   s_CountId;
    private static Map<string, GLib.Type?> s_Factory;

    // static methods
    static construct
    {
        s_CountId = 0;
        s_Lock = SpinLock ();
        s_Factory = new Map<string, GLib.Type> ();
    }

    public static void
    register (string inNodeName, GLib.Type inType)
    {
        s_Lock.lock ();
        s_Factory[inNodeName] = inType;
        s_Lock.unlock ();
    }

    // accessors
    /**
     * Node tag name
     */
    public abstract string tag_name { get; }

    /**
     * Node characters content
     */
    public virtual string characters { get; set; default = null; }

    // static methods
    private static string
    format_attribute_name (string inName)
    {
        GLib.StringBuilder ret = new GLib.StringBuilder("");
        bool previous_is_upper = true;

        unowned char[] s = (char[])inName;
        for (int cpt = 0; s[cpt] != 0; ++cpt)
        {
            char c = s [cpt];
            if (c.isupper())
            {
                if (!previous_is_upper) ret.append_unichar ('_');
                ret.append_unichar (c.tolower());
                previous_is_upper = true;
            }
            else
            {
                ret.append_unichar (c);
                previous_is_upper = false;
            }
        }

        return ret.str;
    }

    private static Node?
    create (string inName, Map<string, string>? inParams)
    {
        Node? node = null;

        if (s_Factory != null)
        {
            s_Lock.lock ();
            GLib.Type? type = s_Factory[inName];
            s_Lock.unlock ();
            if (type != null)
            {
                node = GLib.Object.new (type) as Node;
                foreach (unowned Pair<string, string> param in inParams)
                {
                    node.set_attribute (param.first, param.second);
                }
            }
        }

        return node;
    }

    // methods
    private string?
    get_attribute (string inName)
    {
        // Search property in object class
        string ret = null;
        string name = format_attribute_name (inName);
        unowned GLib.ParamSpec param = get_class ().find_property (name);

        // We found property which correspond to attribute name convert it to
        // string format
        if (param != null)
        {
            GLib.Value val = GLib.Value (param.value_type);
            GLib.Value o = GLib.Value (typeof (string));
            get_property (name, ref val);
            val.transform (ref o);
            ret = (string)o;
        }

        return ret;
    }

    private void
    set_attribute (string inName, string inValue)
    {
        // Search property in object class
        string name = format_attribute_name (inName);
        unowned GLib.ParamSpec param = get_class ().find_property (name);

        // We found property which correspond to attribute name convert value
        // to property type and set
        if (param != null)
        {
            set_property (name, Value.from_string (param.value_type, inValue));
        }
    }

    /**
     * Parse for this object
     *
     * @param inParser parser
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    parse (Parser inParser) throws ParseError
    {
        foreach (Parser.Token token in inParser)
        {
            switch (token)
            {
                case Parser.Token.START_ELEMENT:
                    {
                        Map<string, string> params = inParser.attributes;
                        Node node = create (inParser.element, params);
                        if (node != null)
                        {
                            node.parent = this;
                            node.parse (inParser);
                        }
                    }
                    break;
                case Parser.Token.END_ELEMENT:
                    if (inParser.element == tag_name)
                        return;
                    break;
                case Parser.Token.CHARACTERS:
                    characters = inParser.characters;
                    break;
                case Parser.Token.EOF:
                    return;
            }
        }
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * element.vala
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

public interface Maia.Element : View
{
    // static properties
    private static Map<string, GLib.Type> s_Factory;

    // accessors
    public abstract string tag { get; }

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

    public static Element?
    create (string inName)
    {
        Element? node = null;

        if (s_Factory != null)
        {
            GLib.Type type = s_Factory[inName];
            if (type != 0)
            {
                node = GLib.Object.new (type) as Element;
            }
        }

        return node;
    }

    public static void
    register (string inNodeName, GLib.Type inType)
        requires (inType.is_a (typeof (Element)))
    {
        if (s_Factory == null)
        {
            s_Factory = new Map<string, GLib.Type> ();
        }

        s_Factory[inNodeName] = inType;
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
     * Load manifest for this object
     *
     * @param inManifest manifest
     *
     * @throw ParserError when somethings goes wrong
     */
    public void
    read_manifest (Manifest inManifest) throws ParseError
    {
        foreach (Parser.Token token in inManifest)
        {
            switch (token)
            {
                // found a new child widget create it
                case Parser.Token.START_ELEMENT:
                    Element element = create (inManifest.element);
                    if (element != null)
                    {
                        element.parent = this;
                        element.read_manifest (inManifest);
                    }
                    break;

                // found an attribute set it
                case Parser.Token.ATTRIBUTE:
                    if (inManifest.element == tag)
                    {
                        set_attribute (inManifest.attribute, inManifest.val);
                    }
                    break;

                // end of widget manifest quit
                case Parser.Token.END_ELEMENT:
                    if (inManifest.element == tag)
                    {
                        return;
                    }
                    break;

                // end of file
                case Parser.Token.EOF:
                    return;
            }
        }
    }

    public string
    dump ()
    {
        string ret = "%s {\n".printf (tag);

        // dump attributes
        foreach (unowned GLib.ParamSpec param in get_class ().list_properties ())
        {
            string param_name = param.get_name ();
            string? attr = get_attribute (param_name);
            if (attr != null)
            {
                ret += "\t%s: %s;\n".printf (param_name, attr);
            }
        }

        // dump childs
        foreach (unowned Object child in this)
        {
            if (child is Element)
            {
                ret += (child as Element).dump ();
            }
        }

        ret += "}\n";

        return ret;
    }
}

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

public interface Maia.Manifest.Element : Core.Object
{
    // types
    public delegate Element CreateFunc (string inId);

    private class Create : Core.Object
    {
        public string     tag;
        public CreateFunc func;

        public Create (string inTag, owned CreateFunc inFunc)
        {
            tag = inTag;
            func = (owned)inFunc;
        }

        public override int
        compare (Core.Object inOther)
        {
            return GLib.strcmp (tag, ((Create)inOther).tag);
        }

        public int
        compare_with_tag (string inTag)
        {
            return GLib.strcmp (tag, inTag);
        }
    }

    // static properties
    private static Core.Set<Create> s_Factory = null;
    private static GLib.Quark       s_QuarkNotDumpableAttributes = 0;

    // accessors
    public abstract string tag { get; }
    public abstract string characters { get; set; default = null; }

    public unowned Element? root {
        get {
            unowned Core.Object? ret = this;
            for (; ret.parent != null; ret = ret.parent);

            return (Element)ret;
        }
    }

    public Core.Set<string> not_dumpable_attributes {
        get {
            if (s_QuarkNotDumpableAttributes == 0)
            {
                s_QuarkNotDumpableAttributes = GLib.Quark.from_string ("MaiaManifestElementNotDumpableAttributes");
            }

            unowned Core.Set<string>? ret = get_qdata<Core.Set<string>> (s_QuarkNotDumpableAttributes);
            if (ret == null)
            {
                Core.Set<string> not_dumpable = new Core.Set<string> ();
                set_qdata (s_QuarkNotDumpableAttributes, not_dumpable);
                ret = not_dumpable;
            }
            return ret;
        }
    }

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
    create (string inTag, string inId)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"tag: $inTag, id: $inId");
        Element? node = null;
        if (s_Factory != null)
        {
            unowned Create? create = s_Factory.search<string> (inTag, Create.compare_with_tag);
            if (create != null)
            {
                node = create.func (inId);

                // Add tag and characters in not dumpable attributes
                node.not_dumpable_attributes.insert ("tag");
                node.not_dumpable_attributes.insert ("characters");
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
            s_Factory = new Core.Set <Create> ();
        }

        GLib.Type type = inType;
        Create create = new Create (inNodeName, (i) => {
            return GLib.Object.new (type, id: GLib.Quark.from_string (i)) as Element;
        });
        s_Factory.insert (create);
    }

    // methods
    private bool
    get_attribute (string inName, out string outRet)
    {
        bool ret = false;
        outRet = null;

        // if attribute is dumpable
        if (!(inName in not_dumpable_attributes))
        {
            // Search property in object class
            string name = format_attribute_name (inName);
            unowned GLib.ParamSpec param = get_class ().find_property (name);
            Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"name: $name");

            // We found property which correspond to attribute name convert it to
            // string format
            if (param != null)
            {
                GLib.Value val = GLib.Value (param.value_type);
                get_property (name, ref val);

                if (!param.value_defaults (val))
                {
                    if (val.type () != typeof (string))
                    {
                        GLib.Value o = GLib.Value (typeof (string));
                        val.transform (ref o);
                        outRet = (string)o;
                    }
                    else
                    {
                        outRet = "'%s'".printf (((string)val).replace ("'", "\\'"));
                    }

                    ret = true;
                }
            }
        }

        return ret;
    }

    private void
    set_attribute (string inName, AttributeScanner inScanner) throws Error
    {
        // Search property in object class
        string name = format_attribute_name (inName);
        unowned GLib.ParamSpec param = get_class ().find_property (name);

        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"search name: $name");
        // We found property which correspond to attribute name convert value
        // to property type and set
        if (param != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"name: $name");
            // set property from attribute scanner
            set_property (name, inScanner.transform (param.value_type));
        }
    }

    /**
     * Load manifest for this object
     *
     * @param inManifest manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    read_manifest (Document inManifest) throws Core.ParseError
    {
        inManifest.owner = this;
        foreach (Core.Parser.Token token in inManifest)
        {
            switch (token)
            {
                // found a new child widget create it
                case Core.Parser.Token.START_ELEMENT:
                    Element element = create (inManifest.element_tag, inManifest.element_id);
                    if (element != null)
                    {
                        element.parent = this;
                        element.read_manifest (inManifest);
                        inManifest.owner = this;
                    }
                    break;

                // found an attribute set it
                case Core.Parser.Token.ATTRIBUTE:
                    if (inManifest.element_tag == tag)
                    {
                        try
                        {
                            set_attribute (inManifest.attribute, inManifest.scanner);
                        }
                        catch (Error err)
                        {
                            throw new Core.ParseError.PARSE ("Error on parse object %s attribute %s: %s", tag, inManifest.attribute, err.message);
                        }
                    }
                    break;

                // found characters
                case Core.Parser.Token.CHARACTERS:
                    if (inManifest.element_tag == tag)
                    {
                        characters = inManifest.characters;
                    }
                    break;

                // end of widget manifest quit
                case Core.Parser.Token.END_ELEMENT:
                    if (inManifest.element_tag == tag)
                    {
                        return;
                    }
                    break;

                // end of file
                case Core.Parser.Token.EOF:
                    return;
            }
        }
    }

    internal string
    dump_declaration ()
    {
        string ret = "";
        string attr;

        if (get_attribute ("id", out attr) && attr != null)
        {
            ret += "%s.%s".printf (tag, ((GLib.Quark)id).to_string ());
        }

        return ret;
    }

    internal string
    dump_attributes ()
    {
        string ret = "";

        // dump attributes
        foreach (unowned GLib.ParamSpec param in get_class ().list_properties ())
        {
            string param_name = param.get_name ();
            if (param_name != "id")
            {
                string attr;
                if (get_attribute (param_name, out attr) && attr != null)
                {
                    ret += "\t%s: %s;\n".printf (param_name, attr);
                }
            }
        }

        return ret;
    }

    internal string
    dump_childs ()
    {
        string ret = "";

        // dump childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Element)
            {
                string[] child_dump = (child as Element).dump ().split ("\n");
                foreach (unowned string line in child_dump)
                {
                    if (line != "")
                    {
                        ret += "\t" + line + "\n";
                    }
                }
            }
        }

        return ret;
    }

    internal string
    dump_characters ()
    {
        string ret = "";

        // dump characters
        if (characters != null)
        {
            string[] lines = characters.split ("\n");
            ret += "\t[\n";
            foreach (unowned string line in lines)
            {
                ret += "\t\t" + line.strip () + "\n";
            }
            ret +="\n\t]\n";
        }

        return ret;
    }

    public string
    dump ()
    {
        string ret = dump_declaration ();

        if (ret != "")
        {
            ret += " {\n";

            ret += dump_attributes ();

            ret += dump_childs ();

            ret += dump_characters ();

            ret += "}\n";
        }

        return ret;
    }
}

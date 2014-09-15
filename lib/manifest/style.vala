/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * style.vala
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

public class Maia.Manifest.Style : Core.Object, Element
{
    // types
    public class Property : Core.Object
    {
        // accessors
        public string name {
            get {
                return ((GLib.Quark)id).to_string ();
            }
        }
        public AttributeScanner scanner { get; set; default = null; }

        // methods
        public Property (string inName, AttributeScanner inScanner)
        {
            GLib.Object (id: GLib.Quark.from_string (inName), scanner: inScanner);
        }

        public Property copy ()
        {
            return new Property (name, scanner);
        }
    }

    // accessors
    internal string tag {
        get {
            return "Style";
        }
    }

    internal string characters     { get; set; default = null; }
    internal string style          { get; set; default = null; }
    internal string manifest_path  { get; set; default = null; }
    internal Theme  manifest_theme { get; set; default = null; }

    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public string match      { get; set; default = null; }
    public string match_name { get; set; default = null; }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("name");
    }

    public Style (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
    }

    internal void
    read_manifest (Document inManifest) throws Core.ParseError
    {
        inManifest.owner = this;
        foreach (Core.Parser.Token token in inManifest)
        {
            switch (token)
            {
                // found a new child ignore it
                case Core.Parser.Token.START_ELEMENT:
                    break;

                // found an attribute keep value in list
                case Core.Parser.Token.ATTRIBUTE:
                    if (inManifest.element_tag == tag)
                    {
                        // Found style accessors
                        if (inManifest.attribute.down () != "style"      &&
                            inManifest.attribute.down () != "match"      &&
                            inManifest.attribute.down () != "match-name" &&
                            inManifest.attribute.down () != "match_name")
                        {
                            Property property = new Property (inManifest.attribute, inManifest.scanner);
                            add (property);
                        }
                        else
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
                    }
                    break;

                // found characters ignore it
                case Core.Parser.Token.CHARACTERS:
                    break;

                // end of widget manifest quit
                case Core.Parser.Token.END_ELEMENT:
                    if (inManifest.element_tag == tag)
                    {
                        if (manifest_theme != null)
                        {
                            manifest_theme.apply (this);
                        }
                        return;
                    }
                    break;

                // end of file
                case Core.Parser.Token.EOF:
                    return;
            }
        }
    }

    internal override int
    compare (Core.Object inOther)
    {
        return 0;
    }

    internal string
    dump_childs (string inPrefix)
    {
        string ret = "";

        // dump all properties
        foreach (unowned Core.Object child in this)
        {
            unowned Property? property = child as Property;
            if (property != null)
            {
                try
                {
                    string val = (string)property.scanner.transform (typeof (string));
                    if (val != null)
                    {
                        ret += inPrefix + "%s: %s;\n".printf (property.name, val);
                    }
                }
                catch (GLib.Error err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"Error on parse object attribute $(property.name): $(err.message)");
                }
            }
        }

        return ret;
    }

    public bool
    matches (Element inElement)
    {
        if (match != null)
        {
            // Check if element tag match
            string[] tags = match.split (",");
            foreach (unowned string tag in tags)
            {
                if (tag.strip () == inElement.tag)
                {
                    return true;
                }
            }
        }

        if (match_name != null)
        {
            // Check if name match
            string[] patterns = match_name.split (",");
            foreach (unowned string pattern in patterns)
            {
                string[] ascendants = pattern.split (".");

                if (ascendants.length <= 1)
                {
                    if (GLib.PatternSpec.match_simple (pattern, ((GLib.Quark)inElement.id).to_string ()))
                    {
                        return true;
                    }
                }
                else
                {
                    bool found = true;
                    unowned Core.Object? current = inElement as Core.Object;
                    for (int cpt = ascendants.length - 1; cpt >= 0 && current != null; --cpt)
                    {
                        if (!GLib.PatternSpec.match_simple (ascendants[cpt], ((GLib.Quark)current.id).to_string ()))
                        {
                            found = false;
                            break;
                        }

                        current = current.parent;
                        if (cpt == 1 && ascendants[0].strip () == "" && current == null)
                        {
                            break;
                        }
                        else if (current == null && cpt >= 1)
                        {
                            found = false;
                            break;
                        }
                    }

                    return found;
                }
            }
        }

        return false;
    }
}

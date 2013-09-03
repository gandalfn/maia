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

    // properties
    private Core.Map<string, AttributeScanner> m_Attributes;

    // accessors
    internal string tag {
        get {
            return "Style";
        }
    }

    internal string characters { get; set; default = null; }

    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    // methods
    construct
    {
        m_Attributes = new Core.Map<string, AttributeScanner> ();
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
                        if (inManifest.attribute == "style")
                        {
                            try
                            {
                                // Add all style property in this style
                                string style_name = (string)inManifest.scanner.transform (typeof (string));
                                unowned Style? style = inManifest.get_style (style_name);
                                foreach (unowned Core.Object child in style)
                                {
                                    Property property = child as Property;
                                    if (property != null)
                                    {
                                        add (property.copy ());
                                    }
                                }
                            }
                            catch (Manifest.Error err)
                            {
                                Log.error (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, "Error on read style %s", err.message);
                            }
                        }
                        else
                        {
                            Property property = new Property (inManifest.attribute, inManifest.scanner);
                            add (property);
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
                        return;
                    }
                    break;

                // end of file
                case Core.Parser.Token.EOF:
                    return;
            }
        }
    }
}

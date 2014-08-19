/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * theme.vala
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

public class Maia.Manifest.Theme : Core.Object, Element
{
    // accessors
    internal string tag {
        get {
            return "Theme";
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

    // static methods
    public static Theme?
    create_from_file (string inFilename) throws Core.ParseError
    {
        Document doc = new Document (inFilename);
        Element? item = doc.get ();
        if (item != null)
        {
            Core.List<Theme> list = item.find_by_type<Theme> ();

            return list.length > 0 ? list.first ().ref () as Theme : null;
        }

        return null;
    }

    // methods
    public Theme (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
    }

    private Style[]
    get_styles (Element inElement)
    {
        Style[] ret = {};

        foreach (unowned Core.Object? child in this)
        {
            unowned Style? style = child as Style;
            if (style != null)
            {
                if (style.matches (inElement))
                {
                    ret += style;
                }
                else if (style.name == inElement.style)
                {
                    ret += style;
                }
            }
        }

        return ret;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Style;
    }

    /**
     * Apply theme to element
     *
     * @param inElement element on theme must be apply on
     */
    public void
    apply (Element inElement) throws Core.ParseError
    {
        if (inElement is Style)
        {
            unowned Style? style = inElement as Style;
            if (style.style != null)
            {
                unowned Style? inherit = find (GLib.Quark.from_string (style.style), false) as Style;
                if (inherit != null)
                {
                    foreach (unowned Core.Object child in inherit)
                    {
                        Style.Property property = child as Style.Property;
                        if (property != null)
                        {
                            style.add (property.copy ());
                        }
                    }
                }
            }
        }
        else if (!(inElement is Theme))
        {
            inElement.manifest_theme = this;

            foreach (unowned Style style in get_styles (inElement))
            {
                foreach (unowned Core.Object child in style)
                {
                    unowned Style.Property? property = child as Style.Property;
                    if (property != null)
                    {
                        try
                        {
                            unowned Core.Set<string>? attributes_set = inElement.get_qdata<unowned Core.Set<string>> (Element.s_AttributeSetQuark);

                            if (attributes_set != null && property.name in attributes_set)
                                continue;

                            inElement.set_attribute (property.name, property.scanner);
                        }
                        catch (Error err)
                        {
                            throw new Core.ParseError.PARSE ("Error on parse object %s attribute %s: %s", tag, property.name, err.message);
                        }
                    }
                }
            }

            if (inElement is Popup)
            {
                unowned Element? child_element = (inElement as Popup).content as Element;
                if (child_element != null && child_element.manifest_theme == null)
                {
                    apply (child_element);
                }
            }
            else if (!(inElement is ChartView))
            {
                // Appply theme in all child
                foreach (unowned Core.Object child in ((Core.Object)inElement))
                {
                    unowned Element child_element = child as Element;

                    // if child theme is not same than theme apply theme
                    if (child_element != null && child_element.manifest_theme == null)
                    {
                        apply (child_element);
                    }
                }
            }
        }
    }
}

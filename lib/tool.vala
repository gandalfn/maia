/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tool.vala
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

public enum Maia.ToolAction
{
    NONE,
    ADD,
    ADD_PARENT,
    REMOVE;

    public string
    to_string ()
    {
        switch (this)
        {
            case ADD:
                return "add";
            case ADD_PARENT:
                return "add-parent";
            case REMOVE:
                return "remove";
        }

        return "none";
    }

    public static ToolAction
    from_string (string inValue)
    {
        switch (inValue)
        {
            case "add":
                return ADD;

            case "add-parent":
                return ADD_PARENT;

            case "remove":
                return REMOVE;
        }

        return NONE;
    }
}

public class Maia.Tool : Button
{
    // static properties
    private static unowned Item? s_CurrentItem = null;

    // properties
    private Manifest.Document m_Document = null;
    private uint m_ItemCounter = 0;
    private unowned Toolbox? m_Toolbox = null;

    // accessors
    internal override string tag {
        get {
            return "Tool";
        }
    }

    public unowned Toolbox? toolbox {
        get {
            return m_Toolbox;
        }
    }

    public ToolAction action { get; set; default = ToolAction.NONE; }
    public string sensitive_with { get; set; default = null; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (ToolAction), attribute_to_tool_action);

        GLib.Value.register_transform_func (typeof (ToolAction), typeof (string), tool_action_to_string);

        // register attribute bind
        Manifest.AttributeBind.register_transform_func (typeof (Item), "selected-item-name", attribute_bind_selected_item_name);
    }

    static void
    attribute_to_tool_action (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = ToolAction.from_string (inAttribute.get ());
    }

    static void
    tool_action_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (ToolAction)))
    {
        ToolAction val = (ToolAction)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_bind_selected_item_name (Manifest.AttributeBind inAttributeBind, ref GLib.Value outValue)
        requires (outValue.holds (typeof (string)))
    {
        if (s_CurrentItem != null)
        {
            outValue = s_CurrentItem.name;
        }
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("toolbox");

        // Connect onto clicked signal
        clicked.connect (on_clicked);

        // Connect onto root changed
        notify["root"].connect (on_root_changed);
    }

    public Tool (string inId, string? inLabel = null)
    {
        base (inId, inLabel);
    }

    private void
    on_root_changed ()
    {
        // Disconnect from item changed of old toolbox
        if (m_Toolbox != null)
        {
            m_Toolbox.current_item_changed.disconnect (on_current_item_changed);
        }

        // Search parent toolbox
        m_Toolbox = null;
        for (unowned Core.Object? item = parent; m_Toolbox == null && item != null; item = item.parent)
        {
            m_Toolbox = item as Toolbox;
        }

        // Found toolbox connect onto item changed
        if (m_Toolbox != null)
        {
            m_Toolbox.current_item_changed.connect (on_current_item_changed);
        }
    }

    private Item?
    create_template ()
    {
        // parse template
        try
        {
            if (m_Document == null && characters != null && characters.length > 0)
            {
                m_Document = new Manifest.Document.from_buffer (characters, characters.length);
            }

            if (m_Document != null)
            {
                Item? item = m_Document.get (null) as Item;

                if (item != null)
                {
                    item.id = GLib.Quark.from_string ("%s-%s-%u".printf (name, item.name, m_ItemCounter));
                    m_ItemCounter++;
                }

                return item;
            }
        }
        catch (Core.ParseError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                          "Error on parsing tool template %s: %s", name, err.message);
        }

        return null;
    }

    private void
    on_current_item_changed (Item? inItem)
    {
        s_CurrentItem = inItem;

        if (sensitive_with != null)
        {
            if (inItem != null)
            {
                bool found = false;
                string item_name = inItem.name;
                string[] split = sensitive_with.split (",");

                foreach (unowned string criteria in split)
                {
                    string[] split_criteria = criteria.split (":");
                    if (split_criteria.length == 2)
                    {
                        switch (split_criteria[0].strip ().down ())
                        {
                            case "name":
                                found = GLib.PatternSpec.match_simple (split_criteria[1].strip ().down (), item_name);
                                break;

                            case "parent-name":
                                found = parent != null && parent is Item && GLib.PatternSpec.match_simple (split_criteria[1].strip ().down (), (parent as Item).name);
                                break;

                            case "type":
                                GLib.Type type = GLib.Type.from_name ("Maia" + split_criteria[1].strip ());

                                found = type != 0 && inItem.get_type ().is_a (type);
                                break;

                            case "parent-type":
                                GLib.Type type = GLib.Type.from_name ("Maia" + split_criteria[1].strip ());

                                found = inItem.parent != null && type != 0 && inItem.parent.get_type ().is_a (type);
                                break;

                            default:
                                Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                                              "Invalid visible-with criteria %s for %s", criteria, name);
                                break;
                        }
                    }
                    else
                    {
                        Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                                      "Invalid visible-with criteria %s for %s", criteria, name);
                    }
                }

                sensitive = found;
            }
            else
            {
                sensitive = false;
            }
        }
        else
        {
            sensitive = true;
        }

        damage ();
    }

    private void
    on_clicked ()
    {
        // parent toolbox was found
        if (toolbox != null)
        {
            switch (action)
            {
                case ToolAction.ADD:
                    // Create item from template
                    Item? item = create_template ();
                    if (item != null)
                    {
                        // Launch toolbox add signal
                        toolbox.add_item (item, false);
                        toolbox.hide ();
                    }
                    break;

                case ToolAction.ADD_PARENT:
                    // Create item from template
                    Item? item = create_template ();
                    if (item != null)
                    {
                        // Launch toolbox add signal
                        toolbox.add_item (item, true);
                        toolbox.hide ();
                    }
                    break;

                case ToolAction.REMOVE:
                    // Launch toolbox remove signal
                    toolbox.remove_item ();
                    toolbox.hide ();
                    break;
            }
        }
    }

    internal override void
    on_show ()
    {
        damage ();
    }

    internal override void
    on_hide ()
    {
        damage ();
    }

    internal override string
    dump_characters (string inPrefix)
    {
        string ret = "";

        // parse template
        try
        {
            if (m_Document == null && characters != null && characters.length > 0)
            {
                m_Document = new Manifest.Document.from_buffer (characters, characters.length);
            }

            if (m_Document != null)
            {
                Item? item = m_Document.get (null) as Item;

                if (item != null)
                {
                    ret += inPrefix + "[\n";
                    ret += inPrefix + "\t" + item.dump (inPrefix + "\t");
                    ret += inPrefix + "]\n";
                }
            }
        }
        catch (Core.ParseError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                          "Error on parsing cell %s: %s", name, err.message);
        }

        return ret;
    }
}

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
    REMOVE;

    public string
    to_string ()
    {
        switch (this)
        {
            case ADD:
                return "add";
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

            case "remove":
                return REMOVE;
        }

        return NONE;
    }
}

public class Maia.Tool : Button
{
    // static properties
    static GLib.Quark s_CurrentItemChangedQuark;

    // properties
    private Manifest.Document m_Document = null;
    private uint m_ItemCounter = 0;

    // accessors
    internal override string tag {
        get {
            return "Tool";
        }
    }

    [CCode (notify = false)]
    public override unowned Core.Object? parent {
        get {
            return base.parent;
        }
        construct set {
            ulong id_changed = get_qdata<ulong> (s_CurrentItemChangedQuark);
            if (id_changed != 0 && toolbox != null)
            {
                GLib.SignalHandler.disconnect (toolbox, id_changed);
            }

            base.parent = value;

            if (toolbox != null)
            {
                id_changed = toolbox.current_item_changed.connect (on_current_item_changed);
                set_qdata<ulong> (s_CurrentItemChangedQuark, id_changed);
            }
        }
    }

    public unowned Toolbox? toolbox {
        get {
            for (unowned Core.Object? item = parent; item != null; item = item.parent)
            {
                if (item is Toolbox)
                    return item as Toolbox;
            }

            return null;
        }
    }

    public ToolAction action { get; set; default = ToolAction.NONE; }
    public string visible_with { get; set; default = null; }

    // static methods
    static construct
    {
        s_CurrentItemChangedQuark = GLib.Quark.from_string ("MaiaToolCurrentItemChanged");

        Manifest.Attribute.register_transform_func (typeof (ToolAction), attribute_to_tool_action);

        GLib.Value.register_transform_func (typeof (ToolAction), typeof (string), tool_action_to_string);
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

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("toolbox");

        // Connect onto clicked signal
        clicked.connect (on_clicked);
    }

    public Tool (string inId, string? inLabel = null)
    {
        base (inId, inLabel);
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
        if (visible_with != null)
        {
            if (inItem != null)
            {
                string item_name = inItem.name;
                string[] split = visible_with.split (",");
                foreach (unowned string criteria in split)
                {
                    string[] split_criteria = criteria.split (":");
                    if (split_criteria.length == 2)
                    {
                        switch (split_criteria[0].strip ().down ())
                        {
                            case "name":
                                if (GLib.PatternSpec.match_simple (split_criteria[1].strip ().down (), item_name))
                                {
                                    visible = true;
                                    return;
                                }
                                break;

                            case "type":
                                GLib.Type type = GLib.Type.from_name ("Maia" + split_criteria[1].strip ());

                                if (type != 0 && inItem.get_type ().is_a (type))
                                {
                                    visible = true;
                                    return;
                                }
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

                visible = false;
            }
            else
            {
                visible = false;
            }
        }
        else
        {
            visible = true;
        }
    }

    private void
    on_clicked ()
    {
        // Search parent toolbox
        unowned Toolbox? tb = toolbox;

        // parent toolbox was found
        if (tb != null)
        {
            switch (action)
            {
                case ToolAction.ADD:
                    // Create item from template
                    Item? item = create_template ();
                    if (item != null)
                    {
                        // Launch toolbox add signal
                        tb.add_item (item);
                    }
                    break;

                case ToolAction.REMOVE:
                    // Launch toolbox remove signal
                    tb.remove_item ();
                    break;
            }
        }
    }
}

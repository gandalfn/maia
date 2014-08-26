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
        switch (inValue.down ())
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
    private static string? s_CurrentItemName = null;

    // properties
    private uint                m_ItemCounter = 0;
    private unowned Toolbox?    m_Toolbox = null;
    private Core.EventListener  m_CurrentItemEventListener = null;

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
        if (s_CurrentItemName != null)
        {
            outValue = s_CurrentItemName;
        }
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("toolbox");

        // Connect onto clicked signal
        clicked.subscribe (on_clicked);

        // Connect onto root changed
        notify["root"].connect (on_root_changed);
    }

    public Tool (string inId, string? inLabel = null)
    {
        base (inId, inLabel);
    }

    ~Tool ()
    {
        if (m_CurrentItemEventListener != null)
        {
            m_CurrentItemEventListener.parent = null;
        }
    }

    private void
    on_root_changed ()
    {
        // Search parent toolbox
        unowned Toolbox? toolbox = null;
        for (unowned Core.Object? item = parent; toolbox == null && item != null; item = item.parent)
        {
            toolbox = item as Toolbox;

            if (toolbox == null)
            {
                // Check if item is under popup
                unowned Core.Object? popup = item.get_qdata<unowned Core.Object?> (Item.s_PopupWindow);
                if (popup != null)
                {
                    toolbox = popup as Toolbox;
                    item = popup;
                }
            }
        }

        if (toolbox != m_Toolbox)
        {
            // Disconnect from item changed of old toolbox
            if (m_Toolbox != null && m_CurrentItemEventListener != null)
            {
                m_CurrentItemEventListener.parent = null;
                m_CurrentItemEventListener = null;
            }

            m_Toolbox = toolbox;

            // Found toolbox connect onto item changed
            if (m_Toolbox != null && m_Toolbox.current_item != null)
            {
                m_CurrentItemEventListener = m_Toolbox.current_item.subscribe (on_current_item_changed);
            }
        }
    }

    private void
    on_current_item_changed (Core.EventArgs? inArgs)
    {
        unowned Toolbox.CurrentItemEventArgs? args = inArgs as Toolbox.CurrentItemEventArgs;

        if (args != null)
        {
            s_CurrentItemName = args.item_name;

            if (sensitive_with != null)
            {
                if (args.item_name.length > 0)
                {
                    bool found = false;
                    string[] split = sensitive_with.split (",");

                    foreach (unowned string criteria in split)
                    {
                        string[] split_criteria = criteria.split (":");
                        if (split_criteria.length == 2)
                        {
                            string cmd = split_criteria[0].strip ().down ();
                            string val = split_criteria[1].strip ();

                            switch (cmd)
                            {
                                case "name":
                                    found = GLib.PatternSpec.match_simple (val, args.item_name);
                                    break;

                                case "parent-name":
                                    found = args.parent_name.length > 0 && GLib.PatternSpec.match_simple (val, args.parent_name);
                                    break;

                                case "type":
                                    GLib.Type type = GLib.Type.from_name (@"Maia$val");

                                    found = type != 0 && args.item_type.is_a (type);
                                    break;

                                case "parent-type":
                                    GLib.Type type = GLib.Type.from_name (@"Maia$val");

                                    found = args.parent_type != 0 && args.parent_type.is_a (type);
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
    }

    private void
    on_clicked (Core.EventArgs? inArgs)
    {
        // parent toolbox was found
        if (toolbox != null)
        {
            switch (action)
            {
                case ToolAction.ADD:
                    if (characters != null && characters.length > 0)
                    {
                        // Launch toolbox add event
                        toolbox.add_item.publish (new Toolbox.AddItemEventArgs (++m_ItemCounter, characters, false));
                        toolbox.visible = false;
                    }
                    break;

                case ToolAction.ADD_PARENT:
                    if (characters != null && characters.length > 0)
                    {
                        // Launch toolbox add event
                        toolbox.add_item.publish (new Toolbox.AddItemEventArgs (++m_ItemCounter, characters, true));
                        toolbox.visible = false;
                    }
                    break;

                case ToolAction.REMOVE:
                    // Launch toolbox remove event
                    toolbox.remove_item.publish ();
                    toolbox.visible = false;
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
            if (characters != null && characters.length > 0)
            {
                var document = new Manifest.Document.from_buffer (characters, characters.length);
                Item? item = document.get (null) as Item;

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

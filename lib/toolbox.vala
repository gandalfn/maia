/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * toolbox.vala
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

public class Maia.Toolbox : Popup
{
    // type
    public class AddItemEventArgs : Core.EventArgs
    {
        // properties
        private uint   m_Counter;
        private string m_ItemContent;
        private bool   m_Parent;

        // accessors
        internal override GLib.Variant serialize {
            owned get {
                return new GLib.Variant ("(usb)", m_Counter, m_ItemContent, m_Parent);
            }
            set {
                if (value != null)
                {
                    value.get ("(usb)", out m_Counter, out m_ItemContent, out m_Parent);
                }
            }
        }

        /**
         * Item to add
         */
        public Item? item {
            owned get {
                Item? ret = null;
                try
                {
                    if (m_ItemContent != null && m_ItemContent.length > 0)
                    {
                        var document = new Manifest.Document.from_buffer (m_ItemContent, m_ItemContent.length);
                    
                        if (document != null)
                        {
                            ret = document.get (null) as Item;

                            if (ret != null)
                            {
                                ret.id = GLib.Quark.from_string (@"$(ret.name)-$(m_Counter)");
                            }
                        }
                    }
                }
                catch (GLib.Error err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Error on get item: $(err.message)");
                }

                return ret;
            }
        }

        /**
         * Add item to parent
         */
        public bool parent {
            get {
                return m_Parent;
            }
        }

        // methods
        internal AddItemEventArgs (uint inCounter, string inItemContent, bool inParent)
        {
            base ();

            m_Counter = inCounter;
            m_ItemContent = inItemContent;
            m_Parent = inParent;
        }
    }

    public class CurrentItemEventArgs : Core.EventArgs
    {
        // properties
        private string    m_ItemName = "";
        private GLib.Type m_ItemType = 0;
        private string    m_ParentName = "";
        private GLib.Type m_ParentType = 0;

        // accessors
        internal override GLib.Variant serialize {
            owned get {
                return new GLib.Variant ("(susu)", m_ItemName, m_ItemType, m_ParentName, m_ParentType);
            }
            set {
                if (value != null)
                {
                    value.get ("(susu)", out m_ItemName, out m_ItemType, out m_ParentName, out m_ParentType);
                }
            }
        }

        /**
         * Current item name
         */
        public string item_name {
            owned get {
                return m_ItemName ?? "";
            }
        }

        /**
         * Current item type
         */
        public GLib.Type item_type {
            get {
                return m_ItemType;
            }
        }

        /**
         * Current item parent name
         */
        public string parent_name {
            owned get {
                return m_ParentName ?? "";
            }
        }

        /**
         * Current item parent type
         */
        public GLib.Type parent_type {
            get {
                return m_ParentType;
            }
        }

        // methods
        internal CurrentItemEventArgs (Item? inItem)
        {
            base ();

            if (inItem != null)
            {
                m_ItemName = inItem.name;
                m_ItemType = inItem.get_type ();

                var parent = inItem.parent as Item;
                if (parent != null)
                {
                    m_ParentName = parent.name;
                    m_ParentType = parent.get_type ();
                }
            }
        }
    }

    // accessors
    internal override string tag {
        get {
            return "Toolbox";
        }
    }

    // signals
    /**
     * Event emitted when a tool button with add or add-parent action
     * is pressed
     */
    public Core.Event add_item { get; private set; }

    /**
     * Event emitted when a tool button with remove action is pressed
     */
    public Core.Event remove_item { get; private set; }

    /**
     * Event emitted when the current focus item has changed
     */
    public Core.Event current_item { get; private set; }

    // methods
    construct
    {
        // Create grid content
        Grid grid = new Grid ("%s-content".printf (((GLib.Quark)id).to_string ()));
        add (grid);

        // Create add item event
        add_item = new Core.Event ("add-item", this);

        // Create remove item event
        remove_item = new Core.Event ("remove-item", this);

        // Create current item event
        current_item = new Core.Event ("current-item", this);
    }

    public Toolbox (string inId)
    {
        base (inId);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return content == null ? base.can_append_child (inObject) : (content as Grid).can_append_child (inObject);
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (content != null)
        {
            (content as Grid).insert_child (inObject);
        }
        else
        {
            base.insert_child (inObject);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject != content)
        {
            (content as Grid).remove_child (inObject);
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        if (content != null)
        {
            ret += (content as Item).dump_childs (inPrefix);
        }

        return ret;
    }
}

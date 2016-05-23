/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * togglegroup.vala
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

public class Maia.ToggleGroup : Core.Object, Manifest.Element
{
    // type
    public class ChangedEventArgs : Core.EventArgs
    {
        // properties
        private string m_Active;

        // accessors
        [CCode (notify = false)]
        internal override GLib.Variant serialize {
            owned get {
                return new GLib.Variant ("(s)", m_Active);
            }
            set {
                if (value != null)
                {
                    value.get ("(s)", out m_Active);
                }
            }
        }

        /**
         * Active item name
         */
        public string active {
            get {
                return m_Active;
            }
        }

        // methods
        internal ChangedEventArgs (string inItemName)
        {
            base ();

            m_Active = inItemName;
        }
    }

    // properties
    private Core.Map<string, unowned Toggle> m_Toggles;
    private Core.Map<string, Core.EventListener> m_ToggleListeners;
    private string m_Active = "";
    private bool m_HideAllIfNoActive = false;

    // accessors
    internal string tag {
        get {
            return "ToggleGroup";
        }
    }

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    [CCode (notify = false)]
    public string active {
        get {
            return m_Active;
        }
        set {
            if (m_Active != value)
            {
                m_Active = value;

                if (m_Toggles != null)
                {
                    foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
                    {
                        if (m_Active != pair.first)
                        {
                            if (pair.second.active)
                            {
                                m_ToggleListeners[pair.first].block_next_nb_events++;
                                pair.second.active = false;
                            }
                        }
                        else
                        {
                            if (!pair.second.active)
                            {
                                m_ToggleListeners[pair.first].block_next_nb_events++;
                                pair.second.active = true;
                            }
                        }
                    }

                    check_hide_if_noactive ();
                    check_listeners ();
                }

                if (changed != null && m_Active != null)
                {
                    changed.publish (new ChangedEventArgs (m_Active));
                }
            }
        }
    }

    [CCode (notify = false)]
    public bool hideall_if_noactive {
        get {
            return m_HideAllIfNoActive;
        }
        set {
            if (m_HideAllIfNoActive != value)
            {
                m_HideAllIfNoActive = value;
                check_hide_if_noactive ();
            }
        }
    }

    public bool exclusive { get; set; default = false; }

    public GLib.List<unowned Toggle> toggles {
        owned get {
            GLib.List<unowned Toggle> ret = new GLib.List<unowned Toggle> ();
            foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
            {
                ret.prepend (pair.second);
            }

            return ret;
        }
    }

    // events
    /**
     * Event emitted when the active item changed
     * is pressed
     */
    public Core.Event changed { get; private set; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (ToggleGroup), attribute_to_toggle_group);

        GLib.Value.register_transform_func (typeof (ToggleGroup), typeof (string), toggle_group_to_value_string);
    }

    static void
    attribute_to_toggle_group (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        unowned Core.Object object = inAttribute.owner as Core.Object;
        unowned ToggleGroup? group = null;

        GLib.Quark id  = GLib.Quark.from_string (inAttribute.get ());
        for (unowned Core.Object item = object; item != null; item = item.parent)
        {
            unowned View? view = item.parent as View;

            // If owned is in view search model in cell first
            if (view != null)
            {
                group = item.find (id, false) as ToggleGroup;
                if (group != null) break;
            }
            // We not found model in view parents search in root
            else if (item.parent == null)
            {
                group = item.find (id) as ToggleGroup;
            }
        }

        outValue = group;
    }

    static void
    toggle_group_to_value_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (ToggleGroup)))
    {
        unowned ToggleGroup val = (ToggleGroup)inSrc;

        outDest = val.name;
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("name");

        // Create event changed
        changed = new Core.Event ("changed", this);

        // Create toggle button dictionnary
        m_Toggles = new Core.Map<string, unowned Toggle> ();

        // Create event listener map
        m_ToggleListeners = new Core.Map<string, Core.EventListener> ();
    }

    public ToggleGroup (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    ~ToggleGroup ()
    {
        foreach (unowned Core.Pair<string, Core.EventListener> pair in m_ToggleListeners)
        {
            pair.second.parent = null;
        }

    }

    private void
    check_listeners ()
    {
        foreach (unowned Core.Pair<string, Core.EventListener> pair in m_ToggleListeners)
        {
            if (pair.second.ref_count == 1)
            {
                if (pair.first in m_Toggles)
                {
                    pair.second = m_Toggles[pair.first].toggled.subscribe (on_toggled);
                }
            }
        }
    }

    private void
    check_hide_if_noactive ()
    {
        if (m_Toggles != null)
        {
            bool found = false;
            foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
            {
                if (pair.second.active)
                {
                    found = true;
                    break;
                }
            }

            if (m_HideAllIfNoActive)
            {
                foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
                {
                    if (pair.second.visible && !found)
                    {
                        pair.second.visible = false;
                        int count = pair.second.get_qdata<int> (Item.s_CountHide);
                        count++;
                        pair.second.set_qdata<int> (Item.s_CountHide, count);
                        pair.second.not_dumpable_attributes.insert ("visible");
                    }
                    else if (found && !pair.second.visible)
                    {
                        int count = pair.second.get_qdata<int> (Item.s_CountHide);
                        count = int.max (count - 1, 0);
                        if (count == 0)
                        {
                            pair.second.visible = true;
                            pair.second.not_dumpable_attributes.remove ("visible");
                        }
                        pair.second.set_qdata<int> (Item.s_CountHide, count);
                    }
                }
            }
        }
    }

    private void
    on_toggled (Core.EventArgs? inArgs)
    {
        unowned Toggle.ToggledEventArgs? args = inArgs as Toggle.ToggledEventArgs;

        if (args != null)
        {
            if (args.active && args.button_name != null && m_Active != args.button_name)
            {
                m_Active = args.button_name;
                foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
                {
                    if (pair.first != args.button_name)
                    {
                        if (pair.second.active)
                        {
                            m_ToggleListeners[pair.first].block_next_nb_events++;
                            pair.second.active = false;
                        }
                    }
                }

                changed.publish (new ChangedEventArgs (m_Active));
            }
            else if (!args.active && m_Active == args.button_name)
            {
                m_Active = "";

                changed.publish (new ChangedEventArgs (m_Active));
            }

            check_listeners ();

            check_hide_if_noactive ();
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override int
    compare (Core.Object inOther)
    {
        int ret =  0;

        if (inOther is Item)
        {
            // Item always after
            ret = -1;
        }
        else
        {
            ret = base.compare (inOther);
        }

        return ret;
    }

    public void
    add_button (Toggle inButton)
    {
        if (!(inButton.name in m_Toggles))
        {
            string button_name = inButton.name;
            m_Toggles[button_name] = inButton;
            m_ToggleListeners[button_name] = inButton.toggled.subscribe (on_toggled);

            if (active != null && active == inButton.name)
            {
                if (!inButton.active)
                {
                    m_ToggleListeners[inButton.name].block_next_nb_events++;
                    inButton.active = true;
                }
            }
            else
            {
                if (inButton.active)
                {
                    m_ToggleListeners[inButton.name].block_next_nb_events++;
                    inButton.active = false;
                }
            }

            check_hide_if_noactive ();
            check_listeners ();
        }
        else
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_PARSING, "Duplicate toggle button %s in %s group", inButton.name, name);
        }
    }

    public void
    remove_button (Toggle inButton)
    {
        if (inButton.name in m_Toggles)
        {
            m_Toggles.unset (inButton.name);
            m_ToggleListeners[inButton.name].parent = null;
            m_ToggleListeners.unset (inButton.name);

            check_hide_if_noactive ();
            check_listeners ();
        }
    }
}

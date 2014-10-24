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
    // properties
    private Core.Map<string, unowned Toggle> m_Toggles;
    private Core.Map<string, Core.EventListener> m_ToggleListeners;
    private string m_Active = null;
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
                        m_ToggleListeners[pair.first].block = true;
                        {
                            if (m_Active != pair.first)
                            {
                                pair.second.active = false;
                            }
                            else
                            {
                                pair.second.active = true;
                            }
                        }
                        m_ToggleListeners[pair.first].block = false;
                    }

                    check_hide_if_noactive ();
                }
            }
        }
        default = null;
    }

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

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("name");

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

            foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
            {
                if (m_HideAllIfNoActive && pair.second.visible && !found)
                {
                    pair.second.visible = false;
                    int count = pair.second.get_qdata<int> (Item.s_CountHide);
                    count++;
                    pair.second.set_qdata<int> (Item.s_CountHide, count);
                    pair.second.not_dumpable_attributes.insert ("visible");
                }
                else if (((m_HideAllIfNoActive && found) || !m_HideAllIfNoActive) && !pair.second.visible)
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

    private void
    on_toggled (Core.EventArgs? inArgs)
    {
        unowned Toggle.ToggledEventArgs? args = inArgs as Toggle.ToggledEventArgs;

        if (args != null)
        {
            if (args.active)
            {
                m_Active = args.button_name;
                foreach (unowned Core.Pair<string, unowned Toggle> pair in m_Toggles)
                {
                    if (pair.first != args.button_name)
                    {
                        pair.second.active = false;
                    }
                }
            }

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
            m_Toggles[inButton.name] = inButton;
            m_ToggleListeners[inButton.name] = inButton.toggled.subscribe (on_toggled);

            if (active != null && active == inButton.name)
            {
                inButton.active = true;
            }
            else
            {
                inButton.active = false;
            }

            check_hide_if_noactive ();
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
            m_ToggleListeners[inButton.name].parent = null;
            m_ToggleListeners.unset (inButton.name);
            m_Toggles.unset (inButton.name);

            check_hide_if_noactive ();
        }
    }
}

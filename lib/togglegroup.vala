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
    private Core.Map<string, unowned ToggleButton> m_ToggleButtons;
    private Core.Map<string, Core.EventListener> m_ToggleButtonListeners;
    
    // accessors
    internal string tag {
        get {
            return "ToggleGroup";
        }
    }

    internal string characters { get; set; default = null; }
    internal string manifest_path { get; set; default = null; }
    internal Core.Set<Manifest.Style> manifest_styles { get; set; default = null; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public string active { get; set; default = null; }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("name");

        // Create toggle button dictionnary
        m_ToggleButtons = new Core.Map<string, unowned ToggleButton> ();

        // Create event listener map
        m_ToggleButtonListeners = new Core.Map<string, Core.EventListener> ();
    }

    private void
    on_toggled (Core.EventArgs? inArgs)
    {
        unowned ToggleButton.ToggledEventArgs? args = inArgs as ToggleButton.ToggledEventArgs;
        
        if (args != null && args.active)
        {
            foreach (unowned Core.Pair<string, unowned ToggleButton> pair in m_ToggleButtons)
            {
                if (pair.first != args.button_name)
                {
                    pair.second.active = false;
                }
            }
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
    add_button (ToggleButton inButton)
    {
        if (!(inButton.name in m_ToggleButtons))
        {
            m_ToggleButtons[inButton.name] = inButton;
            m_ToggleButtonListeners[inButton.name] = inButton.toggled.subscribe (on_toggled);
            
            if (active != null && active == inButton.name)
            {
                inButton.active = true;
            }
            else
            {
                inButton.active = false;
            }
        }
        else
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_PARSING, "Duplicate toggle button %s in %s group", inButton.name, name);
        }
    }

    public void
    remove_button (ToggleButton inButton)
    {
        if (inButton.name in m_ToggleButtons)
        {
            m_ToggleButtonListeners.unset (inButton.name);
            m_ToggleButtons.unset (inButton.name);
        }
    }
}

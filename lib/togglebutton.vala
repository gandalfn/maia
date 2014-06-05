/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * togglebutton.vala
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

public abstract class Maia.ToggleButton : Group, ItemPackable, ItemMovable
{
    /**
     * Event args provided by togglebuttion on toggled event
     */
    public class ToggledEventArgs : Core.EventArgs
    {
        // properties
        private string m_ButtonName;
        private bool m_Active;

        // accessors
        internal override GLib.Variant serialize {
            owned get {
                return new GLib.Variant ("(sb)", m_ButtonName, m_Active);
            }
            set {
                if (value != null)
                {
                    value.get ("(sb)", out m_ButtonName, out m_Active);
                }
                else
                {
                    m_Active = false;
                }
            }
        }

        /**
         * Button name where the event appear
         */
        public string button_name {
            get {
                return m_ButtonName;
            }
        }
        
        /**
         * Active state on toggled event
         */
        public bool active {
            get {
                return m_Active;
            }
        }

        // methods
        internal ToggledEventArgs (string inButtonName, bool inActive)
        {
            base ();

            m_ButtonName = inButtonName;
            m_Active = inActive;
        }
    }

    // properties
    private string m_Group = null;
    private bool m_Active = false;

    // accessors
    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    public string group {
        get {
            return m_Group;
        }
        set {
            m_Group = value;
            unowned ToggleGroup? toggle_group = root.find (GLib.Quark.from_string (m_Group)) as ToggleGroup;
            if (toggle_group != null)
            {
                toggle_group.add_button (this);
            }
            else
            {
                Log.warning ("Maia.ToggleButton.group", Log.Category.CANVAS_PARSING, "%s can not find %s group", name, m_Group);
            }
        }
    }

    public string font_description {
        get {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            return label_item == null ? "" : label_item.font_description;
        }
        set {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            if (label_item != null)
            {
                label_item.font_description = value;
            }
        }
    }

    public string label {
        get {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            return label_item == null ? "" : label_item.text;
        }
        set {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            if (label_item != null)
            {
                label_item.text = value;
            }
        }
    }

    public bool active {
        get {
            return m_Active;
        }
        set {
            if (m_Active != value)
            {
                m_Active = value;
                damage ();
            }
        }
    }

    // signals
    public Core.Event toggled { get; private set; }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("size");

        toggled = new Core.Event ("toggled", this);

        string id_label = "%s-label".printf (name);

        var label_item = new Label (id_label, label);
        add (label_item);

        notify["stroke-pattern"].connect (on_stroke_pattern_changed);

        label_item.button_press_event.connect (on_button_press);

        button_press_event.connect (on_button_press);
    }

    public ToggleButton (string inId, string inLabel)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), label: inLabel);
    }

    ~ToggleButton ()
    {
        if (m_Group != null)
        {
            unowned ToggleGroup? toggle_group = root.find (GLib.Quark.from_string (m_Group)) as ToggleGroup;
            if (toggle_group != null)
            {
                toggle_group.remove_button (this);
            }
        }
    }

    private void
    on_stroke_pattern_changed ()
    {
        unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
        if (label_item != null)
        {
            label_item.stroke_pattern = stroke_pattern;
        }
    }

    private bool
    on_button_press (uint inButton, Graphic.Point inPoint)
    {
        if (inButton == 1)
        {
            active = !active;

            toggled.publish (new ToggledEventArgs (name, active));
        }

        return true;
    }

    internal override string
    dump_childs (string inPrefix)
    {
        return "";
    }
}

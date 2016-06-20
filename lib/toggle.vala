/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * toggle.vala
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

public abstract class Maia.Toggle : Group, ItemPackable, ItemMovable
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
        [CCode (notify = false)]
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
    private string         m_Group          = null;
    private ToggleGroup    m_ToggleGroup    = null;
    private bool           m_Active         = false;
    private unowned Item?  m_Content        = null;
    private bool           m_HideIfInactive = false;

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

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    /**
     * Toggle group name
     */
    [CCode (notify = false)]
    public string group {
        get {
            return m_Group;
        }
        set {
            if (m_Group != value)
            {
                m_Group = value;

                // Unset toggle group
                m_ToggleGroup = null;

                // Set and check toggle group
                if (toggle_group == null)
                {
                    Log.warning ("Maia.ToggleButton.group", Log.Category.CANVAS_PARSING, "%s can not find %s group", name, m_Group);
                }

                GLib.Signal.emit_by_name (this, "notify::group");
            }
        }
    }

    /**
     * Toggle group
     */
    public unowned ToggleGroup? toggle_group {
        get {
            if (m_ToggleGroup == null && m_Group != null && root != null)
            {
                m_ToggleGroup = root.find (GLib.Quark.from_string (m_Group)) as ToggleGroup;
                m_ToggleGroup.add_button (this);
            }

            return m_ToggleGroup;
        }
        set {
            if (m_ToggleGroup != value)
            {
                if (m_ToggleGroup != null)
                {
                    m_ToggleGroup.remove_button (this);
                }
                m_ToggleGroup = value;
                if (m_ToggleGroup != null)
                {
                    m_ToggleGroup.add_button (this);
                }
            }
        }
    }

    /**
     * The default font description of button label
     */
    public string font_description { get;  set; default = ""; }

    /**
     * Shade color of label
     */
    public Graphic.Color shade_color { get; set; default = null; }

    /**
     * The label of button
     */
    public string label { get; set; default = ""; }

    /**
     * The border around button content
     */
    public double border { get; set; default = 5.0; }

    /**
     * Indicate if the button is sensitive
     */
    public bool sensitive { get; set; default = true; }

    /**
     * Indicate if toggle is active
     */
    [CCode (notify = false)]
    public virtual bool active {
        get {
            return m_Active;
        }
        set {
            if (m_Active != value)
            {
                m_Active = value;
                state = m_Active ? State.ACTIVE : State.NORMAL;

                GLib.Signal.emit_by_name (this, "notify::active");

                toggled.publish (new ToggledEventArgs (name, active));

                damage.post ();

                if (m_HideIfInactive)
                {
                    if (visible && !m_Active)
                    {
                        visible = false;
                        int count = get_qdata<int> (Item.s_CountHide);
                        count++;
                        set_qdata<int> (Item.s_CountHide, count);
                        not_dumpable_attributes.insert ("visible");
                    }
                    else if (!visible && m_Active)
                    {
                        int count = get_qdata<int> (Item.s_CountHide);
                        count = int.max (count - 1, 0);
                        if (count == 0)
                        {
                            visible = true;
                            not_dumpable_attributes.remove ("visible");
                        }
                        set_qdata<int> (Item.s_CountHide, count);
                    }
                }
            }
        }
    }

    /**
     * Hide toggle if inactive
     */
    [CCode (notify = false)]
    public bool  hide_if_inactive {
        get {
            return m_HideIfInactive;
        }
        set {
            if (m_HideIfInactive != value)
            {
                m_HideIfInactive = value;

                if (m_HideIfInactive && visible && !active)
                {
                    visible = false;
                    int count = get_qdata<int> (Item.s_CountHide);
                    count++;
                    set_qdata<int> (Item.s_CountHide, count);
                    not_dumpable_attributes.insert ("visible");
                }
                else if ((m_HideIfInactive && !visible && active) || !m_HideIfInactive)
                {
                    int count = get_qdata<int> (Item.s_CountHide);
                    count = int.max (count - 1, 0);
                    if (count == 0)
                    {
                        visible = true;
                        not_dumpable_attributes.remove ("visible");
                    }
                    set_qdata<int> (Item.s_CountHide, count);
                }
            }
        }
    }

    public virtual string main_data {
        owned get {
            return @"Grid.$(name)-content { " +
                   @"    Label.$(name)-label { " +
                   @"        yfill: false;" +
                   @"        yexpand: true;" +
                   @"        xexpand: true;" +
                   @"        xfill: true;" +
                   @"        state: @state;" +
                   @"        alignment: left;" +
                   @"        shade-color: @shade-color;" +
                   @"        font-description: @font-description;" +
                   @"        stroke-pattern: @stroke-pattern;" +
                   @"        text: @label;" +
                   @"    }" +
                   @"}";
        }
    }

    public unowned Item? main_content {
        get {
            string data = main_data;
            if (m_Content == null && data != null && data.length > 0)
            {
                // parse template
                try
                {
                    var document = new Manifest.Document.from_buffer (data, data.length);
                    document.path = manifest_path;
                    document.theme = manifest_theme;
                    document.notifications["attribute-bind-added"].add_object_observer (on_template_attribute_bind);
                    var item = document.get () as Item;
                    add (item);
                    m_Content = item;
                }
                catch (Core.ParseError err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, "Error on parsing cell %s: %s", name, err.message);
                }
            }

            return m_Content;
        }
    }

    // events
    public Core.Event toggled { get; private set; }

    // static methods
    static construct
    {
        // Ref ToggleGroup class to register toggle group transform
        typeof (ToggleGroup).class_ref ();
    }

    // methods
    construct
    {
        // Do not dump characters
        not_dumpable_attributes.insert ("main-data");
        not_dumpable_attributes.insert ("main-content");

        // Set default patterns
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        // Create toggled event
        toggled = new Core.Event ("toggled", this);

        // Connect onto root changed
        notify["root"].connect (on_root_changed);
    }

    public Toggle (string inId, string inLabel)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), label: inLabel);
    }

    ~Toggle ()
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
    on_root_changed ()
    {
        if (m_ToggleGroup == null && m_Group != null && root != null)
        {
            m_ToggleGroup = root.find (GLib.Quark.from_string (m_Group)) as ToggleGroup;
            m_ToggleGroup.add_button (this);
        }
    }

    private void
    on_template_attribute_bind (Core.Notification inNotification)
    {
        unowned Manifest.Document.AttributeBindAddedNotification? notification = inNotification as Manifest.Document.AttributeBindAddedNotification;
        if (notification != null)
        {
            // plug property to binded property
            plug_property (notification.attribute.get (), notification.attribute.owner as Core.Object, notification.property);
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (sensitive && ret)
        {
            print (@"$name grab pointer\n");
            grab_pointer (this);
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        print (@"$name ungrab pointer\n");
        ungrab_pointer (this);

        return ret;
    }

    internal override void
    on_gesture (Gesture.Notification inNotification)
    {
        if (sensitive && inNotification.button == 1)
        {
            switch (inNotification.gesture_type)
            {
                case Gesture.Type.PRESS:
                    print(@"$name press\n");
                    inNotification.proceed = true;
                    break;

                case Gesture.Type.RELEASE:
                    print(@"$name release $(m_ToggleGroup.active) $(m_ToggleGroup == null) || $(!m_ToggleGroup.exclusive) || $(m_ToggleGroup.active != name)\n");
                    if (m_ToggleGroup == null || !m_ToggleGroup.exclusive || m_ToggleGroup.active != name)
                    {
                        print(@"$name active: $(active)\n");
                        active = !active;
                    }
                    inNotification.proceed = true;
                    break;
            }
        }
    }

    internal override bool
    can_append_child (Core.Object inChild)
    {
        return m_Content == null;
    }

    internal override string
    dump_childs (string inPrefix)
    {
        return "";
    }
}

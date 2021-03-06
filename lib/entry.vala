/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * entry.vala
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

/**
 * An item which provide text editing.
 *
 * =Manifest description:=
 *
 * {{{
 *      Entry.<id> {
 *          font_description: 'Liberation Sans 12';
 *          lines: 5;
 *          text: '';
 *      }
 * }}}
 *
 */
public class Maia.Entry : Item, ItemPackable, ItemMovable, ItemFocusable
{
    // types
    /**
     * The mask which set when changed event will be published
     */
    [Flags]
    public enum ChangedMask
    {
        /**
         * Never emit changed event
         */
        NEVER,
        /**
         * Emit changed event on focus out
         */
        FOCUS_OUT,
        /**
         * Emit changed event on press return
         */
        RETURN,
        /**
         * Emit changed event on each update of text
         */
        EACH_TEXT_UPDATE;

        public string
        to_string ()
        {
            string ret = "never";

            if (FOCUS_OUT in this)
            {
                ret = "focus-out";
            }

            if (RETURN in this)
            {
                if (ret == "never")
                    ret = "return";
                else
                    ret = " | return";
            }

            if (EACH_TEXT_UPDATE in this)
            {
                if (ret == "never")
                    ret = "each-text-update";
                else
                    ret = " | each-text-update";
            }

            return ret;
        }

        public static ChangedMask
        from_string (string inValue)
        {
            ChangedMask ret = ChangedMask.NEVER;

            string[] values = inValue.split("|");

            foreach (unowned string? val in values)
            {
                switch (val.strip ().down ())
                {
                    case "focus-out":
                    case "focus_out":
                        if (ret == ChangedMask.NEVER)
                            ret = ChangedMask.FOCUS_OUT;
                        else
                            ret |= ChangedMask.FOCUS_OUT;
                        break;

                    case "return":
                        if (ret == ChangedMask.NEVER)
                            ret = ChangedMask.RETURN;
                        else
                            ret |= ChangedMask.RETURN;
                        break;

                    case "each-text-update":
                    case "each_text_update":
                    case "each-text_update":
                    case "each_text-update":
                        if (ret == ChangedMask.NEVER)
                            ret = ChangedMask.EACH_TEXT_UPDATE;
                        else
                            ret |= ChangedMask.EACH_TEXT_UPDATE;
                        break;
                }
            }

            return ret;
        }
    }

    /**
     * Event args provided by entry on changed event
     */
    public class ChangedEventArgs : Core.EventArgs
    {
        // constants
        public const string PROTOBUF = "message Changed {" +
                                       "    string text;"  +
                                       "}";

        /**
         * Entry text on changed event
         */
        public string text {
            owned get {
                return (string)this["text"];
            }
        }

        // static methods
        static construct
        {
            Core.EventArgs.register_protocol (typeof (ChangedEventArgs).name (),
                                              "Changed", PROTOBUF);
        }

        // methods
        internal ChangedEventArgs (string inText)
        {
            base ();

            this["text", 0] = inText;
        }
    }

    public class AllowedValues : GLib.Object
    {
        public class Iterator
        {
            private unowned AllowedValues m_AllowedValues;
            private int m_Index;

            internal Iterator (AllowedValues inAllowedValues)
            {
                m_AllowedValues = inAllowedValues;
                m_Index = -1;
            }

            public bool
            next ()
            {
                m_Index++;
                return m_Index < m_AllowedValues.m_Values.length;
            }

            public unowned string?
            @get ()
            {
                return m_AllowedValues.m_Values[m_Index];
            }
        }

        private string[] m_Values;

        internal AllowedValues ()
        {
            m_Values = {};
        }

        internal AllowedValues.from_string (string inValues)
        {
            m_Values = {};

            string[] values = inValues.split(",");
            foreach (unowned string? val in values)
            {
                m_Values += val.strip ();
            }
        }

        public bool
        contains (string inValue)
        {
            if (m_Values.length == 0) return true;

            foreach (unowned string val in m_Values)
            {
                if ((inValue == val) || (inValue.length < val.length && val.has_prefix (inValue)))
                {
                    return true;
                }
            }

            return false;
        }

        public Iterator
        iterator ()
        {
            return new Iterator (this);
        }

        public string
        to_string ()
        {
            string ret = "";

            foreach (unowned string val in this)
            {
                if (ret == "")
                    ret += val;
                else
                    ret += "," + val;
            }

            return ret;
        }
    }

    // properties
    private string          m_Text = "";
    private string          m_Initial = "";
    private Graphic.Glyph   m_Glyph;
    private Graphic.Surface m_FakeSurface;
    private int             m_Cursor = 0;
    private uint            m_LinePads = 0;
    private bool            m_HideIfEmpty = false;
    private FocusGroup      m_FocusGroup = null;

    // accessors
    internal override string tag {
        get {
            return "Entry";
        }
    }

    internal bool   can_focus   { get; set; default = true; }
    internal bool   have_focus  { get; set; default = false; }
    internal int    focus_order { get; set; default = -1; }
    internal FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }

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
     * The default font description of entry
     */
    public string font_description { get; set; default = "Sans 12"; }

    /**
     * The text of entry
     */
    [CCode (notify = false)]
    public string text {
        get {
            return m_Text;
        }
        set {
            if (m_Text != value)
            {
                m_Text = value;

                if (m_Text == null || m_Text.length == 0)
                {
                    if (m_HideIfEmpty && visible)
                    {
                        visible = false;
                        int count = get_qdata<int> (Item.s_CountHide);
                        count++;
                        set_qdata<int> (Item.s_CountHide, count);
                        not_dumpable_attributes.insert ("visible");
                    }
                }
                else if (m_HideIfEmpty && !visible)
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

                // Update layout
                update_layout ();

                // Damage area
                damage.post ();

                notify_property ("text");


                if (ChangedMask.EACH_TEXT_UPDATE in changed_mask)
                {
                    changed.publish (new ChangedEventArgs (m_Text ?? ""));
                }
            }
        }
        default = "";
    }

    /**
     * If true hide label if text is empty
     */
    [CCode (notify = false)]
    public bool hide_if_empty {
        get {
            return m_HideIfEmpty;
        }
        set {
            if (m_HideIfEmpty != value)
            {
                m_HideIfEmpty = value;
                if (m_HideIfEmpty && visible && (text == null || text.length == 0))
                {
                    visible = false;
                    int count = get_qdata<int> (Item.s_CountHide);
                    count++;
                    set_qdata<int> (Item.s_CountHide, count);
                    not_dumpable_attributes.insert ("visible");
                }
                else if (!m_HideIfEmpty && !visible)
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

    /**
     * The number of lines of entry
     */
    public uint     lines            { get; set; default = 1; }
    /**
     * The number of chars of entry
     */
    public uint     width_in_chars   { get; set; default = 0; }
    /**
     * The line width of entry underline
     */
    public double   underline_width  { get; set; default = 0.2; }
    /**
     * If set to ``true`` only allow numeric value in entry
     */
    public bool     only_numeric     { get; set; default = false; }

    /**
     * {@link ChangedMask} to set when changed event will be published
     */
    public ChangedMask changed_mask { get; set; default = ChangedMask.FOCUS_OUT | ChangedMask.RETURN; }

    /**
     * Alignment of label ``left``, ``center`` or ``right``, default was ``left``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.LEFT; }

    /**
     * Allowed values in entry
     */
    public AllowedValues allowed_values { get; set; default = new AllowedValues (); }

    /**
     * Touchscreen mode
     */
    public bool touchscreen_mode { get; set; default = false; }

    /**
     * If set entry always interact elsewhere it does not have focus
     */
    public bool always_active { get; set; default = false; }

    /**
     * Indicate the label item which labelled this entry
     */
    public unowned Label labelled_by { get; set; default = null; }

    /**
     * Cursor position
     */
    public int cursor {
        get {
            return m_Cursor;
        }
        set {
            m_Cursor = int.min(value, text.length);
            damage.post ();
        }
        default = 0;
    }

    // events
    /**
     * The event published on text changed and following {@link changed_mask}
     */
    public Core.Event changed { get; private set; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (ChangedMask), attribute_to_changed_mask);
        Manifest.Attribute.register_transform_func (typeof (AllowedValues), attribute_to_allowed_values);

        GLib.Value.register_transform_func (typeof (ChangedMask), typeof (string), changed_mask_value_to_string);
        GLib.Value.register_transform_func (typeof (AllowedValues), typeof (string), allowed_values_value_to_string);

        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    static void
    attribute_to_changed_mask (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = ChangedMask.from_string (inAttribute.get ());
    }

    static void
    changed_mask_value_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (ChangedMask)))
    {
        ChangedMask val = (ChangedMask)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_allowed_values (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = new AllowedValues.from_string (inAttribute.get ());
    }

    static void
    allowed_values_value_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (AllowedValues)))
    {
        AllowedValues val = (AllowedValues)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("changed");

        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        // Create a fake surface to calculate the size of path
        m_FakeSurface = new Graphic.Surface (1, 1);

        // Create changed event
        changed = new Core.Event ("changed", this);

        // connect under key press event
        key_press_event.connect (on_key_press_event);

        notify["lines"].connect (() => {
            m_Glyph = null;
            create_glyph ();
            damage.post ();
        });

        notify["font-description"].connect (() => {
            m_Glyph = null;
            create_glyph ();
            damage.post ();
        });

        notify["alignment"].connect (() => {
            m_Glyph = null;
            create_glyph ();
            damage.post ();
        });

        // connect onto have docus to damage
        notify["have-focus"].connect (() => {
            damage.post ();
        });

        notify["pointer-over"].connect (on_pointer_over_changed);

        // connect onto focus changed
        notify["have-focus"].connect (on_focus_changed);

        // connect onto root changed
        notify["window"].connect (on_window_changed);

        // connect onto button press event
        button_press_event.connect (on_button_press_event);
    }

    /**
     * Create a new entry item
     *
     * @param inId id of entry
     * @param inText initial text in entry
     */
    public Entry (string inId, string? inText)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), text: inText);
    }

    private void
    on_window_changed ()
    {
        // unset glyph
        m_Glyph = null;

        // Create a fake surface to calculate the size of path
        m_FakeSurface = new Graphic.Surface (1, 1);

        // Set transform
        m_FakeSurface.context.transform = to_window_transform ();

        // unset geometry to force update
        need_update = true;
        geometry = null;
    }

    private void
    on_focus_changed ()
    {
        if (have_focus)
        {
            cursor = (int)(text ?? "").length;
            m_Initial = text;
        }
        else if (ChangedMask.FOCUS_OUT in changed_mask)
        {
            if (m_Initial != text)
            {
                changed.publish (new ChangedEventArgs (text ?? ""));
            }
        }

        state = (have_focus || always_active) ? State.ACTIVE : State.NORMAL;
    }

    private void
    update_layout ()
    {
        if (m_Glyph != null)
        {
            // Geometry is set and entry is not in drawing area update layout width
            m_Glyph.size = Graphic.Size (geometry != null && !(parent is DrawingArea) ? geometry.extents.size.width : 0, 0);

            // Set text
            m_Glyph.text = text;

            // Calculate the size of glyph without line pads
            m_Glyph.update (m_FakeSurface.context);

            // Count lines pad
            m_LinePads = 0;
            if (lines > 1)
            {
                uint nb_lines = m_Glyph.line_count;
                if (nb_lines < lines)
                {
                    m_LinePads = lines - nb_lines;
                }
            }

            // Set text with line pad
            if (m_LinePads > 0)
            {
                m_Glyph.text = (text ?? "") + (alignment == Graphic.Glyph.Alignment.LEFT ? " " : "") + string.nfill (m_LinePads, '\n');
            }
            else
            {
                m_Glyph.text = (text ?? "") + (alignment == Graphic.Glyph.Alignment.LEFT ? " " : "");
            }

            // Calculate glyph size
            m_Glyph.update (m_FakeSurface.context);
        }
    }

    private void
    remove_char_at_cursor ()
    {
        GLib.StringBuilder new_text = new GLib.StringBuilder (text);
        int begin = (text ?? "").index_of_nth_char (cursor - 1);
        int end = (text ?? "").index_of_nth_char (cursor);
        new_text.erase (begin, end - begin);
        text = new_text.str;
        cursor--;
    }

    private void
    check_line_size ()
    {
        if (m_Glyph != null && geometry != null)
        {
            int line;

            if (width_in_chars > 0 && text.length > width_in_chars)
            {
                remove_char_at_cursor ();
            }

            // cursor is not set, move on end of text
            if (cursor == 0)
            {
                cursor = (int)(text ?? "").length;
            }

            if (!(parent is DrawingArea))
            {
                // get current line at cusor position
                m_Glyph.get_line_position (cursor, true, out line);

                if (line >= lines)
                {
                    remove_char_at_cursor ();
                }

                // check line size
                int cpt = 0;
                foreach (unowned Core.Object child in m_Glyph)
                {
                    // We found line check its size
                    if (cpt == line)
                    {
                        unowned Graphic.Glyph.Line glyph_line = (Graphic.Glyph.Line)child;

                        // line is too long remove last characters inserted
                        if (glyph_line.size.width > geometry.extents.size.width)
                        {
                            remove_char_at_cursor ();
                        }

                        break;
                    }
                    cpt++;
                }
            }
            else
            {
                damage.post ();
                size = m_Glyph.size;
                damage.post ();
            }
        }
    }

    private Graphic.Size
    width_in_chars_to_size ()
    {
        Graphic.Size ret = Graphic.Size (0, 0);

        if (width_in_chars > 0)
        {
            // Create fake glyph
            var glyph = new Graphic.Glyph (font_description);
            glyph.alignment = alignment;
            glyph.use_markup = false;
            glyph.wrap = Graphic.Glyph.WrapMode.WORD;
            glyph.text = string.nfill (width_in_chars, 'Z');

            // Create a fake surface to calculate the size of glyph
            var fake_surface = new Graphic.Surface (1, 1);

            // Get stack of items
            GLib.SList<unowned Item> list = new GLib.SList<unowned Item?> ();
            for (unowned Core.Object? item = this; item != null; item = item.parent)
            {
                if (item is Item)
                {
                    list.append (item as Item);
                }
            }

            // Apply transform of all parents to fake surface
            foreach (unowned Item item in list)
            {
                fake_surface.context.transform = item.transform;
            }

            // Calculate the size of glyph
            glyph.update (fake_surface.context);

            ret = glyph.size;
        }

        return ret;
    }

    private void
    create_glyph ()
    {
        if (m_Glyph == null)
        {
            // Create glyph
            m_Glyph = new Graphic.Glyph (font_description);
            m_Glyph.alignment = alignment;
            m_Glyph.use_markup = false;
            m_Glyph.wrap = Graphic.Glyph.WrapMode.WORD;
            m_Glyph.text = text ?? "";

            // Update the layout with line pad
            update_layout ();
        }
    }

    private void
    on_pointer_over_changed ()
    {
        if (!touchscreen_mode)
        {
            if (pointer_over)
            {
                set_pointer_cursor (Cursor.XTERM);
            }
            else
            {
                set_pointer_cursor (Cursor.TOP_LEFT_ARROW);
            }
        }
    }

    private void
    on_key_press_event (Modifier inModifier, Key inKey, unichar inCar)
    {
        if (have_focus || always_active)
        {
            bool updated = false;
            GLib.StringBuilder new_text = new GLib.StringBuilder (text);

            // Tab pressed pass to next focusable item
            if (inKey == Key.Tab)
            {
                if (focus_group != null)
                {
                    // TODO: Check why shift TAB do not work
                    if (inModifier == Modifier.CONTROL)
                    {
                        focus_group.prev ();
                    }
                    else if (inModifier == Modifier.NONE)
                    {
                        focus_group.next ();
                    }
                }
            }
            // Backspace pressed suppress last characters
            else if (inKey == Key.BackSpace && cursor > 0)
            {
                int begin = (text ?? "").index_of_nth_char (cursor - 1);
                int end = (text ?? "").index_of_nth_char (cursor);
                new_text.erase (begin, end - begin);
                text = new_text.str;
                updated = true;
                cursor--;
            }
            // Enter is pressed and new line
            else if (inKey == Key.Return || inKey == Key.ISO_Enter || inKey == Key.KP_Enter)
            {
                if (parent is DrawingArea || m_Glyph.line_count - m_LinePads < lines)
                {
                    new_text.insert ((text ?? "").index_of_nth_char (cursor), "\n");
                    text = new_text.str;
                    updated = true;
                    cursor++;
                }

                if (ChangedMask.RETURN in changed_mask && m_Initial != text)
                {
                    changed.publish (new ChangedEventArgs (text ?? ""));
                }
            }
            // Space is pressed
            else if ((inKey == Key.space || inKey == Key.KP_Space) && !only_numeric)
            {
                new_text.insert ((text ?? "").index_of_nth_char (cursor), " ");
                text = new_text.str;
                cursor++;
                updated = true;

                check_line_size ();
            }
            // Left arrow is pressed move cursor on left
            else if (inKey == Key.Left || inKey == Key.KP_Left)
            {
                cursor--;
                cursor = int.max (0, cursor);
                damage.post ();
            }
            // Right arrow is pressed move cursor on right
            else if (inKey == Key.Right || inKey == Key.Right)
            {
                cursor++;
                cursor = int.min ((int)(text ?? "").length, cursor);
                damage.post ();
            }
            // Other key is pressed check if character is printable (filter sepcial key)
            else if (inCar.isprint ())
            {
                if (!only_numeric || inCar.isdigit () || ((inCar == '.' || inCar == ',') && !("." in text)))
                {
                    if (only_numeric && inCar == ',')
                    {
                        new_text.insert ((text ?? "").index_of_nth_char (cursor), ".");
                    }
                    else
                    {
                        new_text.insert ((text ?? "").index_of_nth_char (cursor), inCar.to_string ());
                    }
                    if (new_text.str in allowed_values)
                    {
                        text = new_text.str;
                        cursor ++;
                        updated = true;

                        check_line_size ();
                    }
                }
            }
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        create_glyph ();

        if (m_Glyph != null)
        {
            if (width_in_chars > 0)
            {
                size = width_in_chars_to_size ();
            }
            else
            {
                // Set the new glyph size
                size = m_Glyph.size;
            }
        }

        return base.size_request (inSize);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        bool update = geometry == null && !(parent is DrawingArea);

        base.update (inContext, inAllocation);

        if (update) update_layout ();
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        if (m_Glyph != null && m_Glyph.text != null && stroke_pattern != null)
        {
            inContext.save ();
            {
                // Paint background
                paint_background (inContext);

                // Paint text
                inContext.pattern = stroke_pattern[state];
                inContext.render (m_Glyph);

                inContext.line_width = underline_width;
                inContext.dash = { 1.0, 2.0 };

                // Calculate raw cursor index from utf8 string
                int index = m_Glyph.text.index_of_nth_char (cursor);

                // Get cursor pos
                Graphic.Rectangle rect = m_Glyph.get_cursor_position (index);

                var path = new Graphic.Path ();
                if (!(parent is DrawingArea))
                {
                    // foreach lines add underline at end of text
                    double y = 0;
                    var glyph_line_width = width_in_chars > 0 ? width_in_chars_to_size ().width : geometry.extents.size.width;
                    foreach (unowned Core.Object child in m_Glyph)
                    {
                        // Add line
                        Graphic.Glyph.Line line = (Graphic.Glyph.Line)child;
                        switch (alignment)
                        {
                            case Graphic.Glyph.Alignment.LEFT:
                                path.move_to (line.size.width, y + rect.size.height);
                                path.line_to (glyph_line_width, y + rect.size.height);
                                y += rect.size.height;
                                break;

                            case Graphic.Glyph.Alignment.RIGHT:
                                path.move_to (0, y + rect.size.height);
                                path.line_to (glyph_line_width - line.size.width, y + rect.size.height);
                                y += rect.size.height;
                                break;

                            case Graphic.Glyph.Alignment.CENTER:
                                path.move_to (0, y + rect.size.height);
                                path.line_to ((glyph_line_width - line.size.width) / 2, y + rect.size.height);
                                path.move_to (((glyph_line_width - line.size.width) / 2) + line.size.width, y + rect.size.height);
                                path.line_to (glyph_line_width, y + rect.size.height);
                                y += rect.size.height;
                                break;
                        }
                    }
                    inContext.stroke (path);
                }

                inContext.line_width = line_width;
                inContext.dash = null;

                // If have focus
                if (have_focus || always_active)
                {
                    double x = rect.origin.x;

                    if (index == 0 && m_Text.length == 0)
                    {
                        switch (alignment)
                        {
                            case Graphic.Glyph.Alignment.LEFT:
                                break;

                            case Graphic.Glyph.Alignment.RIGHT:
                                x = width_in_chars > 0 ? width_in_chars_to_size ().width : geometry.extents.size.width;
                                break;

                            case Graphic.Glyph.Alignment.CENTER:
                                x = (width_in_chars > 0 ? width_in_chars_to_size ().width : geometry.extents.size.width) / 2.0;
                                break;
                        }
                    }
                    // Draw cursor
                    path = new Graphic.Path ();
                    path.move_to (x, rect.origin.y);
                    path.line_to (x, rect.origin.y + rect.size.height);
                    inContext.stroke (path);
                }
            }
            inContext.restore ();
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPosition)
    {
        bool ret = base.on_button_press_event (inButton, inPosition);

        if (inButton == 1 && ret && m_Glyph != null)
        {
            int index, trailing;
            m_Glyph.get_index_from_position (inPosition, out index, out trailing);
            int pos = m_Text.char_count (index) + trailing;
            if (pos < m_Text.length)
            {
                cursor = pos;
            }
        }

        return ret;
    }
}

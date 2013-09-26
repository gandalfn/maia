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

public class Maia.Entry : Item, ItemPackable, ItemMovable
{
    // properties
    private Graphic.Glyph m_Glyph;
    private int           m_Cursor = 0;
    private uint          m_LinePads = 0;

    // accessors
    internal override string tag {
        get {
            return "Entry";
        }
    }

    internal override bool can_focus { get; set; default = true; }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    public string   font_description { get; set; default = "Sans 12"; }
    public string   text             { get; set; default = ""; }
    public uint     lines            { get; set; default = 1; }
    public uint     width_in_chars   { get; set; default = 0; }
    public double   underline_width  { get; set; default = 0.2; }
    public bool     only_numeric     { get; set; default = false; }

    // signals
    public signal void changed ();

    // methods
    construct
    {
        stroke_pattern = new Graphic.Color (0, 0, 0);
        background_pattern = new Graphic.Color (0, 0, 0);

        // connect under key press event
        key_press_event.connect (on_key_press_event);

        // connect onto text changed
        notify["text"].connect (on_text_changed);

        notify["lines"].connect (() => {
            m_Glyph = null;
            create_glyph ();
            damage ();
        });

        notify["font-description"].connect (() => {
            m_Glyph = null;
            create_glyph ();
            damage ();
        });

        // connect onto have docus to damage
        notify["have-focus"].connect (() => {
            damage ();
        });

        notify["pointer-over"].connect (on_pointer_over_changed);
    }

    public Entry (string inId, string? inText)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), text: inText);
    }

    private void
    update_layout ()
    {
        if (m_Glyph != null)
        {
            // Geometry is set update layout width
            m_Glyph.size = Graphic.Size (geometry != null ? geometry.extents.size.width : 0, 0);

            // Set text
            m_Glyph.text = text;

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

            // Calculate the size of glyph without line pads
            m_Glyph.update (fake_surface.context);

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
                m_Glyph.text = (text ?? "") + " " + string.nfill (m_LinePads, '\n');
            }
            else
            {
                m_Glyph.text = (text ?? "") + " ";
            }

            // Calculate glyph size
            m_Glyph.update (fake_surface.context);
        }
    }

    private void
    remove_char_at_cursor ()
    {
        GLib.StringBuilder new_text = new GLib.StringBuilder (text);
        int begin = (text ?? "").index_of_nth_char (m_Cursor - 1);
        int end = (text ?? "").index_of_nth_char (m_Cursor);
        new_text.erase (begin, end - begin);
        text = new_text.str;
        m_Cursor--;
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
            if (m_Cursor == 0)
            {
                m_Cursor = (int)(text ?? "").length;
            }

            // get current line at cusor position
            m_Glyph.get_line_position (m_Cursor, true, out line);


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
    }

    private Graphic.Size
    width_in_chars_to_size ()
    {
        Graphic.Size ret = Graphic.Size (0, 0);

        if (width_in_chars > 0)
        {
            // Create fake glyph
            var glyph = new Graphic.Glyph (font_description);
            glyph.alignment = Graphic.Glyph.Alignment.LEFT;
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
            m_Glyph.alignment = Graphic.Glyph.Alignment.LEFT;
            m_Glyph.use_markup = false;
            m_Glyph.wrap = Graphic.Glyph.WrapMode.WORD;
            m_Glyph.text = text ?? "";

            // Update the layout with line pad
            update_layout ();
        }
    }

    private void
    on_text_changed ()
    {
        // Update layout
        update_layout ();

        // Damage area
        damage ();
    }

    private void
    on_pointer_over_changed ()
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

    private void
    on_key_press_event (Key inKey, unichar inCar)
    {
        if (have_focus)
        {
            GLib.StringBuilder new_text = new GLib.StringBuilder (text);

            // Backspace pressed suppress last characters
            if (inKey == Key.BackSpace && m_Cursor > 0)
            {
                int begin = (text ?? "").index_of_nth_char (m_Cursor - 1);
                int end = (text ?? "").index_of_nth_char (m_Cursor);
                new_text.erase (begin, end - begin);
                text = new_text.str;
                m_Cursor--;
            }
            // Enter is pressed and new line
            else if (inKey == Key.Return || inKey == Key.ISO_Enter || inKey == Key.KP_Enter)
            {
                if (m_Glyph.line_count - m_LinePads < lines)
                {
                    new_text.insert ((text ?? "").index_of_nth_char (m_Cursor), "\n");
                    text = new_text.str;
                    m_Cursor++;
                }
            }
            // Space is pressed
            else if (inKey == Key.space || inKey == Key.KP_Space)
            {
                new_text.insert ((text ?? "").index_of_nth_char (m_Cursor), " ");
                text = new_text.str;
                m_Cursor++;

                check_line_size ();
            }
            // Left arrow is pressed move cursor on left
            else if (inKey == Key.Left || inKey == Key.KP_Left)
            {
                m_Cursor--;
                m_Cursor = int.max (0, m_Cursor);
                damage ();
            }
            // Right arrow is pressed move cursor on right
            else if (inKey == Key.Right || inKey == Key.Right)
            {
                m_Cursor++;
                m_Cursor = int.min ((int)(text ?? "").length, m_Cursor);
                damage ();
            }
            // Other key is pressed check if character is printable (filter sepcial key)
            else if (inCar.isprint ())
            {
                if (!only_numeric || inCar.isdigit ())
                {
                    new_text.insert ((text ?? "").index_of_nth_char (m_Cursor), inCar.to_string ());
                    text = new_text.str;
                    m_Cursor ++;

                    check_line_size ();
                }
            }

            changed ();
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
            // Update layout
            update_layout ();

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
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_Glyph != null && m_Glyph.text != null && stroke_pattern != null)
        {
            inContext.save ();
            {
                m_Glyph.update (inContext);

                // Paint text
                inContext.pattern = stroke_pattern;
                inContext.render (m_Glyph);

                inContext.pattern = background_pattern;
                inContext.line_width = underline_width;
                inContext.dash = { 1.0, 2.0 };

                // Calculate raw cursor index from utf8 string
                int index = m_Glyph.text.index_of_nth_char (m_Cursor);

                // Get cursor pos
                Graphic.Rectangle rect = m_Glyph.get_cursor_position (index);

                // foreach lines add underline at end of text
                double y = 0;
                var path = new Graphic.Path ();
                var glyph_line_width = width_in_chars > 0 ? width_in_chars_to_size ().width : geometry.extents.size.width;
                foreach (unowned Core.Object child in m_Glyph)
                {
                    // Add line
                    Graphic.Glyph.Line line = (Graphic.Glyph.Line)child;
                    path.move_to (line.size.width, y + rect.size.height);
                    path.line_to (glyph_line_width, y + rect.size.height);

                    y += rect.size.height;
                }
                inContext.stroke (path);

                inContext.line_width = line_width;
                inContext.dash = null;

                // If have focus
                if (have_focus)
                {
                    // Draw cursor
                    path = new Graphic.Path ();
                    path.move_to (rect.origin.x, rect.origin.y);
                    path.line_to (rect.origin.x, rect.origin.y + rect.size.height);
                    inContext.stroke (path);
                }
            }
            inContext.restore ();
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if  (ret)
        {
            m_Cursor = (int)(text ?? "").length;
            grab_focus (this);
        }

        return ret;
    }
}

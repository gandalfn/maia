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
    private int           m_Cursor = 1;

    // accessors
    internal override string tag {
        get {
            return "Entry";
        }
    }

    internal override string characters { get; set; default = null; }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    public string   font_description { get; set; default = ""; }
    public string   text             { get; set; default = ""; }
    public uint     lines            { get; set; default = 1; }
    public double   underline_width  { get; set; default = 0.2; }

    // signals
    public signal void changed ();

    // methods
    construct
    {
        // connect under key press event
        key_press_event.connect (on_key_press_event);

        // connect onto text changed
        notify["text"].connect (() => {
            m_Glyph = null;
            create_glyph ();
            damage ();
        });

        // connect onto have docus to damage
        notify["have-focus"].connect (() => {
            damage ();
        });

        stroke_pattern = new Graphic.Color (0, 0, 0);
        background_pattern = new Graphic.Color (0, 0, 0);
        font_description = "Sans 12";

        notify["pointer-over"].connect (on_pointer_over_changed);
    }

    public Entry (string inId, string? inText)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), text: inText);
    }

    private inline uint
    get_nb_lines ()
    {
        return text.split ("\n").length;
    }

    private void
    create_glyph ()
    {
        if (m_Glyph == null)
        {
            m_Glyph = new Graphic.Glyph (font_description);

            // Count lines pad
            uint lines_pad = 0;
            if (lines > 1)
            {
                uint nb_lines = get_nb_lines ();
                if (nb_lines < lines)
                {
                    lines_pad = lines - nb_lines;
                }
            }

            // Set text with line pad
            if (lines_pad > 0)
            {
                m_Glyph.text = text + " " + string.nfill (lines_pad, '\n');
            }
            else
            {
                m_Glyph.text = text + " ";
            }
        }
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
                new_text.erase (m_Cursor - 1, 1);
                text = new_text.str;
                m_Cursor--;
            }
            // Enter is pressed and new line
            else if (inKey == Key.Return || inKey == Key.ISO_Enter || inKey == Key.KP_Enter)
            {
                if (get_nb_lines () < lines)
                {
                    new_text.insert (m_Cursor, "\n");
                    text = new_text.str;
                    m_Cursor++;
                }
            }
            // Space is pressed
            else if (inKey == Key.space || inKey == Key.KP_Space)
            {
                new_text.insert (m_Cursor, " ");
                text = new_text.str;
                m_Cursor++;
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
                m_Cursor = int.min ((int)text.length, m_Cursor);
                damage ();
            }
            // Other key is pressed check if character is printable (filter sepcial key)
            else if (inCar.isprint ())
            {
                new_text.insert_unichar (m_Cursor, inCar);
                text = new_text.str;
                m_Cursor++;
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
            // Create a fake surface to calculate the size of path
            var fake_surface = new Graphic.Surface (1, 1);

            m_Glyph.update (fake_surface.context);
            size = m_Glyph.size;
        }

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_Glyph != null && stroke_pattern != null)
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
                foreach (unowned Core.Object child in m_Glyph)
                {
                    // Add line
                    Graphic.Glyph.Line line = (Graphic.Glyph.Line)child;
                    path.move_to (line.size.width, y + rect.size.height);
                    path.line_to (geometry.extents.size.width, y + rect.size.height);

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
            m_Cursor = (int)text.length;
            grab_focus (this);
        }

        return ret;
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * sourceview.vala
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

public class CanvasEditor.SourceView : Gtk.SourceView
{
    private string m_Current = null;

    // methods
    public SourceView ()
    {
        buffer = new Gtk.SourceBuffer (null);
        show_line_numbers = true;
        auto_indent = true;
        draw_spaces = Gtk.SourceDrawSpacesFlags.SPACE | Gtk.SourceDrawSpacesFlags.TAB;

        highlight_current_line = true;
        smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
        modify_font (Pango.FontDescription.from_string ("Liberation Mono 11"));
        tab_width = 4;
        insert_spaces_instead_of_tabs = true;
        indent_on_tab = true;
        get_completion ();
        (buffer as Gtk.SourceBuffer).highlight_matching_brackets = true;
        //(buffer as Gtk.SourceBuffer).style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("Oblivion");
    }

    public void
    load (string inFilename)
    {
        buffer.text = "";
        m_Current = null;

        try
        {
            string content;
            GLib.FileUtils.get_contents (inFilename, out content);
            m_Current = inFilename;

            var manager = Gtk.SourceLanguageManager.get_default ();
            (buffer as Gtk.SourceBuffer).language = manager.guess_language (m_Current, null);

            (buffer as Gtk.SourceBuffer).begin_not_undoable_action ();
            (buffer as Gtk.SourceBuffer).text = content;
            (buffer as Gtk.SourceBuffer).end_not_undoable_action ();

            Gtk.TextIter start;
            (buffer as Gtk.SourceBuffer).get_start_iter (out start);
            (buffer as Gtk.SourceBuffer).place_cursor (start);
        }
        catch (GLib.Error err)
        {
            critical ("Error on load %s: %s", inFilename, err.message);
        }
    }
}

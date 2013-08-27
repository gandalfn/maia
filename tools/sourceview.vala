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
    private Engine m_Engine = null;
    private uint m_Timeout = 0;

    // accessors
    public string filename {
        get {
            return m_Current;
        }
    }

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
        insert_spaces_instead_of_tabs = false;
        indent_on_tab = true;
        get_completion ();
        (buffer as Gtk.SourceBuffer).highlight_matching_brackets = true;
        //(buffer as Gtk.SourceBuffer).style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("Oblivion");

        // Provider
        m_Engine = new Engine ();
        var comp_provider = new DocumentProvider (buffer as Gtk.SourceBuffer, m_Engine);
        try
        {
            completion.add_provider (comp_provider);
        }
        catch (GLib.Error err)
        {
            warning (err.message);
        }

        var manifest_provider = new ManifestProvider (buffer as Gtk.SourceBuffer);
        try
        {
            completion.add_provider (manifest_provider);
        }
        catch (GLib.Error err)
        {
            warning (err.message);
        }
    }

    private bool
    on_timeout_update ()
    {
        if (m_Timeout != 0)
        {
            string content = buffer.text;
            new GLib.Thread<void*> ("parser", () => {
                m_Engine.parse (content);

                return null;
            });

            m_Timeout = 0;
        }

        return false;
    }

    internal override bool
    key_press_event (Gdk.EventKey inEvent)
    {
        bool ret = base.key_press_event (inEvent);

        if (m_Timeout != 0)
        {
            GLib.Source.remove (m_Timeout);
            m_Timeout = 0;
        }
        m_Timeout = GLib.Timeout.add_seconds (5, on_timeout_update);

        if (inEvent.str.get_char () in Provider.c_Stoppers)
        {
            completion.hide ();
        }

        return ret;
    }

    public void
    new_document ()
    {
        buffer.text = "";
        m_Current = null;
        buffer.set_modified (false);
    }

    public void
    load (string inFilename)
    {
        buffer.text = "";
        m_Current = null;

        if (m_Timeout != 0)
        {
            GLib.Source.remove (m_Timeout);
            m_Timeout = 0;
        }

        try
        {
            string content;
            GLib.FileUtils.get_contents (inFilename, out content);
            m_Current = inFilename;

            var manager = Gtk.SourceLanguageManager.get_default ();
            (buffer as Gtk.SourceBuffer).language = manager.get_language ("manifest");

            (buffer as Gtk.SourceBuffer).begin_not_undoable_action ();
            (buffer as Gtk.SourceBuffer).text = content;
            (buffer as Gtk.SourceBuffer).end_not_undoable_action ();

            Gtk.TextIter start;
            (buffer as Gtk.SourceBuffer).get_start_iter (out start);
            (buffer as Gtk.SourceBuffer).place_cursor (start);

            m_Timeout = GLib.Timeout.add_seconds (5, on_timeout_update);

            buffer.set_modified (false);
        }
        catch (GLib.Error err)
        {
            critical ("Error on load %s: %s", inFilename, err.message);
        }
    }

    public void
    save (string? inFilename = null)
    {
        if (((inFilename == null && m_Current != null) || (inFilename != null)) && buffer.get_modified ())
        {
            try
            {
                string content = buffer.text;
                GLib.FileUtils.set_contents (inFilename ?? m_Current, content);
                buffer.set_modified (false);
                if (inFilename != null) m_Current = inFilename;
            }
            catch (GLib.Error err)
            {
                critical ("Error on save %s: %s", inFilename ?? m_Current, err.message);
            }
        }
    }
}

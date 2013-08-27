/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
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

public class CanvasEditor.Window : Gtk.Window
{
    // properties
    private SourceView m_SourceView;
    private Gtk.ToolButton m_Save;
    private Gtk.ToolButton m_SaveAs;
    private Gtk.ToolButton m_Undo;
    private Gtk.ToolButton m_Redo;
    private Gtk.ToolButton m_Build;
    private Gtk.ToolButton m_Hide;
    private Gtk.Statusbar m_Bar;
    private Gtk.Container m_Preview;
    private Maia.Gtk.Canvas m_Canvas;

    // methods
    public Window ()
    {
        set_default_size (1024, 600);

        var builder = new Gtk.Builder();

        try
        {
            title = "New manifest*";

            builder.add_from_file ("canvas-editor.ui");
            var content = builder.get_object ("content") as Gtk.Widget;
            add (content);

            var sv = builder.get_object ("sourceview") as Gtk.Container;
            m_SourceView =  new SourceView ();
            m_SourceView.show ();
            sv.add (m_SourceView);

            m_Preview = builder.get_object ("preview") as Gtk.Container;
            m_Canvas = new Maia.Gtk.Canvas ();
            m_Canvas.show ();
            m_Preview.add (m_Canvas);

            var new_button = builder.get_object ("new") as Gtk.ToolButton;
            new_button.clicked.connect (on_new);

            var open = builder.get_object ("open") as Gtk.ToolButton;
            open.clicked.connect (on_open);

            m_Save = builder.get_object ("save") as Gtk.ToolButton;
            m_Save.sensitive = false;
            m_Save.clicked.connect (on_save);

            m_SaveAs = builder.get_object ("saveas") as Gtk.ToolButton;
            m_SaveAs.sensitive = false;
            m_SaveAs.clicked.connect (on_save_as);

            m_Undo = builder.get_object ("undo") as Gtk.ToolButton;
            m_Undo.clicked.connect (on_undo);
            m_Undo.sensitive = false;

            m_Redo = builder.get_object ("redo") as Gtk.ToolButton;
            m_Redo.clicked.connect (on_redo);
            m_Redo.sensitive = false;

            m_Build = builder.get_object ("build") as Gtk.ToolButton;
            m_Build.sensitive = false;
            m_Build.clicked.connect (on_build);

            m_Hide = builder.get_object ("hide") as Gtk.ToolButton;
            m_Hide.sensitive = false;
            m_Hide.clicked.connect (() => {
                m_Preview.hide ();
                m_Hide.sensitive = false;
                m_Canvas.clear ();
            });

            var quit = builder.get_object ("exit") as Gtk.ToolButton;
            quit.clicked.connect (Gtk.main_quit);

            m_Bar = builder.get_object ("statusbar") as Gtk.Statusbar;

            m_SourceView.buffer.changed.connect (() => {
                title = "%s*".printf (m_SourceView.filename ?? "New manifest*");
                m_Save.sensitive = m_SourceView.buffer.get_modified () && m_SourceView.buffer.get_char_count () > 0;
                m_SaveAs.sensitive = m_SourceView.buffer.get_char_count () > 0;
            });

            var undo_manager = (m_SourceView.buffer as Gtk.SourceBuffer).undo_manager;
            undo_manager.can_undo_changed.connect (() => {
                m_Undo.sensitive = undo_manager.can_undo ();
            });

            undo_manager.can_redo_changed.connect (() => {
                m_Redo.sensitive = undo_manager.can_redo ();
            });
        }
        catch (GLib.Error err)
        {
            critical ("Error on loading canvas-editor.ui: %s", err.message);
        }

        destroy.connect (Gtk.main_quit);
    }

    private void
    on_new ()
    {
        m_SourceView.new_document ();
        m_Undo.sensitive = false;
        m_Redo.sensitive = false;
        m_Save.sensitive = false;
        m_SaveAs.sensitive = false;
        m_Hide.sensitive = false;
        m_Build.sensitive = false;
        m_Preview.hide ();
        title = "New manifest*";
    }


    private void
    on_open ()
    {
        var dialog = new Gtk.FileChooserDialog ("Open Manifest", this, Gtk.FileChooserAction.OPEN,
                                                Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                                                Gtk.Stock.OPEN, Gtk.ResponseType.ACCEPT);

        var filter = new Gtk.FileFilter ();
        filter.set_name ("Manifest");
        filter.add_pattern ("*.manifest");
        dialog.add_filter (filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT)
        {
            m_SourceView.load (dialog.get_filename ());

            m_Undo.sensitive = false;
            m_Redo.sensitive = false;
            m_Save.sensitive = m_SourceView.buffer.get_modified ();
            m_SaveAs.sensitive = true;
            m_Hide.sensitive = false;
            m_Build.sensitive = true;
            m_Preview.hide ();

            title = "%s".printf (m_SourceView.filename);

            uint id = m_Bar.get_context_id ("File Operations");
            m_Bar.push (id, "%s loaded.".printf (m_SourceView.filename));
        }
        dialog.destroy ();
    }

    private void
    on_save ()
    {
        if (m_SourceView.filename != null)
        {
            m_SourceView.save ();
            m_Save.sensitive = m_SourceView.buffer.get_modified ();
            m_SaveAs.sensitive = true;
            m_Build.sensitive = true;

            title = "%s".printf (m_SourceView.filename);

            uint id = m_Bar.get_context_id ("File Operations");
            m_Bar.push (id, "%s saved.".printf (m_SourceView.filename));
        }
        else
        {
            on_save_as ();
        }
    }

    private void
    on_save_as ()
    {
        var dialog = new Gtk.FileChooserDialog ("Save Manifest as", this, Gtk.FileChooserAction.SAVE,
                                                Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                                                Gtk.Stock.SAVE, Gtk.ResponseType.ACCEPT);
        dialog.set_do_overwrite_confirmation (true);
        var filter = new Gtk.FileFilter ();
        filter.set_name ("Manifest");
        filter.add_pattern ("*.manifest");
        dialog.add_filter (filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT)
        {
            m_SourceView.save (dialog.get_filename ());
            m_Save.sensitive = m_SourceView.buffer.get_modified ();
            m_SaveAs.sensitive = true;
            m_Build.sensitive = true;

            title = "%s".printf (m_SourceView.filename);

            uint id = m_Bar.get_context_id ("File Operations");
            m_Bar.push (id, "%s saved.".printf (m_SourceView.filename));
        }
        dialog.destroy ();
    }

    private void
    on_undo ()
    {
        var undo_manager = (m_SourceView.buffer as Gtk.SourceBuffer).undo_manager;
        undo_manager.undo ();
    }

    private void
    on_redo ()
    {
        var undo_manager = (m_SourceView.buffer as Gtk.SourceBuffer).undo_manager;
        undo_manager.redo ();
    }

    private void
    on_build ()
    {
        if (m_SourceView.filename != null)
        {
            try
            {
                m_Canvas.load_from_file (m_SourceView.filename);
                m_Preview.show ();
                m_Hide.sensitive = true;
            }
            catch (GLib.Error err)
            {
                print("%s\n", err.message);
                uint id = m_Bar.get_context_id ("Build");
                m_Bar.push (id, err.message);
            }
        }
    }
}

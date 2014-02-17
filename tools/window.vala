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
    private Gtk.ToolButton m_Toolbox;
    private Gtk.ToolButton m_Dump;
    private Gtk.Statusbar m_Bar;
    private Gtk.Container m_Preview;
    private Gtk.Container m_PreviewBox;
    private Gtk.Entry m_Search;
    private Gtk.Entry m_Replace;
    private Gtk.Button m_ReplaceButton;
    private Maia.Gtk.Canvas m_Canvas;
    private Gtk.VBox m_Shortcuts;

    // methods
    public Window ()
    {
        set_default_size (1024, 600);

        var builder = new Gtk.Builder();

        try
        {
            title = "New manifest*";

            //builder.add_from_file (Config.MAIA_UI_PATH + "/canvas-editor.ui");
            builder.add_from_file ("canvas-editor.ui");
            var content = builder.get_object ("content") as Gtk.Widget;
            add (content);

            var sv = builder.get_object ("sourceview") as Gtk.Container;
            m_SourceView =  new SourceView ();
            m_SourceView.show ();
            sv.add (m_SourceView);

            m_PreviewBox = builder.get_object ("preview_box") as Gtk.Container;

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
                m_PreviewBox.hide ();
                m_Hide.sensitive = false;
                m_Build.sensitive = true;
                m_Toolbox.sensitive = false;
                m_Dump.sensitive = false;
                m_Canvas.clear ();
                m_Shortcuts.@foreach ((w) => {
                    m_Shortcuts.remove (w);
                });
            });

            m_Toolbox = builder.get_object ("toolbox") as Gtk.ToolButton;
            m_Toolbox.sensitive = false;
            m_Toolbox.clicked.connect (() => {
                if (m_Canvas.toolbox != null)
                {
                    if (m_Canvas.toolbox.visible)
                        m_Canvas.toolbox.hide ();
                    else
                        m_Canvas.toolbox.show ();
                }
            });

            m_Dump = builder.get_object ("dump") as Gtk.ToolButton;
            m_Dump.sensitive = false;
            m_Dump.clicked.connect (on_dump);


            var search_replace = builder.get_object("search_replace") as Gtk.Container;
            m_Search = builder.get_object("search_entry") as Gtk.Entry;
            m_Search.primary_icon_sensitive = false;
            m_Search.secondary_icon_sensitive = false;
            m_Search.changed.connect (() => {
                m_Search.primary_icon_sensitive = m_Search.text.length > 0;
                m_Search.secondary_icon_sensitive = m_Search.text.length > 0;
                m_Replace.sensitive = m_Search.text.length > 0;
                m_ReplaceButton.sensitive = m_Search.text.length > 0;
            });
            m_Search.activate.connect (on_search);
            m_Search.icon_press.connect ((i, e) => {
                if (i == Gtk.EntryIconPosition.PRIMARY)
                {
                    on_search ();
                }
                else if (i == Gtk.EntryIconPosition.SECONDARY)
                {
                    m_Search.text = "";
                }
            });

            m_ReplaceButton = builder.get_object("replace") as Gtk.Button;
            m_ReplaceButton.sensitive = false;
            m_ReplaceButton.clicked.connect (on_replace);

            m_Replace = builder.get_object("replace_entry") as Gtk.Entry;
            m_Replace.sensitive = false;
            m_Replace.secondary_icon_sensitive = false;
            m_Replace.changed.connect (() => {
                m_Replace.secondary_icon_sensitive = m_Replace.text.length > 0;
            });
            m_Replace.activate.connect (on_replace);
            m_Replace.icon_press.connect ((i, e) => {
                if (i == Gtk.EntryIconPosition.SECONDARY)
                {
                    m_Replace.text = "";
                }
            });

            var search = builder.get_object("search") as Gtk.ToolButton;
            search.clicked.connect (() => {
                if (search_replace.visible)
                {
                    search_replace.hide ();
                }
                else
                {
                    search_replace.show ();
                    m_Search.grab_focus ();
                }
            });

            var quit = builder.get_object ("exit") as Gtk.ToolButton;
            quit.clicked.connect (on_quit);

            m_Bar = builder.get_object ("statusbar") as Gtk.Statusbar;
            m_Shortcuts = builder.get_object ("shortcuts") as Gtk.VBox;

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

        destroy.connect (on_quit);
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
        m_Toolbox.sensitive = false;
        m_Dump.sensitive = false;
        m_Build.sensitive = false;
        m_PreviewBox.hide ();
        title = "New manifest*";
    }

    private void
    on_dump ()
    {
        if (m_Canvas.root != null)
        {
            string dump = m_Canvas.root.to_string ();
            if (dump != "")
            {
                print (@"$dump\n");
            }
        }
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

        if (m_SourceView.filename != null)
        {
            string dir = GLib.Path.get_dirname (m_SourceView.filename);
            dialog.set_current_folder (dir);
        }
        else
        {
            dialog.set_current_folder (GLib.Environment.get_current_dir ());
        }

        if (dialog.run () == Gtk.ResponseType.ACCEPT)
        {
            if (m_SourceView.buffer.get_modified ())
            {
                string message = "<span size='x-large'><b>Manifest %s is not saved.</b>\nDo you want save it before quit?</span>".printf (m_SourceView.filename ?? "New manifest");
                Gtk.MessageDialog msg = new Gtk.MessageDialog.with_markup (this, Gtk.DialogFlags.MODAL,
                                                                           Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
                                                                           message);
                if (msg.run() == Gtk.ResponseType.YES)
                {
                    on_save ();
                }
                msg.destroy ();
            }
            m_SourceView.load (dialog.get_filename ());

            m_Undo.sensitive = false;
            m_Redo.sensitive = false;
            m_Save.sensitive = m_SourceView.buffer.get_modified ();
            m_SaveAs.sensitive = true;
            m_Hide.sensitive = false;
            m_Toolbox.sensitive = false;
            m_Dump.sensitive = false;
            m_Build.sensitive = true;
            m_PreviewBox.hide ();

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
        if (m_SourceView.filename != null && !m_PreviewBox.visible)
        {
            on_save ();
            try
            {
                m_Canvas.load_from_file (m_SourceView.filename);
                foreach (unowned Gtk.Button button in m_Canvas.get_shortcut_buttons ())
                {
                    m_Shortcuts.pack_start (button);
                }
                m_PreviewBox.show ();
                m_Hide.sensitive = true;
                m_Toolbox.sensitive = m_Canvas.toolbox != null;
                m_Dump.sensitive = true;
                m_Build.sensitive = false;
            }
            catch (GLib.Error err)
            {
                Gtk.MessageDialog msg = new Gtk.MessageDialog.with_markup (this, Gtk.DialogFlags.MODAL,
                                                                           Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
                                                                           "<span size='x-large'><b>Error on read manifest:</b></span><span size='large'>\n" + err.message + "</span>");
                msg.run();
                msg.destroy ();

                uint id = m_Bar.get_context_id ("Build");
                m_Bar.push (id, err.message);
            }
        }
    }

    private void
    on_search ()
    {
        m_SourceView.search (m_Search.text);
    }

    private void
    on_replace ()
    {
        m_SourceView.replace (m_Search.text, m_Replace.text);
    }

    private void
    on_quit ()
    {
        if (m_SourceView.buffer.get_modified ())
        {
            string message = "<span size='x-large'><b>Manifest %s is not saved.</b>\nDo you want save it before quit?</span>".printf (m_SourceView.filename ?? "New manifest");
            Gtk.MessageDialog msg = new Gtk.MessageDialog.with_markup (this, Gtk.DialogFlags.MODAL,
                                                                       Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
                                                                       message);
            if (msg.run() == Gtk.ResponseType.YES)
            {
                on_save ();
            }
            msg.destroy ();
        }

        Gtk.main_quit ();
    }
}

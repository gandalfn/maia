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

    // methods
    public Window ()
    {
        set_default_size (1024, 768);

        var builder = new Gtk.Builder();

        try
        {
            builder.add_from_file ("canvas-editor.ui");
            var content = builder.get_object ("content") as Gtk.Widget;
            add (content);

            var sv = builder.get_object ("sourceview") as Gtk.Container;
            m_SourceView =  new SourceView ();
            m_SourceView.show ();
            sv.add (m_SourceView);

            var open = builder.get_object ("open") as Gtk.ToolButton;
            open.clicked.connect (on_open);

            var quit = builder.get_object ("exit") as Gtk.ToolButton;
            quit.clicked.connect (Gtk.main_quit);
        }
        catch (GLib.Error err)
        {
            critical ("Error on loading canvas-editor.ui: %s", err.message);
        }

        destroy.connect (Gtk.main_quit);
    }

    private void
    on_open ()
    {
        var dialog = new Gtk.FileChooserDialog ("Open manifest", this, Gtk.FileChooserAction.OPEN,
                                                Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                                                Gtk.Stock.OPEN, Gtk.ResponseType.ACCEPT);
        if (dialog.run () == Gtk.ResponseType.ACCEPT)
        {
            m_SourceView.load (dialog.get_filename ());
        }
        dialog.destroy ();
    }
}

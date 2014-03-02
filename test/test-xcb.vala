/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-xcb.vala
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

const string manifest = "Window.test {" +
                        "    background_pattern: #CECECE;" +
                        "    Grid.grid {" +
                        "       left_padding: 12;" +
                        "       right_padding: 12;" +
                        "       row_spacing: 12;" +
                        "       column_spacing: 12;" +
                        "       Label.label {" +
                        "           columns: 2;" +
                        "           text: 'Youpi !!!!!\nvive la karioka';" +
                        "           font_description: 'Liberation Sans 48';" +
                        "           stroke_pattern: rgb (0, 0, 0);" +
                        "       }" +
                        "       Button.cancel {" +
                        "           stroke-pattern: #000000;" +
                        "           button-color: #B0B0B0;" +
                        "           row: 1;" +
                        "           font-description: 'Liberation Bold 14';" +
                        "           label: 'Cancel';" +
                        "       }" +
                        "       Button.ok {" +
                        "           stroke-pattern: #000000;" +
                        "           button-color: #B0B0B0;" +
                        "           row: 1;" +
                        "           column: 1;" +
                        "           font-description: 'Liberation Bold 14';" +
                        "           label: 'OK';" +
                        "       }" +
                        "   }" +
                        "}";

void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "test-xcb"));

    var application = new Maia.Application ("test-xcb", 60, { "xcb" });

    try
    {
        var document = new Maia.Manifest.Document.from_buffer (manifest, manifest.length);

        // Get window item
        var window = document["test"] as Maia.Window;
        application.add (window);
        window.visible = true;

        window.destroy_event.subscribe (() => { application.quit (); });

        // Run application
        application.run ();
    }
    catch (GLib.Error err)
    {
        Maia.Log.error (GLib.Log.METHOD, Maia.Log.Category.MANIFEST_PARSING, "error on parsing: %s", err.message);
    }
}

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
                        "       Image.image {" +
                        "           row: 1;" +
                        "           size: 128, 128;" +
                        "           filename: /usr/share/pixmaps/gksu.png;" +
                        "       }" +
                        "       Entry.entry {" +
                        "           row: 1;" +
                        "           column: 1;" +
                        "           lines: 6;" +
                        "       }" +
                        "       DrawingArea.clinical_draw {" +
                        "           row: 2;" +
                        "           columns: 2;" +
                        "           Label.label_draw {" +
                        "               position: 10, 10;" +
                        "               stroke-pattern: #000000;" +
                        "               font-description: 'Liberation Sans Bold 14';" +
                        "               text: 'Label drawing';" +
                        "           }" +
                        "           Rectangle.rectangle_draw {" +
                        "               position: 20, 100;" +
                        "               size: 100, 100;" +
                        "               fill-pattern: #00FF00;" +
                        "           }" +
                        "           Path.path_draw {" +
                        "               position: 50, 100;" +
                        "               path: 'M 0,0 L 50,50 L 0,50 Z';" +
                        "               fill-pattern: linear-gradient (0, 0, @width, 0," +
                        "                                              color-stop (0, rgb (0, 1, 0))," +
                        "                                              color-stop (1, rgb (0, 0, 1)));" +
                        "           }" +
                        "       }" +
                        "       Button.cancel {" +
                        "           stroke-pattern: #000000;" +
                        "           button-color: #B0B0B0;" +
                        "           row: 3;" +
                        "           font-description: 'Liberation Bold 14';" +
                        "           label: 'Cancel';" +
                        "       }" +
                        "       Button.ok {" +
                        "           stroke-pattern: #000000;" +
                        "           button-color: #B0B0B0;" +
                        "           row: 3;" +
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

        var cancel = window.find (GLib.Quark.from_string ("cancel")) as Maia.Button;
        cancel.clicked.connect (() => {
            application.quit ();
        });

        var entry = window.find (GLib.Quark.from_string ("entry")) as Maia.Entry;
        var ok = window.find (GLib.Quark.from_string ("ok")) as Maia.Button;
        ok.clicked.connect (() => {
            print ("text: %s\n", entry.text);
        });

        // Run application
        application.run ();
    }
    catch (GLib.Error err)
    {
        Maia.Log.error (GLib.Log.METHOD, Maia.Log.Category.MANIFEST_PARSING, "error on parsing: %s", err.message);
    }
}

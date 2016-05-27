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
                        "    border: 5;" +
                        "    transform: scale (1.2, 1.2);" +
                        "    Grid.grid {" +
                        "       row_spacing: 12;" +
                        "       column_spacing: 12;" +
                        "       Label.label {" +
                        "           yexpand: false;" +
                        "           columns: 2;" +
                        "           text: 'Youpi !!!!!\ndansons la karioka';" +
                        "           font_description: 'Liberation Sans 24';" +
                        "           stroke_pattern: rgb (0, 0, 0);" +
                        "       }" +
                        "       Image.image {" +
                        "           row: 1;" +
                        "           xexpand: false;" +
                        "           yexpand: false;" +
                        "           size: 128, 128;" +
                        "           filename: /usr/share/pixmaps/gksu.png;" +
                        "       }" +
                        "       Entry.entry {" +
                        "           row: 1;" +
                        "           column: 1;" +
                        "           yexpand: false;" +
                        "           lines: 6;" +
                        "       }" +
                        "       SeekBar.progress_bar {" +
                        "           row: 3;" +
                        "           columns: 2;" +
                        "           size: 20,20;" +
                        "           yexpand: false;" +
                        "           background_pattern: #FAFAFA;" +
                        "           stroke_pattern: #A6A6A6;" +
                        "           fill_pattern: shade (#DBDBDB, 0.1);" +
                        "       }" +
                        "       Combo.combo {" +
                        "           row: 2;" +
                        "           columns: 2;" +
                        "           yexpand: false;" +
                        "           fill-pattern: states (normal, rgba (0.4, 0.4, 0.4, 0.85)," +
                        "                                 prelight, rgba (0.1, 0.1, 0.1, 0.6));" +
                        "           View.view_combo {"+
                        "               [" +
                        "                   Label.label_combo {" +
                        "                       alignment: left;" +
                        "                       text: @label;" +
                        "                   }" +
                        "               ]" +
                        "           }" +
                        "       }" +
                        "       DrawingArea.clinical_draw {" +
                        "           row: 4;" +
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
                        "           LineShape.line {" +
                        "               fill-pattern: states(active, #0000FF);" +
                        "               stroke-pattern: states(normal, #000000, active, #FF0000);" +
                        "               caliper-line-width: 2;" +
                        "               caliper-size: 8, 8;" +
                        "               line-type: dash;" +
                        "               position: 50, 50;" +
                        "           }" +
                        "           EllipseShape.ellipse {" +
                        "               fill-pattern: states(active, #0000FF);" +
                        "               stroke-pattern: states(normal, #000000, active, #FF0000);" +
                        "               caliper-line-width: 2;" +
                        "               caliper-size: 8, 8;" +
                        "               line-type: dash;" +
                        "               position: 50, 50;" +
                        "               begin: 0, 0;" +
                        "               end: 50, 25;" +
                        "               radius: 65;" +
                        "           }" +
                        "       }" +
                        "       Button.cancel {" +
                        "           yexpand: false;" +
                        "           stroke-pattern: #000000;" +
                        "           button-color: #B0B0B0;" +
                        "           row: 5;" +
                        "           font-description: 'Liberation Bold 14';" +
                        "           label: 'Cancel';" +
                        "       }" +
                        "       Button.ok {" +
                        "           yexpand: false;" +
                        "           stroke-pattern: #000000;" +
                        "           button-color: #B0B0B0;" +
                        "           row: 5;" +
                        "           column: 1;" +
                        "           font-description: 'Liberation Bold 14';" +
                        "           label: 'OK';" +
                        "       }" +
                        "   }" +
                        "}";

void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.CANVAS_GEOMETRY, "test-xcb"));

    var application = new Maia.Application ("test-xcb", 60, { "gtk" });

    try
    {
        var document = new Maia.Manifest.Document.from_buffer (manifest, manifest.length);

        // Get window item
        var window = document["test"] as Maia.Window;
        application.add (window);
        window.visible = true;

        window.destroy_event.subscribe (() => { application.quit (); });

        Maia.Core.List<unowned Maia.InputDevice> devices = new Maia.Core.List<unowned Maia.InputDevice> ();
//~         var input_devices = new Maia.InputDevices ();
//~         foreach (var device in input_devices)
//~         {
//~             print (@"device: $(device.name) master:$(device.master)\n");

//~             if (device.name == "Mt-Manager Pointer - Elo Touch Solutions - Elo Touch Solutions Pcap USB Interfa" ||
//~                 device.device_type == Maia.InputDevice.Type.KEYBOARD)
//~             {
//~                 print (@"device: $device master:$(device.master)\n");
//~                 device.master = true;
//~                 devices.insert (device);
//~             }
//~         }

//~         window.input_devices = devices;

        window.grab_key (Maia.Modifier.NONE, Maia.Key.F2);
        window.key_press_event.connect (() => {
            print(@"key pressed\n");
        });

        var cancel = window.find (GLib.Quark.from_string ("cancel")) as Maia.Button;
        cancel.clicked.subscribe (() => {
            print("quit\n");
            application.quit ();
        });

        var ok = window.find (GLib.Quark.from_string ("ok")) as Maia.Button;
        ok.clicked.subscribe (() => {
            print ("%s\n", window.dump (""));
        });

        var model = new Maia.Model ("model", "label", typeof (string));
        uint row;
        model.append_row (out row);
        model.set_values (row, "label", "test 1");
        model.append_row (out row);
        model.set_values (row, "label", "test 2");
        model.append_row (out row);
        model.set_values (row, "label", "test 3");
        model.append_row (out row);
        model.set_values (row, "label", "test 4");
        model.append_row (out row);
        model.set_values (row, "label", "test 5");

        var combo = window.find (GLib.Quark.from_string ("combo")) as Maia.Combo;
        combo.view.model = model;
        combo.active_row = 0;

        var progress_bar = window.find (GLib.Quark.from_string ("progress_bar")) as Maia.ProgressBar;
        progress_bar.adjustment = new Maia.Adjustment.with_properties (0, 100, 10, 1);
        progress_bar.adjustment.@value = 43;

        // Run application
        application.run ();
    }
    catch (GLib.Error err)
    {
        Maia.Log.error (GLib.Log.METHOD, Maia.Log.Category.MANIFEST_PARSING, "error on parsing: %s", err.message);
    }
}

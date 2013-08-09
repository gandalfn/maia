/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-canvas.vala
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

public class Maia.TestCanvas : Maia.TestCase
{
    const string MANIFEST = "Group.root {" +
                            "   background: #FFFFFF;" +
                            "   size: 300, 300;" +
                            "   Path.triangle {" +
                            "       layer: 1;" +
                            "       position: 50, 50;" +
                            "       line-width: 4;" +
                            "       stroke-color: rgb(0, 1, 0);" +
                            "       path: M 0 0 L 50 0 L 25 50 L 0 0 Z;" +
                            "   }" +
                            "   Rectangle.rectangle {" +
                            "       position: 10, 10;" +
                            "       transform: scale(2, 2);" +
                            "       size: 140, 140;" +
                            "       fill-color: linear-gradient(0, 280, 0, 10," +
                            "                                   color-stop(0,   rgb(0.9, 0.1, 0.1))," +
                            "                                   color-stop(0.5, rgb(0.4, 0.1, 0.1))," +
                            "                                   color-stop(1,   rgb(0.1, 0.1, 0.1)));" +
                            "   }" +
                            "   Image.image {" +
                            "       position: 150, 150;" +
                            "       size: 32, 32;" +
                            "       layer: 2;" +
                            "       filename: /usr/share/icons/gnome/24x24/actions/gtk-cut.png;" +
                            "   }" +
                            "   Label.label {" +
                            "       position: 150, 150;" +
                            "       stroke-color: #ffffff;" +
                            "       layer: 1;" +
                            "       font-description: Droid Sans 16;" +
                            "       text: It's Rocks;" +
                            "   }" +
                            "}";

    const string GRID_MANIFEST = "Grid.root {" +
                                 "  Grid.content {" +
                                 "   top_padding: 5;" +
                                 "   bottom_padding: 5;" +
                                 "   left_padding: 5;" +
                                 "   right_padding: 5;" +
                                 "   background: image(/usr/share/icons/gnome/256x256/actions/gnome-run.png);" +
                                 "   stroke-color: #000000;" +
                                 "   border-width: 5;" +
                                 "   border-line-width: 2.0;" +
                                 "   grid-line-width: 0.5;" +
                                 "   ToggleGroup.toggle_group { " +
                                 "      active: highlight;" +
                                 "   }" +
                                 "   Image.image {" +
                                 "       row: 0;" +
                                 "       column: 0;" +
                                 "       yexpand: false;" +
                                 "       xexpand: false;" +
                                 "       size: 64, 64;" +
                                 "       top_padding: 5;" +
                                 "       bottom_padding: 5;" +
                                 "       right_padding: 5;" +
                                 "       left_padding: 5;" +
                                 "       filename: /usr/share/icons/gnome/256x256/actions/gnome-run.png;" +
                                 "   }" +
                                 "   Label.title {" +
                                 "       row: 0;" +
                                 "       column: 1;" +
                                 "       yexpand: false;" +
                                 "       stroke-color: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       text: Title;" +
                                 "   }" +
                                 "   Label.name_label {" +
                                 "       row: 1;" +
                                 "       column: 0;" +
                                 "       transform: rotate (pi/2);" +
                                 "       xexpand: false;" +
                                 "       stroke-color: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       text: Name:;" +
                                 "   }" +
                                 "   Label.name_value {" +
                                 "       row: 1;" +
                                 "       column: 1;" +
                                 "       stroke-color: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       text: Toto;" +
                                 "   }" +
                                 "   CheckButton.check1 {" +
                                 "       row: 2;" +
                                 "       column: 0;" +
                                 "       xfill: false;" +
                                 "       yfill: false;" +
                                 "       fill_color: #C0C0C0;" +
                                 "       group: toggle_group;" +
                                 "       stroke-color: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       label: Test check button;" +
                                 "   }" +
                                 "   Highlight.highlight {" +
                                 "       row: 2;" +
                                 "       column: 1;" +
                                 "       group: toggle_group;" +
                                 "       fill_color: #C0C0C0;" +
                                 "       stroke-color: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       label: Test highlight;" +
                                 "   }" +
                                 "  }" +
                                 "}";

    private global::Gtk.Window window;

    public TestCanvas ()
    {
        base ("canvas");

        add_test ("widget", test_canvas_widget);
        add_test ("manifest", test_canvas_manifest);
        add_test ("grid", test_canvas_grid);
        add_test ("worksheet", test_canvas_worksheet);
    }

    public override void
    set_up ()
    {
        window = new global::Gtk.Window ();
        window.show ();
        window.destroy.connect (global::Gtk.main_quit);
    }

    public override void
    tear_down ()
    {
        window = null;
    }

    public void
    test_canvas_widget ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.refresh_rate = 50;
        canvas.show ();
        window.add (canvas);

        global::Gtk.main ();
    }

    public void
    test_canvas_manifest ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.refresh_rate = 50;
        canvas.show ();
        try
        {
            canvas.load (MANIFEST, "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        assert (canvas.root != null);
        canvas.root.button_press_event.connect (() => {
            Test.message ("root button press");

            return true;
        });


        var rectangle = canvas.root.find (GLib.Quark.from_string ("rectangle")) as Rectangle;
        assert (rectangle != null);
        rectangle.button_press_event.connect (() => {
            Test.message ("rectangle button press");
            //rectangle.grab_pointer (rectangle);

            return true;
        });

        var image = canvas.root.find (GLib.Quark.from_string ("image")) as Image;
        image.button_press_event.connect (() => {
            Test.message ("image button press");

            return true;
        });
        assert (image != null);
        assert (image.layer == 2);

        var triangle = canvas.root.find (GLib.Quark.from_string ("triangle")) as Path;
        assert (triangle != null);
        triangle.button_press_event.connect (() => {
            Test.message ("triangle button press");

            return true;
        });

        var label = canvas.root.find (GLib.Quark.from_string ("label")) as Label;
        assert (label != null);
        label.button_press_event.connect (() => {
            Test.message ("label button press");

            return true;
        });

        double progress = 0;
        GLib.Timeout.add (100, () => {
            progress += (GLib.Math.PI * 2.0) / 360;
            var t = new Graphic.Transform.identity ();
            t.rotate (progress);
            label.transform = t;
            Test.message ("label progress: %g", progress);
            return true;
        });


        window.add (canvas);

//~         GLib.Timeout.add (100, () => {
//~             image.position = Graphic.Point (Test.rand_int_range (0, 200), Test.rand_int_range (0, 200));
//~             Test.message ("image position: %s", image.position.to_string ());
//~             return true;
//~         });

        global::Gtk.main ();
    }

    public void
    test_canvas_grid ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.refresh_rate = 50;
        canvas.show ();
        try
        {
            canvas.load (GRID_MANIFEST, "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        assert (canvas.root != null);
        canvas.root.button_press_event.connect (() => {
            Test.message ("root button press");

            return true;
        });


        window.add (canvas);

        global::Gtk.main ();
    }

    public void
    test_canvas_worksheet ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.refresh_rate = 50;
        canvas.show ();
        try
        {
            canvas.load_from_file ("worksheet.manifest", "worksheet");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }

        var scrolled_window = new global::Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = global::Gtk.PolicyType.AUTOMATIC;
        scrolled_window.vscrollbar_policy = global::Gtk.PolicyType.AUTOMATIC;
        scrolled_window.show ();
        scrolled_window.add (canvas);

        string dump = canvas.root.to_string ();
        try
        {
            GLib.FileUtils.set_contents("worksheet.dump", dump);
        }
        catch (GLib.FileError err)
        {
            Test.message (err.message);
            assert (false);
        }

        window.add (scrolled_window);

        global::Gtk.main ();
    }
}

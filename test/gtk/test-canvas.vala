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
                            "   background_pattern: #FFFFFF;" +
                            "   size: 300, 300;" +
                            "   Path.triangle {" +
                            "       layer: 1;" +
                            "       position: 50, 50;" +
                            "       line-width: 4;" +
                            "       stroke-pattern: rgb(0, 1, 0);" +
                            "       path: M 0 0 L 50 0 L 25 50 L 0 0 Z;" +
                            "   }" +
                            "   Rectangle.rectangle {" +
                            "       position: 10, 10;" +
                            "       transform: scale(2, 2);" +
                            "       size: 140, 140;" +
                            "       fill-pattern: linear-gradient(0, 0, 0, @height," +
                            "                                     color-stop(0,   rgb(0.9, 0.1, 0.1))," +
                            "                                     color-stop(0.5, rgb(0.1, 0.4, 0.1))," +
                            "                                     color-stop(1,   rgb(0.1, 0.1, 0.1)));" +
                            "   }" +
                            "   Image.image {" +
                            "       position: 150, 150;" +
                            "       size: 32, 32;" +
                            "       layer: 2;" +
                            "       filename: /usr/share/icons/gnome/24x24/actions/gtk-cut.png;" +
                            "   }" +
                            "   Label.label {" +
                            "       position: 150, 150;" +
                            "       stroke-pattern: #ffffff;" +
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
                                 "   background_pattern: image(/usr/share/icons/gnome/256x256/actions/gnome-run.png);" +
                                 "   stroke-pattern: #000000;" +
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
                                 "       stroke-pattern: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       text: Title;" +
                                 "   }" +
                                 "   Label.name_label {" +
                                 "       row: 1;" +
                                 "       column: 0;" +
                                 "       transform: rotate (pi/2);" +
                                 "       xexpand: false;" +
                                 "       stroke-pattern: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       text: Name:;" +
                                 "   }" +
                                 "   Label.name_value {" +
                                 "       row: 1;" +
                                 "       column: 1;" +
                                 "       stroke-pattern: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       text: Toto;" +
                                 "   }" +
                                 "   CheckButton.check1 {" +
                                 "       row: 2;" +
                                 "       column: 0;" +
                                 "       xfill: false;" +
                                 "       yfill: false;" +
                                 "       fill-pattern: #C0C0C0;" +
                                 "       group: toggle_group;" +
                                 "       stroke-pattern: #000000;" +
                                 "       font-description: Droid Sans 16;" +
                                 "       label: Test check button;" +
                                 "   }" +
                                 "   Highlight.highlight {" +
                                 "       row: 2;" +
                                 "       column: 1;" +
                                 "       group: toggle_group;" +
                                 "       fill-pattern: #C0C0C0;" +
                                 "       stroke-pattern: #000000;" +
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
        add_test ("image-data-svg", test_canvas_image_data_svg);
        add_test ("image-background-svg", test_canvas_group_background_svg);
        add_test ("combo", test_canvas_combo);
        add_test ("worksheet-model", test_canvas_worksheet_model);
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
        canvas.show ();
        window.add (canvas);

        global::Gtk.main ();
    }

    public void
    test_canvas_manifest ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
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

        GLib.Timeout.add (100, () => {
            image.position = Graphic.Point (Test.rand_int_range (0, 200), Test.rand_int_range (0, 200));
            Test.message ("image position: %s", image.position.to_string ());
            return true;
        });

        global::Gtk.main ();
    }

    public void
    test_canvas_grid ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
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
        window.set_size_request (700, 700);

        GLib.Timeout.add_seconds (3, () => {
            unowned Item item = canvas.root.find (GLib.Quark.from_string ("main_2")) as Item;
            print ("item visible\n");
            item.visible = !item.visible;
            return true;
        });
        Maia.Document[] documents = {};
        documents += canvas.root as Document;
        documents += canvas.root as Document;

        Cairo.generate_report.begin ("test.pdf", 300, documents, null, (obj, res) => {
            Cairo.generate_report.end (res);
            print ("test.pdf generated\n");
            window.show ();
        });

        window.hide ();

        global::Gtk.main ();
    }

    public void
    test_canvas_image_data_svg ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.show ();
        try
        {
            canvas.load ("Group.root {" +
                         "   Image.image {" +
                         "       [" +
                         """<svg width="1300" height="900" xmlns="http://www.w3.org/2000/svg">""" +
                         "<g>" +
                         """<path fill="#FFFFFF" stroke="#000000" stroke-width="3" d="m358.6629,436.63846"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m347.6629,13.63845v233.99999c59,55.00002 55,97.00002 55,97.00002c17.42398,-31.849 32.20801,-65.62802 33.13599,-102.47701c0.57703,-22.89299 -0.13599,-45.92299 -0.16995,-68.82898c-0.01004,-6.89801 0.11398,-13.79701 0.03299,-20.69402"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m421.11191,671.79248l0.55099,-227.15302c-3,-22 7,-63 7,-63c17.37997,-24.33002 26.92001,-54.64001 34.61005,-83.24002c0.94,-3.50998 1.72998,-12.06 2.36993,-22.75998"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m467.6629,151.63844"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m466.42291,259.62946c0.84003,-20.42 1.23999,-43.14 1.25,-54.23c0,-16.50301 -0.02496,-33.007 -0.01398,-49.51001"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m466.42493,259.62946c0,0 9.23798,9.98999 31.23798,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m465.63989,275.63745c0,0 11.02301,10.99899 32.02301,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m347.6629,14.63845c-27.33002,14.67 -45.85999,-5 -45.85999,-5l0.70996,-0.93c0,0 26.17004,-7.3 44.66,3.73l0.49002,2.2z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m358.6629,678.58545c37.12701,19.92902 62.29999,-6.79303 62.29999,-6.79303l-0.96399,-1.26398c0,0 -35.55099,-9.91699 -60.66901,5.06598l-0.66699,2.99103z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m467.67291,156.47545c-19.24399,12.33099 -32.29199,-4.203 -32.29199,-4.203l0.5,-0.782c0,0 18.42798,-6.136 31.44598,3.13499l0.34601,1.85001z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m358.6629,679.63849v-267.00003c0,0 -65,-31 -56,-145l-0.85498,-258"/>""" +
                         """<path fill="#FFFFFF" stroke="#000000" stroke-width="3" d="m941.33716,437.215"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m952.33716,14.215v234c-59,55 -55,97 -55.00104,97c-17.42401,-31.849 -32.20807,-65.62799 -33.13605,-102.47701c-0.5769,-22.89299 0.13605,-45.92299 0.17004,-68.82899c0.01099,-6.89798 -0.11401,-13.797 -0.03296,-20.694"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m834.35803,276.215c0.64001,10.70001 1.43011,19.25 2.36902,22.76001c7.69006,28.60001 17.23004,58.91 34.61011,83.23999c0,0 10,41 7,63l0.55103,227.15305"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m832.33716,152.215"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m832.34094,156.464c0.01215,16.50301 -0.01379,33.00699 -0.01379,49.51001c0.00989,11.09 0.40894,33.81001 1.25,54.23"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m833.57507,260.20499c0,0 -9.23712,9.98999 -31.23706,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m834.36011,276.21301c0,0 -11.02209,10.99899 -32.02203,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m952.33716,15.215c27.33002,14.67 45.85986,-5 45.85986,-5l-0.71088,-0.93c0,0 -26.16998,-7.3 -44.659,3.73l-0.48999,2.2z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m941.33795,679.16101c-37.12787,19.92902 -62.30096,-6.79303 -62.30096,-6.79303l0.96509,-1.26398c0,0 35.55109,-9.91699 60.66998,5.06598l0.66589,2.99103z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m832.32813,157.05099c19.24402,12.33101 32.29199,-4.203 32.29199,-4.203l-0.50006,-0.782c0,0 -18.42786,-6.136 -31.44592,3.13501l-0.34601,1.84999z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m941.33716,680.21503v-267.00003c0,0 65,-31 56,-145l0.85492,-258"/>""" +
                         "</g>" +
                         "</svg>" +
                         "        ]" +
                         "   }" +
                         "}", "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }

        window.add (canvas);

        global::Gtk.main ();
    }

    public void
    test_canvas_group_background_svg ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.show ();
        try
        {
            canvas.load ("Group.root {" +
                         "   size: 1300, 900;" +
                         """   background_pattern: svg('""" +
                         """<svg width="1300" height="900" xmlns="http://www.w3.org/2000/svg">""" +
                         "<g>" +
                         """<path fill="#FFFFFF" stroke="#000000" stroke-width="3" d="m358.6629,436.63846"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m347.6629,13.63845v233.99999c59,55.00002 55,97.00002 55,97.00002c17.42398,-31.849 32.20801,-65.62802 33.13599,-102.47701c0.57703,-22.89299 -0.13599,-45.92299 -0.16995,-68.82898c-0.01004,-6.89801 0.11398,-13.79701 0.03299,-20.69402"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m421.11191,671.79248l0.55099,-227.15302c-3,-22 7,-63 7,-63c17.37997,-24.33002 26.92001,-54.64001 34.61005,-83.24002c0.94,-3.50998 1.72998,-12.06 2.36993,-22.75998"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m467.6629,151.63844"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m466.42291,259.62946c0.84003,-20.42 1.23999,-43.14 1.25,-54.23c0,-16.50301 -0.02496,-33.007 -0.01398,-49.51001"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m466.42493,259.62946c0,0 9.23798,9.98999 31.23798,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m465.63989,275.63745c0,0 11.02301,10.99899 32.02301,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m347.6629,14.63845c-27.33002,14.67 -45.85999,-5 -45.85999,-5l0.70996,-0.93c0,0 26.17004,-7.3 44.66,3.73l0.49002,2.2z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m358.6629,678.58545c37.12701,19.92902 62.29999,-6.79303 62.29999,-6.79303l-0.96399,-1.26398c0,0 -35.55099,-9.91699 -60.66901,5.06598l-0.66699,2.99103z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m467.67291,156.47545c-19.24399,12.33099 -32.29199,-4.203 -32.29199,-4.203l0.5,-0.782c0,0 18.42798,-6.136 31.44598,3.13499l0.34601,1.85001z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m358.6629,679.63849v-267.00003c0,0 -65,-31 -56,-145l-0.85498,-258"/>""" +
                         """<path fill="#FFFFFF" stroke="#000000" stroke-width="3" d="m941.33716,437.215"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m952.33716,14.215v234c-59,55 -55,97 -55.00104,97c-17.42401,-31.849 -32.20807,-65.62799 -33.13605,-102.47701c-0.5769,-22.89299 0.13605,-45.92299 0.17004,-68.82899c0.01099,-6.89798 -0.11401,-13.797 -0.03296,-20.694"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m834.35803,276.215c0.64001,10.70001 1.43011,19.25 2.36902,22.76001c7.69006,28.60001 17.23004,58.91 34.61011,83.23999c0,0 10,41 7,63l0.55103,227.15305"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m832.33716,152.215"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m832.34094,156.464c0.01215,16.50301 -0.01379,33.00699 -0.01379,49.51001c0.00989,11.09 0.40894,33.81001 1.25,54.23"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m833.57507,260.20499c0,0 -9.23712,9.98999 -31.23706,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m834.36011,276.21301c0,0 -11.02209,10.99899 -32.02203,0"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m952.33716,15.215c27.33002,14.67 45.85986,-5 45.85986,-5l-0.71088,-0.93c0,0 -26.16998,-7.3 -44.659,3.73l-0.48999,2.2z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m941.33795,679.16101c-37.12787,19.92902 -62.30096,-6.79303 -62.30096,-6.79303l0.96509,-1.26398c0,0 35.55109,-9.91699 60.66998,5.06598l0.66589,2.99103z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m832.32813,157.05099c19.24402,12.33101 32.29199,-4.203 32.29199,-4.203l-0.50006,-0.782c0,0 -18.42786,-6.136 -31.44592,3.13501l-0.34601,1.84999z"/>""" +
                         """<path fill="none" stroke="#000000" stroke-width="3" d="m941.33716,680.21503v-267.00003c0,0 65,-31 56,-145l0.85492,-258\"/>""" +
                         "</g>" +
                         """</svg>');""" +
                         "}", "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }

        window.add (canvas);

        global::Gtk.main ();
    }

    public void
    test_canvas_combo ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.show ();
        try
        {
            canvas.load ("Group.root {" +
                         "  Model.model {" +
                         "      Column.val {" +
                         "          column: 0;" +
                         "      }" +
                         "  }" +
                         "  Combo.combo {" +
                         "      font-description: 'Liberation Sans 14';" +
                         "      yexpand: false;" +
                         "      fill-pattern: rgba (0.8, 0.8, 0.8, 0.8);" +
                         "      highligh-color: rgba (0.2, 0.2, 0.2, 0.8);" +
                         "      View.view {"+
                         "          model: model;" +
                         "          [" +
                         "              Label.label {" +
                         "                  xfill: false;" +
                         "                  xalign: 0.0;" +
                         "                  yexpand: false;" +
                         "                  text: @val;" +
                         "              }" +
                         "          ]" +
                         "      }" +
                         "  }" +
                         "}", "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }

        global::Gtk.ListStore list = new global::Gtk.ListStore (1, typeof (string));
        for (int cpt = 0; cpt < 10; ++cpt)
        {
            global::Gtk.TreeIter iter;
            list.append (out iter);

            list.set (iter, 0, "Test %i".printf (Test.rand_int_range (0, 200)));
        }

        unowned Gtk.Model? model = canvas.root.find (GLib.Quark.from_string ("model")) as Gtk.Model;
        assert (model != null);

        model.treemodel = list;

        window.add (canvas);

        global::Gtk.main ();
    }

    public void
    test_canvas_worksheet_model ()
    {
        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        canvas.show ();
        try
        {
            canvas.load_from_file ("../tools/worksheets/breast.manifest", "breast");
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

        Maia.Gtk.Model model = canvas.root.find (GLib.Quark.from_string ("images")) as Maia.Gtk.Model;
        assert (model != null);

        global::Gtk.ListStore list = new global::Gtk.ListStore (2, typeof (string), typeof (string));
        model.treemodel = list;
        try
        {
            var directory = GLib.File.new_for_path ("/home/gandalfn/Images");

            var enumerator = directory.enumerate_children (GLib.FileAttribute.STANDARD_NAME, 0);

            GLib.FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null)
            {
                string filename = file_info.get_name ();
                if (filename.has_suffix (".png"))
                {
                    global::Gtk.TreeIter iter;
                    list.append (out iter);

                    list.set (iter, 0, "/home/gandalfn/Images/" + filename, 1, filename);
                }
            }
        }
        catch (GLib.Error err)
        {
            assert (false);
        }

        string dump = canvas.root.to_string ();
        try
        {
            GLib.FileUtils.set_contents("breast.dump", dump);
        }
        catch (GLib.FileError err)
        {
            Test.message (err.message);
            assert (false);
        }

        window.add (scrolled_window);
        window.set_size_request (700, 700);

        global::Gtk.main ();
    }
}

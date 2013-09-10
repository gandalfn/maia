/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-model.vala
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

public class Maia.TestModel : Maia.TestCase
{
    public TestModel ()
    {
        base ("model");

        add_test ("create", test_model_create);
        add_test ("convert", test_model_convert);
        add_test ("view", test_model_view);
    }

    public void
    test_model_create ()
    {
        string manifest =   "Document.root {" +
                            "   Model.model {" +
                            "       Column.name {" +
                            "           column: 0;" +
                            "       }" +
                            "       Column.val {" +
                            "           column: 1;" +
                            "       }" +
                            "   }" +
                            "}";

        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        try
        {
            canvas.load (manifest, "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        assert (canvas.root != null);

        global::Gtk.ListStore list = new global::Gtk.ListStore (2, typeof (string), typeof (int));
        for (int cpt = 0; cpt < 10; ++cpt)
        {
            global::Gtk.TreeIter iter;
            list.append (out iter);

            list.set (iter, 0, "%i".printf (Test.rand_int_range (0, 200)), 1, Test.rand_int_range (0, 200));
        }

        unowned Gtk.Model? model = canvas.root.find (GLib.Quark.from_string ("model")) as Gtk.Model;
        assert (model != null);

        unowned Gtk.Model.Column column_name = canvas.root.find (GLib.Quark.from_string ("name")) as Gtk.Model.Column;
        assert (column_name != null);

        unowned Gtk.Model.Column column_val = canvas.root.find (GLib.Quark.from_string ("val")) as Gtk.Model.Column;
        assert (column_val != null);

        model.treemodel = list;

        int cpt = 0;
        global::Gtk.TreeIter iter;
        if (list.get_iter_first(out iter))
        {
            do
            {
                string name_list, name_model;
                int val_list, val_model;

                list.get (iter, 0, out name_list, 1, out val_list);

                assert (model["name"][cpt].holds (typeof (string)));
                assert (model["val"][cpt].holds (typeof (int)));

                name_model = (string)model["name"][cpt];
                val_model = (int)model["val"][cpt];
                cpt++;

                assert (name_list == name_model);
                assert (val_list == val_model);
            } while (list.iter_next(ref iter));
        }
    }

    public void
    test_model_convert ()
    {
        string manifest =   "Document.root {" +
                            "   Model.model {" +
                            "       Column.name {" +
                            "           column: 0;" +
                            "       }" +
                            "       Column.val {" +
                            "           column: 1;" +
                            "       }" +
                            "   }" +
                            "}";

        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        try
        {
            canvas.load (manifest, "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        assert (canvas.root != null);

        global::Gtk.ListStore list = new global::Gtk.ListStore (2, typeof (string), typeof (int));
        for (int cpt = 0; cpt < 10; ++cpt)
        {
            global::Gtk.TreeIter iter;
            list.append (out iter);

            list.set (iter, 0, "%i".printf (Test.rand_int_range (0, 200)), 1, Test.rand_int_range (0, 200));
        }

        unowned Gtk.Model? model = canvas.root.find (GLib.Quark.from_string ("model")) as Gtk.Model;
        assert (model != null);

        unowned Gtk.Model.Column column_name = canvas.root.find (GLib.Quark.from_string ("name")) as Gtk.Model.Column;
        assert (column_name != null);

        unowned Gtk.Model.Column column_val = canvas.root.find (GLib.Quark.from_string ("val")) as Gtk.Model.Column;
        assert (column_val != null);

        model.treemodel = list;

        int cpt = 0;
        global::Gtk.TreeIter iter;
        if (list.get_iter_first(out iter))
        {
            do
            {
                var path = list.get_path (iter);
                var path_convert = model.convert_row_to_tree_path (cpt);
                assert (path.compare (path_convert) == 0);

                uint row_convert = model.convert_tree_path_to_row (path);
                assert (cpt == row_convert);

                global::Gtk.TreeIter iter_convert;
                assert (model.convert_row_to_tree_iter (cpt, out iter_convert));
                path_convert = list.get_path (iter_convert);
                assert (path_convert != null);
                assert (path.compare (path_convert) == 0);

                assert (model.convert_tree_iter_to_row (iter, out row_convert));
                assert (cpt == row_convert);

                cpt++;
            } while (list.iter_next(ref iter));
        }
    }

    public void
    test_model_view ()
    {
        string manifest =   "Grid.root {" +
                            "   Model.model {" +
                            "       Column.name {" +
                            "           column: 0;" +
                            "       }" +
                            "       Column.val {" +
                            "           column: 1;" +
                            "       }" +
                            "       Column.color {" +
                            "           column: 2;" +
                            "       }" +
                            "   }" +
                            "   View.view { " +
                            "       model: model;" +
                            "       lines: 2;" +
                            "       [" +
                            "           Grid.cell {" +
                            "               Label.label {" +
                            "                   stroke-pattern: @color;" +
                            "                   font-description: 'Liberation Sans 14';" +
                            "                   text: @name;" +
                            "               }" +
                            "               Image.value {" +
                            "                   row: 1;" +
                            "                   font-description: 'Liberation Sans 14';" +
                            "                   filename: @val;" +
                            "               }" +
                            "           }"+
                            "       ]" +
                            "   }" +
                            "   View.view2 { " +
                            "       column: 1;" +
                            "       model: model;" +
                            "       lines: 2;" +
                            "       [" +
                            "           Grid.cell {" +
                            "               Label.label {" +
                            "                   stroke-pattern: @color;" +
                            "                   font-description: 'Liberation Sans 14';" +
                            "                   text: @name;" +
                            "               }" +
                            "               Image.value {" +
                            "                   row: 1;" +
                            "                   font-description: 'Liberation Sans 14';" +
                            "                   filename: @val;" +
                            "               }" +
                            "           }"+
                            "       ]" +
                            "   }" +
                            "   Button.button { " +
                            "       stroke-pattern: #7997AE;" +
                            "       button-color: #C0C0C0;" +
                            "       row: 1;" +
                            "       yexpand: false;" +
                            "       top_padding: 5;" +
                            "       bottom_padding: 5;" +
                            "       icon-name: 'add';" +
                            "       font-description: 'Liberation Bold 14';" +
                            "       label: TEST;" +
                            "   }" +
                            "}";

        Maia.Gtk.Canvas canvas = new Maia.Gtk.Canvas ();
        try
        {
            canvas.load (manifest, "root");
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        assert (canvas.root != null);

        string[] files = {};
        files += "/usr/share/pixmaps/iceweasel.png";
        files += "/usr/share/pixmaps/icon_epdfview-48.png";
        files += "/usr/share/pixmaps/mlterm-icon-24colors-1.png";
        files += "/usr/share/pixmaps/mlterm-icon-24colors-2.png";
        files += "/usr/share/pixmaps/mlterm-icon-fvwm.png";
        files += "/usr/share/pixmaps/mlterm-icon-gnome2.png";
        files += "/usr/share/pixmaps/mlterm-icon-gnome.png";
        files += "/usr/share/pixmaps/mlterm-icon-kde.png";
        files += "/usr/share/pixmaps/mlterm-icon-twm.png";
        files += "/usr/share/pixmaps/mlterm-icon-wmaker.png";
        files += "/usr/share/pixmaps/monitor.png";
        files += "/usr/share/pixmaps/mono-runtime.png";
        files += "/usr/share/pixmaps/mousepad.png";
        files += "/usr/share/pixmaps/nvidia-settings.png";
        files += "/usr/share/pixmaps/show-desktop.png";
        files += "/usr/share/pixmaps/synaptic.png";
        files += "/usr/share/pixmaps/sysprof-icon-16.png";
        files += "/usr/share/pixmaps/sysprof-icon-24.png";
        files += "/usr/share/pixmaps/sysprof-icon-32.png";
        files += "/usr/share/pixmaps/sysprof-icon-48.png";
        files += "/usr/share/pixmaps/transmission.png";
        files += "/usr/share/pixmaps/workspace-overview.png";
        files += "/usr/share/pixmaps/xchat.png";
        files += "/usr/share/pixmaps/xfce4_xicon1.png";
        files += "/usr/share/pixmaps/xfce4_xicon2.png";
        files += "/usr/share/pixmaps/xfce4_xicon3.png";
        files += "/usr/share/pixmaps/xfce4_xicon4.png";
        files += "/usr/share/pixmaps/xfce4_xicon.png";

        global::Gtk.ListStore list = new global::Gtk.ListStore (3, typeof (string), typeof (string), typeof (string));
        for (int cpt = 0; cpt < 10; ++cpt)
        {
            global::Gtk.TreeIter iter;
            list.append (out iter);
            string color = "#%02i%02i%02i".printf (Test.rand_int_range (0, 255), Test.rand_int_range (0, 255), Test.rand_int_range (0, 255));
            list.set (iter, 0, "%i".printf (Test.rand_int_range (0, 200)),
                            1, files[Test.rand_int_range (0, files.length -1)],
                            2, color);
        }

        unowned Gtk.Model? model = canvas.root.find (GLib.Quark.from_string ("model")) as Gtk.Model;
        assert (model != null);

        unowned Gtk.Model.Column column_name = canvas.root.find (GLib.Quark.from_string ("name")) as Gtk.Model.Column;
        assert (column_name != null);

        unowned Gtk.Model.Column column_val = canvas.root.find (GLib.Quark.from_string ("val")) as Gtk.Model.Column;
        assert (column_val != null);

        unowned Button? button = canvas.root.find (GLib.Quark.from_string ("button")) as Button;
        assert (button != null);
        button.clicked.connect (() => {
            Test.message ("clicked");
        });

        model.treemodel = list;

        var window = new global::Gtk.Window ();
        window.show ();
        window.destroy.connect (global::Gtk.main_quit);

        canvas.show ();
        window.add (canvas);

         GLib.Timeout.add_seconds (3, () => {
            int cpt = 0;
            int r = Test.rand_int_range (0, list.iter_n_children(null));
            global::Gtk.TreeIter iter;
            if (list.get_iter_first(out iter))
            {
                do
                {
                    if (cpt == r)
                    {
                        string name = "%i".printf (Test.rand_int_range (0, 200));
                        string val = files[Test.rand_int_range (0, files.length -1)];
                        string color = "#%02i%02i%02i".printf (Test.rand_int_range (0, 255), Test.rand_int_range (0, 255), Test.rand_int_range (0, 255));
                        Test.message (@"set $r $name $val $color");
                        list.set (iter, 0, name, 1, val, 2, color);
                        break;
                    }
                    cpt++;
                } while (list.iter_next(ref iter));
            }
            r = Test.rand_int_range (0, list.iter_n_children(null));
            if (list.get_iter_first(out iter))
            {
                do
                {
                    if (cpt == r)
                    {
                        list.remove (iter);
                        break;
                    }
                    cpt++;
                } while (list.iter_next(ref iter));
            }

            list.append (out iter);

            string color = "#%02i%02i%02i".printf (Test.rand_int_range (0, 255), Test.rand_int_range (0, 255), Test.rand_int_range (0, 255));
            list.set (iter, 0, "%i".printf (Test.rand_int_range (0, 200)),
                            1, files[Test.rand_int_range (0, files.length -1)],
                            2, color);

            return true;
        });

        global::Gtk.main ();
    }
}

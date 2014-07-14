/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-chart.vala
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
                        "    size: 600, 400;" +
                        "    ChartView.view { " +
                        "       chart-axis: chart;" +
                        "       x-axis-label: 'label x';" +
                        "       x-axis-unit: 'mm';" +
                        "       y-axis-label: 'label y';" +
                        "       y-axis-unit: 'wd';" +
                        "       legend: west;" +
                        "       Chart.chart {" +
                        "           title: 'first\nchart';" +
                        "           stroke-pattern: #FF0000;" +
                        "           line-width: 2.0;" +
                        "           x_axis: x;" +
                        "           y_axis: y1;" +
                        "           range: 0, 0, 120, 450;" +
                        "       }" +
                        "       Chart.chart2 {" +
                        "           title: 'second\nchar';" +
                        "           stroke-pattern: #0000FF;" +
                        "           line-type: dash;" +
                        "           x_axis: x;" +
                        "           y_axis: y2;" +
                        "           range: 0, 0, 120, 450;" +
                        "       }" +
                        "       ChartIntersect.intersect {" +
                        "           first_chart: chart2;" +
                        "           second_chart: chart;" +
                        "           fill-pattern: rgba (0.4, 0.4, 0.4, 0.4);" +
                        "       }" +
                        "       ChartPoint.point {" +
                        "           chart: chart;" +
                        "           title: 'point 1:\nx = 35\ny = 307.5';" +
                        "           position: 35, 307.5;" +
                        "       }" +
                        "       ChartPoint.point2 {" +
                        "           chart: chart;" +
                        "           position: 25, 289.5;" +
                        "       }" +
                        "   }" +
                        "}";

void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.CANVAS_GEOMETRY, "test-xcb"));

    var application = new Maia.Application ("test-chart", 60, { "gtk" });

    try
    {
        var document = new Maia.Manifest.Document.from_buffer (manifest, manifest.length);

        // Get window item
        var window = document["test"] as Maia.Window;
        application.add (window);
        window.visible = true;

        window.destroy_event.subscribe (() => { application.quit (); });

        var model = new Maia.Model ("model", "x", typeof (double), "y1", typeof (double), "y2", typeof (double));
        uint row;
        model.append_row (out row);
        model.set_values (row, "x", 10.0, "y1", 50.0, "y2", 70.0);
        model.append_row (out row);
        model.set_values (row, "x", 20.0, "y1", 120.0, "y2", 140.0);
        model.append_row (out row);
        model.set_values (row, "x", 30.0, "y1", 280.0, "y2", 300.0);
        model.append_row (out row);
        model.set_values (row, "x", 40.0, "y1", 320.0, "y2", 340.0);
        model.append_row (out row);
        model.set_values (row, "x", 50.0, "y1", 350.0, "y2", 370.0);
        model.append_row (out row);
        model.set_values (row, "x", 60.0, "y1", 370.0, "y2", 390.0);
        model.append_row (out row);
        model.set_values (row, "x", 70.0, "y1", 380.0, "y2", 400.0);
        model.append_row (out row);
        model.set_values (row, "x", 80.0, "y1", 385.0, "y2", 405.0);
        model.append_row (out row);
        model.set_values (row, "x", 90.0, "y1", 387.0, "y2", 407.0);
        model.append_row (out row);
        model.set_values (row, "x", 100.0, "y1", 388.0, "y2", 408.0);

        var view = window.find (GLib.Quark.from_string ("view")) as Maia.ChartView;
        view.model = model;

        // Run application
        application.run ();
    }
    catch (GLib.Error err)
    {
        Maia.Log.error (GLib.Log.METHOD, Maia.Log.Category.MANIFEST_PARSING, "error on parsing: %s", err.message);
    }
}

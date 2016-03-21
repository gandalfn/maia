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
                        "    Model.data {" +
                        "       Column.x {" +
                        "           column-type: double;" +
                        "       }" +
                        "       Column.x1 {" +
                        "           column-type: double;" +
                        "       }" +
                        "       Column.y1 {" +
                        "           column-type: double;" +
                        "       }" +
                        "       [" +
                        "           Row.0 {" +
                        "               x: 10.0;" +
                        "               x1: 50.0;" +
                        "               y1: 70.0;" +
                        "           }" +
                        "           Row.1 {" +
                        "               x: 20.0;" +
                        "               x1: 120.0;" +
                        "               y1: 140.0;" +
                        "           }" +
                        "           Row.2 {" +
                        "               x: 30.0;" +
                        "               x1: 280.0;" +
                        "               y1: 300.0;" +
                        "           }" +
                        "           Row.3 {" +
                        "               x: 40.0;" +
                        "               x1: 320.0;" +
                        "               y1: 340.0;" +
                        "           }" +
                        "           Row.4 {" +
                        "               x: 50.0;" +
                        "               x1: 350.0;" +
                        "               y1: 370.0;" +
                        "           }" +
                        "           Row.5 {" +
                        "               x: 60.0;" +
                        "               x1: 370.0;" +
                        "               y1: 390.0;" +
                        "           }" +
                        "           Row.6 {" +
                        "               x: 70.0;" +
                        "               x1: 380.0;" +
                        "               y1: 400.0;" +
                        "           }" +
                        "           Row.7 {" +
                        "               x: 80.0;" +
                        "               x1: 385.0;" +
                        "               y1: 405.0;" +
                        "           }" +
                        "           Row.8 {" +
                        "               x: 90.0;" +
                        "               x1: 387.0;" +
                        "               y1: 407.0;" +
                        "           }" +
                        "           Row.9 {" +
                        "               x: 100.0;" +
                        "               x1: 388.0;" +
                        "               y1: 408.0;" +
                        "           }" +
                        "       ]" +
                        "    }" +
                        "    ChartView.view { " +
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
                        "           path: 'M2,8 A6,6,0,1,0,14,8 M14,8 A6,6,0,1,0,2,8'; " +
                        "           fill-pattern: #FF0000; " +
                        "           position: 35, 307.5;" +
                        "       }" +
                        "       ChartPoint.point2 {" +
                        "           chart: chart;" +
                        "           position: 25, 289.5;" +
                        "       }" +
                        "       model-name: 'data';" +
                        "       chart-axis: chart;" +
                        "       x-axis-label: 'label x';" +
                        "       x-axis-unit: 'mm';" +
                        "       y-axis-label: 'label y';" +
                        "       y-axis-unit: 'wd';" +
                        "       legend: west;" +
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

        print (@"%s\n", window.dump (""));
        // Run application
        application.run ();
    }
    catch (GLib.Error err)
    {
        Maia.Log.error (GLib.Log.METHOD, Maia.Log.Category.MANIFEST_PARSING, "error on parsing: %s", err.message);
    }
}

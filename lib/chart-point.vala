/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * chart-point.vala
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

public class Maia.ChartPoint : Core.Object, Manifest.Element
{
    // accessors
    internal string tag {
        get {
            return "ChartPoint";
        }
    }

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    /**
     * Chart of point
     */
    public string chart { get; set; default = ""; }

    /**
     * Title of point
     */
    public string title { get; set; default = null; }

    /**
     * Position of point
     */
    public Graphic.Point position { get; set; default = Graphic.Point (double.NAN, double.NAN); }

    /**
     * Size of point
     */
    public Graphic.Size size { get; set; default = Graphic.Size (6, 6); }

    /**
     * Fill pattern of point
     */
    public Graphic.Pattern fill_pattern { get; set; default = null; }

    /**
     * Point position line type
     */
    public Graphic.LineType line_type { get; set; default = Graphic.LineType.DASH_DOT; }

    /**
     * Stroke pattern of point
     */
    public Graphic.Pattern stroke_pattern { get; set; default = new Graphic.Color (0, 0, 0); }

    /**
     * Point path
     */
    public string path { get; set; default = "M 0 0 L 16 0 L 16 16 L 0 16 z"; }

    /**
     * Point stroke width
     */
    public double stroke_width { get; set; default = 3.0; }

    // methods
    public ChartPoint (string inId, string inChart, Graphic.Point inPosition)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), chart: inChart, position: inPosition);
    }
}

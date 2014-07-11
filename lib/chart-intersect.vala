/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * chart-intersect.vala
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

public class Maia.ChartIntersect : Core.Object, Manifest.Element
{
    // accessors
    internal string tag {
        get {
            return "ChartIntersect";
        }
    }

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    /**
     * First chart of intersect
     */
    public string first_chart { get; set; default = ""; }

    /**
     * Second chart of intersect
     */
    public string second_chart { get; set; default = ""; }

    /**
     * Fill pattern of intersect
     */
    public Graphic.Pattern fill_pattern { get; set; default = new Graphic.Color (0.6, 0.6, 0.6); }

    // methods
    public ChartIntersect (string inId, string inFirst, string inSecond)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), first_chart: inFirst, second_chart: inSecond);
    }
}

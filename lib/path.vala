/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * path.vala
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

public class Maia.Path : Item, ItemPackable, ItemMovable
{
    // accessors
    internal override string tag {
        get {
            return "Path";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    internal override bool can_focus  {
        get {
            return parent is DrawingArea;
        }
        set {
            base.can_focus = value;
        }
    }

    public string path { get; set; default = ""; }

    // methods
    public Path (string inId, string inPath)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), path: inPath);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        try
        {
            // Create a fake surface to calculate the size of path
            var fake_surface = new Graphic.Surface (1, 1);

            var path = new Graphic.Path.from_data (this.path);
            var path_size = fake_surface.context.get_path_area (path).size;
            path_size.width = double.max (inSize.width, path_size.width);
            path_size.height = double.max (inSize.height, path_size.height);
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "error on get path area: %s", err.message);
        }

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        var path = new Graphic.Path.from_data (this.path);
        var path_area = inContext.get_path_area (path);
        double scale_x = area.extents.size.width / (path_area.origin.x + path_area.size.width);
        double scale_y = area.extents.size.height / (path_area.origin.y + path_area.size.height);

        path.transform (new Graphic.Transform.init_scale (scale_x, scale_y));

        if (fill_pattern[state] != null)
        {
            inContext.pattern = fill_pattern[state];
            inContext.fill (path);
        }

        if (stroke_pattern[state] != null)
        {
            inContext.pattern = stroke_pattern[state];
            inContext.stroke (path);
        }
    }
}

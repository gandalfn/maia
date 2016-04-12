/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * line.vala
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

public class Maia.Line : Item, ItemPackable
{
    // accessors
    internal override string tag {
        get {
            return "Line";
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

    // methods
    public Line (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        size = Graphic.Size (line_width, line_width);

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        if (stroke_pattern[state] != null)
        {
            var item_size = area.extents.size;
            var path = new Graphic.Path ();
            path.move_to (0, 0);
            if (item_size.width < item_size.height)
            {
                path.line_to (0, item_size.height);
            }
            else
            {
                path.line_to (item_size.width, 0);
            }
            inContext.pattern = stroke_pattern[state];
            inContext.stroke (path);
        }
    }
}

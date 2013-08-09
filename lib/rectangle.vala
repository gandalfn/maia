/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * rectangle.vala
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

public class Maia.Rectangle : Item
{
    // accessors
    public override string tag {
        get {
            return "Rectangle";
        }
    }

    // methods
    public Rectangle (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        var area = new Graphic.Region (Graphic.Rectangle (0, 0, size.width, size.height));
        var path = new Graphic.Path.from_region (area);

        inContext.line_width = line_width;

        if (fill_color != null)
        {
            inContext.pattern = fill_color;
            inContext.fill (path);
        }

        if (stroke_color != null)
        {
            inContext.pattern = stroke_color;
            inContext.stroke (path);
        }
    }
}
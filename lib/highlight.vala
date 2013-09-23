/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * highlight.vala
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

public class Maia.Highlight : ToggleButton
{
    // accessors
    internal override string tag {
        get {
            return "Highlight";
        }
    }

    public double border { get; set; default = 5; }

    // methods
    public Highlight (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Label;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        // Get label item
        string id_label = "%s-label".printf (name);
        unowned Label label_item = find (GLib.Quark.from_string (id_label), false) as Label;
        if (label_item != null)
        {
            // get position of label
            Graphic.Point position_label = label_item.position;

            // set position of label
            if (position_label.x != border || position_label.y != border)
            {
                label_item.position = Graphic.Point (border, border);

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "label item position : %s", label_item.position.to_string ());
            }
        }


        Graphic.Size ret = base.size_request (inSize);
        ret.width += border;
        ret.height += border;

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "%s size: %s", name, ret.to_string ());

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        inContext.save ();
        {
            // Translate to align in center
            inContext.translate (Graphic.Point (geometry.extents.size.width / 2, geometry.extents.size.height / 2));
            inContext.translate (Graphic.Point (-size_requested.width / 2, -size_requested.height / 2));

            // Paint hightlight if active
            if (active)
            {
                var path = new Graphic.Path ();
                path.rectangle (border / 2, border / 2, size_requested.width - border, size_requested.height - border, 5, 5);

                if (stroke_pattern != null)
                {
                    inContext.pattern = stroke_pattern;
                    inContext.line_width = line_width;
                    inContext.stroke (path);
                }

                if (fill_pattern != null)
                {
                    inContext.pattern = fill_pattern;
                    inContext.fill (path);
                }
            }

            // paint childs
            foreach (unowned Core.Object child in this)
            {
                if (child is Drawable)
                {
                    ((Drawable)child).draw (inContext);
                }
            }
        }
        inContext.restore ();
    }
}

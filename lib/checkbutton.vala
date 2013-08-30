/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * checkbutton.vala
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

public class Maia.CheckButton : ToggleButton
{
    // accessors
    internal override string tag {
        get {
            return "CheckButton";
        }
    }

    public double spacing { get; set; default = 5; }

    // methods
    construct
    {
        fill_pattern = new Graphic.Color (1, 1, 1);
        stroke_pattern = new Graphic.Color (0, 0, 0);
    }

    public CheckButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        // Get label item
        string id_label = "%s-label".printf (name);
        Label label_item = find (GLib.Quark.from_string (id_label), false) as Label;
        if (label_item != null)
        {
            // get size of label
            Graphic.Size size_label = label_item.size;

            // set position of label
            if (label_item.position.x != size_label.height + spacing)
            {
                label_item.position = Graphic.Point (size_label.height + spacing, 0);
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "label item position : %s", label_item.position.to_string ());
            }
        }

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        inContext.save ();
        {
            // Translate to align in center
            inContext.translate (Graphic.Point (geometry.extents.size.width / 2, geometry.extents.size.height / 2));
            inContext.translate (Graphic.Point (-size_requested.width / 2, -size_requested.height / 2));

            // Draw label
            base.paint (inContext);

            // Paint check box
            Graphic.Color color = fill_pattern as Graphic.Color ?? new Graphic.Color (0.7, 0.7, 0.7);
            Graphic.Color shade = new Graphic.Color.shade (color, 0.6);

            var path = new Graphic.Path ();
            path.rectangle (0, 0, size_requested.height, size_requested.height, 5, 5);
            inContext.pattern = shade;
            inContext.fill (path);

            path = new Graphic.Path ();
            path.rectangle (1.5, 1.5, size_requested.height - 3, size_requested.height - 3, 5, 5);
            inContext.pattern = color;
            inContext.fill (path);

            // Paint check if active
            if (active)
            {
                path = new Graphic.Path ();
                path.move_to (0.5 + (size_requested.height * 0.2), (size_requested.height * 0.5));
                path.line_to (0.5 + (size_requested.height * 0.4), (size_requested.height * 0.7));
                path.curve_to (0.5 + (size_requested.height * 0.4), (size_requested.height * 0.7),
                               0.5 + (size_requested.height * 0.5), (size_requested.height * 0.4),
                               0.5 + (size_requested.height * 0.70), (size_requested.height * 0.05));
                inContext.pattern = stroke_pattern;
                inContext.stroke (path);
            }
        }
        inContext.restore ();
    }
}

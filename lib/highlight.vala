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
    // properties
    private unowned Label? m_Label;

    // accessors
    internal override string tag {
        get {
            return "Highlight";
        }
    }

    public double border { get; set; default = 5; }

    // methods
    construct
    {
        m_Label = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
    }

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
        if (m_Label != null)
        {
            // get position of label
            Graphic.Point position_label = m_Label.position;

            // set position of label
            if (position_label.x != border || position_label.y != border)
            {
                m_Label.position = Graphic.Point (border, border);

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "label item position : %s", m_Label.position.to_string ());
            }
        }

        Graphic.Size ret = base.size_request (inSize);
        ret.resize (border, border);

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            // Translate to align in center
            inContext.translate (Graphic.Point (area.extents.size.width / 2, area.extents.size.height / 2));
            inContext.translate (Graphic.Point (-size.width / 2, -size.height / 2));

            // Paint hightlight if active
            if (active)
            {
                var path = new Graphic.Path ();
                path.rectangle (border / 2, border / 2, size.width - border, size.height - border, 5, 5);

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
                    unowned Drawable drawable = (Drawable)child;
                    drawable.draw (inContext, area_to_child_item_space (drawable, inArea));
                }
            }
        }
        inContext.restore ();
    }
}

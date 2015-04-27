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

public class Maia.CheckButton : Toggle
{
    // properties
    private unowned Label? m_Label;

    // accessors
    internal override string tag {
        get {
            return "CheckButton";
        }
    }

    public double spacing { get; set; default = 5; }
    public Graphic.Pattern line_pattern { get; set; default = new Graphic.Color (0, 0, 0); }

    // methods
    construct
    {
        fill_pattern = new Graphic.Color (1, 1, 1);
        stroke_pattern = new Graphic.Color (0, 0, 0);

        m_Label = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
    }

    public CheckButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size ret = Graphic.Size (0, 0);

        if (m_Label != null)
        {
            // get size of label
            Graphic.Size size_label = m_Label.size;

            if (size_label.is_empty () || m_Label.text == null || m_Label.text.strip() == "")
            {
                string text = m_Label.text;
                m_Label.text = "Z";
                size_label = m_Label.size;
                m_Label.position = Graphic.Point (0, 0);
                ret = Graphic.Size (size_label.height, size_label.height);
                m_Label.text = text;
                size_label = m_Label.size;
            }
            else
            {
                // set position of label
                if (m_Label.position.x != size_label.height + spacing)
                {
                    m_Label.position = Graphic.Point (size_label.height + spacing, 0);
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "label item position : %s", m_Label.position.to_string ());
                }

                ret = Graphic.Size (size_label.height + spacing + size_label.width, size_label.height);
            }
        }

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

            // Draw label
            base.paint (inContext, inArea);

            // Paint check box
            Graphic.Color color = fill_pattern as Graphic.Color ?? new Graphic.Color (0.7, 0.7, 0.7);
            Graphic.Color shade = new Graphic.Color.shade (color, 0.6);

            var path = new Graphic.Path ();
            path.rectangle (0, 0, size.height, size.height, 5, 5);
            inContext.pattern = shade;
            inContext.fill (path);

            path = new Graphic.Path ();
            path.rectangle (1.5, 1.5, size.height - 3, size.height - 3, 5, 5);
            inContext.pattern = color;
            inContext.fill (path);

            // Paint check if active
            if (active)
            {
                path = new Graphic.Path ();
                path.move_to (0.5 + (size.height * 0.2), (size.height * 0.5));
                path.line_to (0.5 + (size.height * 0.4), (size.height * 0.7));
                path.curve_to (0.5 + (size.height * 0.4), (size.height * 0.7),
                               0.5 + (size.height * 0.5), (size.height * 0.4),
                               0.5 + (size.height * 0.70), (size.height * 0.05));
                inContext.pattern = line_pattern;
                inContext.stroke (path);
            }
        }
        inContext.restore ();
    }
}

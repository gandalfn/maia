/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * toggle-button.vala
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

public class Maia.ToggleButton : Toggle
{
    // properties
    private unowned Label? m_Label;

    // accessors
    internal override string tag {
        get {
            return "ToggleButton";
        }
    }

    /**
     * The border around label and icon
     */
    public double border { get; set; default = 5; }

    /**
     * Indicate if the button is sensitive
     */
    public bool sensitive { get; set; default = true; }

    /**
     * The background color of button if not set the button does not draw any background
     */
    public Graphic.Color button_color { get; set; default = new Graphic.Color (0.7, 0.7, 0.7); }

    /**
     * The insensitive background color of button if not set the button does not draw any background
     */
    public Graphic.Color button_inactive_color { get; set; default = null; }

    // methods
    construct
    {
        m_Label = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
    }

    public ToggleButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private void
    draw_button (Graphic.Context inContext) throws Graphic.Error
    {
        // Paint Background
        var button_size = geometry.extents.size;
        button_size.resize (-border * 2, -border * 2);
        var pattern = new Graphic.MeshGradient ();

        double vb = 1, ve = 1.1, vd = 0.8, vd2 = 0.7;

        if (active && sensitive)
        {
            vb = 1.1;
            ve = 1;
            vd = 1.05;
            vd2 = 1.15;
        }
        var beginColor = new Graphic.Color.shade (sensitive ? button_color : button_inactive_color ?? button_color, vb);
        var endColor = new Graphic.Color.shade (sensitive ? button_color : button_inactive_color ?? button_color, ve);

        if (m_Label != null && (m_Label.shade_color == null || m_Label.shade_color.compare (beginColor) != 0))
        {
            m_Label.shade_color = beginColor;
        }

        var topleft = new Graphic.MeshGradient.ArcPatch (Graphic.Point (border, border),
                                                         -GLib.Math.PI, -GLib.Math.PI / 2, border,
                                                         { beginColor, endColor, endColor, beginColor });

        var color1 = endColor;
        var color2 =  new Graphic.Color.shade (color1, vd);
        var top =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (border, 0,
                                                                          button_size.width,
                                                                          border),
                                                       { color1, color2, beginColor, beginColor });

        var topright = new Graphic.MeshGradient.ArcPatch (Graphic.Point (button_size.width + border, border),
                                                          -GLib.Math.PI / 2, 0, border,
                                                          { beginColor, color2, color2, beginColor });

        var color3 = color2;
        var color4 =  new Graphic.Color.shade (color3, vd2);
        var right =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (button_size.width + border, border,
                                                                            border, button_size.height),
                                                         { beginColor, color3, color4, beginColor });

        var bottomright = new Graphic.MeshGradient.ArcPatch (Graphic.Point (button_size.width + border,
                                                                            button_size.height + border),
                                                             0, GLib.Math.PI / 2, border,
                                                             { beginColor, color4, color4, beginColor });

        var bottom =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (border, button_size.height + border,
                                                                             button_size.width, border),
                                                         { beginColor, beginColor, color4, color2 });

        var bottomleft = new Graphic.MeshGradient.ArcPatch (Graphic.Point (border, button_size.height + border),
                                                            GLib.Math.PI / 2, GLib.Math.PI, border,
                                                            { beginColor, color2, color2, beginColor });

        var left =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (0, border,
                                                                           border, button_size.height),
                                                       { color1, beginColor, beginColor, color2 });

        var main =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (border, border,
                                                                           button_size.width, button_size.height),
                                                       { beginColor, beginColor, beginColor, beginColor });

        pattern.add (topleft);
        pattern.add (top);
        pattern.add (topright);
        pattern.add (right);
        pattern.add (bottomright);
        pattern.add (bottom);
        pattern.add (bottomleft);
        pattern.add (left);
        pattern.add (main);

        inContext.pattern = pattern;
        inContext.paint ();
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
            // Paint button background
            if (button_color != null)
            {
                draw_button (inContext);
            }

            // Translate to align in center
            inContext.translate (Graphic.Point (area.extents.size.width / 2, area.extents.size.height / 2));
            inContext.translate (Graphic.Point (-size.width / 2, -size.height / 2));

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

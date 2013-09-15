/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * button.vala
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

/**
 * An item that emits a signal when clicked on
 *
 * =Manifest description:=
 *
 * {{{
 *      Button.<id> {
 *          font_description: 'Liberation Sans 12';
 *          icon_filename: '/path/filename';
 *          button_color: '#C0C0C0';
 *      }
 * }}}
 *
 */
public class Maia.Button : Grid
{
    // properties
    private bool m_Clicked = false;

    // accessors
    internal override string tag {
        get {
            return "Button";
        }
    }

    internal override bool can_focus  { get; set; default = false; }

    /**
     * The default font description of button label
     */
    public string font_description {
        get {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            return label_item == null ? "" : label_item.font_description;
        }
        set {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            if (label_item != null)
            {
                label_item.font_description = value;
            }
        }
    }

    /**
     * The label of button
     */
    public string label {
        get {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            return label_item == null ? "" : label_item.text;
        }
        set {
            unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
            if (label_item != null)
            {
                label_item.text = value;
            }
        }
    }

    /**
     * The border around label and icon
     */
    public double border { get; set; default = 5; }

    /**
     * The icon filename no icon if ``null``
     */
    public string icon_filename { get; set; default = null; }

    /**
     * The background color of button if not set the button does not draw any background
     */
    public Graphic.Color button_color { get; set; default = null; }

    // signals
    /**
     * Signal received when button was clicked
     */
    public signal void clicked ();

    // methods
    construct
    {
        stroke_pattern = new Graphic.Color (0, 0, 0);

        column_spacing = border;

        // Create icon item
        string id_icon = "%s-icon".printf (name);

        var icon_item = new Image (id_icon, icon_filename);
        icon_item.xfill = false;
        icon_item.xexpand = false;
        icon_item.yfill = false;
        icon_item.top_padding = border;
        icon_item.left_padding = border;
        icon_item.bottom_padding = border;
        add (icon_item);

        notify ["icon-filename"].connect (() => {
            icon_item.filename = icon_filename;
        });

        // Create label item
        string id_label = "%s-label".printf (name);

        var label_item = new Label (id_label, label);
        label_item.column = 1;
        label_item.xfill = false;
        label_item.top_padding = border;
        label_item.right_padding = border;
        label_item.bottom_padding = border;
        add (label_item);

        notify["stroke-pattern"].connect (() => {
            label_item.stroke_pattern = stroke_pattern;
        });

        notify["border"].connect (() => {
            column_spacing = border;
            icon_item.top_padding = border;
            icon_item.left_padding = border;
            icon_item.bottom_padding = border;
            label_item.top_padding = border;
            label_item.right_padding = border;
            label_item.bottom_padding = border;
        });

        label_item.button_press_event.connect (on_button_press_event);
    }

    /**
     * Create a new button
     *
     * @param inId id of item
     * @param inLabel the label of button ``null`` if none
     */
    public Button (string inId, string? inLabel = null)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), label: inLabel);
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;

        if (geometry != null)
        {
            var area = geometry.copy ();
            area.translate (geometry.extents.origin.invert ());
            ret = inPoint in area;

            if (ret && inButton == 1)
            {
                m_Clicked = true;

                grab_pointer (this);

                damage ();
            }
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;

        if (geometry != null)
        {
            var area = geometry.copy ();
            area.translate (geometry.extents.origin.invert ());
            ret = inPoint in area;

            if (inButton == 1 && m_Clicked)
            {
                m_Clicked = false;

                ungrab_pointer (this);

                damage ();

                if (ret)
                {
                    clicked ();
                }
            }
        }

        return ret;
    }

    private void
    draw_button (Graphic.Context inContext) throws Graphic.Error
    {
        // Paint Background
        var button_size = geometry.extents.size;
        button_size.resize (-border * 2, -border * 2.3);
        var pattern = new Graphic.MeshGradient ();

        double vb = 1, ve = 1.1, vd = 0.8, vd2 = 0.7;

        if (m_Clicked)
        {
            vb = 1.1;
            ve = 1;
            vd = 1.05;
            vd2 = 1.15;
        }
        var beginColor = new Graphic.Color.shade (button_color, vb);
        var endColor = new Graphic.Color.shade (button_color, ve);

        unowned Label? label_item = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;
        if (label_item != null)
        {
            label_item.shade_color = beginColor;
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

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        inContext.save ();
        {
            // Paint button background
            if (button_color != null)
            {
                draw_button (inContext);
            }

            base.paint (inContext);
        }
        inContext.restore ();
    }

    internal override string
    to_string ()
    {
        string ret = dump_declaration ();

        if (ret != "")
        {
            ret += " {\n";

            ret += dump_attributes ();

            ret += dump_characters ();

            ret += "}\n";
        }

        return ret;
    }
}

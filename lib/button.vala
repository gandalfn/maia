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

public class Maia.Button : Group, ItemPackable, ItemMovable
{
    // properties
    private bool m_Clicked = false;

    // accessors
    internal override string tag {
        get {
            return "Button";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

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

    public double border { get; set; default = 5; }
    public string icon_filename { get; set; default = null; }
    public Graphic.Color button_color { get; set; default = null; }

    // signals
    public signal void clicked ();

    // methods
    construct
    {
        // Create icon item
        string id_icon = "%s-icon".printf (name);

        var icon_item = new Image (id_icon, icon_filename);
        add (icon_item);

        notify ["icon-filename"].connect (() => {
            icon_item.filename = icon_filename;
        });

        // Create label item
        string id_label = "%s-label".printf (name);

        var label_item = new Label (id_label, label);
        add (label_item);

        notify["stroke-color"].connect (() => {
            label_item.stroke_color = stroke_color;
        });

        label_item.button_press_event.connect (on_button_press_event);
    }

    public Button (string inId, string? inLabel = null)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), label: inLabel);
    }

    protected override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        Graphic.Point pos = Graphic.Point ((geometry.extents.size.width - size_requested.width) / 2,
                                           (geometry.extents.size.height - size_requested.height) / 2);
        Graphic.Rectangle area = Graphic.Rectangle (pos.x, pos.y, size_requested.width, size_requested.height);
        bool ret = inPoint in area;

        if (ret && inButton == 1)
        {
            m_Clicked = true;

            grab_pointer (this);

            damage ();
        }

        return ret;
    }

    protected override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        Graphic.Point pos = Graphic.Point ((geometry.extents.size.width - size_requested.width) / 2,
                                           (geometry.extents.size.height - size_requested.height) / 2);
        Graphic.Rectangle area = Graphic.Rectangle (pos.x, pos.y, size_requested.width, size_requested.height);
        bool ret = inPoint in area;

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

        return ret;
    }

    private void
    draw_button (Graphic.Context inContext) throws Graphic.Error
    {
        // Paint Background
        var button_size = size_requested;
        button_size.resize (-border * 2, -border * 2);
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

    internal override Graphic.Size
    childs_size_request ()
    {
        double max_height = 0;
        Graphic.Point offset = Graphic.Point (border, border);

        // Get icon item
        string id_icon = "%s-icon".printf (name);
        Image icon_item = find (GLib.Quark.from_string (id_icon), false) as Image;
        if (icon_item != null)
        {
            // get position of icon
            Graphic.Point position_icon = icon_item.position;
            Graphic.Size size_icon = icon_item.size;

            if (!size_icon.is_empty ())
            {
                // set position of icon
                if (position_icon.x != offset.x || position_icon.y != offset.y)
                {
                    icon_item.position = offset;

                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "icon item position : %s", icon_item.position.to_string ());
                }

                // set the current offset
                offset.x += icon_item.size.width + border;

                // set the height of icon
                max_height = size_icon.height;
            }
        }

        // Get label item
        string id_label = "%s-label".printf (name);
        Label label_item = find (GLib.Quark.from_string (id_label), false) as Label;
        if (label_item != null)
        {
            // get position of label
            Graphic.Point position_label = label_item.position;
            Graphic.Size size_label = label_item.size;

            // if label haight is lesser tahn icon and offset to center label
            if (size_label.height < max_height)
            {
                offset.y += (max_height - size_label.height) / 2;
            }
            else if (icon_item != null)
            {
                Graphic.Point position_icon = icon_item.position;
                Graphic.Size size_icon = icon_item.size;

                if (!size_icon.is_empty ())
                {
                    position_icon.y = (size_label.height - size_icon.height) / 2;
                    icon_item.position = position_icon;
                }
            }

            // set position of label
            if (position_label.x != offset.x || position_label.y != offset.y)
            {
                label_item.position = offset;

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "label item position : %s", label_item.position.to_string ());
            }
        }


        Graphic.Size ret = base.childs_size_request ();
        ret.width += border * 2;
        ret.height += border * 2;

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

            // Paint button background
            if (button_color != null)
            {
                draw_button (inContext);
            }

            // paint childs
            foreach (unowned Core.Object child in this)
            {
                if (child is Label)
                {
                    Label label = (Label)child;

                    inContext.save ();
                    {
                        var color = label.stroke_color;

                        inContext.save ();
                        inContext.translate (Graphic.Point (-1, -1));
                        label.stroke_color  = new Graphic.Color.shade ((Graphic.Color)color, 0.8);
                        label.draw (inContext);
                        inContext.restore ();

                        inContext.save ();
                        inContext.translate (Graphic.Point (1, 1));
                        label.stroke_color  = new Graphic.Color.shade ((Graphic.Color)color, 1.2);
                        label.draw (inContext);
                        inContext.restore ();

                        label.stroke_color = color;
                        label.draw (inContext);
                    }
                    inContext.restore ();
                }
                else if (child is Drawable)
                {
                    ((Drawable)child).draw (inContext);
                }
            }
        }
        inContext.restore ();
    }
}

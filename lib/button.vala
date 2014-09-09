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
 * An item that emits an event when clicked on
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
    private unowned Image? m_Icon = null;
    private unowned Label? m_Separator = null;
    private unowned Label? m_Label = null;

    // accessors
    internal override string tag {
        get {
            return "Button";
        }
    }

    internal override bool can_focus  { get; set; default = true; }

    /**
     * The default font description of button label
     */
    public string font_description { get;  set; default = ""; }

    /**
     * The label of button
     */
    public string label { get; set; default = ""; }

    /**
     * The border around label and icon
     */
    public double border { get; set; default = 5; }

    /**
     * Indicate if the button is sensitive
     */
    public bool sensitive { get; set; default = true; }

    /**
     * The icon filename no icon if ``null``
     */
    public string icon_filename { get; set; default = null; }

    /**
     * The icon size
     */
    public Graphic.Size icon_size { get; set; default = Graphic.Size (0, 0); }

    /**
     * The background color of button if not set the button does not draw any background
     */
    public Graphic.Color button_color { get; set; default = new Graphic.Color (0.7, 0.7, 0.7); }

    /**
     * The insensitive background color of button if not set the button does not draw any background
     */
    public Graphic.Color button_inactive_color { get; set; default = null; }

    // events
    /**
     * Event emmitted when button was clicked
     */
    public Core.Event clicked { get; private set; }

    // methods
    construct
    {
        clicked = new Core.Event ("clicked", this);

        stroke_pattern = new Graphic.Color (0, 0, 0);

        column_spacing = border;

        // Create icon item
        string id_icon = "%s-icon".printf (name);

        var icon_item = new Image (id_icon, icon_filename);
        icon_item.xfill = false;
        icon_item.xlimp = true;
        icon_item.xexpand = false;
        icon_item.yfill = false;
        icon_item.ylimp = true;
        add (icon_item);
        m_Icon = icon_item;

        string id_sep = "%s-separator".printf (name);

        var sep_item = new Label (id_sep, "");
        sep_item.column = 1;
        sep_item.visible = false;
        sep_item.xexpand = false;
        sep_item.xfill = false;
        sep_item.xlimp = true;
        sep_item.yfill = false;
        sep_item.visible = false;
        add (sep_item);
        m_Separator = sep_item;

        // Create label item
        string id_label = "%s-label".printf (name);

        var label_item = new Label (id_label, label);
        label_item.column = 2;
        label_item.xlimp = true;
        label_item.yfill = false;
        label_item.ylimp = true;
        label_item.visible = false;
        label_item.hide_if_empty = true;
        add (label_item);
        m_Label = label_item;

        // plug properties
        plug_property("stroke-pattern", label_item, "stroke-pattern");
        plug_property("font-description", label_item, "font-description");
        plug_property("label", label_item, "text");
        plug_property("icon-filename", icon_item, "filename");
        plug_property("icon-size", icon_item, "size");
        plug_property("border", icon_item, "top-padding");
        plug_property("border", icon_item, "left-padding");
        plug_property("border", icon_item, "right-padding");
        plug_property("border", icon_item, "bottom-padding");
        plug_property("border", sep_item, "top-padding");
        plug_property("border", sep_item, "right-padding");
        plug_property("border", sep_item, "bottom-padding");
        plug_property("border", label_item, "top-padding");
        plug_property("border", label_item, "right-padding");
        plug_property("border", label_item, "bottom-padding");

        icon_item.button_press_event.connect (on_button_press_event);
        sep_item.button_press_event.connect (on_button_press_event);
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

    private void
    draw_button (Graphic.Context inContext) throws Graphic.Error
    {
        // Paint Background
        var button_size = geometry.extents.size;
        button_size.resize (-border * 2, -border * 2);
        var pattern = new Graphic.MeshGradient ();

        double vb = 1, ve = 1.1, vd = 0.95, vd2 = 0.85;

        if (m_Clicked && sensitive)
        {
            vb = 1.1;
            ve = 1;
            vd = 1.05;
            vd2 = 1.15;
        }
        var beginColor = new Graphic.Color.shade (sensitive ? button_color : button_inactive_color ?? button_color, vb);
        var endColor = new Graphic.Color.shade (sensitive ? button_color : button_inactive_color ?? button_color, ve);

        if (m_Label.shade_color == null || m_Label.shade_color.compare (beginColor) != 0)
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

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        m_Icon.visible = !m_Icon.size.is_empty () && m_Icon.have_image ();

        m_Icon.xexpand = !m_Label.visible;

        m_Separator.visible = m_Icon.visible && m_Label.visible;

        return base.size_request (inSize);
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

            base.paint (inContext, inArea);
        }
        inContext.restore ();
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (sensitive && ret && inButton == 1)
        {
            m_Clicked = true;

            grab_pointer (this);

            damage ();
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        if (inButton == 1 && m_Clicked)
        {
            m_Clicked = false;

            ungrab_pointer (this);

            damage ();

            if (ret)
            {
                clicked.publish ();
            }
        }

        return ret;
    }

    internal override string
    dump_childs (string inPrefix)
    {
        return "";
    }
}

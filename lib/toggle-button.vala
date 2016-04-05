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
    // accessors
    internal override string tag {
        get {
            return "ToggleButton";
        }
    }

    /**
     * The icon filename no icon if ``null``
     */
    public string icon_filename { get; set; default = null; }

    /**
     * The icon size
     */
    public Graphic.Size icon_size { get; set; default = Graphic.Size (0, 0); }

    /**
     * Sets the relief style of the edges of the button
     */
    public Button.Relief relief { get; set; default = Button.Relief.NORMAL; }

    /**
     * The spacing between button component
     */
    public double spacing { get; set; default = 5.0; }

    internal override string main_data {
        owned get {
            return @"Grid.$(name)-content { " +
                   @"    column-spacing: @spacing;" +
                   @"    Image.$(name)-image { "    +
                   @"        yfill: false;" +
                   @"        yexpand: true;" +
                   @"        xexpand: false;" +
                   @"        xfill: false;" +
                   @"        xlimp: true;" +
                   @"        filename: @icon-filename;" +
                   @"        size: @icon-size;" +
                   @"    }" +
                   @"    Label.$(name)-label { "    +
                   @"        column: 1; "    +
                   @"        yfill: false;" +
                   @"        yexpand: true;" +
                   @"        xexpand: true;" +
                   @"        xfill: true;" +
                   @"        xlimp: true;" +
                   @"        alignment: left;" +
                   @"        shade-color: @shade-color;" +
                   @"        font-description: @font-description;" +
                   @"        stroke-pattern: @stroke-pattern;" +
                   @"        text: @label;" +
                   @"    }" +
                   @"}";
        }
    }

    // methods
    public ToggleButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private Graphic.Pattern?
    get_button_pattern () throws Graphic.Error
    {
        // Paint Background
        var button_size = geometry.extents.size;
        button_size.resize (-border * 2, -border * 2);

        double vb = 1, ve = 1.1, vd = 0.95, vd2 = 0.85;

        if (active && sensitive)
        {
            vb = 1.1;
            ve = 1;
            vd = 1.05;
            vd2 = 1.15;
        }
        var button_color = fill_pattern[state] as Graphic.Color ?? new Graphic.Color (0.7, 0.7, 0.7);;
        if (button_color != null)
        {
            var beginColor = new Graphic.Color.shade (button_color, vb);
            var endColor = new Graphic.Color.shade (button_color, ve);

            if (shade_color == null || shade_color.compare (beginColor) != 0)
            {
                shade_color = beginColor;
            }

            if (relief == Button.Relief.NORMAL)
            {
                var pattern = new Graphic.MeshGradient ();
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
                return pattern;
            }

            return beginColor;
        }

        return null;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Size ret = Graphic.Size (border * 2.0, border * 2.0);
        if (main_content != null)
        {
            var area = Graphic.Rectangle (0, 0, border * 2.0, border * 2.0);
            var content_size = main_content.size;
            area.union_ (Graphic.Rectangle (border, border, content_size.width, content_size.height));

            ret = area.size;
            ret.resize (border, border);
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            if (main_content != null)
            {
                var item_size = area.extents.size;
                item_size.resize (-border * 2.0, -border * 2.0);
                var content_size = main_content.size;
                main_content.update (inContext, new Graphic.Region (Graphic.Rectangle (border, border + ((item_size.height - content_size.height) / 2.0 ), item_size.width, content_size.height)));
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            // Paint button background
            var button_pattern = get_button_pattern ();
            if (button_pattern != null)
            {
                inContext.pattern = get_button_pattern ();
                inContext.paint ();
            }

            if (main_content != null)
            {
                var child_area = area_to_child_item_space (main_content, inArea);
                main_content.draw (inContext, child_area);
            }
        }
        inContext.restore ();
    }
}

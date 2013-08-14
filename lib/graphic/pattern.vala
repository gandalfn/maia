/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * pattern.vala
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

public abstract class Maia.Graphic.Pattern : Core.Object
{
    // methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Pattern), attribute_to_pattern);
        Manifest.Attribute.register_transform_func (typeof (Color),   attribute_to_pattern);

        Manifest.Function.register_transform_func (typeof (Pattern), "rgb",  attribute_to_rgb_color);
        Manifest.Function.register_transform_func (typeof (Pattern), "rgba", attribute_to_rgba_color);
        Manifest.Function.register_transform_func (typeof (Color),   "rgb",  attribute_to_rgb_color);
        Manifest.Function.register_transform_func (typeof (Color),   "rgba", attribute_to_rgba_color);

        Manifest.Function.register_transform_func (typeof (Pattern), "linear-gradient", attribute_to_linear_gradient);

        Manifest.Function.register_transform_func (typeof (Gradient.ColorStop), "color-stop", attribute_to_color_stop);

        Manifest.Function.register_transform_func (typeof (Pattern), "image", attribute_to_image);
        Manifest.Function.register_transform_func (typeof (Image),   "image", attribute_to_image);

        Manifest.Function.register_transform_func (typeof (Pattern), "svg", attribute_to_svg);
        Manifest.Function.register_transform_func (typeof (Image),   "svg", attribute_to_svg);

        GLib.Value.register_transform_func (typeof (Pattern), typeof (string), pattern_to_string);
        GLib.Value.register_transform_func (typeof (string),  typeof (Pattern), string_to_pattern);
        GLib.Value.register_transform_func (typeof (string),  typeof (Color), string_to_pattern);
    }

    static void
    attribute_to_pattern (Manifest.Attribute inAttribute, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new Color.from_attribute (inAttribute);
    }

    static void
    attribute_to_rgb_color (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new Color.from_rgb_function (inFunction);
    }

    static void
    attribute_to_rgba_color (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new Color.from_rgba_function (inFunction);
    }

    static void
    attribute_to_linear_gradient (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new LinearGradient.from_function (inFunction);
    }

    static void
    attribute_to_color_stop (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new Gradient.ColorStop.from_function (inFunction);
    }

    static void
    attribute_to_image (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_PARSING, "Load image %s", arg.get ());
                    outDest = Image.create (arg.get ());
                    break;

                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt <= 0)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }
    }

    static void
    attribute_to_svg (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_PARSING, "Load svg image %s", arg.get ());
                    outDest = new ImageSvg.from_data (arg.get ());
                    break;

                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt <= 0)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }
    }

    static void
    pattern_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Pattern)))
    {
        unowned Pattern? val = (Pattern)inSrc;

        outDest = val.to_string ();
    }

    static void
    string_to_pattern (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        outDest = new Color.parse ((string)inSrc);
    }
}

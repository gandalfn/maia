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

public abstract class Maia.Graphic.Pattern : Object
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
    }

    internal static void
    attribute_to_pattern (Manifest.Attribute inAttribute, ref GLib.Value outDest)
    {
        outDest = new Color.from_attribute (inAttribute);
    }

    internal static void
    attribute_to_rgb_color (Manifest.Function inFunction, ref GLib.Value outDest)
    {
        outDest = new Color.from_rgb_function (inFunction);
    }

    internal static void
    attribute_to_rgba_color (Manifest.Function inFunction, ref GLib.Value outDest)
    {
        outDest = new Color.from_rgba_function (inFunction);
    }

    internal static void
    attribute_to_linear_gradient (Manifest.Function inFunction, ref GLib.Value outDest)
    {
        outDest = new LinearGradient.from_function (inFunction);
    }

    internal static void
    attribute_to_color_stop (Manifest.Function inFunction, ref GLib.Value outDest)
    {
        outDest = new Gradient.ColorStop.from_function (inFunction);
    }
}

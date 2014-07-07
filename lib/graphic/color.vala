/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * color.vala
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

[CCode (has_type_id = false)]
internal struct Maia.Graphic.NamedColor {
    public string m_Name;
    public uint m_Red;
    public uint m_Green;
    public uint m_Blue;
    public uint m_Opacity;
}

const Maia.Graphic.NamedColor[] g_StandardColors = {
    {"aliceblue", 240, 248, 255, 0},
    {"antiquewhite", 250, 235, 215, 0},
    {"aqua", 0, 255, 255, 0},
    {"aquamarine", 127, 255, 212, 0},
    {"azure", 240, 255, 255, 0},
    {"beige", 245, 245, 220, 0},
    {"bisque", 255, 228, 196, 0},
    {"black", 0, 0, 0, 0},
    {"blanchedalmond", 255, 235, 205, 0},
    {"blue", 0, 0, 255, 0},
    {"blueviolet", 138, 43, 226, 0},
    {"brown", 165, 42, 42, 0},
    {"burlywood", 222, 184, 135, 0},
    {"cadetblue", 95, 158, 160, 0},
    {"chartreuse", 127, 255, 0, 0},
    {"chocolate", 210, 105, 30, 0},
    {"coral", 255, 127, 80, 0},
    {"cornflowerblue", 100, 149, 237, 0},
    {"cornsilk", 255, 248, 220, 0},
    {"crimson", 220, 20, 60, 0},
    {"cyan", 0, 255, 255, 0},
    {"darkblue", 0, 0, 139, 0},
    {"darkcyan", 0, 139, 139, 0},
    {"darkgoldenrod", 184, 134, 11, 0},
    {"darkgray", 169, 169, 169, 0},
    {"darkgreen", 0, 100, 0, 0},
    {"darkgrey", 169, 169, 169, 0},
    {"darkkhaki", 189, 183, 107, 0},
    {"darkmagenta", 139, 0, 139, 0},
    {"darkolivegreen", 85, 107, 47, 0},
    {"darkorange", 255, 140, 0, 0},
    {"darkorchid", 153, 50, 204, 0},
    {"darkred", 139, 0, 0, 0},
    {"darksalmon", 233, 150, 122, 0},
    {"darkseagreen", 143, 188, 143, 0},
    {"darkslateblue", 72, 61, 139, 0},
    {"darkslategray", 47, 79, 79, 0},
    {"darkslategrey", 47, 79, 79, 0},
    {"darkturquoise", 0, 206, 209, 0},
    {"darkviolet", 148, 0, 211, 0},
    {"deeppink", 255, 20, 147, 0},
    {"deepskyblue", 0, 191, 255, 0},
    {"dimgray", 105, 105, 105, 0},
    {"dimgrey", 105, 105, 105, 0},
    {"dodgerblue", 30, 144, 255, 0},
    {"firebrick", 178, 34, 34, 0},
    {"floralwhite", 255, 250, 240, 0},
    {"forestgreen", 34, 139, 34, 0},
    {"fuchsia", 255, 0, 255, 0},
    {"gainsboro", 220, 220, 220, 0},
    {"ghostwhite", 248, 248, 255, 0},
    {"gold", 255, 215, 0, 0},
    {"goldenrod", 218, 165, 32, 0},
    {"gray", 128, 128, 128, 0},
    {"grey", 128, 128, 128, 0},
    {"green", 0, 128, 0, 0},
    {"greenyellow", 173, 255, 47, 0},
    {"honeydew", 240, 255, 240, 0},
    {"hotpink", 255, 105, 180, 0},
    {"indianred", 205, 92, 92, 0},
    {"indigo", 75, 0, 130, 0},
    {"ivory", 255, 255, 240, 0},
    {"khaki", 240, 230, 140, 0},
    {"lavender", 230, 230, 250, 0},
    {"lavenderblush", 255, 240, 245, 0},
    {"lawngreen", 124, 252, 0, 0},
    {"lemonchiffon", 255, 250, 205, 0},
    {"lightblue", 173, 216, 230, 0},
    {"lightcoral", 240, 128, 128, 0},
    {"lightcyan", 224, 255, 255, 0},
    {"lightgoldenrodyellow", 250, 250, 210, 0},
    {"lightgray", 211, 211, 211, 0},
    {"lightgreen", 144, 238, 144, 0},
    {"lightgrey", 211, 211, 211, 0},
    {"lightpink", 255, 182, 193, 0},
    {"lightsalmon", 255, 160, 122, 0},
    {"lightseagreen", 32, 178, 170, 0},
    {"lightskyblue", 135, 206, 250, 0},
    {"lightslategray", 119, 136, 153, 0},
    {"lightslategrey", 119, 136, 153, 0},
    {"lightsteelblue", 176, 196, 222, 0},
    {"lightyellow", 255, 255, 224, 0},
    {"lime", 0, 255, 0, 0},
    {"limegreen", 50, 205, 50, 0},
    {"linen", 250, 240, 230, 0},
    {"magenta", 255, 0, 255, 0},
    {"maroon", 128, 0, 0, 0},
    {"mediumaquamarine", 102, 205, 170, 0},
    {"mediumblue", 0, 0, 205, 0},
    {"mediumorchid", 186, 85, 211, 0},
    {"mediumpurple", 147, 112, 219, 0},
    {"mediumseagreen", 60, 179, 113, 0},
    {"mediumslateblue", 123, 104, 238, 0},
    {"mediumspringgreen", 0, 250, 154, 0},
    {"mediumturquoise", 72, 209, 204, 0},
    {"mediumvioletred", 199, 21, 133, 0},
    {"midnightblue", 25, 25, 112, 0},
    {"mintcream", 245, 255, 250, 0},
    {"mistyrose", 255, 228, 225, 0},
    {"moccasin", 255, 228, 181, 0},
    {"navajowhite", 255, 222, 173, 0},
    {"navy", 0, 0, 128, 0},
    {"oldlace", 253, 245, 230, 0},
    {"olive", 128, 128, 0, 0},
    {"olivedrab", 107, 142, 35, 0},
    {"orange", 255, 165, 0, 0},
    {"orangered", 255, 69, 0, 0},
    {"orchid", 218, 112, 214, 0},
    {"palegoldenrod", 238, 232, 170, 0},
    {"palegreen", 152, 251, 152, 0},
    {"paleturquoise", 175, 238, 238, 0},
    {"palevioletred", 219, 112, 147, 0},
    {"papayawhip", 255, 239, 213, 0},
    {"peachpuff", 255, 218, 185, 0},
    {"peru", 205, 133, 63, 0},
    {"pink", 255, 192, 203, 0},
    {"plum", 221, 160, 221, 0},
    {"powderblue", 176, 224, 230, 0},
    {"purple", 128, 0, 128, 0},
    {"red", 255, 0, 0, 0},
    {"rosybrown", 188, 143, 143, 0},
    {"royalblue", 65, 105, 225, 0},
    {"saddlebrown", 139, 69, 19, 0},
    {"salmon", 250, 128, 114, 0},
    {"sandybrown", 244, 164, 96, 0},
    {"seagreen", 46, 139, 87, 0},
    {"seashell", 255, 245, 238, 0},
    {"sienna", 160, 82, 45, 0},
    {"silver", 192, 192, 192, 0},
    {"skyblue", 135, 206, 235, 0},
    {"slateblue", 106, 90, 205, 0},
    {"slategray", 112, 128, 144, 0},
    {"slategrey", 112, 128, 144, 0},
    {"snow", 255, 250, 250, 0},
    {"springgreen", 0, 255, 127, 0},
    {"steelblue", 70, 130, 180, 0},
    {"tan", 210, 180, 140, 0},
    {"teal", 0, 128, 128, 0},
    {"thistle", 216, 191, 216, 0},
    {"tomato", 255, 99, 71, 0},
    {"turquoise", 64, 224, 208, 0},
    {"violet", 238, 130, 238, 0},
    {"wheat", 245, 222, 179, 0},
    {"white", 255, 255, 255, 0},
    {"whitesmoke", 245, 245, 245, 0},
    {"yellow", 255, 255, 0, 0},
    {"yellowgreen", 154, 205, 50, 0},
    {"transparent", 255, 255, 255, 255},
    {null, 0, 0, 0, 0}
};

public class Maia.Graphic.Color : Pattern
{
    // static properties
    static Core.Set <Color> s_StandardColors = null;

    // properties
    private string m_Name  = null;
    private double m_Red   = 0.0;
    private double m_Green = 0.0;
    private double m_Blue  = 0.0;
    private double m_Alpha = 0.0;
    private bool   m_IsSet = false;

    // accessors
    [CCode (notify = false)]
    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
        private set {
            id = GLib.Quark.from_string (value);
        }
    }

    public double red {
        get {
            return m_Red;
        }
    }

    public double green {
        get {
            return m_Green;
        }
    }

    public double blue  {
        get {
            return m_Blue;
        }
    }

    public double alpha {
        get {
            return m_Alpha;
        }
    }

    public bool is_set  {
        get {
            return m_IsSet;
        }
    }

    public uint32 argb {
        get {
            uint32 ret = 0;

            if (m_IsSet)
            {
                ret = (uint32)(m_Alpha * 255) << 24 + (uint32)(m_Red * 255) << 16 +
                      (uint32)(m_Green * 255) << 8  + (uint32)(m_Blue * 255);
            }

            return ret;
        }
    }

    // static methods
    private static void
    create_standard_colors ()
    {
        if (s_StandardColors == null)
        {
            s_StandardColors = new Core.Set <Color> ();

            for (int cpt = 0; g_StandardColors[cpt].m_Name != null; ++cpt)
            {
                Color color = new Color ((double)g_StandardColors[cpt].m_Red / 255,
                                         (double)g_StandardColors[cpt].m_Green / 255,
                                         (double)g_StandardColors[cpt].m_Blue / 255,
                                         1 - (double)(g_StandardColors[cpt].m_Opacity / 255));

                s_StandardColors.insert (color);
            }
        }
    }

    // methods
    /**
     * Create a new color
     *
     * @param inRed red component of color
     * @param inGreen green component of color
     * @param inBlue blue component of color
     * @param inAlpha alpha component of color
     */
    public Color (double inRed, double inGreen, double inBlue, double inAlpha = 1.0)
    {
        m_Red = inRed;
        m_Green = inGreen;
        m_Blue = inBlue;
        m_Alpha = inAlpha;
        m_IsSet = true;
    }

    /**
     * Create a new color from a string
     *
     * @param inValue string color to parse
     */
    public Color.parse (string? inValue)
    {
        if (inValue == null || inValue == "none")
        {
            name = inValue;
            m_Red = 0.0;
            m_Green = 0.0;
            m_Blue = 0.0;
            m_Alpha = 0.0;
            m_IsSet = false;
        }
        else if (inValue[0] == '#')
        {
            int r, g, b;
            inValue.scanf ("#%02x%02x%02x", out r, out g, out b);

            m_Red = (double)r / 255;
            m_Green = (double)g / 255;
            m_Blue = (double)b / 255;
            m_Alpha = 1;
            m_IsSet = true;
        }
        else
        {
            create_standard_colors ();

            unowned Color? color = s_StandardColors.search<string> (inValue, (a, v) => {
                return GLib.strcmp (a.name, v);
            });

            if (color != null)
            {
                name = inValue;
                m_Red = color.red;
                m_Green = color.green;
                m_Blue = color.blue;
                m_Alpha = color.alpha;
                m_IsSet = true;
            }
            else
            {
                m_IsSet = false;
            }
        }
    }

    /**
     * Computes a lighter or darker variant of color
     *
     * @param inColor the color to compute from
     * @param inPercent Shading factor, a factor of 1.0 leaves the color unchanged,
     *                  smaller factors yield darker colors, larger factors
     *                  yield lighter colors.
     *
     * @return the computed color
     */
    public Color.shade (Color inColor, double inPercent)
    {
        m_Red   = inColor.m_Red;
        m_Green = inColor.m_Green;
        m_Blue  = inColor.m_Blue;

        rgb_to_hls (ref m_Red, ref m_Green, ref m_Blue);

        m_Green *= inPercent;
        if (m_Green > 1.0)
            m_Green = 1.0;
        else if (m_Green < 0.0)
            m_Green = 0.0;

        m_Blue *= inPercent;
        if (m_Blue > 1.0)
            m_Blue = 1.0;
        else if (m_Blue < 0.0)
            m_Blue = 0.0;

        hls_to_rgb(ref m_Red, ref m_Green, ref m_Blue);

        m_Alpha = 1;
        m_IsSet = true;
    }

    internal Color.none ()
    {
        m_IsSet = false;
    }

    internal Color.from_rgb_function (Manifest.Function inFunction) throws Manifest.Error
    {
        Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_PARSING, "");

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    m_Red = (double)arg.transform (typeof (double));
                    break;
                case 1:
                    m_Green = (double)arg.transform (typeof (double));
                    break;
                case 2:
                    m_Blue = (double)arg.transform (typeof (double));
                    break;
                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }
        if (cpt > 2)
        {
            m_Alpha = 1.0;
            m_IsSet = true;
        }
        else
        {
            m_IsSet = false;
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }
    }

    internal Color.from_rgba_function (Manifest.Function inFunction) throws Manifest.Error
    {
        Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_PARSING, "");

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    m_Red = (double)arg.transform (typeof (double));
                    break;
                case 1:
                    m_Green = (double)arg.transform (typeof (double));
                    break;
                case 2:
                    m_Blue = (double)arg.transform (typeof (double));
                    break;
                case 3:
                    m_Alpha = (double)arg.transform (typeof (double));
                    break;
                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }
        if (cpt > 3)
        {
            m_IsSet = true;
        }
        else
        {
            m_IsSet = false;
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }
    }

    internal Color.from_attribute (Manifest.Attribute inAttribute)
    {
        this.parse (inAttribute.get ());
    }

    /**
     * Compute HLS color from RGB color
     *
     * @param inoutRed red component in input hue component on output
     * @param inoutGreen green component in input light component on output
     * @param inoutBlue blue component in input sat component on output
     */
    private static void
    rgb_to_hls (ref double inoutRed, ref double inoutGreen, ref double inoutBlue)
    {
        double min;
        double max;
        double red;
        double green;
        double blue;
        double h, l, s;
        double delta;

        red = inoutRed;
        green = inoutGreen;
        blue = inoutBlue;

        if (red > green)
        {
            if (red > blue)
                max = red;
            else
                max = blue;

            if (green < blue)
                min = green;
            else
                min = blue;
        }
        else
        {
            if (green > blue)
                max = green;
            else
                max = blue;

            if (red < blue)
                min = red;
            else
                min = blue;
        }

        l = (max + min) / 2;
        s = 0;
        h = 0;

        if (max != min)
        {
            if (l <= 0.5)
                s = (max - min) / (max + min);
            else
                s = (max - min) / (2 - max - min);

            delta = max -min;
            if (red == max)
                h = (green - blue) / delta;
            else if (green == max)
                h = 2 + (blue - red) / delta;
            else if (blue == max)
                h = 4 + (red - green) / delta;

            h *= 60;
            if (h < 0.0) h += 360;
        }

        inoutRed = h;
        inoutGreen = l;
        inoutBlue = s;
    }

    /**
     * Compute RGB color from HLS color
     *
     * @param inoutHue hue component in input red component on output
     * @param inoutLightness light component in input green component on output
     * @param inoutSaturation sat component in input blue component on output
     */
    private static void
    hls_to_rgb (ref double inoutHue, ref double inoutLightness, ref double inoutSaturation)
    {
        double hue;
        double lightness;
        double saturation;
        double m1, m2;
        double r, g, b;

        lightness = inoutLightness;
        saturation = inoutSaturation;

        if (lightness <= 0.5)
            m2 = lightness * (1 + saturation);
        else
            m2 = lightness + saturation - lightness * saturation;

        m1 = 2 * lightness - m2;

        if (saturation == 0)
        {
            inoutHue = lightness;
            inoutLightness = lightness;
            inoutSaturation = lightness;
        }
        else
        {
            hue = inoutHue + 120;
            while (hue > 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;

            if (hue < 60)
                r = m1 + (m2 - m1) * hue / 60;
            else if (hue < 180)
                r = m2;
            else if (hue < 240)
                r = m1 + (m2 - m1) * (240 - hue) / 60;
            else
                r = m1;

            hue = inoutHue;
            while (hue > 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;

            if (hue < 60)
                g = m1 + (m2 - m1) * hue / 60;
            else if (hue < 180)
                g = m2;
            else if (hue < 240)
                g = m1 + (m2 - m1) * (240 - hue) / 60;
            else
                g = m1;

            hue = inoutHue - 120;
            while (hue > 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;

            if (hue < 60)
                b = m1 + (m2 - m1) * hue / 60;
            else if (hue < 180)
                b = m2;
            else if (hue < 240)
                b = m1 + (m2 - m1) * (240 - hue) / 60;
            else
                b = m1;

            inoutHue = r;
            inoutLightness = g;
            inoutSaturation = b;
        }
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Color)
    {
        Color other = inOther as Color;

        return (int)(argb - other.argb);
    }

    internal override string
    to_string ()
    {
        string ret;

        if (!m_IsSet)
            ret = "none";
        else if (m_Name != null)
            ret = m_Name;
        else if (alpha != 1.0)
            ret = @"rgba ($red, $green, $blue, $alpha)";
        else
            ret = "#%02x%02x%02x".printf((int)(red * 255),
                                         (int)(green * 255),
                                         (int)(blue * 255));

        return ret;
    }
}

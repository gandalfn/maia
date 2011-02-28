/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * graphics-color.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

internal struct Maia.NamedColor {
    public string m_Name;
    public uint m_Red;
    public uint m_Green;
    public uint m_Blue;
    public uint m_Opacity;
}

const Maia.NamedColor[] g_StandardColors = {
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

public class Maia.GraphicColor : Object
{
    // static properties
    static Set <GraphicColor> s_StandardColors = null;

    // properties
    private string m_Name  = null;
    private double m_Red   = 0.0;
    private double m_Green = 0.0;
    private double m_Blue  = 0.0;
    private double m_Alpha = 0.0;
    private bool   m_IsSet = false; 

    // accessors
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
    static construct
    {
        s_StandardColors = new Set <GraphicColor> ();

        for (int cpt = 0; g_StandardColors[cpt].m_Name != null; ++cpt)
        {
            GraphicColor color = new GraphicColor ((double)g_StandardColors[cpt].m_Red / 255,
                                                   (double)g_StandardColors[cpt].m_Green / 255,
                                                   (double)g_StandardColors[cpt].m_Blue / 255,
                                                   1 - (double)(g_StandardColors[cpt].m_Opacity / 255));

            s_StandardColors.insert (color);
        }
    }

    /**
     * Create a new color
     *
     * @param inRed red component of color
     * @param inGreen green component of color
     * @param inBlue blue component of color
     * @param inAlpha alpha component of color
     */
    public GraphicColor(double inRed, double inGreen, double inBlue, double inAlpha = 1.0)
    {
        m_Red = inRed;
        m_Green = inGreen;
        m_Blue = inBlue;
        m_Alpha = inAlpha;
        m_IsSet = true;
    }

    /**
     * Create a new color from string
     *
     * @param inValue string color to parse
     */
    public GraphicColor.parse(string inValue)
    {
        if (inValue == "none")
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
            unowned GraphicColor? color = s_StandardColors.search<string> (inValue,
                                                                          (a, v) => {
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

    public override int
    compare (Object inOther)
        requires (inOther is GraphicColor)
    {
        GraphicColor other = inOther as GraphicColor;

        return (int)(argb - other.argb);
    }

    public override string
    to_string ()
    {
        string ret;

        if (!m_IsSet)
            ret = "none";
        else if (m_Name != null)
            ret = m_Name;
        else
            ret = "#%02x%02x%02x".printf((int)(red * 255),
                                         (int)(green * 255),
                                         (int)(blue * 255));

        return ret;
    }
}

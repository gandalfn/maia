/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * item.vala
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

// types
public enum Maia.State
{
    NORMAL,
    ACTIVE,
    PRELIGHT,
    SELECTED,
    INSENSITIVE,
    FOCUSED,
    N;

    public string
    to_string ()
    {
        switch (this)
        {
            case NORMAL:
                return "normal";

            case ACTIVE:
                return "active";

            case PRELIGHT:
                return "prelight";

            case SELECTED:
                return "selected";

            case INSENSITIVE:
                return "insensitive";

            case FOCUSED:
                return "focused";
        }

        return "normal";
    }

    public static State
    from_string (string inValue)
    {
        switch (inValue.down ())
        {
            case "normal":
                return NORMAL;

            case "active":
                return ACTIVE;

            case "prelight":
                return PRELIGHT;

            case "selected":
                return SELECTED;

            case "insensitive":
                return INSENSITIVE;

            case "focused":
                return FOCUSED;
        }

        return N;
    }
}

public class Maia.StatePatterns : Core.Object
{
    // properties
    private Graphic.Pattern?[] m_Patterns;

    // static methods
    static construct
    {
        // register attribute transform
        Manifest.Attribute.register_transform_func (typeof (StatePatterns), attribute_to_state_patterns);
        GLib.Value.register_transform_func (typeof (StatePatterns), typeof (string), state_patterns_to_string);
        GLib.Value.register_transform_func (typeof (string),  typeof (StatePatterns), string_to_state_patterns);

        // register function transform
        Manifest.Function.register_transform_func (typeof (StatePatterns), "states",          function_states_to_state_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "rgb",             function_rgb_to_state_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "rgba",            function_rgba_to_state_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "shade",           function_shade_to_state_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "linear-gradient", function_linear_gradiant_to_states_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "radial-gradient", function_radial_gradiant_to_states_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "image",           function_image_to_states_patterns);
        Manifest.Function.register_transform_func (typeof (StatePatterns), "svg",             function_svg_to_states_patterns);
    }

    static void
    attribute_to_state_patterns (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = new StatePatterns.from_attribute (inAttribute);
    }

    static void
    state_patterns_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (StatePatterns)))
    {
        StatePatterns val = (StatePatterns)inSrc;

        outDest = val.to_string ();
    }

    static void
    string_to_state_patterns (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        outDest = new StatePatterns.parse ((string)inSrc);
    }

    static void
    function_states_to_state_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_states_function (inFunction);
    }

    static void
    function_rgb_to_state_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_rgb_function (inFunction);
    }

    static void
    function_rgba_to_state_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_rgba_function (inFunction);
    }

    static void
    function_shade_to_state_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_shade_function (inFunction);
    }

    static void
    function_linear_gradiant_to_states_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_linear_gradient_function (inFunction);
    }

    static void
    function_radial_gradiant_to_states_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_radial_gradient_function (inFunction);
    }

    static void
    function_image_to_states_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_image_function (inFunction);
    }

    static void
    function_svg_to_states_patterns (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new StatePatterns.from_svg_function (inFunction);
    }

    // methods
    public StatePatterns ()
    {
        m_Patterns = new Graphic.Pattern[State.N];
    }

    public StatePatterns.va (State inState, ...)
    {
        this ();

        va_list args = va_list ();
        State state = inState;
        while (true)
        {
            m_Patterns[state] = args.arg ();

            state = args.arg ();
            if ((int)state == 0)
            {
                break;
            }
        }
    }

    internal StatePatterns.parse (string inValue)
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.Color.parse (inValue);
    }

    internal StatePatterns.from_attribute (Manifest.Attribute inAttribute)
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.Color.from_attribute (inAttribute);
    }

    internal StatePatterns.from_rgb_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.Color.from_rgb_function (inFunction);
    }

    internal StatePatterns.from_rgba_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.Color.from_rgba_function (inFunction);
    }

    internal StatePatterns.from_shade_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.Color.from_shade_function (inFunction);
    }

    internal StatePatterns.from_linear_gradient_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.LinearGradient.from_function (inFunction);
    }

    internal StatePatterns.from_radial_gradient_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        m_Patterns[State.NORMAL] = new Graphic.RadialGradient.from_function (inFunction);
    }

    internal StatePatterns.from_image_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    m_Patterns[State.NORMAL] = Graphic.Image.create (arg.get ());
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

    internal StatePatterns.from_svg_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    m_Patterns[State.NORMAL] = new Graphic.ImageSvg.from_data (arg.get ());
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

    internal StatePatterns.from_states_function (Manifest.Function inFunction) throws Manifest.Error
    {
        this ();

        int cpt = 0;
        State state = State.N;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt % 2)
            {
                case 0:
                    state = State.from_string ((string)arg.transform (typeof (string)));
                    break;
                case 1:
                    m_Patterns[state] = (Graphic.Pattern)arg.transform (typeof (Graphic.Pattern));
                    break;
            }
            cpt++;
        }
    }

    internal override string
    to_string ()
    {
        string ret = "";

        bool have_state_function = false;
        for (int cpt = State.NORMAL; cpt < State.N; ++cpt)
        {
            if (m_Patterns[cpt] != null)
            {
                if (ret.length > 0)
                {
                    ret += ", " + ((State)cpt).to_string () + ", " + m_Patterns[cpt].to_string ();
                }
                else if (cpt != State.NORMAL)
                {
                    ret += ((State)cpt).to_string () + ", " + m_Patterns[cpt].to_string ();
                }
                else
                {
                    ret += m_Patterns[cpt].to_string ();
                }

                have_state_function |= (cpt != State.NORMAL);
            }
        }

        if (have_state_function)
        {
            if (m_Patterns[State.NORMAL] != null)
            {
                ret = "states (" + State.NORMAL.to_string () + ", " + ret + ")";
            }
            else
            {
                ret = "states (" + ret + ")";
            }
        }

        return ret;
    }

    public new unowned Graphic.Pattern?
    @get (State inState)
        requires (inState < State.N)
    {
        unowned Graphic.Pattern? ret = m_Patterns[inState];
        if (ret == null && inState != State.NORMAL)
        {
            ret = m_Patterns[State.NORMAL];
        }
        return ret;
    }

    public new void
    @set (State inState, Graphic.Pattern? inPattern)
        requires (inState < State.N)
    {
        m_Patterns[inState] = inPattern;
    }
}

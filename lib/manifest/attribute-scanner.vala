/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * attribute-scanner.vala
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

// TODO: I am not really convinced of this implementation of attribute scanner.
//       I continue to thinking on better implementation of it.
public class Maia.Manifest.AttributeScanner : Core.Parser
{
    // Types
    public delegate void TransformFunc (AttributeScanner inScanner, ref GLib.Value outValue) throws Error;
    public delegate void AttributeBindCallback (AttributeBind inAttribute);

    private class Transform : Core.Object
    {
        public GLib.Type     gtype;
        public TransformFunc func;

        public Transform (GLib.Type inType, owned TransformFunc inFunc)
        {
            gtype = inType;
            func = (owned)inFunc;
        }

        public override int
        compare (Core.Object inOther)
        {
            return (int)(gtype - (inOther as Transform).gtype);
        }

        public int
        compare_with_type (GLib.Type inType)
        {
            return (int)(gtype - inType);
        }
    }

    // Static properties
    private static bool                s_SimpleTypeRegistered = false;
    private static Core.Set<Transform> s_Transforms;

    // Properties
    private char                   m_EndChar;
    private string                 m_LastName;
    private Core.Stack<string>     m_FunctionStack;
    private unowned Object         m_Owner;
    private AttributeBindCallback  m_BindCallback;

    // Static methods
    private static inline void
    register_simple_type ()
    {
        if (!s_SimpleTypeRegistered)
        {
            register_transform_func (typeof (Graphic.Point), attributes_to_point);
            register_transform_func (typeof (Graphic.Size),  attributes_to_size);
            register_transform_func (typeof (Graphic.Rectangle), attributes_to_rectangle);
            register_transform_func (typeof (Graphic.Range), attributes_to_range);

            GLib.Value.register_transform_func (typeof (Graphic.Point), typeof (string), point_to_string);
            GLib.Value.register_transform_func (typeof (Graphic.Size), typeof (string), size_to_string);
            GLib.Value.register_transform_func (typeof (Graphic.Rectangle), typeof (string), rectangle_to_string);
            GLib.Value.register_transform_func (typeof (Graphic.Range), typeof (string), range_to_string);

            s_SimpleTypeRegistered = true;
        }
    }

    private static void
    point_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Point)))
    {
        Graphic.Point val = (Graphic.Point)inSrc;

        outDest = val.to_string ();
    }

    private static void
    attributes_to_point (AttributeScanner inScanner, ref GLib.Value outValue) throws Error
    {
        Graphic.Point point = Graphic.Point (0, 0);
        int cpt = 0;
        foreach (unowned Core.Object child in ((Core.Object)inScanner))
        {
            switch (cpt)
            {
                case 0:
                    point.x = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 1:
                    point.y = (double)(child as Attribute).transform (typeof (double));
                    break;
            }
            cpt++;
            if (cpt > 1) break;
        }

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "transform to %s", point.to_string ());
#endif

        outValue = point;
    }

    static void
    size_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Size)))
    {
        Graphic.Size val = (Graphic.Size)inSrc;

        outDest = val.to_string ();
    }

    private static void
    attributes_to_size (AttributeScanner inScanner, ref GLib.Value outValue) throws Error
    {
        Graphic.Size size = Graphic.Size (0, 0);
        int cpt = 0;
        foreach (unowned Core.Object child in ((Core.Object)inScanner))
        {
            switch (cpt)
            {
                case 0:
                    size.width = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 1:
                    size.height = (double)(child as Attribute).transform (typeof (double));
                    break;
            }
            cpt++;
            if (cpt > 1) break;
        }

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "transform to %s", size.to_string ());
#endif

        outValue = size;
    }

    private static void
    rectangle_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Rectangle)))
    {
        Graphic.Rectangle val = (Graphic.Rectangle)inSrc;

        outDest = val.to_string ();
    }

    private static void
    attributes_to_rectangle (AttributeScanner inScanner, ref GLib.Value outValue) throws Error
    {
        Graphic.Rectangle rectangle = Graphic.Rectangle (0, 0, 0, 0);
        int cpt = 0;
        foreach (unowned Core.Object child in ((Core.Object)inScanner))
        {
            switch (cpt)
            {
                case 0:
                    rectangle.origin.x = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 1:
                    rectangle.origin.y = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 2:
                    rectangle.size.width = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 3:
                    rectangle.size.width = (double)(child as Attribute).transform (typeof (double));
                    break;
            }
            cpt++;
            if (cpt > 3) break;
        }

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "transform to %s", rectangle.to_string ());
#endif

        outValue = rectangle;
    }

    private static void
    range_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Range)))
    {
        Graphic.Range val = (Graphic.Range)inSrc;

        outDest = val.to_string ();
    }

    private static void
    attributes_to_range (AttributeScanner inScanner, ref GLib.Value outValue) throws Error
    {
        Graphic.Range range = Graphic.Range (0, 0, 0, 0);
        int cpt = 0;
        foreach (unowned Core.Object child in ((Core.Object)inScanner))
        {
            switch (cpt)
            {
                case 0:
                    range.min.x = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 1:
                    range.min.y = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 2:
                    range.max.x = (double)(child as Attribute).transform (typeof (double));
                    break;

                case 3:
                    range.max.y = (double)(child as Attribute).transform (typeof (double));
                    break;
            }
            cpt++;
            if (cpt > 3) break;
        }

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "transform to %s", range.to_string ());
#endif

        outValue = range;
    }

    public static void
    register_transform_func (GLib.Type inType, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Core.Set<Transform> ();
        }
        Transform transform = new Transform (inType, (owned)inFunc);
        s_Transforms.insert (transform);
    }

    // Methods
    construct
    {
        m_FunctionStack = new Core.Stack<string> ();
    }

    /**
     * Create a new attribute scanner
     *
     * @param inOwner object owner of attributes
     * @param inoutpBegin begin of buffer to parse
     * @param inpEnd end of buffer to parse
     * @param inEndChar the end char of buffer
     */
    internal AttributeScanner (Object? inOwner, ref char* inoutpBegin, char* inpEnd, char inEndChar, owned AttributeBindCallback? inCallback = null) throws Core.ParseError
    {
        base (inoutpBegin, inpEnd);

        m_EndChar = inEndChar;
        m_Owner = inOwner;
        m_BindCallback = (owned)inCallback;

        parse ();

        inoutpBegin = m_pCurrent;
    }

    private string
    read_name () throws Core.ParseError
    {
        char* begin = m_pCurrent;
        bool first = true;
        char quote = 0;
        bool in_quote = false;

        while (m_pCurrent < m_pEnd && m_pCurrent[0] != m_EndChar)
        {
            skip_space ();

            if (first && (m_pCurrent[0] == '"' || m_pCurrent[0] == '\''))
            {
                quote = m_pCurrent[0];
                next_char ();
                in_quote = true;
                continue;
            }
            else if (quote != 0)
            {
                if (m_pCurrent + 1 < m_pEnd && m_pCurrent[0] == '\\' && m_pCurrent[1] == quote)
                {
                    next_char ();
                }
                else if (m_pCurrent[0] == quote)
                {
                    in_quote = false;
                    next_char ();
                    continue;
                }
                else if (!in_quote && (m_pCurrent[0] == m_EndChar ||
                                       m_pCurrent[0] == '('       ||
                                       m_pCurrent[0] == ')'       ||
                                       m_pCurrent[0] == ','))
                {
                    break;
                }
                else if (!in_quote)
                {
                    next_char ();
                    continue;
                }
            }
            else if (m_pCurrent[0] == m_EndChar || m_pCurrent[0] == '(' || m_pCurrent[0] == ')' || m_pCurrent[0] == ',')
            {
                break;
            }

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
            {
                next_unichar (u);
            }
            else
                throw new Core.ParseError.INVALID_UTF8 ("Attribute Invalid UTF-8 character at %i,%i", m_Line, m_Col);


            first = false;
        }

        if (m_pCurrent == begin)
            return "";

        string ret = ((string) begin).substring (0, (int) (m_pCurrent - begin)).strip ();
        if (quote != 0)
        {
            ret = ret.substring (ret[0] == quote ? 1 : 0,
                                 ret.length - (ret[ret.length - 1] == quote ? 2 : 1)).replace (@"\\$quote", @"$quote");
        }

        return ret;
    }

    internal override Core.Parser.Token
    next_token () throws Core.ParseError
    {
        Core.Parser.Token token = Core.Parser.Token.NONE;

        skip_space ();

        m_Attribute = null;

        if (m_pCurrent >= m_pEnd || m_pCurrent[0] == m_EndChar)
        {
            m_Element = null;
            token = Core.Parser.Token.EOF;
        }
        else
        {
            m_LastName = read_name ();

            if (m_pCurrent[0] == '(')
            {
                token = Core.Parser.Token.START_ELEMENT;
                m_Element = m_LastName;
                m_FunctionStack.push (m_LastName);
                next_char ();
            }
            else if (m_pCurrent[0] == ')')
            {
                if (m_LastName != "")
                {
                    token = Core.Parser.Token.ATTRIBUTE;
                    m_Attribute = m_LastName;
                }
                else
                {
                    token = Core.Parser.Token.END_ELEMENT;
                    m_Attribute = null;
                    m_Element = m_FunctionStack.pop ();
                    next_char ();
                }
            }
            else if (m_pCurrent[0] == ',')
            {
                if (m_LastName != "")
                {
                    token = Core.Parser.Token.ATTRIBUTE;
                    m_Attribute = m_LastName;
                }
                next_char ();
            }
            else if (m_LastName != "")
            {
                token = Core.Parser.Token.ATTRIBUTE;
                m_Attribute = m_LastName;
                if (m_pCurrent[0] != m_EndChar)
                    next_char ();
            }
        }

        return token;
    }

    private void
    parse () throws Core.ParseError
    {
        foreach (Core.Parser.Token token in this)
        {
            switch (token)
            {
                case Core.Parser.Token.START_ELEMENT:
                    Function function = new Function (m_Owner, m_Element);
                    add (function);
                    function.parse (this);
                    break;

                case Core.Parser.Token.END_ELEMENT:
                    break;

                case Core.Parser.Token.ATTRIBUTE:
                    if (m_Attribute.has_prefix("@"))
                    {
                        AttributeBind attr = new AttributeBind (m_Owner, m_Attribute);
                        add (attr);
                        if (m_BindCallback != null) m_BindCallback (attr);
                    }
                    else if (m_Attribute != "")
                    {
                        Attribute attr = new Attribute (m_Owner, m_Attribute);
                        add (attr);
                    }
                    break;

                case Core.Parser.Token.EOF:
                    break;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    can_append_child (Core.Object inChild)
    {
        return inChild is Attribute;
    }

    /**
     * {@inheritDoc}
     */
    internal override int
    compare (Core.Object inObject)
    {
        // do not sort child attributes
        return 0;
    }

    /**
     * Transform attribute scanner to Value inType
     *
     * @param inType value type
     *
     * @return the value
     */
    public GLib.Value
    transform (GLib.Type inType) throws Error
    {
        GLib.Value val = GLib.Value (inType);
        if (inType.is_classed () && inType.class_peek () == null)
            inType.class_ref ();
        else
            register_simple_type ();

        unowned Transform? transform = null;
        if (s_Transforms != null)
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "type: %s", inType.name ());
#endif
            transform = s_Transforms.search<GLib.Type> (inType, Transform.compare_with_type);
        }

        if (transform == null)
        {
            foreach (unowned Core.Object child in ((Core.Object)this))
            {
                unowned Attribute attr = (Attribute)child;
                return attr.transform (inType);
            }
        }
        else
        {
            transform.func (this, ref val);
        }

        return val;
    }
}

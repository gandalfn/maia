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
public class Maia.Manifest.AttributeScanner : Parser
{
    // Types
    public delegate void TransformFunc (AttributeScanner inScanner, ref GLib.Value outValue);

    private class Transform : Object
    {
        public GLib.Type     gtype;
        public TransformFunc func;

        public Transform (GLib.Type inType, owned TransformFunc inFunc)
        {
            gtype = inType;
            func = (owned)inFunc;
        }

        public override int
        compare (Object inOther)
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
    private static Set<Transform> s_Transforms;

    // Properties
    private char          m_EndChar;
    private string        m_LastName;
    private Queue<string> m_FunctionQueue;
    private Object        m_Owner;

    // Static methods
    public static void
    register_transform_func (GLib.Type inType, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Set<Transform> ();
        }
        Transform transform = new Transform (inType, (owned)inFunc);
        s_Transforms.insert (transform);
    }

    // Methods
    construct
    {
        m_FunctionQueue = new Queue<string> ();
    }

    /**
     * Create a new attribute scanner
     *
     * @param inOwner object owner of attributes
     * @param inoutpBegin begin of buffer to parse
     * @param inpEnd end of buffer to parse
     * @param inEndChar the end char of buffer
     */
    internal AttributeScanner (Object? inOwner, ref char* inoutpBegin, char* inpEnd, char inEndChar) throws ParseError
    {
        base (inoutpBegin, inpEnd);

        m_EndChar = inEndChar;
        m_Owner = inOwner;

        parse ();

        inoutpBegin = m_pCurrent;
    }

    private string
    read_name () throws ParseError
    {
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd && m_pCurrent[0] != m_EndChar)
        {
            skip_space ();

            if (m_pCurrent[0] == m_EndChar || m_pCurrent[0] == '(' || m_pCurrent[0] == ')' || m_pCurrent[0] == ',')
                break;

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
                next_unichar (u);
            else
                throw new ParseError.INVALID_UTF8 ("Invalid UTF-8 character at %i,%i", m_Line, m_Col);
        }

        if (m_pCurrent == begin)
            return "";

        return ((string) begin).substring (0, (int) (m_pCurrent - begin));
    }

    internal override Parser.Token
    next_token () throws ParseError
    {
        Parser.Token token = Parser.Token.NONE;

        skip_space ();

        m_Attribute = null;

        if (m_pCurrent >= m_pEnd || m_pCurrent[0] == m_EndChar)
        {
            m_Element = null;
            token = Parser.Token.EOF;
        }
        else
        {
            m_LastName = read_name ();
            if (m_pCurrent[0] == '(')
            {
                token = Parser.Token.START_ELEMENT;
                m_Element = m_LastName;
                m_FunctionQueue.push (m_LastName);
                next_char ();
            }
            else if (m_pCurrent[0] == ')')
            {
                if (m_LastName != "")
                {
                    token = Parser.Token.ATTRIBUTE;
                    m_Attribute = m_LastName;
                }
                else
                {
                    token = Parser.Token.END_ELEMENT;
                    m_Attribute = null;
                    m_Element = m_FunctionQueue.pop ();
                    next_char ();
                }
            }
            else if (m_pCurrent[0] == ',')
            {
                if (m_LastName != "")
                {
                    token = Parser.Token.ATTRIBUTE;
                    m_Attribute = m_LastName;
                }
                next_char ();
            }
            else if (m_LastName != "")
            {
                token = Parser.Token.ATTRIBUTE;
                m_Attribute = m_LastName;
                if (m_pCurrent[0] != m_EndChar)
                    next_char ();
            }
        }

        return token;
    }

    private void
    parse () throws ParseError
    {
        foreach (Parser.Token token in this)
        {
            switch (token)
            {
                case Parser.Token.START_ELEMENT:
                    Function function = new Function (m_Owner, m_Element);
                    function.parent = this;
                    function.parse (this);
                    break;

                case Parser.Token.END_ELEMENT:
                    break;

                case Parser.Token.ATTRIBUTE:
                    if (m_Attribute.has_prefix("@"))
                    {
                        AttributeBind attr = new AttributeBind (m_Owner, m_Attribute);
                        attr.parent = this;
                    }
                    else if (m_Attribute != "")
                    {
                        Attribute attr = new Attribute (m_Owner, m_Attribute);
                        attr.parent = this;
                    }
                    break;

                case Parser.Token.EOF:
                    break;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Attribute;
    }

    /**
     * {@inheritDoc}
     */
    internal override int
    compare (Object inObject)
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
    transform (GLib.Type inType)
    {
        GLib.Value val = GLib.Value (inType);
        if (inType.is_classed () && inType.class_peek () == null)
            inType.class_ref ();

        unowned Transform? transform = null;
        if (s_Transforms != null)
        {
            transform = s_Transforms.search<GLib.Type> (inType, Transform.compare_with_type);
        }

        if (transform == null)
        {
            foreach (unowned Object child in ((Object)this))
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

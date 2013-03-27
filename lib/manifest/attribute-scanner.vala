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

public class Maia.Manifest.AttributeScanner : Parser
{
    // Properties
    private string        m_LastName;
    private Queue<string> m_FunctionQueue;

    // Methods
    construct
    {
        m_FunctionQueue = new Queue<string> ();
    }

    /**
     * Create a new attribute scanner
     *
     * @param inContent buffer content
     */
    public AttributeScanner (string inContent) throws ParseError
    {
        char* begin = (char*)inContent;
        char* end = begin + inContent.length;

        base (begin, end);

        parse ();
    }

    private string
    read_name () throws ParseError
    {
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd)
        {
            skip_space ();

            if (m_pCurrent[0] == '(' || m_pCurrent[0] == ')' || m_pCurrent[0] == ',')
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

        if (m_pCurrent >= m_pEnd)
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
                token = Parser.Token.ATTRIBUTE;
                m_Attribute = m_LastName;
                next_char ();
            }
            else
            {
                token = Parser.Token.ATTRIBUTE;
                m_Attribute = m_LastName;
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
                    Function function = new Function (m_Element);
                    function.parent = this;
                    function.parse (this);
                    break;

                case Parser.Token.END_ELEMENT:
                    break;

                case Parser.Token.ATTRIBUTE:
                    Attribute attr = new Attribute (m_Attribute);
                    attr.parent = this;
                    break;

                case Parser.Token.EOF:
                    break;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    can_append_child (Object inChild)
    {
        return inChild is Attribute;
    }

    /**
     * {@inheritDoc}
     */
    public override int
    compare (Object inObject)
    {
        // do not sort child attributes
        return 0;
    }
}
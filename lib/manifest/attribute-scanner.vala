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
    private Array<string> m_Arguments;
    private Set<string>   m_Grammar;

    // Accessors
    public Array<string> arguments {
        get {
            return m_Arguments;
        }
    }

    // Methods
    construct
    {
        m_FunctionQueue = new Queue<string> ();
        m_Grammar = new Set<string> ();
    }

    /**
     * Create a new attribute scanner
     *
     * @param inContent buffer content
     * @param inLength buffer length
     */
    public AttributeScanner (string inContent, long inLength) throws ParseError
    {
        char* begin = (char*)inContent;
        char* end = begin + inLength;

        base (begin, end);
    }

    private string
    read_name () throws ParseError
    {
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd)
        {
            if (m_pCurrent[0] == '(' || m_pCurrent[0] == ' ')
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

    private string
    extract_argument (char* inpBegin)
    {
        StringBuilder content = new StringBuilder ();

        if (inpBegin != m_pCurrent)
        {
            content.append (((string) inpBegin).substring (0, (int)(m_pCurrent - inpBegin)));
        }

        return content.str;
    }

    private void
    extract_arguments (char inEndChar) throws ParseError
    {
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd && m_pCurrent[0] != inEndChar)
        {
            if (m_pCurrent[0] != ',')
            {
                unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
                if (u == (unichar) (-1))
                {
                    throw new ParseError.INVALID_UTF8 ("Invalid UTF-8 character at %i,%i", m_Line, m_Col);
                }
                else
                {
                    next_unichar (u);
                }
            }
            else
            {
                m_Arguments.insert (extract_argument (begin));
                next_char ();
            }

            skip_space ();
        }

        m_Arguments.insert (extract_argument (begin));
    }

    private void
    read_arguments () throws ParseError
    {
        extract_arguments (')');

        if (m_pCurrent[0] != ')')
            throw new ParseError.INVALID_NAME ("Error on read arguments %s: unexpected end of line at %i,%i missing )",
                                               m_Attribute, m_Line, m_Col);

        if (m_pCurrent == m_pEnd)
            throw new ParseError.INVALID_NAME ("Error on read arguments %s: unexpected end of line at %i,%i",
                                               m_Attribute, m_Line, m_Col);
    }

    internal override Parser.Token
    next_token () throws ParseError
    {
        Parser.Token token = Parser.Token.NONE;

        skip_space ();

        if (m_pCurrent >= m_pEnd)
        {
            m_Element = null;
            m_Arguments = null;
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
                m_Arguments = new Array<string> ();
                next_char ();
                skip_space ();
                read_arguments ();
            }
            else if (m_pCurrent[0] == ')')
            {
                token = Parser.Token.END_ELEMENT;
                m_Element = m_FunctionQueue.pop ();
                m_Arguments = null;
                next_char ();
            }
            else
            {
                token = Parser.Token.ATTRIBUTE;
                m_Element = m_LastName;
                m_Arguments = null;
            }
        }

        return token;
    }

    public void
    register_function (string inFunction)
    {
        m_Grammar.insert (inFunction);
    }

    public new bool
    contains (string inFunction)
    {
        return inFunction in m_Grammar;
    }
}

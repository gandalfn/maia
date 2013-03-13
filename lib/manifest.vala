/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * manifest.vala
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

public class Maia.Manifest : Parser
{
    // Properties
    private string        m_Filename = null;
    private MappedFile    m_File;
    private string        m_LastName;
    private Queue<string> m_ElementQueue;

    // Methods
    construct
    {
        m_ElementQueue = new Queue<string> ();
    }

    /**
     * Create a new manifest from a filename
     *
     * @param inFilename manifest filename
     */
    public Manifest (string inFilename) throws ParseError
    {
        try
        {
            MappedFile file = new MappedFile (inFilename, false);
            this.from_buffer ((string)file.get_contents (), (long)file.get_length ());

            m_Filename = inFilename;
            m_File = (owned)file;
        }
        catch (FileError error)
        {
            throw new ParseError.OPEN("Error on open %s: %s", inFilename, error.message);
        }
    }

    /**
     * Create a new manifest from a buffer
     *
     * @param inContent buffer content
     * @param inLength buffer length
     */
    public Manifest.from_buffer (string inContent, long inLength) throws ParseError
    {
        char* begin = (char*)inContent;
        char* end = begin + inLength;

        base (begin, end);
    }

    private void
    skip_comment ()
    {
        m_pCurrent++;
        if (m_pCurrent < m_pEnd && m_pCurrent[0] == '/')
        {
            m_pCurrent ++;
            while (m_pCurrent < m_pEnd)
            {
                if (m_pCurrent[0] == '\n')
                {
                    m_pCurrent++;
                    break;
                }
                m_pCurrent++;
            }
        }
    }

    private string
    read_name () throws ParseError
    {
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd)
        {
            if (m_pCurrent[0] == '{' || m_pCurrent[0] == '\n' || m_pCurrent[0] == '}' ||
                m_pCurrent[0] == ';' || m_pCurrent[0] == '='  || m_pCurrent[0] == '"' ||
                m_pCurrent[0] == ' ')
                break;

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
                m_pCurrent += u.to_utf8 (null);
            else
                throw new ParseError.INVALID_UTF8 ("invalid UTF-8 character");

            skip_space ();
        }

        if (m_pCurrent == begin)
            return "";

        return ((string) begin).substring (0, (int) (m_pCurrent - begin - 1));
    }

    private void
    read_attribute_value () throws ParseError
    {
        m_CurrentValue = text ('"', true);

        if (m_pCurrent[0] != '"')
            throw new ParseError.INVALID_NAME ("unexpected end of line %s: missing \"", m_CurrentAttribute);
        m_pCurrent++;
        skip_space ();

        if (m_pCurrent == m_pEnd)
            throw new ParseError.INVALID_NAME ("unexpected end of line %s: end of file", m_CurrentAttribute);

        if (m_pCurrent[0] != ';')
            throw new ParseError.INVALID_NAME ("unexpected end of line %s: missing ;, %c", m_CurrentAttribute, m_pCurrent[0]);
        m_pCurrent++;

        if (m_pCurrent == m_pEnd)
            throw new ParseError.INVALID_NAME ("unexpected end of line %s: end of file", m_CurrentAttribute);

        m_Attributes[m_CurrentAttribute] = m_CurrentValue;
    }

    private string
    text (char inEndChar, bool inRmTrailingWhitespace) throws ParseError
    {
        StringBuilder content = new StringBuilder ();
        char* text_begin = m_pCurrent;
        char* last_linebreak = m_pCurrent;

        while (m_pCurrent < m_pEnd && m_pCurrent[0] != inEndChar)
        {
            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u == (unichar) (-1))
            {
                throw new ParseError.INVALID_UTF8 ("invalid UTF-8 character");
            }
            else
            {
                if (u == '\n')
                {
                    last_linebreak = m_pCurrent;
                }

                m_pCurrent += u.to_utf8 (null);
            }
        }

        if (text_begin != m_pCurrent)
        {
            content.append (((string) text_begin).substring (0, (int)(m_pCurrent - text_begin)));
        }

        if (inRmTrailingWhitespace)
        {
            char* str_pos = ((char*)content.str) + content.len;
            for (str_pos--; str_pos > ((char*)content.str) && str_pos[0].isspace(); str_pos--);
            content.erase ((ssize_t) (str_pos-((char*) content.str) + 1), -1);
        }

        return content.str;
    }

    internal override Parser.Token
    next_token () throws ParseError
    {
        Parser.Token token = Parser.Token.NONE;

        skip_space ();

        if (m_pCurrent >= m_pEnd)
        {
            token = Parser.Token.EOF;
        }
        else
        {
            m_LastName = read_name ();
            if (m_pCurrent[0] == '/')
            {
                skip_comment ();
                token = next_token ();
            }
            else if (m_pCurrent[0] == '{')
            {
                token = Parser.Token.START_ELEMENT;
                m_pCurrent++;
                m_Element = m_LastName;
                m_ElementQueue.push (m_Element);
                m_Attributes = new Map<string, string> ();
            }
            else if (m_pCurrent[0] == '=')
            {
                m_CurrentAttribute = m_LastName;
                m_pCurrent++;
                skip_space ();
                if (m_pCurrent[0] == '"')
                {
                    m_pCurrent++;
                    read_attribute_value ();
                    token = Parser.Token.ATTRIBUTE;
                }
                else
                {
                    m_pCurrent++;
                    throw new ParseError.PARSE ("Unexpected attribute value %s", m_LastName);
                }
            }
            else if (m_pCurrent[0] == '}')
            {
                token = Parser.Token.END_ELEMENT;
                m_Element = m_ElementQueue.pop ();
                m_pCurrent++;
            }
            else
            {
                m_pCurrent++;
                throw new ParseError.PARSE ("Unexpected data %s %c", m_Element, m_pCurrent[0]);
            }
        }

        return token;
    }
}

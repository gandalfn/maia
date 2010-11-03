/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-xml-parser.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Maia.XmlParser : Parser
{
    // Properties
    private string      m_Filename = null;
    private MappedFile  m_File;

    // Methods

    /**
     * Create a new xml parser from a filename
     *
     * @param inFilename xml filename
     */
    public XmlParser (string inFilename) throws ParseError
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
     * Create a new xml parser from a buffer
     *
     * @param inContent buffer content
     * @param inLength buffer length
     */
    public XmlParser.from_buffer (string inContent, long inLength) throws ParseError
    {
        char* begin = inContent;
        char* end = begin + inLength;

        base (begin, end);
    }

    private void
    skip_comment ()
    {
        m_pCurrent++;
        if (m_pCurrent < m_pEnd - 1 && m_pCurrent[0] == '-' && m_pCurrent[1] == '-')
        {
            m_pCurrent += 2;
            while (m_pCurrent < m_pEnd - 2)
            {
                if (m_pCurrent[0] == '-' && m_pCurrent[1] == '-' && m_pCurrent[2] == '>')
                {
                    m_pCurrent += 3;
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
            if (m_pCurrent[0] == ' ' || m_pCurrent[0] == '\t' || m_pCurrent[0] == '>' ||
                m_pCurrent[0] == '/' || m_pCurrent[0] == '=' || m_pCurrent[0] == '\n')
                break;

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
                m_pCurrent += u.to_utf8 (null);
            else
                throw new ParseError.INVALID_UTF8 ("invalid UTF-8 character");
        }

        if (m_pCurrent == begin)
            throw new ParseError.INVALID_NAME ("invalid name");

        return ((string) begin).ndup (m_pCurrent - begin);
    }

    private void
    read_attributes () throws ParseError
    {
        while (m_pCurrent < m_pEnd && m_pCurrent[0] != '>' && m_pCurrent[0] != '/')
        {
            string name = read_name ();
            if (m_pCurrent >= m_pEnd || m_pCurrent[0] != '=')
                throw new ParseError.PARSE ("Unexpected end of element %s", m_Element);

            m_pCurrent++;
            if (m_pCurrent >= m_pEnd || m_pCurrent[0] != '"')
                throw new ParseError.PARSE ("Unexpected end of element %s", m_Element);

            m_pCurrent++;
            string value = "";
            //string val = text ('"', false);

            if (m_pCurrent >= m_pEnd || m_pCurrent[0] != '"')
                throw new ParseError.PARSE ("Unexpected end of element %s", m_Element);

            m_pCurrent++;

            m_Attributes[name] = value;
            skip_space ();
        }
    }

    public override Parser.Token
    next_token () throws ParseError
    {
        Parser.Token token = Parser.Token.NONE;

        skip_space ();

        if (m_pCurrent >= m_pEnd)
        {
            token = Parser.Token.EOF;
        }
        else if (m_pCurrent[0] == '<')
        {
            m_pCurrent++;
            if (m_pCurrent >= m_pEnd)
            {
                throw new ParseError.PARSE ("Unexpected end of xml");
            }
            else if (m_pCurrent[0] == '?')
            {
                throw new ParseError.NOT_SUPPORTED ("Processing is not yet supported");
            }
            else if (m_pCurrent[0] == '!')
            {
                skip_comment ();
                token = next_token ();
            }
            else if (m_pCurrent[0] == '/')
            {
                token = Parser.Token.END_ELEMENT;
                m_pCurrent++;
                m_Element = read_name ();
                if (m_pCurrent >= m_pEnd || m_pCurrent[0] != '>')
                    throw new ParseError.PARSE ("Unexpected end of element %s", m_Element);
                m_pCurrent++;
            }
            else
            {
                token = Parser.Token.START_ELEMENT;
                m_Element = read_name ();
                skip_space ();
            }
        }

        return token;
    }
}
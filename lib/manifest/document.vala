/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * document.vala
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

public class Maia.Manifest.Document : Parser
{
    // Types
    internal class ElementTag
    {
        public string m_Tag;
        public string m_Id;

        public ElementTag (string inElement)
        {
            string[] split = inElement.split (".", 2);
            if (split.length == 2)
            {
                m_Tag = split[0];
                m_Id = split[1];
            }
            else
            {
                m_Tag = inElement;
                m_Id = null;
            }
        }
    }

    // Properties
    private string            m_Filename = null;
    private MappedFile        m_File;
    private string            m_LastName;
    private ElementTag        m_CurrentTag = null;
    private Queue<ElementTag> m_ElementQueue;
    private AttributeScanner  m_Scanner;

    // Accessors
    public Object owner { get; set; default = null; }

    public AttributeScanner scanner {
        get {
            return m_Scanner;
        }
    }

    public string? element_tag {
        get {
            return m_CurrentTag != null ? m_CurrentTag.m_Tag : null;
        }
    }

    public string? element_id {
        get {
            return m_CurrentTag != null ? m_CurrentTag.m_Id : null;
        }
    }

    // Methods
    construct
    {
        m_ElementQueue = new Queue<ElementTag> ();
    }

    /**
     * Create a new document manifest from a filename
     *
     * @param inFilename manifest filename
     */
    public Document (string inFilename) throws ParseError
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
     * Create a new document manifest from a buffer
     *
     * @param inContent buffer content
     * @param inLength buffer length
     */
    public Document.from_buffer (string inContent, long inLength) throws ParseError
    {
        char* begin = (char*)inContent;
        char* end = begin + inLength;

        base (begin, end);
    }

    private void
    skip_comment ()
    {
        if (m_pCurrent < m_pEnd - 1 && m_pCurrent[0] == '/' && m_pCurrent[1] == '/')
        {
            while (m_pCurrent < m_pEnd)
            {
                if (m_pCurrent[0] == '\n')
                {
                    next_char ();
                    break;
                }
                next_char ();
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
                m_pCurrent[0] == ';' || m_pCurrent[0] == ':')
                break;

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
                next_unichar (u);
            else
                throw new ParseError.INVALID_UTF8 ("Invalid UTF-8 character at %i,%i", m_Line, m_Col);

            skip_space ();
        }

        if (m_pCurrent == begin)
            return "";

        return ((string) begin).substring (0, (int) (m_pCurrent - begin)).chomp ();
    }

    private void
    read_attribute_value () throws ParseError
    {
        m_Scanner = new AttributeScanner (owner, ref m_pCurrent, m_pEnd, ';');

        if (m_pCurrent[0] != ';')
            throw new ParseError.INVALID_NAME ("Error on read attribute value %s: unexpected end of line at %i,%i missing ;",
                                               m_Attribute, m_Line, m_Col);
        next_char ();

        if (m_pCurrent == m_pEnd)
            throw new ParseError.INVALID_NAME ("Error on read attribute value %s: unexpected end of line at %i,%i",
                                               m_Attribute, m_Line, m_Col);
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
        else if (m_pCurrent[0] == '/')
        {
            skip_comment ();
            token = next_token ();
        }
        else
        {
            m_LastName = read_name ();
            if (m_pCurrent[0] == '{')
            {
                token = Parser.Token.START_ELEMENT;
                next_char ();
                m_CurrentTag = new ElementTag (m_LastName);
                m_ElementQueue.push (m_CurrentTag);
                m_Attributes = new Map<string, string> ();
            }
            else if (m_pCurrent[0] == ':')
            {
                token = Parser.Token.ATTRIBUTE;
                next_char ();
                skip_space ();
                m_Attribute = m_LastName;
                read_attribute_value ();
            }
            else if (m_pCurrent[0] == '}')
            {
                token = Parser.Token.END_ELEMENT;
                m_CurrentTag = m_ElementQueue.pop ();
                next_char ();
            }
            else
            {
                next_char ();
                throw new ParseError.PARSE ("Unexpected data for %s at %i,%i", m_Element, m_Line, m_Col);
            }
        }

        return token;
    }

    public new Element?
    @get (string inElement, string? inId = null) throws ParseError
    {
        // return on begining of file
        m_pCurrent = m_pBegin;

        // search first element which match
        foreach (Parser.Token token in this)
        {
            if (token == Parser.Token.START_ELEMENT)
            {
                if (element_tag == inElement && element_id == inId)
                {
                    Element? ret = Element.create (element_tag, element_id);
                    if (ret != null)
                    {
                        ret.read_manifest (this);
                    }

                    return ret;
                }
            }
        }

        return null;
    }
}

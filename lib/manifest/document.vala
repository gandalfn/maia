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

public errordomain Maia.Manifest.Error
{
    INVALID_TYPE,
    TOO_MANY_ATTRIBUTES,
    MISSING_ATTRIBUTES,
    TOO_MANY_FUNCTION_ARGUMENT,
    MISSING_FUNCTION_ARGUMENT
}

public class Maia.Manifest.Document : Core.Parser
{
    // Types
    public delegate void AttributeBindCallback (Object inOwner, string inProperty, string inValue);

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
    private string                 m_Filename = null;
    private MappedFile             m_File;
    private string                 m_LastName;
    private ElementTag             m_CurrentTag = null;
    private Core.Queue<ElementTag> m_ElementQueue;
    private AttributeScanner       m_Scanner;
    private AttributeBindCallback  m_AttributeBindCallback = null;

    // Accessors
    public Object owner { get; set; default = null; }

    public AttributeBindCallback attribute_bind_func {
        owned set {
            m_AttributeBindCallback = (owned)value;
        }
    }

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
        m_ElementQueue = new Core.Queue<ElementTag> ();
    }

    /**
     * Create a new manifest from a filename
     *
     * @param inFilename manifest filename
     */
    public Document (string inFilename) throws Core.ParseError
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
            throw new Core.ParseError.OPEN("Error on open %s: %s", inFilename, error.message);
        }
    }

    /**
     * Create a new manifest from a buffer
     *
     * @param inContent buffer content
     * @param inLength buffer length
     */
    public Document.from_buffer (string inContent, long inLength) throws Core.ParseError
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
    read_name () throws Core.ParseError
    {
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd)
        {
            if (m_pCurrent[0] == '{' || m_pCurrent[0] == '\n' || m_pCurrent[0] == '}' ||
                m_pCurrent[0] == ';' || m_pCurrent[0] == ':' || m_pCurrent[0] == '[')
                break;

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
                next_unichar (u);
            else
                throw new Core.ParseError.INVALID_UTF8 ("Invalid UTF-8 character at %i,%i", m_Line, m_Col);

            skip_space ();
        }

        if (m_pCurrent == begin)
            return "";

        return ((string) begin).substring (0, (int) (m_pCurrent - begin)).chomp ();
    }

    private void
    read_attribute_value () throws Core.ParseError
    {
        if (m_AttributeBindCallback != null)
        {
            string property = m_Attribute;
            m_Scanner = new AttributeScanner (owner, ref m_pCurrent, m_pEnd, ';', (o, a) => {
                    m_AttributeBindCallback (o, property, a);
                });
        }
        else
        {
            m_Scanner = new AttributeScanner (owner, ref m_pCurrent, m_pEnd, ';');
        }

        if (m_pCurrent[0] != ';')
            throw new Core.ParseError.INVALID_NAME ("Error on read attribute value %s: unexpected end of line at %i,%i missing ;",
                                                    m_Attribute, m_Line, m_Col);
        next_char ();

        if (m_pCurrent == m_pEnd)
            throw new Core.ParseError.INVALID_NAME ("Error on read attribute value %s: unexpected end of line at %i,%i",
                                                    m_Attribute, m_Line, m_Col);
    }

    private string
    read_characters () throws Core.ParseError
    {
        char* begin = m_pCurrent;
        int nb_brackets = 0;

        while (m_pCurrent < m_pEnd)
        {
            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u == (unichar) (-1))
            {
                throw new Core.ParseError.INVALID_UTF8 ("invalid UTF-8 character");
            }
            else
            {
                if (u == '[')
                {
                    nb_brackets++;
                }
                else if (u == ']')
                {
                    nb_brackets--;
                }

                if (nb_brackets == 0) break;

                next_unichar (u);
            }
        }

        if (m_pCurrent == begin)
            return "";

        return ((string) begin).substring (1, (int) (m_pCurrent - begin) - (nb_brackets == 0 ? 2 : 0)).strip ();;
    }

    internal override Core.Parser.Token
    next_token () throws Core.ParseError
    {
        Core.Parser.Token token = Core.Parser.Token.NONE;

        skip_space ();

        if (m_pCurrent >= m_pEnd)
        {
            token = Core.Parser.Token.EOF;
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
                token = Core.Parser.Token.START_ELEMENT;
                next_char ();
                m_CurrentTag = new ElementTag (m_LastName);
                m_ElementQueue.push (m_CurrentTag);
                m_Attributes = new Core.Map<string, string> ();
            }
            else if (m_pCurrent[0] == '[')
            {
                token = Maia.Core.Parser.Token.CHARACTERS;
                m_Characters = read_characters ();
                next_char ();
                skip_space ();
            }
            else if (m_pCurrent[0] == ':')
            {
                token = Core.Parser.Token.ATTRIBUTE;
                next_char ();
                skip_space ();
                m_Attribute = m_LastName;
                read_attribute_value ();
            }
            else if (m_pCurrent[0] == '}')
            {
                token = Core.Parser.Token.END_ELEMENT;
                m_CurrentTag = m_ElementQueue.pop ();
                next_char ();
            }
            else
            {
                next_char ();
                throw new Core.ParseError.PARSE ("Unexpected data for %s at %i,%i", m_Element, m_Line, m_Col);
            }
        }

        return token;
    }

    /**
     * Get element in document
     *
     * @param inId id of element to get from document else ``null`` to get
     *             the first element found.
     *
     * @return the element found in document
     *
     * @throws Core.ParseError if something goes wrong
     */
    // TODO: the current implementation of get element requires to reparse all
    //       document. I must find a new way which only require one parsing.
    public new Element?
    @get (string? inId = null) throws Core.ParseError
    {
        bool first = true;

        // return on begining of file
        m_pCurrent = m_pBegin;

        // search first element which match
        foreach (Core.Parser.Token token in this)
        {
            if (token == Core.Parser.Token.START_ELEMENT)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"tag: $element_tag, id: $element_id");
                if ((inId == null && first) || element_id == inId)
                {
                    Element? ret = Element.create (element_tag, element_id);
                    if (ret != null)
                    {
                        ret.read_manifest (this);
                    }

                    return ret;
                }
                first = true;
            }
        }

        return null;
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * buffer.vala
 * Copyright (C) Nicolas Bruguier 2010-2015 <gandalfn@club-internet.fr>
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

public errordomain Maia.ProtocolError
{
    INVALID_TYPE,
    INVALID_OPTION,
    INVALID_DEFAULT_VALUE,
    MISSING_MESSAGE
}

public class Maia.Protocol.Buffer : Core.Parser
{
    // Types
    private struct Attribute
    {
        public string rule;
        public string type;
        public string name;
        public string options;
    }

    // Properties
    private string                  m_Filename = "";
    private MappedFile              m_File;
    private string                  m_LastWord;
    private string?                 m_CurrentMessage = null;
    private Core.Stack<string>      m_MessageStack;
    private Attribute?              m_CurrentAttribute = null;

    // accessors
    internal string message {
        get {
            return m_CurrentMessage;
        }
    }

    internal string attribute_name {
        get {
            return m_CurrentAttribute != null ? m_CurrentAttribute.name : null;
        }
    }

    internal string attribute_rule {
        get {
            return m_CurrentAttribute != null ? m_CurrentAttribute.rule : null;
        }
    }

    internal string attribute_type {
        get {
            return m_CurrentAttribute != null ? m_CurrentAttribute.type : null;
        }
    }

    internal string attribute_options {
        get {
            return m_CurrentAttribute != null ? m_CurrentAttribute.options : null;
        }
    }

    // Methods
    construct
    {
        m_MessageStack = new Core.Stack<string> ();
    }

    /**
     * Create a new protocol buffer from a filename
     *
     * @param inFilename proto filename
     */
    public Buffer (string inFilename) throws Core.ParseError
    {
        try
        {
            MappedFile file = new MappedFile (inFilename, false);

            char* begin = (char*)file.get_contents ();
            char* end = begin + file.get_length ();

            base (begin, end);

            m_Filename = inFilename;
            m_File = (owned)file;

            parse ();
        }
        catch (FileError error)
        {
            throw new Core.ParseError.OPEN(@"Error on open $inFilename: $(error.message)");
        }
    }

    /**
     * Create a new protocol buffer from a buffer
     *
     * @param inContent buffer content
     * @param inLength buffer length
     */
    public Buffer.from_data (string inContent, long inLength) throws Core.ParseError
    {
        char* begin = (char*)inContent;
        char* end = begin + inLength;

        base (begin, end);

        parse ();
    }

    private void
    parse () throws Core.ParseError
    {
        // return on begining of file
        m_pCurrent = m_pBegin;

        foreach (Core.Parser.Token token in this)
        {
            if (token == Core.Parser.Token.START_ELEMENT)
            {
                Message msg = new Message (message);
                add (msg);
                try
                {
                    msg.read_buffer (this);
                }
                catch (ProtocolError err)
                {
                    throw new Core.ParseError.PARSE (@"$(err.message) at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
                }
            }
        }
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
    read_word (bool inKeepSpace = false) throws Core.ParseError
    {
        bool have_char = false;
        bool in_template = false;
        char* begin = m_pCurrent;

        while (m_pCurrent < m_pEnd)
        {
            if (m_pCurrent[0] == '{' || m_pCurrent[0] == '\n' || m_pCurrent[0] == '}' ||
                m_pCurrent[0] == '[' || m_pCurrent[0] == ']' || m_pCurrent[0] == ';' ||
                (in_template && m_pCurrent[0] == '>') ||
                (have_char && !in_template && (m_pCurrent[0] == ' ' || m_pCurrent[0] == '\t')))
                break;

            if (m_pCurrent == "<")
            {
                in_template = true;
            }

            unichar u = ((string) m_pCurrent).get_char_validated ((long) (m_pEnd - m_pCurrent));
            if (u != (unichar) (-1))
            {
                next_unichar (u);
                have_char = !inKeepSpace;
            }
            else
            {
                throw new Core.ParseError.INVALID_UTF8 (@"Invalid UTF-8 character at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
            }

            if (!have_char)
            {
                skip_space ();
            }
        }

        if (m_pCurrent == begin)
            return "";

        skip_space ();

        return ((string) begin).substring (0, (int) (m_pCurrent - begin)).chomp ();
    }

    private void
    read_message () throws Core.ParseError
    {
        if (m_pCurrent[0] == '{')
        {
            throw new Core.ParseError.PARSE (@"Unexpected message at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }

        m_LastWord = read_word ();

        if (m_LastWord == "")
        {
            throw new Core.ParseError.PARSE (@"Unexpected message at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }

        m_MessageStack.push (m_CurrentMessage);
        m_CurrentMessage = m_LastWord;

        if (m_pCurrent[0] != '{')
        {
            throw new Core.ParseError.PARSE (@"Unexpected message at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }
    }

    private void
    read_attribute () throws Core.ParseError
    {
        if (m_LastWord == "repeated")
        {
            m_CurrentAttribute = { m_LastWord, null, null, null };

            if (m_pCurrent[0] == ';')
            {
                throw new Core.ParseError.PARSE (@"Unexpected attribute at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
            }

            m_CurrentAttribute.type = read_word ();
        }
        else
        {
            m_CurrentAttribute = { "", m_LastWord, null, null };
        }

        if (m_pCurrent[0] == ';')
        {
            throw new Core.ParseError.PARSE (@"Unexpected attribute at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }

        if (m_CurrentAttribute.type == "")
        {
            throw new Core.ParseError.PARSE (@"Unexpected attribute at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }

        m_CurrentAttribute.name = read_word ();

        if (m_CurrentAttribute.name == "")
        {
            throw new Core.ParseError.PARSE (@"Unexpected attribute at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }

        if (m_pCurrent[0] == '[')
        {
            next_char ();
            m_CurrentAttribute.options = read_word (true);

            if (m_CurrentAttribute.options == "" || m_pCurrent[0] != ']')
            {
                throw new Core.ParseError.PARSE (@"Unexpected attribute options at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
            }

            next_char ();
            skip_space ();
        }

        if (m_pCurrent[0] != ';')
        {
            throw new Core.ParseError.PARSE (@"Unexpected attribute at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
        }
    }

    internal override bool
    can_append_child (Core.Object inChild)
    {
        return inChild is BufferChild;
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
            m_LastWord = read_word ();

            if (m_LastWord == "message")
            {
                read_message ();
            }
            else if (m_LastWord != "")
            {
                read_attribute ();
            }

            if (m_pCurrent[0] == '{')
            {
                token = Core.Parser.Token.START_ELEMENT;
                next_char ();
            }
            else if (m_pCurrent[0] == ';')
            {
                token = Core.Parser.Token.ATTRIBUTE;
                next_char ();
            }
            else if (m_pCurrent[0] == '}')
            {
                token = Core.Parser.Token.END_ELEMENT;
                if (m_MessageStack.length == 0)
                {
                    throw new Core.ParseError.PARSE (@"Unexpected end at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
                }
                m_CurrentMessage = m_MessageStack.pop ();
                next_char ();
            }
            else
            {
                next_char ();
                throw new Core.ParseError.PARSE (@"Unexpected data at $(GLib.Path.get_basename (m_Filename)):$m_Line,$m_Col");
            }
        }

        return token;
    }

    public new unowned Message?
    @get (string inName)
    {
        string[] split = inName.split (".");

        unowned Message? msg = find (GLib.Quark.from_string (split[0]), false) as Message;
        if (msg != null && split.length > 1)
        {
            msg = msg.get_message (string.joinv(".", split[1:split.length]));
        }

        return msg;
    }
}

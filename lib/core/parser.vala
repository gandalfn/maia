/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * parser.vala
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

public errordomain Maia.Core.ParseError
{
    OPEN,
    INVALID,
    PARSE,
    NOT_SUPPORTED,
    INVALID_UTF8,
    INVALID_NAME
}

public abstract class Maia.Core.Parser : Object
{
    // Types
    public enum Token
    {
        NONE,
        START_ELEMENT,
        ATTRIBUTE,
        END_ELEMENT,
        CHARACTERS,
        EOF
    }

    public class Iterator
    {
        private Parser       m_Parser;
        private Parser.Token m_Current;

        internal Iterator (Parser inParser)
        {
            m_Parser = inParser;
        }

        internal Iterator.end (Parser inParser)
        {
            m_Parser = inParser;
            m_Current = Parser.Token.EOF;
        }

        public bool
        next () throws ParseError
        {
            if (m_Current != Parser.Token.EOF)
            {
                m_Current = m_Parser.next_token ();
            }

            return m_Current != Parser.Token.EOF;
        }

        public new unowned Token
        get ()
        {
            return m_Current;
        }

        public bool
        compare (Iterator inIter)
        {
            return m_Current == inIter.m_Current && m_Parser == inIter.m_Parser;
        }

        public bool
        is_end ()
        {
            return m_Current == Parser.Token.EOF;
        }
    }

    // Properties
    protected char*               m_pBegin;
    protected char*               m_pEnd;
    protected char*               m_pCurrent;
    protected int                 m_Line;
    protected int                 m_Col;

    protected string              m_Element    = null;
    protected Map<string, string> m_Attributes = null;
    protected string              m_Characters = null;
    protected string              m_Attribute  = null;
    protected string              m_Value      = null;

    // Accessors
    public string element {
        get {
            return m_Element;
        }
    }

    public Map<string, string> attributes {
        get {
            return m_Attributes;
        }
    }

    public string attribute {
        get {
            return m_Attribute;
        }
    }

    public string val {
        get {
            return m_Value;
        }
    }

    public string characters {
        get {
            return m_Characters;
        }
    }

    public int line {
        get {
            return m_Line;
        }
    }

    public int column {
        get {
            return m_Col;
        }
    }

    // Methods
    /**
     * Create a new parser
     */
    public Parser (char* inpBegin, char* inpEnd) throws ParseError
    {
        if (inpBegin >= inpEnd)
        {
            throw new ParseError.INVALID ("Invalid content");
        }

        m_pBegin = inpBegin;
        m_pEnd = inpEnd;
        m_pCurrent = m_pBegin;
    }

    protected inline void
    next_char ()
    {
        if (m_pCurrent[0] == '\n')
        {
            m_Line++;
            m_Col = 0;
        }
        else
            m_Col++;
        m_pCurrent++;
    }

    protected inline void
    next_unichar (unichar inChar)
    {
        if (inChar == '\n')
        {
            m_Line++;
            m_Col = 0;
        }
        else
            m_Col++;
        m_pCurrent += inChar.to_utf8 (null);
    }

    protected void
    skip_space ()
    {
        while (m_pCurrent < m_pEnd &&
               (m_pCurrent[0] == ' '  || m_pCurrent[0] == '\n' ||
                m_pCurrent[0] == '\r' || m_pCurrent[0] == '\t'))
            next_char ();
    }

    protected abstract Token next_token () throws ParseError;

    public new Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    public new Iterator
    iterator_end ()
    {
        return new Iterator.end (this);
    }

    public string
    get_current_line ()
    {
        char* begin = m_pCurrent;
        while (begin != m_pBegin)
        {
            begin--;
            if (begin[0] == '\n')
            {
                begin++;
                break;
            }
        }
        char* end = m_pCurrent;
        while (end < m_pEnd)
        {
            end++;
            if (end[0] == '\n')
            {
                end--;
                break;
            }
        }
        return ((string)begin).substring (0, (int)(end - begin)).strip ();
    }
}

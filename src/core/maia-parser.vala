/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-parser.vala
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

public errordomain Maia.ParseError
{
    OPEN,
    INVALID,
    PARSE,
    NOT_SUPPORTED,
    INVALID_UTF8,
    INVALID_NAME
}

public abstract class Maia.Parser : Object
{
    // Types
    public delegate void StartElementFunc (Parser inParser, string inName,
                                           GLib.Parameter[] inParameter);
    public delegate void TextFunc         (Parser inParser, string inText);
    public delegate void EndElementFunc   (Parser inParser, string inName);

    public enum Token
    {
        NONE,
        START_ELEMENT,
        TEXT,
        END_ELEMENT,
        EOF
    }

    private struct Callbacks
    {
        public StartElementFunc   m_StartElementFunc;
        public TextFunc           m_TextFunc;
        public EndElementFunc     m_EndElementFunc;

        public Callbacks (StartElementFunc? inStartElementFunc,
                          TextFunc?         inTextFunc,
                          EndElementFunc?   inEndElementFunc)
        {
            m_StartElementFunc = inStartElementFunc;
            m_TextFunc = inTextFunc;
            m_EndElementFunc = inEndElementFunc;
        }
    }

    // Properties
    private List<Callbacks?>      m_Callbacks = null;

    protected char*               m_pBegin;
    protected char*               m_pEnd;
    protected char*               m_pCurrent;
    protected string              m_Element    = null;
    protected Map<string, string> m_Attributes = null;
    protected string              m_Text       = null;

    // Accessors
    public string current_element {
        get {
            return m_Element;
        }
    }

    public GLib.Parameter[] attributes {
        owned get {
            GLib.Parameter[] parameter = new GLib.Parameter[m_Attributes.nb_items];

            int cpt = 0;
            foreach (Pair<string, string> pair in m_Attributes)
            {
                parameter[cpt].name = pair.first;
                parameter[cpt].value = pair.second;
                cpt++;
            }

            return parameter;
        }
    }

    public string text {
        get {
            return m_Text;
        }
    }

    public StartElementFunc start_element {
        set {
            m_Callbacks.last().m_StartElementFunc = value;
        }
    }

    public TextFunc text_element {
        set {
            m_Callbacks.last().m_TextFunc = value;
        }
    }

    public EndElementFunc end_element {
        set {
            m_Callbacks.last().m_EndElementFunc = value;
        }
    }

    // Methods

    /**
     * Create a new parser
     */
    public Parser (char* inpBegin, char* inpEnd) throws ParseError
    {
        if (inpBegin <= inpEnd)
        {
            throw new ParseError.INVALID ("Invalid content");
        }

        m_pBegin = inpBegin;
        m_pEnd = inpEnd;
        m_pCurrent = m_pBegin;

        m_Callbacks = new List<Callbacks?> ();
        push ();
    }

    protected void
    skip_space ()
    {
        while (m_pCurrent < m_pEnd && m_pCurrent[0].isspace ())
            m_pCurrent++;
    }

    protected abstract Token next_token () throws ParseError;

    public void
    push ()
    {
        m_Callbacks.insert (Callbacks (null, null, null));
    }

    public void
    pop ()
    {
        if (m_Callbacks.nb_items > 1)
        {
            Iterator<Callbacks?> iterator = m_Callbacks[m_Callbacks.last ()];
            m_Callbacks.erase (iterator);
        }
    }

    public void
    parse () throws ParseError
    {
        Token token = next_token ();

        while (token != Token.EOF)
        {
            switch (token)
            {
                case Token.START_ELEMENT:
                    StartElementFunc func = m_Callbacks.last().m_StartElementFunc;
                    if (func != null) 
                        func (this, m_Element, attributes);
                    break;
                case Token.TEXT:
                    TextFunc func = m_Callbacks.last().m_TextFunc;
                    if (func != null) 
                        func (this, m_Text);
                    break;
                case Token.END_ELEMENT:
                    EndElementFunc func = m_Callbacks.last().m_EndElementFunc;
                    if (func != null) 
                        func (this, m_Element);
                    break;
                default:
                    break;
            }
            token = next_token ();
        }
    }
}
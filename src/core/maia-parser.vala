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

public abstract class Maia.Parser : Object
{
    private unowned string m_Content;
    private Vala.HashMap <string, Token> m_Dictionnary;

    /**
     * Create a new parser
     *
     * @param inContent string to parse
     */
    public Parser (string inContent)
    {
        m_Content = inContent;
        m_Dictionnary = new Vala.HashMap <string, Token> ();
    }

    /**
     * Parse the content and construct the dictionnary
     */
    public abstract void parse ();

    /**
     * Get a token by its identifier
     *
     * @param inId token identifier
     *
     * @return Token identified by inId
     */
    public new Token
    @get (string inId)
    {
        return m_Dictionnary[inId];
    }

    /**
     * Set or add a token
     *
     * @param inId token identifier
     * @param inToken token
     */
    public void
    @set (string inId, Token inToken)
    {
        m_Dictionnary[inId] = inToken;
    }

    /**
     * Returns a Iterator that can be used for simple iteration over a
     * token dictionnary.
     *
     * @return a Iterator that can be used for simple iteration over a
     *         token dictionnary
     */
    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    public class Iterator : Object
    {
        private Vala.Iterator <Token> m_Iterator;

        internal Iterator (Parser inParser)
        {
            m_Iterator = inParser.m_Dictionnary.get_values ().iterator ();
        }

        /**
         * Advances to the next Token in the dictionnary.
         *
         * @return true if the iterator has a next Token
         */
        public bool
        next ()
        {
            return m_Iterator.next ();
        }

        /**
         * Returns the current Token in the iteration.
         *
         * @return the current Token in the iteration
         */
        public Token?
        get ()
        {
            return m_Iterator.get ();
        }
    }
}
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
    // Properties
    private class Vala.HashMap <string, GLib.Type> c_Grammar;

    private unowned string m_Content = null;
    private Token m_CurrentToken = Token.NONE;

    class construct 
    {
        c_Grammar = new Vala.HashMap <string, GLib.Type> ();
    }

    /**
     * Create a new parser
     */
    public Parser (string inContent)
    {
        m_Content = inContent;
    }

    /**
     * Parse the content and construct the dictionnary
     */
    public abstract unowned string parse (string inContent);

    /**
     * Get a token by its identifier
     *
     * @param inId token identifier
     *
     * @return Token identified by inId
     */
    public new GLib.Type
    @get (string inId)
    {
        return c_Grammar[inId];
    }

    /**
     * Set or add a token
     *
     * @param inId token identifier
     * @param inToken token
     */
    public class void
    @set (string inId, GLib.Type inType)
    {
        c_Grammar[inId] = inType;
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

    public class Iterator
    {
        private Vala.Iterator <GLib.Type> m_Iterator;

        internal Iterator (Parser inParser)
        {
            m_Iterator = inParser.c_Grammar.get_values ().iterator ();
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
        public GLib.Type?
        get ()
        {
            return m_Iterator.get ();
        }
    }
}
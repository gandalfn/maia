/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-context.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.Context : Object
{
    private Backend m_Backend = null; 

    /**
     * Context backend
     */
    public Backend backend {
        get {
            return m_Backend;
        }
    }

    /**
     * The number of screens in the current context
     */
    public uint nb_screens {
        get {
            return m_Backend.nb_screens;
        }
    }

    /**
     * Create a new context
     *
     * @param inBackend context backend
     */
    public Context (Backend inBackend)
    {
        m_Backend = inBackend;
    }

    /**
     * Get the screen corresponding to specified number.
     *
     * @param inNumScreen screen number
     *
     * @return the screen corresponding to inNumScreen
     */
    public new Screen?
    @get (int inNumScreen)
        requires (m_Backend != null)
        requires (inNumScreen < m_Backend.nb_screens)
    {
        return m_Backend.get_screen (inNumScreen);
    }

    /**
     * Returns a Iterator that can be used for simple iteration over a
     * screens.
     *
     * @return a Iterator that can be used for simple iteration over a
     *         screens
     */
    public Iterator
    iterator ()
        requires (m_Backend != null)
    {
        return new Iterator (this);
    }

    public class Iterator
    {
        private Context m_Context;
        private int m_Index = -1;

        internal Iterator (Context inContext)
        {
            m_Context = inContext;
        }

        /**
         * Advances to the next screen in the context.
         *
         * @return true if the iterator has a next screen
         */
        public bool
        next ()
        {
            if (m_Index < m_Context.m_Backend.nb_screens)
                m_Index++;

            return (m_Index < m_Context.m_Backend.nb_screens);
        }

        /**
         * Returns the current screen in the iteration.
         *
         * @return the current screen in the iteration
         */
        public Screen?
        @get ()
        {
            if (m_Index < 0 || m_Index >= m_Context.m_Backend.nb_screens)
                return null;

            return m_Context.m_Backend.get_screen (m_Index);
        }
    }
}
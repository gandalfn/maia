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
    private static Map <string, GLib.Type> s_Grammar;

    private unowned string m_Content;
    private Token m_CurrentToken = Token.NONE;
    private List<Object> m_Objects;

    static construct 
    {
        s_Grammar = new Map <string, GLib.Type> ((Collection.CompareFunc)GLib.strcmp);
    }

    public static void
    add_syntax (string inSyntax, GLib.Type inType)
    {
        s_Grammar[inSyntax] = inType;
    }

    /**
     * Create a new parser
     */
    public Parser (string inContent)
    {
        m_Content = inContent;
        m_Objects = new List<Object> ();
    }

    /**
     * Parse the content and construct the dictionnary
     */
    public void
    parse ()
    {
        
    }
}
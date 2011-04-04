/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offarray: 4; tab-width: 4 -*- */
/*
 * pair.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public class Maia.Pair <F, S>
{
    // properties
    private CompareFunc<F>  m_CompareFunc;
    private ToStringFunc<F> m_ToStringFuncFirst;
    private ToStringFunc<S> m_ToStringFuncSecond;

    // accessors
    public F first { get; set; }
    public S second { get; set; }

    // methods
    public Pair (F inFirst, S inSecond)
    {
        first = inFirst;
        second = inSecond;

        m_CompareFunc = get_compare_func_for<F> ();
        m_ToStringFuncFirst = get_to_string_func_for<F> ();
        m_ToStringFuncSecond = get_to_string_func_for<S> ();
    }

    public int
    compare (Object inOther)
        requires (inOther is Pair <F, S>)
    {
        return m_CompareFunc (first, ((Pair<F, S>)inOther).first);
    }

    internal int
    compare_with_first (F inFirst)
    {
        return m_CompareFunc (first, inFirst);
    }

    public string
    to_string ()
    {
        return m_ToStringFuncFirst (first) + " " + m_ToStringFuncSecond (second);
    }
}
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
    private F               m_First;
    private S               m_Second;
    private CompareFunc<F>  m_CompareFunc;
    private ToStringFunc<F> m_ToStringFuncFirst;
    private ToStringFunc<S> m_ToStringFuncSecond;

    // accessors
    public F first { 
        get {
            return m_First;
        }
        set {
            m_First = value;
        }
    }

    public S second { 
        get {
            return m_Second;
        }
        set {
            m_Second = value;
        }
    }

    // methods
    public Pair (F inFirst, S inSecond)
    {
        m_First = inFirst;
        m_Second = inSecond;

        m_CompareFunc = get_compare_func_for<F> ();
        m_ToStringFuncFirst = get_to_string_func_for<F> ();
        m_ToStringFuncSecond = get_to_string_func_for<S> ();
    }

    public int
    compare (Object inOther)
        requires (inOther is Pair <F, S>)
    {
        return m_CompareFunc (m_First, ((Pair<F, S>)inOther).m_First);
    }

    internal int
    compare_with_first (F inFirst)
    {
        return m_CompareFunc (m_First, inFirst);
    }

    public string
    to_string ()
    {
        return m_ToStringFuncFirst (m_First) + " " + m_ToStringFuncSecond (m_Second);
    }
}
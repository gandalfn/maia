/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offarray: 4; tab-width: 4 -*- */
/*
 * maia-pair.vala
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

public class Maia.Pair <F, S> : Object
{
    // properties
    private EqualFunc<F>    m_EqualFunc;
    private CompareFunc<F>  m_CompareFunc;
    private ToStringFunc<F> m_ToStringFuncFirst;
    private ToStringFunc<S> m_ToStringFuncSecond;

    public F first;
    public S second;

    // methods
    public Pair (owned F inFirst, owned S inSecond)
    {
        first = (owned)inFirst;
        second = (owned)inSecond;

        m_EqualFunc = get_equal_func_for<F> ();
        m_CompareFunc = get_compare_func_for<F> ();
        m_ToStringFuncFirst = get_to_string_func_for<F> ();
        m_ToStringFuncSecond = get_to_string_func_for<S> ();
    }

    public override bool
    equals (Object inOther)
        requires (inOther is Pair <F, S>)
    {
        return m_EqualFunc (first, (inOther as Pair<F, S>).first);
    }

    public override int
    compare (Object inOther)
        requires (inOther is Pair <F, S>)
    {
        return m_CompareFunc (first, (inOther as Pair<F, S>).first);
    }

    public override string
    to_string ()
    {
        return m_ToStringFuncFirst (first) + " " + m_ToStringFuncSecond (second);
    }
}
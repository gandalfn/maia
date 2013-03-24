/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offarray: 4; tab-width: 4 -*- */
/*
 * pair.vala
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

public class Maia.Pair <F, S>
{
    // properties
    private CompareFunc<F>  m_CompareFunc;

    // accessors
    public F first { get; set; }
    public S second { get; set; }

    // methods
    public Pair (F inFirst, S inSecond)
    {
        first = inFirst;
        second = inSecond;

        m_CompareFunc = get_compare_func_for<F> ();
    }

    public int
    compare (Object inOther)
    {
        return m_CompareFunc (first, ((Pair<F, S>)inOther).first);
    }

    internal int
    compare_with_first (F inFirst)
    {
        return m_CompareFunc (first, inFirst);
    }
}

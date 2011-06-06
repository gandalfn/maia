/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-list.vala
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

public class Maia.AtomicList<T>
{
    // properties
    private AtomicNode<T>         m_First;
    private unowned AtomicNode<T> m_Last;

    public AtomicList ()
    {
        m_First = AtomicNode.create (null);
        m_First.next = AtomicNode.create (null);
        m_First.next.next = AtomicNode.create (null);
        m_Last = m_First.next.next;

        AtomicIterator<T> iter = new AtomicIterator<T> (m_First, m_Last);
        iter.update ();
    }

    public void
    insert (owned T inData)
    {
        AtomicIterator<T> iter = new AtomicIterator<T> (m_First, m_Last);
        CompareFunc<T> func = get_compare_func_for<T> ();

        AtomicNode<T> node = AtomicNode.create (new AtomicNode.Data<T> (inData));
        AtomicNode<T> aux = AtomicNode.create_aux ();

        while (true)
        {
            if (iter.search (inData, func)) break;

            if (iter.try_insert (node, aux)) break;

            iter.update ();
        };
    }

    public AtomicIterator<T>
    iterator ()
    {
        return new AtomicIterator<T> (m_First, m_Last);
    }
}
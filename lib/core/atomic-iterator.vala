/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-iterator.vala
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

public abstract class Maia.AtomicIterator<T> : Iterator<T>
{
    private AtomicNode<T> m_Last;
    private AtomicNode<T> m_Target;
    private AtomicNode<T> m_PreAux;
    private AtomicNode<T> m_PreCell;

    public AtomicIterator (AtomicNode<T> inFirst, AtomicNode<T> inLast)
    {
        m_Last = inLast;
        m_PreCell = inFirst;
        m_PreAux = inFirst.next;
        m_Target = null;

        update ();
    }

    private void
    update ()
    {
        if (m_PreAux.next == m_Target)
            return;

        unowned AtomicNode<T>? p = m_PreAux;
        AtomicNode<T> n = p.next;
        m_Target = null;

        while (n != m_Last && n.data == null)
        {
            GLib.AtomicPointer.compare_and_exchange (&m_PreCell.next, p, n);
            p.unref ();
            p = n;
            n = p.next;
        }

        m_PreAux = p;
        m_Target = n;
    }
}
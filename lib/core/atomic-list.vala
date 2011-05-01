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
    private AtomicNode<T> m_First;
    private AtomicNode<T> m_Last;

    public AtomicList ()
    {
        m_First = AtomicNode.create (null);
        m_Last = AtomicNode.create (null);
        m_First.next = m_Last;
    }

    public void
    insert (T inData)
    {
        AtomicNode<T> node = AtomicNode.create (inData);
        m_First.next = node;
    }
}
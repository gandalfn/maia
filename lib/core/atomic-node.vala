/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-node.vala
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

internal struct Maia.Atomic.Node<T>
{
    // properties
    public SpinLock                      lck;
    public T                             data;
    public Machine.Memory.Atomic.Pointer next;
}

internal struct Maia.Atomic.NodePool<T>
{
    // properties
    public Node<T>[]                     m_Magazin;
    public Machine.Memory.Atomic.uint    m_Index;
    public Machine.Memory.Atomic.Pointer m_Head;

    // methods
    public inline NodePool (int inReserved = 1024)
    {
        m_Magazin = new Node<T>[inReserved];
        m_Head.set (null);
    }

    public inline void
    clear ()
    {
        unowned Node<T>? node = null;

        do
        {
            node = (Node<T>?)m_Head.get ();
            if (m_Head.compare_and_swap ((void*)node, null))
                break;
        } while (true);
        m_Magazin = null;
    }

    public inline void
    free_node (void* inNode)
    {
        unowned Node<T>? node = null;

        do
        {
            node = (Node<T>?)((Node<T>?)inNode).next.get ();
            ((Node<T>?)inNode).next.compare_and_swap ((void*)node, m_Head.get ());
        } while (!m_Head.compare_and_swap((void*)((Node<T>?)inNode).next.get (), inNode));
    }

    public inline unowned Node<T>?
    alloc_node ()
    {
        unowned Node<T>? node = null;

        do
        {
            node = (Node<T>?)m_Head.get ();
            if (node == null)
            {
                m_Index.inc ();
                assert (m_Index.get () < m_Magazin.length);
                void* ptr = &m_Magazin [m_Index.get ()];
                return (Node<T>?)ptr;
            }
        } while (!m_Head.compare_and_swap((void*)node, node.next.get ()));

        node.next.set (null);

        return node;
    }
}

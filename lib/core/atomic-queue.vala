/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-queue.vala
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

public class Maia.AtomicQueue<V>
{
    // types
    private struct Node<V>
    {
        public Os.Atomic.Pointer m_Next;
        public V                 m_Data;
    }

    private struct FreeList<V>
    {
        private Node<V>* m_pHead;

        public FreeList ()
        {
            m_pHead = GLib.Slice.alloc0 (sizeof (Node<V>));
        }

        public void
        free_node (Node<V>* inpNode)
        {
            inpNode->m_Data = null;
            do
            {
                inpNode->m_Next.set (m_pHead->m_Next.get ());
            } while (!m_pHead->m_Next.compare_and_exchange(inpNode->m_Next.get (), inpNode));
        }

        public Node<V>*
        get_node ()
        {
            Node<V>* pNode = null;

            do
            {
                pNode = m_pHead->m_Next.get ();
                if (pNode == null)
                    return GLib.Slice.alloc0 (sizeof (Node<V>));
            } while (!m_pHead->m_Next.compare_and_exchange(pNode, pNode->m_Next.get ()));

            pNode->m_Next.set (null);

            return pNode;
        }
    }

    // properties
    private FreeList<V>   m_Stack = FreeList<V> ();
    private Node<V>*      m_pHead = null;
    private Node<V>*      m_pTail = null;
    private Os.Atomic.Int m_Length;

    // methods
    public AtomicQueue ()
    {
        m_pHead = m_pTail = m_Stack.get_node ();
    }

    ~AtomicQueue ()
    {
        int length;

        do
        {
            length = m_Length.get ();
        } while (!m_Length.compare_and_exchange (length, -1));

        Node<V>* pLink;

        do
        {
            pLink = m_Stack.m_pHead;
        } while (!Os.Atomic.Pointer.cast (&m_Stack.m_pHead).compare_and_exchange (pLink, null));

        while (pLink != null)
        {
            Node<V>* pNext = pLink->m_Next.get ();
            GLib.Slice.free (sizeof (Node<V>), pLink);
            pLink = pNext;
        }
    }

    public void
    push (V inData)
    {
        Node<V>* pNode = m_Stack.get_node ();
        pNode.m_Data = inData;

        while (!m_Length.compare (-1))
        {
            Node<V>* pLast = m_pTail;
            Node<V>* pNext = pLast->m_Next.get ();

            if (m_pTail == pLast)
            {
                if (pNext == null)
                {
                    if (m_pTail->m_Next.compare_and_exchange (pNext, pNode))
                    {
                        Os.Atomic.Pointer.cast(&m_pTail).compare_and_exchange (pLast, pNode);
                        m_Length.inc ();
                        break;
                    }
                }
            }
            else
            {
                m_pTail->m_Next.compare_and_exchange (pLast, pNext);
            }
        }
    }

    public V?
    pop ()
    {
        V? data = null;

        while (true)
        {
            Node<V>* pFirst = m_pHead;
            Node<V>* pLast = m_pTail;
            Node<V>* pNext = pFirst->m_Next.get ();

            if (pFirst == m_pHead)
            {
                if (pFirst == pLast)
                {
                    if (pNext == null)
                        break;
                    Os.Atomic.Pointer.cast(&m_pTail).compare_and_exchange (pLast, pNext);
                }
                else
                {
                    if (Os.Atomic.Pointer.cast(&m_pHead).compare_and_exchange(pFirst, pNext))
                    {
                        m_Length.dec ();
                        data = pNext->m_Data;
                        m_Stack.free_node (pFirst);
                        break;
                    }
                }
            }
        }

        return data;
    }
}
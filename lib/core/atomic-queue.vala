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
        public Node<V>* m_pNext;
        public V        m_Data;
    }

    private struct FreeList<V>
    {
        private Node<V>* m_pHead;

        public FreeList ()
        {
            m_pHead = GLib.malloc0 (sizeof (Node<V>));
        }

        public void
        free_node (Node<V>* inpNode)
        {
            inpNode->m_Data = null;
            do
            {
                inpNode->m_pNext = m_pHead->m_pNext;
            } while (!GLib.AtomicPointer.compare_and_exchange(&m_pHead->m_pNext, inpNode->m_pNext, inpNode));
        }

        public Node<V>*
        get_node ()
        {
            Node<V>* pNode = null;

            do
            {
                pNode = m_pHead->m_pNext;
                if (pNode == null)
                    return GLib.malloc0 (sizeof (Node<V>));
            } while (!GLib.AtomicPointer.compare_and_exchange(&m_pHead->m_pNext, pNode, pNode->m_pNext));

            pNode->m_pNext = null;

            return pNode;
        }
    }

    // properties
    private FreeList<V> m_Stack = FreeList<V> ();
    private Node<V>*    m_pHead = null;
    private Node<V>*    m_pTail = null;
    private int         m_Length = 0;

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
            length = m_Length;
        } while (!GLib.AtomicInt.compare_and_exchange (ref m_Length, length, -1));

        Node<V>* pLink;

        do
        {
            pLink = m_Stack.m_pHead;
        } while (!GLib.AtomicPointer.compare_and_exchange (&m_Stack.m_pHead, pLink, null));

        while (pLink != null)
        {
            Node<V>* pNext = pLink->m_pNext;
            if (pLink != null) delete pLink;
            pLink = pNext;
        }
    }

    public void
    push (V inData)
    {
        Node<V>* pNode = m_Stack.get_node ();
        pNode.m_Data = inData;

        while (!GLib.AtomicInt.compare_and_exchange (ref m_Length, -1, -1))
        {
            Node<V>* pLast = m_pTail;
            Node<V>* pNext = pLast->m_pNext;

            if (m_pTail == pLast)
            {
                if (pNext == null)
                {
                    if (GLib.AtomicPointer.compare_and_exchange (&m_pTail->m_pNext, pNext, pNode))
                    {
                        GLib.AtomicPointer.compare_and_exchange (&m_pTail, pLast, pNode);
                        GLib.AtomicInt.inc (ref m_Length);
                        break;
                    }
                }
            }
            else
            {
                GLib.AtomicPointer.compare_and_exchange (&m_pTail->m_pNext, pLast, pNext);
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
            Node<V>* pNext = pFirst->m_pNext;

            if (pFirst == m_pHead)
            {
                if (pFirst == pLast)
                {
                    if (pNext == null)
                        break;
                    GLib.AtomicPointer.compare_and_exchange (&m_pTail, pLast, pNext);
                }
                else
                {
                    if (GLib.AtomicPointer.compare_and_exchange(&m_pHead, pFirst, pNext))
                    {
                        GLib.AtomicInt.dec_and_test (ref m_Length);
                        data = (owned)pNext->m_Data;
                        m_Stack.free_node (pFirst);
                        break;
                    }
                }
            }
        }

        return data;
    }
}
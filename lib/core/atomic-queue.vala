/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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

public class Maia.Atomic.Queue<V> : GLib.Object
{
    // types
    public delegate bool ForeachFunc<V> (V? inValue);

    // properties
    private NodePool<V>                   m_Pool= NodePool<V> ();
    private SpinLock                      m_DataLock = SpinLock ();
    private Machine.Memory.Atomic.Pointer m_Head;
    private Machine.Memory.Atomic.Pointer m_Tail;

    // methods
    public Queue ()
    {
        m_Pool = NodePool<V> ();
        m_Head.set ((void*)m_Pool.alloc_node ());
        m_Tail.set (m_Head.get ());
    }

    ~Queue ()
    {
        while (dequeue () != null);
        ((Node<V>?)m_Head.get ()).data = null;
        m_Pool.free_node (m_Head.get ());
        m_Pool.clear ();
    }

    /**
     * Adds an item to the end of the queue.
     *
     * @param inData The data to add.
     */
    public void
    enqueue (owned V inData)
    {
        unowned Node<V>? node = m_Pool.alloc_node ();
        m_DataLock.lock ();
        node.data = inData;
        m_DataLock.unlock ();

        while (true)
        {
            unowned Node<V>? cur_tail = (Node<V>?)m_Tail.get ();
            if (((Node<V>?)m_Tail.get ()).next.compare_and_swap (null, (void*)node))
            {
                m_Tail.compare_and_swap ((void*)cur_tail, (void*)node);
                return;
            }
            else
                m_Tail.compare_and_swap ((void*)cur_tail, (void*)cur_tail.next);
            Machine.CPU.pause ();
        }
    }

    /**
     * Attempts to remove an item from the start of the queue.
     *
     * @return The data dequeued if successful.
     */
    public V?
    dequeue ()
    {
        while (true)
        {
            unowned Node<V>? cur_head = (Node<V>?)m_Head.get ();
            unowned Node<V>? cur_tail = (Node<V>?)m_Tail.get ();
            unowned Node<V>? cur_head_next = (Node<V>?)cur_head.next.get ();
            if ((void*)cur_head == (void*)cur_tail)
            {
                if (cur_head_next == null)
                    return null;
                else
                    m_Tail.compare_and_swap ((void*)cur_tail, (void*)cur_head_next);
            }
            if (m_Head.compare_and_swap ((void*)cur_head, (void*)cur_head_next))
            {
                m_DataLock.lock ();
                V? data = cur_head_next.data;
                cur_head_next.data = null;
                m_DataLock.unlock ();
                m_Pool.free_node ((void*)cur_head);
                return data;
            }
            Machine.CPU.pause ();
        }
    }

    /**
     * Calls inFunc for each element in the queue.
     *
     * @param inFunc the function to call for each element's data
     **/
    public void
    @foreach (ForeachFunc<V> inFunc)
    {
        unowned Node<V>? cursor = null, next = null;
        for (cursor = (Node<V>?)((Node<V>?)m_Head.get ()).next.get (); cursor != null; cursor = next)
        {
            next = (Node<V>?)cursor.next.get ();
            m_DataLock.lock ();
            V? data = cursor.data;
            m_DataLock.unlock ();
            if (!inFunc (data))
                break;
        }
    }
}

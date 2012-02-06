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
    private NodePool<V>      m_Pool= NodePool<V> ();
    private unowned Node<V>? m_Head = null;
    private unowned Node<V>? m_Tail = null;

    // methods
    public Queue ()
    {
        m_Pool = NodePool<V> ();
        m_Head = m_Tail = m_Pool.alloc_node ();
    }

    ~Queue ()
    {
        while (dequeue () != null);
        m_Head.data = null;
        m_Pool.free_node (m_Head);
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
        node.data = inData;

        while (true)
        {
            unowned Node<V>? cur_tail = m_Tail;
            if (Machine.Memory.Atomic.Pointer.cast (&m_Tail.next).compare_and_swap (null, (void*)node))
            {
                Machine.Memory.Atomic.Pointer.cast (&m_Tail).compare_and_swap ((void*)cur_tail, (void*)node);
                return;
            }
            else
                Machine.Memory.Atomic.Pointer.cast (&m_Tail).compare_and_swap ((void*)cur_tail, (void*)cur_tail.next);
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
            unowned Node<V>? cur_head = m_Head;
            unowned Node<V>? cur_tail = m_Tail;
            unowned Node<V>? cur_head_next = cur_head.next;
            if ((void*)cur_head == (void*)cur_tail)
            {
                if (cur_head_next == null)
                    return null;
                else
                    Machine.Memory.Atomic.Pointer.cast (&m_Tail).compare_and_swap ((void*)cur_tail, (void*)cur_head_next);
            }
            if (Machine.Memory.Atomic.Pointer.cast (&m_Head).compare_and_swap ((void*)cur_head, (void*)cur_head_next))
            {
                V? data = cur_head_next.data;
                cur_head_next.data = null;
                m_Pool.free_node (cur_head);
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
        for (cursor = m_Head.next; cursor != null; cursor = next)
        {
            V? data = cursor.data;
            if (!inFunc (data))
                break;
            next = cursor.next;
        }
    }
}

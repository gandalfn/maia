/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-stack.vala
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

public class Maia.Atomic.Stack<V> : GLib.Object
{
    // types
    public delegate bool ForeachFunc<V> (V? inValue);

    // properties
    private NodePool<V>      m_Pool= NodePool<V> ();
    private unowned Node<V>? m_Head = null;

    // accessors
    public bool is_empty {
        get {
            return m_Head.next == null;
        }
    }

    // methods
    public Stack ()
    {
        m_Head = m_Pool.alloc_node ();
    }

    ~Stack ()
    {
        while (pop () != null);
        m_Head.data = null;
        m_Pool.free_node (m_Head);
        m_Pool.clear ();
    }

    /**
     * Adds an item to the top of the stack.
     *
     * @param inValue The value to add.
     */
    public void
    push (owned V inValue)
    {
        unowned Node<V>? node = m_Pool.alloc_node ();
        node.data = inValue;
        unowned Node<V>? next = node.next = m_Head.next;
        BackOff bo = BackOff ();

        while (true)
        {
            void* old_next;
            if (Machine.Memory.Atomic.Pointer.cast (&m_Head.next).compare_and_swap_value ((void*)next, (void*)node, out old_next))
                break;
            next = node.next = (Node<V>?)old_next;
            bo.exponential_block ();
        }
    }

    /**
     * Attempts to pop a value from the top of the stack.
     *
     * @return The item removed from the stack.
     */
    public V?
    pop ()
    {
        BackOff bo = BackOff ();

        while (true)
        {
            unowned Node<V>? node = m_Head.next;
            if (node == null)
                return null;

            unowned Node<V>? next = node.next;
            if (Machine.Memory.Atomic.Pointer.cast (&m_Head.next).compare_and_swap ((void*)node, (void*)next))
            {
                V? data = node.data;
                node.data = null;
                m_Pool.free_node (node);
                return data;
            }
            bo.exponential_block ();
        }
    }

    /**
     * Attempts to peek a value from the top of the stack.
     *
     * @return The top item of the stack.
     */
    public V?
    peek ()
    {
        unowned Node<V>? node = m_Head.next;
        if (node != null)
            return node.data;

        return null;
    }

    /**
     * Calls inFunc for each element in the stack.
     *
     * @param inFunc the function to call for each element's data
     **/
    public void
    @foreach (ForeachFunc<V> inFunc)
    {
        unowned Node<V>? cursor = null, next = null;
        for (cursor = m_Head.next; cursor != null; cursor = next)
        {
            if (!inFunc (cursor.data))
                break;
            next = cursor.next;
        }
    }
}

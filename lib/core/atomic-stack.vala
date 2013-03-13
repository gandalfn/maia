/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-stack.vala
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

public class Maia.Atomic.Stack<V> : GLib.Object
{
    // types
    public delegate bool ForeachFunc<V> (V? inValue);

    // properties
    private NodePool<V>                   m_Pool= NodePool<V> ();
    private Machine.Memory.Atomic.Pointer m_Head;

    // accessors
    public bool is_empty {
        get {
            return ((Node<V>?)m_Head.get ()).next.get () == null;
        }
    }

    // methods
    public Stack ()
    {
        m_Head.set ((void*)m_Pool.alloc_node ());
    }

    ~Stack ()
    {
        while (pop () != null);
        ((Node<V>?)m_Head.get ()).data = null;
        m_Pool.free_node (m_Head.get ());
        m_Pool.clear ();
    }

    /**
     * Adds an item to the top of the stack.
     *
     * @param inValue The value to add.
     */
    public void
    push (V inValue)
    {
        unowned Node<V>? node = m_Pool.alloc_node ();
        node.lck.lock ();
        node.data = inValue;
        node.lck.unlock ();
        node.next.set (((Node<V>?)m_Head.get ()).next.get ());
        unowned Node<V>? next = (Node<V>?)node.next.get ();

        while (true)
        {
            void* old_next;
            if ((((Node<V>?)m_Head.get ()).next).compare_and_swap_value ((void*)next, (void*)node, out old_next))
                break;
            node.next.set (old_next);
            next = (Node<V>?)old_next;
            Machine.CPU.pause ();
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
        while (true)
        {
            unowned Node<V>? node = (Node<V>?)((Node<V>?)m_Head.get ()).next.get ();
            if (node == null)
                return null;

            unowned Node<V>? next = (Node<V>?)node.next.get ();
            if (((Node<V>?)m_Head.get ()).next.compare_and_swap ((void*)node, (void*)next))
            {
                node.lck.lock ();
                V? data = node.data;
                node.data = null;
                node.lck.unlock ();
                m_Pool.free_node ((void*)node);
                return data;
            }
            Machine.CPU.pause ();
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
        unowned Node<V>? node = (Node<V>?)((Node<V>?)m_Head.get ()).next.get ();
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
        for (cursor = (Node<V>?)((Node<V>?)m_Head.get ()).next.get (); cursor != null; cursor = next)
        {
            if (!inFunc (cursor.data))
                break;
            next = (Node<V>?)cursor.next.get ();
        }
    }
}

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

public class Maia.Atomic.List<V> : GLib.Object
{
    // types
    public delegate bool ForeachFunc<V> (V? inValue);

    [SimpleType]
    [IntegerType (rank = 9)]
    [CCode (cname = "gpointer", default_value = "0UL", has_type_id = "false", has_copy_function = "false", has_destroy_function = "")]
    private struct Pointer : ulong
    {
        public static inline Pointer
        cast (Node<V>? inPtr)
        {
            return (ulong)(void*)inPtr;
        }

        public inline bool
        is_marked_reference ()
        {
            ulong v = (ulong)this;
            return (v % 2) == 1;
        }

        public inline void*
        get_marked_reference ()
        {
            ulong v = (ulong)this;
            return (void*)(v | 1);
        }

        public inline void*
        get_unmarked_reference ()
        {
            ulong v = (ulong)this;
            return (void*)(v & -2);
        }
    }

    // properties
    private Machine.Memory.Atomic.uint8 m_Alive;
    private NodePool<V>                 m_Pool = NodePool<V> ();
    private unowned Node<V>?            m_Head = null;
    private unowned Node<V>?            m_Tail = null;
    private CompareFunc<V>              m_CompareFunc;

    // accessors
    public CompareFunc<V> compare_func {
        get {
            return m_CompareFunc;
        }
        set {
            m_CompareFunc = value;
        }
    }

    public bool is_empty {
        get {
            return (void*)m_Head.next == (void*)m_Tail;
        }
    }

    // methods
    public List ()
    {
        m_Alive.inc ();
        m_CompareFunc = get_compare_func_for<V> ();
        m_Head = m_Pool.alloc_node ();
        m_Tail = m_Pool.alloc_node ();
        m_Head.next = m_Tail;
    }

    ~List ()
    {
        m_Alive.dec ();

        this.foreach ((v) => {
            remove (v);
            return true;
        });

        m_Head.data = null;
        m_Pool.free_node (m_Head);

        m_Tail.data = null;
        m_Pool.free_node (m_Tail);

        m_Pool.clear ();
    }

    private unowned Node<V>?
    get_node (ref unowned Node<V>? outLeft, V inData)
    {
        unowned Node<V>? left_node_next = null, right_node = null;

        while (m_Alive.get () > 0)
        {
            unowned Node<V>? t = m_Head;
            unowned Node<V>? t_next = m_Head.next;

            do
            {
                if (!Pointer.cast (t_next).is_marked_reference())
                {
                    outLeft = t;
                    left_node_next = t_next;
                }
                t = (Node<V>?)Pointer.cast (t_next).get_unmarked_reference();

                if ((void*)t == (void*)m_Tail)
                    break;

                t_next = t.next;
            } while (Pointer.cast (t_next).is_marked_reference() || m_CompareFunc (t.data, inData) < 0);

            right_node = t;

            if ((void*)left_node_next == (void*)right_node)
            {
                if (((void*)right_node != (void*)m_Tail) && Pointer.cast (right_node.next).is_marked_reference ())
                    continue;
                else
                    return right_node;
            }

            if (Machine.Memory.Atomic.Pointer.cast (&outLeft.next).compare_and_swap ((void*)left_node_next, (void*)right_node))
            {
                left_node_next.data = null;
                m_Pool.free_node (left_node_next);

                if (((void*)right_node != (void*)m_Tail) && Pointer.cast (right_node.next).is_marked_reference())
                    continue;
                else
                    return right_node;
            }
        }

        return null;
    }

    /**
     * Determines whether this list contains the specified value.
     *
     * @param inValue the value to locate in the list
     *
     * @return true if value is found, false otherwise
     */
    public bool
    contains (V inData)
    {
        unowned Node<V>? left_node = null;
        unowned Node<V>? right_node = get_node (ref left_node, inData);

        return (void*)right_node != (void*)m_Tail && m_CompareFunc (right_node.data, inData) == 0;
    }

    /**
     * Insert a value to this list.
     *
     * @param inValue the value to add to the list
     *
     * @return true if value is added to the list, false otherwise
     */
    public bool
    insert (owned V inData)
    {
        unowned Node<V>? node = m_Pool.alloc_node ();
        node.data = inData;

        unowned Node<V>? left_node = null, right_node = null;
        while (m_Alive.get () > 0)
        {
            right_node = get_node (ref left_node, inData);
            if ((void*)right_node != (void*)m_Tail && m_CompareFunc (node.data, inData) == 0)
            {
                node.data = null;
                m_Pool.free_node (node);
                return false;
            }
            node.next = right_node;
            if (Machine.Memory.Atomic.Pointer.cast (&left_node.next).compare_and_swap ((void*)right_node, (void*)node))
                return true;
        }

        return false
        ;
    }

    /**
     * Removes the first occurence of a value from this list.
     *
     * @param inValue the value to remove from the list
     *
     * @return true if value is added from this list, false otherwise
     */
    public bool
    remove (V inData)
    {
        unowned Node<V>? right_node = null, right_node_next = null, left_node = null;

        while (m_Alive.get () > 0)
        {
            right_node = get_node (ref left_node, inData);
            if ((void*)right_node == (void*)m_Tail || m_CompareFunc (right_node.data, inData) != 0)
                return false;

            right_node_next = right_node.next;
            if (!Pointer.cast (right_node_next).is_marked_reference())
            {
                if (Machine.Memory.Atomic.Pointer.cast (&right_node.next).compare_and_swap ((void*)right_node_next, Pointer.cast (right_node_next).get_marked_reference()))
                    break;
            }
        }

        if (!Machine.Memory.Atomic.Pointer.cast (&left_node.next).compare_and_swap ((void*)right_node, (void*)right_node_next))
        {
            right_node = get_node (ref left_node, right_node.data);
        }
        else
        {
            right_node.data = null;
            m_Pool.free_node (right_node);
        }

        return true;
    }

    /**
     * Calls inFunc for each element in the list.
     *
     * @param inFunc the function to call for each element's data
     **/
    public void
    @foreach (ForeachFunc<V> inFunc)
    {
        unowned Node<V>? t;
        unowned Node<V>? t_next = m_Head.next;

        while (m_Alive.get () > 0)
        {
            t = (Node<V>?)Pointer.cast (t_next).get_unmarked_reference();
            if ((void*)t == (void*)m_Tail)
                return;

            if (!Pointer.cast (t_next).is_marked_reference())
            {
                V? data = t.data;
                if (!inFunc (data))
                    return;
            }
            t_next = t.next;
        }
    }
}

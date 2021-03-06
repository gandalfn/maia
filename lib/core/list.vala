/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * list.vala
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

public class Maia.Core.List<V> : Collection<V>
{
    // Types
    private class Node<V>
    {
        public V m_Value;
        public unowned Node<V>? m_Prev = null;
        public Node<V>? m_Next = null;

        public Node (owned V inValue)
        {
            m_Value = inValue;
        }
    }

    private class Iterator<V> : Maia.Core.Iterator<V>
    {
        private bool m_Started = false;
        private List<V> m_List;
        private unowned Node<V>? m_Current;

        public unowned Node<V>? current {
            get {
                return m_Current;
            }
        }

        internal Iterator (List<V> inList, Node<V>? inNode = null)
        {
            m_List = inList;
            m_Current = inNode;
            stamp = m_List.stamp;
        }

        /**
         * {@inheritDoc}
         */
        internal override bool
        next ()
            requires (m_List.stamp == stamp)
        {
            bool ret = false;

            if (!m_Started && m_List.m_Head != null)
            {
                m_Started = true;
                m_Current = m_List.m_Head;
                ret = true;
            }
            else if (m_Current != null && m_Current.m_Next != null)
            {
                m_Current = m_Current.m_Next;
                ret = true;
            }

            return ret;
        }

        /**
         * {@inheritDoc}
         */
        internal override bool
        prev ()
            requires (m_List.stamp == stamp)
        {
            bool ret = false;

            if (m_Current != null && m_Current.m_Prev != null)
            {
                m_Started = true;
                m_Current = m_Current.m_Prev;
                ret = true;
            }

            return ret;
        }

        /**
         * {@inheritDoc}
         */
        internal override unowned V?
        get ()
            requires (m_List.stamp == stamp)
        {
            return m_Current == null ? null : m_Current.m_Value;
        }

        /**
         * {@inheritDoc}
         */
        internal override void
        @foreach (ForeachFunc<V> inFunc)
        {
            if (!m_Started && m_List.m_Head != null)
            {
                m_Started = true;
                m_Current = m_List.m_Head;
            }

            for (;m_Started && m_Current != null; m_Current = m_Current.m_Next)
            {
                if (!inFunc (m_Current.m_Value))
                    return;
            }
        }
    }

    // Properties
    private bool             m_Sorted = false;
    private int              m_Size = 0;
    private Node<V>?         m_Head = null;
    private unowned Node<V>? m_Tail = null;

    /**
     * {@inheritDoc}
     */
    internal override int length {
        get {
            return m_Size;
        }
    }

    public List ()
    {
    }

    public List.sorted ()
    {
        m_Sorted = true;
    }

    private unowned Node<V>?
    get_node (V inValue)
    {
        unowned Node<V>? ret = null;

        // Search task node in queue
        for (unowned Node<V> node = m_Head; ret == null && node != null; node = node.m_Next)
        {
            if (compare_func (node.m_Value, inValue) == 0)
            {
                ret = node;
            }
        }

        return ret;
    }

    private void
    remove_node (Node<V> inNode)
    {
        Node<V> n;
        unowned Node<V> next;

        if (inNode == m_Head)
        {
            n = (owned)m_Head;
            next = m_Head = (owned) n.m_Next;
        }
        else
        {
            n = (owned)inNode.m_Prev.m_Next;
            next = n.m_Prev.m_Next = (owned)n.m_Next;
        }

        if (n == m_Tail)
        {
            m_Tail = n.m_Prev;
        }
        else
        {
            next.m_Prev = n.m_Prev;
        }

        n.m_Prev = null;
        n.m_Next = null;
        n.m_Value = null;
        m_Size--;
        stamp++;
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    contains (V inValue)
    {
        return m_Size > 0 && get_node (inValue) != null;
    }

    /**
     * Search if the specified is in this set.
     *
     * @param inValue the value to locate in the set
     * @param inFunc custom compare function
     *
     * @return value found or null otherwise
     */
    public inline unowned V?
    search<A> (A inValue, ValueCompareFunc<V, A> inFunc)
    {
        unowned V? ret = null;

        // Search task node in queue
        for (unowned Node<V> node = m_Head; ret == null && node != null; node = node.m_Next)
        {
            if (inFunc (node.m_Value, inValue) == 0)
            {
                ret = node.m_Value;
            }
        }

        return ret;
    }

    /**
     * {@inheritDoc}
     */
    internal override Maia.Core.Iterator<V>
    insert (V inValue)
    {
        Iterator<V> iter;

        // Create new node
        Node<V> new_node = new Node<V> (inValue);

        // List is empty
        if (m_Head == null && m_Tail == null)
        {
            m_Tail = new_node;
            m_Head = (owned)new_node;
            iter = new Iterator<V> (this, new_node);
        }
        // Insert at end of list
        else if (!m_Sorted)
        {
            new_node.m_Prev = m_Tail;
            m_Tail = new_node;
            m_Tail.m_Prev.m_Next = (owned)new_node;
            iter = new Iterator<V> (this, new_node);
        }
        else
        {
            unowned Node<V>? found = null;
            CompareFunc<V> func = compare_func;

            // Search node position
            for (unowned Node<V> node = m_Tail; node != null; node = node.m_Prev)
            {
                if (func (new_node.m_Value, node.m_Value) >= 0)
                {
                    found = node;
                    break;
                }
            }
            // Insert node after found
            if (found != null)
            {
                if (found == m_Tail) m_Tail = new_node;
                new_node.m_Prev = found;
                new_node.m_Next = (owned)found.m_Next;
                if (new_node.m_Next !=null) new_node.m_Next.m_Prev = new_node;
                found.m_Next = (owned)new_node;
            }
            // Insert node on head of queue
            else
            {
                new_node.m_Next = (owned)m_Head;
                new_node.m_Next.m_Prev = new_node;
                m_Head = (owned)new_node;
            }

            iter = new Iterator<V> (this, new_node);
        }

        m_Size++;

        stamp++;

        return iter;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    remove (V inValue)
        requires (m_Size > 0)
    {
        unowned Node<V>? node = get_node (inValue);

        if (node != null) remove_node (node);
    }

    public void
    check ()
    {
        if (m_Sorted)
        {
            CompareFunc<V> func = compare_func;

            // Check each node in queue
            for (unowned Node<V> node = m_Head; node != null && node.m_Next != null; node = node.m_Next)
            {
                if (func (node.m_Value, node.m_Next.m_Value) > 0)
                {
                    // swap node data
                    V swap = node.m_Value;
                    node.m_Value = node.m_Next.m_Value;
                    node.m_Next.m_Value = swap;
                }
            }
        }
    }

    /**
     * Returns the iterator of the specified value in this list.
     *
     * @param inValue the value whose iterator is to be retrieved
     *
     * @return the iterator associated with the value, or null if the value
     *         couldn't be found
     */
    public Maia.Core.Iterator<V>?
    @get (V inValue)
    {
        unowned Node<V> node = get_node (inValue);
        Maia.Core.Iterator<V> iterator = null;

        if (node != null)
        {
            iterator = new Iterator<V> (this, node);
        }

        return iterator;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    clear ()
    {
        while (m_Head != null)
            remove_node (m_Head);
        this.m_Head = null;
        this.m_Tail = null;
        this.m_Size = 0;
    }

    /**
     * Get the first element of the list
     *
     * @return the first of element of the list
     */
    public unowned V?
    first ()
    {
        return m_Size > 0 ? m_Head.m_Value : null;
    }

    /**
     * Get the last element of the list
     *
     * @return the last of element of the list
     */
    public unowned V?
    last ()
    {
        return m_Size > 0 ? m_Tail.m_Value : null;
    }

    /**
     * {@inheritDoc}
     */
    internal override Maia.Core.Iterator<V>
    iterator ()
    {
        return new Iterator<V> (this);
    }

    /**
     * Returns the last Iterator that can be used for simple iteration over a
     * collection.
     *
     * @return a Iterator that can be used for simple iteration over a
     *         collection
     */
    public Maia.Core.Iterator<V>
    end ()
    {
        return new Iterator<V> (this, m_Tail);
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    erase (Maia.Core.Iterator<V> inIterator)
        requires (inIterator.stamp == stamp)
    {
        Iterator<V> iter = inIterator as Iterator<V>;

        remove_node (iter.current);
   }
}

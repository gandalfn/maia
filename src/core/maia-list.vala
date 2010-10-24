/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-list.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.List<T> : Vala.Collection<T>
{
    // Properties
    private int              m_Size = 0;
    private Node<T>?         m_Head = null;
    private unowned Node<T>? m_Tail = null;
    private GLib.CompareFunc m_CompareFunc = null;

    /**
     * {@inheritDoc}
     */
    public override int size {
        get {
            return m_Size;
        }
    }

    /**
     * The elements compare testing function.
     */
    public GLib.CompareFunc compare_func {
        get {
            return m_CompareFunc;
        }
    }

    public class List (GLib.CompareFunc? inFunc = null)
    {
        m_CompareFunc = inFunc;
    }

    private unowned Node<T>?
    get_node (T inData)
    {
        unowned Node<T>? ret = null;

        // Search task node in queue
        for (unowned Node<T> node = m_Head; node != null && ret == null; node = node.m_Next)
        {
            if (m_CompareFunc != null && m_CompareFunc (node.m_Data, inData) == 0)
            {
                ret = node;
            }
            else if (m_CompareFunc == null && node.m_Data == inData)
            {
                ret = node;
            }
        }

        return ret;
    }

    private void
    remove_node (Node<T> inNode)
    {
        Node<T> n;
        unowned Node<T> next;

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
        n.m_Data = null;
        m_Size--;
    }

    /**
     * {@inheritDoc}
     */
    public override Type
    get_element_type ()
    {
        return typeof (T);
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    contains (T inData)
        requires (m_Size > 0)
    {
        return get_node (inData) != null;
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    add (T inData)
    {
        // Create new node
        Node<T> new_node = new Node<T> (inData);

        // List is empty
        if (m_Head == null && m_Tail == null)
        {
            m_Tail = new_node;
            m_Head = (owned)new_node;
        }
        // Insert at end of list
        else if (m_CompareFunc == null)
        {
            new_node.m_Prev = m_Tail;
            m_Tail.m_Next = (owned)new_node;
            m_Tail = new_node;
        }
        else
        {
            unowned Node<T>? found = null;

            // Search node position
            for (unowned Node<T> node = m_Tail; node != null; node = node.m_Prev)
            {
                if (m_CompareFunc (new_node.m_Data, node.m_Data) >= 0)
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
        }

        m_Size++;

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    remove (T inData)
        requires (m_Size > 0)
    {
        bool ret = false;
        unowned Node<T>? node = get_node (inData);

        if (node != null)
        {
            remove_node (node);
            ret = true;
        }

        return ret;
    }

    public void
    check ()
    {
        if (m_CompareFunc != null)
        {
            // Check each node in queue
            for (unowned Node<T> node = m_Head; node != null && node.m_Next != null; node = node.m_Next)
            {
                if (m_CompareFunc (node.m_Data, node.m_Next.m_Data) > 0)
                {
                    // swap node data
                    T swap = node.m_Data;
                    node.m_Data = node.m_Next.m_Data;
                    node.m_Next.m_Data = swap;
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void
    clear ()
    {
        this.m_Head = null;
        this.m_Tail = null;
        this.m_Size = 0;
    }

    public T
    first ()
        requires (m_Size > 0)
    {
        return m_Head.m_Data;
    }

    public T
    last ()
        requires (m_Size > 0)
    {
        return m_Tail.m_Data;
    }

    /**
     * {@inheritDoc}
     */
    public override Vala.Iterator<T>
    iterator ()
        requires (m_Size > 0)
    {
        return new Iterator<T> (this);
    }

    [Compact]
    private class Node<T>
    {
        public T m_Data;
        public unowned Node<T>? m_Prev = null;
        public Node<T>? m_Next = null;

        public Node (owned T inData) 
        {
            m_Data = inData;
        }
    }

    private class Iterator<T> : Vala.Iterator<T>
    {
        private bool m_Started = false;
        private unowned Node<T>? m_Current;
        private List<T> m_List;

        internal Iterator (List<T> inList)
        {
            m_List = inList;
            m_Current = null;
        }

        /**
         * {@inheritDoc}
         */
        public override bool
        next ()
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
        public override T?
        get ()
            requires (m_Current != null)
        {
            return m_Current.m_Data;
        }
    }
}
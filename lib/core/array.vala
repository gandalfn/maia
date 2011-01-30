/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * array.vala
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

public class Maia.Array <V> : Collection <V>
{
    // Types
    private struct Node<V>
    {
        public V val;
    }

    private class Iterator<V> : Maia.Iterator<V>
    {
        private Array<V> m_Array;
        private int m_Index;

        public int index {
            get {
                return m_Index;
            }
        }

        public Iterator (Array<V> inArray, int inIndex = -1)
        {
            m_Array = inArray;
            m_Index = inIndex;
            stamp = m_Array.stamp;
        }

        public override bool
        next ()
            requires (m_Array.stamp == stamp)
        {
            bool ret = false;

            if (m_Index == -1 && m_Array.m_Size > 0)
            {
                m_Index = 0;
                ret = true;
            }
            else if (m_Index < m_Array.m_Size)
            {
                m_Index++;
                ret = m_Index < m_Array.m_Size;
            }

            return ret;
        }

        public override unowned V?
        get ()
            requires (m_Array.stamp == stamp)
            requires (m_Index >= 0)
            requires (m_Index < m_Array.m_Size)
        {
            return m_Array.m_pContent[m_Index].val;
        }
    }

    // Properties
    private bool     m_Sorted = false;
    private int      m_Size = 0;
    private int      m_ReservedSize = 4;
    private Node<V>* m_pContent;

    // Accessors
    public override int nb_items {
        get {
            return m_Size;
        }
    }

    // Methods
    public Array ()
    {
        m_pContent = new Node<V> [m_ReservedSize];
    }

    public Array.sorted ()
    {
        this ();
        m_Sorted = true;
    }

    ~Array ()
    {
        clear ();

        if (m_pContent != null)
            delete m_pContent;

        m_pContent = null;
    }

    private int
    get_nearest_pos (V inValue)
    {
        int ret = m_Size;
        int left = 0, right = m_Size - 1;

        if (right != -1)
        {
            while (right >= left)
            {
                int medium = (left + right) / 2;
                int res = compare_func (m_pContent[medium].val, inValue);

                if (res == 0)
                {
                    while (medium < m_Size && compare_func (m_pContent[medium].val, inValue) == 0)
                        medium++;
                    return medium;
                }
                else if (res > 0)
                {
                    right = medium - 1;
                }
                else
                {
                    left = medium + 1;
                }

                ret = (int)Posix.ceil((double)(left + right) / 2);
            }
        }

        return ret;
    }

    private void
    grow ()
    {
        if (m_Size > m_ReservedSize)
        {
            int oldReservedSize = m_ReservedSize;
            m_ReservedSize = 2 * m_ReservedSize;
            m_pContent = GLib.realloc (m_pContent, m_ReservedSize * sizeof (Node<V>));
            GLib.Memory.set (&m_pContent[oldReservedSize], 0, oldReservedSize * sizeof (Node<V>));
        }
    }

    private Iterator<V>?
    get_iterator (V? inValue)
    {
        Iterator<V>? iterator = null;

        if (!m_Sorted)
        {
            for (int cpt = 0; iterator == null && cpt < m_Size; ++cpt)
            {
                if (compare_func (m_pContent[cpt].val, inValue) == 0)
                    iterator = new Iterator<V> (this, cpt);
            }
        }
        else
        {
            int left = 0, right = m_Size - 1;

            if (right != -1)
            {
                while (iterator == null && right >= left)
                {
                    int medium = (left + right) / 2;
                    int res = compare_func (m_pContent[medium].val, inValue);

                    if (res == 0)
                    {
                        iterator = new Iterator<V> (this, medium);
                    }
                    else if (res > 0)
                    {
                        right = medium - 1;
                    }
                    else
                    {
                        left = medium + 1;
                    }
                }
            }
        }

        return iterator;
    }

    /**
     * Reserve the size of array
     *
     * @param inSize the reserved size
     */
    public void
    reserve (int inSize)
    {
        if (inSize > m_ReservedSize)
        {
            int oldReservedSize = m_ReservedSize;
            m_ReservedSize = inSize;
            m_pContent = GLib.realloc (m_pContent, m_ReservedSize * sizeof (Node<V>));
            GLib.Memory.set (&m_pContent[oldReservedSize], 0, (m_ReservedSize - oldReservedSize) * sizeof (Node<V>));
        }
    }

    /**
     * Check if an iterator of array is correctly sorted
     *
     * @param inIterator array iterator
     */
    public void
    check (Maia.Iterator<V> inIterator)
        requires (inIterator is Iterator<V>)
        requires (inIterator.stamp == stamp)
    {
        if (m_Sorted)
        {
            Iterator<V> iter = inIterator as Iterator<V>;
            int pos = get_nearest_pos (inIterator.get ());

            if (pos < iter.index)
            {
                V val = m_pContent[iter.index].val;
                GLib.Memory.move (&m_pContent[pos + 1], &m_pContent[pos],
                                  (iter.index - pos - 1) * sizeof (Node<V>));
                m_pContent[pos].val = val;
            }
            else if (pos > iter.index)
            {
                V val = m_pContent[iter.index].val;
                GLib.Memory.move (&m_pContent[iter.index], &m_pContent[iter.index + 1],
                                  (pos - iter.index - 1) * sizeof (Node<V>));
                m_pContent[pos].val = val;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    contains (V inValue)
    {
        return get_iterator (inValue) != null;
    }

    /**
     * {@inheritDoc}
     */
    public override unowned V?
    search<A> (A inValue, ValueCompareFunc<V, A> inFunc)
    {
        unowned V? ret = null;

        if (!m_Sorted)
        {
            for (int cpt = 0; ret == null && cpt < m_Size; ++cpt)
            {
                if (inFunc (m_pContent[cpt].val, inValue) == 0)
                    ret = m_pContent[cpt].val;
            }
        }
        else
        {
            int left = 0, right = m_Size - 1;

            if (right != -1)
            {
                while (ret == null && right >= left)
                {
                    int medium = (left + right) / 2;
                    int res = inFunc (m_pContent[medium].val, inValue);

                    if (res == 0)
                    {
                        ret = m_pContent[medium].val;
                    }
                    else if (res > 0)
                    {
                        right = medium - 1;
                    }
                    else
                    {
                        left = medium + 1;
                    }
                }
            }
        }

        return ret;
    }

    /**
     * {@inheritDoc}
     */
    public override void
    insert (V inValue)
    {
        if (m_Sorted)
        {
            int pos = get_nearest_pos (inValue);

            m_Size++;
            grow ();

            if (pos < m_Size - 1)
            {
                GLib.Memory.move (&m_pContent[pos + 1], &m_pContent[pos],
                                  (m_Size - pos - 1) * sizeof (Node<V>));
                GLib.Memory.set (&m_pContent[pos], 0, sizeof (Node<V>));
            }

            m_pContent[pos].val = inValue;

            stamp++;
        }
        else
        {
            m_Size++;
            grow ();

            m_pContent[m_Size - 1].val = inValue;

            stamp++;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void
    remove (V inValue)
    {
        Iterator<V>? iterator = get_iterator (inValue);
        if (iterator != null)
        {
            erase (iterator);
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void
    clear ()
    {
        if (m_pContent != null)
        {
            for (int cpt = 0; cpt < m_Size; ++cpt)
                m_pContent[cpt].val = null;

            delete m_pContent;
            m_ReservedSize = 4;
            m_Size = 0;
            m_pContent = new Node<V>[m_ReservedSize];
            stamp++;
        }
    }

    /**
     * Returns the iterator of the specified value in this array.
     *
     * @param inValue the value whose iterator is to be retrieved
     *
     * @return the iterator associated with the value, or null if the value
     *         couldn't be found
     */
    public Maia.Iterator<V>?
    get (V inValue)
    {
        return get_iterator (inValue);
    }

    /**
     * Returns the value at the specified index in this collection.
     *
     * @param inIndex zero-based index of the value to be returned
     *
     * @return the value at the specified index in the collection
     */
    public unowned V?
    at (int inIndex)
    {
        unowned V? ret = null;

        if (m_Size > 0 && inIndex >= 0 && inIndex < m_Size)
        {
            ret = m_pContent[inIndex].val;
        }

        return ret;
    }

    /**
     * {@inheritDoc}
     */
    public override Maia.Iterator<V>
    iterator ()
    {
        return new Iterator<V> (this);
    }

    /**
     * {@inheritDoc}
     */
    public override void
    erase (Maia.Iterator<V> inIterator)
        requires (inIterator is Iterator<V>)
        requires (inIterator.stamp == stamp)
    {
        Iterator<V> iter = inIterator as Iterator<V>;

        m_Size--;

        int index = iter.index;

        if (index != m_Size)
            GLib.Memory.move (&m_pContent[index], &m_pContent[index + 1],
                              (m_Size - index) * sizeof (V));

        m_pContent[m_Size].val = null;

        stamp++;
    }
}
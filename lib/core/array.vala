/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * array.vala
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

public class Maia.Core.Array <V> : Collection <V>
{
    // Types
    private struct Node<V>
    {
        public V val;
    }

    private class Iterator<V> : Maia.Core.Iterator<V>
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

        /**
         * {@inheritDoc}
         */
        internal override bool
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

        /**
         * {@inheritDoc}
         */
        internal override unowned V?
        get ()
            requires (m_Array.stamp == stamp)
            requires (m_Index >= 0)
            requires (m_Index < m_Array.m_Size)
        {
            return m_Array.m_pContent[m_Index].val;
        }

        /**
         * {@inheritDoc}
         */
        internal override void
        @foreach (ForeachFunc<V> inFunc)
        {
            if (m_Index == -1 && m_Array.m_Size > 0)
            {
                m_Index = 0;
            }
            for (; m_Index >= 0 && m_Index < m_Array.m_Size; ++m_Index)
            {
                if (!inFunc (m_Array.m_pContent[m_Index].val))
                {
                    return;
                }
            }
        }
    }

    // Properties
    private bool     m_Sorted = false;
    private int      m_Size = 0;
    private int      m_ReservedSize = 4;
    private Node<V>* m_pContent;

    // Accessors
    internal override int length {
        get {
            return m_Size;
        }
    }

    internal bool is_sorted {
        set {
            m_Sorted = value;
        }
    }

    // Methods
    // TODO: It is very stable ? I doubt it though even if the unit test pass.
    //       I must check much more this class.
    public Array ()
    {
        m_pContent = GLib.Slice.alloc0 (m_ReservedSize * sizeof (Node<V>));
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
            GLib.Slice.free (m_ReservedSize * sizeof (Node<V>), m_pContent);

        m_pContent = null;
    }

    private int
    get_nearest_pos (V inValue)
    {
        int ret = m_Size;
        int left = 0, right = m_Size - 1;

        if (right != -1)
        {
            CompareFunc<V> func = compare_func;

            while (right >= left)
            {
                int medium = (int)(((uint)left + (uint)right) >> 1);
                int res = func (m_pContent[medium].val, inValue);

                if (res == 0)
                {
                    while (medium < m_Size && func (m_pContent[medium].val, inValue) == 0)
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

                ret = (int)GLib.Math.ceil((double)(left + right) / 2);
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
            void* o = (void*)m_pContent;
            m_pContent = GLib.Slice.alloc0 (m_ReservedSize * sizeof (Node<V>));
            GLib.Memory.copy (m_pContent, o, oldReservedSize * sizeof (Node<V>));
            GLib.Slice.free (oldReservedSize * sizeof (Node<V>), o);
        }
    }

    private void
    reduce ()
    {
        if (m_Size < (int)(m_ReservedSize / 2.5))
        {
            int oldReservedSize = m_ReservedSize;
            m_ReservedSize = (int)(m_ReservedSize / 2.5);
            void* o = (void*)m_pContent;
            m_pContent = GLib.Slice.copy (m_ReservedSize * sizeof (Node<V>), o);
            GLib.Slice.free (oldReservedSize * sizeof (Node<V>), o);
        }
    }

    private Iterator<V>?
    get_iterator (V? inValue)
    {
        Iterator<V>? iterator = null;

        if (!m_Sorted)
        {
            CompareFunc<V> func = compare_func;

            for (int cpt = 0; iterator == null && cpt < m_Size; ++cpt)
            {
                if (func (m_pContent[cpt].val, inValue) == 0)
                    iterator = new Iterator<V> (this, cpt);
            }
        }
        else
        {
            int left = 0, right = m_Size - 1;

            if (right != -1)
            {
                CompareFunc<V> func = compare_func;

                while (iterator == null && right >= left)
                {
                    int medium = (int)(((uint)left + (uint)right) >> 1);
                    int res = func (m_pContent[medium].val, inValue);

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
            void* o = (void*)m_pContent;
            m_pContent = GLib.Slice.alloc0 (m_ReservedSize * sizeof (Node<V>));
            GLib.Memory.copy (m_pContent, o, oldReservedSize * sizeof (Node<V>));
            GLib.Slice.free (oldReservedSize * sizeof (Node<V>), o);
        }
    }

    /**
     * Check if the element at pos of array is correctly sorted
     *
     * @param inPos pos of element
     */
    public void
    sort (uint inPos)
        requires (inPos < m_Size)
    {
        if (m_Sorted)
        {
            unowned V val = m_pContent[inPos].val;
            m_Size--;

            if (inPos != m_Size)
                GLib.Memory.move (&m_pContent[inPos], &m_pContent[inPos + 1],
                                  (m_Size - inPos) * sizeof (Node<V>));

            int pos = get_nearest_pos (val);

            m_Size++;

            if (pos < m_Size - 1)
            {
                GLib.Memory.move (&m_pContent[pos + 1], &m_pContent[pos],
                                  (m_Size - pos - 1) * sizeof (Node<V>));
                GLib.Memory.set (&m_pContent[pos], 0, sizeof (Node<V>));
            }

            GLib.Memory.copy (&m_pContent[pos].val, &val, sizeof (V*));
        }
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    contains (V inValue)
    {
        return get_iterator (inValue) != null;
    }

    /**
     * {@inheritDoc}
     */
    internal override unowned V?
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
                    int medium = (int)(((uint)left + (uint)right) >> 1);
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
    internal override Maia.Core.Iterator<V>
    insert (V inValue)
    {
        Iterator<V> iter;

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

            iter = new Iterator<V> (this, pos);

            stamp++;
        }
        else
        {
            m_Size++;
            grow ();

            m_pContent[m_Size - 1].val = inValue;

            iter = new Iterator<V> (this, m_Size - 1);

            stamp++;
        }

        return iter;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    remove (V inValue)
    {
        Iterator<V>? iterator = get_iterator (inValue);
        if (iterator != null)
        {
            erase (iterator);
            reduce ();
        }
    }

    /**
     * {@inheritDoc}
     */
    public void
    remove_at (uint inPos)
        requires (inPos < m_Size)
    {
        m_Size--;

        V val = (owned)m_pContent[inPos].val;
        m_pContent[inPos].val = null;
        val = null;

        if (inPos != m_Size)
            GLib.Memory.move (&m_pContent[inPos], &m_pContent[inPos + 1],
                              (m_Size - inPos) * sizeof (Node<V>));

        GLib.Memory.set (&m_pContent[m_Size], 0, sizeof (Node<V>));
        reduce ();

        stamp++;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    clear ()
    {
        if (m_pContent != null)
        {
            for (int cpt = 0; cpt < m_Size; ++cpt)
            {
                m_pContent[cpt].val = null;
            }

            GLib.Slice.free (m_ReservedSize * sizeof (Node<V>), m_pContent);
            m_ReservedSize = 4;
            m_Size = 0;
            m_pContent = GLib.Slice.alloc0 (m_ReservedSize * sizeof (Node<V>));
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
    public Maia.Core.Iterator<V>?
    get_iter (V inValue)
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
    get (int inIndex)
    {
        return at (inIndex);
    }

    /**
     * Sets the item at the specified index in this list.
     *
     * @param inIndex zero-based index of the value position
     * @param inValue the value to add to the collection
     */
    public void
    set (int inIndex, V inValue)
        requires (inIndex <= m_Size)
    {
        if (inIndex < m_Size)
        {
            m_pContent[inIndex].val = inValue;
        }
        else if (inIndex == m_Size)
        {
            insert (inValue);
        }
    }

    /**
     * Returns the index of the specified value in this array.
     *
     * @param inValue the value whose index is to be retrieved
     *
     * @return the index associated with the value, or -1 if the value
     *         couldn't be found
     */
    public int
    index_of (V inValue)
    {
        int pos = -1;
        Iterator<V>? iter = get_iterator (inValue);
        if (iter != null)
        {
            pos = iter.index;
        }

        return pos;
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
    internal override Maia.Core.Iterator<V>
    iterator ()
    {
        return new Iterator<V> (this);
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    erase (Maia.Core.Iterator<V> inIterator)
        requires (inIterator.stamp == stamp)
    {
        Iterator<V> iter = inIterator as Iterator<V>;

        remove_at (iter.index);
    }
}

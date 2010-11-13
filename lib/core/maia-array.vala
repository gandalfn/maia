/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-array.vala
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

    ~Array ()
    {
        delete m_pContent;
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

        if (compare_func == null)
        {
            for (int cpt = 0; iterator == null && cpt < m_Size; ++cpt)
            {
                if (equal_func (m_pContent[cpt].val, inValue))
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
                    int res = compare_func ((void*)m_pContent[medium].val, (void*)inValue);

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
    public override void
    insert (V inValue)
    {
        if (compare_func != null)
        {
            int index = m_Size;

            m_Size++;
            grow ();

            while (index > 0 && compare_func (m_pContent[index - 1].val, inValue) > 0)
            {
                m_pContent[index].val = m_pContent[index - 1].val;
                index--;
            }

            m_pContent[index].val = inValue;

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
        delete m_pContent;
        m_ReservedSize = 4;
        m_Size = 0;
        m_pContent = new Node<V>[m_ReservedSize];
        stamp++;
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

        for (int cpt = index; cpt < m_Size; ++cpt)
            m_pContent[cpt].val = m_pContent[cpt + 1].val;

        m_pContent[m_Size].val = null;

        stamp++;
    }
}
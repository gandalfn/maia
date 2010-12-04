/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-collection.vala
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

public abstract class Maia.Collection<V>
{
    // Types
    [CCode (has_target = false)]
    public delegate int ValueCompareFunc<V, A> (V inV, A inA);

    // Properties
    private EqualFunc<V>    m_EqualFunc;
    private CompareFunc<V>  m_CompareFunc;
    private ToStringFunc<V> m_ToStringFunc;

    internal int            stamp;

    // Accessors
    public virtual EqualFunc<V> equal_func {
        get {
            return m_EqualFunc;
        }
        set {
            m_EqualFunc = value;
        }
    }

    public virtual CompareFunc<V> compare_func {
        get {
            return m_CompareFunc;
        }
        set {
            m_CompareFunc = value;
        }
    }

    public virtual ToStringFunc<V> to_string_func {
        get {
            return m_ToStringFunc;
        }
        set {
            m_ToStringFunc = value;
        }
    }

    // Methods
    public Collection ()
    {
        equal_func = get_equal_func_for<V> ();
        compare_func = null;
        to_string_func = get_to_string_func_for<V> ();
        stamp = 0;
    }

    ~Collection ()
    {
        clear ();
    }

    /**
     * The number of items in this collection.
     */
    public abstract int nb_items { get; }

    /**
     * Determines whether this collection contains the specified value.
     *
     * @param inValue the value to locate in the collection
     *
     * @return true if value is found, false otherwise
     */
    public abstract bool contains (V inValue);

    /**
     * Search if the specified is in this collection.
     *
     * @param inValue the value to locate in the collection
     * @param inCompareFunc custom compare function
     *
     * @return value found or null otherwise
     */
    public abstract unowned V? search<A> (A inValue, ValueCompareFunc<V, A> inFunc);     

    /**
     * Insert a value to this collection.
     *
     * @param inValue the value to add to the collection
     */
    public abstract void insert (V inValue);

    /**
     * Removes the first occurence of a value from this collection.
     *
     * @param inValue the value to remove from the collection
     */
    public abstract void remove (V inValue);

    /**
     * Removes all values from this collection.
     */
    public abstract void clear ();


    /**
     * Returns a Iterator that can be used for simple iteration over a
     * collection.
     *
     * @return a Iterator that can be used for simple iteration over a
     *         collection
     */
    public abstract Iterator<V> iterator ();

    /**
     * Removes the iterator from this collection.
     *
     * @param inIterator the iterator to remove from the collection
     */
    public abstract void erase (Iterator<V> inIterator);
}
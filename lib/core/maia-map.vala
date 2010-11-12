/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-map.vala
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

public class Maia.Map <K, V> : Set <Pair <K, V>>
{
    // Properties
    private Pair<K, V>   m_SearchKey;

    // Methods
    public Map ()
    {
        m_SearchKey = new Pair<K, V> (null, null);
    }

    /**
     * Determines whether this map contains the specified key.
     *
     * @param inKey the key to locate in the map
     *
     * @return true if key is found, false otherwise
     */
    public new bool
    contains (K inKey)
    {
        m_SearchKey.first = inKey;
        return base.contains (m_SearchKey);
    }

    /**
     * Returns the value of the specified key in this map.
     *
     * @param inKey the key whose value is to be retrieved
     *
     * @return the value associated with the key, or null if the key
     *         couldn't be found
     */
    public new unowned V?
    @get (K inKey)
    {
        m_SearchKey.first = inKey;
        unowned Pair<K, V>? pair = find (m_SearchKey);
 
        return pair != null ? pair.second : null;
    }

    /**
     * Inserts a new key and value into this map.
     *
     * @param inKey the key to insert
     * @param inValue the value to associate with the key
     */
    public void
    @set (K inKey, V inValue)
    {
        insert (new Pair<K, V> (inKey, inValue));
    }

    /**
     * Removes the specified key from this tree.
     *
     * @param inKey the key to remove from the tree
     */
    public void
    unset (K inKey)
    {
        m_SearchKey.first = inKey;
        remove (m_SearchKey);
    }
}
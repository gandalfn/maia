/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * iterator.vala
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

/**
 * Implemented by classes that support a simple iteration over instances of the
 * collection.
 */
public abstract class Maia.Iterator<V>
{
    internal int stamp;

    /**
     * Advances to the next element in the iteration.
     *
     * @return true if the iterator has a next element
     */
    public abstract bool next ();

    /**
     * Returns the current element in the iteration.
     *
     * @return the current element in the iteration
     */
    public abstract unowned V? get ();
}
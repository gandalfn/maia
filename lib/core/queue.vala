/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * queue.vala
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

public class Maia.Core.Queue<V> : Array<V>
{
    // methods
    // TODO: use Array for Queue ? perhaps List is more accurate.
    public Queue ()
    {
        base ();
    }

    public Queue.sorted ()
    {
        base.sorted ();
    }

    public virtual unowned V?
    peek ()
    {
        return length > 0 ? at (0) : null;
    }

    public virtual V?
    pop ()
    {
        if (length > 0)
        {
            V? val = at (0);
            remove_at (0);

            return val;
        }

        return null;
    }

    public virtual void
    push (V inVal)
    {
        insert (inVal);
    }
}

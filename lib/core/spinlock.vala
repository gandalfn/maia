/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * spinlock.vala
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
 
public struct Maia.SpinLock
{
    internal Os.Atomic.UShort ticket;
    internal Os.Atomic.UShort users;

    public SpinLock ()
    {
        ticket = Os.Atomic.UShort ();
        users = Os.Atomic.UShort ();
    }

    public ushort
    lock ()
    {
        ushort me = users.fetch_and_add (1);

        while (!ticket.compare (me))
        {
            Os.usleep (10);
        }

        return me;
    }

    public void
    unlock ()
    {
        ticket.inc ();
    }

    public bool
    try_lock ()
    {
        ushort me = users.get ();
        ushort menew = me + 1;
        uint cmp = ((uint) me << 16) + me;
        uint cmpnew = ((uint) menew << 16) + me;

        return Os.Atomic.UInt.cast (&this).compare_and_exchange (cmp, cmpnew);
    }

    public bool
    is_lockable ()
    {
        return users.compare (ticket.get ());
    }
}
/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    internal Machine.Memory.Atomic.uint16 ticket;
    internal Machine.Memory.Atomic.uint16 users;

    public void
    lock ()
    {
        uint16 me = users.fetch_and_add (1);

        while (ticket.get () != me)
            Machine.CPU.pause ();
    }

    public void
    lock_eb ()
    {
        uint16 me = users.fetch_and_add (1);
        BackOff bo = BackOff ();

        while (ticket.get () != me)
            bo.exponential_block ();
    }

    public void
    unlock ()
    {
        ticket.inc ();
    }

    public bool
    try_lock ()
    {
        uint16 me = users.get ();
        uint16 menew = me + 1;
        uint32 cmp = ((uint32) me << 16) + me;
        uint32 cmpnew = ((uint32) menew << 16) + me;

        return Machine.Memory.Atomic.uint32.cast (&this).compare_and_swap (cmp, cmpnew);
    }

    public bool
    is_lockable ()
    {
        return users.get () == ticket.get ();
    }
}

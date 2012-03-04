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

internal struct Maia.Ticket16
{
    public uint16 ticket;

    internal static inline unowned Ticket16?
    cast (void* inLck)
    {
        return (Ticket16?)inLck;
    }
}

public struct Maia.SpinLock
{
    internal Machine.Memory.Atomic.uint32 lck;

    public inline void
    lock ()
    {
        uint32 me = lck.fetch_and_add (1 << 16);
        uint16 val = (uint16)(me >> 16);
        unowned Ticket16? l = Ticket16.cast (&lck);

        while (val != l.ticket)
            Machine.CPU.pause ();
    }

    public inline void
    unlock ()
    {
        uint32 val = 0, inc = 0;
        do
        {
            val = lck.get ();
            inc = val;

            unowned Ticket16 l = Ticket16.cast (&lck);

            if (l.ticket == 0xFFFF)
                inc += 1 - (1 << 16);
            else
                inc += 1;
        } while (!lck.compare_and_swap (val, inc));
    }
}

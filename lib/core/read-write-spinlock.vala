/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * read-write-spinlock.vala
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

internal struct Maia.RWTicket16
{
    public uint16 rw;
    public uint16 users;

    internal static inline unowned RWTicket16?
    cast (void* inLck)
    {
        return (RWTicket16?)inLck;
    }
}

internal struct Maia.RWTicket8
{
    public uint8 writers;
    public uint8 readers;
    public uint8 users;

    internal static inline unowned RWTicket8?
    cast (void* inLck)
    {
        return (RWTicket8?)inLck;
    }
}

public struct Maia.ReadWriteSpinLock
{
    internal Machine.Memory.Atomic.uint32 lck;

    public inline void
    write_lock ()
    {
        uint32 me = lck.fetch_and_add (1 << 16);
        uint8 val = (uint8)(me >> 16);
        unowned RWTicket8? l = RWTicket8.cast (&lck);

        if (val != l.writers)
            Log.warning (GLib.Log.METHOD, "write %u %u", val, l.writers);
        while (val != l.writers) Machine.CPU.pause ();
    }

    public inline void
    write_unlock ()
    {
        unowned RWTicket8? l = RWTicket8.cast (&lck);
        uint32 inc = 0;
        if (l.readers == 255)
            inc += (1 << 8) - (1 << 16);
        else
            inc += (1 << 8);
        if (l.writers == 255)
            inc += 1 - (1 << 8);
        else
            inc += 1;
        lck.fetch_and_add (inc);
    }

    public inline void
    read_lock ()
    {
        uint32 me = lck.fetch_and_add (1 << 16);
        uint8 val = (uint8)(me >> 16);
        unowned RWTicket8? l = RWTicket8.cast (&lck);

        if (val != l.readers)
            Log.warning (GLib.Log.METHOD, "read %u %u", val, l.readers);
        while (val != l.readers) Machine.CPU.pause ();
        if (val != 255)
            lck.fetch_and_add (1 << 8);
        else
            lck.fetch_and_add ((1 << 8) - (1 << 16));
    }

    public inline void
    read_lock_eb ()
    {
        uint32 me = lck.fetch_and_add (1 << 16);
        uint8 val = (uint8)(me >> 16);
        unowned RWTicket8? l = RWTicket8.cast (&lck);
        BackOff bo = BackOff ();

        if (val != l.readers)
            Log.warning (GLib.Log.METHOD, "read %u %u", val, l.readers);
        while (val != l.readers) bo.exponential_block ();
        lck.fetch_and_add (1 << 8);
    }

    public inline void
    read_unlock ()
    {
        Machine.Memory.Atomic.uint8.cast (&lck).inc ();
    }
}

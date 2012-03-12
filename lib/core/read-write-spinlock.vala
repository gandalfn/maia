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

internal struct Maia.RWTicket8
{
    public uint8 writers;
    public uint8 readers;

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

        Log.warning_cond (val != l.writers, GLib.Log.METHOD, "write %u %u", val, l.writers);

        while (val != l.writers) Machine.CPU.pause ();

#if USE_VALGRIND
        Valgrind.Helgrind.rwlock_acquired (&this, 1);
#endif
    }

    public inline void
    write_unlock ()
    {
        uint32 val = 0, inc = 0;
        do
        {
            val = lck.get ();
            inc = val;

            unowned RWTicket8? l = RWTicket8.cast (&val);

            if (l.readers == 255)
                inc += (1 << 8) - (1 << 16);
            else
                inc += (1 << 8);
            if (l.writers == 255)
                inc += 1 - (1 << 8);
            else
                inc += 1;
        } while (!lck.compare_and_swap (val, inc));

#if USE_VALGRIND
        Valgrind.Helgrind.rwlock_released (&this, 1);
#endif
    }

    public inline void
    read_lock ()
    {
        uint32 me = lck.fetch_and_add (1 << 16);
        uint8 val = (uint8)(me >> 16);
        unowned RWTicket8? l = RWTicket8.cast (&lck);

        Log.warning_cond (val != l.readers, GLib.Log.METHOD, "read %u %u", val, l.readers);

        while (val != l.readers) Machine.CPU.pause ();

        if (val != 255)
            lck.fetch_and_add (1 << 8);
        else
            lck.fetch_and_add ((1 << 8) - (1 << 16));

#if USE_VALGRIND
        Valgrind.Helgrind.rwlock_acquired (&this, 0);
#endif
    }

    public inline void
    read_unlock ()
    {
        uint32 val = 0, inc = 0;
        do
        {
            val = lck.get ();
            inc = val;

            unowned RWTicket8? l = RWTicket8.cast (&val);

            if (l.writers == 255)
                inc += 1 - (1 << 8);
            else
                inc += 1;
        } while (!lck.compare_and_swap (val, inc));

#if USE_VALGRIND
        Valgrind.Helgrind.rwlock_released (&this, 0);
#endif
    }
}

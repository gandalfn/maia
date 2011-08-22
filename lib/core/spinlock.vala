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
    internal ushort ticket;
    internal ushort users;

    public SpinLock ()
    {
    }

    public ushort
    lock ()
    {
        message("lock: %u, 0x%lx", users, (ulong)GLib.Thread.self<void*> ());
        ushort me = Os.Atomic.ushort_fetch_and_add (ref users, 1);

        message("wait: %u, 0x%lx", me, (ulong)GLib.Thread.self<void*> ());
        while (ticket != me) Os.Cpu.relax ();
        message("get: %u, 0x%lx", me, (ulong)GLib.Thread.self<void*> ());

        return me;
    }

    public void
    unlock ()
    {
        message("unlock: %u, 0x%lx", ticket, (ulong)GLib.Thread.self<void*> ());
        Os.Atomic.ushort_inc (ref ticket);
        message("next: %u, 0x%lx", ticket, (ulong)GLib.Thread.self<void*> ());
    }

    public bool
    try_lock ()
    {
        ushort me = users;
        ushort menew = me + 1;
        uint cmp = ((uint) me << 16) + me;
        uint cmpnew = ((uint) menew << 16) + me;
        SpinLock* ptr = &this;
        uint* u = (uint*)ptr;

        return Os.Atomic.uint_compare_and_exchange (u, cmp, cmpnew);
    }

    public bool
    is_lockable ()
    {
        return Os.Atomic.ushort_compare (users, ticket);
    }
}
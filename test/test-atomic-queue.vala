/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-atomic-queue.vala
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

// static properties
static Maia.Atomic.Queue<string> s_Queue = null;
const int s_Cpt = 200;
const int s_NbThreads = 5;

// methods
static int
main (string[] inArgs)
{
    GLib.Test.init (ref inArgs);
    unowned GLib.Thread<void*> id[5];

    s_Queue = new Maia.Atomic.Queue<string> ();

    for (int i = 0; i < s_NbThreads; ++i)
    {
        id[i] = GLib.Thread.create<void*> (() => {
            GLib.Rand rand = new GLib.Rand ();
            for (int cpt = 0; cpt < s_Cpt; ++cpt)
            {
                s_Queue.enqueue ("thread 0x%lx: count = %i".printf ((ulong)GLib.Thread.self<void*> (), cpt));
                Os.usleep (rand.int_range (0, 20) * 1000);
            }
            return null;
        }, true);
    }

    GLib.Rand rand = new GLib.Rand ();
    for (int cpt = 0; cpt < s_Cpt * s_NbThreads;)
    {
        string? data = s_Queue.dequeue ();
        if (data != null)
        {
            message ("data = %s", data);
            ++cpt;
        }
        Os.usleep (rand.int_range (0, 20) * 1000);
    }

    for (int i = 0; i < s_NbThreads; ++i)
    {
        id[i].join ();
    }

    s_Queue = null;

    return 0;
}

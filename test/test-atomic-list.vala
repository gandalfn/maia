/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-atomic-list.vala
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
static Maia.AtomicList<string> s_List = null;

// methods
static int
main (string[] inArgs)
{
    GLib.Test.init (ref inArgs);

    s_List = new Maia.AtomicList<string> ();
/*    for (int cpt = 0; cpt < 1000; ++cpt)
    {
        s_List.insert (@"main 1: count = $cpt");
    }
    foreach (string data in s_List)
    {
        message ("data = %s", data);
    }
    return 0;*/

    unowned GLib.Thread<void*> id1 = GLib.Thread.create<void*> (() => {
        GLib.Rand rand = new GLib.Rand ();
        for (int cpt = 0; cpt < 1000; ++cpt)
        {
            s_List.insert ("thread 1: count = " + cpt.to_string ());
            Os.usleep (rand.int_range (0, 5) * 1000);
        }
        return null;
    }, true);

    unowned GLib.Thread<void*> id2 = GLib.Thread.create<void*> (() => {
        GLib.Rand rand = new GLib.Rand ();
        for (int cpt = 0; cpt < 1000; ++cpt)
        {
            s_List.insert ("thread 2: count = " + cpt.to_string ());
            Os.usleep (rand.int_range (0, 5) * 1000);
        }
        return null;
    }, true);

    unowned GLib.Thread<void*> id3 = GLib.Thread.create<void*> (() => {
        GLib.Rand rand = new GLib.Rand ();
        for (int cpt = 0; cpt < 1000; ++cpt)
        {
            s_List.insert ("thread 3: count = " + cpt.to_string ());
            Os.usleep (rand.int_range (0, 5) * 1000);
        }
        return null;
    }, true);

    id1.join ();
    id2.join ();
    id3.join ();


    foreach (string data in s_List)
    {
        message ("data = %s", data);
    }

    s_List = null;

    return 0;
}
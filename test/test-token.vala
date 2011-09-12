/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-token.vala
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

private void*
thread_1 ()
{
    Maia.Token token1 = Maia.Token.get (1);
    Maia.Token token2 = Maia.Token.get (2);
    Maia.Token token3 = Maia.Token.get (3);

    GLib.Rand rand = new GLib.Rand ();

    for (int cpt = 0; cpt < 10; ++ cpt)
    {
        message ("Lock t1: 0x%x", Os.gettid());
        token1.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Lock t2: 0x%x", Os.gettid());
        token2.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Lock t1: 0x%x", Os.gettid());
        token1.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Lock t3: 0x%x", Os.gettid());
        token3.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t3: 0x%x", Os.gettid());
        token3.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t1: 0x%x", Os.gettid());
        token1.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t2: 0x%x", Os.gettid());
        token2.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t1: 0x%x", Os.gettid());
        token1.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);
    }

    return null;
}

private void*
thread_2 ()
{
    Maia.Token token1 = Maia.Token.get (1);
    Maia.Token token2 = Maia.Token.get (2);
    Maia.Token token3 = Maia.Token.get (3);

    GLib.Rand rand = new GLib.Rand ();

    for (int cpt = 0; cpt < 10; ++ cpt)
    {
        message ("Lock t2: 0x%x", Os.gettid());
        token2.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Lock t1: 0x%x", Os.gettid());
        token1.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Lock t3: 0x%x", Os.gettid());
        token3.acquire ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t3: 0x%x", Os.gettid());
        token3.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t1: 0x%x", Os.gettid());
        token1.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);

        message ("Unlock t2: 0x%x", Os.gettid());
        token2.release ();
        Os.usleep (rand.int_range (0, 200) * 1000);
    }

    return null;
}

static int
main (string[] inArgs)
{
    Maia.log_set_level (Maia.Level.AUDIT);
    unowned GLib.Thread<void*> id[8];
    Os.Atomic.ULong test = Os.Atomic.ULong ();

    test.set (1);
    test.fetch_and_add (1);
    message ("%lu",sizeof (GLib.Pid)); 

    for (int cpt = 0; cpt < id.length; cpt += 2)
    {
         id[cpt] = GLib.Thread.create<void*> (thread_1, true);
         id[cpt + 1] = GLib.Thread.create<void*> (thread_2, true);
    }

    for (int cpt = 0; cpt < id.length; cpt++)
    {
        id[cpt].join ();
    }

    return 0;
}

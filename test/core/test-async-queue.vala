/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-async-queue.vala
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

public class Maia.TestAsyncQueue : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private Core.AsyncQueue<int> m_Queue;

    private int[] m_Keys;

    public TestAsyncQueue ()
    {
        base ("async-queue");

        add_test ("push-pop", test_async_queue_push_pop);
        add_test ("push-peek", test_async_queue_push_peek);
        add_test ("pop-timed", test_async_queue_pop_timed);
        add_test ("peek-timed", test_async_queue_peek_timed);
    }

    public override void
    set_up ()
    {
        m_Queue = new Core.AsyncQueue<int> ();

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (1, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_Queue = null;
    }

    public void
    test_async_queue_push_pop ()
    {
        var thread = new GLib.Thread<bool> ("push-pop", () => {
            bool ret = true;
            int cpt = 0;
            while (ret && cpt < NB_KEYS)
            {
                int val = m_Queue.pop ();

                ret = val == m_Keys[cpt];
                ++cpt;
            }

            return ret;
        });

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Queue.push (m_Keys[cpt]);
        }

        assert (thread.join ());

        assert (m_Queue.length == 0);
    }

    public void
    test_async_queue_push_peek ()
    {
        var thread = new GLib.Thread<bool> ("push-pop", () => {
            return m_Queue.peek () == m_Keys[0];
        });

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Queue.push (m_Keys[cpt]);
        }

        assert (thread.join ());
        assert (m_Queue.length != 0);
    }

    public void
    test_async_queue_pop_timed ()
    {
        var thread = new GLib.Thread<bool> ("pop-timed", () => {
            bool ret = true;
            int cpt = 0;
            while (ret && cpt < NB_KEYS)
            {
                Test.timer_start ();
                int val = m_Queue.pop_timed (200);
                double elapsed = Test.timer_elapsed () * 1000;

                if (val == 0)
                {
                    Test.message ("pop timeout %i", (int)elapsed);
                    ret = elapsed >= 200;
                    break;
                }

                ret = val == m_Keys[cpt];
                ++cpt;
            }

            return ret;
        });

        Posix.usleep (100000);

        for (int cpt = 0; cpt < NB_KEYS / 2; ++cpt)
        {
            if (m_Keys[cpt] != 0) m_Queue.push (m_Keys[cpt]);
        }

        assert (thread.join ());

        assert (m_Queue.length == 0);
    }

    public void
    test_async_queue_peek_timed ()
    {
        var thread = new GLib.Thread<bool> ("pop-timed", () => {
            bool ret = true;
            Test.timer_start ();
            int val = m_Queue.peek_timed (200);
            double elapsed = Test.timer_elapsed () * 1000;

            ret = elapsed < 200;
            if (ret) ret = val == m_Keys[0];
            if (ret) ret = m_Queue.length != 0;

            if (ret)
            {
                m_Queue.pop ();
                Test.timer_start ();
                val = m_Queue.peek_timed (200);
                elapsed = Test.timer_elapsed () * 1000;
                ret = val == 0;
                if (ret) ret = elapsed >= 200;
            }

            return ret;
        });

        m_Queue.push (m_Keys[0]);

        assert (thread.join ());
    }
}

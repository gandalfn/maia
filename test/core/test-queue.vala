/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-queue.vala
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

public class Maia.TestQueue : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private Core.Queue<int> m_Queue;

    private int[] m_Keys;

    public TestQueue ()
    {
        base ("queue");

        add_test ("push-pop", test_queue_push_pop);
        add_test ("push-peek", test_queue_push_peek);
        if (Test.perf())
        {
            add_test ("benchmark-push", test_queue_benchmark_push);
            add_test ("benchmark-pop", test_queue_benchmark_pop);
        }
    }

    public override void
    set_up ()
    {
        m_Queue = new Core.Queue<int> ();

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (0, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_Queue = null;
    }

    public void
    test_queue_push_pop ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Queue.push (m_Keys[cpt]);
        }

        for (int cpt = NB_KEYS - 1; cpt >= 0; --cpt)
        {
            int l = m_Queue.length;
            assert (m_Queue.pop () == m_Keys[cpt]);
            assert (l - 1 == m_Queue.length);
        }

        assert (m_Queue.length == 0);
    }

    public void
    test_queue_push_peek ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Queue.push (m_Keys[cpt]);
        }

        assert (m_Queue.peek () == m_Keys[NB_KEYS - 1]);
        assert (m_Queue.length != 0);
    }

    public void
    test_queue_benchmark_push ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Queue.push (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Queue push min time %f ms", min);
        Test.maximized_result (min, "Queue push max time %f ms", max);
    }

    public void
    test_queue_benchmark_pop ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Queue.push (m_Keys[cpt]);
            }

            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Queue.pop ();
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Queue push min time %f ms", min);
        Test.maximized_result (min, "Queue push max time %f ms", max);
    }
}

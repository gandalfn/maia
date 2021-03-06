/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-array.vala
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

public class Maia.TestArray : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private Core.Array<int> m_ArrayNoSorted;
    private Core.Array<int> m_Array;

    private int[] m_Keys;

    public TestArray ()
    {
        base ("array");

        add_test ("insert", test_array_insert);
        add_test ("remove", test_array_remove);
        add_test ("erase", test_array_erase);
        add_test ("search", test_array_search);
        add_test ("parse", test_array_parse);
        add_test ("parse-foreach", test_array_parse_foreach);
        if (Test.perf())
        {
            add_test ("benchmark-insert", test_array_benchmark_insert);
            add_test ("benchmark-insert-no-sorted", test_array_no_sorted_benchmark_insert);
            add_test ("benchmark-insert-reserve", test_array_benchmark_insert_reserve);
            add_test ("benchmark-remove", test_array_benchmark_remove);
            add_test ("benchmark-search", test_array_benchmark_search);
            add_test ("benchmark-parse", test_array_benchmark_parse);
            add_test ("benchmark-parse-foreach", test_array_benchmark_parse_foreach);
        }
    }

    public override void
    set_up ()
    {
        m_ArrayNoSorted = new Core.Array<int> ();
        m_Array = new Core.Array<int>.sorted ();
        m_Array.compare_func = (Core.CompareFunc<int>)Maia.Core.direct_compare;

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (0, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_Array = null;
        m_ArrayNoSorted = null;
        m_Keys = null;
    }

    public void
    test_array_insert ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Array.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Keys[cpt] in m_Array);
        }
    }

    public void
    test_array_remove ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_ArrayNoSorted.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int nb_items = m_ArrayNoSorted.length;
            m_ArrayNoSorted.remove (m_Keys[cpt]);
            for (int i = cpt + 1; i < NB_KEYS; ++i)
            {
                assert (m_ArrayNoSorted.at (i - cpt - 1) == m_Keys[i]);
            }
            assert (m_ArrayNoSorted.length == nb_items - 1);
        }
        assert (m_ArrayNoSorted.length == 0);
    }

    public void
    test_array_erase ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Array.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            Core.Iterator<int> found = m_Array.get_iter (m_Keys[index]);
            int size = m_Array.length;
            if (found != null)
            {
                m_Array.erase (found);
                assert (m_Array.length == size - 1);
            }
        }
    }

    public void
    test_array_search ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Array.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            assert (m_Keys[index] in m_Array);
        }
    }

    public void
    test_array_parse ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Array.insert (m_Keys[cpt]);
        }

        int prev = -1;
        int count = 0;
        foreach (int val in m_Array)
        {
            if (prev >= 0)
            {
                assert (prev <= val);
            }
            prev = val;
            count++;
        }
        assert (count == m_Array.length);
    }

    public void
    test_array_parse_foreach ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Array.insert (m_Keys[cpt]);
        }

        int prev = -1;
        int count = 0;
        m_Array.iterator ().foreach ((val) => {
            if (prev >= 0)
            {
                assert (prev <= val);
            }
            prev = val;
            count++;
            return true;
        });
        assert (count == m_Array.length);
    }

    public void
    test_array_benchmark_insert ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Array.insert (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Array.clear ();
        }
        Test.minimized_result (min, "Array set min time %f ms", min);
        Test.maximized_result (min, "Array set max time %f ms", max);
    }

    public void
    test_array_no_sorted_benchmark_insert ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_ArrayNoSorted.insert (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_ArrayNoSorted.clear ();
        }
        Test.minimized_result (min, "Array set min time %f ms", min);
        Test.maximized_result (min, "Array set max time %f ms", max);
    }

    public void
    test_array_benchmark_insert_reserve ()
    {
        double min = double.MAX, max = 0;
        m_Array.reserve (NB_KEYS + 1);
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Array.insert (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Array.clear ();
        }
        Test.minimized_result (min, "Array set min time %f ms", min);
        Test.maximized_result (min, "Array set max time %f ms", max);
    }

    public void
    test_array_benchmark_search ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Array.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int index = Test.rand_int_range (0, NB_KEYS - 1);
                assert (m_Keys[index] in m_Array);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Array.clear ();
        }
        Test.minimized_result (min, "Array search min time %f ms", min);
        Test.maximized_result (min, "Array search max time %f ms", max);
    }

    public void
    test_array_benchmark_parse ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Array.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            int prev = -1;
            foreach (int val in m_Array)
            {
                if (prev >= 0)
                {
                    assert (prev <= val);
                }
                prev = val;
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Array.clear ();
        }
        Test.minimized_result (min, "Array parse min time %f ms", min);
        Test.maximized_result (min, "Array parse max time %f ms", max);
    }

    public void
    test_array_benchmark_parse_foreach ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Array.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            int prev = -1;
            m_Array.iterator ().foreach ((val) => {
                if (prev >= 0)
                {
                    assert (prev <= val);
                }
                prev = val;
                return true;
            });
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Array.clear ();
        }
        Test.minimized_result (min, "Array parse min time %f ms", min);
        Test.maximized_result (min, "Array parse max time %f ms", max);
    }

    public void
    test_array_benchmark_remove ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Array.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int nb_items = m_Array.length;
                m_Array.remove (m_Keys[cpt]);
                assert (m_Array.length == nb_items - 1);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Array unset min time %f ms", min);
        Test.maximized_result (min, "Array unset max time %f ms", max);
    }
}

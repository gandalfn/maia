/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-set.vala
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

public class Maia.TestSet : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private Set<int> m_Set;

    private int[] m_Keys;

    public TestSet ()
    {
        base ("set");

        add_test ("insert", test_set_insert);
        add_test ("remove", test_set_remove);
        add_test ("erase", test_set_erase);
        add_test ("search", test_set_search);
        add_test ("parse", test_set_parse);
        if (Test.perf())
        {
            add_test ("benchmark-insert", test_set_benchmark_insert);
            add_test ("benchmark-remove", test_set_benchmark_remove);
            add_test ("benchmark-search", test_set_benchmark_search);
            add_test ("benchmark-search-key", test_set_benchmark_search_key);
            add_test ("benchmark-parse", test_set_benchmark_parse);
        }
    }

    private static string
    data_to_string (int inData)
    {
        return "%d".printf(inData);
    }

    public override void
    set_up ()
    {
        m_Set = new Set<int> ();
        m_Set.to_string_func = (ToStringFunc<int>)data_to_string;

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (0, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_Set = null;
        m_Keys = null;
    }

    public void
    test_set_insert ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Set.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Keys[cpt] in m_Set);
        }
    }

    public void
    test_set_remove ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Set.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Set.remove (m_Keys[cpt]);
            assert (!(m_Keys[cpt] in m_Set));
        }
        assert (m_Set.length == 0);
    }

    public void
    test_set_erase ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Set.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            Iterator<int> found = m_Set[m_Keys[index]];
            int size = m_Set.length;
            if (found != null)
            {
                m_Set.erase (found);
                assert (!(m_Keys[index] in m_Set));
                assert (m_Set.length == size - 1);
            }
        }
    }

    public void
    test_set_search ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Set.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            assert (m_Keys[index] in m_Set);
        }
    }

    public void
    test_set_parse ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Set.insert (m_Keys[cpt]);
        }

        int prev = -1;
        int count = 0;
        foreach (int val in m_Set)
        {
            if (prev >= 0)
            {
                assert (prev < val);
            }
            prev = val;
            count++;
        }
        assert (count == m_Set.length);
    }

    public void
    test_set_benchmark_insert ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Set.insert (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Set.clear ();
        }
        Test.minimized_result (min, "Set set min time %f ms", min); 
        Test.maximized_result (min, "Set set max time %f ms", max);
    }

    public void
    test_set_benchmark_search ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Set.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int index = Test.rand_int_range (0, NB_KEYS - 1);
                assert (m_Keys[index] in m_Set);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Set.clear ();
        }
        Test.minimized_result (min, "Set search min time %f ms", min); 
        Test.maximized_result (min, "Set search max time %f ms", max); 
    }

    public void
    test_set_benchmark_search_key ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Set.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int index = Test.rand_int_range (0, NB_KEYS - 1);
                m_Set.search<int> (m_Keys[index], (v, k) => {
                    return v - k;
                });
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Set.clear ();
        }
        Test.minimized_result (min, "Set search min time %f ms", min); 
        Test.maximized_result (min, "Set search max time %f ms", max); 
    }

    public void
    test_set_benchmark_parse ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Set.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            int prev = -1;
            foreach (int val in m_Set)
            {
                if (prev >= 0)
                {
                    assert (prev < val);
                }
                prev = val;
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Set.clear ();
        }
        Test.minimized_result (min, "Set parse min time %f ms", min); 
        Test.maximized_result (min, "Set parse max time %f ms", max); 
    }

    public void
    test_set_benchmark_remove ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Set.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Set.remove (m_Keys[cpt]);
                assert (!(m_Keys[cpt] in m_Set));
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Set unset min time %f ms", min); 
        Test.maximized_result (min, "Set unset max time %f ms", max); 
    }
}

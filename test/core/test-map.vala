/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-map.vala
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

public class Maia.TestMap : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private Map<int, string> m_Map;

    private int[] m_Keys;

    public TestMap ()
    {
        base ("map");

        add_test ("set", test_map_set);
        add_test ("unset", test_map_unset);
        add_test ("search", test_map_search);
        add_test ("parse", test_map_parse);
        if (Test.perf())
        {
            add_test ("benchmark-set", test_map_benchmark_set);
            add_test ("benchmark-unset", test_map_benchmark_unset);
            add_test ("benchmark-search", test_map_benchmark_search);
            add_test ("benchmark-parse", test_map_benchmark_parse);
        }
    }

    public override void
    set_up ()
    {
        m_Map = new Map<int, string> ();

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (0, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_Map = null;
        m_Keys = null;
    }

    public void
    test_map_set ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Map[m_Keys[cpt]] == m_Keys[cpt].to_string ());
        }
    }

    public void
    test_map_unset ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Map.unset (m_Keys[cpt]);
            assert (m_Map[m_Keys[cpt]] == null);
        }
        assert (m_Map.length == 0);
    }

    public void
    test_map_search ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            assert (m_Map[m_Keys[index]] == m_Keys[index].to_string ());
        }
    }

    public void
    test_map_parse ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        string prev = null;
        int count = 0;
        foreach (Pair<int, string> val in m_Map)
        {
            if (prev != null)
            {
                assert (int.parse (prev) < int.parse (val.second));
            }
            prev = val.second;
            count++;
        }
        assert (count == m_Map.length);
    }

    public void
    test_map_benchmark_set ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Map.clear ();
        }
        Test.minimized_result (min, "Map set min time %f ms", min);
        Test.maximized_result (min, "Map set max time %f ms", max);
    }

    public void
    test_map_benchmark_search ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int index = Test.rand_int_range (0, NB_KEYS - 1);
                assert (m_Map[m_Keys[index]] == m_Keys[index].to_string ());
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Map.clear ();
        }
        Test.minimized_result (min, "Map search min time %f ms", min);
        Test.maximized_result (min, "Map search max time %f ms", max);
    }

    public void
    test_map_benchmark_parse ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            Test.timer_start ();
            string prev = null;
            foreach (Pair<int, string> data in m_Map)
            {
                if (prev != null)
                {
                    assert (int.parse (prev) < int.parse (data.second));
                }
                prev = data.second;
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Map.clear ();
        }
        Test.minimized_result (min, "Map parse min time %f ms", min);
        Test.maximized_result (min, "Map parse max time %f ms", max);
    }

    public void
    test_map_benchmark_unset ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Map[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Map.unset (m_Keys[cpt]);
                assert (m_Map[m_Keys[cpt]] == null);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Map unset min time %f ms", min);
        Test.maximized_result (min, "Map unset max time %f ms", max);
    }
}

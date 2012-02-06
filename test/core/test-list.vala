/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-list.vala
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

public class Maia.TestList : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private List<int> m_ListNoSorted;
    private List<int> m_List;

    private int[] m_Keys;

    public TestList ()
    {
        base ("list");

        add_test ("insert", test_list_insert);
        add_test ("remove", test_list_remove);
        add_test ("erase", test_list_erase);
        add_test ("search", test_list_search);
        add_test ("parse", test_list_parse);
        add_test ("parse-foreach", test_list_parse_foreach);
        if (Test.perf())
        {
            add_test ("benchmark-insert", test_list_benchmark_insert);
            add_test ("benchmark-no-sorted-insert", test_list_no_sorted_benchmark_insert);
            add_test ("benchmark-remove", test_list_benchmark_remove);
            add_test ("benchmark-search", test_list_benchmark_search);
            add_test ("benchmark-parse", test_list_benchmark_parse);
            add_test ("benchmark-parse-foreach", test_list_benchmark_parse_foreach);
        }
    }

    public override void
    set_up ()
    {
        m_ListNoSorted = new List<int> ();
        m_List = new List<int>.sorted ();
        m_List.compare_func = (CompareFunc<int>)Maia.direct_compare;

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (0, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_List = null;
        m_ListNoSorted = null;
        m_Keys = null;
    }

    public void
    test_list_insert ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_List.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Keys[cpt] in m_List);
        }
    }

    public void
    test_list_remove ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_List.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int nb_items = m_List.length;
            m_List.remove (m_Keys[cpt]);
            assert (nb_items != m_List.length);
        }
        assert (m_List.length == 0);
    }

    public void
    test_list_erase ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_List.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            Iterator<int> found = m_List[m_Keys[index]];
            int size = m_List.length;
            if (found != null)
            {
                m_List.erase (found);
                assert (m_List.length == size - 1);
            }
        }
    }

    public void
    test_list_search ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_List.insert (m_Keys[cpt]);
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            assert (m_Keys[index] in m_List);
        }
    }

    public void
    test_list_parse ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_List.insert (m_Keys[cpt]);
        }

        int prev = -1;
        int count = 0;
        foreach (int val in m_List)
        {
            if (prev >= 0)
            {
                assert (prev <= val);
            }
            prev = val;
            count++;
        }
        assert (count == m_List.length);
    }

    public void
    test_list_parse_foreach ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_List.insert (m_Keys[cpt]);
        }

        int prev = -1;
        int count = 0;
        m_List.iterator ().foreach ((val) => {
            if (prev >= 0)
            {
                assert (prev <= val);
            }
            prev = val;
            count++;
            return true;
        });
        assert (count == m_List.length);
    }

    public void
    test_list_benchmark_insert ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_List.insert (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_List.clear ();
        }
        Test.minimized_result (min, "List insert min time %f ms", min);
        Test.maximized_result (min, "List insert max time %f ms", max);
    }

    public void
    test_list_no_sorted_benchmark_insert ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_ListNoSorted.insert (m_Keys[cpt]);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_ListNoSorted.clear ();
        }
        Test.minimized_result (min, "List insert min time %f ms", min);
        Test.maximized_result (min, "List insert max time %f ms", max);
    }

    public void
    test_list_benchmark_search ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_List.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int index = Test.rand_int_range (0, NB_KEYS - 1);
                assert (m_Keys[index] in m_List);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_List.clear ();
        }
        Test.minimized_result (min, "List search min time %f ms", min);
        Test.maximized_result (min, "List search max time %f ms", max);
    }

    public void
    test_list_benchmark_parse ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_List.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            int prev = -1;
            foreach (int val in m_List)
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
            m_List.clear ();
        }
        Test.minimized_result (min, "List parse min time %f ms", min);
        Test.maximized_result (min, "List parse max time %f ms", max);
    }

    public void
    test_list_benchmark_parse_foreach ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_List.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            int prev = -1;
            m_List.iterator ().foreach ((val) => {
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
            m_List.clear ();
        }
        Test.minimized_result (min, "List parse min time %f ms", min);
        Test.maximized_result (min, "List parse max time %f ms", max);
    }

    public void
    test_list_benchmark_remove ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_List.insert (m_Keys[cpt]);
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int nb_items = m_List.length;
                m_List.remove (m_Keys[cpt]);
                assert (nb_items != m_List.length);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "List remove min time %f ms", min);
        Test.maximized_result (min, "Set remove max time %f ms", max);
    }
}

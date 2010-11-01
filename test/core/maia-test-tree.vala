/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-test-tree.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.TestTree : Maia.TestCase
{
    const int NB_KEYS = 1000;

    private Tree<int, string> m_Tree;

    private int[] m_Keys;

    public TestTree ()
    {
        base ("tree");

        add_test ("set", test_tree_set);
        add_test ("unset", test_tree_unset);
        add_test ("search", test_tree_search);
        add_test ("parse", test_tree_parse);
        add_test ("benchmark-set", test_tree_benchmark_set);
        add_test ("benchmark-unset", test_tree_benchmark_unset);
        add_test ("benchmark-search", test_tree_benchmark_search);
        add_test ("benchmark-parse", test_tree_benchmark_parse);
        //add_test ("dot", test_tree_dot);
    }

    private static string
    data_to_string (string inData)
    {
        return "%s".printf(inData);
    }

    private static int
    key_cmp (int inA, int inB)
    {
        int ret = 0;

        if (inA < inB)
            ret = -1;
        else if (inA > inB)
            ret = 1;

        return ret;
    }

    public override void
    set_up ()
    {
        m_Tree = new Tree<int, string> ((GLib.CompareDataFunc)key_cmp,
                                        (Tree.ToStringFunc)data_to_string);

        m_Keys = new int[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range (0, NB_KEYS);
        }
    }

    public override void
    tear_down ()
    {
        m_Tree = null;
    }

    public void
    test_tree_set ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Tree[m_Keys[cpt]] == m_Keys[cpt].to_string ());
        }
    }

    public void
    test_tree_unset ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree.unset (m_Keys[cpt]);
            assert (m_Tree[m_Keys[cpt]] == null);
        }
        assert (m_Tree.nb_items == 0);
    }

    public void
    test_tree_search ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            int index = Test.rand_int_range (0, NB_KEYS - 1);
            assert (m_Tree[m_Keys[index]] == m_Keys[index].to_string ());
        }
    }

    public void
    test_tree_parse ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
        }

        string prev = null;
        int count = 0;
        foreach (string val in m_Tree)
        {
            if (prev != null)
            {
                assert (prev.to_int () < val.to_int ());
            }
            prev = val;
            count++;
        }
        assert (count == m_Tree.nb_items);
    }

    public void
    test_tree_benchmark_set ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Tree.clear ();
        }
        Test.minimized_result (min, "Tree set min time %f ms", min); 
        Test.maximized_result (min, "Tree set max time %f ms", max);
    }

    public void
    test_tree_benchmark_search ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                int index = Test.rand_int_range (0, NB_KEYS - 1);
                assert (m_Tree[m_Keys[index]] == m_Keys[index].to_string ());
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Tree.clear ();
        }
        Test.minimized_result (min, "Tree search min time %f ms", min); 
        Test.maximized_result (min, "Tree search max time %f ms", max); 
    }

    public void
    test_tree_benchmark_parse ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            Test.timer_start ();
            string prev = null;
            foreach (string data in m_Tree)
            {
                if (prev != null)
                {
                    assert (prev.to_int () < data.to_int ());
                }
                prev = data;
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            m_Tree.clear ();
        }
        Test.minimized_result (min, "Tree parse min time %f ms", min); 
        Test.maximized_result (min, "Tree parse max time %f ms", max); 
    }

    public void
    test_tree_benchmark_unset ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            }
            Test.timer_start ();
            for (int cpt = 0; cpt < NB_KEYS; ++cpt)
            {
                m_Tree.unset (m_Keys[cpt]);
                assert (m_Tree[m_Keys[cpt]] == null);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Tree unset min time %f ms", min); 
        Test.maximized_result (min, "Tree unset max time %f ms", max); 
    }

    public void
    test_tree_dot ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt]] = m_Keys[cpt].to_string ();
            try
            {
                FileUtils.set_contents ("test-tree-set-%i.dot".printf(cpt), m_Tree.to_dot ());
                Process.spawn_command_line_sync ("dot -Tpng test-tree-set-%i.dot -otest-tree-set-%i.png".printf (cpt, cpt));
            }
            catch (GLib.Error err)
            {
                assert (false);
            }
        }
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree.unset (m_Keys[cpt]);
            try
            {
                FileUtils.set_contents ("test-tree-unset-%i.dot".printf(cpt), m_Tree.to_dot ());
                Process.spawn_command_line_sync ("dot -Tpng test-tree-unset-%i.dot -otest-tree-unset-%i.png".printf (cpt, cpt));
            }
            catch (GLib.Error err)
            {
                assert (false);
            }
        }
    }
}

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
    const int NB_KEYS = 26;

    private Tree<string, string> m_Tree;
    private uint32[] m_Keys;

    public TestTree ()
    {
        base ("tree");

        add_test ("set", test_tree_set);
        add_test ("unset", test_tree_unset);
        add_test ("parse", test_tree_parse);
        //add_test ("dot", test_tree_dot);
    }

    private static string
    data_to_string (string inData)
    {
        return "%c".printf((char)inData.to_int());
    }

    public override void
    set_up ()
    {
        m_Tree = new Tree<string, string> ((GLib.CompareFunc)GLib.strcmp,
                                           (Tree.ToStringFunc)data_to_string);
        m_Keys = new uint32[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int_range ('A', 'Z');
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
            m_Tree[m_Keys[cpt].to_string ()] = m_Keys[cpt].to_string ();
        }
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Tree[m_Keys[cpt].to_string ()] == m_Keys[cpt].to_string ());
        }
    }

    public void
    test_tree_unset ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt].to_string ()] = m_Keys[cpt].to_string ();
        }
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree.unset (m_Keys[cpt].to_string ());
            assert (m_Tree[m_Keys[cpt].to_string ()] == null);
        }
    }

    public void
    test_tree_dot ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            message ("set %s", data_to_string (m_Keys[cpt].to_string ()));
            m_Tree[m_Keys[cpt].to_string ()] = m_Keys[cpt].to_string ();
            try
            {
                FileUtils.set_contents ("test-tree-set-%i.dot".printf(cpt), m_Tree.to_dot ());
                Process.spawn_command_line_sync ("dot -Tsvg test-tree-set-%i.dot -otest-tree-set-%i.svg".printf (cpt, cpt));
            }
            catch (GLib.Error err)
            {
                assert (false);
            }
        }
        message ("unset");
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            message ("unset %s", data_to_string (m_Keys[cpt].to_string ()));
            m_Tree.unset (m_Keys[cpt].to_string ());
            try
            {
                FileUtils.set_contents ("test-tree-unset-%i.dot".printf(cpt), m_Tree.to_dot ());
                Process.spawn_command_line_sync ("dot -Tsvg test-tree-unset-%i.dot -otest-tree-unset-%i.svg".printf (cpt, cpt));
            }
            catch (GLib.Error err)
            {
                assert (false);
            }
        }
    }

    public void
    test_tree_parse ()
    {
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt].to_string ()] = m_Keys[cpt].to_string ();
        }
        string prev = null;
        foreach (string data in m_Tree)
        {
            if (prev != null)
            {
                assert (prev.to_int () < data.to_int ());
            }
            prev = data;
        }
    }
}

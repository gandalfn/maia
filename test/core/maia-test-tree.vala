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
    const int NB_KEYS = 200;

    private Tree<string, string> m_Tree;
    private uint32[] m_Keys;

    public TestTree ()
    {
        base ("tree");

        add_test ("get", test_tree_get);
    }

    public override void
    set_up ()
    {
        m_Tree = new Tree<string, string> ((GLib.CompareFunc)GLib.strcmp);
        m_Keys = new uint32[NB_KEYS];
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Keys[cpt] = Test.rand_int ();
        }
    }

    public override void
    tear_down ()
    {
        m_Tree = null;
    }

    public void
    test_tree_get ()
    {
        Vala.HashMap <string, string> hash = new Vala.HashMap <string, string> (GLib.str_hash, GLib.str_equal);
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            hash[m_Keys[cpt].to_string ()] = m_Keys[cpt].to_string ();
        }
        Test.timer_start ();
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (hash[m_Keys[cpt].to_string ()] == m_Keys[cpt].to_string ());
        }
        message ("hash %s s", (Test.timer_elapsed () * 1000).to_string ());

        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            m_Tree[m_Keys[cpt].to_string ()] = m_Keys[cpt].to_string ();
        }
        Test.timer_start ();
        for (int cpt = 0; cpt < NB_KEYS; ++cpt)
        {
            assert (m_Tree[m_Keys[cpt].to_string ()] == m_Keys[cpt].to_string ());
        }
        message ("tree %s s", (Test.timer_elapsed () * 1000).to_string ());
    }
}

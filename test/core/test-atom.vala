/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-atom.vala
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

public class Maia.TestAtom : Maia.TestCase
{
    const int NB_STRS = 1000;

    private string[] m_Strs;
    private uint32[] m_Atoms;

    public TestAtom ()
    {
        base ("atom");

        add_test ("from_string", test_from_string);
        add_test ("to_string", test_to_string);

        m_Strs = new string [NB_STRS];
        m_Atoms = new uint32 [NB_STRS];
        for (int cpt = 0; cpt < NB_STRS; ++cpt)
        {
            m_Strs[cpt] = rand_string (Test.rand_int_range (2, 20));
        }
    }

    public void
    test_from_string ()
    {
        double min = double.MAX, max = 0;
        for (int cpt = 0; cpt < NB_STRS; ++cpt)
        {
            Test.timer_start ();
            m_Atoms[cpt] = Maia.Atom.from_string (m_Strs[cpt]);
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
            assert (m_Atoms[cpt] != 0);
        }
        if (Test.perf())
        {
            Test.minimized_result (min, "Atom set min time %f ms", min);
            Test.maximized_result (min, "Atom set max time %f ms", max);
        }
    }

    public void
    test_to_string ()
    {
        for (int cpt = 0; cpt < NB_STRS; ++cpt)
        {
            assert (Maia.Atom.to_string (m_Atoms[cpt]) == m_Strs[cpt]);
        }
    }
}
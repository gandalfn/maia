/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-case.vala
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

public abstract class Maia.TestCase : GLib.Object
{
    // types
    public delegate void TestMethod ();

    private class Adaptor
    {
        // properties
        private string m_Name;
        private unowned TestMethod m_Test;
        private TestCase m_TestCase;

        // accessors
        public string name {
            get {
                return m_Name;

            }
        }

        // methods
        public Adaptor (string inName, TestMethod inTest, TestCase inTestCase)
        {
            m_Name = inName;
            m_Test = inTest;
            m_TestCase = inTestCase;
        }

        public void
        set_up (void* inFixture)
        {
            m_TestCase.set_up ();
        }

        public void
        run (void* inFixture)
        {
            m_Test ();
        }

        public void
        tear_down (void* inFixture)
        {
            m_TestCase.tear_down ();
        }
    }

    // properties
    private Adaptor[]      m_Adaptors = new Adaptor[0];
    private GLib.TestSuite m_Suite;

    // accessors
    public GLib.TestSuite suite {
        get {
            return m_Suite;
        }
    }

    // static methods
    public static string
    rand_string (int inLength)
    {
        StringBuilder name = new StringBuilder ();

        string letters[2];
        letters[0] = "bcdfghjklmnpqrstvwxyz";
        letters[1] = "aeiouy";
        int letterlen[2];
        letterlen[0] = letters[0].length;
        letterlen[1] = letters[1].length;

        for (int i = 0; i < inLength; ++i)
        {
            name.append_c (letters[i%2][Random.next_int()%letterlen[i%2]]);
        }
        return name.str;
    }

    // methods
    public TestCase (string inName)
    {
        m_Suite = new GLib.TestSuite (inName);
    }

    public void
    add_test (string inName, TestMethod inTest)
    {
        Adaptor adaptor = new Adaptor (inName, inTest, this);
        m_Adaptors += adaptor;

        m_Suite.add (new GLib.TestCase (adaptor.name,
                                        adaptor.set_up,
                                        adaptor.run,
                                        adaptor.tear_down ));
    }

    public virtual void
    set_up ()
    {
    }

    public virtual void
    tear_down ()
    {
    }
}
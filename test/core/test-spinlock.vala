/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-spinlock.vala
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

public class Maia.TestSpinLock : Maia.TestCase
{
    const int NB_STRS = 1000;

    private Maia.SpinLock m_SpinLock;

    public TestSpinLock ()
    {
        base ("spinlock");

        add_test ("lock", test_lock);
    }

    public override void
    set_up ()
    {
        m_SpinLock = SpinLock ();
    }

    public override void
    tear_down ()
    {
    }

    public void
    test_lock ()
    {
        int i = 0;
        m_SpinLock.lock ();

        try
        {
            unowned GLib.Thread<void*> id = GLib.Thread.create<void*> (() => {
                i++;
                m_SpinLock.unlock ();
                return null;
            }, true);

            m_SpinLock.lock ();
            assert (i != 0);
            id.join ();
        }
        catch (GLib.ThreadError err)
        {
            Test.message ("error on create thread %s", err.message);
        }
    }
}

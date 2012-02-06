/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-spinlock.vala
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

public class Maia.TestSpinLock : Maia.TestCase
{
    const int NB_STRS = 1000;

    private Maia.SpinLock m_SpinLock;

    public TestSpinLock ()
    {
        base ("spinlock");

        add_test ("lock", test_lock);
        add_test ("trylock", test_try_lock);
        add_test ("lockable", test_is_lockable);
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
        m_SpinLock.lock ();

        try
        {
            unowned GLib.Thread<void*> id = GLib.Thread.create<void*> (() => {
                m_SpinLock.unlock ();
                return null;
            }, true);

            id.join ();
        }
        catch (GLib.ThreadError err)
        {
            Test.message ("error on create thread %s", err.message);
        }
    }

    public void
    test_try_lock ()
    {
        assert (m_SpinLock.try_lock ());
        assert (!m_SpinLock.try_lock ());
    }

    public void
    test_is_lockable ()
    {
        assert (m_SpinLock.is_lockable ());
        m_SpinLock.lock ();
        assert (!m_SpinLock.is_lockable ());
    }
}
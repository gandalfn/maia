/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-any.vala
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

public class Maia.TestAny : Maia.TestCase
{
    public class FooDelegateDual : FooAnyDual
    {
        protected override void
        delegate_construct ()
        {
            delegate_dual_constructed = true;
        }
    }

    public class FooDelegate : FooAny
    {
        protected override void
        delegate_construct ()
        {
            delegate_constructed = true;
        }
    }

    public class FooAnyDual : FooAny
    {
        public bool delegate_dual_constructed = false;

        public FooAnyDual ()
        {
        }
    }

    public class FooAny : Maia.Any
    {
        public bool delegate_constructed = false;

        public FooAny ()
        {
        }
    }

    public TestAny ()
    {
        base ("any");

        add_test ("delegate", test_any_delegate);
        add_test ("undelegate", test_any_undelegate);
        add_test ("delegate-construct", test_any_delegate_construct);
        add_test ("delegate-dual", test_any_dual_delegate);
        add_test ("lock-unlock", test_any_lock_unlock);
    }

    public override void
    set_up ()
    {
        Maia.Any.delegate (typeof (FooAny), typeof (FooDelegate));
        Maia.Any.delegate (typeof (FooAnyDual), typeof (FooDelegateDual));
    }

    public override void
    tear_down ()
    {
        Maia.Any.undelegate (typeof (FooAny));
        Maia.Any.undelegate (typeof (FooAnyDual));
    }

    public void
    test_any_delegate ()
    {
        FooAny foo = new FooAny ();
        assert (foo is FooDelegate);
    }

    public void
    test_any_undelegate ()
    {
        Maia.Any.undelegate (typeof (FooAny));
        FooAny foo = new FooAny ();
        assert (!(foo is FooDelegate));
    }

    public void
    test_any_dual_delegate ()
    {
        FooAnyDual foo = new FooAnyDual ();
        assert (foo is FooDelegateDual);
        assert (foo.delegate_dual_constructed);
        assert (!foo.delegate_constructed);
    }

    public void
    test_any_delegate_construct ()
    {
        FooAny foo = new FooAny ();
        assert (foo is FooDelegate);

        assert (foo.delegate_constructed);
    }

    public void
    test_any_lock_unlock ()
    {
        FooAny foo = new FooAny ();
        int i = 0;
        foo.lock ();

        try
        {
            unowned GLib.Thread<void*> id = GLib.Thread.create<void*> (() => {
                i++;
                foo.unlock ();
                return null;
            }, true);

            foo.lock ();
            assert (i != 0);
            foo.unlock ();
            id.join ();
        }
        catch (GLib.ThreadError err)
        {
            Test.message ("error on create thread %s", err.message);
        }
    }
}

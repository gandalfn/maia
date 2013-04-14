/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-object.vala
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

public class Maia.TestObject : Maia.TestCase
{
    const int NB_OBJECTS = 1000;

    public class TestFoo : Maia.Object
    {
        public TestFoo (uint32 inId)
        {
            GLib.Object (id: inId);
        }

        public override bool
        can_append_child (Object inChild)
        {
            return inChild is TestFoo;
        }

        public override int
        compare (Object inOther)
        {
            return (int)(id - inOther.id);
        }
    }

    public class TestFoo2 : Maia.Object
    {
        public string name;

        public TestFoo2 (uint32 inId, string inName)
        {
            GLib.Object (id: inId);
            name = inName;
        }

        public override int
        compare (Object inOther)
        {
            return GLib.strcmp (name, (inOther as TestFoo2).name);
        }
    }

    public TestObject ()
    {
        base ("object");

        add_test ("create", test_object_create);
        add_test ("id", test_object_id);
        add_test ("parent", test_object_parent);
        add_test ("add-child", test_object_add_child);
        add_test ("remove-child", test_object_remove_child);
        add_test ("first-last-child", test_object_first_last_child);
        add_test ("can-append-child", test_object_can_append_child);
        add_test ("child-sort", test_object_sort_child);
        add_test ("child-reorder", test_object_child_reorder);
        add_test ("compare", test_object_compare);

        if (Test.perf())
        {
            add_test ("benchmark-add", test_object_benchmark_add);
            add_test ("benchmark-reorder", test_object_benchmark_reorder);
        }
    }

    public void
    test_object_create ()
    {
        TestFoo foo = new TestFoo(34);

        assert (foo != null);
    }

    public void
    test_object_id ()
    {
        TestFoo foo = new TestFoo(34);

        assert (foo.id == 34);
        foo.id = 12;
        assert (foo.id == 12);
    }

    public void
    test_object_parent ()
    {
        TestFoo foo = new TestFoo(34);
        TestFoo parent = new TestFoo (1);

        assert (foo.parent == null);
        assert (parent.parent == null);
        foo.parent = parent;
        assert (foo.parent == parent);
        foo.parent = null;
        assert (foo.parent == null);
    }

    public void
    test_object_add_child ()
    {
        TestFoo parent = new TestFoo (1);

        for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
        {
            TestFoo foo = new TestFoo (cpt + 2);
            parent.add (foo);
            assert (foo in parent);
        }

        int nb = 0;
        foreach (unowned Object child in parent)
        {
            nb++;
            assert (child.parent == parent);
            assert (child.ref_count == 1);
        }

        assert (nb == NB_OBJECTS);
    }

    public void
    test_object_remove_child ()
    {
        TestFoo parent = new TestFoo (1);
        unowned TestFoo child_to_remove = null;
        int pos = Test.rand_int_range (0, NB_OBJECTS);

        for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
        {
            TestFoo foo = new TestFoo (Test.rand_int_range (0, NB_OBJECTS));
            parent.add (foo);
            if (pos == cpt)
            {
                child_to_remove = foo;
            }
        }

        child_to_remove.parent = null;

        int nb = 0;
        foreach (unowned Object child in parent)
        {
            nb++;
            assert ((ulong)child != (ulong)child_to_remove);
            assert (child.ref_count == 1);
        }

        assert (nb == NB_OBJECTS - 1);
    }

    public void
    test_object_first_last_child ()
    {
        TestFoo parent = new TestFoo (1);
        assert (parent.first () == null);
        assert (parent.last () == null);

        TestFoo first = new TestFoo (1);
        first.parent = parent;
        assert (parent.first () == first);
        assert (parent.last () == first);

        TestFoo middle = new TestFoo (2);
        middle.parent = parent;
        assert (parent.first () == first);
        assert (parent.last () == middle);

        TestFoo last = new TestFoo (3);
        last.parent = parent;
        assert (parent.first () == first);
        assert (parent.last () == last);
    }

    public void
    test_object_can_append_child ()
    {
        TestFoo parent = new TestFoo (1);
        TestFoo child_ok = new TestFoo (2);
        TestFoo2 child_nok = new TestFoo2 (3, "test-append-child");

        child_ok.parent = parent;
        child_nok.parent = parent;

        int nb = 0;
        foreach (unowned Object child in parent)
        {
            ++nb;
        }

        assert (nb == 1);
        assert (child_ok.parent == parent);
        assert (child_nok.parent == null);
    }

    public void
    test_object_sort_child ()
    {
        TestFoo parent = new TestFoo (1);

        for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
        {
            TestFoo foo = new TestFoo (Test.rand_int_range (0, NB_OBJECTS));
            parent.add (foo);
        }

        unowned Object prev = null;
        foreach (unowned Object child in parent)
        {
            if (prev != null)
            {
                assert (prev.id <= child.id);
            }
            prev = child;
        }
    }

    public void
    test_object_child_reorder ()
    {
        TestFoo parent = new TestFoo (1);
        unowned TestFoo child_to_reorder = null;

        int pos = Test.rand_int_range (0, NB_OBJECTS);
        for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
        {
            TestFoo foo = new TestFoo (Test.rand_int_range (0, NB_OBJECTS));
            parent.add (foo);
            if (pos == cpt)
            {
                child_to_reorder = foo;
            }
        }

        child_to_reorder.id = Test.rand_int_range (0, NB_OBJECTS);
        child_to_reorder.reorder ();

        unowned Object prev = null;
        foreach (unowned Object child in parent)
        {
            if (prev != null)
            {
                assert (prev.id <= child.id);
            }
            prev = child;
        }
    }

    public void
    test_object_compare ()
    {
        TestFoo2 parent = new TestFoo2 (1, "parent");
        TestFoo2 child1 = new TestFoo2 (4, "child1");
        child1.parent = parent;
        TestFoo2 child2 = new TestFoo2 (2, "child2");
        child2.parent = parent;
        TestFoo2 child3 = new TestFoo2 (0, "child3");
        child3.parent = parent;

        unowned Object prev = null;
        foreach (unowned Object child in parent)
        {
            if (prev != null)
            {
                assert ((prev as TestFoo2).name <= (child as TestFoo2).name);
            }
            prev = child;
        }
    }

    public void
    test_object_benchmark_add ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            TestFoo[] childs = {};
            for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
            {
                childs += new TestFoo (Test.rand_int_range (0, NB_OBJECTS));
            }
            TestFoo parent = new TestFoo (1);
            Test.timer_start ();
            foreach (unowned Object child in childs)
            {
                parent.add (child);
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Object add min time %f ms", min);
        Test.maximized_result (min, "Object add max time %f ms", max);
    }

    public void
    test_object_benchmark_reorder ()
    {
        double min = double.MAX, max = 0;
        for (int iter = 0; iter < 100; ++iter)
        {
            TestFoo parent = new TestFoo (1);
            TestFoo[] childs = {};
            for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
            {
                TestFoo child = new TestFoo (Test.rand_int_range (0, NB_OBJECTS));
                childs += child;
                parent.add (child);
            }
            Test.timer_start ();
            foreach (unowned Object child in childs)
            {
                child.id = Test.rand_int_range (0, NB_OBJECTS);
                child.reorder ();
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);

            unowned Object prev = null;
            foreach (unowned Object child in parent)
            {
                if (prev != null)
                {
                    assert (prev.id <= child.id);
                }
                prev = child;
            }
        }
        Test.minimized_result (min, "Object add min time %f ms", min);
        Test.maximized_result (min, "Object add max time %f ms", max);
    }
}

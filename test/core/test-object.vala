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

    public class TestFoo : Maia.Core.Object
    {
        public string test_property { get; set; default = null; }

        public TestFoo (uint32 inId)
        {
            GLib.Object (id: inId);
        }

        public override bool
        can_append_child (Core.Object inChild)
        {
            return inChild is TestFoo;
        }

        public override int
        compare (Core.Object inOther)
        {
            return (int)(id - inOther.id);
        }
    }

    public class TestFoo2 : Maia.Core.Object
    {
        public string test_property_other { get; set; default = null; }

        public string name;

        public TestFoo2 (uint32 inId, string inName)
        {
            GLib.Object (id: inId);
            name = inName;
        }

        public override int
        compare (Core.Object inOther)
        {
            return GLib.strcmp (name, (inOther as TestFoo2).name);
        }
    }

    public class TestFoo3 : Maia.Core.Object
    {
        public string test_property { get; set; default = null; }

        public TestFoo3 (uint32 inId)
        {
            GLib.Object (id: inId);
        }

        public override bool
        can_append_child (Core.Object inChild)
        {
            return inChild is TestFoo || inChild is TestFoo3;
        }

        public override int
        compare (Core.Object inOther)
        {
            return (int)(id - inOther.id);
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
        add_test ("clear-childs", test_object_clear_childs);
        add_test ("find", test_object_find);
        add_test ("find-by-type", test_object_find_by_type);
        add_test ("plug-property", test_object_plug_property);
        add_test ("plug-property-lock", test_object_plug_property_lock);

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
        foreach (unowned Core.Object child in parent)
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
        foreach (unowned Core.Object child in parent)
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
        foreach (unowned Core.Object child in parent)
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

        unowned Core.Object prev = null;
        foreach (unowned Core.Object child in parent)
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

        for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
        {
            TestFoo foo = new TestFoo (Test.rand_int_range (0, NB_OBJECTS / 100));
            parent.add (foo);
        }

        for (int cpt = 0; cpt < NB_OBJECTS; ++cpt)
        {
            int pos = Test.rand_int_range (0, NB_OBJECTS);
            int nb = 0;
            foreach (unowned Core.Object child in parent)
            {
                if (nb == pos)
                {
                    child_to_reorder = child as TestFoo;
                    break;
                }
                nb++;
            }

            child_to_reorder.id = Test.rand_int_range (0, NB_OBJECTS / 100);
            child_to_reorder.reorder ();
        }

        unowned Core.Object prev = null;
        foreach (unowned Core.Object child in parent)
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

        unowned Core.Object prev = null;
        foreach (unowned Core.Object child in parent)
        {
            if (prev != null)
            {
                assert ((prev as TestFoo2).name <= (child as TestFoo2).name);
            }
            prev = child;
        }
    }

    public void
    test_object_clear_childs ()
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

        parent.clear_childs ();
        assert (parent.first () == null);
        assert (parent.last () == null);
    }

    public void
    test_object_find ()
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

        assert (parent.find (1) == first);
        assert (parent.find (2) == middle);
        assert (parent.find (3) == last);
    }

    public void
    test_object_find_by_type ()
    {
        TestFoo3 parent = new TestFoo3 (1);
        assert (parent.first () == null);
        assert (parent.last () == null);

        TestFoo first = new TestFoo (1);
        first.parent = parent;
        assert (parent.first () == first);
        assert (parent.last () == first);

        TestFoo3 middle = new TestFoo3 (2);
        middle.parent = parent;
        assert (parent.first () == first);
        assert (parent.last () == middle);

        TestFoo last = new TestFoo (3);
        last.parent = parent;
        assert (parent.first () == first);
        assert (parent.last () == last);

        Maia.Core.List<unowned TestFoo?> list = parent.find_by_type<TestFoo> ();
        assert (list.length == 2);
        assert (list.first () == first);
        assert (list.last () == last);

        Maia.Core.List<unowned TestFoo3?> list2 = parent.find_by_type<TestFoo3> ();
        assert (list2.length == 1);
        assert (list2.first () == middle);
    }

    public void
    test_object_plug_property ()
    {
        TestFoo object1 = new TestFoo (1);
        TestFoo2 object2 = new TestFoo2 (2, "object2");

        object1.test_property = "test-init";
        object1.plug_property ("test-property", object2, "test-property-other");
        assert (object2.test_property_other == "test-init");

        object1.test_property = "test-set";
        assert (object2.test_property_other == "test-set");

        object1.unplug_property ("test-property", object2, "test-property-other");
        object1.test_property = "test-unplug";
        assert (object2.test_property_other == "test-set");
    }

    public void
    test_object_plug_property_lock ()
    {
        TestFoo object1 = new TestFoo (1);
        TestFoo2 object2 = new TestFoo2 (2, "object2");

        object1.test_property = "test-init";
        object1.plug_property ("test-property", object2, "test-property-other");
        assert (object2.test_property_other == "test-init");

        object1.lock_property ("test-property", object2, "test-property-other");
        object1.test_property = "test-lock";
        assert (object2.test_property_other == "test-init");

        object1.unlock_property ("test-property", object2, "test-property-other");
        object1.test_property = "test-unlock";
        assert (object2.test_property_other == "test-unlock");

        object1.unplug_property ("test-property", object2, "test-property-other");
        object1.test_property = "test-unplug";
        assert (object2.test_property_other == "test-unlock");
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
            foreach (unowned Core.Object child in childs)
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
            foreach (unowned Core.Object child in childs)
            {
                child.id = Test.rand_int_range (0, NB_OBJECTS);
                child.reorder ();
            }
            double elapsed = Test.timer_elapsed () * 1000;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);

            unowned Core.Object prev = null;
            foreach (unowned Core.Object child in parent)
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

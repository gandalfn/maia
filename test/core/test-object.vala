/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-object.vala
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

public class Maia.FooDelegate : Maia.Object
{
    public int
    f ()
    {
        return 1;
    }
}

public class Maia.FooDelegate1 : Maia.Object
{
}

public class Maia.FooDelegate2 : Maia.Object
{
}

public class Maia.FooDelegate3 : Maia.Object
{
}

public class Maia.FooDelegate4 : Maia.Object
{
}

public class Maia.FooDelegate5 : Maia.Object
{
}

public class Maia.FooObject : Maia.Object
{
    class construct
    {
        delegate<FooObject> (typeof (FooDelegate));
        delegate<FooObject> (typeof (FooDelegate1));
        delegate<FooObject> (typeof (FooDelegate2));
        delegate<FooObject> (typeof (FooDelegate3));
        delegate<FooObject> (typeof (FooDelegate4));
        delegate<FooObject> (typeof (FooDelegate5));
    }

    public int
    f ()
    {
        return delegate_cast<FooDelegate> ().f ();
    }
}

public class Maia.PooObject : Maia.Object
{
}

public class Maia.TooObject : Maia.Object
{
}

public class Maia.TestObject : Maia.TestCase
{
    const long n = 200000000;

    public TestObject ()
    {
        base ("object");

        add_test ("create", test_object_create);
        add_test ("delegate", test_object_delegate);
        add_test ("parent", test_object_parent);
        add_test ("identified", test_object_identified);
        add_test ("parse", test_object_parse);
    }

    public override void
    set_up ()
    {
        
    }

    public void
    test_object_create ()
    {
        Object foo = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("foo")) as Object;

        Test.message ("name = %s", Atom.to_string (foo.id));
        assert (foo is FooObject);
        assert (foo.id == Atom.from_string ("foo"));
        assert (foo.delegate_cast<FooDelegate> () != null); 
        (foo as FooObject).f ();
    }

    public void
    test_object_delegate ()
    {
        FooObject foo = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("foo")) as FooObject;

        Test.timer_start ();
        for (long i = 0; i < n; ++i)
        {
            foo.f ();
        }
        Test.message ("delegate: %i", (int)(Test.timer_elapsed () * 1000));

        FooDelegate delegate_foo = foo.delegate_cast<FooDelegate> ();
        assert (foo.id == Atom.from_string ("foo"));

        Test.timer_start ();
        for (long i = 0; i < n; ++i)
        {
            delegate_foo.f ();
        }
        Test.message ("delegate: %i", (int)(Test.timer_elapsed () * 1000));
    }

    public void
    test_object_parent ()
    {
        Object parent = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("parent")) as Object;

        assert (parent is FooObject);
        assert (parent.id == Atom.from_string ("parent"));

        Object foo1 = GLib.Object.new (typeof (FooObject), parent: parent) as Object;

        assert (foo1 is FooObject);

        Object foo2 = GLib.Object.new (typeof (FooObject), parent: parent) as Object;

        assert (foo2 is FooObject);

        assert (parent.childs.nb_items == 2);
    }

    public void
    test_object_identified ()
    {
        Object parent = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("parent")) as Object;

        assert (parent is FooObject);
        assert (parent.id == Atom.from_string ("parent"));

        Object foo1 = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("foo"), parent: parent) as Object;

        assert (foo1 is FooObject);
        assert (foo1.id == Atom.from_string ("foo"));

        Object foo2 = GLib.Object.new (typeof (PooObject), id: Atom.from_string ("too"), parent: parent) as Object;

        assert (foo2 is PooObject);
        assert (foo2.id == Atom.from_string ("too"));

        Object foo3 = GLib.Object.new (typeof (TooObject), parent: parent) as Object;

        assert (foo3 is TooObject);

        assert (parent.childs.nb_items == 3);
        assert ("foo" in parent);
        assert ("too" in parent);
        assert (!("poo" in parent));
    }

    public void
    test_object_parse ()
    {
        Object parent = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("parent")) as Object;

        assert (parent is FooObject);
        assert (parent.id == Atom.from_string ("parent"));

        Object foo1 = GLib.Object.new (typeof (FooObject), id: Atom.from_string ("foo"), parent: parent) as Object;

        assert (foo1 is FooObject);

        Object foo2 = GLib.Object.new (typeof (PooObject), id: Atom.from_string ("poo"), parent: parent) as Object;

        assert (foo2 is PooObject);

        Object foo3 = GLib.Object.new (typeof (TooObject), id: Atom.from_string ("too"), parent: parent) as Object;

        assert (foo3 is TooObject);

        assert (parent.childs.nb_items == 3);

        bool found_foo = false,
             found_poo = false,
             found_too = false;
        foreach (Object object in parent.childs)
        {
            switch (Atom.to_string (object.id))
            {
                case "foo":
                    found_foo = true;
                    break;
                case "poo":
                    found_poo = true;
                    break;
                case "too":
                    found_too = true;
                    break;
                default:
                    assert (false);
                    break;
            }
        }
        assert (found_foo);
        assert (found_poo);
        assert (found_too);
    }
}

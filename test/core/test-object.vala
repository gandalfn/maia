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
    public override GLib.Type object_type {
        get {
            return typeof (FooDelegate);
        }
    }

    public FooDelegate.newv (va_list inArgs)
    {
        constructor (inArgs);
    }

    public int
    f ()
    {
        return 1;
    }
}

public class Maia.FooDelegate1 : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (FooDelegate1);
        }
    }

    public FooDelegate1.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
}

public class Maia.FooDelegate2 : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (FooDelegate2);
        }
    }

    public FooDelegate2.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
}

public class Maia.FooDelegate3 : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (FooDelegate3);
        }
    }

    public FooDelegate3.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
}

public class Maia.FooDelegate4 : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (FooDelegate4);
        }
    }

    public FooDelegate4.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
}

public class Maia.FooDelegate5 : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (FooDelegate5);
        }
    }

    public FooDelegate5.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
}

public class Maia.FooObject : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (FooObject);
        }
    }

    class construct
    {
        delegate<FooObject> (typeof (FooDelegate));
        delegate<FooObject> (typeof (FooDelegate1));
        delegate<FooObject> (typeof (FooDelegate2));
        delegate<FooObject> (typeof (FooDelegate3));
        delegate<FooObject> (typeof (FooDelegate4));
        delegate<FooObject> (typeof (FooDelegate5));
    }

    public FooObject.newv (va_list inArgs)
    {
        constructor (inArgs);
    }

    public int
    f ()
    {
        return delegate_cast<FooDelegate> ().f ();
    }
}

public class Maia.PooObject : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (PooObject);
        }
    }

    public PooObject.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
}

public class Maia.TooObject : Maia.Object
{
    public override GLib.Type object_type {
        get {
            return typeof (TooObject);
        }
    }

    public TooObject.newv (va_list inArgs)
    {
        constructor (inArgs);
    }
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
        Object.register_object (typeof (FooObject), (Maia.Object.CreateFunc)FooObject.newv);
        Object.register_object (typeof (PooObject), (Maia.Object.CreateFunc)PooObject.newv);
        Object.register_object (typeof (TooObject), (Maia.Object.CreateFunc)TooObject.newv);
        Object.register_object (typeof (FooDelegate), (Maia.Object.CreateFunc)FooDelegate.newv);
        Object.register_object (typeof (FooDelegate1), (Maia.Object.CreateFunc)FooDelegate1.newv);
        Object.register_object (typeof (FooDelegate2), (Maia.Object.CreateFunc)FooDelegate2.newv);
        Object.register_object (typeof (FooDelegate3), (Maia.Object.CreateFunc)FooDelegate3.newv);
        Object.register_object (typeof (FooDelegate4), (Maia.Object.CreateFunc)FooDelegate4.newv);
        Object.register_object (typeof (FooDelegate5), (Maia.Object.CreateFunc)FooDelegate5.newv);
    }

    public void
    test_object_create ()
    {
        Object foo = Maia.Object.create (typeof (FooObject), id: "foo");

        assert (foo is FooObject);
        assert (foo.id == "foo");
        assert (foo.delegate_cast<FooDelegate> () != null); 
        (foo as FooObject).f ();
    }

    public void
    test_object_delegate ()
    {
        FooObject foo = Maia.Object.create (typeof (FooObject), id: "foo") as FooObject;

        Test.timer_start ();
        for (long i = 0; i < n; ++i)
        {
            foo.f ();
        }
        Test.message ("delegate: %i", (int)(Test.timer_elapsed () * 1000));

        FooDelegate delegate_foo = foo.delegate_cast<FooDelegate> ();
        assert (foo.id == "foo");

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
        Object parent = Maia.Object.create (typeof (FooObject), id: "parent");

        assert (parent is FooObject);
        assert (parent.id == "parent");

        Object foo1 = Maia.Object.create (typeof (FooObject), parent: parent);

        assert (foo1 is FooObject);

        Object foo2 = Maia.Object.create (typeof (FooObject), parent: parent);

        assert (foo2 is FooObject);

        assert (parent.childs.nb_items == 2);
    }

    public void
    test_object_identified ()
    {
        Object parent = Maia.Object.create (typeof (FooObject), id: "parent");

        assert (parent is FooObject);
        assert (parent.id == "parent");

        Object foo1 = Maia.Object.create (typeof (FooObject), id: "foo", parent: parent);

        assert (foo1 is FooObject);
        assert (foo1.id == "foo");

        Object foo2 = Maia.Object.create (typeof (PooObject), id: "too", parent: parent);

        assert (foo2 is PooObject);
        assert (foo2.id == "too");

        Object foo3 = Maia.Object.create (typeof (TooObject), parent: parent);

        assert (foo3 is TooObject);

        assert (parent.childs.nb_items == 3);
        assert ("foo" in parent);
        assert ("too" in parent);
        assert (!("poo" in parent));
    }

    public void
    test_object_parse ()
    {
        Object parent = Maia.Object.create (typeof (FooObject), id: "parent");

        assert (parent is FooObject);
        assert (parent.id == "parent");

        Object foo1 = Maia.Object.create (typeof (FooObject), id: "foo", parent: parent);

        assert (foo1 is FooObject);

        Object foo2 = Maia.Object.create (typeof (PooObject), id: "poo", parent: parent);

        assert (foo2 is PooObject);

        Object foo3 = Maia.Object.create (typeof (TooObject), id: "too", parent: parent);

        assert (foo3 is TooObject);

        assert (parent.childs.nb_items == 3);

        bool found_foo = false,
             found_poo = false,
             found_too = false;
        foreach (Object object in parent.childs)
        {
            switch (object.id)
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

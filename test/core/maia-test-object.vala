/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-test-object.vala
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

public class Maia.FooDelegate : Maia.Delegate
{
    public int
    f ()
    {
        return 1;
    }
}

public class Maia.FooObject : Maia.Object
{
    class construct
    {
        delegate (typeof (FooDelegate));
    }

    public static Object
    create_from_parameter (GLib.Parameter[] inProperties)
    {
        string id = null;
        Object parent = null;
        foreach (GLib.Parameter parameter in inProperties)
        {
            switch (parameter.name)
            {
                case "id":
                    id = (string)parameter.value;
                    break;
                case "parent":
                    parent = (Object)parameter.value;
                    break;
                default:
                    assert (false);
                    break;
            }
        }
        return (Object)new FooObject (id, parent);
    }

    public FooObject (string? inId = null, Object? inParent = null)
    {
        base (inId, inParent);
    }

    public int
    f ()
    {
        return delegate_cast<FooDelegate> ().f ();
    }
}

public class Maia.PooObject : Maia.Object
{
    public static Object
    create_from_parameter (GLib.Parameter[] inProperties)
    {
        string id = null;
        Object parent = null;
        foreach (GLib.Parameter parameter in inProperties)
        {
            switch (parameter.name)
            {
                case "id":
                    id = (string)parameter.value;
                    break;
                case "parent":
                    parent = (Object)parameter.value;
                    break;
                default:
                    assert (false);
                    break;
            }
        }
        return (Object)new PooObject (id, parent);
    }

    public PooObject (string? inId = null, Object? inParent = null)
    {
        base (inId, inParent);
    }
}

public class Maia.TooObject : Maia.Object
{
    public static Object
    create_from_parameter (GLib.Parameter[] inProperties)
    {
        string id = null;
        Object parent = null;
        foreach (GLib.Parameter parameter in inProperties)
        {
            if (parameter.name == "id")
                id = (string)parameter.value;
            if (parameter.name == "parent")
                parent = (Object)parameter.value;
        }
        return (Object)new TooObject (id, parent);
    }

    public TooObject (string? inId = null, Object? inParent = null)
    {
        base (inId, inParent);
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
        Object.register (typeof (FooObject), FooObject.create_from_parameter);
        Object.register (typeof (PooObject), PooObject.create_from_parameter);
        Object.register (typeof (TooObject), TooObject.create_from_parameter);
    }

    public void
    test_object_create ()
    {
        GLib.Parameter[] parameters = new GLib.Parameter[1];
        parameters[0] = { "id", "foo" };
        Object foo = Object.newv (typeof (FooObject), parameters);

        assert (foo is FooObject);
        assert (foo.id == "foo");
        assert (foo.delegate_cast<FooDelegate> () != null); 
        (foo as FooObject).f ();
    }

    public void
    test_object_delegate ()
    {
        GLib.Parameter[] parameters = new GLib.Parameter[1];
        parameters[0] = { "id", "foo" };
        FooObject foo = Object.newv (typeof (FooObject), parameters) as FooObject;

        Test.timer_start ();
        for (long i = 0; i < n; ++i)
        {
            foo.f ();
        }
        Test.message ("delegate: %i", (int)(Test.timer_elapsed () * 1000));

        FooDelegate delegate_foo = foo.delegate_cast<FooDelegate> ();
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
        GLib.Parameter[] parameters = new GLib.Parameter[1];
        parameters[0] = { "id", "parent" };
        Object parent = Object.newv (typeof (FooObject), parameters);

        assert (parent is FooObject);
        assert (parent.id == "parent");

        parameters = new GLib.Parameter[1];
        parameters[0] = { "parent", parent };
        Object foo1 = Object.newv (typeof (FooObject), parameters);

        assert (foo1 is FooObject);

        parameters = new GLib.Parameter[1];
        parameters[0] = { "parent", parent };
        Object foo2 = Object.newv (typeof (FooObject), parameters);

        assert (foo2 is FooObject);

        assert (parent.childs.nb_items == 2);
    }

    public void
    test_object_identified ()
    {
        GLib.Parameter[] parameters = new GLib.Parameter[1];
        parameters[0] = { "id", "parent" };
        Object parent = Object.newv (typeof (FooObject), parameters);

        assert (parent is FooObject);
        assert (parent.id == "parent");

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "foo" };
        parameters[1] = { "parent", parent };
        Object foo1 = Object.newv (typeof (FooObject), parameters);

        assert (foo1 is FooObject);
        assert (foo1.id == "foo");

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "too" };
        parameters[1] = { "parent", parent };
        Object foo2 = Object.newv (typeof (PooObject), parameters);

        assert (foo2 is PooObject);
        assert (foo2.id == "too");

        parameters = new GLib.Parameter[1];
        parameters[0] = { "parent", parent };
        Object foo3 = Object.newv (typeof (TooObject), parameters);

        assert (foo3 is TooObject);

        assert (parent.childs.nb_items == 3);
        assert ("foo" in parent);
        assert ("too" in parent);
        assert (!("poo" in parent));
    }

    public void
    test_object_parse ()
    {
        GLib.Parameter[] parameters = new GLib.Parameter[1];
        parameters[0] = { "id", "parent" };
        Object parent = Object.newv (typeof (FooObject), parameters);

        assert (parent is FooObject);
        assert (parent.id == "parent");

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "foo" };
        parameters[1] = { "parent", parent };
        Object foo1 = Object.newv (typeof (FooObject), parameters);

        assert (foo1 is FooObject);

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "poo" };
        parameters[1] = { "parent", parent };
        Object foo2 = Object.newv (typeof (PooObject), parameters);

        assert (foo2 is PooObject);

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "too" };
        parameters[1] = { "parent", parent };
        Object foo3 = Object.newv (typeof (TooObject), parameters);

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

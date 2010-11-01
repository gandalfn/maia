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

public class Maia.FooObject : Maia.Object
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
        return (Object)new FooObject (id, parent);
    }

    public FooObject (string? inId = null, Object? inParent = null)
    {
        base (inId, inParent);
    }
}

public class Maia.TestObject : Maia.TestCase
{
    public TestObject ()
    {
        base ("object");

        add_test ("create", test_object_create);
        add_test ("parent", test_object_parent);
        add_test ("identified", test_object_identified);
        add_test ("parse", test_object_parse);
    }

    public override void
    set_up ()
    {
        Object.register (typeof (FooObject), FooObject.create_from_parameter);
    }

    public void
    test_object_create ()
    {
        GLib.Parameter[] parameters = new GLib.Parameter[1];
        parameters[0] = { "id", "foo" };
        Object foo = Object.newv (typeof (FooObject), parameters);

        assert (foo is FooObject);
        assert (foo.id == "foo");
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
        parameters[0] = { "id", "foo1" };
        parameters[1] = { "parent", parent };
        Object foo1 = Object.newv (typeof (FooObject), parameters);

        assert (foo1 is FooObject);
        assert (foo1.id == "foo1");

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "foo2" };
        parameters[1] = { "parent", parent };
        Object foo2 = Object.newv (typeof (FooObject), parameters);

        assert (foo2 is FooObject);
        assert (foo2.id == "foo2");

        parameters = new GLib.Parameter[1];
        parameters[0] = { "parent", parent };
        Object foo3 = Object.newv (typeof (FooObject), parameters);

        assert (foo3 is FooObject);

        assert (parent.childs.nb_items == 3);
        assert ("foo1" in parent);
        assert ("foo2" in parent);
        assert (!("foo3" in parent));
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
        parameters[0] = { "id", "foo1" };
        parameters[1] = { "parent", parent };
        Object foo1 = Object.newv (typeof (FooObject), parameters);

        assert (foo1 is FooObject);

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "foo2" };
        parameters[1] = { "parent", parent };
        Object foo2 = Object.newv (typeof (FooObject), parameters);

        assert (foo2 is FooObject);

        parameters = new GLib.Parameter[2];
        parameters[0] = { "id", "foo3" };
        parameters[1] = { "parent", parent };
        Object foo3 = Object.newv (typeof (FooObject), parameters);

        assert (foo3 is FooObject);

        assert (parent.childs.nb_items == 3);

        bool found_foo1 = false,
             found_foo2 = false,
             found_foo3 = false;
        foreach (Object object in parent.childs)
        {
            if (object.id == "foo1")
                found_foo1 = true;
            else if (object.id == "foo2")
                found_foo2 = true;
            else if (object.id == "foo3")
                found_foo3 = true;
        }
        assert (found_foo1);
        assert (found_foo2);
        assert (found_foo3);
    }
}

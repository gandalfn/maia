/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-object.cc
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

#include <maiamm.h>

#include "test-object.h"

using namespace Maia;

class FooNotification : public Maia::Core::Notification
{
    public:
        FooNotification (const Glib::ustring& inName) :
            Glib::ObjectBase ("FooNotification"),
            Maia::Core::Notification (inName),
            value (""),
            count (0)
        {
        }

        static Glib::RefPtr<FooNotification> create (const Glib::ustring& inName)
        {
            return Glib::RefPtr<FooNotification> (new FooNotification (inName));
        }

        Glib::ustring value;
        int count;
};

class Foo : public Maia::Core::Object
{
    public:
        Foo (const Glib::ustring& inName) :
            Glib::ObjectBase ("Foo")
        {
            set_id (Glib::Quark (inName));

            g_assert (notifications ());
            notifications ()->add (Maia::Core::Notification::create ("test-object-notification"));

            g_assert (notifications ()->get ("test-object-notification"));
            notifications ()->get ("test-object-notification")->add_observer (this, &Foo::on_object_notification);
        }

        static Glib::RefPtr<Foo> create (const Glib::ustring& inName)
        {
            return Glib::RefPtr<Foo> (new Foo (inName));
        }

        void
        on_object_notification (const Glib::RefPtr<Maia::Core::Notification>& inpNotification)
        {
            last_notification = inpNotification->get_name ();
        }

        Glib::ustring last_notification;
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestObject::TestObject () :
    TestCase ("object")
{
    add_test ("create", sigc::mem_fun (this, &TestObject::test_create));
    add_test ("notifications",  sigc::mem_fun (this, &TestObject::test_notifications));
    add_test ("append-notifications",  sigc::mem_fun (this, &TestObject::test_append_notifications));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestObject::~TestObject ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestObject::set_up ()
{
    notification_value = "";
    notification_count = 0;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestObject::tear_down ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestObject::test_create ()
{
    Glib::RefPtr<Foo> pFoo = Foo::create ("foo");
    g_assert (pFoo);
    g_assert (pFoo->get_id () == Glib::Quark ("foo"));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestObject::on_test_notification (const Glib::RefPtr<Maia::Core::Notification>& inpNotification)
{
    Glib::RefPtr<FooNotification> pNotification = Glib::RefPtr<FooNotification>::cast_dynamic (inpNotification);

    g_assert (pNotification);

    notification_value = pNotification->value;
    notification_count = pNotification->count;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestObject::test_notifications ()
{
    Glib::RefPtr<Foo> pFoo = Foo::create ("foo");
    g_assert (pFoo);

    g_assert (pFoo->notifications ());
    pFoo->notifications ()->add (FooNotification::create ("test-notification"));
    g_assert (pFoo->notifications ()->get ("test-notification"));

    pFoo->notifications ()->get ("test-notification")->add_observer (sigc::mem_fun (this, &TestObject::on_test_notification));

    Glib::RefPtr<FooNotification> pNotification = Glib::RefPtr<FooNotification>::cast_dynamic (pFoo->notifications ()->get ("test-notification"));
    g_assert (pNotification);

    pNotification->value = "test";
    pNotification->count = 1;
    pNotification->post ();

    g_assert (notification_value == "test");
    g_assert (notification_count == 1);

    g_assert (pFoo->notifications ()->get ("test-object-notification"));
    pFoo->notifications ()->get ("test-object-notification")->post ();

    g_assert (pFoo->last_notification == "test-object-notification");
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestObject::test_append_notifications ()
{
    Glib::RefPtr<Foo> pFoo = Foo::create ("foo");
    g_assert (pFoo);

    g_assert (pFoo->notifications ());
    pFoo->notifications ()->add (FooNotification::create ("test-notification"));
    g_assert (pFoo->notifications ()->get ("test-notification"));

    pFoo->notifications ()->get ("test-notification")->add_observer (sigc::mem_fun (this, &TestObject::on_test_notification));

    Glib::RefPtr<Foo> pFoo2 = Foo::create ("foo");
    g_assert (pFoo2);

    g_assert (pFoo2->notifications ());
    pFoo2->notifications ()->add (FooNotification::create ("test-notification-append"));
    g_assert (pFoo2->notifications ()->get ("test-notification-append"));

    pFoo2->notifications ()->get ("test-notification-append")->append_observers (pFoo->notifications ()->get ("test-notification"));

    Glib::RefPtr<FooNotification> pNotification = Glib::RefPtr<FooNotification>::cast_dynamic (pFoo2->notifications ()->get ("test-notification-append"));
    g_assert (pNotification);

    pNotification->value = "test-append";
    pNotification->count = 2;
    pNotification->post ();

    g_assert (notification_value == "test-append");
    g_assert (notification_count == 2);
}

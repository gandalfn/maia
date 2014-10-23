/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-notification.vala
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

public class Maia.TestNotification : Maia.TestCase
{
    const int NB_ITERATIONS = 10000;

    private Core.Notifications m_Notifications;
    private Core.Queue<string> m_Received = null;
    private double m_ElapsedNotification = 0;
    private double m_ElapsedNotify = 0;

    public class TestFoo : Maia.Core.Object
    {
        private string m_TestProperty;

        [CCode (notify = false)]
        public string test_property {
            get {
                return m_TestProperty;
            }
            set {
                m_TestProperty = value;
                notifications.post ("test-property");
            }
            default = null;
        }

        public TestFoo (uint32 inId)
        {
            GLib.Object (id: inId);
        }
    }

    public class TestFoo2 : Maia.Core.Object
    {
        public string test_property { get; set; default = null; }

        public TestFoo2 (uint32 inId)
        {
            GLib.Object (id: inId);
        }
    }

    public TestNotification ()
    {
        base ("notification");

        add_test ("add", test_notification_add);
        add_test ("post", test_notification_post);
        add_test ("remove-observer", test_notification_remove_observer);
        add_test ("object", test_notification_object);
        add_test ("append", test_notification_append);
        if (Test.perf())
        {
            add_test ("notification-notify", test_notification_object_vs_notify);
        }
    }

    private void
    on_test_notification (Core.Notification inNotification)
    {
        Test.message (@"received $(inNotification.name)");
        m_Received.push (inNotification.name);
    }

    private void
    on_test_perf_notification (Core.Notification inNotification)
    {
        m_ElapsedNotification = Test.timer_elapsed ();
    }

    private void
    on_test_perf_notify ()
    {
        m_ElapsedNotify = Test.timer_elapsed ();
    }

    internal override void
    set_up ()
    {
        m_Notifications = new Core.Notifications ();
        m_Received = new Core.Queue<string> ();
    }

    internal override void
    tear_down ()
    {
        m_Notifications = null;
        m_Received = null;
    }

    public void
    test_notification_add ()
    {
        m_Notifications.add (new Core.Notification ("test"));
        assert (m_Notifications["test"] != null);


        m_Notifications.remove ("test");
        assert (m_Notifications["test"] == null);
    }

    public void
    test_notification_post ()
    {
        m_Notifications.add (new Core.Notification ("test"));
        assert (m_Notifications["test"] != null);

        m_Notifications["test"].add_object_observer(on_test_notification);
        m_Notifications["test"].post ();

        assert (m_Received.pop () == "test");
    }

    public void
    test_notification_remove_observer ()
    {
        m_Notifications.add (new Core.Notification ("test"));
        assert (m_Notifications["test"] != null);

        m_Notifications["test"].add_object_observer(on_test_notification);
        m_Notifications["test"].post ();

        assert (m_Received.pop () == "test");

        m_Notifications["test"].remove_observer(on_test_notification);
        m_Notifications["test"].post ();

        assert (m_Received.pop () == null);
    }

    public void
    test_notification_object ()
    {
        var foo = new TestFoo (0);
        foo.notifications.add_object_observer ("test-property", on_test_notification);
        foo.test_property = "test-foo";

        assert (m_Received.length == 1);
        assert (m_Received.pop () == "test-property");
    }

    public void
    test_notification_append ()
    {
        m_Notifications.add (new Core.Notification ("test"));
        assert (m_Notifications["test"] != null);
        m_Notifications["test"].add_object_observer(on_test_notification);

        var foo = new TestFoo (0);
        foo.notifications.add_object_observer ("test-property", on_test_notification);
        foo.notifications["test-property"].append_observers (m_Notifications["test"]);
        foo.test_property = "test-foo";

        assert (m_Received.length == 2);
        assert (m_Received.pop () == "test-property");
        assert (m_Received.pop () == "test-property");
    }

    public void
    test_notification_object_vs_notify ()
    {
        var foo = new TestFoo (0);
        var foo2 = new TestFoo2 (0);

        foo.notifications.add_object_observer ("test-property", on_test_perf_notification);
        foo2.notify["test-property"].connect (on_test_perf_notify);

        double elapsed_notification = 0, elapsed_notify = 0;
        double min_notification = double.MAX, max_notification = 0;
        double min_notify = double.MAX, max_notify = 0;

        for (int cpt = 0; cpt < NB_ITERATIONS; ++cpt)
        {
            m_ElapsedNotification = 0;
            Test.timer_start ();
            foo.test_property = "toto";
            elapsed_notification += m_ElapsedNotification;
            min_notification = double.min (m_ElapsedNotification, min_notification);
            max_notification = double.max (m_ElapsedNotification, max_notification);

            m_ElapsedNotify = 0;
            Test.timer_start ();
            foo2.test_property = "toto";
            elapsed_notify += m_ElapsedNotify;
            min_notify = double.min (m_ElapsedNotify, min_notify);
            max_notify = double.max (m_ElapsedNotify, max_notify);
        }

        Test.minimized_result (min_notification, "Notification min time %f ms", min_notification * 1000);
        Test.maximized_result (max_notification, "Notification max time %f ms", max_notification * 1000);
        Test.message ("Notification total time %f ms", elapsed_notification * 1000);

        Test.minimized_result (min_notify, "Notify min time %f ms", min_notify * 1000);
        Test.maximized_result (max_notify, "Notify max time %f ms", max_notify * 1000);
        Test.message ("Notify total time %f ms", elapsed_notify * 1000);
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-notificatio.vala
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

public class FooNotification : Maia.Object
{
    public Maia.Notification1<FooNotification, int> test_notification;
    public signal void test_signal (int inValue);

    public FooNotification ()
    {
        test_notification = new Maia.Notification1<FooNotification, int> (this);
    }
}

public class Maia.TestNotification : Maia.TestCase
{
    private FooNotification foo = null;
    public bool received = false;
    public double elapsed = 0.0;

    public TestNotification ()
    {
        base ("notification");

        add_test ("listen", test_listen);
        add_test ("remove", test_remove);
        add_test ("block", test_block);
        if (Test.perf())
        {
            add_test ("benchmark", test_benchmark_notification);
        }
    }

    public override void
    set_up ()
    {
        foo = new FooNotification ();
        received = false;
    }

    public override void
    tear_down ()
    {
        foo = null;
    }

    private void
    on_notification_callback (FooNotification? inOwner, int inValue)
    {
        Test.message ("Notification received %i", inValue);
        received = true;
    }

    private void
    on_notification_other (FooNotification? inOwner, int inValue)
    {
        Test.message ("Notification other received %i", inValue);
    }

    public void
    test_listen ()
    {
        foo.test_notification.watch (on_notification_callback);
        foo.test_notification.watch (on_notification_callback);
        foo.test_notification.watch (on_notification_other);
        foo.test_notification.send (1);
        assert (received);
    }

    public void
    test_remove ()
    {
        var observer = foo.test_notification.watch (on_notification_callback);
        foo.test_notification.watch (on_notification_other);
        foo.test_notification.send (1);
        assert (received);
        received = false;
        observer.destroy ();
        foo.test_notification.send (1);
        assert (!received);
    }

    public void
    test_block ()
    {
        var observer = foo.test_notification.watch (on_notification_callback);
        foo.test_notification.send (1);
        assert (received);
        received = false;
        observer.block = true;
        foo.test_notification.send (1);
        assert (!received);
        observer.block = false;
        foo.test_notification.send (1);
        assert (received);
    }

    public void
    test_benchmark_notification ()
    {
        double min = double.MAX, max = 0, total = 0;

        foo.test_signal.connect (() => {
            elapsed = Test.timer_elapsed () * 1000;
        });

        foo.test_signal.connect ((i) => {
            int a = i;
            a++;
        });

        for (int cpt = 0; cpt < 200000; ++cpt)
        {
            Test.timer_start ();
            foo.test_signal (1);
            total += elapsed;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Signal min time %f ms", min);
        Test.maximized_result (min, "Signal max time %f ms", max);
        Test.maximized_result (min, "Signal total time %f ms", total);

        min = double.MAX;
        max = 0;
        total = 0;

        foo.test_notification.watch (() => {
            elapsed = Test.timer_elapsed () * 1000;
        });
        foo.test_notification.watch ((o, i) => {
            int a = i;
            a++;
        });
        for (int cpt = 0; cpt < 200000; ++cpt)
        {
            Test.timer_start ();
            foo.test_notification.send (1);
            total += elapsed;
            min = double.min (elapsed, min);
            max = double.max (elapsed, max);
        }
        Test.minimized_result (min, "Notification min time %f ms", min);
        Test.maximized_result (min, "Notification max time %f ms", max);
        Test.maximized_result (min, "Notification total time %f ms", total);
    }
}
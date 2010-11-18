/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-test-notification.vala
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

public class Maia.TestNotification : Maia.TestCase
{
    const int NB_ITERATIONS = 1000000;

    private signal void signal_test (int a, string b);
    private Maia.Notification notification;
    private double signal_elapsed;
    private double notification_elapsed;

    public TestNotification ()
    {
        base ("notification");

        if (Test.perf())
            add_test ("benchmark", test_benchmark_notification);
    }

    public override void
    set_up ()
    {
        notification = new Maia.Notification("test", this);
        notification.watch (new Observer2<void, int, string> (on_notification, this));
        notification_elapsed = 0.0;
        signal_test.connect (on_signal);
        signal_elapsed = 0.0;
    }

    private void
    on_notification (int a, string b)
    {
        notification_elapsed = Test.timer_elapsed () * 1000;
    }

    private void
    on_signal (int a, string b)
    {
        signal_elapsed = Test.timer_elapsed () * 1000;
    }

    public void
    test_benchmark_notification ()
    {
        double min = double.MAX, max = 0, total = 0;
        for (int iter = 0; iter < NB_ITERATIONS; ++iter)
        {
            Test.timer_start ();
            signal_test (12, "test");
            total += signal_elapsed;
            min = double.min (signal_elapsed, min);
            max = double.max (signal_elapsed, max);
        }
        Test.minimized_result (min, "Signal min time %f ms", min); 
        Test.maximized_result (max, "Signal max time %f ms", max);
        Test.maximized_result (total / (double)NB_ITERATIONS, "Signal average time %f ms", total / (double)NB_ITERATIONS);
        Test.maximized_result (total, "Signal global time %f ms", total);

        total = 0;
        min = double.MAX;
        max = 0;
        for (int iter = 0; iter < NB_ITERATIONS; ++iter)
        {
            Test.timer_start ();
            notification.post (new Observer2.Args<void, int, string> (12, "test"));
            total += notification_elapsed;
            min = double.min (notification_elapsed, min);
            max = double.max (notification_elapsed, max);
        }
        Test.minimized_result (min, "Notification min time %f ms", min); 
        Test.maximized_result (max, "Notification max time %f ms", max);
        Test.maximized_result (total / (double)NB_ITERATIONS, "Notification average time %f ms", total / (double)NB_ITERATIONS);
        Test.maximized_result (total, "Notification global time %f ms", total);
    }
}

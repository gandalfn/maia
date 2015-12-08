/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-bus.vala
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

public class Maia.TestEventArgs : Maia.Core.EventArgs
{
    public string name {
        owned get {
            return (string)this["name"].get ();
        }
        set {
            this["name"].set (value);
        }
    }

    public uint32 val {
        get {
            return (uint32)this["val"].get ();
        }
        set {
            this["val"].set (value);
        }
    }

    static construct
    {
        Core.EventArgs.register_protocol (typeof (TestEventArgs),
                                          "Test",
                                          "message Test {"               +
                                          "     required string name;"   +
                                          "     required uint32 val;"    +
                                          "}");
    }

    public TestEventArgs (string inName, uint32 inVal)
    {
        this["name"].set (inName);
        this["val"].set (inVal);
    }

    internal override void
    accumulate (Core.EventArgs inArgs)
        requires (inArgs is TestEventArgs)
    {
        name += "|" + ((TestEventArgs)inArgs).name;
        val += ((TestEventArgs)inArgs).val;

        Test.message ("accumulate name: %s val: %u", name, val);
    }
}

public class Maia.TestBus : Maia.TestCase
{
    private GLib.MainLoop loop;

    public TestBus ()
    {
        base ("bus");

        //add_test ("socket-bus", test_socket_bus);
        add_test ("event-bus",             test_event_bus);
        add_test ("event-bus-multithread", test_event_bus_multithread);
        add_test ("event-bus-reply",       test_event_bus_reply);
        add_test ("event-bus-contention",  test_event_bus_contention);
    }

    public override void
    set_up ()
    {
        loop = new GLib.MainLoop (null);
    }

    public override void
    tear_down ()
    {
        loop = null;
    }

    public void
    test_socket_bus ()
    {
        bool message_client1 = false;
        bool message_client2 = false;
        var bus = new Core.SocketBusService ("service");
        Core.SocketBusConnection client1 = null,
                                 client2 = null;

        GLib.Timeout.add_seconds (1, () => {
            try
            {
                client2 = new Core.SocketBusConnection ("client2", bus.id);
            }
            catch (GLib.Error err)
            {
                Test.message (err.message);
                assert (false);
            }

            client2.notifications["message-received"].add_observer ((n) => {
                unowned Core.BusConnection.MessageReceivedNotification notification = n as Core.BusConnection.MessageReceivedNotification;
                unowned Core.Bus.MessageData message = notification.message as Core.Bus.MessageData;

                if (message != null)
                {
                    message_client1 = true;
                    GLib.Variant data = message.get_data ("(s)");
                    string str;
                    data.get ("(s)", out str);
                    Test.message ("client 2 message received from 0x%x : %s", message.sender, str);

                    data = new GLib.Variant ("(s)", "reply client 2");
                    var reply = new Core.Bus.MessageData (data);
                    reply.destination = client1.id;
                    client2.send_async.begin (reply);
                }
            });

            return false;
        });

        GLib.Timeout.add_seconds (2, () => {
            try
            {
                client1 = new Core.SocketBusConnection ("client1", bus.id);
            }
            catch (GLib.Error err)
            {
                Test.message (err.message);
                assert (false);
            }
            client1.notifications["connected"].add_observer ((n) => {
                var data = new GLib.Variant ("(s)", "test bus message");
                client1.send_async.begin (new Core.Bus.MessageData (data));
            });

            client1.notifications["message-received"].add_observer ((n) => {
                unowned Core.BusConnection.MessageReceivedNotification notification = n as Core.BusConnection.MessageReceivedNotification;
                unowned Core.Bus.MessageData message = notification.message as Core.Bus.MessageData;

                if (message != null)
                {
                    GLib.Variant data = message.get_data ("(s)");
                    string str;
                    data.get ("(s)", out str);
                    Test.message ("client 1 message received from 0x%x : %s", message.sender, str);
                    if (str == "reply client 2")
                    {
                        client1 = null;
                        client2 = null;
                        message_client2 = true;
                    }
                }
            });

            return false;
        });

        GLib.Timeout.add_seconds (5, () => {
            loop.quit ();

            return false;
        });

        loop.run ();

        assert (message_client1);
        assert (message_client2);
    }

    public void
    test_event_bus ()
    {
        bool event_received1 = false;
        bool event_received2 = false;
        Core.Event event = new Core.Event ("test-event-bus", null);

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                Test.message ("TestEventArgs %s %u recv ", event_args.name, event_args.val);
                event_received1 = true;
            }
        });

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                Test.message ("TestEventArgs %s %u recv ", event_args.name, event_args.val);
                event_received2 = true;
            }
        });

        GLib.Timeout.add_seconds (1, () => {
            var event_args = new TestEventArgs ("test event", GLib.Test.rand_int_range (10, 1000));
            Test.message ("TestEventArgs %s %u send", event_args.name, event_args.val);
            event.publish (event_args);

            return false;
        });

        GLib.Timeout.add_seconds (5, () => {
            loop.quit ();

            return false;
        });

        loop.run ();

        assert (event_received1);
        assert (event_received2);
    }

    public void
    test_event_bus_multithread ()
    {
        bool message_main = false;
        bool message_thread = false;
        Core.Event event = new Core.Event ("test-event-bus-multithread", null);

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                Test.message ("TestEventArgs 0x%lx %s %u", (ulong)GLib.Thread.self<void*> (), event_args.name, event_args.val);

                message_main = true;
            }
        });

        new GLib.Thread<void*> (null, () => {
            GLib.MainContext ctx = new GLib.MainContext ();
            ctx.push_thread_default ();
            GLib.MainLoop loop_thread = new GLib.MainLoop (ctx);

            event.subscribe ((args) => {
                if (args is TestEventArgs)
                {
                    unowned TestEventArgs event_args = (TestEventArgs)args;

                    Test.message ("TestEventArgs 0x%lx %s %u", (ulong)GLib.Thread.self<void*> (), event_args.name, event_args.val);

                    message_thread = true;

                    loop_thread.quit ();
                }
            });

            loop_thread.run ();

            return null;
        });

        new GLib.Thread<void*> (null, () => {
            Posix.sleep (3);

            event.publish (new TestEventArgs ("test multithread event", GLib.Test.rand_int_range (10, 1000)));

            return null;
        });

        GLib.Timeout.add_seconds (5, () => {
            loop.quit ();

            return false;
        });

        loop.run ();

        assert (message_main);
        assert (message_thread);
    }

    public void
    test_event_bus_reply ()
    {
        bool message_main = false;
        bool message_thread = false;
        bool have_reply = false;
        Core.Event event = new Core.Event ("test-event-bus-reply", null);

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                event_args.name = "main 0x%lx".printf ((ulong)GLib.Thread.self<void*> ());
                event_args.val++;

                Test.message ("name: %s val: %u", event_args.name, event_args.val);

                message_main = true;
            }
        });

        var thread = new GLib.Thread<void*> (null, () => {
            GLib.MainContext ctx = new GLib.MainContext ();
            ctx.push_thread_default ();
            GLib.MainLoop loop_thread = new GLib.MainLoop (ctx);

            event.subscribe ((args) => {
                if (args is TestEventArgs)
                {
                    unowned TestEventArgs event_args = (TestEventArgs)args;

                    event_args.name = "thread 0x%lx".printf ((ulong)GLib.Thread.self<void*> ());
                    event_args.val++;

                    Test.message ("name: %s val: %u", event_args.name, event_args.val);

                    message_thread = true;
                }
            });

            GLib.Timeout.add_seconds (5, () => {
                loop_thread.quit ();

                return false;
            });


            loop_thread.run ();

            return null;
        });

        GLib.Timeout.add_seconds (2, () => {
            event.publish_with_reply (new TestEventArgs ("test reply event", 0), (arg) => {
                Test.message ("Reply event 0x%lx %s %u", (ulong)GLib.Thread.self<void*> (), ((TestEventArgs)arg).name, ((TestEventArgs)arg).val);
                have_reply = ((TestEventArgs)arg).val == 2;
            });
            return false;
        });

        GLib.Timeout.add_seconds (5, () => {
            loop.quit ();

            return false;
        });

        loop.run ();

        thread.join ();

        assert (message_main);
        assert (message_thread);
        assert (have_reply);
    }

    public void
    test_event_bus_contention ()
    {
        Core.Event[] events = {};
        double min = double.MAX, max = double.MIN;

        for (int cpt = 0; cpt < 2000; ++cpt)
        {
            events += new Core.Event ("test-event-bus-contention", cpt.to_pointer ());
            events[cpt].subscribe ((args) => {
                if (args is TestEventArgs)
                {
                    double elapsed = (Test.timer_elapsed () * 1000);
                    min = double.min (elapsed, min);
                    max = double.max (elapsed, max);
                    unowned TestEventArgs event_args = (TestEventArgs)args;

                    //Test.message ("name: %s val: %u", event_args.name, event_args.val);

                    if (event_args.val == 1999) loop.quit ();
                }
            });
        }

        GLib.Timeout.add_seconds (5, () => {
            Test.timer_start ();
            for (int cpt = 0; cpt < 2000; ++cpt)
            {
                events[cpt].publish (new TestEventArgs (@"$cpt", cpt));
            }
            double elapsed = Test.timer_elapsed () * 1000;
            Test.message ("elapsed: %g", elapsed);
            return false;
        });

        loop.run ();

        Test.minimized_result (min, "Received min time %f ms", min);
        Test.maximized_result (min, "Received max time %f ms", max);
    }
}

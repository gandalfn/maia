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
    private string m_Name;
    private uint32 m_Val;

    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(su)", m_Name, m_Val);
        }
        set {
            if (value != null)
            {
                value.get ("(su)", out m_Name, out m_Val);
            }
        }
    }

    public string name {
        get {
            return m_Name;
        }
        set {
            m_Name = value;
        }
    }

    public uint32 val {
        get {
            return m_Val;
        }
        set {
            m_Val = value;
        }
    }

    public TestEventArgs (string inName, uint32 inVal)
    {
        m_Name = inName;
        m_Val = inVal;
    }

    internal override void
    accumulate (Core.EventArgs inArgs)
        requires (inArgs is TestEventArgs)
    {
        m_Name += "|" + ((TestEventArgs)inArgs).m_Name;
        m_Val += ((TestEventArgs)inArgs).m_Val;

        print ("accumulate name: %s val: %u\n", m_Name, m_Val);
    }
}

public class Maia.TestBus : Maia.TestCase
{
    private GLib.MainLoop loop;

    public TestBus ()
    {
        base ("bus");

        add_test ("socket-bus", test_socket_bus);
        add_test ("event-bus",  test_event_bus);
        add_test ("event-bus-multithread",  test_event_bus_multithread);
        add_test ("event-bus-reply",  test_event_bus_reply);
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
        var bus = new Core.SocketBusService ("service");
        Core.SocketBusConnection client1 = null,
                                 client2 = null;

        GLib.Timeout.add_seconds (5, () => {
            client2 = new Core.SocketBusConnection ("client2", bus.id);

            client2.message_received.connect ((msg) => {
                unowned Core.Bus.MessageData message = msg as Core.Bus.MessageData;

                if (message != null)
                {
                    GLib.Variant data = message.get_data ("(s)");
                    string str;
                    data.get ("(s)", out str);
                    print ("client 2 message received from 0x%x : %s\n", message.sender, str);

                    data = new GLib.Variant ("(s)", "reply client 2");
                    var reply = new Core.Bus.MessageData (data);
                    reply.destination = client1.id;
                    client2.send.begin (reply);
                }
            });

            return false;
        });

        GLib.Timeout.add_seconds (10, () => {
            client1 = new Core.SocketBusConnection ("client1", bus.id);

            client1.connected.connect (() => {
                var data = new GLib.Variant ("(s)", "test bus message");
                client1.send.begin (new Core.Bus.MessageData (data));
            });

            client1.message_received.connect ((msg) => {
                unowned Core.Bus.MessageData message = msg as Core.Bus.MessageData;

                if (message != null)
                {
                    GLib.Variant data = message.get_data ("(s)");
                    string str;
                    data.get ("(s)", out str);
                    print ("client 1 message received from 0x%x : %s\n", message.sender, str);
                    if (str == "reply client 2")
                    {
                        client1 = null;
                        client2 = null;
                    }
                }
            });

            return false;
        });

        loop.run ();
    }

    public void
    test_event_bus ()
    {
        Core.EventBus.default = new Core.EventBus ("test-event-bus");
        Core.Event event = new Core.Event ("test", null);

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                print ("TestEventArgs %s %u\n", event_args.name, event_args.val);
            }
        });

        GLib.Timeout.add_seconds (5, () => {
            event.publish (new TestEventArgs ("test event", GLib.Test.rand_int_range (10, 1000)));

            return true;
        });

        loop.run ();
    }

    public void
    test_event_bus_multithread ()
    {
        Core.EventBus.default = new Core.EventBus ("test-event-bus");
        Core.Event event = new Core.Event ("test", null);

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                print ("TestEventArgs 0x%lx %s %u\n", (ulong)GLib.Thread.self<void*> (), event_args.name, event_args.val);
            }
        });

        new GLib.Thread<void*> (null, () => {
            Posix.sleep (2);
            GLib.MainContext ctx = new GLib.MainContext ();
            ctx.push_thread_default ();
            GLib.MainLoop loop_thread = new GLib.MainLoop (ctx);

            event.subscribe ((args) => {
                if (args is TestEventArgs)
                {
                    unowned TestEventArgs event_args = (TestEventArgs)args;

                    print ("TestEventArgs 0x%lx %s %u\n", (ulong)GLib.Thread.self<void*> (), event_args.name, event_args.val);
                }
            });

            loop_thread.run ();

            return null;
        });

        new GLib.Thread<void*> (null, () => {
            while (true)
            {
                Posix.sleep (5);

                event.publish (new TestEventArgs ("test multithread event", GLib.Test.rand_int_range (10, 1000)));
            }
        });

        loop.run ();
    }

    public void
    test_event_bus_reply ()
    {
        Core.EventBus.default = new Core.EventBus ("test-event-bus");
        Core.Event event = new Core.Event ("test", null);

        event.subscribe ((args) => {
            if (args is TestEventArgs)
            {
                unowned TestEventArgs event_args = (TestEventArgs)args;

                event_args.name = "0x%lx".printf ((ulong)GLib.Thread.self<void*> ());
                event_args.val++;

                print ("name: %s val: %u\n", event_args.name, event_args.val);
            }
        });

        new GLib.Thread<void*> (null, () => {
            Posix.sleep (2);
            GLib.MainContext ctx = new GLib.MainContext ();
            ctx.push_thread_default ();
            GLib.MainLoop loop_thread = new GLib.MainLoop (ctx);

            event.subscribe ((args) => {
                if (args is TestEventArgs)
                {
                    unowned TestEventArgs event_args = (TestEventArgs)args;

                    event_args.name = "0x%lx".printf ((ulong)GLib.Thread.self<void*> ());
                    event_args.val++;

                    print ("name: %s val: %u\n", event_args.name, event_args.val);
                }
            });

            loop_thread.run ();

            return null;
        });

        new GLib.Thread<void*> (null, () => {
            while (true)
            {
                Posix.sleep (5);

                event.publish_with_reply (new TestEventArgs ("test reply event", 0), (arg) => {
                    print ("Reply event 0x%lx %s %u\n", (ulong)GLib.Thread.self<void*> (), ((TestEventArgs)arg).name, ((TestEventArgs)arg).val);
                });
            }
        });

        loop.run ();
    }
}

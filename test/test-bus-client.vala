/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-bus-client.vala
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
            return (string)this["name"];
        }
        set {
            this["name", 0] = value;
        }
    }

    public int64 time {
        get {
            return (int64)this["time"];
        }
        set {
            this["time", 0] = value;
        }
    }

    static construct
    {
        Core.EventArgs.register_protocol (typeof (TestEventArgs).name (),
                                          "Test",
                                          "message Test {"    +
                                          "     string name;" +
                                          "     int64 time;"  +
                                          "}");
    }

    public TestEventArgs (string inName)
    {
        this["name", 0] = inName;
        this["time", 0] = GLib.get_monotonic_time ();
    }

    internal override void
    accumulate (Core.EventArgs inArgs)
        requires (inArgs is TestEventArgs)
    {
        name += "|" + ((TestEventArgs)inArgs).name;
    }
}

public class Maia.TestSurfaceEventArgs : Maia.Core.EventArgs
{
    public Maia.Graphic.Surface surface {
        owned get {
            return (Maia.Graphic.Surface)this["surface"];
        }
    }

    public int64 time {
        get {
            return (int64)this["time"];
        }
    }

    static construct
    {
        Core.EventArgs.register_protocol (typeof (TestSurfaceEventArgs).name (),
                                          "TestSurface",
                                          "message TestSurface {"    +
                                          "     surface surface;" +
                                          "     int64 time;"  +
                                          "}");
    }

    public TestSurfaceEventArgs (Maia.Graphic.Surface inSurface)
    {
        this["surface", 0] = inSurface;
    }
}

static Maia.Core.EventListener s_Listener = null;
static Maia.Core.EventListener s_ListenerSurface = null;

static void on_bus_linked (bool connected, string? message)
{
    if (connected)
    {
        print (@"linked to server\n");

        Maia.Core.EventBus.default.subscribe (s_Listener);
        Maia.Core.EventBus.default.subscribe (s_ListenerSurface);
    }
    else
        print (@"not linked: $message\n");
}

static void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "test-bus-client"));

    var application = new Maia.Application ("test-bus-client", 60, { "gtk" });
    //var foo = new Maia.TestEventArgs ("");
    typeof (Maia.TestEventArgs).class_peek ();
    typeof (Maia.TestSurfaceEventArgs).class_peek ();

    s_Listener = new Maia.Core.EventListener.with_hash ("test", null, (inArgs) => {
        unowned Maia.TestEventArgs msg = (Maia.TestEventArgs)inArgs;

        int64 now = GLib.get_monotonic_time ();
        double diff = (double)(now - msg.time) / 1000.0;

        print(@"received event name: $(msg.name) time: $(diff) ms\n");

        msg.name = "reply";
    });

    s_ListenerSurface = new Maia.Core.EventListener.with_hash ("test-surface", null, (inArgs) => {
        unowned Maia.TestSurfaceEventArgs msg = (Maia.TestSurfaceEventArgs)inArgs;

        int64 now = GLib.get_monotonic_time ();
        double diff = (double)(now - msg.time) / 1000.0;

        print(@"received event surface time: $(diff) ms\n");

        msg.surface.dump ("received.png");
    });

    Maia.Core.EventBus.default.link_bus (args[1], on_bus_linked);

    // Run application
    application.run ();
}

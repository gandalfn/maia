/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-bus-server.vala
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
        this["time", 0] = GLib.get_monotonic_time ();
    }
}

static void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "test-bus-server"));

    var application = new Maia.Application ("test-bus-server", 60, { "gtk" }, args.length > 1 ? args[1] : "unix://");
    print (@"bus address: $(Maia.Core.EventBus.default.address)\n");

    var event = new Maia.Core.Event ("test");
    var event_surface = new Maia.Core.Event ("test-surface");
    uint32 count = 1;

//~     GLib.Timeout.add_seconds (10, () => {
//~         print(@"send event name: event number $count\n");
//~         event.publish_with_reply (new Maia.TestEventArgs (@"event number $count"), (inA) => {
//~             unowned Maia.TestEventArgs a = (Maia.TestEventArgs)inA;
//~             int64 now = GLib.get_monotonic_time ();
//~             double diff = (double)(now - a.time) / 1000.0;
//~             print (@"reply: $(a.name) diff: $(diff) ms\n");
//~         });
//~         count++;

//~         return true;
//~     });

    GLib.Timeout.add_seconds (5, () => {
        print(@"send event surface\n");
        Maia.Graphic.ImagePng image = new Maia.Graphic.ImagePng ("test.png");
        event_surface.publish (new Maia.TestSurfaceEventArgs (image.surface));

        return true;
    });

    // Run application
    application.run ();
}

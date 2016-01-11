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

    public uint32 val {
        get {
            return (uint32)this["val"];
        }
        set {
            this["val", 0] = value;
        }
    }

    static construct
    {
        Core.EventArgs.register_protocol (typeof (TestEventArgs).name (),
                                          "Test",
                                          "message Test {"    +
                                          "     string name;" +
                                          "     uint32 val;"  +
                                          "}");
    }

    public TestEventArgs (string inName, uint32 inVal)
    {
        this["name", 0] = inName;
        this["val", 0] = inVal;
    }

    internal override void
    accumulate (Core.EventArgs inArgs)
        requires (inArgs is TestEventArgs)
    {
        name += "|" + ((TestEventArgs)inArgs).name;
        val += ((TestEventArgs)inArgs).val;
    }
}

static void main (string[] args)
{
    Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "test-bus-server"));

    var application = new Maia.Application ("test-bus-server", 60, { "gtk" }, args.length > 1 ? args[1] : "unix://");
    print (@"bus address: $(Maia.Core.EventBus.default.address)\n");

    var event = new Maia.Core.Event ("test");
    uint32 count = 1;

    GLib.Timeout.add_seconds (1, () => {
        print(@"send event name: event number $count, val: $count\n");
        event.publish (new Maia.TestEventArgs (@"event number $count", count));
        count++;

        return true;
    });

    // Run application
    application.run ();
}

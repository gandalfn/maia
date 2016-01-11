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

static Maia.Core.EventListener s_Listener = null;

static void on_bus_linked (bool connected, string? message)
{
    if (connected)
    {
        print (@"linked to server\n");

        Maia.Core.EventBus.default.subscribe (s_Listener);
    }
    else
        print (@"not linked: $message\n");
}

static void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "test-bus-client"));

    var application = new Maia.Application ("test-bus-client", 60, { "gtk" });
    var foo = new Maia.TestEventArgs ("", 0);

    s_Listener = new Maia.Core.EventListener.with_hash ("test", null, (inArgs) => {
        unowned Maia.TestEventArgs msg = (Maia.TestEventArgs)inArgs;

        print(@"received event name: $(msg.name) val: $(msg.val)\n");
    });
    Maia.Core.EventBus.default.link_bus (args[1], on_bus_linked);

    // Run application
    application.run ();
}

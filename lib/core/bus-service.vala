/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * bus-service.vala
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

public abstract class Maia.Core.BusService : Bus
{
    // types
    public delegate bool DispatchFunc (Bus.Message inMessage);

    // properties
    private unowned DispatchFunc m_DispatchFunc = null;

    // signals
    public signal void new_connection (BusConnection inConnection);

    // methods
    protected BusService (string inUUID)
    {
        GLib.Object (uuid: inUUID);
    }

    private void
    on_client_message_received (Bus.Message inMessage)
    {
        if (m_DispatchFunc == null || !m_DispatchFunc (inMessage))
        {
            foreach (unowned Core.Object? child in this)
            {
                unowned BusConnection? client = child as BusConnection;
                if (client != null && (inMessage.destination == 0 || inMessage.destination == client.id))
                {
                    // send message to client
                    client.send.begin (inMessage);

                    // if no broadcast stop on first match
                    if (inMessage.destination != 0) break;
                }
            }
        }
    }

    protected async bool
    authorize (BusConnection inClient)
    {
        bool ret = false;

        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Check authorization of client");

        try
        {
            Bus.MessageAuth? msg = (yield inClient.recv ()) as Bus.MessageAuth;

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Receive auth %s", msg.auth_type.to_string ());
            if (msg != null)
            {
                switch (msg.auth_type)
                {
                    case Bus.AuthType.NONE:
                        bool found = false;

                        // Check if sender is not already registered
                        foreach (unowned Object child in this)
                        {
                            unowned BusConnection? client = child as BusConnection;

                            if (client != null)
                            {
                                if (client.id == msg.sender)
                                {
                                    found = true;
                                    break;
                                }
                            }
                        }

                        if (!found)
                        {
                            // Connection get same id than client
                            inClient.id = msg.sender;
                            inClient.reorder ();
                        }

                        // Send reply
                        Bus.MessageStatus reply = new Bus.MessageStatus(found ? Bus.Status.ERROR : Bus.Status.OK);
                        yield inClient.send (reply);
                        ret = !found;

                        // Send client connected signal to restart watch
                        if (!found) inClient.connected ();
                        break;
                }
            }
        }
        catch (BusError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on authorize client: %s", err.message);
        }

        return ret;
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is BusConnection;
    }

    internal override void
    insert_child (Object inChild)
    {
        unowned BusConnection client = inChild as BusConnection;

        if (client != null)
        {
            authorize.begin (client, (obj, res) => {
                if (authorize.end (res))
                {
                    base.insert_child(client);

                    new_connection (client);

                    client.message_received.connect (on_client_message_received);
                }
            });
        }
    }

    public void
    set_dispatch_func (DispatchFunc inDispatchFunc)
    {
        m_DispatchFunc = inDispatchFunc;
    }
}

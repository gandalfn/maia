/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * bus-connection.vala
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

public abstract class Maia.Core.BusConnection : Bus
{
    // types
    public class MessageReceivedNotification : Core.Notification
    {
        [CCode (notify = false)]
        public unowned Bus.Message message { get; set; default = null; }

        public MessageReceivedNotification (string inName)
        {
            base (inName);
        }
    }

    // methods
    construct
    {
        notifications.add (new Notification ("connected"));
        notifications.add (new MessageReceivedNotification ("message-received"));
        notifications.add (new Notification ("closed"));
    }

    protected BusConnection (string inName, BusAddress inAddress)
    {
        GLib.Object (id: inName.hash (), address: inAddress);
    }

    protected bool
    connect_to_service ()
    {
        bool ret = false;

#if MAIA_DEBUG
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Connect onto socket bus service");
#endif

        try
        {
            Bus.MessageAuth msg = new MessageAuth (Bus.AuthType.NONE);
            send (msg);

            Bus.MessageStatus reply = recv () as Bus.MessageStatus;
            ret = reply.status == Bus.Status.OK;

            if (ret) notifications["connected"].post ();
        }
        catch (GLib.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on connect to service: %s", err.message);
        }

        return ret;
    }
}

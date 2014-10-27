/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * socket-bus-connection.vala
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

public class Maia.Core.SocketBusConnection : BusConnection
{
    // properties
    private GLib.SocketClient     m_Client;
    private GLib.SocketConnection m_Connection;
    private SocketWatch           m_Watch;

    // methods
    construct
    {
        notifications["connected"].add_object_observer (on_connected);
    }

    public SocketBusConnection (string inName, uint32 inService) throws BusError
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Connect to bus service %s", inName);

        try
        {
            string filename = "%s/maia-bus-socket.%x".printf (GLib.Environment.get_tmp_dir (), inService);

            var client = new GLib.SocketClient ();
            var connection = client.connect (new GLib.UnixSocketAddress (filename));

            base (inName, new SocketWatch (connection.socket), new SocketWatch (connection.socket, Watch.Condition.OUT));

            m_Client = client;
            m_Connection = connection;

            init_connection ();

            connect_to_service.begin ();
        }
        catch (GLib.Error err)
        {
            throw new BusError.CONNECT ("Error on connect bus service: %s", err.message);
        }
    }

    public SocketBusConnection.tcp (string inName, string inHost, uint16 inPort) throws BusError
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Connect to bus service %s:%u", inHost, inPort);

        try
        {
            var client = new GLib.SocketClient ();
            var connection = m_Client.connect_to_host (inHost, inPort);

            base (inName, new SocketWatch (connection.socket), new SocketWatch (connection.socket, Watch.Condition.OUT));

            m_Client = client;
            m_Connection = connection;

            init_connection ();

            connect_to_service.begin ();
        }
        catch (GLib.Error err)
        {
            throw new BusError.CONNECT ("Error on connect bus service: %s", err.message);
        }
    }

    internal SocketBusConnection.client (string inName, GLib.SocketConnection inConnection)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "");

        base (inName, new SocketWatch (inConnection.socket), new SocketWatch (inConnection.socket, Watch.Condition.OUT));

        m_Connection = inConnection;

        init_connection ();
    }

    ~SocketBusConnection ()
    {
        Log.audit ("~SocketBusConnection", Log.Category.MAIN_BUS, "");
        if (m_Connection != null)
        {
            try
            {
                m_Connection.close ();
            }
            catch (GLib.Error err)
            {
                Log.critical ("~SocketBusConnection", Log.Category.MAIN_BUS, "Error on close client connection: %s", err.message);
            }

            m_Watch.stop ();
        }
    }

    private void
    init_connection ()
    {
        // Create watch on receive
        m_Watch = new SocketWatch (m_Connection.socket);
        m_Watch.notifications["ready"].add_object_observer (on_received);
        m_Watch.notifications["closed"].add_object_observer (on_closed);
        m_Watch.stop ();
    }

    private void
    on_connected (Core.Notification inpNotification)
    {
        m_Watch.start ();
    }

    private void
    on_received (Core.Notification inNotification)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "receive message");

        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;

        if (notification != null)
        {
            m_Watch.stop ();

            recv.begin (null, (obj, res) => {
                try
                {
                    unowned BusConnection.MessageReceivedNotification notify = notifications["message-received"] as BusConnection.MessageReceivedNotification;
                    notify.message = recv.end (res);
                    notify.post ();
                }
                catch (BusError err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on receive message: %s", err.message);
                }
                m_Watch.start ();
            });

            notification.@continue = true;
        }
    }

    private void
    on_closed (Core.Notification inNotification)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "");
        m_Watch.stop ();
        parent = null;
    }

    internal override size_t
    read (uint8[] inData, uint inTimeout) throws BusError
    {
        size_t ret = 0;

        try
        {
            int wait = 0;

            while ((uint64)wait * 1000 < (uint64)inTimeout * 1000  && m_Connection.socket.condition_check (GLib.IOCondition.IN) != GLib.IOCondition.IN)
            {
                GLib.Thread.@yield ();
                GLib.Thread.usleep (1000);
                wait++;
            }

            if ((uint64)wait * 1000 < (uint64)inTimeout * 1000)
            {
                m_Connection.input_stream.read_all (inData, out ret);
            }
            else
            {
                throw new BusError.READ ("error on receive message : timed out");
            }
        }
        catch (GLib.Error err)
        {
            throw new BusError.READ ("error on receive message : %s", err.message);
        }

        return ret;
    }

    internal override size_t
    write (uint8[] inData, uint inTimeout) throws BusError
    {
        size_t ret = 0;

        try
        {
            int wait = 0;

            while ((uint64)wait * 1000 < (uint64)inTimeout * 1000  && m_Connection.socket.condition_check (GLib.IOCondition.OUT) != GLib.IOCondition.OUT)
            {
                GLib.Thread.@yield ();
                GLib.Thread.usleep (1000);
                wait++;
            }

            if ((uint64)wait * 1000 < (uint64)inTimeout * 1000)
            {
                m_Connection.output_stream.write_all (inData, out ret);
            }
            else
            {
                throw new BusError.WRITE ("error on send message : timed out");
            }
        }
        catch (GLib.Error err)
        {
            throw new BusError.WRITE ("error on send message : %s", err.message);
        }

        return ret;
    }
}

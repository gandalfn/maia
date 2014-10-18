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
        }
    }

    private void
    init_connection ()
    {
        // Create watch on receive
        m_Watch = new SocketWatch (m_Connection.socket);
        m_Watch.ready.connect (on_received);
        m_Watch.closed.connect (on_closed);
        m_Watch.stop ();
    }

    private bool
    on_received ()
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "receive message");

        m_Watch.stop ();

        recv.begin (null, (obj, res) => {
            try
            {
                message_received (recv.end (res));
            }
            catch (BusError err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on receive message: %s", err.message);
            }
            m_Watch.start ();
        });

        return true;
    }

    private void
    on_closed ()
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "");
        m_Watch.stop ();
        parent = null;
    }

    internal override void
    connected ()
    {
        m_Watch.start ();
    }

    internal override size_t
    read (uint8[] inData, uint inTimeout) throws BusError
    {
        size_t ret = 0;

        try
        {
            if (m_Connection.socket.condition_timed_wait (GLib.IOCondition.IN | GLib.IOCondition.PRI, (int64)inTimeout * 1000))
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
            if (m_Connection.socket.condition_timed_wait (GLib.IOCondition.OUT, (int64)inTimeout * 1000))
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

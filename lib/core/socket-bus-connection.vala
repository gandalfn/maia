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
    // types
    private class Request : GLib.Object
    {
        public delegate void Callback (Request inRequest);

        // properties
        public GLib.Cancellable? m_Cancellable;
        public Callback          m_Callback;
        public uint8[]           m_Data;
        public size_t            m_Size;
        public BusError          m_Status;

        // methods
        public Request (uint8[] inData, owned Callback inCallback, GLib.Cancellable? inCancellable)
        {
            m_Cancellable = inCancellable;
            m_Callback = (owned)inCallback;
            m_Data = inData;
            m_Size = 0;
            m_Status = new BusError.OK ("");
        }
    }

    // properties
    private GLib.SocketClient     m_Client;
    private GLib.SocketConnection m_Connection;
    private SocketWatch           m_RecvWatch;
    private SocketWatch           m_SendWatch;
    private Queue<Request>        m_SendQueue;

    // methods
    construct
    {
        notifications["connected"].add_object_observer (on_connected);

        m_SendQueue = new Queue<Request> ();
    }

    public SocketBusConnection (string inName, uint32 inService) throws BusError
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Connect to bus service %s", inName);

        try
        {
            string filename = "%s/maia-bus-socket.%x".printf (GLib.Environment.get_tmp_dir (), inService);

            var client = new GLib.SocketClient ();
            var connection = client.connect (new GLib.UnixSocketAddress (filename));

            base (inName);

            m_Client = client;
            m_Connection = connection;

            init_connection ();

            connect_to_service ();
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

            base (inName);

            m_Client = client;
            m_Connection = connection;

            init_connection ();

            connect_to_service ();
        }
        catch (GLib.Error err)
        {
            throw new BusError.CONNECT ("Error on connect bus service: %s", err.message);
        }
    }

    internal SocketBusConnection.client (string inName, GLib.SocketConnection inConnection)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "");

        base (inName);

        m_Connection = inConnection;

        init_connection ();
    }

    ~SocketBusConnection ()
    {
        Log.audit ("~SocketBusConnection", Log.Category.MAIN_BUS, @"$uuid");
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

            m_RecvWatch.stop ();
        }
    }

    private void
    init_connection ()
    {
        // Create watch on receive
        m_RecvWatch = new SocketWatch (m_Connection.socket);
        m_RecvWatch.notifications["ready"].add_object_observer (on_received);
        m_RecvWatch.notifications["closed"].add_object_observer (on_closed);
        m_RecvWatch.stop ();

        // Create watch on send
        m_SendWatch = new SocketWatch (m_Connection.socket, Watch.Condition.OUT);
        m_SendWatch.notifications["ready"].add_object_observer (on_send_ready);
        m_SendWatch.stop ();
    }

    private void
    on_connected (Core.Notification inpNotification)
    {
        m_RecvWatch.start ();
    }

    private void
    on_received (Core.Notification inNotification)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "receive message");

        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;

        if (notification != null)
        {
            try
            {
                unowned BusConnection.MessageReceivedNotification notify = notifications["message-received"] as BusConnection.MessageReceivedNotification;
                notify.message = recv ();
                notify.post ();
            }
            catch (BusError err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on receive message: %s", err.message);
            }

            notification.@continue = true;
        }
    }

    private void
    on_send_ready (Core.Notification inNotification)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "send ready");

        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;

        if (notification != null)
        {
            Request? request = m_SendQueue.pop ();
            if (request != null)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "write message");
                try
                {
                    do
                    {
                        request.m_Size += m_Connection.output_stream.write (request.m_Data[request.m_Size:request.m_Data.length], request.m_Cancellable);
                    } while (request.m_Size < request.m_Data.length);
                }
                catch (GLib.Error err)
                {
                    Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"error on write message : $(err.message)");
                    request.m_Size = 0;
                    if (!request.m_Cancellable.is_cancelled ())
                    {
                        request.m_Status = new BusError.READ (@"error on write message : $(err.message)");
                    }
                }

                if (request.m_Cancellable.is_cancelled ())
                {
                    request.m_Size = 0;
                    request.m_Status = new BusError.CANCELLED(@"read request cancelled");
                }

                request.m_Callback (request);
            }

            notification.@continue = m_SendQueue.length > 0;
        }
    }

    private void
    on_closed (Core.Notification inNotification)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "");
        m_RecvWatch.stop ();
        m_SendWatch.stop ();
        parent = null;
    }

    internal override size_t
    read (uint8[] inData) throws BusError
    {
        size_t ret = 0;

        try
        {
            do
            {
                ret += m_Connection.input_stream.read (inData[ret:inData.length]);
            } while (ret < inData.length);
        }
        catch (GLib.Error err)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"error on read message : $(err.message)");
            ret = 0;
            throw new BusError.READ (@"error on read message : $(err.message)");
        }

        return ret;
    }

    internal override async size_t
    read_async (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError
    {
        size_t ret = 0;

        try
        {
            do
            {
                ret += yield m_Connection.input_stream.read_async (inData[ret:inData.length], GLib.Priority.HIGH_IDLE, inCancellable);
            } while (ret < inData.length);
        }
        catch (GLib.Error err)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"error on read message : $(err.message)");
            ret = 0;
            if (!inCancellable.is_cancelled ())
            {
                throw new BusError.READ (@"error on read message : $(err.message)");
            }
        }

        if (inCancellable.is_cancelled ())
        {
            throw new BusError.CANCELLED(@"read request cancelled");
        }

        return ret;
    }

    internal override size_t
    write (uint8[] inData) throws BusError
    {
        size_t ret = 0;
        try
        {
            do
            {
                ret += m_Connection.output_stream.write (inData[ret:inData.length]);
            } while (ret < inData.length);
        }
        catch (GLib.Error err)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"error on write message : $(err.message)");
            ret = 0;
            throw new BusError.READ (@"error on write message : $(err.message)");
        }

        return ret;
    }

    internal override async size_t
    write_async (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError
    {
        var request = new Request (inData, () => {
                                                write_async.callback ();
                                            }, inCancellable);

        m_SendQueue.push (request);
        m_SendWatch.start ();
        yield;

        if (!(request.m_Status is BusError.OK))
        {
            throw request.m_Status;
        }

        return request.m_Size;
    }
}

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
        public unowned uint8[]   m_Data;
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

    private unowned BusConnection.MessageReceivedNotification m_MessageReceivedNotification;

    // methods
    construct
    {
        notifications["connected"].add_object_observer (on_connected);
        m_MessageReceivedNotification = notifications["message-received"] as BusConnection.MessageReceivedNotification;

        m_SendQueue = new Queue<Request> ();
    }

    public SocketBusConnection (string inName, BusAddress inAddress) throws BusError
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"Connect to bus service $inAddress");

        try
        {
            var client = new GLib.SocketClient ();
            GLib.SocketConnection connection = null;

            switch (inAddress.address_type)
            {
                case BusAddress.Type.UNIX:
                    connection = client.connect (new GLib.UnixSocketAddress.as_abstract (inAddress.hier, -1));
                    break;

                case BusAddress.Type.SOCKET:
                    connection = client.connect_to_host (inAddress.hier == "" ? "127.0.0.1" : inAddress.hier, (uint16)inAddress.port);
                    break;
            }

            base (inName, inAddress);

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

    internal SocketBusConnection.client (string inName, BusAddress inAddress, GLib.SocketConnection inConnection)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "");

        base (inName, inAddress);

        m_Connection = inConnection;

        init_connection ();
    }

    ~SocketBusConnection ()
    {
        Log.audit ("~SocketBusConnection", Log.Category.MAIN_BUS, @"$address");
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
        m_SendWatch.notifications["closed"].add_object_observer (on_closed);
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
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "receive message");
#endif

        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;

        if (notification != null)
        {
            try
            {
                m_MessageReceivedNotification.message = recv ();
                m_MessageReceivedNotification.post ();
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
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "send ready");
#endif

        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;

        if (notification != null)
        {
            Request? request = m_SendQueue.pop ();
            if (request != null)
            {
#if MAIA_DEBUG
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "write message");
#endif
                if (!m_Connection.is_connected ())
                {
                    request.m_Size = 0;
                    request.m_Status = new BusError.WRITE (@"error on write message : Connection closed");
                }
                else
                {
                    try
                    {
                        unowned GLib.OutputStream stream = m_Connection.output_stream;
                        do
                        {
                            request.m_Size += stream.write (request.m_Data[request.m_Size:request.m_Data.length], request.m_Cancellable);
                        } while (request.m_Size > 0 && request.m_Size < request.m_Data.length);
                    }
                    catch (GLib.IOError err)
                    {
                        Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"error on write message : $(err.code) $(err.message)");
                        request.m_Size = 0;
                        if (!request.m_Cancellable.is_cancelled ())
                        {
                            request.m_Status = new BusError.WRITE (@"error on write message : $(err.message)");
                        }
                    }

                    if (request.m_Cancellable.is_cancelled ())
                    {
                        request.m_Size = 0;
                        request.m_Status = new BusError.CANCELLED(@"read request cancelled");
                    }
                    else if (request.m_Size == 0)
                    {
                        try
                        {
                            m_Connection.close ();
                        }
                        catch (GLib.IOError err)
                        {}
                        request.m_Status = new BusError.CLOSED (@"error on write message : Connection closed");
                    }
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

        ref ();
        m_RecvWatch.stop ();
        m_SendWatch.stop ();
        notifications["closed"].post ();
        parent = null;
        unref ();
    }

    internal override size_t
    read (uint8[] inData) throws BusError
    {
        size_t ret = 0;

        if (!m_Connection.is_connected ())
        {
            throw new BusError.READ (@"error on read message : Connection closed");
        }

        try
        {
            unowned GLib.InputStream stream = m_Connection.input_stream;
            do
            {
                ret += stream.read (inData[ret:inData.length]);
            } while (ret > 0 && ret < inData.length);

            if (ret == 0)
            {
                try
                {
                    m_Connection.close ();
                }
                catch (GLib.IOError err)
                {}
                throw new BusError.CLOSED (@"error on read message : Connection closed");
            }
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

        if (!m_Connection.is_connected ())
        {
            throw new BusError.READ (@"error on read message : Connection closed");
        }

        try
        {
            unowned GLib.InputStream stream = m_Connection.input_stream;
            do
            {
                ret += yield stream.read_async (inData[ret:inData.length], GLib.Priority.HIGH_IDLE, inCancellable);
            } while (ret > 0 && ret < inData.length);
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
        else if (ret == 0)
        {
            try
            {
                m_Connection.close ();
            }
            catch (GLib.IOError err)
            {}
            throw new BusError.CLOSED (@"error on read message : Connection closed");
        }

        return ret;
    }

    internal override size_t
    write (uint8[] inData) throws BusError
    {
        if (!m_Connection.is_connected ())
        {
            throw new BusError.WRITE (@"error on write message : Connection closed");
        }

        size_t ret = 0;
        try
        {
            unowned GLib.OutputStream stream = m_Connection.output_stream;
            do
            {
                ret += stream.write (inData[ret:inData.length]);
            } while (ret > 0 && ret < inData.length);

            if (ret == 0)
            {
                try
                {
                    m_Connection.close ();
                }
                catch (GLib.IOError err)
                {}
                throw new BusError.CLOSED (@"error on write message : Connection closed");
            }
        }
        catch (GLib.Error err)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"error on write message : $(err.message)");
            ret = 0;
            throw new BusError.WRITE (@"error on write message : $(err.message)");
        }

        return ret;
    }

    internal override async size_t
    write_async (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError
    {
        if (!m_Connection.is_connected ())
        {
            throw new BusError.WRITE (@"error on write message : Connection closed");
        }

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

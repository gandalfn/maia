/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * bus.vala
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

public errordomain Maia.Core.BusError
{
    OK,
    CONNECT,
    READ,
    WRITE,
    CANCELLED
}

public abstract class Maia.Core.Bus : Object
{
    // types
    public enum MessageType
    {
        NONE,
        AUTH,
        DATA,
        STATUS;

        public string
        to_string ()
        {
            switch (this)
            {
                case AUTH:
                    return "Authentification";
                case DATA:
                    return "Data";
                case STATUS:
                    return "Status";
            }

            return "Unknown";
        }
    }

    public enum Status
    {
        OK,
        ERROR
    }

    public enum AuthType
    {
        NONE
    }

    public class Message : Maia.Core.Message
    {
        // constants
        public const int HEADER_SIZE = 13;

        // static properties
        private static Core.Map<int, GLib.Type> s_Factory = null;

        // accessors
        public int message_type {
            get {
                return (int)(get (0));
            }
            construct {
                set (0, (uint8)value);
            }
        }

        public uint32 message_size {
            get {
                return get_uint32 (1);
            }
            construct {
                set_uint32 (1, value);
            }
        }

        public uint32 sender {
            get {
                return get_uint32 (5);
            }
            construct set {
                set_uint32 (5, value);
            }
        }

        public uint32 destination {
            get {
                return get_uint32 (9);
            }
            construct set {
                set_uint32 (9, value);
            }
        }

        // static methods
        public static void
        register (int inMessageType, GLib.Type inType)
            requires (inType.is_a (typeof (Message)))
        {
            if (s_Factory == null)
            {
                s_Factory = new Core.Map<int, GLib.Type> ();
            }

            s_Factory[inMessageType] = inType;
        }

        // methods
        public Message ()
        {
            base (HEADER_SIZE);
        }

        internal static Message?
        recv (Bus inBus, uint inTimeout) throws BusError
        {
            Message header = new Message ();

            if (inBus.read (header.raw, inTimeout) == header.length)
            {
                GLib.Type type = s_Factory[header.message_type];
                if (type != 0)
                {
                    Message msg = GLib.Object.new (type, message_type: header.message_type,
                                                         message_size: header.message_size,
                                                         sender:       header.sender,
                                                         destination:  header.destination,
                                                         length:       header.message_size + HEADER_SIZE) as Message;

                    unowned uint8[] data = msg.raw[HEADER_SIZE:msg.raw.length];
                    inBus.read (data, inTimeout);

                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Received message %s : %s", msg.get_type ().name (), msg.to_string ());

                    return msg;
                }
            }

            return null;
        }

        internal bool
        send (Bus inBus, uint inTimeout) throws BusError
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Send message %s : %s", message_type.to_string (), to_string ());

            return inBus.write (raw, inTimeout) == length;
        }
    }

    public class MessageAuth : Message
    {
        // accessors
        public uint8 auth_type {
            get {
                return get(Message.HEADER_SIZE);
            }
        }

        // methods
        public MessageAuth (AuthType inType)
        {
            GLib.Object (message_type: MessageType.AUTH, message_size: 1);
            push_back (inType);

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "New auth message : %s", to_string ());
        }
    }

    public class MessageData : Message
    {
        // methods
        public MessageData (GLib.Variant inData)
        {
            uint32 size = (uint32)inData.get_size ();
            GLib.Object (message_type: MessageType.DATA, message_size: size);
            push_back_variant (inData);
        }

        public new GLib.Variant
        get_data (string inFormat)
        {
            return get_variant (Message.HEADER_SIZE, inFormat);
        }
    }

    public class MessageStatus : Message
    {
        // accessors
        public uint8 status {
            get {
                return get(Message.HEADER_SIZE);
            }
        }

        // methods
        public MessageStatus (Status inStatus)
        {
            GLib.Object (message_type: MessageType.STATUS, message_size: 1);
            push_back (inStatus);
        }
    }

    private delegate void RequestCallback (Request inRequest);

    private class Request : Object
    {
        public unowned Bus             m_Bus;
        public Message                 m_Message;
        public uint                    m_Timeout;
        public BusError                m_Status;
        public GLib.Cancellable        m_Cancellable;
        public unowned RequestCallback m_Callback;

        internal Request (Bus inBus, uint inTimeout, RequestCallback inCallback, Message? inMessage = null, GLib.Cancellable? inCancellable = null)
        {
            m_Bus = inBus;
            m_Message = inMessage;
            m_Timeout = inTimeout;
            m_Status = new BusError.OK ("");
            m_Cancellable = inCancellable;
            m_Callback = inCallback;
        }

        public void
        complete ()
        {
            m_Callback (this);
        }
    }

    // properties
    private Queue<Request> m_RequestRecvQueue;
    private Queue<Request> m_RequestSendQueue;

    // accessors
    public string uuid       { get; construct; default = null; }
    public uint   timeout    { get; set; default = 30000; }
    public Watch  recv_watch { get; construct; }
    public Watch  send_watch { get; construct; }

    // signals
    public signal void received (Message inMessage);

    // static methods
    static construct
    {
        Message.register (MessageType.AUTH,   typeof (MessageAuth));
        Message.register (MessageType.DATA,   typeof (MessageData));
        Message.register (MessageType.STATUS, typeof (MessageStatus));
    }

    // methods
    construct
    {
        // Set bus id
        if (uuid != null) id = uuid.hash ();

        if (recv_watch != null)
        {
            // Create receive request queue
            m_RequestRecvQueue = new Queue<Request> ();

            // Connect onto watch received callback
            recv_watch.notifications["ready"].add_object_observer (on_receive_ready);
            // Connect onto watch timed out
            recv_watch.notifications["timeout"].add_object_observer (on_receive_timeout);
            recv_watch.stop ();
        }

        if (send_watch != null)
        {
            // Create send request queue
            m_RequestSendQueue = new Queue<Request> ();

            // Connect onto watch send callback
            send_watch.notifications["ready"].add_object_observer (on_send_ready);
            // Connect onto watch timed out
            send_watch.notifications["timeout"].add_object_observer (on_send_timeout);
            send_watch.stop ();
        }
    }

    ~Bus ()
    {
        if (recv_watch != null)
        {
            recv_watch.stop ();
        }
        if (send_watch != null)
        {
            send_watch.stop ();
        }
    }

    private void
    on_receive_timeout (Core.Notification inNotification)
    {
        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;
        if (notification != null)
        {
            ref ();
            {
                Request request = null;
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Receive timed out %s %lu", uuid, (ulong)GLib.Thread.self<void*> ());
                if ((request = m_RequestRecvQueue.pop ()) != null)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Timed out request %s", uuid);

                    if (request.m_Cancellable == null || !request.m_Cancellable.is_cancelled ())
                    {
                        request.m_Status = new BusError.READ ("error on receive message : timed out");
                    }
                    else
                    {
                        request.m_Status = new BusError.CANCELLED ("Read request cancelled");
                    }

                    request.complete ();
                }

                notification.@continue = m_RequestRecvQueue.length != 0;
            }
            unref ();
        }
    }

    private void
    on_receive_ready (Core.Notification inNotification)
    {
        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;
        if (notification != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Receive ready %s %lu", uuid, (ulong)GLib.Thread.self<void*> ());
            ref ();
            {
                Request request = null;
                while (recv_watch != null && recv_watch.check () && (request = m_RequestRecvQueue.pop ()) != null)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Read request %s", uuid);

                    if (request.m_Cancellable == null || !request.m_Cancellable.is_cancelled ())
                    {
                        try
                        {
                            request.m_Message = Message.recv (this, timeout);
                        }
                        catch (BusError err)
                        {
                            Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on read request %s: %s", uuid, err.message);
                            request.m_Status = err;
                        }
                    }
                    else
                    {
                        request.m_Status = new BusError.CANCELLED ("Read request cancelled");
                    }

                    request.complete ();
                }

                notification.@continue = m_RequestRecvQueue.length != 0;
            }
            unref ();
        }
    }

    private void
    on_send_timeout (Core.Notification inNotification)
    {
        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;
        if (notification != null)
        {
            ref ();
            {
                Request request = null;
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Write timed out %s %lu", uuid, (ulong)GLib.Thread.self<void*> ());
                if ((request = m_RequestSendQueue.pop ()) != null)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Timed out request %s", uuid);

                    if (request.m_Cancellable == null || !request.m_Cancellable.is_cancelled ())
                    {
                        request.m_Status = new BusError.WRITE ("error on send message : timed out");
                    }
                    else
                    {
                        request.m_Status = new BusError.CANCELLED ("Write request cancelled");
                    }

                    request.complete ();
                }

                notification.@continue = m_RequestSendQueue.length != 0;
            }
            unref ();
        }
    }

    private void
    on_send_ready (Core.Notification inNotification)
    {
        unowned Core.Watch.Notification? notification = inNotification as Core.Watch.Notification;
        if (notification != null)
        {
            ref ();
            {
                Request request = null;
                while (send_watch != null && send_watch.check () && (request = m_RequestSendQueue.pop ()) != null)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Write request %s", uuid);

                    if (request.m_Message != null)
                    {
                        if ((request.m_Cancellable == null || !request.m_Cancellable.is_cancelled ()))
                        {
                            try
                            {
                                request.m_Message.send (this, timeout);
                            }
                            catch (BusError err)
                            {
                                Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on write request %s: %s", uuid, err.message);
                                request.m_Status = err;
                            }
                        }
                        else
                        {
                            request.m_Status = new BusError.CANCELLED ("Write request cancelled");
                        }

                        request.complete ();
                    }
                }

                notification.@continue = m_RequestSendQueue.length != 0;
            }
            unref ();
        }
    }

    protected abstract size_t read (uint8[] inData, uint inTimeout) throws BusError;
    protected abstract size_t write (uint8[] inData, uint inTimeout) throws BusError;

    public async Message?
    recv (GLib.Cancellable? inCancellable = null) throws BusError
    {
        if (recv_watch != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch recv");

            if (!recv_watch.is_started)
            {
                recv_watch.timeout = (int)timeout;
            }
            recv_watch.start ();

            Request? ret = null;
            m_RequestRecvQueue.push (new Request (this, timeout, (request) => {
                    ret = request;

                    recv.callback ();
                }, null, inCancellable));

            yield;

            if (!(ret.m_Status is BusError.OK))
            {
                throw ret.m_Status;
            }

            return ret.m_Message;
        }

        return null;
    }

    public async void
    send (Message inMessage, GLib.Cancellable? inCancellable = null) throws BusError
    {
        if (send_watch != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch send");

            Request? ret = null;

            if (inMessage.sender == 0) inMessage.sender = id;

            if (!send_watch.is_started)
            {
                send_watch.timeout = (int)timeout;
            }
            send_watch.start ();

            m_RequestSendQueue.push (new Request (this, timeout, (request) => {
                    ret = request;

                    send.callback ();
            }, inMessage, inCancellable));

            yield;

            if (!(ret.m_Status is BusError.OK))
            {
                throw ret.m_Status;
            }
        }
    }
}

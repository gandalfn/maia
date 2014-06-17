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

    private delegate void RequestCallback ();

    private enum RequestType
    {
        READ,
        WRITE,
        END
    }

    private class Request : Object
    {
        public RequestType             m_Type;
        public unowned Bus             m_Bus;
        public Message                 m_Message;
        public uint                    m_Timeout;
        public BusError                m_Status;
        public GLib.Cancellable        m_Cancellable;
        public unowned RequestCallback m_Callback;
        public GLib.IdleSource         m_Source;
        public GLib.MainContext        m_Context;

        internal Request.read (Bus inBus, uint inTimeout, RequestCallback inCallback, GLib.Cancellable? inCancellable = null)
        {
            m_Type = RequestType.READ;
            m_Bus = inBus;
            m_Message = null;
            m_Timeout = inTimeout;
            m_Status = new BusError.OK ("");
            m_Cancellable = inCancellable;
            m_Callback = inCallback;
            m_Source = new GLib.IdleSource ();
            m_Source.set_callback (on_callback);
            m_Context = GLib.MainContext.get_thread_default ();

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Read request context : 0x%lx", (ulong)m_Context);
        }

        internal Request.write (Bus inBus, Message inMessage, uint inTimeout, RequestCallback inCallback, GLib.Cancellable? inCancellable = null)
        {
            m_Type = RequestType.WRITE;
            m_Bus = inBus;
            m_Message = inMessage;
            m_Timeout = inTimeout;
            m_Status = new BusError.OK ("");
            m_Cancellable = inCancellable;
            m_Callback = inCallback;
            m_Source = new GLib.IdleSource ();
            m_Source.set_callback (on_callback);
            m_Context = GLib.MainContext.get_thread_default ();

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Write request context : 0x%lx", (ulong)m_Context);
        }

        internal Request.end ()
        {
            m_Type = RequestType.END;
            m_Message = null;
            m_Timeout = 0;
        }

        internal override int
        compare (Object inObject)
            requires (inObject is Request)
        {
            Request other = inObject as Request;

            if (m_Type == RequestType.END)
                return 1;
            else if (other.m_Type == RequestType.END)
                return -1;

            return 0;
        }

        private bool
        on_callback ()
        {
            m_Callback ();
            return false;
        }

        public void
        complete ()
        {
            m_Source.attach (m_Context);
        }
    }

    private class Engine : Object
    {
        private unowned Bus         m_Bus;
        private GLib.Thread<void*>? m_Id = null;
        private AsyncQueue<Request> m_RequestQueue;
        private AsyncQueue<Request> m_RecvQueue;
        private AsyncQueue<Request> m_SendQueue;

        public Engine (Bus inBus)
        {
            // Create request Queue
            m_RequestQueue = new AsyncQueue<Request> ();
            m_RequestQueue.is_sorted = true;

            // Create recv/send Queue
            m_RecvQueue = new AsyncQueue<Request> ();
            m_SendQueue = new AsyncQueue<Request> ();

            // Get bus
            m_Bus = inBus;
        }

        private void*
        run ()
        {
            while (true)
            {
                Request request = m_RequestQueue.pop ();
                if (request != null)
                {
                    switch (request.m_Type)
                    {
                        case RequestType.READ:
                            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Read request %s", m_Bus.uuid);

                            if (request.m_Cancellable == null || !request.m_Cancellable.is_cancelled ())
                            {
                                try
                                {
                                    request.m_Message = Message.recv (request.m_Bus, request.m_Timeout);
                                }
                                catch (BusError err)
                                {
                                    request.m_Status = err;
                                }
                            }
                            else
                            {
                                request.m_Status = new BusError.CANCELLED ("Read request cancelled");
                            }

                            m_RecvQueue.push (request);

                            request.complete ();

                            break;

                        case RequestType.WRITE:
                            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Write request %s", m_Bus.uuid);

                            if (request.m_Message != null)
                            {
                                if ((request.m_Cancellable == null || !request.m_Cancellable.is_cancelled ()))
                                {
                                    try
                                    {
                                        request.m_Message.send (request.m_Bus, request.m_Timeout);
                                    }
                                    catch (BusError err)
                                    {
                                        Log.error (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Error on write request %s: %s", m_Bus.uuid, err.message);
                                        request.m_Status = err;
                                    }
                                }
                                else
                                {
                                    request.m_Status = new BusError.CANCELLED ("Write request cancelled");
                                }

                                m_SendQueue.push (request);

                                request.complete ();
                            }
                            break;

                        case RequestType.END:
                            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "End request %s", m_Bus.uuid);
                            return null;
                    }
                    request = null;
                }
            }
        }

        public void
        stop ()
        {
            if (m_Id != null)
            {
                // Send end engine request
                m_RequestQueue.push (new Request.end ());

                // Wait end of engine
                m_Id.join ();
            }
        }

        public void
        push (Request inRequest)
        {
            if (m_Id == null)
            {
                m_Id = new GLib.Thread<void*> (m_Bus.uuid, run);
            }

            m_RequestQueue.push (inRequest);
        }

        public Request?
        pop_recv ()
        {
            return m_RecvQueue.pop ();
        }

        public Request?
        pop_send ()
        {
            return m_SendQueue.pop ();
        }
    }

    // properties
    private Engine m_Engine;

    // accessors
    public string uuid    { get; construct; default = null; }
    public uint   timeout { get; set; default = 1000; }

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

        // Create engine
        m_Engine = new Engine (this);
    }

    ~Bus ()
    {
        // Stop engine
        m_Engine.stop ();
    }

    protected abstract size_t read (uint8[] inData, uint inTimeout) throws BusError;
    protected abstract size_t write (uint8[] inData, uint inTimeout) throws BusError;

    public async Message?
    recv (GLib.Cancellable? inCancellable = null) throws BusError
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch recv");

        Request? ret = null;

        m_Engine.push (new Request.read (this, timeout, () => {
                ret = m_Engine.pop_recv ();

                recv.callback ();
            }, inCancellable));

        yield;

        if (!(ret.m_Status is BusError.OK))
        {
            throw ret.m_Status;
        }

        return ret.m_Message;
    }

    public async void
    send (Message inMessage, GLib.Cancellable? inCancellable = null) throws BusError
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch send");

        Request? ret = null;

        if (inMessage.sender == 0) inMessage.sender = id;

        m_Engine.push (new Request.write (this, inMessage, timeout, () => {
                ret = m_Engine.pop_send ();

                send.callback ();
        }, inCancellable));

        yield;

        if (!(ret.m_Status is BusError.OK))
        {
            throw ret.m_Status;
        }
    }
}

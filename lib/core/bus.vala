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
    CANCELLED,
    CLOSED
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

        internal static async Message?
        recv_async (Bus inBus, GLib.Cancellable? inCancellable) throws BusError
        {
            Message header = new Message ();

            yield inBus.read_async (header.raw, inCancellable);

            GLib.Type type = s_Factory[header.message_type];
            if (type != 0)
            {
                Message msg = GLib.Object.new (type, message_type: header.message_type,
                                                     message_size: header.message_size,
                                                     sender:       header.sender,
                                                     destination:  header.destination,
                                                     length:       header.message_size + HEADER_SIZE) as Message;

                unowned uint8[] data = msg.raw[HEADER_SIZE:msg.raw.length];
                yield inBus.read_async (data, inCancellable);

#if MAIA_DEBUG
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Received message %s : %s", msg.get_type ().name (), msg.to_string ());
#endif
                return msg;
            }

            return null;
        }

        internal static Message?
        recv (Bus inBus) throws BusError
        {
            Message header = new Message ();

            inBus.read (header.raw);

            GLib.Type type = s_Factory[header.message_type];
            if (type != 0)
            {
                Message msg = GLib.Object.new (type, message_type: header.message_type,
                                                     message_size: header.message_size,
                                                     sender:       header.sender,
                                                     destination:  header.destination,
                                                     length:       header.message_size + HEADER_SIZE) as Message;

                unowned uint8[] data = msg.raw[HEADER_SIZE:msg.raw.length];
                inBus.read (data);

#if MAIA_DEBUG
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Received message %s : %s", msg.get_type ().name (), msg.to_string ());
#endif

                return msg;
            }

            return null;
        }

        internal async void
        send_async (Bus inBus, GLib.Cancellable? inCancellable) throws BusError
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Send message %s : %s", message_type.to_string (), to_string ());
#endif
            yield inBus.write_async (raw, inCancellable);
        }

        internal void
        send (Bus inBus) throws BusError
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Send message %s : %s", message_type.to_string (), to_string ());
#endif

            inBus.write (raw);
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

#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "New auth message : %s", to_string ());
#endif
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

    // accessors
    public BusAddress address { get; construct; default = null; }

    // static methods
    static construct
    {
        Message.register (MessageType.AUTH,   typeof (MessageAuth));
        Message.register (MessageType.DATA,   typeof (MessageData));
        Message.register (MessageType.STATUS, typeof (MessageStatus));
    }

    // methods
    protected abstract size_t read  (uint8[] inData) throws BusError;
    protected abstract size_t write (uint8[] inData) throws BusError;

    protected abstract async size_t read_async  (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError;
    protected abstract async size_t write_async (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError;

    public Message?
    recv () throws BusError
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch recv");
#endif

        Message? msg = Message.recv (this);

        return msg;
    }

    public async Message?
    recv_async (GLib.Cancellable? inCancellable = null) throws BusError
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch recv");
#endif

        Message? msg = yield Message.recv_async (this, inCancellable);

        return msg;
    }

    public void
    send (Message inMessage) throws BusError
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch send");
#endif

        if (inMessage.sender == 0) inMessage.sender = id;

        inMessage.send (this);
    }

    public async void
    send_async (Message inMessage, GLib.Cancellable? inCancellable = null) throws BusError
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Launch send");
#endif

        if (inMessage.sender == 0) inMessage.sender = id;

        yield inMessage.send_async (this, inCancellable);
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-bus.vala
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

public class Maia.Core.EventBus : Object
{
    // types
    public enum MessageType
    {
        INVALID = 10,
        EVENT_ADVERTISE,
        EVENT,
        EVENT_REPLY,
        EVENT_DESTROY,
        SUBSCRIBE,
        UNSUBSCRIBE;

        public string
        to_string ()
        {
            switch (this)
            {
                case EVENT_ADVERTISE:
                    return "EventAdvertise";
                case EVENT:
                    return "Event";
                case EVENT_REPLY:
                    return "EventReply";
                case EVENT_DESTROY:
                    return "EventDestroy";
                case SUBSCRIBE:
                    return "Subscribe";
                case UNSUBSCRIBE:
                    return "Unsubscribe";
            }

            return "Invalid";
        }
    }

    private class MessageEventAdvertise : Bus.Message
    {
        private bool                 m_Parsed;
        private Core.Set<Event.Hash> m_Hashs;

        public Core.Set<Event.Hash> hash {
            get {
                parse ();
                return m_Hashs;
            }
        }

        construct
        {
            m_Hashs = new Core.Set<Event.Hash> ();
            m_Hashs.compare_func = Event.Hash.compare;
        }

        public MessageEventAdvertise (Event.Hash inEventHash)
        {
            var builder = new GLib.VariantBuilder (new GLib.VariantType ("a{su}"));
            builder.add ("{su}", inEventHash.name (), inEventHash.owner);
            var data = builder.end ();

            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.EVENT_ADVERTISE, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }

        public MessageEventAdvertise.list (Core.Set<Occurence> inList)
        {
            var builder = new GLib.VariantBuilder (new GLib.VariantType ("a{su}"));
            foreach (unowned Occurence occurence in inList)
            {
                builder.add ("{su}", occurence.hash.name (), occurence.hash.owner);
            }
            var data = builder.end ();

            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.EVENT_ADVERTISE, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }

        private void
        parse ()
        {
            if (!m_Parsed)
            {
                var data = get_variant (Bus.Message.HEADER_SIZE, "a{su}");

                if (data != null)
                {
                    foreach (GLib.Variant iter in data)
                    {
                        unowned string name;
                        uint32 owner;

                        iter.get ("{&su}", out name, out owner);
                        m_Hashs.insert (new Event.Hash.raw (name, (void*)owner));
                    }
                }
                m_Parsed = true;
            }
        }
    }

    private class MessageEvent : Bus.Message
    {
        private bool          m_Parsed = false;
        private Event.Hash    m_Hash;
        private GLib.Type     m_ArgsType = GLib.Type.INVALID;
        private int           m_Sequence;
        private bool          m_NeedReply = false;
        private GLib.Variant? m_Args = null;

        public Event.Hash hash {
            get {
                parse ();
                return m_Hash;
            }
        }

        public bool need_reply {
            get {
                parse ();
                return m_NeedReply;
            }
        }

        public EventArgs? args {
            owned get {
                parse ();
                return m_Args != null ? GLib.Object.new (m_ArgsType, sequence: m_Sequence, serialize: m_Args) as EventArgs : null;
            }
        }

        public MessageEvent (string inName, void* inOwner, EventArgs? inArgs, bool inNeedReply = false)
        {
            GLib.Variant data;
            if (inArgs == null)
            {
                data = new GLib.Variant ("(susibv)", inName, (uint32)inOwner, "", 0, false, new GLib.Variant ("()"));
            }
            else
            {
                data = new GLib.Variant ("(susibv)", inName, (uint32)inOwner, inArgs.get_type ().name (), inArgs.sequence, inNeedReply, inArgs.serialize);
            }
            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.EVENT, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }

        private void
        parse ()
        {
            if (!m_Parsed)
            {
                unowned string name, atype;
                uint32 owner;
                var data = get_variant (Bus.Message.HEADER_SIZE, "(susibv)");
                if (data != null)
                {
                    data.get ("(&su&sibv)", out name, out owner, out atype, out m_Sequence, out m_NeedReply, out m_Args);
                    m_Hash = new Event.Hash.raw (name, (void*)owner);
                    if (atype != "")
                    {
                        m_ArgsType = GLib.Type.from_name (atype);
                    }
                    else
                    {
                        m_Args = null;
                    }
                }
                else
                {
                    m_Hash = new Event.Hash.raw ("", null);
                }
                m_Parsed = true;
            }
        }
    }

    private class MessageEventReply : Bus.Message
    {
        private bool          m_Parsed = false;
        private bool          m_Final = false;
        private Event.Hash    m_Hash;
        private GLib.Type     m_ArgsType = GLib.Type.INVALID;
        private int           m_Sequence;
        private GLib.Variant? m_Args = null;

        public bool is_final {
            get {
                parse ();
                return m_Final;
            }
        }

        public Event.Hash hash {
            get {
                parse ();
                return m_Hash;
            }
        }

        public EventArgs? args {
            owned get {
                parse ();
                return m_Args != null ? GLib.Object.new (m_ArgsType, sequence: m_Sequence, serialize: m_Args) as EventArgs : null;
            }
        }

        public MessageEventReply (Event.Hash inHash, EventArgs? inArgs)
        {
            GLib.Variant data = new GLib.Variant ("(bsusiv)", false, inHash.name (), (uint32)inHash.owner, inArgs.get_type ().name (), inArgs.sequence, inArgs.serialize);
            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.EVENT_REPLY, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }

        public MessageEventReply.final (Event.Hash inHash, EventArgs? inArgs)
        {
            GLib.Variant data = new GLib.Variant ("(bsusiv)", true, inHash.name (), (uint32)inHash.owner, inArgs.get_type ().name (), inArgs.sequence, inArgs.serialize);
            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.EVENT_REPLY, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }

        private void
        parse ()
        {
            if (!m_Parsed)
            {
                unowned string name, atype;
                uint32 owner;
                var data = get_variant (Bus.Message.HEADER_SIZE, "(bsusiv)");
                if (data != null)
                {
                    data.get ("(b&su&siv)", out m_Final, out name, out owner, out atype, out m_Sequence, out m_Args);
                    m_Hash = new Event.Hash.raw (name, (void*)owner);
                    if (atype != "")
                    {
                        m_ArgsType = GLib.Type.from_name (atype);
                    }
                    else
                    {
                        m_Args = null;
                    }
                }
                else
                {
                    m_Hash = new Event.Hash.raw ("", null);
                }
                m_Parsed = true;
            }
        }
    }

    private class MessageDestroyEvent : Bus.Message
    {
        public Event.Hash hash {
            owned get {
                string name = "";
                uint32 owner = 0;
                var v = get_variant (Bus.Message.HEADER_SIZE, "(su)");
                if (v != null)
                {
                    v.get ("(su)", out name, out owner);
                }
                return new Event.Hash.raw (name, (void*)owner);
            }
        }

        public MessageDestroyEvent (Event inEvent)
        {
            var data = new GLib.Variant ("(su)", inEvent.name, inEvent.owner);
            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.EVENT_DESTROY, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }
    }

    internal class MessageSubscribe : Bus.Message
    {
        public Event.Hash hash {
            owned get {
                string name = "";
                uint32 owner = 0;
                var v = get_variant (Bus.Message.HEADER_SIZE, "(su)");
                if (v != null)
                {
                    v.get ("(su)", out name, out owner);
                }
                return new Event.Hash.raw (name, (void*)owner);
            }
        }

        public MessageSubscribe (Event.Hash inHash)
        {
            var data = new GLib.Variant ("(su)", inHash.name (), inHash.owner);
            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.SUBSCRIBE, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }
    }

    internal class MessageUnsubscribe : Bus.Message
    {
        public Event.Hash hash {
            owned get {
                string name = "";
                uint32 owner = 0;
                var v = get_variant (Bus.Message.HEADER_SIZE, "(su)");
                if (v != null)
                {
                    v.get ("(su)", out name, out owner);
                }
                return new Event.Hash.raw (name, (void*)owner);
            }
        }

        public MessageUnsubscribe (Event.Hash inHash)
        {
            var data = new GLib.Variant ("(su)", inHash.name (), inHash.owner);
            uint32 size = (uint32)data.get_size ();
            GLib.Object (message_type: MessageType.UNSUBSCRIBE, message_size: size);
            set_variant (Bus.Message.HEADER_SIZE, data);
        }
    }

    private class Reply
    {
        public struct Hash
        {
            public uint32 sender;
            public uint32 sequence;

            public Hash (uint32 inSender, uint32 inSequence)
            {
                sender = inSender;
                sequence = inSequence;
            }
        }

        // accessors
        public uint32    sender;
        public EventArgs args;
        public uint      count = 0;

        // methods
        public Reply (uint32 inSender, EventArgs inArgs)
        {
            sender = inSender;
            args = inArgs;
        }

        public int
        compare (Reply inOther)
        {
            int ret = (int)(sender - inOther.sender);

            if (ret == 0)
            {
                ret = (int)(args.sequence - inOther.args.sequence);
            }

            return ret;
        }

        public int
        compare_with_hash (Hash? inHash)
        {
            int ret = (int)(sender - inHash.sender);

            if (ret == 0)
            {
                ret = (int)(args.sequence - inHash.sequence);
            }

            return ret;
        }
    }

    private class ReplyHandler : Object
    {
        public struct Hash
        {
            public Event.Hash hash;
            public uint32     sequence;

            public Hash (uint32 inSequence, Event.Hash inHash)
            {
                hash = inHash;
                sequence = inSequence;
            }
        }

        // properties
        private Event.Hash             m_Hash;
        private unowned Event.Handler? m_Callback;
        private unowned GLib.Object?   m_Target;

        // accessors
        public Event.Hash hash {
            get {
                return m_Hash;
            }
        }

        // methods
        public ReplyHandler (uint32 inSequence, Event.Hash inHash, Event.Handler inCallback)
        {
            GLib.Object (id: inSequence);
            m_Hash = inHash;
            m_Callback = inCallback;
            m_Target = null;
        }

        public ReplyHandler.object (uint32 inSequence, Event.Hash inHash, Event.Handler inCallback)
        {
            GLib.Object (id: inSequence);
            m_Hash = inHash;
            m_Callback = inCallback;
            m_Target = (GLib.Object?)(*(void**)((&m_Callback) + 1));
            GLib.return_val_if_fail (m_Target != null, null);
            m_Target.weak_ref (on_target_destroy);
        }

        ~ReplyHandler ()
        {
            if (m_Target != null)
            {
                m_Target.weak_unref (on_target_destroy);
            }
        }

        private void
        on_target_destroy ()
        {
            m_Target = null;
            m_Callback = null;
        }

        internal override int
        compare (Object inOther)
            requires (inOther is ReplyHandler)
        {
            unowned ReplyHandler other = (ReplyHandler)inOther;

            int ret = m_Hash.compare (other.m_Hash);

            if (ret == 0)
            {
                ret = base.compare (inOther);
            }

            return ret;
        }

        public int
        compare_with_hash (Hash? inHash)
        {
            int ret = m_Hash.compare (inHash.hash);

            if (ret == 0)
            {
                ret = (int)(id - inHash.sequence);
            }

            return ret;
        }

        public void
        @callback (EventArgs inArgs)
        {
            if (m_Callback != null)
            {
                m_Callback (inArgs);
            }
        }
    }

    private class Engine : GLib.Object
    {
        private unowned EventBus  m_EventBus;
        private GLib.Thread<bool> m_Thread;
        private GLib.MainContext  m_Context;
        private GLib.MainLoop     m_Loop;
        private GLib.Mutex        m_Mutex = GLib.Mutex ();
        private GLib.Cond         m_Cond  = GLib.Cond ();


        public Engine (EventBus inBus)
        {
            m_EventBus = inBus;

            // Create thread service
            m_Mutex.lock ();
            m_Thread = new GLib.Thread<bool> ("event-bus", run);
            m_Cond.wait (m_Mutex);
            m_Mutex.unlock ();
        }

        ~Engine ()
        {
            Log.debug ("~Engine", Log.Category.MAIN_EVENT, @"Destroy event-bus engine $((GLib.Quark)m_EventBus.id)");
            stop ();
        }

        private bool
        run ()
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Start event-bus $((GLib.Quark)m_EventBus.id)");

            // Create context and loop
            m_Context = new GLib.MainContext ();
            m_Context.push_thread_default ();
            m_Loop = new GLib.MainLoop (m_Context);

            // Start event bus
            m_EventBus.start ();

            // Signal has loop run
            m_Mutex.lock ();
            m_Cond.signal ();
            m_Mutex.unlock ();

            // Run main loop
            m_Loop.run ();

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Stop event-bus engine $((GLib.Quark)m_EventBus.id)");

            return false;
        }

        public void
        stop ()
        {
            if (m_Thread != null && m_Loop != null)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Stop event-bus engine $((GLib.Quark)m_EventBus.id)");

                m_Loop.quit ();
                m_Loop = null;

                m_Thread.join ();
                m_Thread = null;
            }
        }
    }

    private class Client : Object
    {
        // properties
        private Set<EventListenerPool> m_Subscribers;
        private Set<EventListenerPool> m_Pendings;
        private Set<ReplyHandler>      m_ReplyHandlers;
        private BusConnection          m_Connection;

        // methods
        public Client (uint32 inId) throws BusError
        {
            // Create connection
            m_Connection = new SocketBusConnection ("event-bus-client-%lx".printf ((long)GLib.Thread.self<void*> ()), inId);
            m_Connection.notifications["message-received"].add_object_observer (on_message_received);

            // Create subscribers
            m_Subscribers = new Set<EventListenerPool> ();

            // Create pendings
            m_Pendings = new Set<EventListenerPool> ();

            // Create reply handler list
            m_ReplyHandlers = new Set<ReplyHandler> ();
        }

        private void
        on_message_received (Core.Notification inNotification)
        {
            unowned BusConnection.MessageReceivedNotification? notification =  inNotification as BusConnection.MessageReceivedNotification;

            if (notification != null)
            {
                unowned Bus.Message message = notification.message;

                if (message is MessageEventAdvertise)
                {
                    unowned MessageEventAdvertise? msg =  (MessageEventAdvertise)message;

                    foreach (unowned Event.Hash hash in msg.hash)
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "Event advertise %s", hash.to_string ());
                        unowned EventListenerPool? pool = m_Subscribers.search<Event.Hash> (hash, EventListenerPool.compare_with_event_hash);
                        if (pool == null)
                        {
                            pool = m_Pendings.search<Event.Hash> (hash, EventListenerPool.compare_with_event_hash);

                            if (pool != null)
                            {
                                m_Subscribers.insert (pool);
                                m_Pendings.remove (pool);

                                foreach (unowned Core.Object child in pool)
                                {
                                    unowned EventListener? listener = (EventListener)child;

                                    if (listener != null)
                                    {
                                        listener.attach (m_Connection);
                                    }
                                }
                            }
                            else
                            {
                                var new_pool = new EventListenerPool (hash);
                                m_Subscribers.insert (new_pool);
                            }
                        }
                    }
                }
                else if (message is MessageEvent)
                {
                    unowned MessageEvent? msg =  (MessageEvent)message;

                    unowned EventListenerPool? pool = m_Subscribers.search<Event.Hash> (msg.hash, EventListenerPool.compare_with_event_hash);
                    if (pool != null)
                    {
                        EventArgs args = msg.args;
                        pool.notify (args);
                        if (msg.need_reply)
                        {
                            MessageEventReply reply = new MessageEventReply (msg.hash, args);
                            reply.destination = msg.sender;
                            m_Connection.send.begin (reply);
                        }
                    }
                }
                else if (message is MessageEventReply)
                {
                    unowned MessageEventReply? msg =  (MessageEventReply)message;
                    ReplyHandler.Hash hash = ReplyHandler.Hash (msg.args.sequence, msg.hash);
                    unowned ReplyHandler? handler = m_ReplyHandlers.search<ReplyHandler.Hash?> (hash, ReplyHandler.compare_with_hash);
                    if (handler != null)
                    {
                        handler.callback (msg.args);
                        m_ReplyHandlers.remove (handler);
                    }
                }
                else if (message is MessageDestroyEvent)
                {
                    unowned MessageDestroyEvent? msg =  (MessageDestroyEvent)message;
                    unowned EventListenerPool? pool = m_Subscribers.search<Event.Hash> (msg.hash, EventListenerPool.compare_with_event_hash);
                    if (pool != null)
                    {
                        pool.event_destroyed = true;
                        m_Subscribers.remove (pool);
                    }
                }
            }
        }

        public void
        advertise (Event inEvent)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "Advertise %s 0x%lx", inEvent.name, (ulong)inEvent.owner);

            m_Connection.send.begin (new MessageEventAdvertise (new Event.Hash (inEvent)));
        }

        public void
        destroy (Event inEvent)
        {
            // Remove all waiting replies
            Event.Hash hash = new Event.Hash (inEvent);
            List<ReplyHandler> to_remove = new List<ReplyHandler> ();
            foreach (unowned ReplyHandler handler in m_ReplyHandlers)
            {
                if (handler.hash.compare (hash) == 0)
                {
                    to_remove.insert (handler);
                }
            }
            foreach (unowned ReplyHandler handler in to_remove)
            {
                m_ReplyHandlers.remove (handler);
            }

            // Send destroy event message
            m_Connection.send.begin (new MessageDestroyEvent (inEvent));
        }

        public void
        publish (string inName, void* inOwner, EventArgs? inArgs = null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "Create message publish %s", inName);
            m_Connection.send.begin (new MessageEvent (inName, inOwner, inArgs));
        }

        public void
        publish_with_reply (string inName, void* inOwner, EventArgs? inArgs, Event.Handler inReply)
        {
            Event.Hash hash = new Event.Hash.raw (inName, inOwner);
            ReplyHandler reply = new ReplyHandler (inArgs.sequence, hash, inReply);
            m_ReplyHandlers.insert (reply);

            m_Connection.send.begin (new MessageEvent (inName, inOwner, inArgs, true));
        }

        public void
        object_publish_with_reply (string inName, void* inOwner, EventArgs? inArgs, Event.Handler inReply)
        {
            Event.Hash hash = new Event.Hash.raw (inName, inOwner);
            ReplyHandler reply = new ReplyHandler.object (inArgs.sequence, hash, inReply);
            m_ReplyHandlers.insert (reply);

            m_Connection.send.begin (new MessageEvent (inName, inOwner, inArgs, true));
        }

        public void
        subscribe (EventListener inListener)
        {
            bool send = true;

            unowned EventListenerPool? pool = m_Subscribers.search<Event.Hash> (inListener.hash, EventListenerPool.compare_with_event_hash);
            if (pool == null)
            {
                pool = m_Pendings.search<Event.Hash> (inListener.hash, EventListenerPool.compare_with_event_hash);
                if (pool == null)
                {
                    var new_pool = new EventListenerPool (inListener.hash);
                    m_Pendings.insert (new_pool);
                    pool = new_pool;
                    send = false;
                }
            }

            if (!(inListener in pool))
            {
                pool.add (inListener);

                if (send)
                {
                    inListener.attach (m_Connection);
                }
            }
            else
            {
                Log.warning (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "listener already in pool %s", inListener.hash.to_string ());
            }
        }
    }

    private class Subscriber
    {
        public uint32 id;
        public uint count;

        public Subscriber (uint32 inId)
        {
            id = inId;
            count = 1;
        }

        public int
        compare (Subscriber inOther)
        {
            return (int)(id - inOther.id);
        }

        public int
        compare_with_id (uint32 inId)
        {
            return (int)(id - inId);
        }
    }

    private class Occurence
    {
        public Event.Hash      hash;
        public Set<Subscriber> subscribers;
        public Set<Reply>      replies;

        public Occurence (Event.Hash inHash)
        {
            // get hash
            hash = inHash;

            // create subscriber list
            subscribers = new Set<Subscriber> ();
            subscribers.compare_func = Subscriber.compare;

            // create reply list
            replies = new Set<Reply> ();
            replies.compare_func = Reply.compare;
        }

        public void
        add_reply (uint32 inId, EventArgs inArgs)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "Add reply %s %u", hash.to_string  (), inArgs.sequence);
            replies.insert (new Reply (inId, inArgs));
        }

        public MessageEventReply?
        check_reply (uint32 inId, EventArgs inArgs)
        {
            MessageEventReply? ret = null;
            Reply.Hash reply_hash = Reply.Hash (inId, inArgs.sequence);

            unowned Reply? reply = replies.search<Reply.Hash?> (reply_hash, Reply.compare_with_hash);
            if (reply != null && reply.count < subscribers.length)
            {
                reply.args.accumulate (inArgs);
                reply.count++;

                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "check reply %s %u count: %u", hash.to_string (), inArgs.sequence, reply.count);

                if (reply.count == subscribers.length)
                {
                    ret = new MessageEventReply.final (hash, reply.args);
                    ret.destination = inId;
                    replies.remove (reply);
                }
            }

            return ret;
        }

        public void
        subscribe (uint32 inId)
        {
            unowned Subscriber? subscriber = subscribers.search<uint32> (inId, Subscriber.compare_with_id);
            if (subscriber == null)
            {
                Subscriber new_subscriber = new Subscriber (inId);
                subscribers.insert (new_subscriber);
            }
            else
            {
                subscriber.count++;
            }
        }

        public void
        unsubscribe (uint32 inId)
        {
            unowned Subscriber? subscriber = subscribers.search<uint32> (inId, Subscriber.compare_with_id);
            if (subscriber != null)
            {
                subscriber.count--;
                if (subscriber.count == 0)
                {
                    subscribers.remove (subscriber);
                }
            }
        }

        public Set<uint32>
        get_subscriber_destinations ()
        {
            Set<uint32> ret = new Set<uint32> ();

            foreach (unowned Subscriber? subscriber in subscribers)
            {
                if (subscriber != null)
                {
                    ret.insert (subscriber.id);
                }
            }

            return ret;
        }

        public int
        compare (Occurence inOther)
        {
            return hash.compare (inOther.hash);
        }

        public int
        compare_with_event_hash (Event.Hash inHash)
        {
            return hash.compare (inHash);
        }
    }

    // static properties
    private static unowned EventBus? s_Default = null;

    // static accessors
    public static unowned EventBus @default {
        get {
            return s_Default;
        }
        set {
            s_Default = value;
        }
    }

    // properties
    private Engine         m_Engine;
    private BusService     m_Service;
    private Set<Occurence> m_Occurences;
    private Set<Occurence> m_PendingsOccurences;
    private GLib.Private   m_Client;

    // static methods
    static construct
    {
        Bus.Message.register (MessageType.EVENT_ADVERTISE, typeof (MessageEventAdvertise));
        Bus.Message.register (MessageType.EVENT,           typeof (MessageEvent));
        Bus.Message.register (MessageType.EVENT_REPLY,     typeof (MessageEventReply));
        Bus.Message.register (MessageType.EVENT_DESTROY,   typeof (MessageDestroyEvent));
        Bus.Message.register (MessageType.SUBSCRIBE,       typeof (MessageSubscribe));
        Bus.Message.register (MessageType.UNSUBSCRIBE,     typeof (MessageUnsubscribe));
    }

    // method
    construct
    {
        // Create occurence list
        m_Occurences = new Core.Set<Occurence> ();
        m_Occurences.compare_func = Occurence.compare;

        // Create pendings occurence list
        m_PendingsOccurences = new Core.Set<Occurence> ();
        m_PendingsOccurences.compare_func = Occurence.compare;

        // Create client private
        m_Client = new GLib.Private (GLib.Object.unref);
    }

    public EventBus (string inName)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Create event-bus $inName");

        // Create event bus
        GLib.Object (id: GLib.Quark.from_string (inName));

        // Create engine
        m_Engine = new Engine (this);
    }

    ~EventBus ()
    {
        Log.debug ("~EventBus", Log.Category.MAIN_EVENT, @"Destroy event-bus $((GLib.Quark)id)");

        m_Engine.stop ();
    }

    private void
    start ()
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Start event-bus $((GLib.Quark)id)");

        // Create bus service
        m_Service = new SocketBusService (((GLib.Quark)id).to_string ());
        m_Service.notifications["connection"].add_object_observer (on_new_connection);
        m_Service.set_dispatch_func (on_dispatch_message);
    }

    private unowned Client?
    get_client ()
    {
        unowned Client? client = (Client?)m_Client.get ();
        if (client == null)
        {
            try
            {
                var new_client = new Client (m_Service.id);
                m_Client.set (new_client);
                new_client.ref ();
                client = new_client;
            }
            catch (BusError err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "Error on create client: %s", err.message);
            }
        }

        return client;
    }

    private void
    on_new_connection (Core.Notification inNotification)
    {
        if (m_Occurences.length > 0)
        {
            unowned BusService.ConnectionNotification? notification = inNotification as BusService.ConnectionNotification;
            if (notification != null)
            {
                notification.connection.send.begin (new MessageEventAdvertise.list (m_Occurences));
            }
        }
    }

    private void
    notify_occurence_destroy_event (Occurence inOccurence, Bus.Message inMessage)
    {
        // Get list of destination of event
        Set<uint32> destination = inOccurence.get_subscriber_destinations ();
        if (destination.length > 0)
        {
            // Send event for client which is subscribed on
            foreach (unowned Core.Object? child in m_Service)
            {
                unowned BusConnection? client = child as BusConnection;
                if (client != null && client.id in destination)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Send event destroy $(((MessageDestroyEvent)inMessage).hash) to client $(client.id)");
                    // send message to client
                    client.send.begin (inMessage);
                }
            }
        }
    }

    private bool
    on_dispatch_message (Bus.Message inMessage)
    {
        bool ret = false;

        if (inMessage is MessageEventAdvertise)
        {
            unowned MessageEventAdvertise? msg = (MessageEventAdvertise)inMessage;

            foreach (unowned Event.Hash hash in msg.hash)
            {
                unowned Occurence? occurence = m_Occurences.search<Event.Hash> (hash, Occurence.compare_with_event_hash);
                if (occurence == null)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Event $(hash) advertise");
                    occurence = m_PendingsOccurences.search<Event.Hash> (hash, Occurence.compare_with_event_hash);
                    if (occurence != null)
                    {
                        m_Occurences.insert (occurence);
                        m_PendingsOccurences.remove (occurence);
                    }
                    else
                    {
                        m_Occurences.insert (new Occurence (hash));
                    }
                }
            }
        }
        else if (inMessage is MessageDestroyEvent)
        {
            unowned MessageDestroyEvent? msg = (MessageDestroyEvent)inMessage;

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Event $(msg.hash) remove");

            unowned Occurence occurence = m_Occurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
            if (occurence != null)
            {
                notify_occurence_destroy_event (occurence, inMessage);
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Event $(msg.hash) destroy");
                m_Occurences.remove (occurence);
            }

            occurence = m_PendingsOccurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
            if (occurence != null)
            {
                notify_occurence_destroy_event (occurence, inMessage);
                Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Event $(msg.hash) destroy");
                m_PendingsOccurences.remove (occurence);
            }

            ret = true;
        }
        else if (inMessage is MessageEvent)
        {
            unowned MessageEvent? msg = (MessageEvent)inMessage;

            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Event $(msg.hash) publish");

            unowned Occurence occurence = m_Occurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
            if (occurence != null)
            {
                // Event with reply
                if (msg.need_reply)
                {
                   // Add pending reply
                    occurence.add_reply (msg.sender, msg.args);
                }

                // Get list of destination of event
                Set<uint32> destination = occurence.get_subscriber_destinations ();
                if (destination.length > 0)
                {
                    // Send event for client which is subscribed on
                    foreach (unowned Core.Object? child in m_Service)
                    {
                        unowned BusConnection? client = child as BusConnection;
                        if (client != null && client.id in destination)
                        {
                            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Send event $(msg.hash) to client $(client.id)");
                            // send message to client
                            client.send.begin (inMessage);
                        }
                    }
                }
            }

            ret = true;
        }
        else if (inMessage is MessageEventReply)
        {
            unowned MessageEventReply? msg = (MessageEventReply)inMessage;

            // Not the final reply message
            if (!msg.is_final)
            {
                // Search the corresponding occurence
                unowned Occurence occurence = m_Occurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
                if (occurence != null)
                {
                    // Check if we reach all reply
                    MessageEventReply? reply = occurence.check_reply (msg.destination, msg.args);

                    if (reply != null)
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Send event reply $(msg.hash) $(msg.args.sequence)");

                        // send reply to sender
                        unowned BusConnection? connection = m_Service.find (msg.destination, false) as BusConnection;
                        if (connection != null)
                        {
                            connection.send.begin (reply);
                        }
                    }
                }

                ret = true;
            }
        }
        else if (inMessage is MessageSubscribe)
        {
            unowned MessageSubscribe? msg = (MessageSubscribe)inMessage;

            Log.audit (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Subscribe $(msg.sender) event $(msg.hash)");

            unowned Occurence occurence = m_Occurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
            if (occurence != null)
            {
                occurence.subscribe (msg.sender);
            }
            else
            {
                occurence = m_PendingsOccurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
                if (occurence == null)
                {
                    var new_occurence = new Occurence (msg.hash);
                    m_PendingsOccurences.insert (new_occurence);
                    occurence = new_occurence;
                }
                occurence.subscribe (msg.sender);
            }

            ret = true;
        }
        else if (inMessage is MessageUnsubscribe)
        {
            unowned MessageUnsubscribe? msg = (MessageUnsubscribe)inMessage;

            Log.audit (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Unsubscribe $(msg.sender) event $(msg.hash)");

            unowned Occurence occurence = m_Occurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
            if (occurence != null)
            {
                occurence.unsubscribe (msg.sender);
            }
            occurence = m_PendingsOccurences.search<Event.Hash> (msg.hash, Occurence.compare_with_event_hash);
            if (occurence != null)
            {
                occurence.unsubscribe (msg.sender);
                if (occurence.subscribers.length == 0)
                {
                    m_PendingsOccurences.remove (occurence);
                }
            }

            ret = true;
        }

        return ret;
    }

    public void
    advertise (Event inEvent)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.advertise (inEvent);
        }
    }

    public void
    destroy (Event inEvent)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.destroy (inEvent);
        }
    }

    public void
    publish (string inName, void* inOwner, EventArgs? inArgs)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.publish (inName, inOwner, inArgs);
        }
    }

    public void
    publish_event (Event inEvent, EventArgs? inArgs)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.publish (inEvent.name, inEvent.owner, inArgs);
        }
    }

    public void
    publish_with_reply (string inName, void* inOwner, EventArgs inArgs, Event.Handler inReply)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.publish_with_reply (inName, inOwner, inArgs, inReply);
        }
    }

    public void
    publish_event_with_reply (Event inEvent, EventArgs inArgs, Event.Handler inReply)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.publish_with_reply (inEvent.name, inEvent.owner, inArgs, inReply);
        }
    }

    public void
    object_publish_with_reply (string inName, void* inOwner, EventArgs inArgs, Event.Handler inReply)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.object_publish_with_reply (inName, inOwner, inArgs, inReply);
        }
    }

    public void
    object_publish_event_with_reply (Event inEvent, EventArgs inArgs, Event.Handler inReply)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.object_publish_with_reply (inEvent.name, inEvent.owner, inArgs, inReply);
        }
    }

    public void
    subscribe (EventListener inListener)
    {
        unowned Client? client = get_client ();

        if (client != null)
        {
            client.subscribe (inListener);
        }
    }
}

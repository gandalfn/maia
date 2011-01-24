/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-dispatcher.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

internal class Maia.EventDispatcher : Watch
{
    // types
    internal enum MessageType
    {
        NONE,
        POST_EVENT
    }

    private struct Message
    {
        public MessageType m_Type;
        public Event       m_Event;

        public Message (MessageType inType, Event inEvent)
        {
            m_Type = inType;
            m_Event = inEvent;
        }

        public Message.pop (int inFd)
        {
            Posix.read (inFd, &this, sizeof (Message));
        }

        public void
        push (int inFd)
        {
            m_Event.ref ();
            Posix.write (inFd, &this, sizeof (Message));
        }
    }

    private class ListenerQueue : List<EventListener>
    {
        private string m_EventId;
        private Type   m_OwnerType;

        public class ListenerQueue (EventListener inListener)
        {
            base ();

            m_EventId   = inListener.id;
            m_OwnerType = inListener.owner_type;

            insert (inListener);
        }

        public override void
        insert (EventListener inListener)
            requires (m_EventId == inListener.id)
            requires (m_OwnerType == inListener.owner_type)
        {
            base.insert (inListener);
        }

        public override void
        remove (EventListener inListener)
            requires (m_EventId == inListener.id)
            requires (m_OwnerType == inListener.owner_type)
        {
            base.remove (inListener);
        }

        public int
        compare (ListenerQueue inOther)
        {
            int ret = GLib.strcmp (m_EventId, inOther.m_EventId);

            if (ret == 0)
            {
                ret = m_OwnerType < inOther.m_OwnerType ? - 1 : (m_OwnerType > inOther.m_OwnerType ? 1 : 0);
            }

            return ret;
        }

        public int
        compare_with_event (Event inEvent)
        {
            int ret = GLib.strcmp (m_EventId, inEvent.id);

            if (ret == 0)
            {
                Type owner_type = inEvent.owner != null ? inEvent.owner.get_type () : Type.INVALID;
                ret = m_OwnerType < owner_type ? - 1 : (m_OwnerType > owner_type ? 1 : 0);
            }

            return ret;
        }

        public int
        compare_with_listener (EventListener inListener)
        {
            int ret = GLib.strcmp (m_EventId, inListener.id);

            if (ret == 0)
            {
                ret = m_OwnerType < inListener.owner_type ? - 1 : (m_OwnerType > inListener.owner_type ? 1 : 0);
            }

            return ret;
        }
    }

    // static properties
    static Set<EventDispatcher> s_EventDispatcher = null;

    // properties
    private int                 m_MessageTunnel[2];
    private Queue<Event>        m_EventQueue;
    private Set<ListenerQueue>  m_Listeners;

    // static methods
    public static new unowned EventDispatcher
    @get (GLib.Thread<void*> inThreadId = GLib.Thread.self<void*> ())
    {
        lock (s_EventDispatcher)
        {
            if (s_EventDispatcher == null)
            {
                s_EventDispatcher = new Set<EventDispatcher> ();
                s_EventDispatcher.compare_func = (a, b) => {
                    return direct_compare (a.thread_id, b.thread_id);
                };
            }
            unowned EventDispatcher? event_dispatcher =
                s_EventDispatcher.search<unowned GLib.Thread<void*>> (inThreadId,
                                                                      (a, b) => {
                            return direct_compare (a.thread_id, b);
                        });
            if (event_dispatcher == null)
            {
                EventDispatcher dispatcher = new EventDispatcher ();
                event_dispatcher = dispatcher.ref () as EventDispatcher;
            }

            return event_dispatcher;
        }
    }

    // methods
    public EventDispatcher ()
    {
        int fds[2];

        Posix.pipe (fds);

        base (fds[0], Watch.Flags.IN);

        m_MessageTunnel = fds;
        m_EventQueue = new Queue<Event> ();
        m_Listeners = new Set<ListenerQueue> ();
        m_Listeners.compare_func = ListenerQueue.compare;
    }

    ~EventDispatcher ()
    {
    }

    private void
    dispatch (Message inMsg)
    {
        // Send event to all other event dispatcher
        foreach (unowned EventDispatcher event_dispatcher in s_EventDispatcher)
        {
            if (event_dispatcher != this)
            {
                event_dispatcher.post (inMsg.m_Event);
            }
        }

        // Check if we have listener for event in this dispatcher
        lock (m_Listeners)
        {
            unowned ListenerQueue? queue = m_Listeners.search<Event> (inMsg.m_Event,
                                                                      ListenerQueue.compare_with_event);

            if (queue != null)
            {
                debug (GLib.Log.METHOD, "Found listener notify");
            }
        }
    }

    public override void
    run ()
    {
        base.run ();

        lock (s_EventDispatcher)
        {
            unowned EventDispatcher? event_dispatcher =
                s_EventDispatcher.search<unowned GLib.Thread<void*>> (thread_id,
                                                                      (a, b) => {
                            return direct_compare (a.thread_id, b);
                        });
            if (event_dispatcher != null)
            {
                foreach (ListenerQueue queue in m_Listeners)
                {
                    event_dispatcher.m_Listeners.insert (queue);
                }
            }
            else
            {
                s_EventDispatcher.insert (this);
            }
            unref ();
        }
    }

    public override void*
    main ()
    {
        base.main ();

        Message msg = Message.pop (m_MessageTunnel[0]);

        switch (msg.m_Type)
        {
            case MessageType.POST_EVENT:
                debug (GLib.Log.METHOD, "Received event %s", msg.m_Event.id);
                dispatch (msg);
                break;
        }

        return null;
    }

    public void
    post (Event inEvent)
    {
        debug (GLib.Log.METHOD, "Post event %s", inEvent.id);

        lock (m_MessageTunnel)
        {
            Message msg = Message (MessageType.POST_EVENT, inEvent);
            msg.push (m_MessageTunnel[1]);
        }
    }
}
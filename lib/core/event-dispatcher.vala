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
        public MessageType      m_Type;
        public Event<EventArgs> m_Event;

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
        private uint32 m_EventId;
        private void*  m_Owner;

        public ListenerQueue (EventListener inListener)
        {
            base ();

            m_EventId = inListener.id;
            m_Owner = inListener.owner;

            base.insert (inListener);
        }

        public override void
        insert (EventListener inListener)
            requires (m_EventId == inListener.id)
            requires (m_Owner == inListener.owner)
        {
            base.insert (inListener);
        }

        public override void
        remove (EventListener inListener)
            requires (m_EventId == inListener.id)
            requires (m_Owner == inListener.owner)
        {
            base.remove (inListener);
        }

        public int
        compare (ListenerQueue inOther)
        {
            int ret = atom_compare (m_EventId, inOther.m_EventId);

            if (ret == 0)
            {
                ret = direct_compare (m_Owner, inOther.m_Owner);
            }

            return ret;
        }

        public int
        compare_with_event (Event inEvent)
        {
            int ret = atom_compare (m_EventId, inEvent.id);

            if (ret == 0)
            {
                ret = direct_compare (m_Owner, inEvent.owner);
            }

            return ret;
        }

        public int
        compare_with_listener (EventListener inListener)
        {
            int ret = atom_compare (m_EventId, inListener.id);

            if (ret == 0)
            {
                ret = direct_compare (m_Owner, inListener.owner);
            }

            return ret;
        }
    }

    // properties
    private int                 m_MessageTunnel[2];
    private Queue<Event>        m_EventQueue;
    private GLib.StaticRWLock   m_ListenersMutex;
    private Set<ListenerQueue>  m_Listeners;

    // methods
    public EventDispatcher ()
    {
        int fds[2];

        Posix.pipe (fds);

        base (fds[0], Watch.Flags.IN);

        m_MessageTunnel[0] = fds[0];
        m_MessageTunnel[1] = fds[1];
        m_EventQueue = new Queue<Event> ();
        m_ListenersMutex = GLib.StaticRWLock ();
        m_Listeners = new Set<ListenerQueue> ();
        m_Listeners.compare_func = ListenerQueue.compare;
    }

    ~EventDispatcher ()
    {
        Posix.close (m_MessageTunnel[0]);
        Posix.close (m_MessageTunnel[1]);
    }

    private void
    dispatch (Message inMsg)
    {
        // Check if we have listener for event in this dispatcher
        m_ListenersMutex.reader_lock ();
        {
            unowned ListenerQueue? queue = m_Listeners.search<Event> (inMsg.m_Event,
                                                                      ListenerQueue.compare_with_event);

            if (queue != null)
            {
                foreach (unowned EventListener event_listener in queue)
                {
                    event_listener.notify (inMsg.m_Event.args);
                }
            }
        }
        m_ListenersMutex.reader_unlock ();
    }

    public override void*
    main ()
    {
        base.main ();

        Message msg = Message.pop (m_MessageTunnel[0]);

        switch (msg.m_Type)
        {
            case MessageType.POST_EVENT:
                debug (GLib.Log.METHOD, "Received event %s", msg.m_Event.name);
                dispatch (msg);
                break;
        }

        return null;
    }

    public void
    post (Event inEvent)
    {
        debug (GLib.Log.METHOD, "Post event %s", inEvent.name);

        bool listen_event = false;

        // Check if we have listener for event in this dispatcher
        m_ListenersMutex.reader_lock ();
        {
            unowned ListenerQueue? queue = m_Listeners.search<Event> (inEvent,
                                                                      ListenerQueue.compare_with_event);

            listen_event = queue != null;
        }
        m_ListenersMutex.reader_unlock ();

        if (listen_event)
        {
            Message msg = Message (MessageType.POST_EVENT, inEvent);
            msg.push (m_MessageTunnel[1]);
        }
    }

    public void
    listen (EventListener inEventListener)
    {
        m_ListenersMutex.writer_lock ();
        {
            ListenerQueue queue = m_Listeners.search<EventListener> (inEventListener,
                                                                     ListenerQueue.compare_with_listener);
            if (queue == null)
            {
                queue = new ListenerQueue (inEventListener);
                m_Listeners.insert (queue);
            }
            else
            {
                queue.insert (inEventListener);
            }
        }
        m_ListenersMutex.writer_unlock ();
    }
}
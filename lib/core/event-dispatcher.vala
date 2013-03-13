/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-dispatcher.vala
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

internal class Maia.EventDispatcher : Watch
{
    // types
    private class ListenerQueue : Atomic.List<EventListener>
    {
        internal uint32 m_EventId;
        internal void*  m_Owner;

        public ListenerQueue (EventListener inListener)
        {
            m_EventId = inListener.id;
            m_Owner = inListener.owner;
        }

        public int
        compare (ListenerQueue? inOther)
        {
            if (inOther == null) return -1;

            int ret = uint32_compare (m_EventId, inOther.m_EventId);

            if (ret == 0)
            {
                ret = direct_compare (m_Owner, inOther.m_Owner);
            }

            return ret;
        }

        public int
        compare_with_event (Event inEvent)
        {
            int ret = uint32_compare (m_EventId, inEvent.id);

            if (ret == 0)
            {
                ret = direct_compare (m_Owner, inEvent.owner);
            }

            return ret;
        }

        public int
        compare_with_listener (EventListener inListener)
        {
            int ret = uint32_compare (m_EventId, inListener.id);

            if (ret == 0)
            {
                ret = direct_compare (m_Owner, inListener.owner);
            }

            return ret;
        }
    }

    // properties
    private Atomic.Queue<Event> m_EventQueue;
    private SpinLock            m_ListenersLock;
    private Set<ListenerQueue>  m_Listeners;

    // accessors
    internal override int watch_fd {
        get {
            return fd;
        }
    }


    // methods
    public EventDispatcher ()
    {
        int event_fd = Os.eventfd ();

        base (event_fd, Watch.Flags.IN);

        m_EventQueue = new Atomic.Queue<Event> ();
        m_ListenersLock = SpinLock ();
        m_Listeners = new Set<ListenerQueue> ();
        m_Listeners.compare_func = ListenerQueue.compare;
    }

    ~EventDispatcher ()
    {
        Os.close (fd);
    }

    private void
    dispatch (Event inEvent)
    {
        Log.debug (GLib.Log.METHOD, "dispatch %s", inEvent.name);
        m_ListenersLock.lock ();
        unowned ListenerQueue? queue = m_Listeners.search<Event> (inEvent, ListenerQueue.compare_with_event);
        m_ListenersLock.unlock ();

        if (queue != null)
        {
            queue.foreach ((event_listener) => {
                Log.debug (GLib.Log.METHOD, "notify %s", inEvent.name);
                event_listener.notify (inEvent);
                return true;
            });
        }
    }

    internal override void*
    main ()
    {
        base.main ();

        uint64 count;
        Os.eventfd_read (fd, out count);

        Log.debug (GLib.Log.METHOD, "received %llu", count);
        for (;count > 0; count--)
        {
            Event event = m_EventQueue.dequeue ();
            if (event != null)
                dispatch (event);
        }

        return null;
    }

    public void
    post (Event inEvent)
    {
        m_ListenersLock.lock ();
        unowned ListenerQueue? queue = m_Listeners.search<Event> (inEvent, ListenerQueue.compare_with_event);
        m_ListenersLock.unlock ();

        if (queue != null)
        {
            Log.debug (GLib.Log.METHOD, "Post event %s", inEvent.name);

            m_EventQueue.enqueue (inEvent);
            Os.eventfd_write (fd, 1);
        }
    }

    public void
    listen (EventListener inEventListener)
    {
        m_ListenersLock.lock ();
        unowned ListenerQueue? queue = m_Listeners.search<EventListener> (inEventListener, ListenerQueue.compare_with_listener);

        if (queue != null)
        {
            Log.debug (GLib.Log.METHOD, "Add listener %s", inEventListener.name);
            queue.insert (inEventListener);
        }
        else
        {
            ListenerQueue new_queue = new ListenerQueue (inEventListener);
            new_queue.insert (inEventListener);
            m_Listeners.insert (new_queue);
            Log.debug (GLib.Log.METHOD, "Add listener %s", inEventListener.name);
        }
        m_ListenersLock.unlock ();
    }

    public void
    deafen (EventListener inEventListener)
    {
        m_ListenersLock.lock ();
        unowned ListenerQueue? queue = m_Listeners.search<EventListener> (inEventListener, ListenerQueue.compare_with_listener);
        m_ListenersLock.unlock ();

        if (queue != null)
        {
            queue.remove (inEventListener);
        }
    }

    public void
    deafen_event (Event inEvent)
    {
        m_ListenersLock.lock ();
        unowned ListenerQueue? queue = m_Listeners.search<Event> (inEvent, ListenerQueue.compare_with_event);
        m_ListenersLock.unlock ();

        if (queue != null)
        {
            m_Listeners.remove (queue);
        }
    }
}

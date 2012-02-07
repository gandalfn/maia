/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    private Atomic.Queue<Event>        m_EventQueue;
    private Atomic.List<ListenerQueue> m_Listeners;

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
        m_Listeners = new Atomic.List<ListenerQueue> ();
        m_Listeners.compare_func = ListenerQueue.compare;
    }

    ~EventDispatcher ()
    {
        Os.close (fd);
    }

    private void
    dispatch (Event inEvent)
    {
        m_Listeners.foreach ((queue) => {
            if (queue.compare_with_event (inEvent) == 0)
            {
                queue.foreach ((event_listener) => {
                    event_listener.notify (inEvent.event_args);
                    return true;
                });

                return false;
            }

            return true;
        });
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
        m_Listeners.foreach ((queue) => {
            if (queue.compare_with_event (inEvent) == 0)
            {
                Log.debug (GLib.Log.METHOD, "Post event %i", inEvent.id);

                m_EventQueue.enqueue (inEvent);
                Os.eventfd_write (fd, 1);

                return false;
            }

            return true;
        });
    }

    public void
    listen (EventListener inEventListener)
    {
        bool have_queue = false;
        m_Listeners.foreach ((queue) => {
            if (queue.compare_with_listener (inEventListener) == 0)
            {
                have_queue = true;
                Log.debug (GLib.Log.METHOD, "Add listener %i", inEventListener.id);
                queue.insert (inEventListener);
                return false;
            }
            return true;
        });


        if (!have_queue)
        {
            ListenerQueue queue = new ListenerQueue (inEventListener);
            bool ret = queue.insert (inEventListener);
            bool ret1 = m_Listeners.insert (queue);
            Log.debug (GLib.Log.METHOD, "Add listener %i %s %s", inEventListener.id, ret.to_string (), ret1.to_string ());
        }
    }

    public void
    deafen (EventListener inEventListener)
    {
        m_Listeners.foreach ((queue) => {
            if (queue.compare_with_listener (inEventListener) == 0)
            {
                queue.remove (inEventListener);
                return false;
            }
            return true;
        });
    }

    public void
    deafen_event (Event inEvent)
    {
        unowned Event evt = inEvent;
        m_Listeners.foreach ((queue) => {
            if (queue.compare_with_event (evt) == 0)
            {
                m_Listeners.remove (queue);
                return false;
            }
            return true;
        });
    }
}

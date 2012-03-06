/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * dispatcher.vala
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

public class Maia.Dispatcher : Task
{
    // static properties
    static GLib.Private                    s_Private;
    static Atomic.List<unowned Dispatcher> s_Dispatchers;

    // properties
    private Os.EPoll         m_PollFd = -1;
    private EventDispatcher  m_EventDispatcher = null;
    private Event<EventArgs> m_FinishEvent = null;

    // accessors
    public static unowned Dispatcher? self {
        get {
            return (Dispatcher?)s_Private.get ();
        }
    }

    // static methods
    static construct
    {
        s_Private = new GLib.Private (null);
        s_Private.set (null);

        s_Dispatchers = new Atomic.List<unowned Dispatcher> ();
        s_Dispatchers.compare_func = (a, b) => {
            return direct_compare (a.thread_id, b.thread_id);
        };
    }

    // methods
    internal static void
    remove_event_listeners (Event inEvent)
    {
        Log.audit (GLib.Log.METHOD, "Remove event listeners for event id = %s", inEvent.name);

        unowned Event evt = inEvent;
        s_Dispatchers.foreach ((dispatcher) => {
            dispatcher.m_EventDispatcher.deafen_event (evt);
            return true;
        });
    }

    public Dispatcher ()
    {
        base (Priority.HIGH, false);
        Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        sorted_childs = true;

        m_EventDispatcher = new EventDispatcher ();
        m_EventDispatcher.parent = this;

        m_FinishEvent = new Event<EventArgs> ("finish", this);
        m_FinishEvent.listen (on_finish, this);

        assert (!(this in s_Dispatchers));

        s_Dispatchers.insert (this);
        s_Private.set (this);
    }

    public Dispatcher.thread ()
    {
        base (Priority.HIGH, true);
        Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        sorted_childs = true;

        m_EventDispatcher = new EventDispatcher ();
        m_EventDispatcher.parent = this;

        m_FinishEvent = new Event<EventArgs> ("finish", this);
        m_FinishEvent.listen (on_finish, this);
    }

    ~Dispatcher ()
    {
        Log.audit ("Maia.Dispatcher.finalize", "");

        s_Private.set (null);
        s_Dispatchers.remove (this);

        m_EventDispatcher.parent = null;

        if (m_PollFd >= 0)
            Os.close (m_PollFd);
        m_PollFd = -1;
    }

    private void
    on_finish ()
    {
        Log.audit (GLib.Log.METHOD, "Finish %lx 0x%lx", (ulong)thread_id, (ulong)this);
        state = State.TERMINATED;
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Task;
    }

    /**
     * {@inheritDoc}
     */
    internal override void*
    main ()
    {
        Log.audit (GLib.Log.METHOD, "");
        void* ret = base.main ();

        if (is_thread)
        {
            assert (!(this in s_Dispatchers));

            s_Dispatchers.insert (this);
            s_Private.set (this);
        }

        Array<unowned Task> ready_tasks = new Array<unowned Task>.sorted ();

        Os.EPollEvent[] events = new Os.EPollEvent[64];

        while (state == Task.State.RUNNING)
        {
            int timeout = nb_childs > 0 && ((Task)first ()).state == Task.State.READY ? 0 : -1;

            int nb_fds = m_PollFd.wait (events, timeout);

            if (nb_fds < 0)
                continue;

            iterator ().foreach ((object) => {
                unowned Task task = object as Task;

                if (task.state != Task.State.READY)
                    return false;

                debug (GLib.Log.METHOD, "ready task 0x%lx", (ulong)task);
                ready_tasks.insert (task);
                return true;
            });

            for (int cpt = 0; cpt < nb_fds; ++cpt)
            {
                unowned Task task = events[cpt].data.ptr as Task;
                if (task.state == Task.State.SLEEPING)
                {
                    task.wakeup ();
                }
                else
                {
                    debug (GLib.Log.METHOD, "ready watch 0x%lx", (ulong)task);
                    task.state = Task.State.READY;
                }

                if (task.state == Task.State.READY)
                    ready_tasks.insert (task);
            }

            ready_tasks.iterator ().foreach ((task) => {
                task.ref ();
                {
                    task.run ();
                }
                task.unref ();

                return true;
            });

            ready_tasks.clear ();
        }

        finished ();

        return ret;
    }

    internal override void
    finish ()
    {
        Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);
        if (state != State.TERMINATED)
        {
            m_FinishEvent.post ();
            if (is_thread && self != this)
                thread_id.join ();
        }
    }

    internal void
    post_event (Event inEvent)
    {
        Log.audit (GLib.Log.METHOD, "Event id = %i", inEvent.id);
        inEvent.ref ();
        {
            s_Dispatchers.foreach ((dispatcher) => {
                dispatcher.m_EventDispatcher.post (inEvent);
                return true;
            });
        }
        inEvent.unref ();
    }

    internal void
    add_listener (EventListener inEventListener)
    {
        Log.audit (GLib.Log.METHOD, "Listen event id = %i", inEventListener.id);
        m_EventDispatcher.listen (inEventListener);
    }

    internal void
    remove_listener (EventListener inEventListener)
    {
        Log.audit (GLib.Log.METHOD, "Deaf event id = %i", inEventListener.id);
        m_EventDispatcher.deafen (inEventListener);
    }

    internal new void
    sleep (Task inTask)
    {
        Log.audit (GLib.Log.METHOD, "");

        Os.EPollEvent event = Os.EPollEvent ();
        event.events = Os.EPOLLIN;
        event.data.ptr = inTask;
        m_PollFd.ctl (Os.EPOLL_CTL_ADD, inTask.sleep_fd, event);
    }

    internal new void
    wakeup (Task inTask)
    {
        Log.audit (GLib.Log.METHOD, "");
        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inTask.sleep_fd, null);
    }

    internal void
    add_watch (Watch inWatch)
    {
        Log.audit (GLib.Log.METHOD, "");

        Os.EPollEvent event = Os.EPollEvent ();
        event.events = Os.EPOLLERR | Os.EPOLLHUP;
        if ((inWatch.flags & Watch.Flags.IN) == Watch.Flags.IN)
            event.events |= Os.EPOLLIN;
        if ((inWatch.flags & Watch.Flags.OUT) == Watch.Flags.OUT)
            event.events |= Os.EPOLLOUT;
        if ((inWatch.flags & Watch.Flags.ERR) == Watch.Flags.ERR)
            event.events |= Os.EPOLLERR;
        event.data.ptr = inWatch;
        m_PollFd.ctl (Os.EPOLL_CTL_ADD, inWatch.watch_fd, event);
    }

    internal void
    remove_watch (Watch inWatch)
    {
        Log.audit (GLib.Log.METHOD, "");

        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inWatch.watch_fd, null);
        inWatch.close_watch_fd ();
    }
}

/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    protected delegate R ThreadSafeCallback<R> ();

    // Static properties
    static Set<unowned Dispatcher> s_Dispatchers;

    // Properties
    private Os.EPoll         m_PollFd = -1;
    private EventDispatcher  m_EventDispatcher = null;
    private Event<EventArgs> m_FinishEvent = null;

    // Accessors
    public static unowned Dispatcher? self {
        get {
            unowned Dispatcher ret = null;

            Token token = Token.get_for_class (s_Dispatchers);
            {
                ret = s_Dispatchers.search<unowned GLib.Thread<void*>> (GLib.Thread.self<void*> (),
                                                                        (v, a) => {
                                                                            return direct_compare (v.thread_id, a);
                                                                        });
            }
            token.release ();

            return ret;
        }
    }

    // Methods
    static construct
    {
        s_Dispatchers = new Set<unowned Dispatcher> ();
        s_Dispatchers.compare_func = (a, b) => {
            return direct_compare (a.thread_id, b.thread_id);
        };
    }

    internal static void
    remove_event_listeners (Event inEvent)
    {
        audit (GLib.Log.METHOD, "Leaf event id = %s", inEvent.name);
        Token token = Token.get_for_class (s_Dispatchers);
        {
            foreach (unowned Dispatcher dispatcher in s_Dispatchers)
            {
                Token token_event_dispatcher = Token.get_for_object (dispatcher.m_EventDispatcher);
                {
                    dispatcher.m_EventDispatcher.deafen_event (inEvent);
                }
                token_event_dispatcher.release ();
            }
        }
        token.release ();
    }

    public Dispatcher ()
    {
        audit (GLib.Log.METHOD, "");
        base (Priority.HIGH, false);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        sorted_childs = true;

        m_EventDispatcher = new EventDispatcher ();
        m_EventDispatcher.parent = this;

        m_FinishEvent = new Event<EventArgs> ("finish", this);
        m_FinishEvent.listen (on_finish, this);
    }

    public Dispatcher.thread ()
    {
        audit (GLib.Log.METHOD, "");
        base (Priority.HIGH, true);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        sorted_childs = true;

        m_EventDispatcher = new EventDispatcher ();
        m_EventDispatcher.parent = this;

        m_FinishEvent = new Event<EventArgs> ("finish", this);
        m_FinishEvent.listen (on_finish, this);
    }

    ~Dispatcher ()
    {
        audit ("Maia.Dispatcher.finalize", "");
        Token token = Token.get_for_class (s_Dispatchers);
        {
            s_Dispatchers.remove (this);
        }
        token.release ();

        m_EventDispatcher.parent = null;

        if (m_PollFd >= 0)
            Os.close (m_PollFd);
        m_PollFd = -1;
    }

    private void
    on_finish ()
    {
        audit (GLib.Log.METHOD, "Finish %lx", (ulong)thread_id);
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
        audit (GLib.Log.METHOD, "");
        void* ret = base.main ();

        Token token = Token.get_for_class (s_Dispatchers);
        {
            assert (!(this in s_Dispatchers));

            s_Dispatchers.insert (this);
        }
        token.release ();

        Array<unowned Task> ready_tasks = new Array<unowned Task>.sorted ();

        Os.EPollEvent[] events = new Os.EPollEvent[64];

        while (state == Task.State.RUNNING)
        {
            int timeout = nb_childs > 0 && ((Task)first ()).state == Task.State.READY ? 0 : -1;

            int nb_fds = m_PollFd.wait (events, timeout);

            if (nb_fds < 0)
                continue;

            foreach (unowned Object object in this)
            {
                unowned Task task = object as Task;

                if (task.state != Task.State.READY)
                    break;

                debug (GLib.Log.METHOD, "ready task 0x%lx", (ulong)task);
                ready_tasks.insert (task);
            }

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

            foreach (unowned Task task in ready_tasks)
            {
                task.ref ();
                {
                    task.run ();
                }
                task.unref ();
            }

            ready_tasks.clear ();
        }

        finished.send ();

        return ret;
    }

    internal override void
    finish ()
    {
        audit (GLib.Log.METHOD, "");
        m_FinishEvent.post<EventArgs> ();
        if (is_thread && self != this)
            thread_id.join ();
    }

    internal void
    post_event (Event inEvent)
    {
        audit (GLib.Log.METHOD, "Event id = %s", inEvent.name);
        Token token = Token.get_for_class (s_Dispatchers);
        {
            foreach (unowned Dispatcher dispatcher in s_Dispatchers)
            {
                dispatcher.m_EventDispatcher.post (inEvent);
            }
        }
        token.release ();
    }

    internal void
    add_listener (EventListener inEventListener)
    {
        audit (GLib.Log.METHOD, "Listen event id = %s", inEventListener.name);
        Token token = Token.get_for_class (s_Dispatchers);
        {
            m_EventDispatcher.listen (inEventListener);
        }
        token.release ();
    }

    internal void
    remove_listener (EventListener inEventListener)
    {
        audit (GLib.Log.METHOD, "Deaf event id = %s", inEventListener.name);
        Token token = Token.get_for_class (s_Dispatchers);
        {
            m_EventDispatcher.deafen (inEventListener);
        }
        token.release ();
    }

    internal new void
    sleep (Task inTask)
    {
        audit (GLib.Log.METHOD, "");

        Os.EPollEvent event = Os.EPollEvent ();
        event.events = Os.EPOLLIN;
        event.data.ptr = inTask;
        m_PollFd.ctl (Os.EPOLL_CTL_ADD, inTask.sleep_fd, event);
    }

    internal new void
    wakeup (Task inTask)
    {
        audit (GLib.Log.METHOD, "");
        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inTask.sleep_fd, null);
    }

    internal void
    add_watch (Watch inWatch)
    {
        audit (GLib.Log.METHOD, "");

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
        audit (GLib.Log.METHOD, "");

        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inWatch.watch_fd, null);
        inWatch.close_watch_fd ();
    }
}

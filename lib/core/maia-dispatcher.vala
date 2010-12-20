/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-dispatcher.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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
    // Static properties
    static Set<unowned Dispatcher> s_Dispatchers;

    // Properties
    private Os.EPoll m_PollFd = -1;

    // Methods
    static construct
    {
        s_Dispatchers = new Set<unowned Dispatcher> ();
        s_Dispatchers.compare_func = (a, b) => {
            return direct_compare (a.thread_id, b.thread_id);
        };
    }

    public static unowned Dispatcher?
    self ()
    {
        lock (s_Dispatchers)
        {
            return s_Dispatchers.search<unowned GLib.Thread<void*>> (GLib.Thread.self<void*> (),
                                                                     (v, a) => {
                                                                         return direct_compare (v.thread_id, a);
                                                                     });
        }
    }

    public Dispatcher ()
    {
        base (Priority.HIGH);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        childs.compare_func = get_compare_func_for<Task> ();
    }

    ~Dispatcher ()
    {
        lock (s_Dispatchers)
        {
            s_Dispatchers.remove (this);
        }

        if (m_PollFd >= 0)
            Posix.close (m_PollFd);
        m_PollFd = -1;
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    can_append_child (Object inChild)
    {
        return inChild is Task;
    }

    /**
     * {@inheritDoc}
     */
    protected override void*
    main ()
    {
        void* ret = base.main ();

        lock (s_Dispatchers)
        {
            assert (!(this in s_Dispatchers));

            s_Dispatchers.insert (this);
        }

        Array<unowned Task> ready_tasks = new Array<unowned Task> ();
        ready_tasks.compare_func = get_compare_func_for<Task> ();

        Os.EPollEvent events[64];

        while (state == Task.State.RUNNING)
        {
            int timeout = childs.nb_items > 0 && ((Task)childs.at (0)).state == Task.State.READY ? 0 : -1;

            int nb_fds = m_PollFd.wait (events, timeout);

            assert (nb_fds >= 0);

            foreach (unowned Object object in childs)
            {
                Task task = (Task)object;

                if (task.state != Task.State.READY)
                    break;

                ready_tasks.insert (task);
            }

            for (int cpt = 0; cpt < nb_fds; ++cpt)
            {
                Task task = (Task)events[cpt].data.ptr;
                if (task.state == Task.State.SLEEPING)
                {
                    task.wakeup ();
                }
                else
                {
                    task.state = Task.State.READY;
                }

                if (task.state == Task.State.READY)
                    ready_tasks.insert (task);
            }

            foreach (unowned Task task in ready_tasks)
            {
                task.run ();

                if (task.state == Task.State.TERMINATED)
                    task.parent = null;
            }

            ready_tasks.clear ();
        }

        finished.post ();

        return ret;
    }

    public override void
    finish ()
    {
        state = State.TERMINATED;

        if (is_thread && self () != this)
        {
            thread_id.join ();
        }
    }

    internal new void
    sleep (Task inTask)
    {
        Os.EPollEvent event = Os.EPollEvent ();
        event.events = Os.EPOLLIN;
        event.data.ptr = inTask;
        m_PollFd.ctl (Os.EPOLL_CTL_ADD, inTask.sleep_fd, event);
    }

    internal new void
    wakeup (Task inTask)
    {
        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inTask.sleep_fd, null);
    }

    internal void
    add_watch (Watch inWatch)
    {
        Os.EPollEvent event = Os.EPollEvent ();
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
        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inWatch.watch_fd, null);
        inWatch.close_watch_fd ();
    }
}

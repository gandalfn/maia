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
    // Properties
    private Os.EPoll m_PollFd = -1;

    // Methods
    public Dispatcher ()
    {
        base (Priority.HIGH);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        childs.compare_func = get_compare_func_for<Task> ();
    }

    ~Dispatcher ()
    {
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
    public override void*
    run ()
    {
        void* ret = base.run ();

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

                task.parent = null;
                if (task.state != Task.State.TERMINATED)
                    task.parent = this;
            }

            ready_tasks.clear ();
        }

        return ret;
    }

    internal new void
    sleep (Task inTask)
    {
        Os.EPollEvent event = Os.EPollEvent ();
        event.events = Os.EPOLLIN;
        event.data.ptr = inTask;
        m_PollFd.ctl (Os.EPOLL_CTL_ADD, inTask.sleep_fd, event);
        inTask.parent = this;
    }

    internal new void
    wakeup (Task inTask)
    {
        m_PollFd.ctl (Os.EPOLL_CTL_DEL, inTask.sleep_fd, null);
        inTask.parent = null;
        if (inTask.state != Task.State.TERMINATED)
            inTask.parent = this;
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
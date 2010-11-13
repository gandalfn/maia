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
    private Os.EPoll m_PollFd;

    // Methods
    public Dispatcher ()
    {
        base (Priority.HIGH);

        m_PollFd = Os.EPoll (Os.EPOLL_CLOEXEC);
        childs.compare_func = get_compare_func_for<Task> ();
    }

    ~Dispatcher ()
    {
        Posix.close (m_PollFd);
    }

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
                unowned Task task = (Task)events[cpt].data.ptr;
                task.state = Task.State.READY;

                m_PollFd.ctl (Os.EPOLL_CTL_DEL, task.wait_fd, null);
                Posix.close (task.wait_fd);
                task.wait_fd = -1;
                ready_tasks.insert (task);
            }

            foreach (unowned Task task in ready_tasks)
            {
                task.run ();

                task.parent = null;
                if (task.state != Task.State.TERMINATED)
                {
                    task.parent = this;
                }
            }

            ready_tasks.clear ();
        }

        return ret;
    }

    internal new void
    sleep (Task inTask, ulong inTimeout)
    {
        ulong ustime = inTimeout * 1000;
        Os.ITimerSpec itimer_spec = Os.ITimerSpec ();
        itimer_spec.it_value.tv_sec = (time_t)(ustime / 1000000);
        itimer_spec.it_value.tv_nsec = (long)(1000 * (ustime % 1000000));

        Os.TimerFd timer_fd = Os.TimerFd (Os.CLOCK_MONOTONIC, Os.TFD_CLOEXEC);
        timer_fd.settime (0, itimer_spec, null);

        Os.EPollEvent event = Os.EPollEvent ();
        event.events = Os.EPOLLIN;
        event.data.ptr = inTask;
        m_PollFd.ctl (Os.EPOLL_CTL_ADD, timer_fd, event);

        inTask.wait_fd = timer_fd;
    }
}
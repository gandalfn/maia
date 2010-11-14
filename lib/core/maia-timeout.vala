/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-timeout.vala
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

public class Maia.Timeout : Watch
{
    public class Observer : Maia.Observer
    {
        [CCode (has_target = false)]
        public delegate bool ActionFunc (void* inpTarget);

        public class Args : Maia.Observer.Args
        {
            public bool return_val = false;
        }

        public Observer (ActionFunc inFunc, void* inpTarget)
        {
            base ((Maia.Observer.ActionFunc)inFunc, inpTarget);
        }

        public override void
        notify (Maia.Notification inNotification, Maia.Observer.Args? inArgs = null)
        {
            Args args = (Args)inArgs;
            ActionFunc callback = (ActionFunc)func;

            args.return_val |= callback (target);
        }
    }

    // Properties
    private ulong m_TimeoutMs;
    private bool m_WatchSet = false;

    // Notifications
    public Notification elapsed;

    // Accessors
    internal override int watch_fd {
        get {
            if (!m_WatchSet)
            {
                ulong ustime = m_TimeoutMs * 1000;
                Os.ITimerSpec itimer_spec = Os.ITimerSpec ();
                itimer_spec.it_value.tv_sec = (time_t)(ustime / 1000000);
                itimer_spec.it_value.tv_nsec = (long)(1000 * (ustime % 1000000));

                ((Os.TimerFd)fd).settime (0, itimer_spec, null);

                m_WatchSet = true;
            }
            return fd;
        }
    }

    // Methods

    /**
     * Create a new Timeout
     *
     * @param inTimeoutMs timeout in milliseconds
     * @param inPriority timeout priority
     */
    public Timeout (ulong inTimeoutMs, Task.Priority inPriority = Task.Priority.NORMAL)
    {
        Os.TimerFd timer_fd = Os.TimerFd (Os.CLOCK_MONOTONIC, Os.TFD_CLOEXEC);
        
        base (timer_fd, Watch.Flags.IN, inPriority);

        m_TimeoutMs = inTimeoutMs;

        elapsed = new Notification ("elapsed", this);
    }

    /**
     * {@inheritDoc}
     */
    public override void*
    run ()
    {
        void* ret = base.run ();

        Observer.Args args = new Observer.Args ();
        elapsed.post (args);
        if (args.return_val)
            state = Task.State.WAITING;
        else
            finish ();

        return ret;
    }

    internal override void
    close_watch_fd ()
    {
        if (m_WatchSet)
        {
            Os.ITimerSpec itimer_spec = Os.ITimerSpec ();
            ((Os.TimerFd)fd).settime (0, itimer_spec, null);
            m_WatchSet = false;
        }
    }
}
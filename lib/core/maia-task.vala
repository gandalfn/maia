/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-task.vala
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

public class Maia.Task : Object
{
    // Types
    public enum Priority
    {
        HIGH = -20,
        NORMAL = 0,
        LOW = 20
    }

    public enum State
    {
        UNKNOWN,
        TERMINATED,
        SLEEPING,
        WAITING,
        RUNNING,
        READY
    }

    // Properties
    private Priority m_Priority;
    private State m_State = State.UNKNOWN;
    private Os.TimerFd m_SleepFd = -1;

    // Notifications
    public Notification<void> running;
    public Notification<void> finished;

    // Accessors

    /**
     * Task priority
     */
    public Priority priority {
        get {
            return m_Priority;
        }
    }

    /**
     * Task state
     */
    public State state {
        get {
            return m_State;
        }
        set {
            if (m_State != value)
            {
                Dispatcher dispatcher = parent as Dispatcher;
                Iterator<Object> iter = null;

                if (dispatcher != null)
                    iter = dispatcher.childs[this];

                m_State = value;

                if (dispatcher != null && iter != null)
                    dispatcher.childs.check (iter);
            }
        }
    }

    internal int sleep_fd {
        get {
            return m_SleepFd;
        }
    }

    // Methods

    /**
     * Create a new Task
     *
     * @param inPriority task priority
     */
    public Task (Priority inPriority = Priority.NORMAL)
    {
        running = new Notification<void> ("running");
        finished = new Notification<void> ("finished");

        m_Priority = inPriority;
        m_State = State.READY;
    }

    ~Task ()
    {
        if (m_SleepFd >= 0) Posix.close (m_SleepFd);
        m_SleepFd = -1;
        parent = null;
    }

    /**
     * Runs a task until finish() is called. 
     */
    public virtual void*
    run ()
    {
        state = State.RUNNING;

        running.post ();

        return null;
    }

    /**
     * Finish a task
     */
    public virtual void
    finish ()
    {
        state = State.TERMINATED;

        finished.post ();
    }

    /**
     * Sleeping a task inTimeout milliseconds
     *
     * @param inTimeout sleeping tim in milliseconds
     */
    public virtual void
    sleep (ulong inTimeout)
    {
        if (parent != null)
        {
            wakeup ();

            ulong ustime = inTimeout * 1000;
            Os.ITimerSpec itimer_spec = Os.ITimerSpec ();
            itimer_spec.it_value.tv_sec = (time_t)(ustime / 1000000);
            itimer_spec.it_value.tv_nsec = (long)(1000 * (ustime % 1000000));

            m_SleepFd = Os.TimerFd (Os.CLOCK_MONOTONIC, Os.TFD_CLOEXEC);
            m_SleepFd.settime (0, itimer_spec, null);

            (parent as Dispatcher).sleep (this);

            state = State.SLEEPING;
        }
    }

    /**
     * Wakeup a sleeping task
     */
    public virtual void
    wakeup ()
    {
        if (parent != null && m_SleepFd >= 0)
        {
            if (m_State == State.SLEEPING)
                m_State = State.READY;

            (parent as Dispatcher).wakeup (this);

            Posix.close (m_SleepFd);
            m_SleepFd = -1;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override int
    compare (Object inOther)
        requires (inOther is Task)
    {
        int ret = 0;

        if (m_State < ((Task)inOther).m_State)
            ret = 1;
        else if (m_State > ((Task)inOther).m_State)
            ret = -1;
        else if (m_Priority < ((Task)inOther).m_Priority)
            ret =  -1;
        else if (m_Priority > ((Task)inOther).m_Priority)
            ret = 1;

        return ret;
    }
}

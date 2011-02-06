/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * task.vala
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
    private bool                       m_Thread;
    private unowned GLib.Thread<void*> m_ThreadId = null;
    private Priority                   m_Priority;
    private State                      m_State = State.READY;
    private Os.TimerFd                 m_SleepFd = -1;

    // Signals
    public signal void running  ();
    public signal void finished ();

    // Accessors

    /**
     * Task is threaded
     */
    public bool is_thread {
        get {
            return m_Thread;
        }
    }

    /**
     * Task thread id
     */
    public GLib.Thread<void*> thread_id {
        get {
            return m_ThreadId;
        }
    }

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
    public Task (Priority inPriority = Priority.NORMAL, bool inThread = false)
    {
        m_Thread    = inThread;
        m_Priority  = inPriority;
    }

    ~Task ()
    {
        if (m_SleepFd >= 0) Posix.close (m_SleepFd);
        m_SleepFd = -1;
    }

    /**
     * Runs a task until finish() is called. 
     */
    public virtual void
    run ()
    {
        if (m_Thread)
        {
            try
            {
                audit (GLib.Log.METHOD, "Start task has thread");
                m_ThreadId = GLib.Thread.create<void*> (main, true);
            }
            catch (GLib.ThreadError error)
            {
                Maia.error (GLib.Log.METHOD, "%s", error.message);
            }
        }
        else
        {
            if (m_ThreadId == null) m_ThreadId = GLib.Thread.self<void*> ();

            audit (GLib.Log.METHOD, "Start task has main");
            main ();
        }
    }

    /**
     * Runs a task until finish() is called. 
     */
    protected virtual void*
    main ()
    {
        state = State.RUNNING;

        running ();

        return null;
    }

    /**
     * Finish a task
     */
    public virtual void
    finish ()
    {
        state = State.TERMINATED;

        finished ();
    }

    /**
     * Sleeping a task inTimeout milliseconds
     *
     * @param inTimeout sleeping time in milliseconds
     */
    public virtual void
    sleep (ulong inTimeout = 0)
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

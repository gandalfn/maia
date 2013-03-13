/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * task.vala
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

public class Maia.Task : Object
{
    // types
    public enum State
    {
        UNKNOWN,
        TERMINATED,
        WAITING,
        RUNNING,
        READY;

        public string
        to_string ()
        {
            switch (this)
            {
                case TERMINATED:
                    return "terminated";
                case WAITING:
                    return "waiting";
                case RUNNING:
                    return "running";
                case READY:
                    return "ready";
            }

            return "unknown";
        }
    }

    // properties
    private int   m_Priority;
    private State m_State = State.WAITING;

    // accessors
    /**
     * Task priority
     */
    public int priority {
        get {
            return m_Priority;
        }
        construct set {
            if (m_Priority != value)
            {
                m_Priority = value;
                reorder ();
            }
        }
    }

    /**
     * Task state
     */
    [CCode (notify = false)]
    public State state {
        get {
            return m_State;
        }
        construct set {
            if (m_State != value)
            {
                m_State = value;
                reorder ();

                if (m_State == State.READY && parent != null && parent is Dispatcher)
                {
                    Log.debug ("set state", "wake up task");
                    Dispatcher.MessageWakeUp (parent as Dispatcher).post ();
                }
            }
        }
    }

    // methods
    /**
     * Create a new Task
     *
     * @param inPriority task priority
     */
    public Task (int inPriority = GLib.Priority.DEFAULT)
    {
        m_Priority  = inPriority;
    }

    /**
     * Run a task.
     */
    public virtual void
    run ()
    {
        Log.audit (GLib.Log.METHOD, "Run 0x%lx", (ulong)this);
        state = State.WAITING;
    }

    /**
     * Start a task
     */
    public virtual void
    start ()
    {
        Log.audit (GLib.Log.METHOD, "Start 0x%lx", (ulong)this);
        state = State.READY;
    }

    /**
     * Stop a task
     */
    public virtual void
    stop ()
    {
        Log.audit (GLib.Log.METHOD, "Finish 0x%lx", (ulong)this);
        state = State.TERMINATED;
    }

    /**
     * {@inheritDoc}
     */
    internal override int
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

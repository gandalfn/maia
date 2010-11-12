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
        RUNNING,
        SLEEPING,
        READY
    }

    public delegate void Func ();

    // Properties
    private Func m_Func;
    private Priority m_Priority;
    private State m_State = State.UNKNOWN;
    internal int wait_fd;

    // Accessors
    public Priority priority {
        get {
            return m_Priority;
        }
    }

    public State state {
        get {
            return m_State;
        }
        internal set {
            m_State = value;
        }
    }

    // Methods
    public Task (Func? inFunc, Priority inPriority = Priority.NORMAL)
    {
        m_Func = inFunc;
        m_Priority = inPriority;
        m_State = State.READY;
    }

    ~Task ()
    {
        if (wait_fd >= 0) Posix.close (wait_fd);
    }

    public virtual void*
    run ()
    {
        m_State = State.RUNNING;

        if (m_Func != null) m_Func ();

        return null;
    }

    public virtual void
    finish ()
    {
        m_State = State.TERMINATED;
    }
    
    public void
    sleep (ulong inTimeout)
    {
        if (parent != null)
        {
            (parent as Dispatcher).sleep (this, inTimeout);
            m_State = State.SLEEPING;
        }
    }

    public override int
    compare (Object inOther)
        requires (inOther is Task)
    {
        int ret = 0;

        if (m_State > ((Task)inOther).m_State)
            ret = 1;
        else if (m_State < ((Task)inOther).m_State)
            ret = -1;
        else if (m_Priority < ((Task)inOther).m_Priority)
            ret =  -1;
        else if (m_Priority > ((Task)inOther).m_Priority)
            ret = 1;

        return ret;
    }
}

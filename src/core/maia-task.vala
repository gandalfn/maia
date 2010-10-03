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

public class Maia.Task : GLib.Object
{
    public enum Priority
    {
        HIGH = -20,
        NORMAL = 0,
        LOW = 20
    }

    public enum State
    {
        UNKNOWN,
        READY,
        SLEEPING,
        RUNNING,
        TERMINATED
    }

    public delegate void Func ();

    private Func m_Func;

    private Priority m_Priority;
    public Priority priority {
        get {
            return m_Priority;
        }
    }

    private State m_State = State.UNKNOWN;
    public State state {
        get {
            return m_State;
        }
        internal set {
            m_State = value;
        }
    }

    public Task (Func inFunc, Priority inPriority = Priority.NORMAL)
    {
        m_Func = inFunc;
        m_Priority = inPriority;
    }

    internal virtual void
    init ()
    {
        m_State = State.READY;
    }

    internal virtual void*
    run ()
    {
        m_State = State.RUNNING;
        m_Func ();

        return null;
    }

    internal virtual void
    finish ()
    {
        m_State = State.TERMINATED;
    }
    
    internal static int
    compare (Task inA, Task inB)
    {
        if (inA.m_Priority < inB.m_Priority)
            return -1;
        else if (inA.m_Priority > inB.m_Priority)
            return 1;
        else
            return 0;
    }

    public void
    sleep (int inMs)
    {
        m_State = State.SLEEPING;
    }
}

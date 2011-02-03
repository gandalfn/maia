/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-args.vala
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

internal class Maia.EventArgs
{
}

internal class Maia.EventArgsR<R> : EventArgs
{
    // properties
    private R                 m_Ret;
    private AccumulateFunc<R> m_AccumulateFunc;

    // accessors
    public R ret {
        get {
            lock (m_Ret)
            {
                return m_Ret;
            }
        }
        set {
            lock (m_Ret)
            {
                m_Ret = m_AccumulateFunc (m_Ret, value);
            }
        }
    }

    public AccumulateFunc<R> accumulate_func {
        set {
            m_AccumulateFunc = value;
        }
    }

    // methods
    public EventArgsR ()
    {
        m_AccumulateFunc = get_accumulator_func_for<R> ();
    }
}

internal class Maia.EventArgs1<A> : EventArgs
{
    // properties
    public A m_A;

    // methods
    public EventArgs1(A inA)
    {
        m_A = inA;
    }
}

internal class Maia.EventArgsR1<R, A> : EventArgsR<R>
{
    // properties
    public A m_A;

    // methods
    public EventArgsR1(A inA)
    {
        m_A = inA;
    }
}
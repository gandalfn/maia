/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * async-queue.vala
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

public class Maia.Core.AsyncQueue<V> : Queue<V>
{
    // properties
    private uint       m_WaitingThreads = 0;
    private GLib.Mutex m_Mutex = GLib.Mutex ();
    private GLib.Cond  m_Cond  = GLib.Cond ();

    // methods
    public AsyncQueue ()
    {
        base ();
    }

    public unowned V?
    peek_timed (uint inWait = 0)
    {
        unowned V? ret = null;

        m_Mutex.lock ();
        {
            m_WaitingThreads++;
            while ((ret = base.peek ()) == null)
            {
                if (inWait == 0)
                {
                    m_Cond.wait (m_Mutex);
                }
                else if (!m_Cond.wait_until (m_Mutex, GLib.get_monotonic_time () + inWait * GLib.TimeSpan.MILLISECOND))
                {
                    break;
                }
            }
            m_WaitingThreads--;
        }
        m_Mutex.unlock ();

        return ret;
    }

    public override unowned V?
    peek ()
    {
        return peek_timed (0);
    }

    public V?
    pop_timed (uint inWait = 0)
    {
        V? ret = null;

        m_Mutex.@lock ();
        {
            m_WaitingThreads++;
            while ((ret = base.pop ()) == null)
            {
                if (inWait == 0)
                {
                    m_Cond.wait (m_Mutex);
                }
                else if (!m_Cond.wait_until (m_Mutex, GLib.get_monotonic_time () + inWait * GLib.TimeSpan.MILLISECOND))
                {
                    break;
                }
            }
            m_WaitingThreads--;
        }
        m_Mutex.unlock ();

        return ret;
    }

    public override V?
    pop ()
    {
        return pop_timed (0);
    }

    public override void
    push (V inVal)
    {
        m_Mutex.@lock ();
        {
            base.push (inVal);

            if (m_WaitingThreads > 0)
            {
                m_Cond.@signal ();
            }
        }
        m_Mutex.unlock ();
    }
}

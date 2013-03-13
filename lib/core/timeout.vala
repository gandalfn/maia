/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * timeout.vala
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

public class Maia.Timeout : Task
{
    // types
    public delegate bool ElapsedFunc ();

    // properties
    private uint64      m_StartTime;
    private ulong       m_Interval;
    private long        m_Delay;
    private ElapsedFunc m_Callback;

    // accessors
    public long delay {
        get {
            return m_Delay;
        }
    }

    // methods
    /**
     * Create a new Timeout
     *
     * @param inTimeoutMs timeout in milliseconds
     * @param inPriority timeout priority
     */
    internal Timeout (ulong inTimeoutMs, owned ElapsedFunc inFunc, int inPriority = GLib.Priority.DEFAULT)
    {
        base (inPriority);

        m_Interval = inTimeoutMs;
        m_Callback = (owned)inFunc;
    }

    private inline ulong
    get_ticks (uint64 inCurrentTime)
    {
        return (ulong)(inCurrentTime - m_StartTime) / 1000;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    start ()
    {
        m_StartTime = GLib.get_monotonic_time ();
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    run ()
    {
        if (m_Callback ())
        {
            base.run ();
        }
        else
            state = Task.State.TERMINATED;
    }

    /**
     * {@inheritDoc}
     */
    internal override int
    compare (Object inOther)
    {
        if (inOther is Timeout)
        {
            unowned Timeout other = inOther as Timeout;
            int diff = (int)(m_Delay - other.m_Delay);
            if (diff == 0)
                return compare (inOther);

            return diff;
        }

        return compare (inOther);
    }

    internal void
    prepare (uint64 inCurrentTime)
    {
        ulong elapsed_time = get_ticks (inCurrentTime);
        double diff = (double)elapsed_time / (double)m_Interval;

        if (diff >= 1.0)
        {
            m_StartTime += (uint64)(((int)diff * m_Interval) * 1000.0);

            m_Delay = 0;
        }
        else
        {
            m_Delay = int.max (((int)m_Interval - ((int)elapsed_time % (int)m_Interval)), 0);
        }

        if (m_Delay == 0)
        {
            state = Task.State.READY;
        }
        else
        {
            reorder ();
        }
    }
}

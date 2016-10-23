/* -*- Mode: Vala indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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

[Flags]
private enum Maia.Core.TimeoutFlags
{
    NONE = 0,
    READY = 1 << 1
}

internal class Maia.Core.Timeout : Object
{
    private TimeoutFlags m_Flags;

    internal TimeoutInterval interval;
    internal TimeoutFunc callback;
    internal void* data;
    internal new DestroyNotify notify;

    [CCode (notify = false)]
    internal bool ready {
        get {
            return (m_Flags & TimeoutFlags.READY) == TimeoutFlags.READY;
        }
        set {
            if (value)
                m_Flags |= TimeoutFlags.READY;
            else
                m_Flags &= ~(int)TimeoutFlags.READY;

            reorder ();
        }
    }

    internal Timeout (uint inFps)
    {
        interval = new TimeoutInterval (inFps);
        m_Flags = TimeoutFlags.NONE;
    }

    ~Timeout ()
    {
        if (notify != null) notify (data);
    }

    internal override int
    compare (Object inOther)
        requires (inOther is Timeout)
    {
        Timeout other = (Timeout)inOther;

        /* Keep 'ready' timeouts at the front */
        if (ready) return -1;

        if (other.ready) return 1;

        return interval.compare (other.interval);
    }

    internal bool
    prepare (Source inSource, out int outNextTimeout)
    {
        uint64 now = inSource.get_time();

        return interval.prepare(now, out outNextTimeout);
    }
}

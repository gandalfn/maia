/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * timeout-pool.vala
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

internal class Maia.Core.TimeoutPool : Object
{
    private Source        m_Source;
    private uint64        m_StartTime;
    private List<Timeout> m_Readys;

    public TimeoutPool (int inPriority = GLib.Priority.DEFAULT, GLib.MainContext? inContext = null)
    {
        m_Source = new Source (prepare, check, dispatch);
        m_Source.attach (inContext);
        m_StartTime = m_Source.get_time();
        m_Source.set_priority (inPriority);
        m_Readys = new List<Timeout> ();
    }

    private bool
    prepare (out int outTimeOut)
    {
        bool ret = false;

        if (first () != null)
        {
            Timeout timeout = (Timeout)first ();
            ret = timeout.prepare (m_Source, out outTimeOut);
            if (ret)
            {
                timeout.ready = true;
            }
        }
        else
        {
            outTimeOut = -1;
        }

        return ret;
    }

    private bool
    check ()
    {
        foreach (unowned Object child in this)
        {
            Timeout timeout = (Timeout)child;

            int val;
            if (timeout.ready || timeout.prepare (m_Source, out val))
            {
                m_Readys.insert (timeout);
            }
            else
                break;
        }

        foreach (unowned Timeout timeout in m_Readys)
        {
            timeout.ready = true;
        }

        return m_Readys.length > 0;
    }

    private bool
    dispatch (SourceFunc inCallback)
    {
        if (m_Readys.length <= 0) check ();

        foreach (unowned Timeout timeout in m_Readys)
        {
            timeout.interval.dispatch(timeout.callback, timeout.data);
        }

        foreach (unowned Timeout timeout in m_Readys)
        {
            timeout.ready = false;
        }

        m_Readys.clear ();

        return true;
    }

    public void
    set_priority (int inPriority)
    {
        m_Source.set_priority (inPriority);
    }

    public Timeout
    add_timeout (uint inFps, TimeoutFunc inFunc, void* inData, DestroyNotify? inNotify)
    {
        Timeout timeout = new Timeout (inFps);

        timeout.callback = inFunc;
        timeout.data = inData;
        timeout.notify = inNotify;
        timeout.parent = this;

        return timeout;
    }
}

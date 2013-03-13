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

internal class Maia.TimeoutPool : Object
{
    // properties
    private GLib.Source m_Source;

    // methods
    /**
     * Create a new timeout pool
     *
     * @param inContext the MainContext where timeout pool run on
     * @param inPriority watch priority
     */
    public TimeoutPool (GLib.MainContext? inContext = null, int inPriority = GLib.Priority.DEFAULT)
    {
        m_Source = new Source (on_prepare, on_check, on_dispatch);
        m_Source.set_priority (inPriority);

        m_Source.attach (inContext);
    }

    ~TimeoutPool ()
    {
        m_Source.destroy ();
    }

    private bool
    on_prepare (out int outTimeout)
    {
        bool ret = false;
        Object.Iterator iter = iterator ();
        unowned Timeout child = iter.get () as Timeout;

        outTimeout = -1;

        while (child != null)
        {
            unowned Timeout next = iter.next_value () as Timeout;
            child.prepare (m_Source.get_time ());
            if (child.state != Task.State.READY)
            {
                if (!ret) outTimeout = (int)child.delay;
                break;
            }
            else
            {
                outTimeout = 0;
                ret = true;
            }
            child = next;
        }

        return ret;
    }

    private bool
    on_check ()
    {
        unowned Timeout child = first () as Timeout;
        return child != null && child.state == Task.State.READY;
    }

    private bool
    on_dispatch (SourceFunc inCallback)
    {
        Object.Iterator iter = iterator ();
        unowned Timeout child = iter.get () as Timeout;

        while (child != null)
        {
            unowned Timeout next = iter.next_value () as Timeout;
            if (child.state == Task.State.READY)
            {
                child.run ();
            }
            else
            {
                break;
            }
            child = next;
        }

        return true;
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Timeout;
    }
}

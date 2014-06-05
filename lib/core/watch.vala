/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * watch.vala
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

public abstract class Maia.Core.Watch : Object
{
    // properties
    private Source            m_Source;
    private GLib.MainContext? m_Context;
    private int               m_Priority;
    private GLib.PollFD       m_Fd = GLib.PollFD ();

    // accessors
    /**
     * File descriptor watched
     */
    public int fd {
        get {
            return m_Fd.fd;
        }
    }

    // methods
    /**
     * Create a new File descriptor watcher
     *
     * @param inFd file descriptor to watch
     * @param inPriority watch priority
     */
    public Watch (int inFd, GLib.MainContext? inContext = null, int inPriority = GLib.Priority.DEFAULT)
    {
        m_Fd.fd = inFd;
        m_Fd.events = GLib.IOCondition.IN  | GLib.IOCondition.PRI |
                      GLib.IOCondition.ERR | GLib.IOCondition.HUP | GLib.IOCondition.NVAL;
        m_Fd.revents = 0;

        m_Context = inContext;
        m_Priority = inPriority;

        start ();
    }

    ~Watch ()
    {
        stop ();
    }

    private bool
    check ()
    {
        if ((m_Fd.revents & GLib.IOCondition.ERR)  == GLib.IOCondition.ERR ||
            (m_Fd.revents & GLib.IOCondition.HUP)  == GLib.IOCondition.HUP ||
            (m_Fd.revents & GLib.IOCondition.NVAL) == GLib.IOCondition.NVAL)
        {
            on_error ();
            return false;
        }

        return ((m_Fd.revents & GLib.IOCondition.IN)  == GLib.IOCondition.IN ||
                (m_Fd.revents & GLib.IOCondition.PRI) == GLib.IOCondition.PRI);
    }

    private bool
    on_dispatch (SourceFunc inCallback)
    {
        return on_process ();
    }

    protected virtual bool
    on_prepare (out int outTimeout)
    {
        outTimeout = -1;

        return check ();
    }

    protected virtual bool
    on_check ()
    {
        return check ();
    }

    /**
     * Called when an error occur on fd
     */
    protected abstract void on_error ();

    /**
     * Called when a data has been available on fd
     */
    protected abstract bool on_process ();

    /**
     * Start watch
     */
    public void
    start ()
    {
        if (m_Source == null)
        {
            m_Source = new Source (on_prepare, on_check, on_dispatch);
            m_Source.add_poll (ref m_Fd);
            m_Source.set_can_recurse (true);
            m_Source.set_priority (m_Priority);

            m_Source.attach (m_Context);
        }
    }

    /**
     * Stop watch
     */
    public void
    stop ()
    {
        if (m_Source != null)
        {
            m_Source.destroy ();
            m_Source = null;
        }
    }
}

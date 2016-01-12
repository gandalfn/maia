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
    // type
    public enum Condition
    {
        IN,
        OUT
    }

    public class Notification : Core.Notification
    {
        public bool @continue { get; set; default = false; }

        public Notification (string inName)
        {
            base (inName);
        }
    }

    // properties
    private Condition         m_Condition = Condition.IN;
    private Source            m_Source;
    private GLib.MainContext? m_Context;
    private int               m_Priority;
    private GLib.PollFD       m_Fd = GLib.PollFD ();
    private uint64            m_CurrentTime;
    private bool              m_TimedOut = false;

    // accessors
    /**
     * File descriptor watched
     */
    public int fd {
        get {
            return m_Fd.fd;
        }
    }

    /**
     * Indicate is watch for which Condiition
     */
    public Condition condition {
        get {
            return m_Condition;
        }
    }

    /**
     * Time in milliseconds to wait before watch timed out
     */
    public int timeout { get; set; default = -1; }


    /**
     * Indicate if watch is currently running
     */
    public bool is_started {
        get {
            return m_Source != null;
        }
    }

    // methods
    construct
    {
        notifications.add (new Notification ("ready"));
        notifications.add (new Notification ("timeout"));
    }

    /**
     * Create a new File descriptor watcher
     *
     * @param inFd file descriptor to watch
     * @param inCondition watch condition
     * @param inContext main context
     * @param inPriority watch priority
     */
    public Watch (int inFd, Condition inCondition = Condition.IN, GLib.MainContext? inContext = null, int inPriority = GLib.Priority.DEFAULT)
    {
        m_Condition = inCondition;
        m_Fd.fd = inFd;
        if (m_Condition == Condition.IN)
        {
            m_Fd.events = GLib.IOCondition.IN  | GLib.IOCondition.PRI |
                          GLib.IOCondition.ERR | GLib.IOCondition.HUP | GLib.IOCondition.NVAL;
        }
        else
        {
            m_Fd.events = GLib.IOCondition.OUT |
                          GLib.IOCondition.ERR | GLib.IOCondition.HUP | GLib.IOCondition.NVAL;
        }

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
    on_dispatch (SourceFunc inCallback)
    {
        ref ();

        bool ret = false;

        if (timeout >= 0 && m_TimedOut)
        {
            ret = on_timeout ();
            m_TimedOut = false;
        }
        else
        {
            ret = on_process ();
        }

        if (!ret)
        {
            m_Source = null;
        }
        else if (timeout >= 0)
        {
            m_CurrentTime = m_Source.get_time();
        }

        unref ();

        return ret;
    }

    private bool
    on_prepare (out int outTimeout)
    {
        m_TimedOut = false;
        if (timeout >= 0)
        {
            m_CurrentTime = m_Source.get_time();
        }

        outTimeout = timeout;

        ref ();
        bool ret = check ();
        unref ();

        return ret;
    }

    private bool
    on_check ()
    {
        bool ret = false;

        ref ();
        uint64 now = m_Source.get_time ();
        if (timeout >= 0 && (now - m_CurrentTime) / 1000 > timeout)
        {
            m_TimedOut = true;
            ret = true;
        }
        else if ((m_Fd.revents & GLib.IOCondition.ERR)  == GLib.IOCondition.ERR ||
                 (m_Fd.revents & GLib.IOCondition.HUP)  == GLib.IOCondition.HUP ||
                 (m_Fd.revents & GLib.IOCondition.NVAL) == GLib.IOCondition.NVAL)
        {
            on_error ();
        }
        else if (m_Condition == Condition.IN ? ((m_Fd.revents & GLib.IOCondition.IN)  == GLib.IOCondition.IN ||
                                                (m_Fd.revents & GLib.IOCondition.PRI) == GLib.IOCondition.PRI)
                                             : (m_Fd.revents & GLib.IOCondition.OUT)  == GLib.IOCondition.OUT)
        {
            ret = check ();
        }
        unref ();

        return ret;
    }

    /**
     * Called when an error occur on fd
     */
    protected abstract void on_error ();

    /**
     * Called when a time out occur on fd
     */
    protected virtual bool
    on_timeout ()
    {
        unowned Notification notification = notifications["timeout"] as Notification;
        notification.@continue = false;
        notification.post ();
        return notification.@continue;
    }

    /**
     * Called when a data has been available on fd
     */
    protected virtual bool
    on_process ()
    {
        unowned Notification notification = notifications["ready"] as Notification;
        notification.@continue = false;
        notification.post ();
        return notification.@continue;
    }

    /**
     * Called to verify if watch is ready
     *
     * @return  ``true`` if watch is ready
     */
    public abstract bool check ();

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

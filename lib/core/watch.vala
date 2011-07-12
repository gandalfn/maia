/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * watch.vala
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

public class Maia.Watch : Task
{
    // Types
    public enum Flags
    {
        NONE = 0,
        IN   = 1 << 0,
        OUT  = 1 << 1,
        ERR  = 1 << 2
    }

    // Properties
    private int m_Fd;
    private int m_WatchFd;
    private Flags m_Flags = Flags.NONE;

    // Accessors

    /**
     * {@inheritDoc}
     */
    [CCode (notify = false)]
    public override Object parent {
        get {
            return base.parent;
        }
        construct set {
            if (base.parent != value)
            {
                if (base.parent != null)
                    ((Dispatcher)base.parent).remove_watch (this);

                base.parent = value;

                if (value != null)
                    ((Dispatcher)value).add_watch (this);
            }
        }
    }

    /**
     * File descriptor watched
     */
    public int fd {
        get {
            return m_Fd;
        }
    }

    internal virtual int watch_fd {
        get {
            if (m_WatchFd < 0) m_WatchFd = Os.dup (m_Fd);
            return m_WatchFd;
        }
    }

    /**
     * Watch flags
     */
    public Flags flags {
        get {
            return m_Flags;
        }
    }

    // Methods

    /**
     * Create a new File descriptor watcher
     *
     * @param inFd file descriptor to watch
     * @param inPriority watch priority
     */
    public Watch (int inFd, Flags inFlags, Task.Priority inPriority = Task.Priority.NORMAL)
    {
        base (inPriority);

        m_Fd = inFd;
        m_Flags = inFlags;
        m_WatchFd = -1;
        state = Task.State.WAITING;
    }

    ~Watch ()
    {
        if (m_WatchFd >= 0) Os.close (m_WatchFd);
        m_WatchFd = -1;
    }

    /**
     * {@inheritDoc}
     */
    internal override void*
    main ()
    {
        void* ret = base.main ();

        state = Task.State.WAITING;

        return ret;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    sleep (ulong inTimeoutMs)
    {
        base.sleep (inTimeoutMs);
        if (parent != null)
        {
            (parent as Dispatcher).remove_watch (this);
        }
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    wakeup ()
    {
        base.wakeup ();
        if (parent != null)
        {
            (parent as Dispatcher).add_watch (this);
            state = Task.State.WAITING;
        }
    }

    internal virtual void
    close_watch_fd ()
    {
        if (m_WatchFd >= 0) Os.close (m_WatchFd);
        m_WatchFd = -1;
    }
}
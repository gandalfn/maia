/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-watch.vala
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

public class Maia.Watch : Task
{
    // Types
    public enum Flags
    {
        IN  = 1 << 0,
        OUT = 1 << 1,
        ERR = 1 << 2
    }

    // Properties
    private int m_Fd;
    private int m_WatchFd;
    private Flags m_Flags;

    // Accessors

    /**
     * {@inheritDoc}
     */
    public override Object parent {
        get {
            return base.parent;
        }
        set {
            if (base.parent != null)
                ((Dispatcher)base.parent).remove_watch (this);

            base.parent = value;

            if (value != null)
                ((Dispatcher)value).add_watch (this);
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
            if (m_WatchFd < 0) m_WatchFd = Posix.dup (m_Fd);
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
        if (m_WatchFd >= 0) Posix.close (m_WatchFd);
        m_WatchFd = -1;
    }

    /**
     * {@inheritDoc}
     */
    public override void*
    run ()
    {
        void* ret = base.run ();

        state = Task.State.WAITING;

        return ret;
    }

    public override void
    sleep (ulong inTimeoutMs)
    {
        base.sleep (inTimeoutMs);
        close_watch_fd ();
    }

    public override void
    wakeup ()
    {
        state = Task.State.WAITING;
        base.wakeup ();
    }

    internal virtual void
    close_watch_fd ()
    {
        if (m_WatchFd >= 0) Posix.close (m_WatchFd);
        m_WatchFd = -1;
    }
}
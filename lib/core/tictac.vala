/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tictac.vala
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

public class Maia.TicTac : Watch
{
    // properties
    private uint        m_Fps;
    private uint        m_FrameCount = 0;
    private Os.TimeSpec m_StartTime;
    private bool        m_WatchSet = false;

    // signals
    public signal bool bell ();

    // Accessors
    internal override int watch_fd {
        get {
            if (!m_WatchSet)
            {
                Os.TimeSpec current_time = Os.TimeSpec ();
                Os.clock_gettime (Os.CLOCK_MONOTONIC, out current_time);

                uint elapsed = get_ticks (current_time);
                uint new_frame_num = elapsed * m_Fps / 1000;
                int delay = 0;

                if (new_frame_num < m_FrameCount || new_frame_num - m_FrameCount > 2)
                {
                    ulong frame_time = ((1000 + m_Fps - 1) / m_Fps) * 1000;

                    m_StartTime = current_time;
                    m_StartTime.tv_sec = current_time.tv_sec - (time_t)(frame_time / 1000000);
                    m_StartTime.tv_nsec = current_time.tv_nsec - (long)(1000 * (frame_time % 1000000));
                    m_FrameCount = 0;
                    delay = 100;
                }
                else if (new_frame_num > m_FrameCount)
                {
                    delay = 100;
                }
                else
                {
                    delay = (int)(((m_FrameCount + 1) * 1000 / m_Fps - elapsed) * 1000);
                }

                Os.ITimerSpec itimer_spec = Os.ITimerSpec ();
                itimer_spec.it_value.tv_sec = (time_t)(delay / 1000000);
                itimer_spec.it_value.tv_nsec = (long)(1000 * (delay % 1000000));

                ((Os.TimerFd)fd).settime (0, itimer_spec, null);

                m_WatchSet = true;
            }

            return fd;
        }
    }

    // methods
    public TicTac (uint inFps, Task.Priority inPriority = Task.Priority.NORMAL)
    {
        Os.TimerFd timer_fd = Os.TimerFd (Os.CLOCK_MONOTONIC, Os.TFD_CLOEXEC);

        base (timer_fd, Watch.Flags.IN, inPriority);

        m_Fps = inFps;
        Os.clock_gettime (Os.CLOCK_MONOTONIC, out m_StartTime);
    }

    private inline uint
    get_ticks (Os.TimeSpec inCurrentTime)
    {
        return (uint)((inCurrentTime.tv_sec - m_StartTime.tv_sec) * 1000 + 
                      (inCurrentTime.tv_nsec - m_StartTime.tv_nsec) / 1000000);
    }

    /**
     * {@inheritDoc}
     */
    internal override void*
    main ()
        requires (parent != null)
    {
        (parent as Dispatcher).remove_watch (this);

        void* ret = base.main ();

        if (bell ())
        {
            ++m_FrameCount;
            (parent as Dispatcher).add_watch (this);
        }
        else
        {
            finish ();
        }

        return ret;
    }

    internal override void
    close_watch_fd ()
    {
        if (m_WatchSet)
        {
            Os.ITimerSpec itimer_spec = Os.ITimerSpec ();
            ((Os.TimerFd)fd).settime (0, itimer_spec, null);
            m_WatchSet = false;
        }
    }
}
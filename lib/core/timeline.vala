/* -*- Mode: Vala indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * timeline.vala
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

public enum Maia.Core.TimelineDirection
{
    FORWARD,
    BACKWARD
}

public class Maia.Core.Timeline : Object
{
    // types
    public class NewFrameNotification : Core.Notification
    {
        [CCode (notify = false)]
        public uint num_frame { get; set; default = 0; }

        public NewFrameNotification (string inName)
        {
            base (inName);
        }

        public new void
        post (uint inNumFrame)
        {
            num_frame = inNumFrame;
            base.post ();
        }
    }

    // static properties
    static GLib.Private s_TimeoutPool;

    static bool        s_HaveDefault = false;
    static int         s_DefaultPriority = 0;

    // properties
    private Timeout?          m_Timeout = null;
    private TimelineDirection m_Direction = TimelineDirection.FORWARD;
    private int               m_CurrentFrameNum = 0;
    private uint              m_Fps = 60;
    private uint              m_NFrames = 0;
    private uint              m_Duration = 0;
    private TimeVal           m_PrevFrameTimeVal;

    private unowned Core.Notification    m_StartedNotification;
    private unowned Core.Notification    m_PausedNotification;
    private unowned NewFrameNotification m_NewFrameNotification;
    private unowned Core.Notification    m_CompletedNotification;

    /**
     * Timeline direction
     */
    public TimelineDirection direction {
        get {
            return m_Direction;
        }
        set {
            if (m_Direction != value)
            {
                m_Direction = value;
                if (m_CurrentFrameNum == 0) m_CurrentFrameNum = (int)m_NFrames;
            }
        }
    }

    /**
     * Timeline speed in frame per second
     */
    public uint speed {
        get {
            return m_Fps;
        }
        set {
            if (m_Fps != value)
            {
                m_Fps = value;
                if (m_Timeout != null)
                {
                    m_Timeout.parent = null;
                    m_Timeout = null;
                    add_timeout ();
                }
            }
        }
    }

    /**
     * Number of frame in Timeline
     */
    public uint n_frames { get; set; default = 0; }

    /**
     * Timeline duration in msecs
     */
    public uint duration {
        get {
            return m_Duration;
        }
        set {
            if (m_Duration != value)
            {
                m_Duration = value;
                n_frames = m_Duration * m_Fps / 1000;
            }
        }
    }

    /**
     * Timeline loop
     */
    public bool loop { get; set; default = false; }

    /**
     * Indicate if timeline is currently running
     */
    public bool is_playing {
        get {
            return m_Timeout != null;
        }
    }

    /**
     * Current frame
     */
    public uint current_frame {
        get {
            return m_CurrentFrameNum;
        }
    }

    /**
     * Timeline progress
     */
    public double progress {
        get {
            if (!is_playing)
            {
                if (m_Direction == TimelineDirection.FORWARD)
                    return 0.0;
                else
                    return 1.0;
            }

            return ((double)m_CurrentFrameNum / (double)n_frames).clamp (0.0, 1.0);
        }
    }

    // notifications
    public unowned Core.Notification started {
        get {
            return m_StartedNotification;
        }
    }

    public unowned Core.Notification paused {
        get {
            return m_PausedNotification;
        }
    }

    public unowned NewFrameNotification new_frame {
        get {
            return m_NewFrameNotification;
        }
    }

    public unowned Core.Notification completed {
        get {
            return m_CompletedNotification;
        }
    }

    // static methods
    static construct
    {
        s_TimeoutPool = new GLib.Private (GLib.Object.unref);
    }


    public static void
    initialize (int inPriority)
    {
        s_DefaultPriority = inPriority;
        s_HaveDefault = true;
    }

    // methods
    construct
    {
        m_StartedNotification = notifications.add (new Core.Notification ("started"));
        m_PausedNotification = notifications.add (new Core.Notification ("paused"));
        m_NewFrameNotification = notifications.add (new NewFrameNotification ("new-frame")) as NewFrameNotification;
        m_CompletedNotification = notifications.add (new Core.Notification ("completed"));
    }

    /**
     * Construct a new timeline
     *
     * @param inNbFrames number of frames
     * @param inFps timeline speed in frame per second
     */
    public Timeline (uint inNbFrames, uint inFps)
    {
        GLib.Object (speed: inFps, n_frames: inNbFrames);
    }


    /**
     * Construct a new timeline from duration
     *
     * @param inDuration timeline duration
     */
    public Timeline.for_duration (uint inDuration)
    {
        GLib.Object (duration: inDuration);
    }

    ~Timeline ()
    {
        if (m_Timeout != null)
        {
            m_Timeout.parent = null;
            m_Timeout = null;
        }
    }

    private static unowned TimeoutPool?
    get_timeout_pool ()
    {
        unowned TimeoutPool? pool = (TimeoutPool?)s_TimeoutPool.get ();
        if (pool == null)
        {
            var new_pool = new TimeoutPool (s_HaveDefault ? s_DefaultPriority : Priority.HIGH, GLib.MainContext.get_thread_default ());
            s_TimeoutPool.set (new_pool);
            new_pool.ref ();
            pool = new_pool;
        }

        return pool;
    }

    private void
    add_timeout ()
    {
        if (m_PrevFrameTimeVal.tv_sec == 0)
            m_PrevFrameTimeVal.get_current_time ();

        m_Timeout = get_timeout_pool ().add_timeout (m_Fps, on_timeout, this, null);
    }

    private inline bool
    is_complete ()
    {
        return ((m_Direction == TimelineDirection.FORWARD) && (m_CurrentFrameNum >= n_frames)) ||
               ((m_Direction == TimelineDirection.BACKWARD) && (m_CurrentFrameNum <= 0));
    }

    private bool
    on_timeout ()
    {
        GLib.TimeVal now = GLib.TimeVal ();
        uint n_frames;
        ulong msecs, speed;

        now.get_current_time ();

        if (m_PrevFrameTimeVal.tv_sec == 0)
            m_PrevFrameTimeVal = now;

        if ((now.tv_sec - m_PrevFrameTimeVal.tv_sec) < 0)
            m_PrevFrameTimeVal = now;

        msecs = (now.tv_sec - m_PrevFrameTimeVal.tv_sec) * 1000;
        msecs += (now.tv_usec - m_PrevFrameTimeVal.tv_usec) / 1000;

        speed = uint.max (1000 / m_Fps, 1);
        n_frames = (uint)(msecs / speed);
        if (n_frames == 0) n_frames = 1;

        m_PrevFrameTimeVal = now;

        if (m_Direction == TimelineDirection.FORWARD)
            m_CurrentFrameNum += (int)n_frames;
        else
            m_CurrentFrameNum -= (int)n_frames;

        if (!is_complete ())
        {
            new_frame.post (m_CurrentFrameNum);

            if (m_Timeout == null)
            {
                return false;
            }

            return true;
        }
        else
        {
            TimelineDirection saved_direction = m_Direction;
            uint overflow_frame_num = m_CurrentFrameNum;
            int end_frame;

            if (m_Direction == TimelineDirection.FORWARD)
            {
                m_CurrentFrameNum = (int)this.n_frames;
            }
            else if (m_Direction == TimelineDirection.BACKWARD)
            {
                m_CurrentFrameNum = 0;
            }

            end_frame = m_CurrentFrameNum;

            new_frame.post (m_CurrentFrameNum);

            if (m_CurrentFrameNum != end_frame)
                return true;

            if (!loop && m_Timeout != null)
            {
                m_Timeout.parent = null;
                m_Timeout = null;
            }

            completed.post ();

            if (m_CurrentFrameNum != end_frame &&
                !((m_CurrentFrameNum == 0 && end_frame == this.n_frames) ||
                  (m_CurrentFrameNum == this.n_frames && end_frame == 0)))
                return true;

            if (loop)
            {
                if (saved_direction == TimelineDirection.FORWARD)
                    m_CurrentFrameNum = (int)(overflow_frame_num - this.n_frames);
                else
                    m_CurrentFrameNum = (int)(this.n_frames + overflow_frame_num);

                if (m_Direction != saved_direction)
                {
                    m_CurrentFrameNum = (int)(this.n_frames - m_CurrentFrameNum);
                }

                return true;
            }
            else
            {
                rewind ();

                m_PrevFrameTimeVal.tv_sec = 0;
                m_PrevFrameTimeVal.tv_usec = 0;

                return false;
            }
        }
    }

    /**
     * Start timeline
     */
    public void
    start ()
        requires (n_frames > 0)
    {
        if (m_Timeout != null) return;

        add_timeout ();

        started.post ();
    }

    /**
     * Pause timeline
     */
    public void
    pause ()
    {
        if (m_Timeout != null)
        {
            m_Timeout.parent = null;
            m_Timeout = null;
        }

        m_PrevFrameTimeVal.tv_sec = 0;
        m_PrevFrameTimeVal.tv_usec = 0;

        paused.post ();
    }

    /**
     * Stop timeline
     */
    public void
    stop ()
    {
        pause ();
        rewind ();
    }

    /**
     * Rewind timeline to begining
     */
    public void
    rewind ()
    {
        if (m_Direction == TimelineDirection.FORWARD)
            advance (0);
        else if (m_Direction == TimelineDirection.BACKWARD)
            advance (n_frames);
    }

    /**
     * Advance timeline to frame inNumFrame
     *
     * @param inNumFrame frame number to advance to
     */
    public void
    advance (uint inNumFrame)
    {
        m_CurrentFrameNum = (int)inNumFrame.clamp (0, n_frames);
    }

    /**
     * Skip inNbFrames
     *
     * @param inNbFrames number of frames to skip
     */
    public void
    skip (int inNbFrames)
    {
        if (m_Direction == TimelineDirection.FORWARD)
        {
            m_CurrentFrameNum += inNbFrames;

            if (m_CurrentFrameNum > n_frames)
                m_CurrentFrameNum = 1;
        }
        else if (m_Direction == TimelineDirection.BACKWARD)
        {
            m_CurrentFrameNum -= inNbFrames;

            if (m_CurrentFrameNum < 1)
                m_CurrentFrameNum = (int)(n_frames - 1);
        }
    }

    /**
     * Set timeline timeout pool priority
     *
     * @param inPriority timeout pool priority
     */
    public static void
    set_priority (int inPriority)
    {
        get_timeout_pool ().set_priority (inPriority);
    }
}

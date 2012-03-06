/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * timeline.vala
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
 * along
 */

public class Maia.Timeline : Object
{
    // types
    public enum Direction
    {
        FORWARD,
        BACKWARD
    }

    // properties
    private Dispatcher  m_Dispatcher = null;
    private TicTac      m_TicTac     = null;
    private uint        m_Fps        = 60;
    private uint        m_NFrames    = 0;
    private bool        m_Loop       = false;
    private Direction   m_Direction  = Direction.FORWARD;
    private int         m_CurrentFrameNum = 0;
    private Os.TimeSpec m_PrevFrameTime;

    // signals
    public signal void started ();
    public signal void new_frame (int inNumFrame);
    public signal void paused ();
    public signal void completed ();

    // accessors

    /**
     * Timeline direction
     */
    [CCode (notify = false)]
    public Direction direction {
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
    [CCode (notify = false)]
    public uint speed {
        get {
            return m_Fps;
        }
        set {
            if (m_Fps != value)
            {
                m_Fps = value;
                if (m_TicTac != null)
                {
                    m_TicTac = new TicTac (m_Fps);
                    m_TicTac.parent = m_Dispatcher;
                    m_TicTac.bell.connect (on_tictac_bell);
                }
            }
        }
    }

    /**
     * Number of frame in Timeline
     */
    [CCode (notify = false)]
    public uint n_frames {
        get {
            return m_NFrames;
        }
        set {
            m_NFrames = value;
        }
    }

    /**
     * Timeline loop
     */
    [CCode (notify = false)]
    public bool loop {
        get {
            return m_Loop;
        }
        set {
            m_Loop = value;
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
            if (m_TicTac == null)
            {
                if (m_Direction == Direction.FORWARD)
                    return 0.0;
                else
                    return 1.0;
            }

            return ((double)m_CurrentFrameNum / (double)m_NFrames).clamp (0.0, 1.0);
        }
    }

    /**
     * Indicate if timeline is currently running
     */
    public bool is_playing {
        get {
            return m_TicTac != null;
        }
    }

    // methods
    public Timeline (uint inFps, uint inNFrames, Dispatcher inDispatcher = Dispatcher.self)
    {
        m_Fps        = inFps;
        m_NFrames    = inNFrames;
        m_Dispatcher = inDispatcher;
    }

    private inline bool
    is_complete ()
    {
        return ((m_Direction == Direction.FORWARD) && (m_CurrentFrameNum >= m_NFrames)) ||
               ((m_Direction == Direction.BACKWARD) && (m_CurrentFrameNum <= 0));
    }

    private bool
    on_tictac_bell ()
    {
        Os.TimeSpec now = Os.TimeSpec ();
        uint n_frames;
        ulong msecs, speed;

        Os.clock_gettime (Os.CLOCK_MONOTONIC, out now);

        if (m_PrevFrameTime.tv_sec == 0)
            m_PrevFrameTime = now;

        if ((now.tv_sec - m_PrevFrameTime.tv_sec) < 0)
            m_PrevFrameTime = now;

        msecs = (now.tv_sec - m_PrevFrameTime.tv_sec) * 1000;
        msecs += (now.tv_nsec - m_PrevFrameTime.tv_nsec) / 1000000;

        speed = ulong.max (1000 / m_Fps, 1);
        n_frames = (uint)(msecs / speed);
        if (n_frames == 0) n_frames = 1;

        m_PrevFrameTime = now;

        if (m_Direction == Direction.FORWARD)
            m_CurrentFrameNum += (int)n_frames;
        else
            m_CurrentFrameNum -= (int)n_frames;

        if (!is_complete ())
        {
            new_frame (m_CurrentFrameNum);

            if (m_TicTac == null)
            {
                return false;
            }

            return true;
        }
        else
        {
            Direction saved_direction = m_Direction;
            uint overflow_frame_num = m_CurrentFrameNum;
            int end_frame;

            if (m_Direction == Direction.FORWARD)
            {
                m_CurrentFrameNum = (int)m_NFrames;
            }
            else if (m_Direction == Direction.BACKWARD)
            {
                m_CurrentFrameNum = 0;
            }

            end_frame = m_CurrentFrameNum;

            new_frame (m_CurrentFrameNum);

            if (m_CurrentFrameNum != end_frame)
                return true;

            if (!m_Loop)
            {
                m_TicTac = null;
            }

            completed ();

            if (m_CurrentFrameNum != end_frame &&
                !((m_CurrentFrameNum == 0 && end_frame == m_NFrames) ||
                  (m_CurrentFrameNum == m_NFrames && end_frame == 0)))
                return true;

            if (m_Loop)
            {
                if (saved_direction == Direction.FORWARD)
                    m_CurrentFrameNum = (int)(overflow_frame_num - m_NFrames);
                else
                    m_CurrentFrameNum = (int)(m_NFrames + overflow_frame_num);

                if (m_Direction != saved_direction)
                {
                    m_CurrentFrameNum = (int)(m_NFrames - m_CurrentFrameNum);
                }

                return true;
            }
            else
            {
                rewind ();

                m_PrevFrameTime.tv_sec = 0;
                m_PrevFrameTime.tv_nsec = 0;

                return false;
            }
        }
    }

    /**
     * Advance timeline to frame inNumFrame
     *
     * @param inNFrames frame number to advance to
     */
    public void
    advance (uint inNumFrame)
    {
        m_CurrentFrameNum = (int)inNumFrame.clamp (0, m_NFrames);
    }

    /**
     * Rewind timeline to begining
     */
    public void
    rewind ()
    {
        if (m_Direction == Direction.FORWARD)
            advance (0);
        else if (m_Direction == Direction.BACKWARD)
            advance (m_NFrames);
    }

    /**
     * Skip inNbFrames
     *
     * @param inNbFrames number of frames to skip
     */
    public void
    skip (int inNbFrames)
    {
        if (m_Direction == Direction.FORWARD)
        {
            m_CurrentFrameNum += inNbFrames;

            if (m_CurrentFrameNum > m_NFrames)
                m_CurrentFrameNum = 1;
        }
        else if (m_Direction == Direction.BACKWARD)
        {
            m_CurrentFrameNum -= inNbFrames;

            if (m_CurrentFrameNum < 1)
                m_CurrentFrameNum = (int)(m_NFrames - 1);
        }
    }

    /**
     * Start timeline
     */
    public void
    start ()
       requires (m_NFrames > 0)
    {
        if (m_TicTac != null) return;

        m_TicTac = new TicTac (m_Fps);
        m_TicTac.bell.connect (on_tictac_bell);
        m_TicTac.parent = m_Dispatcher;

        started ();
    }

    /**
     * Pause timeline
     */
    public void
    pause ()
    {
        m_TicTac = null;

        m_PrevFrameTime.tv_sec = 0;
        m_PrevFrameTime.tv_nsec = 0;

        paused ();
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
}

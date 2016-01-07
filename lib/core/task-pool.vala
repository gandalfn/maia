/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * task-pool.vala
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

public class Maia.Core.TaskPool : GLib.Object
{
    // properties
    private GLib.Thread<void*> m_Thread = null;
    private GLib.MainContext   m_Context;
    private GLib.MainLoop      m_Loop;
    private GLib.Mutex         m_Mutex = GLib.Mutex ();
    private GLib.Cond          m_Cond  = GLib.Cond ();
    private bool               m_IsWaiting = false;
    private uint               m_IdleTime = 15;
    private Queue<Task>        m_Tasks = new Queue<Task> ();
    private Task?              m_CurrentTask = null;
    private uint               m_IdPop = 0;

    // acessors
    [CCode (notify = false)]
    public string name       { get; construct; }
    [CCode (notify = false)]
    public bool   is_running { get; private set; default = false; }
    [CCode (notify = false)]
    public uint   idle_time  {
        get {
            return m_IdleTime;
        }
        set {
            m_Mutex.@lock ();
            m_IdleTime = value;
            m_Mutex.unlock ();
        }
    }

    // methods
    public TaskPool (string inName)
    {
        GLib.Object (name: inName);
    }

    ~TaskPool ()
    {
#if MAIA_DEBUG
        Log.debug ("~TaskPool", Log.Category.MAIN_BUS, "");
#endif
        if (m_Thread != null && m_Loop != null)
        {
            m_Loop.quit ();
            m_Thread.join ();
        }
        if (m_IdPop != 0)
        {
            GLib.Source.remove (m_IdPop);
            m_IdPop = 0;
        }
    }

    private void
    on_task_finished (Notification inNotification)
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"task finished $(m_CurrentTask.ref_count)");
#endif

        program_pop ();
    }

    private bool
    pop ()
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"$m_IdPop");
#endif

        if (m_IdPop != 0)
        {
            m_Mutex.@lock ();
            {
                m_CurrentTask = m_Tasks.pop ();
                if (m_CurrentTask == null)
                {
                    m_IsWaiting = true;
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"wait task");
#endif
                    if (m_Cond.wait_until (m_Mutex, GLib.get_monotonic_time () + m_IdleTime * GLib.TimeSpan.SECOND))
                    {
                        m_CurrentTask = m_Tasks.pop ();
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"task pop $(m_CurrentTask.ref_count)");
#endif
                    }
                    m_IsWaiting = false;
                }
                else
                {
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"task pop $(m_CurrentTask.ref_count)");
#endif
                }

                m_IdPop = 0;

                if (m_CurrentTask == null)
                {
                    if (is_running)
                    {
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"quit task");
#endif
                        m_Loop.quit ();
                    }
                    is_running = false;
                }
                else
                {
                    is_running = true;
                    m_CurrentTask.finished.add_object_observer (on_task_finished);
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"task launch $(m_CurrentTask.ref_count)");
#endif
                    m_CurrentTask.run (m_Context);
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"task launched $(m_CurrentTask.ref_count)");
#endif
                }
            }
            m_Mutex.unlock ();
        }

        return false;
    }

    private void
    program_pop ()
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"$m_IdPop");
#endif
        if (m_IdPop == 0)
        {
            var source = new GLib.IdleSource ();
            source.set_callback (pop);
            m_IdPop = source.attach (m_Context);
        }
    }

    private void*
    main ()
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"start $name");
#endif

        m_Context = new GLib.MainContext ();
        m_Context.push_thread_default ();
        m_Loop = new GLib.MainLoop (m_Context);

        program_pop ();
        m_Loop.run ();

        m_Loop = null;
        m_Context = null;

        return null;
    }

    public void
    push (Task inTask)
    {
        m_Mutex.@lock ();
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"push is_running: $is_running $m_IsWaiting");
#endif
            m_Tasks.push (inTask);

            if (!is_running)
            {
                is_running = true;
                m_Thread = new GLib.Thread<void*> (name, main);
            }
            else if (m_IsWaiting)
            {
                m_Cond.@signal ();
            }
        }
        m_Mutex.unlock ();
    }
}

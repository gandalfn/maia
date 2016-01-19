/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * task.vala
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

public abstract class Maia.Core.Task : Object
{
    // types
    public delegate bool Callback (Task inTask);

    private class Observer : GLib.Object
    {
        private unowned Task         m_Task;
        private unowned Callback     m_Callback;
        private void*                m_Target;
        private unowned GLib.Object? m_TargetObject;

        public Observer (Task inTask, Callback inCallback)
        {
            m_Task = inTask;
            m_Callback = inCallback;
            m_Target = (*(void**)((&m_Callback) + 1));
            m_TargetObject = null;
        }

        public Observer.object (Task inTask, Callback inCallback)
        {
            this (inTask, inCallback);

            m_TargetObject = m_Target as GLib.Object;
            if (m_TargetObject != null)
            {
                m_TargetObject.weak_ref (on_target_destroy);
            }
        }

        ~Observer ()
        {
            if (m_TargetObject != null)
            {
                m_TargetObject.weak_unref (on_target_destroy);
            }
        }

        private void
        on_target_destroy ()
        {
            m_Target = null;
            m_TargetObject = null;
            m_Callback = null;
        }

        public new bool
        notify ()
        {
            if (m_Callback != null)
            {
                return m_Callback (m_Task);
            }

            return false;
        }
    }

    private enum EventState
    {
        WAITING,
        READY
    }

    internal class EventWatch : GLib.Object
    {
        [CCode (has_target = false)]
        public delegate void DestroyNotifyFunc (Task inTask);

        unowned Task?               m_Task        = null;
        unowned DestroyNotifyFunc?  m_DestroyFunc = null;
        EventState                  m_State       = EventState.WAITING;
        Observer                    m_Observer    = null;
        GLib.MainContext?           m_Context     = null;
        GLib.IdleSource             m_Source      = null;

        public bool is_waiting {
            get {
                return m_State == EventState.WAITING;
            }
        }

        public EventWatch (Task inTask, DestroyNotifyFunc? inFunc = null)
        {
            m_Task = inTask;
            m_DestroyFunc = inFunc;
        }

        ~EventWatch ()
        {
            if (m_Task != null && m_DestroyFunc != null)
            {
                m_DestroyFunc (m_Task);
            }
            if (m_Source != null)
            {
                m_Source.destroy ();
                m_Source = null;
            }
        }

        private bool
        on_process ()
        {
            if (m_Source != null)
            {
                lock (m_State)
                {
                    if (m_State == EventState.READY)
                    {
                        bool ret = false;
                        if (m_Observer != null)
                        {
                            ret = m_Observer.notify ();
                        }
                        if (!ret)
                        {
                            if (m_DestroyFunc != null)
                            {
                                m_DestroyFunc (m_Task);
                            }
                            m_Task = null;
                        }
                        else
                        {
                            m_State = EventState.WAITING;
                        }
                    }
                }
            }
            m_Source = null;

            return false;
        }

        public void
        attach (GLib.MainContext inContext)
        {
            lock (m_Context)
            {
                m_Context = inContext;
            }
        }

        public void
        set_object_observer (Callback inCallback)
        {
            m_Observer = new Observer.object (m_Task, inCallback);
        }

        public void
        set_observer (Callback inCallback)
        {
            m_Observer = new Observer (m_Task, inCallback);
        }

        public void
        @signal ()
        {
            lock (m_State)
            {
                if (m_State == EventState.WAITING)
                {
                    lock (m_Context)
                    {
                        if (m_Context != null && m_Source == null)
                        {
                            m_State = EventState.READY;
                            m_Source = new GLib.IdleSource ();
                            m_Source.set_callback (on_process);
                            m_Source.set_priority (GLib.Priority.HIGH);
                            m_Source.attach (m_Context);
                        }
                        else if (m_Context == null)
                        {
                            m_State = EventState.READY;
                            if (m_DestroyFunc != null)
                            {
                                m_DestroyFunc (m_Task);
                            }
                            m_Task = null;
                        }
                    }
                }
            }
        }
    }

    // properties
    private EventWatch   m_Cancel;
    private EventWatch[] m_Start;
    private EventWatch[] m_Finish;
    private bool         m_IsRunning = false;
    private bool         m_IsCancelled = false;

    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public bool is_running {
        get {
            return m_IsRunning;
        }
    }

    public bool is_cancelled {
        get {
            return m_IsCancelled;
        }
    }

    // notifications
    internal unowned Notification? finished {
        get {
            return notifications["finished"];
        }
    }

    // methods
    construct
    {
        notifications.add (new Notification ("finished"));
    }

    public Task (string inName)
    {
        GLib.Object (id: (uint32)GLib.Quark.from_string (inName));

        m_Cancel = new EventWatch (this);
        m_Cancel.set_object_observer (on_cancelled);
        m_Finish = {};
    }

    private bool
    on_cancelled (Task inTask)
    {
        m_IsCancelled = true;

        if (m_IsRunning)
        {
            finish ();
        }

        return false;
    }

    protected abstract void main (GLib.MainContext? inContext);

    protected virtual void
    finish ()
    {
        m_IsRunning = false;

        lock (m_Finish)
        {
            foreach (unowned EventWatch? f in m_Finish)
            {
                f.@signal ();
            }
            m_Finish = {};
        }

        finished.post ();
    }

    protected virtual void
    start ()
    {
        lock (m_Start)
        {
            foreach (unowned EventWatch? f in m_Start)
            {
                f.@signal ();
            }
            m_Start = {};
        }
    }

    internal void
    run (GLib.MainContext? inContext)
    {
        m_Cancel.attach (inContext);

        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_BUS, @"run task $(m_Cancel.is_waiting)");
        if (m_Cancel.is_waiting)
        {
            m_IsRunning = true;
            start ();
            main (inContext);
        }
        else
        {
            finish ();
        }
    }

    public void
    cancel ()
    {
        m_Cancel.@signal ();
    }

    public void
    add_start_object_observer (Callback inCallback, GLib.MainContext? inContext = null)
    {
        lock (m_Start)
        {
            var f = new EventWatch (this, (EventWatch.DestroyNotifyFunc)unref);
            f.set_object_observer (inCallback);
            f.attach (inContext ?? GLib.MainContext.@default ());
            m_Start += f;
            ref ();
        }
    }

    public void
    add_start_observer (Callback inCallback, GLib.MainContext? inContext = null)
    {
        lock (m_Start)
        {
            var f = new EventWatch (this, (EventWatch.DestroyNotifyFunc)unref);
            f.set_observer (inCallback);
            f.attach (inContext ?? GLib.MainContext.@default ());
            m_Start += f;
            ref ();
        }
    }

    public void
    add_finish_object_observer (Callback inCallback, GLib.MainContext? inContext = null)
    {
        lock (m_Finish)
        {
            var f = new EventWatch (this, (EventWatch.DestroyNotifyFunc)unref);
            f.set_object_observer (inCallback);
            f.attach (inContext ?? GLib.MainContext.@default ());
            m_Finish += f;
            ref ();
        }
    }

    public void
    add_finish_observer (Callback inCallback, GLib.MainContext? inContext = null)
    {
        lock (m_Finish)
        {
            var f = new EventWatch (this, (EventWatch.DestroyNotifyFunc)unref);
            f.set_observer (inCallback);
            f.attach (inContext ?? GLib.MainContext.@default ());
            m_Finish += f;
            ref ();
        }
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event.vala
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

public class Maia.Core.Notification : Object
{
    // types
    public delegate void RecvFunc (Notification inNotification);

    public class Observer : Object
    {
        private struct Func
        {
            public unowned RecvFunc m_Func;

            public Func (RecvFunc inFunc)
            {
                m_Func = inFunc;
            }

            public void*
            get_target ()
            {
                return (*(void**)((&m_Func) + 1));
            }
        }

        // properties
        private unowned Notification m_Notification;
        private int                  m_Priority = 0;
        private Func?                m_Callback;
        private unowned GLib.Object? m_TargetObject;

        /**
         * Block temporarily the event notification
         */
        [CCode (notify = false)]
        public bool block { get; set; default = false; }

        internal bool is_clonable {
            get {
                return m_TargetObject == null || m_TargetObject.get_data<void*> ("NotificationObserverCpp") == null;
            }
        }

        internal Observer (Notification inNotification, RecvFunc inFunc, int inPriority = 0)
        {
            m_Notification = inNotification;
            m_Callback = Func (inFunc);
            m_TargetObject = null;
            m_Priority = inPriority;
        }

        internal Observer.object (Notification inNotification, RecvFunc inFunc, int inPriority = 0)
        {
            this (inNotification, inFunc, inPriority);

            m_TargetObject = m_Callback.get_target () as GLib.Object;
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
            m_TargetObject = null;
            m_Callback = null;
            parent = null;
        }

        internal override int
        compare (Core.Object inOther)
            requires (inOther is Observer)
        {
            return m_Priority - (inOther as Observer).m_Priority;
        }

        internal bool
        equals (RecvFunc inFunc)
        {
            Func func = Func (inFunc);
            void* target = func.get_target ();
            return  m_Callback.m_Func == inFunc && m_Callback.get_target () == target;
        }

        internal new void
        notify ()
        {
            if (!block && m_Callback != null)
            {
                m_Callback.m_Func (m_Notification);
            }
        }

        internal Observer
        clone (Notification inNotification)
        {
            return m_TargetObject != null ? new Observer.object (inNotification, m_Callback.m_Func, m_Priority) : new Observer (inNotification, m_Callback.m_Func, m_Priority);
        }
    }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    // methods
    public Notification (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
    }

    public void
    add_observer (RecvFunc inFunc, int inPriority = 0)
    {
        var observer = new Observer (this, inFunc, inPriority);
        observer.parent = this;
    }

    public Observer
    add_object_observer (RecvFunc inFunc, int inPriority = 0)
    {
        var observer = new Observer.object (this, inFunc, inPriority);
        observer.parent = this;
        return observer;
    }

    public void
    remove_observer (RecvFunc inFunc)
    {
        foreach (unowned Core.Object? child in this)
        {
            unowned Observer? observer = child as Observer;
            if (observer != null && observer.equals (inFunc))
            {
                observer.parent = null;
                break;
            }
        }
    }

    public void
    post ()
    {
        ref ();
        {
            foreach (unowned Core.Object? child in this)
            {
                unowned Observer? observer = child as Observer;
                if (observer != null)
                {
                    observer.notify ();
                }
            }
        }
        unref ();
    }

    public virtual void
    append_observers (Notification inNotification)
    {
        foreach (unowned Object? child in inNotification)
        {
            unowned Observer? observer = child as Observer;
            if (observer != null && observer.is_clonable)
            {
                add (observer.clone (this));
            }
        }
    }

    internal override int
    compare (Core.Object inOther)
    {
        return (int)(id - inOther.id);
    }

    internal int
    compare_with_id (uint32 inId)
    {
        return (int)(id - inId);
    }
}

public class Maia.Core.Notifications : GLib.Object
{
    // properties
    private Core.Set<Notification> m_Notifications;

    // methods
    construct
    {
        m_Notifications = new Core.Set<Notification> ();
    }

    public Notifications ()
    {
    }

    public new unowned Notification?
    @get (string inName)
    {
        return m_Notifications.search<uint32> ((uint32)GLib.Quark.from_string (inName), Notification.compare_with_id);
    }

    public unowned Notification?
    add (Notification inNotification)
    {
        var iter = m_Notifications.insert (inNotification);
        return iter.get ();
    }

    public void
    remove (string inName)
    {
        unowned Notification? notification = this[inName];
        if (notification != null)
        {
            m_Notifications.remove (notification);
        }
    }
}

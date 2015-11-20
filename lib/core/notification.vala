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

    private class Observer : Object
    {
        private unowned Notification m_Notification;
        private unowned RecvFunc     m_Callback;
        private void*                m_Target;
        private unowned GLib.Object? m_TargetObject;

        public bool is_clonable {
            get {
                return m_TargetObject == null || m_TargetObject.get_data<void*> ("NotificationObserverCpp") == null;
            }
        }

        public Observer (Notification inNotification, RecvFunc inFunc)
        {
            m_Notification = inNotification;
            m_Callback = inFunc;
            m_Target = (*(void**)((&m_Callback) + 1));
            m_TargetObject = null;
        }

        public Observer.object (Notification inNotification, RecvFunc inFunc)
        {
            this (inNotification, inFunc);

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
            parent = null;
        }

        internal override int
        compare (Core.Object inOther)
        {
            return 0;
        }

        public bool
        equals (RecvFunc inFunc)
        {
            var observer = new Observer (m_Notification, inFunc);
            return  m_Callback == observer.m_Callback && m_Target == observer.m_Target;
        }

        public new void
        notify ()
        {
            if (m_Callback != null)
            {
                m_Callback (m_Notification);
            }
        }

        public Observer
        clone (Notification inNotification)
        {
            return m_TargetObject != null ? new Observer.object (inNotification, m_Callback) : new Observer (inNotification, m_Callback);
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
    add_observer (RecvFunc inFunc)
    {
        var observer = new Observer (this, inFunc);
        observer.parent = this;
    }

    public void
    add_object_observer (RecvFunc inFunc)
    {
        var observer = new Observer.object (this, inFunc);
        observer.parent = this;
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
        foreach (unowned Core.Object? child in this)
        {
            unowned Observer? observer = child as Observer;
            if (observer != null)
            {
                observer.notify ();
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

    public void
    post (string inName)
    {
        unowned Notification? notification = this[inName];
        if (notification != null)
        {
            notification.post ();
        }
    }

    public void
    add_observer (string inName, Notification.RecvFunc inFunc)
    {
        unowned Notification? notification = this[inName];
        if (notification == null)
        {
            var new_notification = new Notification (inName);
            m_Notifications.insert (new_notification);
            notification = new_notification;
        }

        notification.add_observer (inFunc);
    }

    public void
    add_object_observer (string inName, Notification.RecvFunc inFunc)
    {
        unowned Notification? notification = this[inName];
        if (notification == null)
        {
            var new_notification = new Notification (inName);
            m_Notifications.insert (new_notification);
            notification = new_notification;
        }

        notification.add_object_observer (inFunc);
    }

    public void
    remove_observer (Notification.RecvFunc inFunc)
    {
        foreach (unowned Notification notification in m_Notifications)
        {
            notification.remove_observer (inFunc);
        }
    }
}

/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-notification.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Maia.Notification
{
    // types
    public abstract class Args
    {
    }

    public class Observer
    {
        [CCode (has_target = false)]
        public delegate void ActionFunc (void* inTarget, Args inArgs);

        private unowned Notification m_Notification;
        private ActionFunc           m_Func;
        private void*                m_Target;

        internal Notification notification {
            get {
                return m_Notification;
            }
        }

        internal ActionFunc func {
            get {
                return m_Func;
            }
        }

        internal void* target {
            get {
                return m_Target;
            }
        } 

        internal Observer (Notification inNotification, ActionFunc inFunc, void* inTarget)
        {
            m_Notification = inNotification;
            m_Func = inFunc;
            m_Target = inTarget;

            m_Notification.m_Observers.insert (this);
        }

        ~Observer ()
        {
            unwatch ();
        }

        internal void
        notify (Args inArgs)
        {
            m_Func (m_Target, inArgs);
        }

        public void
        unwatch ()
        {
            if (m_Notification != null)
            {
                m_Notification.m_Observers.remove (this);

                m_Notification = null;
            }
        }
    }

    // properties
    private string         m_Name;
    private Object         m_Owner;
    private List<Observer> m_Observers;

    // accessors
    public string name {
        get {
            return m_Name;
        }
    }

    public Object owner {
        get {
            return m_Owner;
        }
    }

    // methods

    /**
     * Create a new notification
     *
     * @param inName name of notification
     * @param inOwner notification object owner
     */
    public Notification (string inName, Object? inOwner = null)
    {
        m_Name = inName;
        m_Owner = inOwner;
        m_Observers = new List<Observer> ();
    }

    /**
     * Post notification
     */
    public void
    post (Args? inArgs = null)
    {
        foreach (unowned Observer observer in m_Observers)
            observer.notify (inArgs);
    }

    /**
     * Watch the notification
     *
     * @param inFunc function to call on notification post
     */
    public Observer
    watch (Observer.ActionFunc inFunc, void* inTarget = null)
    {
        return new Observer (this, inFunc, inTarget);
    }

    /**
     * Unwatch a notification
     *
     * @param inFunc function to remove from notification watch
     */
    public void
    unwatch (Observer.ActionFunc inFunc, void* inTarget = null)
    {
        foreach (unowned Observer observer in m_Observers)
        {
            if (observer.notification == this &&
                observer.func == inFunc &&
                observer.target == inTarget)
            {
                observer.unwatch ();
                break;
            }
        }
    }
}
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
 *
 * Mostly parts of this code is inspired from valamarkupreader.vala in vala
 * Author: Jürg Billeter <j@bitron.ch>
 */

public class Maia.Notification
{
    // types
    public class Observer
    {
        public delegate void ActionFunc ();

        internal unowned Notification m_Notification;
        internal ActionFunc           m_Func;

        public Observer (Notification inNotification, ActionFunc inFunc)
        {
            m_Notification = inNotification;
            m_Func = inFunc;

            m_Notification.m_Observers.insert (this);
        }

        ~Observer ()
        {
            unwatch ();
        }

        internal void
        notify ()
        {
            m_Func ();
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
    post ()
    {
        foreach (unowned Observer observer in m_Observers)
            observer.notify ();
    }

    /**
     * Watch the notification
     *
     * @param inFunc function to call on notification post
     */
    public virtual Observer
    watch (Observer.ActionFunc inFunc)
    {
        return new Observer (this, inFunc);
    }

    /**
     * Unwatch a notification
     *
     * @param inFunc function to remove from notification watch
     */
    public virtual void
    unwatch (Observer.ActionFunc inFunc)
    {
        // Very bad hack to get target delegate parameter
        int fake;
        void* inTarget = &fake - (4 + sizeof(void));

        foreach (unowned Observer observer in m_Observers)
        {
            // Very bad hack to get target of observer delegate
            void* target = (void*)(((ulong)(&observer.m_Func)) + sizeof (Observer.ActionFunc));
            if (observer.m_Notification == this && observer.m_Func == inFunc && target == inTarget)
            {
                observer.unwatch ();
                break;
            }
        }
    }
}
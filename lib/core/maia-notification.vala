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

        private ActionFunc           m_Func;
        private void*                m_Target;

        protected Observer (ActionFunc inFunc, void* inTarget)
        {
            m_Func = inFunc;
            m_Target = inTarget;
        }

        internal void
        notify (Args inArgs)
        {
            m_Func (m_Target, inArgs);
        }

        internal bool
        equals (Observer inOther)
        {
            return m_Func == inOther.m_Func && m_Target == inOther.m_Target;
        }
    }

    // properties
    private string          m_Name;
    private Object          m_Owner;
    private Array<Observer> m_Observers;

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
        m_Observers = new Array<Observer> ();
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
     * Add an observer to notification
     *
     * @param inObserver observer to add to notification
     */
    public void
    watch (Observer inObserver)
    {
        m_Observers.insert (inObserver);
    }

    /**
     * Remove an observer from notification
     *
     * @param inObserver observer to remove from notification
     */
    public void
    unwatch (Observer inObserver)
    {
        Iterator<Observer> iter = m_Observers[inObserver];
        if (iter != null) m_Observers.erase (iter);
    }
}
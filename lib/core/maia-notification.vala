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
    // properties
    private string           m_Name;
    private void*            m_Owner;
    private Array<Observer?> m_Observers;

    // accessors
    public string name {
        get {
            return m_Name;
        }
    }

    public void* owner {
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
    public Notification (string inName, void* inOwner = null)
    {
        m_Name = inName;
        m_Owner = inOwner;
        m_Observers = new Array<Observer?> ();
        m_Observers.equal_func = (EqualFunc)Observer.equals;
    }

    /**
     * Post notification
     */
    public void
    post (Observer.Args? inArgs = null)
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
        Iterator<Observer?> iter = m_Observers[inObserver];
        if (iter != null) m_Observers.erase (iter);
    }
}
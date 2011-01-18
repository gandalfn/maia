/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * notification.vala
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Maia.Notification<R> : Object
{
    // properties
    private string           m_Name;
    private Array<Observer?> m_Observers;
    private AccumulateFunc   m_Accumulator;

    // accessors
    public override Type object_type {
        get {
            return typeof (Notification);
        }
    }

    public string name {
        get {
            return m_Name;
        }
    }

    // methods

    /**
     * Create a new notification
     *
     * @param inName name of notification
     * @param inOwner notification object owner
     */
    public Notification (string inName, AccumulateFunc? inAccumulator = null)
    {
        m_Name = inName;
        m_Observers = new Array<Observer?> ();
        m_Accumulator = inAccumulator == null ? get_accumulator_func_for<R> () : inAccumulator;
    }

    /**
     * Post notification
     */
    public R
    post (...)
    {
        va_list args = va_list ();
        R result = null;

        foreach (unowned Observer<R> observer in m_Observers)
        {
            R ret = observer.notify (args);

            if (m_Accumulator != null)
                result = m_Accumulator (result, ret);
            else
                result = ret;
        }

        return result;
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
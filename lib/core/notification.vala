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

public class Maia.Notification<O> : Object
{
    // types
    public delegate void Handler<O> (O? inOwner);

    public class Observer<O> : Object
    {
        // properties
        private unowned Object? m_BlockParent = null;
        internal unowned Handler<O> m_Callback;

        // accessors
        public bool block {
            get {
                return m_BlockParent != null;
            }
            set {
                if (m_BlockParent != null && !value)
                {
                    parent = m_BlockParent;
                    m_BlockParent = null;
                }
                else if (m_BlockParent == null && value)
                {
                    m_BlockParent = parent;
                    parent = null;
                }
            }
        }

        // methods
        internal Observer (Handler<O> inCallback)
        {
            m_Callback = inCallback;
        }

        internal bool
        equal (Handler<O> inCallback)
        {
            char* ptr = (char*)m_Callback;
            void* this_target = *((void**)(&ptr + sizeof (Handler)));
            ptr = (char*)inCallback;
            void* in_target = *((void**)(&ptr + sizeof (Handler)));

            return m_Callback == inCallback && this_target == in_target;
        }

        internal new void
        notify ()
        {
            m_Callback (((Notification<O>)parent).m_Owner);
        }

        public void
        destroy ()
        {
            m_BlockParent = null;
            parent = null;
        }
    }

    // properties
    internal unowned O m_Owner;

    // methods
    public Notification (O? inOwner)
    {
        m_Owner = inOwner;
    }

    internal unowned Observer<O>?
    get_observer (Handler<O> inCallback)
    {
        foreach (unowned Object? child in this)
        {
            unowned Observer<O>? observer = (Observer<O>)child;
            if (observer.equal (inCallback))
            {
                return observer;
            }
        }

        return null;
    }

    public unowned Observer<O>?
    watch (Handler<O> inCallback)
    {
        unowned Observer<O>? ret = get_observer (inCallback);
        if (ret == null)
        {
            Observer<O> observer = new Observer<O> (inCallback);
            observer.parent = this;
            ret = observer;
        }
        return ret;
    }

    public void
    send ()
    {
        foreach (unowned Object? child in this)
        {
            unowned Observer<O> observer = (Observer<O>)child;
            observer.notify ();
        }
    }
}

public class Maia.NotificationR<O, R> : Notification<O>
{
    // types
    public delegate R Handler<O, R> (O? inOwner);

    public class Observer<O, R> : Notification.Observer<O>
    {
        // methods
        internal Observer (Handler<O, R> inCallback)
        {
            base ((Notification.Handler<O>)inCallback);
        }

        internal new R
        notify ()
        {
            return ((Handler<O, R>)m_Callback) (((Notification<O>)parent).m_Owner);
        }
    }

    // methods
    public NotificationR (O? inOwner)
    {
        base (inOwner);
    }

    public new unowned Observer<O, R>?
    watch (Handler<O, R> inCallback)
    {
        unowned Observer<O, R>? ret = (Observer<O, R>)get_observer ((Notification.Handler<O>)inCallback);
        if (ret == null)
        {
            Observer<O, R> observer = new Observer<O, R> (inCallback);
            observer.parent = this;
            ret = observer;
        }
        return ret;
    }

    public new void
    send (ref R inoutRet)
    {
        AccumulateFunc<R> func = get_accumulator_func_for<R> ();

        foreach (unowned Object? child in this)
        {
            unowned Observer<O, R> observer = (Observer<O, R>)child;
            inoutRet = func (inoutRet, observer.notify ());
        }
    }
}

public class Maia.Notification1<O, A> : Notification<O>
{
    // types
    public delegate void Handler<O, A> (O? inOwner, A inA);

    public class Observer<O, A> : Notification.Observer<O>
    {
        // methods
        internal Observer (Handler<O, A> inCallback)
        {
            base ((Notification.Handler<O>)inCallback);
        }

        internal new void
        notify (A inA)
        {
            ((Handler<O, A>)m_Callback) (((Notification<O>)parent).m_Owner, inA);
        }
    }

    // methods
    public Notification1 (O? inOwner)
    {
        base (inOwner);
    }

    public new unowned Observer<O, A>?
    watch (Handler<O, A> inCallback)
    {
        unowned Observer<O, A>? ret = (Observer<O, A>)get_observer ((Notification.Handler<O>)inCallback);
        if (ret == null)
        {
            Observer<O, A> observer = new Observer<O, A> (inCallback);
            observer.parent = this;
            ret = observer;
        }
        return ret;
    }

    public new void
    send (A inA)
    {
        foreach (unowned Object? child in this)
        {
            unowned Observer<O, A> observer = (Observer<O, A>)child;
            observer.notify (inA);
        }
    }
}
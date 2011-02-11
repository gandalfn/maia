/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event.vala
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

public class Maia.Event : Object
{
    // types
    public delegate void Callback ();
    public delegate R CallbackR<R> ();
    public delegate void Callback1<A> (A inA);
    public delegate R CallbackR1<R, A> (A inA);

    internal delegate void Func (EventArgs? inArgs);

    // properties
    private void*     m_Owner = null;
    private EventArgs m_Args  = null;

    // accessors
    internal void* owner {
        get {
            return m_Owner;
        }
    }

    internal EventArgs args {
        get {
            return m_Args;
        }
    }

    // methods

    /**
     * Create a new event
     *
     * @param inName event name
     * @param inOwner event object owner
     */
    public Event (string inName, void* inOwner = null)
    {
        GLib.Object (name: inName);
        m_Owner = inOwner;
    }

    /**
     * Post event
     *
     * @param inDispatcher dispatcher
     */
    public void
    post (Dispatcher inDispatcher = Dispatcher.self ())
    {
        Event event = new Event (name, m_Owner);
        inDispatcher.post_event (event);
    }

    /**
     * Post event
     *
     * @param inDispatcher dispatcher
     */
    public void
    postR<R> (Dispatcher inDispatcher = Dispatcher.self ())
    {
        Event event = new Event (name, m_Owner);
        event.m_Args = new EventArgsR<R> ();
        inDispatcher.post_event (event);
    }

    /**
     * Post event
     *
     * @param inA event args
     * @param inDispatcher dispatcher
     */
    public void
    post1<A> (A inA, Dispatcher inDispatcher = Dispatcher.self ())
    {
        Event event = new Event (name, m_Owner);
        event.m_Args = new EventArgs1<A> (inA);
        inDispatcher.post_event (event);
    }

    /**
     * Post event
     *
     * @param inA event args
     * @param inDispatcher dispatcher
     */
    public void
    postR1<R, A> (A inA, Dispatcher inDispatcher = Dispatcher.self ())
    {
        Event event = new Event (name, m_Owner);
        event.m_Args = new EventArgsR1<R, A> (inA);
        inDispatcher.post_event (event);
    }

    /**
     * Listen event
     *
     * @param inCallback event callback
     * @param inDispatcher dispatcher
     */
    public void
    listen (Callback inCallback, Dispatcher inDispatcher = Dispatcher.self ())
    {
        EventListener event_listener = new EventListener0 (this, inCallback);
        inDispatcher.add_listener (event_listener);
    }

    /**
     * Listen event
     *
     * @param inCallback event callback
     * @param inDispatcher dispatcher
     */
    public void
    listenR<R> (CallbackR<R> inCallback, Dispatcher inDispatcher = Dispatcher.self ())
    {
        EventListener event_listener = new EventListenerR0<R> (this, inCallback);
        inDispatcher.add_listener (event_listener);
    }

    /**
     * Listen event
     *
     * @param inCallback event callback
     * @param inDispatcher dispatcher
     */
    public void
    listen1<A> (Callback1<A> inCallback, Dispatcher inDispatcher = Dispatcher.self ())
    {
        EventListener event_listener = new EventListener1<A> (this, inCallback);
        inDispatcher.add_listener (event_listener);
    }

    /**
     * Listen event
     *
     * @param inCallback event callback
     * @param inDispatcher dispatcher
     */
    public void
    listenR1<R, A> (CallbackR1<R, A> inCallback, Dispatcher inDispatcher = Dispatcher.self ())
    {
        EventListener event_listener = new EventListenerR1<R, A> (this, inCallback);
        inDispatcher.add_listener (event_listener);
    }
}
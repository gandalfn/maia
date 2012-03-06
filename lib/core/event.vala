/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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

public class Maia.Event<A> : Object
{
    // types
    public delegate void Handler<A> (A? inArgs);

    // properties
    private void* m_Owner  = null;
    private A     m_Args   = null;
    private bool  m_Sender = false;

    // accessors
    public string name {
        get {
            return Atom.to_string (id);
        }
    }

    [CCode (notify = false)]
    public void* owner {
        get {
            return m_Owner;
        }
        construct {
            m_Owner = value;
        }
    }

    public A args {
        get {
            return m_Args;
        }
    }

    internal EventArgs event_args {
        get {
            return (EventArgs)m_Args;
        }
    }

    // static methods
    public static void
    post_event<A> (string inName, void* inOwner, owned A? inArgs = null,
                   Dispatcher inDispatcher = Dispatcher.self)
    {
        Event<A> event = new Event<A> (inName, inOwner);
        event.m_Args = inArgs;
        event.m_Sender = true;
        Log.debug (GLib.Log.METHOD, "post event %s", inName);
        inDispatcher.post_event (event);
    }

    // methods

    /**
     * Create a new event
     *
     * @param inName event name
     * @param inOwner event object owner
     */
    public Event (string inName, void* inOwner = null)
        requires (typeof (A).is_a (typeof (EventArgs)))
    {
        GLib.Object (id: Atom.from_string (inName), owner: inOwner);
    }

    /**
     * Create a new event
     *
     * @param inId event id
     * @param inOwner event object owner
     */
    private Event.with_id (uint32 inId, void* inOwner = null)
        requires (typeof (A).is_a (typeof (EventArgs)))
    {
        GLib.Object (id: inId, owner: inOwner);
    }

    ~Event ()
    {
        if (!m_Sender)
        {
            Dispatcher.remove_event_listeners (this);
        }
    }

    protected virtual void
    on_listen ()
    {
    }

    /**
     * Post event
     *
     * @param inDispatcher dispatcher
     */
    public void
    post (owned A? inArgs = null, Dispatcher inDispatcher = Dispatcher.self)
    {
        Event<A> event = new Event<A>.with_id (id, owner);
        event.m_Args = inArgs;
        event.m_Sender = true;
        Log.debug (GLib.Log.METHOD, "post event 0x%lx", id);
        inDispatcher.post_event (event);
    }

    /**
     * Listen event
     *
     * @param inCallback event callback
     * @param inDispatcher dispatcher
     */
    public void
    listen (Handler<A> inHandler, Dispatcher inDispatcher = Dispatcher.self)
    {
        EventListener event_listener = new EventListener (this, inHandler);
        inDispatcher.add_listener (event_listener);
        on_listen ();
    }
}

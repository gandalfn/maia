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
    public delegate void Callback (EventArgs? inArgs);

    // properties
    private Object    m_Owner = null;
    private EventArgs m_Args = null;

    // accessors
    internal Object? owner {
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
    public Event (string inName, Object? inOwner = null)
    {
        GLib.Object (id: inName);
        m_Owner = inOwner;
    }

    /**
     * Post event
     *
     * @param inArgs event args
     * @param inDispatcher dispatcher
     */
    public void
    post (EventArgs? inArgs = null, Dispatcher inDispatcher = Dispatcher.self ())
    {
        Event event = new Event (id, m_Owner);
        event.m_Args = inArgs;
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
        EventListener event_listener = new EventListener (this, inCallback);
        inDispatcher.add_listener (event_listener);
    }
}
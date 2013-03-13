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

public class Maia.Event<A> : Object
{
    // types
    internal struct Hash
    {
        public void*  owner;
        public uint32 id;

        public Hash (void* inOwner, uint32 inId)
        {
            owner = inOwner;
            id = inId;
        }

        public int
        compare (Hash inOther)
        {
            int ret = direct_compare (owner, inOther.owner);
            if (ret == 0)
            {
                return (int)(id - inOther.id);
            }

            return ret;
        }
    }

    /**
     * The listen event handler
     *
     * @param inArgs EventArgs of notification
     */
    public delegate void Handler<A> (A? inArgs);

    // accessors
    /**
     * The name of event
     */
    public string name {
        owned get {
            return id.to_string ();
        }
    }

    /**
     * The owner of event
     */
    public void* owner { get; construct; default = null; }

    // methods
    /**
     * Create a new event
     *
     * @param inName event name
     * @param inOwner owner of event
     */
    public Event (string inName, void* inOwner = null)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), owner: inOwner);
    }

    ~Event ()
    {
        Dispatcher.MessageDestroyEvent (Event.Hash (owner, id)).post ();
    }

    protected virtual void
    on_listen ()
    {
    }

    /**
     * Post event
     *
     * @param inArgs event args
     */
    public void
    post (A? inArgs = null)
        requires (inArgs is EventArgs)
    {
        Log.debug (GLib.Log.METHOD, "post event %s", name);

        Dispatcher.MessageEvent (Event.Hash (owner, id), inArgs as EventArgs).post ();
    }

    /**
     * Listen event
     *
     * @param inHandler event handler
     * @param inDispatcher dispatcher
     */
    public unowned EventListener?
    listen (owned Handler<A> inHandler, Dispatcher inDispatcher = Dispatcher.self)
    {
        unowned EventListener? listener = inDispatcher.create_event_listener (Event.Hash (owner, id), (owned)inHandler);
        if (listener != null)
        {
            on_listen ();
        }

        return listener;
    }

    internal override int
    compare (Object inObject)
    {
        int ret = direct_compare (owner, (inObject as Event).owner);
        if (ret == 0)
        {
            return base.compare (inObject);
        }

        return ret;
    }
}

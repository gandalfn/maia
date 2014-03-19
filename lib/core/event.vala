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

public class Maia.Core.Event : Object
{
    // types
    internal class Hash
    {
        public uint32 id;
        public void*  owner;

        public Hash (Event inEvent)
        {
            id = inEvent.id;
            owner = inEvent.owner;
        }

        public Hash.raw (string inName, void* inOwner)
        {
            id = GLib.Quark.from_string (inName);
            owner = inOwner;
        }

        public inline string
        name ()
        {
            return ((GLib.Quark)id).to_string ();
        }

        public inline int
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
    public delegate void Handler (EventArgs? inArgs);

    // properties
    private unowned EventBus m_EventBus;

    // accessors
    /**
     * The name of event
     */
    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
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
    public Event (string inName, void* inOwner = null, EventBus? inBus = EventBus.default)
    {
        Log.debug ("Event", Log.Category.MAIN_EVENT, "Create event %s %lx", inName, (ulong)inOwner);
        GLib.Object (id: GLib.Quark.from_string (inName), owner: inOwner);
        m_EventBus = inBus;
        m_EventBus.advertise (this);
    }

    ~Event ()
    {
        m_EventBus.destroy (this);
    }

    internal override int
    compare (Object inObject)
        requires (inObject is Event)
    {
        int ret = direct_compare (owner, (inObject as Event).owner);
        if (ret == 0)
        {
            return base.compare (inObject);
        }

        return ret;
    }

    /**
     * Publish event
     *
     * @param inArgs event args
     */
    public void
    publish (EventArgs? inArgs = null)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "publish event %s", name);

        m_EventBus.publish_event (this, inArgs);
    }

    /**
     * Publish event with reply
     *
     * @param inArgs event args
     * @param inHandler reply handler
     */
    public void
    publish_with_reply (EventArgs inArgs, Event.Handler inHandler)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "publish with reply event %s", name);

        m_EventBus.publish_event_with_reply (this, inArgs, inHandler);
    }

    /**
     * Publish event with reply
     *
     * @param inArgs event args
     * @param inHandler reply handler
     */
    public void
    object_publish_with_reply (EventArgs inArgs, Event.Handler inHandler)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "publish with reply event %s", name);

        m_EventBus.object_publish_event_with_reply (this, inArgs, inHandler);
    }

    /**
     * Subscribe to event
     *
     * @param inHandler event handler
     *
     * @return listener
     */
    public EventListener
    subscribe (Handler inHandler)
    {
        EventListener listener = new EventListener (this, inHandler);

        m_EventBus.subscribe (listener);

        return listener;
    }

    /**
     * Subscribe to event
     *
     * @param inHandler event handler
     *
     * @return listener
     */
    public EventListener
    object_subscribe (Handler inHandler)
    {
        EventListener listener = new EventListener.object (this, inHandler);

        m_EventBus.subscribe (listener);

        return listener;
    }
}

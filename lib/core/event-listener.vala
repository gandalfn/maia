/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-listener.vala
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

internal class Maia.Core.EventListenerPool : Object
{
    // properties
    private Event.Hash m_EventHash;

    // accessors
    public bool event_destroyed {
        set {
            foreach (Object child in this)
            {
                (child as EventListener).event_destroyed = value;
            }
        }
    }

    // methods
    public EventListenerPool (Event.Hash inEventHash)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "%s", ((GLib.Quark)inEventHash.id).to_string ());
        m_EventHash = inEventHash;
    }

    public new void
    notify (EventArgs? inEventArgs)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "%s", ((GLib.Quark)m_EventHash.id).to_string ());
        foreach (Object child in this)
        {
            (child as EventListener).notify (inEventArgs);
        }
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is EventListener;
    }

    internal override int
    compare (Object inOther)
    {
        return m_EventHash.compare ((inOther as EventListenerPool).m_EventHash);
    }

    internal inline int
    compare_with_event_hash (Event.Hash inEventHash)
    {
        return m_EventHash.compare (inEventHash);
    }
}

public class Maia.Core.EventListener : Object
{
    // properties
    private Event.Hash            m_EventHash;
    private unowned Event.Handler m_Handler;
    private unowned GLib.Object?  m_Target;
    private unowned BusConnection m_Connection;

    // accessors
    internal Event.Hash hash {
        get {
            return m_EventHash;
        }
    }

    // accessors
    [CCode (notify = false)]
    public bool event_destroyed { get; set; default = false; }

    /**
     * Block temporarily the event notification
     */
    [CCode (notify = false)]
    public bool block { get; set; default = false; }

    /**
     * Block the next event notification
     */
    [CCode (notify = false)]
    public int block_next_nb_events { get; set; default = 0; }

    // methods
    public EventListener (Event inEvent, Event.Handler inHandler)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "create eventlistener");

        m_EventHash = new Event.Hash (inEvent);
        m_Handler = inHandler;
    }

    public EventListener.object (Event inEvent, Event.Handler inHandler)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "create eventlistener");

        m_EventHash = new Event.Hash (inEvent);
        m_Handler = inHandler;

        m_Target = (*(void**)((&m_Handler) + 1)) as GLib.Object;
        GLib.return_val_if_fail (m_Target != null, null);
        m_Target.weak_ref (on_target_destroy);
    }

    ~EventListener ()
    {
        Log.audit ("~EventListener", Log.Category.MAIN_EVENT,  "");
        if (m_Target != null)
        {
            m_Target.weak_unref (on_target_destroy);
        }
        if (m_Connection != null && !event_destroyed)
        {
            try
            {
                m_Connection.send (new EventBus.MessageUnsubscribe (m_EventHash));
            }
            catch (BusError err)
            {
                Log.error (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Error on send unsubscribe: $(err.message)");
            }
            m_Connection.weak_unref (on_connection_destroy);
        }
    }

    private void
    on_connection_destroy ()
    {
        m_Connection = null;
    }

    private void
    on_target_destroy ()
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "target unref");
        m_Target = null;
        m_Handler = null;
        parent = null;
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is EventListener)
    {
        int result = (int)((ulong)m_Handler - (ulong)((EventListener)inOther).m_Handler);
        if (result == 0)
        {
            result = (int)((ulong)m_Target - (ulong)((EventListener)inOther).m_Target);
        }
        return result;
    }

    internal void
    attach (BusConnection inConnection)
    {
        m_Connection = inConnection;
        m_Connection.weak_ref (on_connection_destroy);
    }

    internal new void
    notify (EventArgs? inEventArgs)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_EVENT, "");

        if (!block && block_next_nb_events <= 0 && m_Handler != null)
        {
            m_Handler (inEventArgs);
        }
        else if (!block && block_next_nb_events > 0)
        {
            block_next_nb_events = int.max (0, block_next_nb_events - 1);
        }
    }
}

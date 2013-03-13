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

internal class Maia.EventListenerPool : Object
{
    // properties
    private Event.Hash m_EventHash;

    // methods
    public EventListenerPool (Event.Hash inEventHash)
    {
        Log.audit (GLib.Log.METHOD, "%s", ((GLib.Quark)inEventHash.id).to_string ());
        m_EventHash = inEventHash;
    }

    public new void
    notify (EventArgs? inEventArgs)
    {
        Log.audit (GLib.Log.METHOD, "%s", ((GLib.Quark)m_EventHash.id).to_string ());
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

    internal int
    compare_with_event_hash (Event.Hash inEventHash)
    {
        return m_EventHash.compare (inEventHash);
    }
}

public class Maia.EventListener : Object
{
    // properties
    private Event.Handler m_Handler;

    // accessors
    /**
     * Block temporarily the event notification
     */
    public bool block { get; set; default = false; }

    // methods
    internal EventListener (owned Event.Handler inHandler)
    {
        Log.debug (GLib.Log.METHOD, "create eventlistener");

        m_Handler = (owned)inHandler;
    }

    ~EventListener ()
    {
        Log.audit ("~EventListener", "");
    }

    internal new void
    notify (EventArgs? inEventArgs)
    {
        Log.audit (GLib.Log.METHOD, "");

        if (!block)
        {
            m_Handler (inEventArgs);
        }
    }

    /**
     * Destroy event listener, must be called to stop any event notification
     */
    public void
    destroy ()
    {
        Log.audit (GLib.Log.METHOD, "");
        parent = null;
    }
}

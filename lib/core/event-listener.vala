/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-listener.vala
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

internal class Maia.EventListener : Object
{
    // properties
    private unowned Event.Handler m_Handler;
    private void*                 m_Owner;

    // accessors
    public string name {
        get {
            return Atom.to_string (id);
        }
    }

    public void* owner {
        get {
            return m_Owner;
        }
    }

    // methods
    public EventListener (Event inEvent, Event.Handler inHandler)
    {
        Log.debug (GLib.Log.METHOD, "create eventlistener = %lu", inEvent.id);
        GLib.Object (id: inEvent.id);
        m_Owner = inEvent.owner;
        m_Handler = inHandler;
    }

    public new void
    notify (EventArgs? inArgs)
    {
        m_Handler (inArgs);
    }

    internal override int
    compare (Object inOther)
        requires (inOther is EventListener)
    {
        unowned EventListener other = inOther as EventListener;

        int ret = atom_compare (id, other.id);

        if (ret == 0)
        {
            ret = direct_compare (m_Owner, other.m_Owner);
        }

        if (ret == 0)
        {
             ret = m_Handler == other.m_Handler ? 0 : 1;
        }

        return ret;
    }
}

/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    private unowned Object m_Owner = null;
    private Event.Callback m_Callback;

    // accessors
    public Object owner {
        get {
            return m_Owner;
        }
    }

    // methods
    public EventListener (Event inEvent, Event.Callback inCallback)
    {
        GLib.Object (id: inEvent.id);
        m_Callback = inCallback;
        m_Owner = inEvent.owner;
    }

    public new void
    notify (EventArgs? inArgs)
    {
        m_Callback (inArgs);
    }
}
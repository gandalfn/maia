/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * damage-event.vala
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

internal class Maia.DamageEventArgs : EventArgs
{
    // properties
    private Region m_Area;

    // accessors
    public Region area {
        get {
            return m_Area;
        }
    }

    // methods
    public DamageEventArgs (Region inArea)
    {
        m_Area = inArea;
    }
}

internal class Maia.DamageEventListener : EventListener
{
    // methods
    public DamageEventListener (DamageEvent inEvent, DamageEvent.Callback inCallback)
    {
        base (inEvent);
        func = (a) => {
            DamageEventArgs args = (DamageEventArgs)a;
            inCallback (args.area);
        };
    }
}

public class Maia.DamageEvent : Event
{
    // types
    public delegate void Callback (Region inDamagedArea);

    // methods
    internal DamageEvent (View inView)
    {
        GLib.Object (owner: inView);
    }

    public new void
    post (Region inDamagedArea, Dispatcher inDispatcher = Dispatcher.self ())
    {
        DamageEventArgs args = new DamageEventArgs (inDamagedArea);
        DamageEvent event = GLib.Object.new (get_type (), id: id, owner: owner, args: args) as DamageEvent;

        inDispatcher.post_event (event);
    }

    public new void
    listen (Callback inCallback, Dispatcher inDispatcher = Dispatcher.self ())
    {
        DamageEventListener event_listener = new DamageEventListener (this, inCallback);

        inDispatcher.add_listener (event_listener);
    }
}
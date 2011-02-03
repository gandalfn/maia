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
    public unowned Object owner = null;
    public Event.Func func;

    // methods
    public EventListener (Event inEvent)
    {
        GLib.Object (id: inEvent.id);
        owner = inEvent.owner;
    }

    public new void
    notify (EventArgs? inArgs)
    {
        func (inArgs);
    }
}

internal class Maia.EventListener0 : EventListener
{
    public EventListener0 (Event inEvent, Event.Callback inCallback)
    {
        base (inEvent);
        func = (a) => {
            inCallback ();
        };
    }
}

internal class Maia.EventListenerR0<R> : EventListener
{
    public EventListenerR0 (Event inEvent, Event.CallbackR<R> inCallback)
    {
        base (inEvent);
        func = (a) => {
            EventArgsR<R> args = (EventArgsR<R>)a;
            args.ret = inCallback ();
        };
    }
}

internal class Maia.EventListener1<A> : EventListener
{
    public EventListener1 (Event inEvent, Event.Callback1<A> inCallback)
    {
        base (inEvent);
        func = (a) => {
            unowned EventArgs1<A> args = (EventArgs1<A>)a;
            inCallback (args.m_A);
        };
    }
}

internal class Maia.EventListenerR1<R, A> : EventListener
{
    public EventListenerR1 (Event inEvent, Event.CallbackR1<R, A> inCallback)
    {
        base (inEvent);
        func = (a) => {
            unowned EventArgsR1<R, A> args = (EventArgsR1<R, A>)a;
            args.ret = inCallback (args.m_A);
        };
    }
}

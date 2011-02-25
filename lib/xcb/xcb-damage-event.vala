/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-damage-event.vala
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

internal class Maia.XcbDamageEvent : DamageEvent
{
    // accessors
    public uint32 mask {
        get {
            return Xcb.EventMask.EXPOSURE;
        }
    }

    // static methods
    public static void
    post_event (Xcb.GenericEvent inEvent)
    {
        Xcb.ExposeEvent evt = (Xcb.ExposeEvent)inEvent;
        XcbDamageEvent damage_event = new XcbDamageEvent (evt.window);
        DamageEventArgs args = new DamageEventArgs (new Region.raw_rectangle (evt.x, evt.y, evt.width, evt.height));

        damage_event.post (args);
    }

    // methods
    public XcbDamageEvent (Xcb.Window inWindow)
    {
        base (Xcb.EXPOSE, ((uint)inWindow).to_pointer ());
    }
}
/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-geometry-event.vala
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

internal class Maia.XcbGeometryEvent : GeometryEvent
{
    // properties
    private unowned XcbWindow m_Window;

    // static methods
    public static new void
    post_event (Xcb.GenericEvent inEvent)
    {
        unowned Xcb.ConfigureNotifyEvent evt = (Xcb.ConfigureNotifyEvent)inEvent;
        GeometryEventArgs args = new GeometryEventArgs (new Graphic.Region (Graphic.Rectangle(evt.x, evt.y,
                                                                                              evt.width + (evt.border_width * 2),
                                                                                              evt.height + (evt.border_width * 2))));
        Log.audit (GLib.Log.METHOD, "0x%lx", evt.window);
        GeometryEvent.post_event (((uint)evt.window).to_pointer (), args);
    }

    // methods
    public XcbGeometryEvent (XcbWindow inWindow)
    {
        base (((uint)inWindow.id).to_pointer ());
        m_Window = inWindow;
    }

    protected override void
    on_listen ()
    {
        uint32 mask = m_Window.event_mask;

        if ((mask & Xcb.EventMask.STRUCTURE_NOTIFY) != Xcb.EventMask.STRUCTURE_NOTIFY ||
            (mask & Xcb.EventMask.SUBSTRUCTURE_NOTIFY) != Xcb.EventMask.SUBSTRUCTURE_NOTIFY)
        {
            m_Window.event_mask |= Xcb.EventMask.STRUCTURE_NOTIFY |
                                   Xcb.EventMask.SUBSTRUCTURE_NOTIFY;
        }
    }
}

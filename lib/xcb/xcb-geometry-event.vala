/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-geometry-event.vala
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

internal class Maia.XcbGeometryEvent : GeometryEvent
{
    // properties
    private unowned XcbWindow m_Window = null;
    private int m_ListenCount          = 0;

    // static methods
    public static new void
    post_event (Xcb.GenericEvent inEvent)
    {
        Xcb.ConfigureNotifyEvent evt = (Xcb.ConfigureNotifyEvent)inEvent;
        GeometryEventArgs args = new GeometryEventArgs (new Region.raw_rectangle (evt.x, evt.y, 
                                                                                  evt.width + (evt.border_width * 2),
                                                                                  evt.height + (evt.border_width * 2)));
        Event.post_event<GeometryEventArgs> (Xcb.CONFIGURE_NOTIFY, ((uint)evt.window).to_pointer (), args);
    }

    // methods
    public XcbGeometryEvent (XcbWindow inWindow)
    {
        base (Xcb.CONFIGURE_NOTIFY, ((uint)inWindow.id).to_pointer ());
        m_Window = inWindow;
    }

    protected override void
    on_listen ()
    {
        if (m_Window != null && m_ListenCount == 0)
        {
            m_Window.event_mask |= Xcb.EventMask.STRUCTURE_NOTIFY |
                                   Xcb.EventMask.SUBSTRUCTURE_NOTIFY;
        }
        ++m_ListenCount;
    }
}
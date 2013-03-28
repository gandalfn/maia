/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-event-dispatcher.vala
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

internal class Maia.XcbEventDispatcher : Watch
{
    // properties
    private unowned Xcb.Connection m_Connection;

    // methods
    public XcbEventDispatcher (Dispatcher inDispatcher, Xcb.Connection inConnection)
    {
        Log.audit (GLib.Log.METHOD, "Create event dispatcher %i", inConnection.file_descriptor);
        base (inConnection.file_descriptor, inDispatcher.context);

        m_Connection = inConnection;
    }

    internal override bool
    on_process ()
    {
        Xcb.GenericEvent? evt = null;

        while ((evt = m_Connection.poll_for_event ()) != null)
        {
            int response_type = evt.response_type & ~0x80;
            Log.audit (GLib.Log.METHOD, "received %i", response_type);
            switch (response_type)
            {
                case Xcb.EventType.CREATE_NOTIFY:
                    XcbCreateWindowEvent.post_event (evt);
                    break;
                case Xcb.EventType.DESTROY_NOTIFY:
                    XcbDestroyWindowEvent.post_event (evt);
                    break;
                case Xcb.EventType.CONFIGURE_NOTIFY:
                    XcbGeometryEvent.post_event (evt);
                    break;
                case Xcb.EventType.EXPOSE:
                    XcbDamageEvent.post_event (evt);
                    break;
            }
        }

        return true;
    }

    internal override void
    on_error ()
    {
        // TODO:
    }
}

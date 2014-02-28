/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * connection-watch.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.ConnectionWatch : Core.Watch
{
    // properties
    private unowned global::Xcb.Connection m_Connection;

    // methods
    public ConnectionWatch (global::Xcb.Connection inConnection)
    {
        base (inConnection.file_descriptor);

        m_Connection = inConnection;
    }

    internal override void
    on_error ()
    {
        // TODO
    }

    internal override bool
    on_process ()
    {
        global::Xcb.GenericEvent? evt = null;

        while ((evt = m_Connection.poll_for_event ()) != null)
        {
            int response_type = evt.response_type & ~0x80;
            switch (response_type)
            {
                // Expose event
                case global::Xcb.EventType.EXPOSE:
                    unowned global::Xcb.ExposeEvent evt_expose = (global::Xcb.ExposeEvent)evt;
                    
                    // send event damage
                    Core.EventBus.default.publish ("damage", ((int)evt_expose.window).to_pointer (),
                                                   new DamageEventArgs (evt_expose.x, evt_expose.y,
                                                                        evt_expose.width, evt_expose.height));
                    break;
            }
        }

        return true;
    }
}

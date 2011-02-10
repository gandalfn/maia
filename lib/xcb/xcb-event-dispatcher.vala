/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-event-dispatcher.vala
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

internal class Maia.XcbEventDispatcher : Watch
{
    // properties
    private XcbDesktop m_Desktop;

    // methods
    public XcbEventDispatcher (XcbDesktop inDesktop)
    {
        base (inDesktop.connection.get_file_descriptor (), Watch.Flags.IN);
        m_Desktop = inDesktop;
    }

    public override void*
    main ()
    {
        Xcb.GenericEvent? evt = null;
        Xcb.Connection connection = m_Desktop.connection;

        while ((evt = connection.poll_for_event ()) != null)
        {
            int response_type = evt.response_type & ~0x80;
            audit (GLib.Log.METHOD, "received %i", response_type);
        }

        return base.main ();
    }
}
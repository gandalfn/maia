/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-client-message-event.vala
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

internal class Maia.XcbClientMessageEvent
{
    // properties
    private unowned XcbDesktop m_Desktop;
    private Xcb.Atom           m_WMProtocolsAtom;
    private Xcb.Atom           m_DeleteWindowAtom;

    // methods
    public XcbClientMessageEvent (XcbDesktop inDesktop)
    {
        m_Desktop = inDesktop;
        m_WMProtocolsAtom = inDesktop.atoms[XcbAtomType.WM_PROTOCOLS];
        m_DeleteWindowAtom = inDesktop.atoms[XcbAtomType.WM_DELETE_WINDOW];
    }

    private void
    dispatch_wm_protocols (Xcb.ClientMessageEvent inEvent)
    {
        Xcb.Atom request = inEvent.data.data32[0];
        if (request == m_DeleteWindowAtom)
        {
            XcbDeleteEvent.post_event (inEvent);
        }
    }

    public void
    dispatch (Xcb.GenericEvent inEvent)
    {
        Xcb.ClientMessageEvent evt = (Xcb.ClientMessageEvent)inEvent;

        if (evt.type == m_WMProtocolsAtom)
        {
            dispatch_wm_protocols (evt);
        }
    }
}
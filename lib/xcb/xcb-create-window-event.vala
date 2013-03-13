/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-create-window-event.vala
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

internal class Maia.XcbCreateWindowEvent : CreateWindowEvent
{
    // properties
    private unowned XcbWorkspace m_Workspace;

    // static methods
    public static void
    post_event (Xcb.GenericEvent inEvent)
    {
        unowned Xcb.CreateNotifyEvent? evt = (Xcb.CreateNotifyEvent?)inEvent;

        XcbWindow window = new XcbWindow (evt.window);

        CreateWindowEvent.post (((uint)evt.parent).to_pointer (), new CreateWindowEventArgs (window));
    }

    // methods
    public XcbCreateWindowEvent (XcbWorkspace inWorkspace)
    {
        base (((uint)inWorkspace.root.id).to_pointer ());
        m_Workspace = inWorkspace;
    }

    public override void
    on_listen ()
    {
        uint32 mask = m_Workspace.root.event_mask;

        if ((mask & Xcb.EventMask.STRUCTURE_NOTIFY) != Xcb.EventMask.STRUCTURE_NOTIFY ||
            (mask & Xcb.EventMask.SUBSTRUCTURE_NOTIFY) != Xcb.EventMask.SUBSTRUCTURE_NOTIFY)
        {
            m_Workspace.root.event_mask |= Xcb.EventMask.STRUCTURE_NOTIFY | Xcb.EventMask.SUBSTRUCTURE_NOTIFY;
        }
    }
}

/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-reparent-window-event.vala
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

internal class Maia.XcbReparentWindowEvent : ReparentWindowEvent
{
    // properties
    private unowned XcbWindow m_Window = null;
    private int m_ListenCount          = 0;

    // static methods
    public static void
    post_event (Xcb.GenericEvent inEvent)
    {
        Xcb.ReparentNotifyEvent evt = (Xcb.ReparentNotifyEvent)inEvent;
        XcbWorkspace workspace = Application.default.desktop.default_workspace.proxy as XcbWorkspace;
        unowned Window? parent = workspace.find_window (evt.parent);
        unowned Window? window = workspace.find_window (evt.window);

        if (parent != null && window != null)
        {
            XcbReparentWindowEvent reparent_window_event = new XcbReparentWindowEvent.from_event (evt);

            ReparentWindowEventArgs args = new ReparentWindowEventArgs (parent, window);
            reparent_window_event.post (args);
        }
    }

    // methods
    public XcbReparentWindowEvent (XcbWindow inWindow)
    {
        base (Xcb.REPARENT_NOTIFY, ((uint)inWindow.id).to_pointer ());
        m_Window = inWindow;
    }

    public XcbReparentWindowEvent.from_event (Xcb.ReparentNotifyEvent inEvent)
    {
        base (Xcb.REPARENT_NOTIFY, ((uint)inEvent.event).to_pointer ());
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
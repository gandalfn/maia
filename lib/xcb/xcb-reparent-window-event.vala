/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-reparent-window-event.vala
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

internal class Maia.XcbReparentWindowEvent : ReparentWindowEvent
{
    // properties
    private unowned XcbWindow m_Window = null;
    private int m_ListenCount          = 0;

    // static methods
    public static new void
    post_event (Xcb.GenericEvent inEvent)
    {
        Xcb.ReparentNotifyEvent evt = (Xcb.ReparentNotifyEvent)inEvent;
        unowned Application? application = Application.default;

        if (application != null)
        {
            unowned Desktop? desktop = application.desktop;

            if (desktop != null)
            {
                foreach (unowned Workspace workspace in desktop)
                {
                    unowned Window? event = (Window)workspace[evt.event];

                    if (event != null && event == workspace.root)
                    {
                        unowned Window? parent = (Window)workspace[evt.parent];
                        unowned Window? window = (Window)workspace[evt.window];

                        if (parent != null && window != null)
                        {
                            ReparentWindowEventArgs args = new ReparentWindowEventArgs (parent, window);
                            window.proxy.parent = parent;
                            workspace.reparent_window_event.post (args);

                            break;
                        }
                    }
                }
            }
        }
    }

    // methods
    public XcbReparentWindowEvent (XcbWindow inWindow)
    {
        base (((uint)inWindow.id).to_pointer ());
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

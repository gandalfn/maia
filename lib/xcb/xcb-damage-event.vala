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
    // properties
    private unowned XcbWindow m_Window = null;
    private int m_ListenCount          = 0;

    // static methods
    public static void
    post_event (Xcb.GenericEvent inEvent)
    {
        Xcb.ExposeEvent evt = (Xcb.ExposeEvent)inEvent;
        unowned Application? application = Application.default;

        if (application != null)
        {
            unowned Desktop? desktop = application.desktop;

            if (desktop != null)
            {
                foreach (unowned Workspace workspace in desktop)
                {
                    unowned Window? window = (workspace.proxy as XcbWorkspace).find_window (evt.window);

                    if (window != null)
                    {
                        DamageEventArgs args = new DamageEventArgs (new Region.raw_rectangle (evt.x, evt.y, evt.width, evt.height));

                        window.damage_event.post (args);

                        break;
                    }
                }
            }
        }
    }

    // methods
    public XcbDamageEvent (XcbWindow inWindow)
    {
        base (Xcb.EXPOSE, ((uint)inWindow.id).to_pointer ());
        m_Window = inWindow;
    }

    public XcbDamageEvent.from_event (Xcb.ExposeEvent inEvent)
    {
        base (Xcb.EXPOSE, ((uint)inEvent.window).to_pointer ());
        is_sender = true;
    }

    protected override void
    on_listen ()
    {
        if (m_Window != null && m_ListenCount == 0)
        {
            m_Window.event_mask |= Xcb.EventMask.EXPOSURE;
        }
        ++m_ListenCount;
    }
}
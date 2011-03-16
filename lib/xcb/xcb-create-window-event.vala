/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-create-window-event.vala
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

internal class Maia.XcbCreateWindowEvent : CreateWindowEvent
{
    // properties
    private unowned XcbWindow m_Window = null;
    private int m_ListenCount          = 0;

    // static methods
    public static void
    post_event (Xcb.GenericEvent inEvent)
    {
        Xcb.CreateNotifyEvent evt = (Xcb.CreateNotifyEvent)inEvent;
        XcbCreateWindowEvent create_window_event = new XcbCreateWindowEvent.from_event (evt);

        Window new_window = GLib.Object.new (typeof (Window), parent: evt.parent) as Window;
        unowned XcbWindow? proxy = new_window.delegate_cast<XcbWindow> ();
        proxy.foreign (evt.window);
        new_window.proxy = proxy;

        CreateWindowEventArgs args = new CreateWindowEventArgs (new_window);
        create_window_event.post (args);
    }

    // methods
    public XcbCreateWindowEvent (XcbWindow inWindow)
    {
        base (Xcb.CREATE_NOTIFY, ((uint)inWindow.xcb_window).to_pointer ());
        m_Window = inWindow;
    }

    public XcbCreateWindowEvent.from_event (Xcb.CreateNotifyEvent inEvent)
    {
        base (Xcb.CREATE_NOTIFY, ((uint)inEvent.parent).to_pointer ());
    }

    protected override void
    on_listen ()
    {
        if (m_Window != null && m_ListenCount == 0)
        {
            m_Window.attributes.event_mask |= Xcb.EventMask.STRUCTURE_NOTIFY      |
                                              Xcb.EventMask.SUBSTRUCTURE_NOTIFY   |
                                              Xcb.EventMask.SUBSTRUCTURE_REDIRECT;
            m_Window.attributes.commit ();
        }
        ++m_ListenCount;
    }
}
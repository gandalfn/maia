/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-attributes.vala
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

internal class Maia.XcbWindowAttributes : XcbRequest
{
    // properties
    private uint m_Mask = 0;
    private bool m_OverrideRedirect = false;
    private bool m_IsViewable = false;
    private bool m_IsInputOnly = false;
    private uint m_EventMask = 0;

    private unowned Notification1.Observer<Object, string>? m_XcbWindowPropertyObserver;
    private unowned Notification1.Observer<Object, string>? m_WindowPropertyObserver;

    // accessors
    [CCode (notify = false)]
    public bool override_redirect {
        get {
            return m_OverrideRedirect;
        }
        set {
            m_OverrideRedirect = value;
            on_property_changed ("override-redirect");
        }
    }

    [CCode (notify = false)]
    public bool is_viewable {
        get {
            return m_IsViewable;
        }
        protected set {
            m_IsViewable = value;
            on_property_changed ("is-viewable");
        }
    }

    [CCode (notify = false)]
    public bool is_input_only {
        get {
            return m_IsInputOnly;
        }
        protected set {
            m_IsInputOnly = value;
            on_property_changed ("is-input-only");
        }
    }

    [CCode (notify = false)]
    public uint event_mask {
        get {
            return m_EventMask;
        }
        set {
            m_EventMask = value;
            on_property_changed ("event-mask");
        }
    }

    // methods
    construct
    {
        m_XcbWindowPropertyObserver = window.property_changed.watch (on_xcb_window_property_changed);
        m_WindowPropertyObserver = window.delegator.property_changed.watch (on_window_property_changed);
        m_EventMask = window.event_mask;
        m_IsViewable = ((Window)window.delegator).is_viewable;
        m_IsInputOnly = ((Window)window.delegator).is_input_only;
    }

    public XcbWindowAttributes (XcbWindow inWindow)
    {
        base (inWindow);
    }

    private void
    on_xcb_window_property_changed (Object inObject, string inName)
    {
        switch (inName)
        {
            case "event-mask":
                m_EventMask = ((XcbWindow)inObject).event_mask; 
                m_Mask |= Xcb.CW.EVENT_MASK;
                commit ();
                break;
        }
    }

    private void
    on_window_property_changed (Object inObject, string inName)
    {
        switch (inName)
        {
            case "is-viewable":
                m_IsViewable = ((Window)inObject).is_viewable;
                break;
            case "is-input-only":
                m_IsInputOnly = ((Window)inObject).is_input_only;
                break;
        }
    }

    internal override void
    on_property_changed (string inName)
    {
        switch (inName)
        {
            case "event-mask":
                if (m_XcbWindowPropertyObserver != null) m_XcbWindowPropertyObserver.block = true;
                window.event_mask = m_EventMask;
                if (m_XcbWindowPropertyObserver != null) m_XcbWindowPropertyObserver.block = false;
                break;

            case "is-viewable":
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = true;
                ((Window)window.delegator).is_viewable = m_IsViewable;
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = false;
                break;

            case "is-input-only":
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = true;
                ((Window)window.delegator).is_input_only = m_IsInputOnly;
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = false;
                break;
        }
        base.on_property_changed (inName);
    }

    protected override void
    on_reply ()
    {
        base.on_reply ();

        unowned XcbDesktop desktop = window.xcb_desktop;
        Xcb.GetWindowAttributesReply reply = ((Xcb.GetWindowAttributesCookie?)cookie).reply (desktop.connection);
        if (reply != null)
        {
            override_redirect = (bool)reply.override_redirect;
            event_mask = reply.all_event_masks;
            is_viewable = reply.map_state == Xcb.MapState.VIEWABLE;
            is_input_only = reply._class == Xcb.WindowClass.INPUT_ONLY;
        }
        else 
            error (GLib.Log.METHOD, "Error on get window attributes");
    }

    protected override void
    on_commit ()
    {
        uint32[] values_list = {};

        if ((m_Mask & Xcb.CW.OVERRIDE_REDIRECT) == Xcb.CW.OVERRIDE_REDIRECT)
        {
            values_list += (uint32)override_redirect;
        }
        if ((m_Mask & Xcb.CW.EVENT_MASK) == Xcb.CW.EVENT_MASK)
        {
            values_list += (uint32)event_mask;
        }

        debug (GLib.Log.METHOD, "%u", m_Mask);
        XcbDesktop desktop = window.xcb_desktop;
        ((Xcb.Window)window.id).change_attributes (desktop.connection, m_Mask, values_list);

        m_Mask = 0;

        base.on_commit ();
    }

    public override void
    query ()
    {
        XcbDesktop desktop = window.xcb_desktop;
        Xcb.GetWindowAttributesCookie? c = ((Xcb.Window)window.id).get_attributes (desktop.connection);
        cookie = (Xcb.VoidCookie?)c;

        base.query ();
    }
}
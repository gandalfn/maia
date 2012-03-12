/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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

    // accessors
    public bool override_redirect {
        get {
            return m_OverrideRedirect;
        }
        set {
            m_OverrideRedirect = value;
        }
    }

    public bool is_viewable {
        get {
            return m_IsViewable;
        }
        protected set {
            m_IsViewable = value;
        }
    }

    public bool is_input_only {
        get {
            return m_IsInputOnly;
        }
        protected set {
            m_IsInputOnly = value;
        }
    }

    public uint event_mask {
        get {
            rw_lock.read_lock ();
            uint ret = m_EventMask;
            rw_lock.read_unlock ();

            return ret;
        }
        set {
            m_EventMask = value;
        }
    }

    // methods
    construct
    {
        window.notify["event-mask"].connect (() => {
            rw_lock.write_lock ();
            m_EventMask = window.event_mask;
            m_Mask |= Xcb.CW.EVENT_MASK;
            rw_lock.write_unlock ();
            commit ();
        });

        window.delegator.notify["is-viewable"].connect (() => {
            m_IsViewable = ((Window)window.delegator).is_viewable;
        });
        window.delegator.notify["is-input-only"].connect (() => {
            m_IsInputOnly = ((Window)window.delegator).is_input_only;
        });

        m_EventMask = window.event_mask;
        m_IsViewable = ((Window)window.delegator).is_viewable;
        m_IsInputOnly = ((Window)window.delegator).is_input_only;

        notify["event-mask"].connect (() => {
            window.event_mask = m_EventMask;
        });
        notify["is-viewable"].connect (() => {
            ((Window)window.delegator).is_viewable = m_IsViewable;
        });
        notify["is-input-only"].connect (() => {
            ((Window)window.delegator).is_input_only = m_IsInputOnly;
        });
    }

    public XcbWindowAttributes (XcbWindow inWindow)
    {
        base (inWindow);
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
            Log.error (GLib.Log.METHOD, "Error on get window attributes");
    }

    protected override void
    on_commit ()
    {
        uint32[] values_list = {};

        rw_lock.read_lock ();
        uint mask = m_Mask;
        rw_lock.read_unlock ();

        if ((mask & Xcb.CW.OVERRIDE_REDIRECT) == Xcb.CW.OVERRIDE_REDIRECT)
        {
            values_list += (uint32)override_redirect;
        }
        if ((mask & Xcb.CW.EVENT_MASK) == Xcb.CW.EVENT_MASK)
        {
            values_list += (uint32)event_mask;
        }

        debug (GLib.Log.METHOD, "%u", mask);
        XcbDesktop desktop = window.xcb_desktop;
        ((Xcb.Window)window.id).change_attributes (desktop.connection, mask, values_list);

        rw_lock.write_lock ();
        m_Mask = 0;
        rw_lock.write_unlock ();

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

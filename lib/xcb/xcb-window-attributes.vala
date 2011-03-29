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
    private uint m_EventMask = 0;

    // accessors
    [CCode (notify = false)]
    public bool override_redirect {
        get {
            return m_OverrideRedirect;
        }
        set {
            m_OverrideRedirect = value;
            m_Mask |= Xcb.CW.OVERRIDE_REDIRECT;
        }
    }

    [CCode (notify = false)]
    public uint event_mask {
        get {
            return m_EventMask;
        }
        set {
            m_EventMask = value;
            m_Mask |= Xcb.CW.EVENT_MASK;
        }
    }

    // methods
    public XcbWindowAttributes (XcbWindow inWindow)
    {
        base (inWindow);
    }

    protected override void
    on_reply ()
    {
        base.on_reply ();

        XcbDesktop desktop = window.xcb_desktop;
        Xcb.GetWindowAttributesReply reply = ((Xcb.GetWindowAttributesCookie?)cookie).reply (desktop.connection);
        if (reply != null)
        {
            m_OverrideRedirect = (bool)reply.override_redirect;
            m_EventMask = reply.all_event_masks;
        }
    }

    protected override void
    on_commit ()
    {
        base.on_commit ();

        uint32[] values_list = {};

        if ((m_Mask & Xcb.CW.OVERRIDE_REDIRECT) == Xcb.CW.OVERRIDE_REDIRECT)
        {
            values_list += (uint32)m_OverrideRedirect;
        }
        if ((m_Mask & Xcb.CW.EVENT_MASK) == Xcb.CW.EVENT_MASK)
        {
            values_list += (uint32)m_EventMask;
        }

        debug (GLib.Log.METHOD, "");
        XcbDesktop desktop = window.xcb_desktop;
        ((Xcb.Window)window.id).change_attributes (desktop.connection, m_Mask, values_list);
    }

    public override void
    query ()
    {
        XcbDesktop desktop = window.xcb_desktop;
        cookie = ((Xcb.Window)window.id).get_attributes (desktop.connection);
    }

    public override string
    to_string ()
    {
        string ret = "    override redirect = %s\n".printf (m_OverrideRedirect.to_string ());
        ret += "    event mask %s\n".printf (m_EventMask.to_string ());

        return ret;
    }
}
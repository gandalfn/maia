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

    // accessors
    public bool override_redirect { get; set; default = false; }
    public bool is_viewable { get; protected set; default = false; }
    public bool is_input_only { get; protected set; default = false; }
    public uint event_mask { get; set; default = 0; }

    // methods
    construct
    {
        bind_property ("event-mask", window, "event-mask", 
                       GLib.BindingFlags.BIDIRECTIONAL,
                       null, on_set_event_mask);
        bind_property ("is-viewable", window.delegator, "is-viewable", 
                       GLib.BindingFlags.BIDIRECTIONAL);
        bind_property ("is-input-only", window.delegator, "is-input-only", 
                       GLib.BindingFlags.BIDIRECTIONAL);
    }

    public XcbWindowAttributes (XcbWindow inWindow)
    {
        base (inWindow);
    }

    private bool
    on_set_event_mask (GLib.Binding inBinding, GLib.Value inSrc, GLib.Value inTarget)
    {
        audit (GLib.Log.METHOD, "id: 0x%lx mask: %u", window.id, (uint)inSrc);
        inTarget = inSrc;
        m_Mask |= Xcb.CW.EVENT_MASK;
        commit ();

        return true;
    }

    protected override void
    on_reply ()
    {
        base.on_reply ();

        XcbDesktop desktop = window.xcb_desktop;
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

        debug (GLib.Log.METHOD, "");
        XcbDesktop desktop = window.xcb_desktop;
        ((Xcb.Window)window.id).change_attributes (desktop.connection, m_Mask, values_list);

        base.on_commit ();
    }

    public override void
    query ()
    {
        XcbDesktop desktop = window.xcb_desktop;
        cookie = ((Xcb.Window)window.id).get_attributes (desktop.connection);

        base.query ();
    }
}
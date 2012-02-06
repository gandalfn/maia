/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-geometry.vala
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

internal class Maia.XcbWindowGeometry : XcbRequest
{
    // properties
    private Region m_Area;

    private unowned Notification1.Observer<Object, string>? m_WindowPropertyObserver;

    // accessors
    [CCode (notify = false)]
    public Region area {
        get {
            return m_Area;
        }
        set {
            m_Area = value;
            on_property_changed ("area");
        }
    }

    // methods
    construct
    {
        m_Area = new Region ();

        m_WindowPropertyObserver = window.delegator.property_changed.watch (on_window_property_changed);
        if (!((Window)window.delegator).is_foreign)
        {
            m_Area = ((Window)window.delegator).geometry;
            commit ();
        }
    }

    public XcbWindowGeometry (XcbWindow inWindow)
    {
        base (inWindow);
    }

    private void
    on_window_property_changed (Object inObject, string inName)
    {
        switch (inName)
        {
            case "geometry":
                m_Area = ((Window)inObject).geometry;
                break;
        }
    }

    internal override void
    on_property_changed (string inName)
    {
        switch (inName)
        {
            case "area":
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = true;
                window.geometry = m_Area;
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
        Xcb.GetGeometryReply reply = ((Xcb.GetGeometryCookie?)cookie).reply (desktop.connection);

        if (reply != null)
        {
            m_Area = new Region.raw_rectangle (reply.x, reply.y,
                                               reply.width + (reply.border_width * 2),
                                               reply.height + (reply.border_width * 2));
            on_property_changed ("area");
        }
    }

    public override void
    query ()
    {
        XcbDesktop desktop = window.xcb_desktop;
        Xcb.GetGeometryCookie? c = ((Xcb.Window)window.id).get_geometry (desktop.connection);
        cookie = (Xcb.VoidCookie?)c;

        base.query ();
    }
}
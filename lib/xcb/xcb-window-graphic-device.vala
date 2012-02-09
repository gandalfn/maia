/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-graphic-device.vala
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

internal class Maia.XcbWindowGraphicDevice : CairoGraphicDevice
{
    // properties
    private unowned XcbWindow? m_Window = null;
    private Xcb.CairoSurface   m_Surface = null;

    // accessors
    public override Cairo.Surface surface {
        get {
            rw_lock.read_lock ();
            unowned Cairo.Surface? ret = m_Surface;
            rw_lock.read_unlock ();
            return ret;
        }
    }

    // methods
    public XcbWindowGraphicDevice (XcbWindow inWindow)
    {
        m_Window = inWindow;

        // Connect on geometry changed
        m_Window.property_changed.watch (on_window_property_changed);

        // Create surface
        unowned XcbWorkspace? xcb_workspace = (XcbWorkspace)((Window)m_Window.delegator).workspace.proxy;
        m_Surface = new Xcb.CairoSurface (m_Window.xcb_desktop.connection, m_Window.id,
                                          xcb_workspace.xcb_visual,
                                          (int)m_Window.geometry.clipbox.size.width,
                                          (int)m_Window.geometry.clipbox.size.height);
    }

    private void
    on_window_property_changed (Object? inObject, string inName)
    {
        switch (inName)
        {
            case "geometry":
                rw_lock.write_lock ();
                m_Surface.set_size ((int)m_Window.geometry.clipbox.size.width,
                                    (int)m_Window.geometry.clipbox.size.height);
                rw_lock.write_unlock ();
                break;
        }
    }
}

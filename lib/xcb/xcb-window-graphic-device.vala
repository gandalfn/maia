/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-graphic-device.vala
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

internal class Maia.XcbWindowGraphicDevice : Graphic.Cairo.Device
{
    // properties
    private unowned XcbWindow? m_Window = null;
    private Xcb.CairoSurface   m_Surface = null;
    private Graphic.Size       m_Size = Graphic.Size ();

    // accessors
    public override Cairo.Surface surface {
        get {
            return m_Surface;
        }
    }

    // methods
    public XcbWindowGraphicDevice (XcbWindow inWindow)
    {
        m_Window = inWindow;

        // Connect on geometry changed
        m_Window.notify["geometry"].connect (on_window_property_changed);

        // Create surface
        unowned XcbWorkspace? xcb_workspace = (XcbWorkspace)((Window)m_Window.delegator).workspace.proxy;
        m_Surface = new Xcb.CairoSurface (m_Window.xcb_desktop.connection, m_Window.id,
                                          xcb_workspace.xcb_visual,
                                          (int)m_Window.geometry.extents.size.width,
                                          (int)m_Window.geometry.extents.size.height);
    }

    private void
    on_window_property_changed ()
    {
        if (m_Surface == null || !m_Window.geometry.extents.size.compare (m_Size))
        {
            // Affect current size
            m_Size.set (m_Window.geometry.extents.size);

            // Set surface size
            write_lock ();
            m_Surface.set_size ((int)m_Window.geometry.extents.size.width,
                                (int)m_Window.geometry.extents.size.height);
            write_unlock ();
        }
    }
}

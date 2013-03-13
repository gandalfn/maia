/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-offscreen-graphic-device.vala
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

internal class Maia.XcbOffscreenGraphicDevice : Graphic.Cairo.Device
{
    // properties
    private unowned XcbWindow? m_Window = null;
    private Cairo.Surface      m_Surface = null;
    private Graphic.Size       m_Size = Graphic.Size ();

    // accessors
    public override Cairo.Surface surface {
        get {
            return m_Surface;
        }
    }

    // methods
    public XcbOffscreenGraphicDevice (XcbWindow inWindow)
    {
        m_Window = inWindow;

        // Connect on geometry changed
        m_Window.notify["geometry"].connect (create_surface);

        // Create surface
        create_surface ();
    }

    ~XcbOffscreenGraphicDevice ()
    {
        ((Xcb.Pixmap)id).destroy (m_Window.xcb_desktop.connection);
        id = 0;
    }

    private void
    create_surface ()
    {
        unowned Xcb.Connection? connection = m_Window.xcb_desktop.connection;

        if (m_Surface == null || !m_Window.geometry.extents.size.compare (m_Size))
        {
            // Affect current size
            m_Size.set (m_Window.geometry.extents.size);

            // destroy old pixmap
            Xcb.Pixmap pixmap = (Xcb.Pixmap)id;

            write_lock ();
            if (pixmap != 0)
                pixmap.destroy (m_Window.xcb_desktop.connection);

            // Create pixmap
            pixmap = Xcb.Pixmap (connection);
            connection.create_pixmap (24, pixmap, (Xcb.Drawable)m_Window.id,
                                      (uint16)m_Window.geometry.extents.size.width,
                                      (uint16)m_Window.geometry.extents.size.height);

            unowned XcbWorkspace? xcb_workspace = (XcbWorkspace)((Window)m_Window.delegator).workspace.proxy;

            m_Surface = new Xcb.CairoSurface (connection, pixmap,
                                              xcb_workspace.xcb_visual,
                                              (int)m_Window.geometry.extents.size.width,
                                              (int)m_Window.geometry.extents.size.height);

            // Cleanup pixmap
            var ctx = new Cairo.Context (m_Surface);
            ctx.set_operator (Cairo.Operator.CLEAR);
            ctx.paint ();
            write_unlock ();

            id = pixmap;
            Log.audit (GLib.Log.METHOD, "pixmap %lu", pixmap);

            m_Window.xcb_desktop.flush ();
        }
    }
}

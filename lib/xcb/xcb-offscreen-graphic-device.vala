/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-offscreen-graphic-device.vala
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

internal class Maia.XcbOffscreenGraphicDevice : CairoGraphicDevice
{
    // properties
    private unowned XcbWindow? m_Window = null;
    private Cairo.Surface      m_Surface = null;
    private Notification1.Observer<Object, string> m_PropertyChangedObserver;

    // accessors
    public override Cairo.Surface surface {
        get {
            unowned Cairo.Surface? ret = m_Surface;

            return ret;
        }
    }

    // methods
    public XcbOffscreenGraphicDevice (XcbWindow inWindow)
    {
        m_Window = inWindow;

        // Connect on geometry changed
        m_PropertyChangedObserver = m_Window.property_changed.watch (on_window_property_changed);

        // Create surface
        create_surface ();
    }

    ~XcbOffscreenGraphicDevice ()
    {
        m_PropertyChangedObserver.destroy ();
        ((Xcb.Pixmap)id).destroy (m_Window.xcb_desktop.connection);
        id = 0;
    }

    private void
    create_surface ()
    {
        unowned Xcb.Connection? connection = m_Window.xcb_desktop.connection;

        // Create pixmap
        Xcb.Pixmap pixmap = Xcb.Pixmap (connection);
        connection.create_pixmap (24, pixmap, (Xcb.Drawable)m_Window.id,
                                  (uint16)m_Window.geometry.clipbox.size.width,
                                  (uint16)m_Window.geometry.clipbox.size.height);
        if (id != 0)
            ((Xcb.Pixmap)id).destroy (m_Window.xcb_desktop.connection);
        id = pixmap;

        Log.audit (GLib.Log.METHOD, "pixmap %lu", pixmap);

        unowned XcbWorkspace? xcb_workspace = (XcbWorkspace)((Window)m_Window.delegator).workspace.proxy;

        m_Surface = new Xcb.CairoSurface (connection, pixmap,
                                          xcb_workspace.xcb_visual,
                                          (int)m_Window.geometry.clipbox.size.width,
                                          (int)m_Window.geometry.clipbox.size.height);

        // Cleanup pixmap
        var ctx = new Cairo.Context (m_Surface);
        ctx.set_operator (Cairo.Operator.CLEAR);
        ctx.paint ();

        m_Window.xcb_desktop.flush ();
    }

    private void
    on_window_property_changed (Object? inObject, string inName)
    {
        switch (inName)
        {
            case "geometry":
                create_surface ();
                break;
        }
    }
}

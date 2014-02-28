/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * pixmap.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.Pixmap : Maia.Core.Object, Maia.Graphic.Device
{
    // properties
    private Graphic.Surface m_Surface = null;

    // accessors
    public string backend {
        get {
            return "xcb/drawable";
        }
    }

    public global::Xcb.Connection connection {
        get {
            return Maia.Xcb.application.connection;
        }
    }

    public int screen_num { get; set; default = 0; }

    public Graphic.Size size { get; construct; default = Graphic.Size (0, 0); }

    public Graphic.Surface? surface {
        get {
            if (m_Surface == null)
            {
                m_Surface = new Graphic.Surface.from_device (this, (int)size.width, (int)size.height);
            }
            return m_Surface;
        }
    }

    // methods
    public Pixmap (Window inWindow, int inDepth, int inWidth, int inHeight)
    {
        GLib.Object (id: global::Xcb.Pixmap (inWindow.connection), screen_num: inWindow.screen_num, size: Graphic.Size (inWidth, inHeight));

        ((global::Xcb.Pixmap)id).create_checked (connection, (uint8)inDepth, (global::Xcb.Drawable)inWindow.id, (uint16)inWidth, (uint16)inHeight);
        
    }

    ~Pixmap ()
    {
        ((global::Xcb.Pixmap)id).free (Maia.Xcb.application.connection);
    }
}

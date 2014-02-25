/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
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

internal class Maia.Xcb.Window : Maia.Window, Maia.Graphic.Device
{
    // properties
    private Graphic.Surface m_Surface = null;

    // accessors
    public string backend {
        get {
            return "xcb/window";
        }
    }

    public global::Xcb.Connection connection {
        get {
            return Maia.Xcb.dispatcher.connection;
        }
    }

    public int screen_num { get; set; default = 0; }

    public global::Xcb.Visualtype? visual_type {
        get {
            unowned global::Xcb.Screen screen = Maia.Xcb.dispatcher.connection.roots[screen_num];

            for (int i = 0; i < screen.allowed_depths_length; ++i)
            {
                for (int j = 0; j < screen.allowed_depths[i].visuals_length; ++j)
                {
                    if (screen.allowed_depths[i].visuals[j].visual_id == screen.root_visual)
                    {
                        return screen.allowed_depths[i].visuals[j];
                    }
                }
            }

            return null;
        }
    }

    public override Graphic.Surface? surface {
        get {
            return m_Surface;
        }
    }

    // methods
    construct
    {
        screen_num = Maia.Xcb.dispatcher.default_screen;
        id = global::Xcb.Window (Maia.Xcb.dispatcher.connection);

        Maia.Xcb.dispatcher.add (this);
    }

    public Window (string inName, int inWidth, int inHeight)
    {
        base (inName, inWidth, inHeight);
    }

    ~Window ()
    {
        ((global::Xcb.Window)id).destroy (Maia.Xcb.dispatcher.connection);
    }

    internal override void
    on_move ()
    {
        if (m_Surface != null)
        {
            uint32[] values = { (uint32)position.x, (uint32)position.y };

            ((global::Xcb.Window)id).configure (Maia.Xcb.dispatcher.connection,
                                                global::Xcb.ConfigWindow.X |
                                                global::Xcb.ConfigWindow.Y,
                                                values);
        }
    }

    internal override void
    on_resize ()
    {
        if (m_Surface != null)
        {
            uint32[] values = { (uint32)size.width, (uint32)size.height };

            ((global::Xcb.Window)id).configure (Maia.Xcb.dispatcher.connection,
                                                global::Xcb.ConfigWindow.WIDTH |
                                                global::Xcb.ConfigWindow.HEIGHT,
                                                values);
        }
    }

    internal override void
    on_show ()
    {
        if (m_Surface == null)
        {
            unowned global::Xcb.Screen screen = Maia.Xcb.dispatcher.connection.roots[screen_num];

            ((global::Xcb.Window)id).create (Maia.Xcb.dispatcher.connection,
                                             global::Xcb.COPY_FROM_PARENT, screen.root,
                                             (int16)position.x, (int16)position.y,
                                             (uint16)size.width, (uint16)size.height, 0,
                                             global::Xcb.WindowClass.INPUT_OUTPUT,
                                             screen.root_visual);
            m_Surface = new Graphic.Surface.from_device (this);
        }

        ((global::Xcb.Window)id).map (Maia.Xcb.dispatcher.connection);

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        if (m_Surface != null)
        {
            ((global::Xcb.Window)id).unmap (Maia.Xcb.dispatcher.connection);
        }

        base.on_hide ();
    }
}

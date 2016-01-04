/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * renderer.vala
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

internal class Maia.Xcb.Renderer : Maia.Graphic.Renderer
{
    // properties
    private Pixmap                   m_Pixmap = null;
    private Graphic.Size             m_Size = Graphic.Size (0, 0);
    private Graphic.Surface?         m_Surface = null;

    // accessors
    public override Graphic.Surface? surface {
        get {
            return m_Surface;
        }
    }

    [CCode (notify = false)]
    public override Graphic.Size size {
        get {
            return m_Size;
        }
        construct set {
            if (!m_Size.equal (value))
            {
                m_Size = value;

                create_surface ();
            }
        }
    }

    // methods
    public Renderer (Graphic.Size inSize)
    {
        base (inSize);
    }

    private void
    create_surface ()
    {
        m_Surface = null;
        m_Pixmap = null;

        if (m_Size.width != 0 && m_Size.height != 0)
        {
            int screen_num = Maia.Xcb.application.default_screen;

            m_Pixmap = new Pixmap (screen_num, (uint8)32, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));

            m_Surface = new Graphic.Surface.from_device (m_Pixmap, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));
        }
    }
}

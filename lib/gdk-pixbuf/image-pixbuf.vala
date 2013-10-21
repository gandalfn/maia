/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * image-pixbuf.vala
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

public class Maia.GdkPixbuf.ImagePixbuf : Graphic.Image, Image
{
    // properties
    private Graphic.Size       m_Size      = Graphic.Size (0, 0);
    private Graphic.Surface    m_Surface   = null;
    private Graphic.Transform  m_Transform = new Graphic.Transform.identity ();
    private global::Gdk.Pixbuf m_Pixbuf    = null;

    // accessors
    public override Graphic.Size size {
        get {
            if (m_Size.is_empty ())
            {
                return surface != null ? surface.size : Graphic.Size (0, 0);
            }
            return m_Size;
        }
        set {
            // Reset transform
            m_Transform.init ();

            // Set size
            m_Size = value;

            // Destroy surface
            if (m_Surface != null)
            {
                destroy_surface (m_Surface);
                m_Surface = null;
            }
        }
    }

    public override Graphic.Transform transform {
        get {
            return m_Transform;
        }
        set {
            // Remove old user transform
            unowned Graphic.Transform? user_transform = m_Transform.first () as Graphic.Transform;
            if (user_transform != null)
            {
                user_transform.parent = null;
            }
            // add new one
            m_Transform.add (value);

            // Destroy surface
            if (m_Surface != null)
            {
                destroy_surface (m_Surface);
                m_Surface = null;
            }
        }
    }

    public override Graphic.Surface? surface {
        get {
            if (m_Surface == null && m_Pixbuf != null)
            {
                // Size is set
                if (!m_Size.is_empty ())
                {
                    // Calculate the transform
                    double scale = double.max ((double)m_Pixbuf.width / m_Size.width, (double)m_Pixbuf.height / m_Size.height);
                    m_Transform.translate (((m_Pixbuf.width / scale) - m_Size.width) / 2, ((m_Pixbuf.height / scale) - m_Size.height) / 2);
                    m_Transform.scale (scale, scale);
                }

                // Create new surface
                m_Surface = create_surface (m_Pixbuf);
            }

            return m_Surface;
        }
    }

    public Gdk.Pixbuf pixbuf {
        get {
            return m_Pixbuf;
        }
        set {
            if (m_Surface != null)
            {
                destroy_surface (m_Surface);
                m_Surface = null;
            }

            m_Pixbuf = value;
        }
    }

    // methods
    public ImagePixbuf (Gdk.Pixbuf inPixbuf, Graphic.Size inSize)
    {
        GLib.Object (pixbuf: inPixbuf, size: inSize);
    }

    ~ImagePixbuf ()
    {
        if (m_Surface != null)
        {
            destroy_surface (m_Surface);
            m_Surface = null;
        }
    }
}

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
    private Graphic.Surface    m_Surface   = null;
    private global::Gdk.Pixbuf m_Pixbuf    = null;

    // accessors
    [CCode (notify = false)]
    public override Graphic.Size size {
        get {
            if (base.size.is_empty ())
            {
                return surface != null ? surface.size : Graphic.Size (0, 0);
            }
            return base.size;
        }
        set {
            // Reset transform
            transform.init ();

            // Set size
            base.size = value;

            // Destroy surface
            m_Surface = null;
        }
    }

    [CCode (notify = false)]
    public override Graphic.Transform transform {
        get {
            return base.transform;
        }
        set {
            base.transform = value;

            // Destroy surface
            m_Surface = null;
        }
    }

    public override Graphic.Surface? surface {
        get {
            if (m_Surface == null && m_Pixbuf != null)
            {
                var size = base.size;

                // Size is set
                if (!size.is_empty ())
                {
                    // Calculate the transform
                    double scale = double.max ((double)m_Pixbuf.width / size.width, (double)m_Pixbuf.height / size.height);
                    transform.translate (((m_Pixbuf.width / scale) - size.width) / 2, ((m_Pixbuf.height / scale) - size.height) / 2);
                    transform.scale (scale, scale);
                }

                // Create new surface
                m_Surface = create_surface (m_Pixbuf);
            }

            return m_Surface;
        }
    }

    [CCode (notify = false)]
    public Gdk.Pixbuf pixbuf {
        get {
            return m_Pixbuf;
        }
        set {
            m_Surface = null;

            m_Pixbuf = value;
        }
    }

    // methods
    public ImagePixbuf (Gdk.Pixbuf inPixbuf, Graphic.Size inSize)
    {
        GLib.Object (pixbuf: inPixbuf, size: inSize);
    }
}

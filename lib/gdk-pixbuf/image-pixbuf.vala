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
    private Graphic.Size m_Size = Graphic.Size (0, 0);
    private Graphic.Surface m_Surface = null;
    private global::Gdk.Pixbuf m_Pixbuf = null;

    // accessors
    public override string? filename {
        get {
            return "";
        }
        construct set {
        }
    }

    public override Graphic.Size size {
        get {
            return m_Size;
        }
        construct set {
            if (m_Surface != null && !m_Size.is_empty () && !value.is_empty ())
            {
                // reset surface
                m_Surface = null;
            }

            m_Size = value;
        }
    }

    internal override Graphic.Surface? surface {
        get {
            if (m_Surface == null && m_Pixbuf != null)
            {
                // Get the current size
                Graphic.Size current_size = size;
                m_Size = Graphic.Size (0, 0);

                // Create new surface
                m_Surface = create_surface (m_Pixbuf);

                // Restore size if not empty
                if (!current_size.is_empty ())
                {
                    m_Surface = resize (m_Surface, current_size);
                    m_Size = current_size;
                }
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
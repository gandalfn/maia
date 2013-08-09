/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * image-png.vala
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

internal class Maia.Cairo.ImagePng : Graphic.ImagePng
{
    // properties
    private Graphic.Size    m_Size = Graphic.Size (0, 0);
    private Graphic.Surface m_Surface = null;

    // accessors
    public override string filename { get; construct set; }

    public override Graphic.Size size {
        get {
            if (m_Size.is_empty ())
            {
                load_surface ();
            }
            return m_Size;
        }
        construct set {
            if (m_Surface != null && !m_Size.is_empty () && !value.is_empty ())
            {
                // reset size
                m_Size = Graphic.Size (0, 0);

                if (filename != null)
                {
                    // reset surface
                    m_Surface = null;
                }
            }

            m_Size = value;
        }
    }

    public override Graphic.Surface? surface {
        get {
            load_surface ();

            return m_Surface;
        }
    }

    // methods
    public ImagePng (string inFilename, Graphic.Size inSize = Graphic.Size (0, 0))
    {
        GLib.Object (filename: inFilename, size: inSize);
    }

    private void
    load_surface ()
    {
        if (m_Surface == null && filename != null)
        {
            var image_surface = new global::Cairo.ImageSurface.from_png (filename);

            Graphic.Size current_size = m_Size;
            m_Size = Graphic.Size (0, 0);

            size = Graphic.Size ((double)image_surface.get_width (), (double)image_surface.get_height ());

            m_Surface = new Surface  (image_surface, image_surface.get_width (), image_surface.get_height ());

            if (!current_size.is_empty ())
            {
                m_Surface = resize (m_Surface, current_size);
                m_Size = current_size;
            }
        }
    }

    private Graphic.Surface
    resize (Graphic.Surface inSurface, Graphic.Size inSize)
    {
        Graphic.Surface ret = null;

        if (inSurface != null && !size.equal (inSize))
        {
            try
            {
                var buffer = new Graphic.Surface ((uint)inSize.width, (uint)inSize.height);
                buffer.context.operator = Graphic.Operator.SOURCE;
                var transform = new Graphic.Transform.identity ();
                transform.scale (inSize.width / size.width, inSize.height / size.height);
                buffer.context.transform = transform;
                buffer.context.pattern = inSurface;
                buffer.context.paint ();

                ret = buffer;
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "Error on resize %s: %s", filename, err.message);
            }
        }

        return ret;
    }
}

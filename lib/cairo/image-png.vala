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
    private Graphic.Surface   m_Surface   = null;

    // accessors
    [CCode (notify = false)]
    public override string? filename {
        get {
            return base.filename;
        }
        set {
            // Set filename
            base.filename = value;

            // Initialize surface
            m_Surface = null;
        }
    }

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

            // Initialize surface
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

            // Initialize surface
            m_Surface = null;
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
            // Load png image
            var image_surface = new global::Cairo.ImageSurface.from_png (filename);
            var size = base.size;

            // Size is set
            if (!size.is_empty ())
            {
                // Calculate the transform
                double scale = double.max ((double)image_surface.get_width () / size.width, (double)image_surface.get_height () / size.height);
                transform.translate (((image_surface.get_width () / scale) - size.width) / 2, ((image_surface.get_height () / scale) - size.height) / 2);
                transform.scale (scale, scale);
            }

            m_Surface = new Graphic.Surface.from_native  (image_surface, image_surface.get_width (), image_surface.get_height ());
        }
    }
}

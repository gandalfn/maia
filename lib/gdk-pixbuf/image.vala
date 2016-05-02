/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * image.vala
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

public interface Maia.GdkPixbuf.Image : Graphic.Image
{
    // methods
    public Graphic.Surface
    create_surface (Gdk.Pixbuf inPixbuf)
    {
        // Get pixbuf data
        int n_channels = inPixbuf.n_channels;
        int width = inPixbuf.width;
        int height = inPixbuf.height;
        int pixbuf_rowstride = inPixbuf.rowstride;
        Graphic.Surface.Format format = n_channels == 3 ? Graphic.Surface.Format.RGB24 : Graphic.Surface.Format.ARGB32;
        int rowstride = format.stride_for_width (width);
        uchar* data = GLib.malloc (height * rowstride);
        uchar* pixbuf_pixels = inPixbuf.pixels;
        uchar* pixels = data;

        // Convert pixbuf data to cairo data
        for (int j = height; j > 0; j--)
        {
            uchar *p = pixbuf_pixels;
            uchar *q = pixels;

            if (n_channels == 3)
            {
                uchar *end = p + 3 * width;

                while (p < end)
                {
                    q[0] = p[2];
                    q[1] = p[1];
                    q[2] = p[0];
                    p += 3;
                    q += 4;
                }
            }
            else
            {
                uchar *end = p + 4 * width;
                uint t1, t2, t3;

                while (p < end)
                {
                    t1 = p[2] * p[3] + 0x7f;
                    t2 = p[1] * p[3] + 0x7f;
                    t3 = p[0] * p[3] + 0x7f;

                    q[0] = (uchar)(((t1 >> 8) + t1) >> 8);
                    q[1] = (uchar)(((t2 >> 8) + t2) >> 8);
                    q[2] = (uchar)(((t3 >> 8) + t3) >> 8);
                    q[3] = p[3];

                    p += 4;
                    q += 4;
                }
            }

            pixbuf_pixels += pixbuf_rowstride;
            pixels += rowstride;
        }

        // Create new surface
        var ret = new Graphic.Surface.from_data (format, data, width, height);
        ret.set_data_full ("MaiaGdkPixbufImageData", data, GLib.free);
        return ret;
    }
}

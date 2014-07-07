/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawable.vala
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

internal class Maia.Xcb.Drawable : Maia.Core.Object, Maia.Graphic.Device
{
    // properties
    private uint8               m_Depth;
    private Graphic.Surface     m_Surface = null;

    // accessors
    public virtual string backend {
        get {
            return "xcb/drawable";
        }
    }

    public global::Xcb.Connection connection {
        get {
            return Maia.Xcb.application.connection;
        }
    }

    public uint32 xid { get; private set; }

    public int screen_num { get; set; default = 0; }

    public uint8 depth {
        get {
            return m_Depth;
        }
    }

    public uint32 visual {
        get {
            return Maia.Xcb.application.find_visual_from_depth (screen_num, m_Depth);
        }
    }

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
    public Drawable (uint32 inXid, int inScreenNum, int inDepth, int inWidth, int inHeight)
    {
        GLib.Object (screen_num: inScreenNum, size: Graphic.Size (inWidth, inHeight));

        xid = inXid;
        m_Depth = (uint8)inDepth;
    }


    public void
    clear ()
    {
        var picture = global::Xcb.Render.Picture (connection);
        var format = Maia.Xcb.application.find_format_from_depth (screen_num, m_Depth);

        picture.create (connection, xid, format);
        global::Xcb.Render.Color color = { 0, 0, 0, 0 };
        global::Xcb.Rectangle rectangles[1];

        rectangles[0].x = 0;
        rectangles[0].y = 0;
        rectangles[0].width = (uint16)size.width;
        rectangles[0].height = (uint16)size.height;

        picture.fill_rectangles (connection, global::Xcb.Render.PictOp.SRC, color, rectangles);

        picture.free (connection);
    }

    public void
    copy (Drawable inDrawable)
        requires (inDrawable.size.equal (size))
    {
        var src = global::Xcb.Render.Picture (connection);
        var format_src = Maia.Xcb.application.find_format_from_depth (screen_num, m_Depth);
        src.create (connection, xid, format_src);

        var dst = global::Xcb.Render.Picture (connection);
        var format_dst = Maia.Xcb.application.find_format_from_depth (inDrawable.screen_num, inDrawable.m_Depth);
        dst.create (connection, inDrawable.xid, format_dst);

        src.composite (connection, global::Xcb.Render.PictOp.SRC, global::Xcb.NONE, dst,
                       0, 0, 0, 0, 0, 0, (uint16)size.width, (uint16)size.height);

        src.free (connection);
        dst.free (connection);
    }
}

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

internal abstract class Maia.Xcb.Drawable : GLib.Object, Core.Serializable, Graphic.Device
{
    // properties
    private Graphic.Surface m_Surface = null;

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

    public unowned Screen? screen {
        get {
            return Maia.Xcb.application[screen_num];
        }
    }

    [CCode (notify = false)]
    public uint32 xid { get; construct set; default = 0; }

    [CCode (notify = false)]
    public int screen_num { get; set; default = Maia.Xcb.application.default_screen; }

    [CCode (notify = false)]
    public virtual uint8 depth { get; set; default = 24; }

    public uint32 visual {
        get {
            return screen.find_visual_from_depth (depth);
        }
    }

    [CCode (notify = false)]
    public virtual Graphic.Size size { get; set; default = Graphic.Size (0, 0); }

    public virtual Graphic.Surface? surface {
        get {
            if (m_Surface == null)
            {
                m_Surface = new Graphic.Surface.from_device (this, (int)size.width, (int)size.height);
            }
            return m_Surface;
        }
    }

    [CCode (notify = false)]
    public GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(iuyii)", screen_num, xid, depth, (int)size.width, (int)size.height);
        }
        set {
            int screen_num;
            uint32 xid;
            uint8 depth;
            int width, height;

            value.get ("(iuydd)", out screen_num, out xid, out depth, out width, out height);

            this.xid = xid;
            this.screen_num = screen_num;
            this.depth = depth;
            this.size = Graphic.Size ((double)width, (double)height);
        }
    }

    // methods
    public void
    clear ()
    {
        var picture = global::Xcb.Render.Picture (connection);
        var format = screen.find_format_from_depth (depth);

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
        copy_area (inDrawable, Graphic.Rectangle (0, 0, size.width, size.height));
    }

    public void
    copy_area (Drawable inDrawable, Graphic.Rectangle inArea, Graphic.Point inOffset = Graphic.Point (0, 0))
    {
        var src = global::Xcb.Render.Picture (connection);
        var format_src = screen.find_format_from_depth (depth);
        src.create (connection, xid, format_src);

        var dst = global::Xcb.Render.Picture (connection);
        var format_dst = inDrawable.screen.find_format_from_depth (inDrawable.depth);
        dst.create (connection, inDrawable.xid, format_dst);

        src.composite (connection, global::Xcb.Render.PictOp.SRC, global::Xcb.NONE, dst,
                       (int16)GLib.Math.floor (inArea.origin.x), (int16)GLib.Math.floor (inArea.origin.y),
                       0, 0,
                       (int16)GLib.Math.floor (inOffset.x), (int16)GLib.Math.floor (inOffset.y),
                       (uint16)(GLib.Math.ceil (inArea.origin.x + inArea.size.width) - GLib.Math.floor (inArea.origin.x)),
                       (uint16)(GLib.Math.ceil (inArea.origin.y + inArea.size.height) - GLib.Math.floor (inArea.origin.y)));

        src.free (connection);
        dst.free (connection);
    }
}

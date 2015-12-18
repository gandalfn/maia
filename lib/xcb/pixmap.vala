/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * pixmap.vala
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

internal class Maia.Xcb.Pixmap : Maia.Xcb.Drawable
{
    // accessors
    public override string backend {
        get {
            return "xcb/pixmap";
        }
    }

    // methods
    public Pixmap (int inScreenNum, uint8 inDepth, int inWidth, int inHeight)
    {
        var pixmap = global::Xcb.Pixmap (Maia.Xcb.application.connection);

        GLib.Object (xid: pixmap, screen_num: inScreenNum, depth: inDepth, size: Graphic.Size (inWidth, inHeight));

        unowned global::Xcb.Screen screen = connection.roots[inScreenNum];

        var cookie = pixmap.create_checked (connection, (uint8)depth, (global::Xcb.Drawable)screen.root, (uint16)inWidth, (uint16)inHeight);

        global::Xcb.GenericError? err = connection.request_check (cookie);
        if (err != null)
        {
            Log.error (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"Error on create pixmap on screen $(inScreenNum) depth: $(inDepth) size: $(inWidth)x$(inHeight) : $(err.error_code)");
        }

        clear ();
    }

    public Pixmap.from_drawable (Drawable inDrawable, int inWidth, int inHeight)
    {
        var pixmap = global::Xcb.Pixmap (Maia.Xcb.application.connection);

        GLib.Object (xid: pixmap, screen_num: inDrawable.screen_num, depth: inDrawable.depth, size: Graphic.Size (inWidth, inHeight));

        var cookie = pixmap.create_checked (connection, (uint8)inDrawable.depth, (global::Xcb.Drawable)inDrawable.xid, (uint16)inWidth, (uint16)inHeight);

        if (connection.request_check (cookie) != null)
        {
            Log.error (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"Error on create pixmap for $(inDrawable.xid)");
        }

        clear ();
    }

    public Pixmap.clone (Pixmap inPixmap)
    {
        var pixmap = global::Xcb.Pixmap (Maia.Xcb.application.connection);

        GLib.Object (xid: pixmap, screen_num: inPixmap.screen_num, depth: inPixmap.depth, size: inPixmap.size);

        var cookie = pixmap.create_checked (connection, (uint8)depth, (global::Xcb.Drawable)inPixmap.xid, (uint16)size.width, (uint16)size.height);

        if (connection.request_check (cookie) != null)
        {
            Log.error (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"Error on clone pixmap $(inPixmap.xid)");
        }

        inPixmap.copy (this);
    }

    ~Pixmap ()
    {
        ((global::Xcb.Pixmap)xid).free (Maia.Xcb.application.connection);
    }
}

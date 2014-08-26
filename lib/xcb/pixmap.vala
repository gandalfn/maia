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
    public Pixmap (int inScreenNum, int inDepth, int inWidth, int inHeight)
    {
        var pixmap = global::Xcb.Pixmap (Maia.Xcb.application.connection);

        base (pixmap, inScreenNum, inDepth, inWidth, inHeight);

        unowned global::Xcb.Screen screen = connection.roots[inScreenNum];

        var cookie = pixmap.create_checked (connection, (uint8)inDepth, (global::Xcb.Drawable)screen.root, (uint16)inWidth, (uint16)inHeight);

        global::Xcb.GenericError? err = connection.request_check (cookie);
        if (err != null)
        {
            Log.error (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"Error on create pixmap on screen $(inScreenNum) depth: $(inDepth) size: $(inWidth)x$(inHeight) : $(err.error_code)");
        }

        clear ();
    }

    public Pixmap.clone (Pixmap inPixmap)
    {
        var pixmap = global::Xcb.Pixmap (Maia.Xcb.application.connection);

        base (pixmap, inPixmap.screen_num, inPixmap.depth, (int)inPixmap.size.width, (int)inPixmap.size.height);

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

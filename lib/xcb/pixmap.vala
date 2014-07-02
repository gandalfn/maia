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
    public Pixmap (Window inWindow, int inDepth, int inWidth, int inHeight)
    {
        var pixmap = global::Xcb.Pixmap (Maia.Xcb.application.connection);

        base (pixmap, inWindow.screen_num, inDepth, inWidth, inHeight);
        
        var cookie = pixmap.create_checked (connection, (uint8)inDepth, (global::Xcb.Drawable)inWindow.xid, (uint16)inWidth, (uint16)inHeight);

        if (connection.request_check (cookie) != null)
        {
            Log.error (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"Error on create pixmap for $(inWindow.name)");
        }

        clear ();
    }

    ~Pixmap ()
    {
        ((global::Xcb.Pixmap)xid).free (Maia.Xcb.application.connection);
    }
}

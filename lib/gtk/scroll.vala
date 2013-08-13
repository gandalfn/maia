/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * scroll.vala
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

namespace Maia.Gtk
{
    internal static Scroll
    convert_gdk_scrolldirection_to_scroll (global::Gdk.ScrollDirection inScroll)
    {
        switch (inScroll)
        {
            case global::Gdk.ScrollDirection.UP:
                return Scroll.UP;
            case global::Gdk.ScrollDirection.DOWN:
                return Scroll.DOWN;
            case global::Gdk.ScrollDirection.LEFT:
                return Scroll.LEFT;
            case global::Gdk.ScrollDirection.RIGHT:
                return Scroll.RIGHT;
        }

        return Scroll.NONE;
    }
}

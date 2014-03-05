/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cursor.vala
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
    const global::Gdk.CursorType[] c_Cursors = {
        global::Gdk.CursorType.BLANK_CURSOR,
        global::Gdk.CursorType.X_CURSOR,
        global::Gdk.CursorType.ARROW,
        global::Gdk.CursorType.BASED_ARROW_DOWN,
        global::Gdk.CursorType.BASED_ARROW_UP,
        global::Gdk.CursorType.BOAT,
        global::Gdk.CursorType.BOGOSITY,
        global::Gdk.CursorType.BOTTOM_LEFT_CORNER,
        global::Gdk.CursorType.BOTTOM_RIGHT_CORNER,
        global::Gdk.CursorType.BOTTOM_SIDE,
        global::Gdk.CursorType.BOTTOM_TEE,
        global::Gdk.CursorType.BOX_SPIRAL,
        global::Gdk.CursorType.CENTER_PTR,
        global::Gdk.CursorType.CIRCLE,
        global::Gdk.CursorType.CLOCK,
        global::Gdk.CursorType.COFFEE_MUG,
        global::Gdk.CursorType.CROSS,
        global::Gdk.CursorType.CROSS_REVERSE,
        global::Gdk.CursorType.CROSSHAIR,
        global::Gdk.CursorType.DIAMOND_CROSS,
        global::Gdk.CursorType.DOT,
        global::Gdk.CursorType.DOTBOX,
        global::Gdk.CursorType.DOUBLE_ARROW,
        global::Gdk.CursorType.DRAFT_LARGE,
        global::Gdk.CursorType.DRAFT_SMALL,
        global::Gdk.CursorType.DRAPED_BOX,
        global::Gdk.CursorType.EXCHANGE,
        global::Gdk.CursorType.FLEUR,
        global::Gdk.CursorType.GOBBLER,
        global::Gdk.CursorType.GUMBY,
        global::Gdk.CursorType.HAND1,
        global::Gdk.CursorType.HAND2,
        global::Gdk.CursorType.HEART,
        global::Gdk.CursorType.ICON,
        global::Gdk.CursorType.IRON_CROSS,
        global::Gdk.CursorType.LEFT_PTR,
        global::Gdk.CursorType.LEFT_SIDE,
        global::Gdk.CursorType.LEFT_TEE,
        global::Gdk.CursorType.LEFTBUTTON,
        global::Gdk.CursorType.LL_ANGLE,
        global::Gdk.CursorType.LR_ANGLE,
        global::Gdk.CursorType.MAN,
        global::Gdk.CursorType.MIDDLEBUTTON,
        global::Gdk.CursorType.MOUSE,
        global::Gdk.CursorType.PENCIL,
        global::Gdk.CursorType.PIRATE,
        global::Gdk.CursorType.PLUS,
        global::Gdk.CursorType.QUESTION_ARROW,
        global::Gdk.CursorType.RIGHT_PTR,
        global::Gdk.CursorType.RIGHT_SIDE,
        global::Gdk.CursorType.RIGHT_TEE,
        global::Gdk.CursorType.RIGHTBUTTON,
        global::Gdk.CursorType.RTL_LOGO,
        global::Gdk.CursorType.SAILBOAT,
        global::Gdk.CursorType.SB_DOWN_ARROW,
        global::Gdk.CursorType.SB_H_DOUBLE_ARROW,
        global::Gdk.CursorType.SB_LEFT_ARROW,
        global::Gdk.CursorType.SB_RIGHT_ARROW,
        global::Gdk.CursorType.SB_UP_ARROW,
        global::Gdk.CursorType.SB_V_DOUBLE_ARROW,
        global::Gdk.CursorType.SHUTTLE,
        global::Gdk.CursorType.SIZING,
        global::Gdk.CursorType.SPIDER,
        global::Gdk.CursorType.SPRAYCAN,
        global::Gdk.CursorType.STAR,
        global::Gdk.CursorType.TARGET,
        global::Gdk.CursorType.TCROSS,
        global::Gdk.CursorType.TOP_LEFT_ARROW,
        global::Gdk.CursorType.TOP_LEFT_CORNER,
        global::Gdk.CursorType.TOP_RIGHT_CORNER,
        global::Gdk.CursorType.TOP_SIDE,
        global::Gdk.CursorType.TOP_TEE,
        global::Gdk.CursorType.TREK,
        global::Gdk.CursorType.UL_ANGLE,
        global::Gdk.CursorType.UMBRELLA,
        global::Gdk.CursorType.UR_ANGLE,
        global::Gdk.CursorType.WATCH,
        global::Gdk.CursorType.XTERM
    };

    internal static global::Gdk.CursorType
    convert_cursor_to_gdk_cursor (Cursor inCursor)
    {
        return c_Cursors[inCursor];
    }
}

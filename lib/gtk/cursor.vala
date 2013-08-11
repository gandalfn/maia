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
    internal static global::Gdk.CursorType
    convert_cursor_to_gdk_cursor (Cursor inCursor)
    {
        switch (inCursor)
        {
            case Cursor.BLANK_CURSOR:
                return global::Gdk.CursorType.BLANK_CURSOR;
            case Cursor.X_CURSOR:
                return global::Gdk.CursorType.X_CURSOR;
            case Cursor.ARROW:
                return global::Gdk.CursorType.ARROW;
            case Cursor.BASED_ARROW_DOWN:
                return global::Gdk.CursorType.BASED_ARROW_DOWN;
            case Cursor.BASED_ARROW_UP:
                return global::Gdk.CursorType.BASED_ARROW_UP;
            case Cursor.BOAT:
                return global::Gdk.CursorType.BOAT;
            case Cursor.BOGOSITY:
                return global::Gdk.CursorType.BOGOSITY;
            case Cursor.BOTTOM_LEFT_CORNER:
                return global::Gdk.CursorType.BOTTOM_LEFT_CORNER;
            case Cursor.BOTTOM_RIGHT_CORNER:
                return global::Gdk.CursorType.BOTTOM_RIGHT_CORNER;
            case Cursor.BOTTOM_SIDE:
                return global::Gdk.CursorType.BOTTOM_SIDE;
            case Cursor.BOTTOM_TEE:
                return global::Gdk.CursorType.BOTTOM_TEE;
            case Cursor.BOX_SPIRAL:
                return global::Gdk.CursorType.BOX_SPIRAL;
            case Cursor.CENTER_PTR:
                return global::Gdk.CursorType.CENTER_PTR;
            case Cursor.CIRCLE:
                return global::Gdk.CursorType.CIRCLE;
            case Cursor.CLOCK:
                return global::Gdk.CursorType.CLOCK;
            case Cursor.COFFEE_MUG:
                return global::Gdk.CursorType.COFFEE_MUG;
            case Cursor.CROSS:
                return global::Gdk.CursorType.CROSS;
            case Cursor.CROSS_REVERSE:
                return global::Gdk.CursorType.CROSS_REVERSE;
            case Cursor.CROSSHAIR:
                return global::Gdk.CursorType.CROSSHAIR;
            case Cursor.DIAMOND_CROSS:
                return global::Gdk.CursorType.DIAMOND_CROSS;
            case Cursor.DOT:
                return global::Gdk.CursorType.DOT;
            case Cursor.DOTBOX:
                return global::Gdk.CursorType.DOTBOX;
            case Cursor.DOUBLE_ARROW:
                return global::Gdk.CursorType.DOUBLE_ARROW;
            case Cursor.DRAFT_LARGE:
                return global::Gdk.CursorType.DRAFT_LARGE;
            case Cursor.DRAFT_SMALL:
                return global::Gdk.CursorType.DRAFT_SMALL;
            case Cursor.DRAPED_BOX:
                return global::Gdk.CursorType.DRAPED_BOX;
            case Cursor.EXCHANGE:
                return global::Gdk.CursorType.EXCHANGE;
            case Cursor.FLEUR:
                return global::Gdk.CursorType.FLEUR;
            case Cursor.GOBBLER:
                return global::Gdk.CursorType.GOBBLER;
            case Cursor.GUMBY:
                return global::Gdk.CursorType.GUMBY;
            case Cursor.HAND1:
                return global::Gdk.CursorType.HAND1;
            case Cursor.HAND2:
                return global::Gdk.CursorType.HAND2;
            case Cursor.HEART:
                return global::Gdk.CursorType.HEART;
            case Cursor.ICON:
                return global::Gdk.CursorType.ICON;
            case Cursor.IRON_CROSS:
                return global::Gdk.CursorType.IRON_CROSS;
            case Cursor.LEFT_PTR:
                return global::Gdk.CursorType.LEFT_PTR;
            case Cursor.LEFT_SIDE:
                return global::Gdk.CursorType.LEFT_SIDE;
            case Cursor.LEFT_TEE:
                return global::Gdk.CursorType.LEFT_TEE;
            case Cursor.LEFTBUTTON:
                return global::Gdk.CursorType.LEFTBUTTON;
            case Cursor.LL_ANGLE:
                return global::Gdk.CursorType.LL_ANGLE;
            case Cursor.LR_ANGLE:
                return global::Gdk.CursorType.LR_ANGLE;
            case Cursor.MAN:
                return global::Gdk.CursorType.MAN;
            case Cursor.MIDDLEBUTTON:
                return global::Gdk.CursorType.MIDDLEBUTTON;
            case Cursor.MOUSE:
                return global::Gdk.CursorType.MOUSE;
            case Cursor.PENCIL:
                return global::Gdk.CursorType.PENCIL;
            case Cursor.PIRATE:
                return global::Gdk.CursorType.PIRATE;
            case Cursor.PLUS:
                return global::Gdk.CursorType.PLUS;
            case Cursor.QUESTION_ARROW:
                return global::Gdk.CursorType.QUESTION_ARROW;
            case Cursor.RIGHT_PTR:
                return global::Gdk.CursorType.RIGHT_PTR;
            case Cursor.RIGHT_SIDE:
                return global::Gdk.CursorType.RIGHT_SIDE;
            case Cursor.RIGHT_TEE:
                return global::Gdk.CursorType.RIGHT_TEE;
            case Cursor.RIGHTBUTTON:
                return global::Gdk.CursorType.RIGHTBUTTON;
            case Cursor.RTL_LOGO:
                return global::Gdk.CursorType.RTL_LOGO;
            case Cursor.SAILBOAT:
                return global::Gdk.CursorType.SAILBOAT;
            case Cursor.SB_DOWN_ARROW:
                return global::Gdk.CursorType.SB_DOWN_ARROW;
            case Cursor.SB_H_DOUBLE_ARROW:
                return global::Gdk.CursorType.SB_H_DOUBLE_ARROW;
            case Cursor.SB_LEFT_ARROW:
                return global::Gdk.CursorType.SB_LEFT_ARROW;
            case Cursor.SB_RIGHT_ARROW:
                return global::Gdk.CursorType.SB_RIGHT_ARROW;
            case Cursor.SB_UP_ARROW:
                return global::Gdk.CursorType.SB_UP_ARROW;
            case Cursor.SB_V_DOUBLE_ARROW:
                return global::Gdk.CursorType.SB_V_DOUBLE_ARROW;
            case Cursor.SHUTTLE:
                return global::Gdk.CursorType.SHUTTLE;
            case Cursor.SIZING:
                return global::Gdk.CursorType.SIZING;
            case Cursor.SPIDER:
                return global::Gdk.CursorType.SPIDER;
            case Cursor.SPRAYCAN:
                return global::Gdk.CursorType.SPRAYCAN;
            case Cursor.STAR:
                return global::Gdk.CursorType.STAR;
            case Cursor.TARGET:
                return global::Gdk.CursorType.TARGET;
            case Cursor.TCROSS:
                return global::Gdk.CursorType.TCROSS;
            case Cursor.TOP_LEFT_ARROW:
                return global::Gdk.CursorType.TOP_LEFT_ARROW;
            case Cursor.TOP_LEFT_CORNER:
                return global::Gdk.CursorType.TOP_LEFT_CORNER;
            case Cursor.TOP_RIGHT_CORNER:
                return global::Gdk.CursorType.TOP_RIGHT_CORNER;
            case Cursor.TOP_SIDE:
                return global::Gdk.CursorType.TOP_SIDE;
            case Cursor.TOP_TEE:
                return global::Gdk.CursorType.TOP_TEE;
            case Cursor.TREK:
                return global::Gdk.CursorType.TREK;
            case Cursor.UL_ANGLE:
                return global::Gdk.CursorType.UL_ANGLE;
            case Cursor.UMBRELLA:
                return global::Gdk.CursorType.UMBRELLA;
            case Cursor.UR_ANGLE:
                return global::Gdk.CursorType.UR_ANGLE;
            case Cursor.WATCH:
                return global::Gdk.CursorType.WATCH;
            case Cursor.XTERM:
                return global::Gdk.CursorType.XTERM;
        }

        return global::Gdk.CursorType.BLANK_CURSOR;
    }
}

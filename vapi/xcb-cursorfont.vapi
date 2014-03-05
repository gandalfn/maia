/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-cursorfont.vapi
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

[CCode (cheader_filename = "X11/cursorfont.h")]
namespace Xcb
{
    [CCode (cname = "int", cprefix = "XC_", cheader_filename = "X11/cursorfont.h", has_type_id=false)]
    public enum CursorFont
    {
        X_cursor,
        arrow,
        based_arrow_down,
        based_arrow_up,
        boat,
        bogosity,
        bottom_left_corner,
        bottom_right_corner,
        bottom_side,
        bottom_tee,
        box_spiral,
        center_ptr,
        circle,
        clock,
        coffee_mug,
        cross,
        cross_reverse,
        crosshair,
        diamond_cross,
        dot,
        dotbox,
        double_arrow,
        draft_large,
        draft_small,
        draped_box,
        exchange,
        fleur,
        gobbler,
        gumby,
        hand1,
        hand2,
        heart,
        icon,
        iron_cross,
        left_ptr,
        left_side,
        left_tee,
        leftbutton,
        ll_angle,
        lr_angle,
        man,
        middlebutton,
        mouse,
        pencil,
        pirate,
        plus,
        question_arrow,
        right_ptr,
        right_side,
        right_tee,
        rightbutton,
        rtl_logo,
        sailboat,
        sb_down_arrow,
        sb_h_double_arrow,
        sb_left_arrow,
        sb_right_arrow,
        sb_up_arrow,
        sb_v_double_arrow,
        shuttle,
        sizing,
        spider,
        spraycan,
        star,
        target,
        tcross,
        top_left_arrow,
        top_left_corner,
        top_right_corner,
        top_side,
        top_tee,
        trek,
        ul_angle,
        umbrella,
        ur_angle,
        watch,
        xterm
    }
}

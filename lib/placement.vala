/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * placement.vala
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

public enum Maia.Placement
{
    TOP,
    BOTTOM,
    LEFT,
    RIGHT;

    public string
    to_string ()
    {
        switch (this)
        {
            case TOP:
                return "top";
            case BOTTOM:
                return "bottom";
            case LEFT:
                return "left";
            case RIGHT:
                return "right";
        }

        return "";
    }

    public static Placement
    from_string (string inValue)
    {
        switch (inValue.down ())
        {
            case "top":
                return TOP;
            case "bottom":
                return BOTTOM;
            case "left":
                return LEFT;
            case "right":
                return RIGHT;
        }

        return TOP;
    }
}

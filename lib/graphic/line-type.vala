/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * line-type.vala
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

public enum Maia.Graphic.LineType
{
    CONTINUE,
    DOT,
    DASH,
    DASH_DOT;

    public double[]?
    to_dash (double inLineWidth)
    {
        switch (this)
        {
            case DOT:
                return { inLineWidth, 2.0 * inLineWidth };

            case DASH:
                return { 4.0 * inLineWidth, 6.0 * inLineWidth };

            case DASH_DOT:
                return { 4.0 * inLineWidth, 6.0 * inLineWidth, inLineWidth, 6.0 * inLineWidth };
        }

        return null;
    }

    public string
    to_string ()
    {
        switch (this)
        {
            case DOT:
                return "dot";

            case DASH:
                return "dash";

            case DASH_DOT:
                return "dash-dot";
        }

        return "continue";
    }

    public static LineType
    from_string (string inValue)
    {
        switch (inValue.down ())
        {
            case "dot":
                return DOT;

            case "dash":
                return DASH;

            case "dash-dot":
                return DASH_DOT;
        }

        return CONTINUE;
    }
}

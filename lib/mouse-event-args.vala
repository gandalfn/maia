/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * mouse-event-args.vala
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

public class Maia.MouseEventArgs : Maia.Core.EventArgs
{
    // type
    [Flags]
    public enum EventFlags
    {
        BUTTON_PRESS    = 1 << 0,
        BUTTON_RELEASE  = 1 << 1,
        MOTION          = 1 << 2
    }

    // accessors
    public uint8 flags {
        get {
            return (uint8)(uchar)this["flags"].get ();
        }
    }

    public uint8 button {
        get {
            return (uint8)(uchar)this["button"].get ();
        }
    }

    public Graphic.Point position {
        get {
            return Graphic.Point ((double)this["x"].get (), (double)this["y"].get ());
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (MouseEventArgs),
                                          "Mouse",
                                          "message Mouse {"             +
                                          "     required byte flags;"   +
                                          "     required byte button;"  +
                                          "     required double x;"     +
                                          "     required double y;"     +
                                          "}");
    }

    // methods
    public MouseEventArgs (uint8 inEventFlags, uint8 inButton, double inX, double inY)
    {
        base ();

        this["flags"].set ((uchar)inEventFlags);
        this["button"].set ((uchar)inButton);
        this["x"].set (inX);
        this["y"].set (inY);
    }
}

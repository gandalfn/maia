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
    // constants
    public const string PROTOBUF = "message Mouse {"   +
                                   "     byte flags;"  +
                                   "     byte button;" +
                                   "     double x;"    +
                                   "     double y;"    +
                                   "}";

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
            return (uint8)this["flags"];
        }
    }

    public uint8 button {
        get {
            return (uint8)this["button"];
        }
    }

    public Graphic.Point position {
        get {
            return Graphic.Point ((double)this["x"], (double)this["y"]);
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (MouseEventArgs).name (),
                                          "Mouse", PROTOBUF);
    }

    // methods
    public MouseEventArgs (uint8 inEventFlags, uint8 inButton, double inX, double inY)
    {
        base ();

        this["flags", 0] = inEventFlags;
        this["button", 0] = inButton;
        this["x", 0] = inX;
        this["y", 0] = inY;
    }
}

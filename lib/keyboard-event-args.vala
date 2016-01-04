/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * keyboard-event-args.vala
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

public class Maia.KeyboardEventArgs : Maia.Core.EventArgs
{
    // constants
    public const string PROTOBUF = "message Key {"          +
                                   "     byte state;"       +
                                   "     byte modifier;"    +
                                   "     uint32 key;"       +
                                   "     uint32 character;" +
                                   "}";

    // type
    public enum State
    {
        INVALID,
        PRESS,
        RELEASE
    }

    // accessors
    public State state {
        get {
            return (State)(uchar)this["state"];
        }
    }

    public Modifier modifier {
        get {
            return (Modifier)(uchar)this["modifier"];
        }
    }

    public Key key {
        get {
            return (Key)(uint32)this["key"];
        }
    }

    public unichar character {
        get {
            return (unichar)(uint32)this["character"];
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (KeyboardEventArgs).name (),
                                          "Key", PROTOBUF);
    }

    // methods
    public KeyboardEventArgs (State inState, Modifier inModifier, Key inKey, unichar inChar)
    {
        base ();

        this["state", 0]     = (uchar)inState;
        this["modifier", 0]  = (uchar)inModifier;
        this["key", 0]       = (uint32)inKey;
        this["character", 0] = (uint32)inChar;
    }
}

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
            return (State)(uchar)this["state"].get ();
        }
    }

    public Modifier modifier {
        get {
            return (Modifier)(uchar)this["modifier"].get ();
        }
    }

    public Key key {
        get {
            return (Key)(uint32)this["key"].get ();
        }
    }

    public unichar character {
        get {
            return (unichar)(uint32)this["character"].get ();
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (KeyboardEventArgs),
                                          "Key",
                                          "message Key {"          +
                                          "     byte state;"       +
                                          "     byte modifier;"    +
                                          "     uint32 key;"       +
                                          "     uint32 character;" +
                                          "}");
    }

    // methods
    public KeyboardEventArgs (State inState, Modifier inModifier, Key inKey, unichar inChar)
    {
        base ();

        this["state"].set ((uchar)inState);
        this["modifier"].set ((uchar)inModifier);
        this["key"].set ((uint32)inKey);
        this["character"].set ((uint32)inChar);
    }
}

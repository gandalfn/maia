/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * delete-event-args.vala
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

public class Maia.Xcb.DeleteEventArgs : Maia.DeleteEventArgs
{
    // accessors
    public global::Xcb.Window window {
        get {
            return (global::Xcb.Window)(uint32)this["window"].get ();
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (DeleteEventArgs),
                                          "DeleteXcb",
                                          Maia.DeleteEventArgs.ProtoBuf +
                                          "message DeleteXcb {" +
                                          "     required Delete delete;" +
                                          "     required uint32 window;" +
                                          "}");
    }

    // methods
    public DeleteEventArgs (global::Xcb.Window inWindow)
    {
        base ();
        this["window"].set ((uint32)inWindow);
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        if (window == ((DeleteEventArgs)inArgs).window)
        {
            base.accumulate (inArgs);
        }
    }
}

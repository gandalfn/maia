/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * damage-event-args.vala
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

public class Maia.DamageEventArgs : Maia.Core.EventArgs
{
    // constants
    public const string PROTOBUF = "message Area {"      +
                                   "     double x;"      +
                                   "     double y;"      +
                                   "     double width;"  +
                                   "     double height;" +
                                   "}";

    // accessors
    public Graphic.Rectangle area {
        get {
            return Graphic.Rectangle ((double)this["x"],
                                      (double)this["y"],
                                      (double)this["width"],
                                      (double)this["height"]);
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (DamageEventArgs).name (),
                                          "Area", PROTOBUF);
    }

    // methods
    public DamageEventArgs (double inX, double inY, double inWidth, double inHeight)
    {
        base ();

        this["x", 0] = inX;
        this["y", 0] = inY;
        this["width", 0] = inWidth;
        this["height", 0] = inHeight;
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        Graphic.Rectangle a = area;
        Graphic.Rectangle b = ((DamageEventArgs)inArgs).area;
        a.union_ (b);

        this["x", 0] = a.origin.x;
        this["y", 0] = a.origin.y;
        this["width", 0] = a.size.width;
        this["height", 0] = a.size.height;
    }
}

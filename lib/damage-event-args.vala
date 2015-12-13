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
    // accessors
    public Graphic.Rectangle area {
        get {
            return Graphic.Rectangle ((double)this["x"].get (),
                                      (double)this["y"].get (),
                                      (double)this["width"].get (),
                                      (double)this["height"].get ());
        }
    }

    // static methods
    static construct
    {
        Core.EventArgs.register_protocol (typeof (DamageEventArgs),
                                          "Area",
                                          "message Area {"      +
                                          "     double x;"      +
                                          "     double y;"      +
                                          "     double width;"  +
                                          "     double height;" +
                                          "}");
    }

    // methods
    public DamageEventArgs (double inX, double inY, double inWidth, double inHeight)
    {
        base ();

        this["x"].set (inX);
        this["y"].set (inY);
        this["width"].set (inWidth);
        this["height"].set (inHeight);
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        Graphic.Rectangle a = area;
        Graphic.Rectangle b = ((DamageEventArgs)inArgs).area;
        a.union_ (b);

        this["x"].set ((double)inArgs["x"].get ());
        this["y"].set ((double)inArgs["y"].get ());
        this["width"].set ((double)inArgs["width"].get ());
        this["height"].set ((double)inArgs["height"].get ());
    }
}

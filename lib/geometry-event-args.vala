/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * geometry-event-args.vala
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

public class Maia.GeometryEventArgs : Maia.Core.EventArgs
{
    // properties
    private Graphic.Rectangle m_Area;
    
    // accessors
    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(dddd)", m_Area.origin.x, m_Area.origin.y, m_Area.size.width, m_Area.size.height);
        }
        set {
            if (value != null)
            {
                double x, y, width, height;
                value.get ("(dddd)", out x, out y, out width, out height);
                m_Area = Graphic.Rectangle (x, y, width, height);
            }
            else
            {
                m_Area = Graphic.Rectangle (0, 0, 0, 0);
            }
        }
    }

    public Graphic.Rectangle area {
        get {
            return m_Area;
        }
    }

    // methods
    public GeometryEventArgs (double inX, double inY, double inWidth, double inHeight)
    {
        base ();

        m_Area = Graphic.Rectangle (inX, inY, inWidth, inHeight);
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        m_Area = ((GeometryEventArgs)inArgs).m_Area.copy ();
    }
}

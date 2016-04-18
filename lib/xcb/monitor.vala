/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * monitor.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.Monitor : Core.Object
{
    // properties
    private Graphic.Rectangle m_Geometry;

    // accessors
    public Graphic.Rectangle geometry {
        get {
            return m_Geometry;
        }
    }

    // methods
    public Monitor (global::Xcb.RandR.GetCrtcInfoReply inInfo)
    {
        m_Geometry = Graphic.Rectangle (inInfo.x, inInfo.y, inInfo.width, inInfo.height);
    }

    internal override int
    compare (Core.Object inObject)
        requires (inObject is Monitor)
    {
        unowned Monitor? other = inObject as Monitor;

        int xdiff = (int)m_Geometry.origin.x - (int)other.m_Geometry.origin.x;
        int ydiff = (int)m_Geometry.origin.y - (int)other.m_Geometry.origin.y;

        if (xdiff == 0)
            return ydiff;

        return xdiff;
    }
}

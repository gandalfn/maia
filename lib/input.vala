/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * input.vala
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

public class Maia.Input : Object
{
    // properties
    private Graphic.Region m_Geometry;

    // events
    public GeometryEvent geometry_event { get; set; default = null; }

    // accessors
    /**
     * The geometry of input
     */
    [CCode (notify = false)]
    public virtual Graphic.Region geometry {
        get {
            return m_Geometry;
        }
        construct set {
            m_Geometry = value;

            if (value != null)
            {
                notify_property ("width");
                notify_property ("height");
            }
        }
    }

    /**
     * Width of input
     */
    public double width {
        get {
            return geometry == null ? 0.0 : geometry.extents.size.width;
        }
    }

    /**
     * Height of input
     */
    public double height {
        get {
            return geometry == null ? 0.0 : geometry.extents.size.height;
        }
    }
}

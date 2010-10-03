/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-point.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.Point : GLib.Object, Value
{
    private double m_X = 0.0;
    public double x {
        get {
            return m_X;
        }
        set {
            m_X = value;
        }
    }

    private double m_Y = 0.0;
    public double y {
        get {
            return m_Y;
        }
        set {
            m_Y = value;
        }
    }

    static construct
    {
        GLib.Value.register_transform_func (typeof (string), typeof (Point),
                                            (ValueTransform)string_to_point);
        GLib.Value.register_transform_func (typeof (Point), typeof (string),
                                            (ValueTransform)point_to_string);
    }

    static void 
    point_to_string (GLib.Value inSrc, out GLib.Value outDest) 
        requires (inSrc.holds (typeof (Point)))
        requires ((Point)inSrc != null)
    {
        Point point = (Point)inSrc;

        outDest = point.to_string ();
    }

    static void 
    string_to_point (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
        requires ((string)inSrc != null)
    {
        string val = (string)inSrc;

        outDest = new Point (val);
    }

    /**
     * Create a new point from string attribute
     *
     * @param inValue point string attribute
     */
    public Point (string inValue)
    {
        string[] val = inValue.split(",");
        if (val.length >= 2)
        {
            m_X =  val[0].to_double (); 
            m_Y = val[1].to_double ();
        }
    }

    /**
     * Create a new point from inX, inY coordinates
     *
     * @param inX x point coordinate
     * @param inY y point coordinate
     */
    public Point.xy(double inX, double inY)
    {
        m_X = inX;
        m_Y = inY;
    }

    /**
     * Transform the point by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Maia.Transform inTransform)
    {
        double new_x, new_y;
        Maia.Matrix matrix = inTransform.matrix;

        new_x = (matrix.m_XX * m_X + matrix.m_XY * m_Y) + matrix.m_X0;
        new_y = (matrix.m_YX * m_X + matrix.m_YY * m_Y) + matrix.m_Y0;

        m_X = new_x;
        m_Y = new_y;
    }

    /**
     * Returns the string representation of point
     *
     * @return string representation of point
     */
    public string
    to_string ()
    {
        return m_X.to_string () + "," + m_Y.to_string ();
    }
}

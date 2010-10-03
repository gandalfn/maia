/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-rectangle.vala
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

public class Maia.Rectangle : GLib.Object, Value
{
    private Point m_Origin = new Point.xy(0.0, 0.0);
    public Maia.Point origin {
        get {
            return m_Origin;
        }
    }

    private double m_Width = 0.0;
    public double width {
        get {
            return m_Width;
        }
        set {
            m_Width = value;
        }
    }

    private double m_Height = 0.0;
    public double height {
        get {
            return m_Height;
        }
        set {
            m_Height = value;
        }
    }

    public bool is_empty {
        get {
            return m_Width == 0 || m_Height == 0;
        }
    }

    static construct
    {
        GLib.Value.register_transform_func (typeof (string), typeof (Rectangle),
                                            (ValueTransform)string_to_rectangle);
        GLib.Value.register_transform_func (typeof (Rectangle), typeof (string),
                                            (ValueTransform)rectangle_to_string);
    }

    static void 
    rectangle_to_string (GLib.Value inSrc, out GLib.Value outDest) 
        requires (inSrc.holds (typeof (Rectangle)))
        requires ((Rectangle)inSrc != null)
    {
        Rectangle rectangle = (Rectangle)inSrc;

        outDest = rectangle.to_string ();
    }

    static void 
    string_to_rectangle (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
        requires ((string)inSrc != null)
    {
        string val = (string)inSrc;

        outDest = new Rectangle (val);
    }

    /**
     * Create a new rectangle from string attribute
     *
     * @param inValue rectangle string attribute
     */
    public Rectangle (string inValue)
    {
        string[] val = inValue.split(",");
        if (val.length >= 4)
        {
            m_Origin = new Point.xy (val[0].to_double (), val[1].to_double ());
            m_Width = val[2].to_double ();
            m_Height = val[3].to_double ();
        }
    }

    /**
     * Create a new rectangle from raw values
     *
     * @param inX x coordinate of rectangle
     * @param inY y coordinate of rectangle
     * @param inWidth width of rectangle
     * @param inHeight height of rectangle
     */
    public Rectangle.raw (double inX, double inY, double inWidth, double inHeight)
    {
        m_Origin = new Point.xy (inX, inY);
        m_Width = inWidth;
        m_Height= inHeight;
    }

    /**
     * Create a new rectangle from a pixman box
     *
     * @param inBox a pixman box
     */
    internal Rectangle.pixman_box (Pixman.Box32 inBox)
    {
        double x = ((Pixman.Fixed)inBox.x1).to_double();
        double y = ((Pixman.Fixed)inBox.y1).to_double();
        m_Origin = new Point.xy (x, y);
        m_Width = ((Pixman.Fixed)inBox.x2 - inBox.x1).to_double();
        m_Height = ((Pixman.Fixed)inBox.y2 - inBox.y1).to_double();
    }

    /**
     * Transform the rectangle by inTransform.
     *
     * @param inTransform transform matrix
     */
    public void
    transform (Maia.Transform inTransform)
    {
        double new_width, new_height;
        Maia.Matrix matrix = inTransform.matrix;

        new_width = (matrix.m_XX * m_Width + matrix.m_XY * m_Height);
        new_height = (matrix.m_YX * m_Width + matrix.m_YY * m_Height);

        m_Width = new_width;
        m_Height = new_height;

        m_Origin.transform (inTransform);
    }

    /**
     * Return string representation of rectangle
     *
     * @return string representation of rectangle
     */
    public string
    to_string ()
    {
        return "%s,%f,%f".printf (m_Origin.to_string (), m_Width, m_Height);
    }

    /**
     * Returrn the pixman box representation of rectangle
     *
     * @return Pixman Box
     */
    internal Pixman.Box32 
    to_pixman_box ()
    {
        Pixman.Box32 box = Pixman.Box32();

        box.x1 = ((Pixman.double)m_Origin.x).to_fixed();
        box.y1 = ((Pixman.double)m_Origin.y).to_fixed();
        box.x2 = ((Pixman.double)m_Origin.x + m_Width).to_fixed();
        box.y2 = ((Pixman.double)m_Origin.y + m_Height).to_fixed();

        return box;
    }
}

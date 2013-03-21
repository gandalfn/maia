/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * path.vala
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

public class Maia.Graphic.Path : Object
{
    public enum DataType
    {
        PATH,
        MOVETO,
        LINETO,
        CURVETO,
        ARC,
        ARC_NEGATIVE,
        RECTANGLE
    }

    // properties
    private Point[] m_Points;
    private int     m_NbChilds;

    // accessors
    public Type data_type { get; private set; }

    public Point[] points {
        get {
            return m_Points;
        }
    }

    // static methods
    private static inline double
    calc_angle (double inUx, double inUy, double inVx, double inVy)
    {
        double top, u_magnitude, v_magnitude, angle_cos, angle;

        top = inUx * inVx + inUy * inVy;
        u_magnitude = GLib.Math.sqrt (inUx * inUx + inUy * inUy);
        v_magnitude = GLib.Math.sqrt (inVx * inVx + inVy * inVy);
        angle_cos = top / (u_magnitude * v_magnitude);

        if (angle_cos >= 1.0)
            angle = 0.0;
        if (angle_cos <= -1.0)
            angle = GLib.Math.PI;
        else
            angle = GLib.Math.acos (angle_cos);

        if (inUx * inVy - inUy * inVx < 0)
            angle = -angle;

        return angle;
    }

    // methods
    construct
    {
        m_Points = {};
        m_NbChilds = 0;
    }

    public Path ()
    {
        data_type = DataType.PATH;
    }

    public Path.from_region (Region inRegion)
    {
        data_type = DataType.PATH;
        foreach (Rectangle rect in inRegion)
        {
            rectangle (rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
    }

    private Point
    get_origin ()
    {
        unowned Path? path = (Path?)first ();
        if (path != null)
        {
            return m_Points[m_Points.length - 1];
        }

        return Point(0, 0);
    }

    private Point
    get_current_point ()
    {
        unowned Path? path = (Path?)last ();
        if (path != null)
        {
            return m_Points[m_Points.length - 1];
        }

        return Point(0, 0);
    }

    private Point
    get_last_control ()
    {
        unowned Path? path = (Path?)last ();
        if (path != null)
        {
            Point current = m_Points[m_Points.length - 1];
            if (path.data_type == DataType.CURVETO)
            {
                Point control = m_Points[1];
                control.x = current.x + (current.x - m_Points[1].x);
                control.y = current.y + (current.y - m_Points[1].y);
                return control;
            }

            return current;
        }

        return Point(0, 0);
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return data_type == DataType.PATH && inChild is Path;
    }

    public Path
    copy ()
    {
        Path path = new Path ();
        path.data_type = data_type;
        path.m_Points = m_Points;

        foreach (unowned Object child in this)
        {
            add ((child as Path).copy ());
        }

        return path;
    }

    public void
    move_to (double inX, double inY)
    {
        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.data_type = DataType.MOVETO;
        path.m_Points += Point (inX, inY);
        add (path);
    }

    public void
    rel_move_to (double inX, double inY)
    {
        Point current = get_current_point ();
        move_to (current.x + inX, current.y + inY);
    }

    public void
    line_to (double inX, double inY)
    {
        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.data_type = DataType.LINETO;
        path.m_Points += Point (inX, inY);
        add (path);
    }

    public void
    rel_line_to (double inX, double inY)
    {
        Point current = get_current_point ();
        line_to (current.x + inX, current.y + inY);
    }

    public void
    curve_to (double inX, double inY, double inX1, double inY1, double inX2, double inY2)
    {
        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.data_type = DataType.CURVETO;
        path.m_Points += Point (inX1, inY1);
        path.m_Points += Point (inX2, inY2);
        path.m_Points += Point (inX, inY);
        add (path);
    }

    public void
    rel_curve_to (double inX, double inY, double inX1, double inY1, double inX2, double inY2)
    {
        Point current = get_current_point ();
        curve_to (current.x + inX,  current.y + inY, current.x + inX1, current.y + inY1, current.x + inX2, current.y + inY2);
    }

    public void
    smooth_curve_to (double inX, double inY, double inX2, double inY2)
    {
        Point control = get_last_control ();

        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.data_type = DataType.CURVETO;
        path.m_Points += Point (control.x, control.y);
        path.m_Points += Point (inX2, inY2);
        path.m_Points += Point (inX, inY);
        add (path);
    }

    public void
    rel_smooth_curve_to (double inX, double inY, double inX2, double inY2)
    {
        Point current = get_current_point ();
        smooth_curve_to (current.x + inX, current.y + inY, current.x + inX2, current.y + inY2);
    }

    public void
    quadratic_curve_to (double inX, double inY, double inX1, double inY1)
    {
        Point current = get_current_point ();

        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.data_type = DataType.CURVETO;
        path.m_Points += Point (current.x + (2.0 / 3.0) * (inX1 - current.x),
                                current.y + (2.0 / 3.0) * (inY1 - current.y));
        path.m_Points += Point (inX + (2.0 / 3.0) * (inX1 - inX),
                                inY + (2.0 / 3.0) * (inY1 - inY));
        path.m_Points += Point (inX, inY);
        add (path);
    }

    public void
    rel_quadratic_curve_to (double inX, double inY, double inX1, double inY1)
    {
        Point current = get_current_point ();
        quadratic_curve_to (current.x + inX, current.y + inY, current.x + inX1, current.y + inY1);
    }

    public void
    smooth_quadratic_curve_to (double inX, double inY)
    {
        Point control = get_last_control ();
        quadratic_curve_to (inX, inY, control.x, control.y);
    }

    public void
    rel_smooth_quadratic_curve_to (double inX, double inY)
    {
        Point current = get_current_point ();
        smooth_quadratic_curve_to (current.x + inX, current.y + inY);
    }

    public void
    arc_to (double inRx, double inRy, double inXAxisRotation,
            bool inLargeArcFlag, bool inSweepFlag, double inX, double inY)
    {
        double x2, y2, lambda;
        double v1, v2, angle, angle_sin, angle_cos, x11, y11;
        double rx_squared, ry_squared, x11_squared, y11_squared, top, bottom;
        double c, cx1, cy1, cx, cy, start_angle, angle_delta;
        Point current = get_current_point ();

        x2 = inX;
        y2 = inY;

        if (current.x == x2 && current.y == y2)
        {
            return;
        }

        if (inRx == 0.0 || inRy == 0.0)
        {
            line_to (x2, y2);
            return;
        }

        v1 = (current.x - x2) / 2.0;
        v2 = (current.y - y2) / 2.0;

        angle = inXAxisRotation * (GLib.Math.PI / 180.0);
        angle_sin = GLib.Math.sin (angle);
        angle_cos = GLib.Math.cos (angle);

        x11 = (angle_cos * v1) + (angle_sin * v2);
        y11 = - (angle_sin * v1) + (angle_cos * v2);

        inRx = inRx > 0.0 ? inRx : - inRx;
        inRy = inRy > 0.0 ? inRy : - inRy;
        lambda = (x11 * x11) / (inRx * inRx) + (y11 * y11) / (inRy * inRy);
        if (lambda > 1.0)
        {
            double square_root = GLib.Math.sqrt (lambda);
            inRx *= square_root;
            inRy *= square_root;
        }

        rx_squared = inRx * inRx;
        ry_squared = inRy * inRy;
        x11_squared = x11 * x11;
        y11_squared = y11 * y11;

        top = (rx_squared * ry_squared) - (rx_squared * y11_squared) - (ry_squared * x11_squared);
        if (top < 0.0)
        {
            c = 0.0;
        }
        else
        {
            bottom = (rx_squared * y11_squared) + (ry_squared * x11_squared);
            c = GLib.Math.sqrt (top / bottom);
        }

        if (inLargeArcFlag == inSweepFlag)
            c = - c;

        cx1 = c * ((inRx * y11) / inRy);
        cy1 = c * (- (inRy * x11) / inRx);

        cx = (angle_cos * cx1) - (angle_sin * cy1) + (current.x + x2) / 2;
        cy = (angle_sin * cx1) + (angle_cos * cy1) + (current.y + y2) / 2;

        v1 = (x11 - cx1) / inRx;
        v2 = (y11 - cy1) / inRy;

        start_angle = calc_angle (1, 0, v1, v2);
        angle_delta = calc_angle (v1, v2, (-x11 - cx1) / inRx, (-y11 - cy1) / inRy);

        if (!inSweepFlag && angle_delta > 0.0)
            angle_delta -= 2 * GLib.Math.PI;
        else if (inSweepFlag && angle_delta < 0.0)
            angle_delta += 2 * GLib.Math.PI;

        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.m_Points += Point (cx, cy);
        path.m_Points += Point (inRx, inRy);
        if (angle_delta > 0.0)
        {
            path.data_type = DataType.ARC;
            path.m_Points += Point (start_angle + angle, start_angle + angle + angle_delta);
        }
        else
        {
            path.data_type = DataType.ARC_NEGATIVE;
            path.m_Points += Point (start_angle - angle, start_angle - angle + angle_delta);
        }
        add (path);
    }

    public void rel_arc_to (double inRx, double inRy, double inXAxisRotation,
                            bool inLargeArcFlag, bool inSweepFlag, double inX, double inY)
    {
        Point current = get_current_point ();
        arc_to (inRx, inRy, inXAxisRotation, inLargeArcFlag, inSweepFlag, current.x + inX, current.y + inY);
    }

    public void
    rectangle (double inX, double inY, double inWidth, double inHeight, double inRx = 0.0, double inRy = 0.0)
    {
        if (inRx > inWidth / 2.0) inRx = inWidth / 2.0;
        if (inRy > inHeight / 2.0) inRy = inHeight / 2.0;
        if (inRx > 0 && inRy == 0) inRy = inRx;
        if (inRy > 0 && inRx == 0) inRx = inRy;

        if (inRx > 0 && inRy > 0)
        {
            move_to (inX + inRx, inY);
            line_to (inX + inWidth - inRx, inY);
            arc_to  (inRx, inRy, 0, false, true, inX + inWidth, inY + inRy);
            line_to (inX + inWidth, inY + inHeight - inRy);
            arc_to  (inRx, inRy, 0, false, true, inX + inWidth - inRx, inY + inHeight);
            line_to (inX + inRx, inY + inHeight);
            arc_to  (inRx, inRy, 0, false, true, inX, inY + inHeight - inRy);
            line_to (inX, inY + inRy);
            arc_to  (inRx, inRy, 0, false, true, inX + inRx, inY);
        }
        else
        {
            Path path = new Path ();
            path.id = ++m_NbChilds;
            path.data_type = DataType.RECTANGLE;
            path.m_Points += Point (inX, inY);
            path.m_Points += Point (inX + inWidth, inY + inHeight);
            add (path);
        }
    }

    public void
    arc (double inXc, double inYc, double inRx, double inRy,double inAngle1, double inAngle2)
    {
        Path path = new Path ();
        path.id = ++m_NbChilds;
        path.data_type = DataType.ARC;
        path.m_Points += Point (inXc, inYc);
        path.m_Points += Point (inRx, inRy);
        path.m_Points += Point (inAngle1, inAngle2);
        add (path);
    }

    public void
    close ()
    {
        Point origin = get_origin ();
        line_to (origin.x, origin.y);
    }
}
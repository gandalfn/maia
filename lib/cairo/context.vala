/* -*- Mode: Vala indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cairo-graphic-context.vala
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

internal class Maia.Graphic.Cairo.Context : Graphic.Context
{
    private enum PathType
    {
        UNKNOWN,
        CLOSEPATH,
        MOVETO,
        LINETO,
        CURVETO,
        CURVETO_QUADRATIC,
        ARC
    }

    // properties
    private global::Cairo.Context m_Context = null;
    private Device                m_Device = null;
    private PathType              m_LastPath = PathType.UNKNOWN;
    private double m_OriginX      = 0.0;
    private double m_OriginY      = 0.0;
    private double m_LastControlX = 0.0;
    private double m_LastControlY = 0.0;

    // accessors
    internal global::Cairo.Context context {
        get {
            if (m_Context == null && device != null)
            {
                m_Context = new global::Cairo.Context (m_Device.surface);
            }

            return m_Context;
        }
    }

    public override Graphic.Device device {
        get {
            return m_Device;
        }
    }

    public override Graphic.Pattern pattern {
        set {
            if (value is Graphic.Device)
            {
                global::Cairo.Pattern pattern = new global::Cairo.Pattern.for_surface (((Cairo.Device)value).surface);
                context.set_source (pattern);
            }
            else if (value is Graphic.Color)
            {
                context.set_source_rgba (((Graphic.Color)value).red,
                                         ((Graphic.Color)value).green,
                                         ((Graphic.Color)value).blue,
                                         ((Graphic.Color)value).alpha);
            }
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
    internal Context (Device inDevice)
    {
        m_Device = inDevice;
    }

    public override void
    save () throws Graphic.Error
    {
        context.save ();
        status ();
    }

    public override void
    restore () throws Graphic.Error
    {
        context.restore ();
        status ();
    }

    public override void
    status () throws Graphic.Error
    {
        global::Cairo.Status status = context.status ();

        switch (status)
        {
            case global::Cairo.Status.SUCCESS:
                break;
            case global::Cairo.Status.NO_MEMORY:
                throw new Graphic.Error.NO_MEMORY ("out of memory");
            case global::Cairo.Status.INVALID_RESTORE:
                throw new Graphic.Error.END_ELEMENT ("call end element without matching begin element");
            case global::Cairo.Status.NO_CURRENT_POINT:
                throw new Graphic.Error.NO_CURRENT_POINT ("no current point defined");
            case global::Cairo.Status.INVALID_MATRIX:
                throw new Graphic.Error.INVALID_MATRIX ("invalid matrix (not invertible)");
            case global::Cairo.Status.NULL_POINTER:
                throw new Graphic.Error.NULL_POINTER ("null pointer");
            case global::Cairo.Status.INVALID_STRING:
                throw new Graphic.Error.INVALID_STRING ("input string not valid UTF-8");
            case global::Cairo.Status.INVALID_PATH_DATA:
                throw new Graphic.Error.INVALID_PATH ("input path not valid");
            case global::Cairo.Status.SURFACE_FINISHED:
                throw new Graphic.Error.SURFACE_FINISHED ("the target surface has been finished");
            case global::Cairo.Status.SURFACE_TYPE_MISMATCH:
                throw new Graphic.Error.SURFACE_TYPE_MISMATCH ("the surface type is not appropriate for the operation");
            case global::Cairo.Status.PATTERN_TYPE_MISMATCH:
                throw new Graphic.Error.PATTERN_TYPE_MISMATCH ("the pattern type is not appropriate for the operation");
            default:
                throw new Graphic.Error.UNKNOWN ("a unknown error occured");
        }
    }

    public override void
    new_path () throws Graphic.Error
    {
        context.new_path ();
        context.move_to(0.0, 0.0);
        status ();

        m_LastPath = PathType.UNKNOWN;
        m_OriginX = 0.0;
        m_OriginY = 0.0;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    move_to (double inX, double inY) throws Graphic.Error
    {
        context.move_to (inX, inY);
        status ();

        m_LastPath = PathType.MOVETO;
        m_OriginX = inX;
        m_OriginY = inY;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_move_to (double inX, double inY) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();

        context.rel_move_to (inX, inY);
        status ();

        m_LastPath = PathType.MOVETO;
        m_OriginX = inX + x0;
        m_OriginY = inY + y0;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    line_to (double inX, double inY) throws Graphic.Error
    {
        context.line_to (inX, inY);
        status ();

        m_LastPath = PathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_line_to (double inX, double inY) throws Graphic.Error
    {
        context.rel_line_to (inX, inY);
        status ();

        m_LastPath = PathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    horizontal_line_to (double inX) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();

        context.line_to (inX, y0);
        status ();

        m_LastPath = PathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_horizontal_line_to (double inX) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();

        context.line_to (inX + x0, y0);
        status ();

        m_LastPath = PathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    vertical_line_to (double inY) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();

        context.line_to (x0, inY);
        status ();

        m_LastPath = PathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_vertical_line_to (double inY) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();

        context.line_to (x0, y0 + inY);
        status ();

        m_LastPath = PathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    curve_to (double inX, double inY, double inX1, double inY1,
              double inX2, double inY2) throws Graphic.Error
    {
        context.curve_to (inX1, inY1, inX2, inY2, inX, inY);
        status ();

        m_LastPath = PathType.CURVETO;
        m_LastControlX = inX2;
        m_LastControlY = inY2;
    }

    public override void
    rel_curve_to (double inX, double inY, double inX1, double inY1,
                  double inX2, double inY2) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();

        context.rel_curve_to (inX1, inY1, inX2, inY2, inX, inY);
        status ();

        m_LastPath = PathType.CURVETO;
        m_LastControlX = x0 + inX2;
        m_LastControlY = y0 + inY2;
    }

    public override void
    smooth_curve_to (double inX, double inY,
                     double inX2, double inY2) throws Graphic.Error
    {
        double x0, y0, x1, y1;

        context.get_current_point (out x0, out y0);
        status ();

        x1 = x0;
        y1 = y0;
        if (m_LastPath == PathType.CURVETO)
        {
            x1 = x0 + (x0 - m_LastControlX);
            y1 = y0 + (y0 - m_LastControlY);
        }
        curve_to (inX, inY, x1, y1, inX2, inY2);
    }

    public override void
    rel_smooth_curve_to (double inX, double inY,
                         double inX2, double inY2) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();
        smooth_curve_to (x0 + inX, y0 + inY, x0 + inX2, y0 + inY2);
    }

    public override void
    quadratic_curve_to (double inX, double inY,
                        double inX1, double inY1) throws Graphic.Error
    {
        double x0, y0, xx1, yy1, xx2, yy2;

        context.get_current_point (out x0, out y0);
        status ();

        xx1 = x0 + (2.0 / 3.0) * (inX1 - x0);
        yy1 = y0 + (2.0 / 3.0) * (inY1 - y0);

        xx2 = inX + (2.0 / 3.0) * (inX1 - inX);
        yy2 = inY + (2.0 / 3.0) * (inY1 - inY);

        context.curve_to (xx1, yy1, xx2, yy2, inX, inY);
        status ();

        m_LastPath = PathType.CURVETO_QUADRATIC;
        m_LastControlX = inX1;
        m_LastControlY = inY1;
    }

    public override void
    rel_quadratic_curve_to (double inX, double inY,
                            double inX1, double inY1) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();
        quadratic_curve_to (x0 + inX, y0 + inY, x0 + inX1, y0 + inY1);
    }

    public override void
    smooth_quadratic_curve_to (double inX, double inY) throws Graphic.Error
    {
        double x0, y0, x1, y1;

        context.get_current_point (out x0, out y0);
        status ();
        x1 = x0;
        y1 = y0;
        if (m_LastPath == PathType.CURVETO_QUADRATIC)
        {
            x1 = x0 + (x0 - m_LastControlX);
            y1 = y0 + (y0 - m_LastControlY);
        }
        quadratic_curve_to (inX, inY, x1, y1);
    }

    public override void
    rel_smooth_quadratic_curve_to (double inX, double inY) throws Graphic.Error
    {
        double x0, y0;

        context.get_current_point (out x0, out y0);
        status ();
        smooth_quadratic_curve_to (x0 + inX, y0 + inY);
    }

    public override void
    arc_to (double inRx, double inRy,
            double inXAxisRotation, bool inLargeArcFlag, bool inSweepFlag,
            double inX, double inY) throws Graphic.Error
    {
        double x1, y1, x2, y2, lambda;
        double v1, v2, angle, angle_sin, angle_cos, x11, y11;
        double rx_squared, ry_squared, x11_squared, y11_squared, top, bottom;
        double c, cx1, cy1, cx, cy, start_angle, angle_delta;

        context.get_current_point (out x1, out y1);
        status ();

        x2 = inX;
        y2 = inY;

        if (x1 == x2 && y1 == y2)
        {
            return;
        }

        if (inRx == 0.0 || inRy == 0.0)
        {
            context.line_to (x2, y2);
            return;
        }

        v1 = (x1 - x2) / 2.0;
        v2 = (y1 - y2) / 2.0;

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

        cx = (angle_cos * cx1) - (angle_sin * cy1) + (x1 + x2) / 2;
        cy = (angle_sin * cx1) + (angle_cos * cy1) + (y1 + y2) / 2;

        v1 = (x11 - cx1) / inRx;
        v2 = (y11 - cy1) / inRy;

        start_angle = calc_angle (1, 0, v1, v2);
        angle_delta = calc_angle (v1, v2, (-x11 - cx1) / inRx, (-y11 - cy1) / inRy);

        if (!inSweepFlag && angle_delta > 0.0)
            angle_delta -= 2 * GLib.Math.PI;
        else if (inSweepFlag && angle_delta < 0.0)
            angle_delta += 2 * GLib.Math.PI;

        context.save ();
        context.translate (cx, cy);
        status ();

        context.rotate (angle);
        status ();

        context.scale (inRx, inRy);
        status ();

        if (angle_delta > 0.0)
            context.arc (0.0, 0.0, 1.0, start_angle, start_angle + angle_delta);
        else
            context.arc_negative (0.0, 0.0, 1.0, start_angle, start_angle + angle_delta);
        status ();

        context.restore ();
        status ();

        m_LastPath = PathType.ARC;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_arc_to (double inRx, double inRy,
                double inXAxisRotation, bool inLargeArcFlag, bool inSweepFlag,
                double inX, double inY) throws Graphic.Error
    {
        double x, y;

        context.get_current_point (out x, out y);
        status ();

        arc_to (inRx, inRy, inXAxisRotation, inLargeArcFlag, inSweepFlag, x + inX , y + inY);
    }

    public override void
    rectangle (double inX, double inY,
               double inWidth, double inHeight,
               double inRx, double inRy) throws Graphic.Error
    {
        context.new_path ();

        if (inRx > inWidth / 2.0) inRx = inWidth / 2.0;
        if (inRy > inHeight / 2.0) inRy = inHeight / 2.0;
        if (inRx > 0 && inRy == 0) inRy = inRx;
        if (inRy > 0 && inRx == 0) inRx = inRy;

        if (inRx > 0 && inRy > 0)
        {
            context.move_to(inX + inRx, inY);
            status ();

            context.line_to (inX + inWidth - inRx, inY);
            status ();

            arc_to  (inRx, inRy, 0, false, true, inX + inWidth, inY + inRy);
            context.line_to (inX + inWidth, inY + inHeight - inRy);
            status ();

            arc_to  (inRx, inRy, 0, false, true, inX + inWidth - inRx, inY + inHeight);
            context.line_to (inX + inRx, inY + inHeight);
            status ();

            arc_to  (inRx, inRy, 0, false, true, inX, inY + inHeight - inRy);
            context.line_to (inX, inY + inRy);
            status ();

            arc_to  (inRx, inRy, 0, false, true, inX + inRx, inY);
        }
        else
        {
            context.rectangle (inX, inY, inWidth, inHeight);
            status ();
        }
    }

    public override void
    arc (double inXc, double inYc, double inRx, double inRy,
         double inAngle1, double inAngle2) throws Graphic.Error
    {
        context.save ();
        context.new_path ();
        context.translate (inXc, inYc);
        status ();

        context.scale (inRx, inRy);
        status ();

        context.arc (0, 0, 1, inAngle1, inAngle2);
        status ();

        context.restore ();
        status ();
    }

    public override void
    close_path () throws Graphic.Error
    {
        context.close_path ();
        context.move_to (m_OriginX, m_OriginY);
        status ();

        m_LastPath = PathType.UNKNOWN;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    add_clip_region (Graphic.Region inRegion) throws Graphic.Error
    {
        foreach (Rectangle rect in inRegion)
        {
            context.rectangle (rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
        context.clip ();
        context.status ();
    }

    public override void
    reset_clip () throws Graphic.Error
    {
        context.reset_clip ();
        context.status ();
    }

    public override void
    paint () throws Graphic.Error
    {
        context.paint ();
        context.status ();
    }

    public override void
    fill () throws Graphic.Error
    {
        context.fill ();
        context.status ();
    }

    public override void
    stroke () throws Graphic.Error
    {
        context.stroke ();
        context.status ();
    }
}

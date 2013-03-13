/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cairo-graphic-shape.vala
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

internal enum Maia.CairoGraphicPathType
{
    UNKNOWN,
    CLOSEPATH,
    MOVETO,
    LINETO,
    CURVETO,
    CURVETO_QUADRATIC,
    ARC
}

internal class Maia.CairoGraphicShape : GraphicShape
{
    // properties
    private unowned CairoGraphicContext m_Context  = null;
    private CairoGraphicPathType        m_LastPath = CairoGraphicPathType.UNKNOWN;
    private double m_OriginX                       = 0.0;
    private double m_OriginY                       = 0.0;
    private double m_LastControlX                  = 0.0;
    private double m_LastControlY                  = 0.0;

    // accessors
    public override GraphicContext context {
        get {
            return m_Context;
        }
    }

    // methods
    public CairoGraphicShape (CairoGraphicContext inContext)
    {
        m_Context = inContext;
    }

    private double
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

    public override void
    new_path () throws GraphicError
    {
        m_Context.context.new_path ();
        m_Context.context.move_to(0.0, 0.0);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.UNKNOWN;
        m_OriginX = 0.0;
        m_OriginY = 0.0;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    move_to (double inX, double inY) throws GraphicError
    {
        m_Context.context.move_to (inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.MOVETO;
        m_OriginX = inX;
        m_OriginY = inY;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_move_to (double inX, double inY) throws GraphicError
    {
        unowned Cairo.Context ctx = m_Context.context;
        double x0, y0;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();
        ctx.rel_move_to (inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.MOVETO;
        m_OriginX = inX + x0;
        m_OriginY = inY + y0;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    line_to (double inX, double inY) throws GraphicError
    {
        m_Context.context.line_to (inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_line_to (double inX, double inY) throws GraphicError
    {
        m_Context.context.rel_line_to (inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    horizontal_line_to (double inX) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x0, y0;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();
        ctx.line_to (inX, y0);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_horizontal_line_to (double inX) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x0, y0;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();
        ctx.line_to (inX + x0, y0);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    vertical_line_to (double inY) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x0, y0;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();
        ctx.line_to (x0, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_vertical_line_to (double inY) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x0, y0;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();
        ctx.line_to (x0, y0 + inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.LINETO;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    curve_to (double inX, double inY, double inX1, double inY1,
              double inX2, double inY2) throws GraphicError
    {
        m_Context.context.curve_to (inX1, inY1, inX2, inY2, inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.CURVETO;
        m_LastControlX = inX2;
        m_LastControlY = inY2;
    }

    public override void
    rel_curve_to (double inX, double inY, double inX1, double inY1,
                  double inX2, double inY2) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x0, y0;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();
        ctx.rel_curve_to (inX1, inY1, inX2, inY2, inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.CURVETO;
        m_LastControlX = x0 + inX2;
        m_LastControlY = y0 + inY2;
    }

    public override void
    smooth_curve_to (double inX, double inY,
                     double inX2, double inY2) throws GraphicError
    {
        double x0, y0, x1, y1;

        m_Context.context.get_current_point (out x0, out y0);
        m_Context.status ();
        x1 = x0;
        y1 = y0;
        if (m_LastPath == CairoGraphicPathType.CURVETO)
        {
            x1 = x0 + (x0 - m_LastControlX);
            y1 = y0 + (y0 - m_LastControlY);
        }
        curve_to (inX, inY, x1, y1, inX2, inY2);
    }

    public override void
    rel_smooth_curve_to (double inX, double inY,
                         double inX2, double inY2) throws GraphicError
    {
        double x0, y0;

        m_Context.context.get_current_point (out x0, out y0);
        m_Context.status ();
        smooth_curve_to (x0 + inX, y0 + inY, x0 + inX2, y0 + inY2);
    }

    public override void
    quadratic_curve_to (double inX, double inY,
                        double inX1, double inY1) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x0, y0, xx1, yy1, xx2, yy2;

        ctx.get_current_point (out x0, out y0);
        m_Context.status ();

        xx1 = x0 + (2.0 / 3.0) * (inX1 - x0);
        yy1 = y0 + (2.0 / 3.0) * (inY1 - y0);

        xx2 = inX + (2.0 / 3.0) * (inX1 - inX);
        yy2 = inY + (2.0 / 3.0) * (inY1 - inY);

        ctx.curve_to (xx1, yy1, xx2, yy2, inX, inY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.CURVETO_QUADRATIC;
        m_LastControlX = inX1;
        m_LastControlY = inY1;
    }

    public override void
    rel_quadratic_curve_to (double inX, double inY,
                            double inX1, double inY1) throws GraphicError
    {
        double x0, y0;

        m_Context.context.get_current_point (out x0, out y0);
        m_Context.status ();
        quadratic_curve_to (x0 + inX, y0 + inY, x0 + inX1, y0 + inY1);
    }

    public override void
    smooth_quadratic_curve_to (double inX, double inY) throws GraphicError
    {
        double x0, y0, x1, y1;

        m_Context.context.get_current_point (out x0, out y0);
        m_Context.status ();
        x1 = x0;
        y1 = y0;
        if (m_LastPath == CairoGraphicPathType.CURVETO_QUADRATIC)
        {
            x1 = x0 + (x0 - m_LastControlX);
            y1 = y0 + (y0 - m_LastControlY);
        }
        quadratic_curve_to (inX, inY, x1, y1);
    }

    public override void
    rel_smooth_quadratic_curve_to (double inX, double inY) throws GraphicError
    {
        double x0, y0;

        m_Context.context.get_current_point (out x0, out y0);
        m_Context.status ();
        smooth_quadratic_curve_to (x0 + inX, y0 + inY);
    }

    public override void
    arc_to (double inRx, double inRy,
            double inXAxisRotation, bool inLargeArcFlag, bool inSweepFlag,
            double inX, double inY) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;
        double x1, y1, x2, y2, lambda;
        double v1, v2, angle, angle_sin, angle_cos, x11, y11;
        double rx_squared, ry_squared, x11_squared, y11_squared, top, bottom;
        double c, cx1, cy1, cx, cy, start_angle, angle_delta;

        ctx.get_current_point (out x1, out y1);
        m_Context.status ();

        x2 = inX;
        y2 = inY;

        /* If the endpoints are exactly the same, just return (see SVG spec). */
        if (x1 == x2 && y1 == y2)
        {
            return;
        }

        /* If either rx or ry is 0, do a simple lineto (see SVG spec). */
        if (inRx == 0.0 || inRy == 0.0)
        {
            ctx.line_to (x2, y2);
            return;
        }

        /* Calculate x1' and y1' (as per SVG implementation notes). */
        v1 = (x1 - x2) / 2.0;
        v2 = (y1 - y2) / 2.0;

        angle = inXAxisRotation * (GLib.Math.PI / 180.0);
        angle_sin = GLib.Math.sin (angle);
        angle_cos = GLib.Math.cos (angle);

        x11 = (angle_cos * v1) + (angle_sin * v2);
        y11 = - (angle_sin * v1) + (angle_cos * v2);

        /* Ensure rx and ry are positive and large enough. */
        inRx = inRx > 0.0 ? inRx : - inRx;
        inRy = inRy > 0.0 ? inRy : - inRy;
        lambda = (x11 * x11) / (inRx * inRx) + (y11 * y11) / (inRy * inRy);
        if (lambda > 1.0)
        {
            double square_root = GLib.Math.sqrt (lambda);
            inRx *= square_root;
            inRy *= square_root;
        }

        /* Calculate cx' and cy'. */
        rx_squared = inRx * inRx;
        ry_squared = inRy * inRy;
        x11_squared = x11 * x11;
        y11_squared = y11 * y11;

        top = (rx_squared * ry_squared) - (rx_squared * y11_squared)
            - (ry_squared * x11_squared);
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

        /* Calculate cx and cy. */
        cx = (angle_cos * cx1) - (angle_sin * cy1) + (x1 + x2) / 2;
        cy = (angle_sin * cx1) + (angle_cos * cy1) + (y1 + y2) / 2;

        /* Calculate the start and end angles. */
        v1 = (x11 - cx1) / inRx;
        v2 = (y11 - cy1) / inRy;

        start_angle = calc_angle (1, 0, v1, v2);
        angle_delta = calc_angle (v1, v2, (-x11 - cx1) / inRx, (-y11 - cy1) / inRy);

        if (!inSweepFlag && angle_delta > 0.0)
            angle_delta -= 2 * GLib.Math.PI;
        else if (inSweepFlag && angle_delta < 0.0)
            angle_delta += 2 * GLib.Math.PI;

        /* Now draw the arc. */
        ctx.save ();
        ctx.translate (cx, cy);
        m_Context.status ();
        ctx.rotate (angle);
        m_Context.status ();
        ctx.scale (inRx, inRy);
        m_Context.status ();

        if (angle_delta > 0.0)
            ctx.arc (0.0, 0.0, 1.0, start_angle, start_angle + angle_delta);
        else
            ctx.arc_negative (0.0, 0.0, 1.0, start_angle,
                              start_angle + angle_delta);
        m_Context.status ();

        ctx.restore ();
        m_Context.status ();

        m_LastPath = CairoGraphicPathType.ARC;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }

    public override void
    rel_arc_to (double inRx, double inRy,
                double inXAxisRotation, bool inLargeArcFlag, bool inSweepFlag,
                double inX, double inY) throws GraphicError
    {
        double x, y;

        m_Context.context.get_current_point (out x, out y);
        m_Context.status ();

        arc_to (inRx, inRy, inXAxisRotation, inLargeArcFlag, inSweepFlag,
                x + inX , y + inY);
    }

    public override void
    rectangle (double inX, double inY,
               double inWidth, double inHeight,
               double inRx, double inRy) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;

        ctx.new_path ();

        if (inRx > inWidth / 2.0) inRx = inWidth / 2.0;
        if (inRy > inHeight / 2.0) inRy = inHeight / 2.0;
        if (inRx > 0 && inRy == 0) inRy = inRx;
        if (inRy > 0 && inRx == 0) inRx = inRy;

        if (inRx > 0 && inRy > 0)
        {
            ctx.move_to(inX + inRx, inY);
            m_Context.status ();
            ctx.line_to (inX + inWidth - inRx, inY);
            m_Context.status ();
            arc_to  (inRx, inRy, 0, false, true, inX + inWidth, inY + inRy);
            ctx.line_to (inX + inWidth, inY + inHeight - inRy);
            m_Context.status ();
            arc_to  (inRx, inRy, 0, false, true, inX + inWidth - inRx, inY + inHeight);
            ctx.line_to (inX + inRx, inY + inHeight);
            m_Context.status ();
            arc_to  (inRx, inRy, 0, false, true, inX, inY + inHeight - inRy);
            ctx.line_to (inX, inY + inRy);
            m_Context.status ();
            arc_to  (inRx, inRy, 0, false, true, inX + inRx, inY);
        }
        else
        {
            ctx.rectangle (inX, inY, inWidth, inHeight);
            m_Context.status ();
        }
    }

    public override void
    arc (double inXc, double inYc, double inRx, double inRy,
         double inAngle1, double inAngle2) throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;

        ctx.save ();
        ctx.new_path ();
        ctx.translate (inXc, inYc);
        m_Context.status ();
        ctx.scale (inRx, inRy);
        m_Context.status ();
        ctx.arc (0, 0, 1, inAngle1, inAngle2);
        m_Context.status ();
        ctx.restore ();
        m_Context.status ();
    }

    public override void
    close_path () throws GraphicError
    {
        Cairo.Context ctx = m_Context.context;

        ctx.close_path ();
        ctx.move_to (m_OriginX, m_OriginY);
        m_Context.status ();
        m_LastPath = CairoGraphicPathType.UNKNOWN;
        m_LastControlX = 0.0;
        m_LastControlY = 0.0;
    }
}
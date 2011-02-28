/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * graphic-shape.vala
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

public abstract class Maia.GraphicShape : Object
{
    // accessors
    public abstract GraphicContext context { get; }

    // methods
    public virtual void
    new_path () throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    move_to (double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_move_to (double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    line_to (double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_line_to (double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    horizontal_line_to (double inX) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_horizontal_line_to (double inX) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    vertical_line_to (double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_vertical_line_to (double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    curve_to (double inX, double inY,
              double inX1, double inY1,
              double inX2, double inY2) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_curve_to (double inX, double inY,
                  double inX1, double inY1,
                  double inX2, double inY2) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    smooth_curve_to (double inX, double inY,
                     double inX2, double inY2) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_smooth_curve_to (double inX, double inY,
                         double inX2, double inY2) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    quadratic_curve_to (double inX, double inY,
                        double inX1, double inY1) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_quadratic_curve_to (double inX, double inY, 
                            double inX1, double inY1) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    smooth_quadratic_curve_to (double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_smooth_quadratic_curve_to (double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    arc_to (double inRx, double inRy, 
            double inXAxisRotation, bool inLargeArcFlag,
            bool inSweepFlag, double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rel_arc_to (double inRx, double inRy, 
                double inXAxisRotation, bool inLargeArcFlag,
                bool inSweepFlag, double inX, double inY) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    rectangle (double inX, double inY, 
               double inWidth, double inHeight,
               double inRx, double inRy) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    arc (double inXc, double inYc,
         double inRx, double inRy,
         double inAngle1, double inAngle2) throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }

    public virtual void
    close_path () throws GraphicError
    {
        throw new GraphicError.NOT_IMPLEMENTED ("not implemented");
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * context.vala
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

public errordomain Maia.Graphic.Error
{
    SUCCESS,
    NOT_IMPLEMENTED,
    NO_MEMORY,
    END_ELEMENT,
    NO_CURRENT_POINT,
    INVALID_MATRIX,
    INVALID_STATUS,
    NULL_POINTER,
    INVALID_STRING,
    INVALID_PATH,
    SURFACE_FINISHED,
    SURFACE_TYPE_MISMATCH,
    PATTERN_TYPE_MISMATCH,
    UNKNOWN
}

public abstract class Maia.Graphic.Context : Object
{
    // accessors
    public abstract Device  device  { get; }
    public abstract Pattern pattern { set; }

    // methods
    public abstract void save    () throws Error;
    public abstract void restore () throws Error;
    public abstract void status  () throws Error;

    public abstract void new_path () throws Error;

    public abstract void move_to     (double inX, double inY) throws Error;
    public abstract void rel_move_to (double inX, double inY) throws Error;

    public abstract void line_to     (double inX, double inY) throws Error;
    public abstract void rel_line_to (double inX, double inY) throws Error;

    public abstract void horizontal_line_to     (double inX) throws Error;
    public abstract void rel_horizontal_line_to (double inX) throws Error;

    public abstract void vertical_line_to     (double inY) throws Error;
    public abstract void rel_vertical_line_to (double inY) throws Error;

    public abstract void curve_to     (double inX, double inY,
                                       double inX1, double inY1,
                                       double inX2, double inY2) throws Error;
    public abstract void rel_curve_to (double inX, double inY,
                                       double inX1, double inY1,
                                       double inX2, double inY2) throws Error;

    public abstract void smooth_curve_to     (double inX, double inY,
                                              double inX2, double inY2) throws Error;
    public abstract void rel_smooth_curve_to (double inX, double inY,
                                              double inX2, double inY2) throws Error;

    public abstract void quadratic_curve_to     (double inX, double inY,
                                                 double inX1, double inY1) throws Error;
    public abstract void rel_quadratic_curve_to (double inX, double inY,
                                                 double inX1, double inY1) throws Error;

    public abstract void smooth_quadratic_curve_to     (double inX, double inY) throws Error;
    public abstract void rel_smooth_quadratic_curve_to (double inX, double inY) throws Error;

    public abstract void arc_to     (double inRx, double inRy,
                                     double inXAxisRotation, bool inLargeArcFlag,
                                     bool inSweepFlag, double inX, double inY) throws Error;
    public abstract void rel_arc_to (double inRx, double inRy,
                                     double inXAxisRotation, bool inLargeArcFlag,
                                     bool inSweepFlag, double inX, double inY) throws Error;

    public abstract void rectangle (double inX, double inY,
                                    double inWidth, double inHeight,
                                    double inRx, double inRy) throws Error;

    public abstract void arc (double inXc, double inYc,
                              double inRx, double inRy,
                              double inAngle1, double inAngle2) throws Error;

    public abstract void close_path () throws Error;

    public abstract void add_clip_region (Region inRegion) throws Error;
    public abstract void reset_clip      () throws Error;
    public abstract void paint           () throws Error;
    public abstract void fill            () throws Error;
    public abstract void stroke          () throws Error;
}

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

public enum Maia.Graphic.Operator
{
    CLEAR,
    SOURCE,
    OVER,
    IN,
    OUT,
    ATOP,
    DEST,
    DEST_OVER,
    DEST_IN,
    DEST_OUT,
    DEST_ATOP,
    XOR,
    ADD,
    SATURATE,
    MULTIPLY,
    SCREEN,
    OVERLAY,
    DARKEN,
    LIGHTEN,
    COLOR_DODGE,
    COLOR_BURN,
    HARD_LIGHT,
    SOFT_LIGHT,
    DIFFERENCE,
    EXCLUSION,
    HSL_HUE,
    HSL_SATURATION,
    HSL_COLOR,
    HSL_LUMINOSITY
}

public class Maia.Graphic.Context : Core.Object
{
    // accessors
    public virtual Operator          operator   { get; set; default = Operator.OVER; }
    public virtual unowned Surface   surface    { get; construct set; }
    public virtual Pattern           pattern    { get; set; }
    public virtual double            line_width { get; set; }
    public virtual double[]?         dash       { get; set; }
    public virtual Transform         transform  { get; set; }

    // methods
    public Context (Surface inSurface)
    {
        GLib.Object (surface: inSurface);
    }

    public virtual void
    save () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Save context not implemented");
    }

    public virtual void
    restore () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Restore context not implemented");
    }

    public virtual void
    status  () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context status not implemented");
    }

    public virtual void
    translate (Point inOffset) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context translate not implemented");
    }

    public virtual void
    clip (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context clip not implemented");
    }

    public virtual void
    clip_region (Region inRegion) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context clip_region not implemented");
    }

    public virtual void
    paint () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context paint not implemented");
    }

    public virtual void
    fill (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context fill not implemented");
    }

    public virtual void
    stroke (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context stroke not implemented");
    }

    public virtual void
    render (Glyph inGlyph) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context render not implemented");
    }

    public virtual Rectangle
    get_path_area (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context path area not implemented");
    }
}

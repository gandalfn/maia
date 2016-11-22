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
    INVALID_CONTENT,
    INVALID_FORMAT,
    INVALID_VISUAL,
    FILE_NOT_FOUND,
    INVALID_DASH,
    INVALID_DSC_COMMENT,
    INVALID_INDEX,
    CLIP_NOT_REPRESENTABLE,
    TEMP_FILE_ERROR,
    INVALID_STRIDE,
    FONT_TYPE_MISMATCH,
    USER_FONT_IMMUTABLE,
    USER_FONT_ERROR,
    NEGATIVE_COUNT,
    INVALID_CLUSTERS,
    INVALID_SLANT,
    INVALID_WEIGHT,
    INVALID_SIZE,
    USER_FONT_NOT_IMPLEMENTED,
    DEVICE_TYPE_MISMATCH,
    DEVICE_ERROR,
    INVALID_MESH_CONSTRUCTION,
    DEVICE_FINISHED,
    INVALID_BACKEND,
    INVALID_PROPERTY,
    UNKNOWN
}

/**
 * Operator is used to set the compositing operator for all graphic drawing operations.
 *
 * The default operator is Operator.OVER.
 *
 * The operators marked as unbounded modify their destination even outside of the mask layer
 * (that is, their effect is not bound by the mask layer). However, their effect can still be
 * limited by way of clipping.
 */
public enum Maia.Graphic.Operator
{
    /**
     * clear destination layer (bounded)
     */
    CLEAR,
    /**
     * replace destination layer (bounded)
     */
    SOURCE,
    /**
     * draw source layer on top of destination layer (bounded)
     */
    OVER,
    /**
     * draw source where there was destination content (unbounded)
     */
    IN,
    /**
     * draw source where there was no destination content (unbounded)
     */
    OUT,
    /**
     * draw source on top of destination content and only there
     */
    ATOP,
    /**
     * draw source on top of destination content and only there
     */
    DEST,
    /**
     * draw destination on top of source
     */
    DEST_OVER,
    /**
     * leave destination only where there was source content (unbounded)
     */
    DEST_IN,
    /**
     * leave destination only where there was source content (unbounded)
     */
    DEST_OUT,
    /**
     * leave destination only where there was source content (unbounded)
     */
    DEST_ATOP,
    /**
     * leave destination only where there was source content (unbounded)
     */
    XOR,
    /**
     * leave destination only where there was source content (unbounded)
     */
    ADD,
    /**
     * like over, but assuming source and dest are disjoint geometries
     */
    SATURATE,
    /**
     * source and destination layers are multiplied. This causes the result
     * to be at least as dark as the darker inputs.
     */
    MULTIPLY,
    /**
     * source and destination are complemented and multiplied. This causes
     * the result to be at least as light as the lighter inputs.
     */
    SCREEN,
    /**
     * multiplies or screens, depending on the lightness of the destination
     * color.
     */
    OVERLAY,
    /**
     * replaces the destination with the source if it is darker, otherwise
     * keeps the source.
     */
    DARKEN,
    /**
     * replaces the destination with the source if it is lighter, otherwise
     * keeps the source.
     */
    LIGHTEN,
    /**
     * brightens the destination color to reflect the source color.
     */
    COLOR_DODGE,
    /**
     * darkens the destination color to reflect the source color.
     */
    COLOR_BURN,
    /**
     * Multiplies or screens, dependent on source color.
     */
    HARD_LIGHT,
    /**
     * Darkens or lightens, dependent on source color.
     */
    SOFT_LIGHT,
    /**
     * Takes the difference of the source and destination color.
     */
    DIFFERENCE,
    /**
     * Produces an effect similar to difference, but with lower contrast.
     */
    EXCLUSION,
    /**
     * Creates a color with the hue of the source and the saturation and
     * luminosity of the target.
     */
    HSL_HUE,
    /**
     * Creates a color with the saturation of the source and the hue and
     * luminosity of the target. Painting with this mode onto a gray area
     * produces no change.
     */
    HSL_SATURATION,
    /**
     * Creates a color with the hue and saturation of the source and the
     * luminosity of the target. This preserves the gray levels of the
     * target and is useful for coloring monochrome images or tinting color
     * images.
     */
    HSL_COLOR,
    /**
     * Creates a color with the luminosity of the source and the hue and
     * saturation of the target. This produces an inverse effect to
     * HSL_COLOR.
     */
    HSL_LUMINOSITY
}

/**
 * Specifies how to render the junction of two lines when stroking.
 *
 * The default line join style is LineJoin.MITER.
 */
public enum Maia.Graphic.LineJoin
{
    /**
     * use a sharp (angled) corner
     */
    MITER,
    /**
     * use a rounded join, the center of the circle is the joint point.
     */
    ROUND,
    /**
     * use a cut-off join, the join is cut off at half the line width
     * from the joint point.
     */
    BEVEL
}

/**
 * Specifies how to render the endpoints of the path when stroking.
 *
 * The default line cap style is LineCap.BUTT.
 */
public enum Maia.Graphic.LineCap
{
    /**
     * start(stop) the line exactly at the start(end) point.
     */
    BUTT,
    /**
     * use a round ending, the center of the circle is the end point.
     */
    ROUND,
    /**
     * use a round ending, the center of the circle is the end point.
     */
    SQUARE
}

public class Maia.Graphic.Context : Core.Object
{
    // accessors
    /**
     * The compositing operator to be used for all drawing operations.
     */
    [CCode (notify = false)]
    public virtual Operator          operator   { get; set; default = Operator.OVER; }
    [CCode (notify = false)]
    public virtual unowned Surface   surface    { get; construct set; }
    [CCode (notify = false)]
    public virtual unowned Pattern   pattern    { get; set; }
    [CCode (notify = false)]
    public virtual double            line_width { get; set; }
    /**
     * The current line join style within the Context.
     */
    [CCode (notify = false)]
    public virtual LineJoin          line_join  { get; set; }
    /**
     * The current line cap style within the Context.
     */
    [CCode (notify = false)]
    public virtual LineCap           line_cap   { get; set; }
    [CCode (notify = false)]
    public virtual double[]?         dash       { get; set; }
    [CCode (notify = false)]
    public virtual Transform         transform  { owned get; set; }

    // methods
    /**
     * Creates a new Context with all graphics state parameters set to default values and with
     * target as a target surface
     *
     * @param inSurface target surface for the context
     */
    public Context (Surface inSurface)
    {
        GLib.Object (surface: inSurface);
    }

    /**
     * Makes a copy of the current state of Context and saves it on an internal stack of
     * saved states for Context.
     *
     * When restore() is called, Context will be restored to the saved state.
     * Multiple calls to save() and restore() can be nested; each call
     * to restore() restores the state from the matching paired save().
     */
    public virtual void
    save () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Save context not implemented");
    }

    /**
     * Restores cr to the state saved by a preceding call to save() and removes that state
     * from the stack of saved states.
     */
    public virtual void
    restore () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Restore context not implemented");
    }

    /**
     * Checks whether an error has previously occurred for this Context.
     */
    public virtual void
    status  () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context status not implemented");
    }

    /**
     * Modifies the current transformation matrix (CTM) by translating the user-space
     * origin by @inOffset.
     *
     * This offset is interpreted as a user-space coordinate according to the CTM in
     * place before the new call to translate. In other words, the translation of
     * the user-space origin takes place after any existing transformation.
     *
     * @param inOffset amount to translate
     */
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
    mask (Pattern inPattern) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context paint not implemented");
    }

    public virtual void
    paint () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context paint not implemented");
    }

    public virtual void
    paint_with_alpha (double inAlpha) throws Error
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

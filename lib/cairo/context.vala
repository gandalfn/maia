/* -*- Mode: Vala indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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

internal class Maia.Cairo.Context : Graphic.Context
{
    // properties
    private global::Cairo.Context m_Context = null;
    private Graphic.Transform     m_Transform = new Graphic.Transform.identity ();
    private double[]?             m_Dashes = null;
    private uint                  m_SaveCount = 0;

    // accessors
    internal global::Cairo.Context context {
        get {
            return m_Context;
        }
    }

    public override Graphic.Operator operator {
        get {
            return m_Context != null ? (Graphic.Operator)m_Context.get_operator () : Graphic.Operator.OVER;
        }
        set {
            m_Context.set_operator ((global::Cairo.Operator)value);
        }
    }

    public override Graphic.Transform transform {
        get {
            return m_Transform;
        }
        set {
            if (m_Context != null)
            {
                // convert matrix to cairo format
                global::Cairo.Matrix matrix = global::Cairo.Matrix (value.matrix.xx, value.matrix.yx,
                                                                    value.matrix.xy, value.matrix.yy,
                                                                    value.matrix.x0, value.matrix.y0);

                // apply matrix
                m_Context.transform (matrix);
            }
        }
    }

    public override unowned Graphic.Surface surface {
        get {
            return base.surface;
        }
        construct set {
            base.surface = value;
            m_Context = new global::Cairo.Context ((value as Surface).surface);
        }
    }

    public override double line_width {
        get {
            if (m_Context != null)
            {
                return m_Context.get_line_width ();
            }
            return 0;
        }
        set {
            if (m_Context != null)
            {
                m_Context.set_line_width (value);
            }
        }
    }

    public override double[]? dash {
        get {
            return m_Dashes;
        }
        set {
            if (m_Context != null)
            {
                m_Dashes = value;
                m_Context.set_dash (m_Dashes, 0);
            }
        }
    }

    public override Graphic.Pattern pattern {
        get {
            return base.pattern;
        }
        set {
            base.pattern = value;
            if (value is Graphic.Surface)
            {
                global::Cairo.Pattern pattern = new global::Cairo.Pattern.for_surface (((Surface)value).surface);
                m_Context.set_source (pattern);
            }
            else if (value is Graphic.Image)
            {
                unowned Graphic.Image image = (Graphic.Image)value;
                global::Cairo.Pattern pattern = new global::Cairo.Pattern.for_surface (((Surface)image.surface).surface);
                m_Context.set_source (pattern);
            }
            else if (value is Graphic.Color)
            {
                m_Context.set_source_rgba (((Graphic.Color)value).red,
                                           ((Graphic.Color)value).green,
                                           ((Graphic.Color)value).blue,
                                           ((Graphic.Color)value).alpha);
            }
            else if (value is Graphic.LinearGradient)
            {
                unowned Graphic.LinearGradient? gradient = (Graphic.LinearGradient?)value;

                global::Cairo.Pattern pattern = new global::Cairo.Pattern.linear (gradient.start.x, gradient.start.y,
                                                                                  gradient.end.x,   gradient.end.y);
                foreach (unowned Object child in gradient)
                {
                    unowned Graphic.Gradient.ColorStop? color_stop = (Graphic.Gradient.ColorStop?)child;
                    pattern.add_color_stop_rgba (color_stop.offset,
                                                 color_stop.color.red,
                                                 color_stop.color.green,
                                                 color_stop.color.blue,
                                                 color_stop.color.alpha);
                }

                m_Context.set_source (pattern);
            }
        }
    }

    // methods
    public Context (Graphic.Surface inSurface)
    {
        base (inSurface);
    }

    private void
    set_path (Graphic.Path inPath) throws Graphic.Error
    {
        switch (inPath.data_type)
        {
            case Graphic.Path.DataType.PATH:
                foreach (unowned Object child in inPath)
                {
                    set_path (child as Graphic.Path);
                }
                break;

            case Graphic.Path.DataType.MOVETO:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "move to %g,%g", inPath.points[0].x, inPath.points[0].y);
                m_Context.move_to (inPath.points[0].x, inPath.points[0].y);
                status ();
                break;

            case Graphic.Path.DataType.LINETO:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "line to %g,%g", inPath.points[0].x, inPath.points[0].y);
                m_Context.line_to (inPath.points[0].x, inPath.points[0].y);
                status ();
                break;

            case Graphic.Path.DataType.CURVETO:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "curve to %g,%g %g,%g %g,%g", inPath.points[0].x, inPath.points[0].y,
                                                                                                    inPath.points[1].x, inPath.points[1].y,
                                                                                                    inPath.points[2].x, inPath.points[2].y);
                m_Context.curve_to (inPath.points[0].x, inPath.points[0].y,
                                    inPath.points[1].x, inPath.points[1].y,
                                    inPath.points[2].x, inPath.points[2].y);
                status ();
                break;

            case Graphic.Path.DataType.ARC:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "arc %g,%g %g%g %g,%g", inPath.points[0].x, inPath.points[0].y,
                                                                                               inPath.points[1].x, inPath.points[1].y,
                                                                                               inPath.points[2].x, inPath.points[2].y);
                m_Context.save ();
                m_Context.translate (inPath.points[0].x, inPath.points[0].y);
                status ();
                m_Context.scale (inPath.points[1].x, inPath.points[1].y);
                status ();
                m_Context.arc (0, 0, 1, inPath.points[2].x, inPath.points[2].y);
                status ();
                m_Context.restore ();
                break;

            case Graphic.Path.DataType.ARC_NEGATIVE:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "arc negative %g,%g %g%g %g,%g", inPath.points[0].x, inPath.points[0].y,
                                                                                                        inPath.points[1].x, inPath.points[1].y,
                                                                                                        inPath.points[2].x, inPath.points[2].y);
                m_Context.save ();
                m_Context.translate (inPath.points[0].x, inPath.points[0].y);
                status ();
                m_Context.scale (inPath.points[1].x, inPath.points[1].y);
                status ();
                m_Context.arc_negative (0, 0, 1, inPath.points[2].x, inPath.points[2].y);
                status ();
                m_Context.restore ();
                break;

            case Graphic.Path.DataType.RECTANGLE:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "rectangle %g,%g %g,%g", inPath.points[0].x, inPath.points[0].y,
                                                                                                inPath.points[1].x, inPath.points[1].y);
                m_Context.rectangle (inPath.points[0].x, inPath.points[0].y,
                                     inPath.points[1].x - inPath.points[0].x,
                                     inPath.points[1].y - inPath.points[0].y);
                status ();
                break;
        }
    }

    public override void
    save () throws Graphic.Error
    {
        m_Context.save ();
        status ();
        m_SaveCount++;
    }

    public override void
    restore () throws Graphic.Error
    {
        if (m_SaveCount > 0)
        {
            m_Context.restore ();
            status ();
            m_SaveCount--;
        }
    }

    public override void
    status () throws Graphic.Error
    {
        global::Cairo.Status status = m_Context.status ();

        if (status != global::Cairo.Status.SUCCESS)
        {
            for (int cpt = 0; cpt < m_SaveCount; cpt++)
            {
                m_Context.restore ();
            }
        }

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
    clip (Graphic.Path inPath) throws Graphic.Error
    {
        m_Context.new_path ();
        set_path (inPath);
        m_Context.clip ();
        status ();
    }

    public override void
    clip_region (Graphic.Region inRegion) throws Graphic.Error
    {
        foreach (unowned Graphic.Rectangle rect in inRegion)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "clip %s", rect.to_string ());
            m_Context.rectangle (rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
        m_Context.clip ();
        status ();
    }

    public override void
    translate (Graphic.Point inOffset) throws Graphic.Error
    {
        m_Context.translate (inOffset.x, inOffset.y);
        status ();
    }

    public override void
    paint () throws Graphic.Error
    {
        m_Context.paint ();
        status ();
    }

    public override void
    fill (Graphic.Path inPath) throws Graphic.Error
    {
        m_Context.new_path ();
        set_path (inPath);
        m_Context.fill ();
        status ();
    }

    public override void
    stroke (Graphic.Path inPath) throws Graphic.Error
    {
        m_Context.new_path ();
        set_path (inPath);
        m_Context.stroke ();
        status ();
    }

    public override void
    render (Graphic.Glyph inGlyph) throws Graphic.Error
    {
        m_Context.move_to (inGlyph.origin.x, inGlyph.origin.y);
        status ();
        (inGlyph as Glyph).update (this);
        Pango.cairo_show_layout (m_Context, (inGlyph as Glyph).layout);
        status ();
    }

    public override Graphic.Rectangle
    get_path_area (Graphic.Path inPath) throws Graphic.Error
    {
        double x1, y1, x2, y2;

        m_Context.new_path ();
        set_path (inPath);
        m_Context.path_extents (out x1, out y1, out x2, out y2);
        status ();
        return Graphic.Rectangle (x1, y1, x2 - x1, y2 - y1);
    }
}

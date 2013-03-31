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
    // properties
    private global::Cairo.Context m_Context = null;

    // accessors
    internal global::Cairo.Context context {
        get {
            return m_Context;
        }
    }

    public override Graphic.Device device {
        get {
            return base.device;
        }
        construct set {
            base.device = value;
            m_Context = new global::Cairo.Context ((value as Device).surface);
        }
    }


    public override Graphic.Pattern pattern {
        get {
            return base.pattern;
        }
        set {
            base.pattern = value;
            if (value is Graphic.Device)
            {
                global::Cairo.Pattern pattern = new global::Cairo.Pattern.for_surface (((Cairo.Device)value).surface);
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
    public Context (Device inDevice)
    {
        base (inDevice);
    }

    private void
    set_path (Path inPath) throws Graphic.Error
    {
        switch (inPath.data_type)
        {
            case Graphic.Path.DataType.PATH:
                foreach (unowned Object child in inPath)
                {
                    set_path (child as Path);
                }
                break;

            case Graphic.Path.DataType.MOVETO:
                Log.audit (GLib.Log.METHOD, "move to %f,%f", inPath.points[0].x, inPath.points[0].y);
                m_Context.move_to (inPath.points[0].x, inPath.points[0].y);
                status ();
                break;

            case Graphic.Path.DataType.LINETO:
                Log.audit (GLib.Log.METHOD, "line to %f,%f", inPath.points[0].x, inPath.points[0].y);
                m_Context.line_to (inPath.points[0].x, inPath.points[0].y);
                status ();
                break;

            case Graphic.Path.DataType.CURVETO:
                Log.audit (GLib.Log.METHOD, "curve to %f,%f %f%f %f,%f", inPath.points[0].x, inPath.points[0].y,
                                                                         inPath.points[1].x, inPath.points[1].y,
                                                                         inPath.points[2].x, inPath.points[2].y);
                m_Context.curve_to (inPath.points[0].x, inPath.points[0].y,
                                    inPath.points[1].x, inPath.points[1].y,
                                    inPath.points[2].x, inPath.points[2].y);
                status ();
                break;

            case Graphic.Path.DataType.ARC:
                Log.audit (GLib.Log.METHOD, "arc %f,%f %f%f %f,%f", inPath.points[0].x, inPath.points[0].y,
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
                Log.audit (GLib.Log.METHOD, "arc negative %f,%f %f%f %f,%f", inPath.points[0].x, inPath.points[0].y,
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
                Log.audit (GLib.Log.METHOD, "rectangle %f,%f %f,%f", inPath.points[0].x, inPath.points[0].y,
                                                                     inPath.points[1].x, inPath.points[1].y);
                m_Context.rectangle (inPath.points[0].x, inPath.points[0].y,
                                     inPath.points[1].x, inPath.points[1].y);
                status ();
                break;
        }
    }

    public override void
    save () throws Graphic.Error
    {
        m_Context.save ();
        status ();
    }

    public override void
    restore () throws Graphic.Error
    {
        m_Context.restore ();
        status ();
    }

    public override void
    status () throws Graphic.Error
    {
        global::Cairo.Status status = m_Context.status ();

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
    clip (Path inPath) throws Graphic.Error
    {
        set_path (inPath);
        m_Context.clip ();
        status ();
    }

    public override void
    translate (Point inOffset) throws Graphic.Error
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
    fill (Path inPath) throws Graphic.Error
    {
        set_path (inPath);
        m_Context.fill ();
        status ();
    }

    public override void
    stroke (Path inPath) throws Graphic.Error
    {
        set_path (inPath);
        m_Context.stroke ();
        status ();
    }

    public override void
    render (Graphic.Glyph inGlyph) throws Graphic.Error
    {
        m_Context.move_to (inGlyph.origin.x, inGlyph.origin.y);
        status ();
        (inGlyph as Cairo.Glyph).update (this);
        Pango.cairo_show_layout (m_Context, (inGlyph as Cairo.Glyph).layout);
        status ();
    }
}

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
    private Device                m_Device = null;

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

    // methods
    internal Context (Device inDevice)
    {
        m_Device = inDevice;
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
                context.move_to (inPath.points[0].x, inPath.points[0].y);
                status ();
                break;

            case Graphic.Path.DataType.LINETO:
                context.line_to (inPath.points[0].x, inPath.points[0].y);
                status ();
                break;

            case Graphic.Path.DataType.CURVETO:
                context.curve_to (inPath.points[0].x, inPath.points[0].y,
                                  inPath.points[1].x, inPath.points[1].y,
                                  inPath.points[2].x, inPath.points[2].y);
                status ();
                break;

            case Graphic.Path.DataType.ARC:
                context.save ();
                context.translate (inPath.points[0].x, inPath.points[0].y);
                status ();
                context.scale (inPath.points[1].x, inPath.points[1].y);
                status ();
                context.arc (0, 0, 1, inPath.points[2].x, inPath.points[2].y);
                status ();
                context.restore ();
                break;

            case Graphic.Path.DataType.ARC_NEGATIVE:
                context.save ();
                context.translate (inPath.points[0].x, inPath.points[0].y);
                status ();
                context.scale (inPath.points[1].x, inPath.points[1].y);
                status ();
                context.arc_negative (0, 0, 1, inPath.points[2].x, inPath.points[2].y);
                status ();
                context.restore ();
                break;

            case Graphic.Path.DataType.RECTANGLE:
                context.rectangle (inPath.points[0].x, inPath.points[0].y,
                                   inPath.points[1].x + inPath.points[0].x,
                                   inPath.points[1].y + inPath.points[0].y);
                status ();
                break;
        }
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
    clip (Path inPath) throws Graphic.Error
    {
        set_path (inPath);
        context.clip ();
        context.status ();
    }

    public override void
    paint () throws Graphic.Error
    {
        context.paint ();
        context.status ();
    }

    public override void
    fill (Path inPath) throws Graphic.Error
    {
        set_path (inPath);
        context.fill ();
        context.status ();
    }

    public override void
    stroke (Path inPath) throws Graphic.Error
    {
        set_path (inPath);
        context.stroke ();
        context.status ();
    }

    public override void
    render (Graphic.Glyph inGlyph) throws Graphic.Error
    {
        context.move_to (inGlyph.origin.x, inGlyph.origin.y);
        (inGlyph as Cairo.Glyph).update (this);
        Pango.cairo_show_layout (context, (inGlyph as Cairo.Glyph).layout);
    }
}

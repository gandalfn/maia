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
    private global::Cairo.Context      m_Context = null;
    private Pango.Context              m_PangoContext = null;
    private double[]?                  m_Dashes = null;
    private uint                       m_SaveCount = 0;
    private Core.Notification.Observer m_TransformPatternObserver = null;

    // accessors
    public global::Cairo.Context context {
        get {
            return m_Context;
        }
    }

    public Pango.Context? pango_context {
        get {
            if (m_Context != null && m_PangoContext == null)
            {
                m_PangoContext = Pango.cairo_create_context (m_Context);
            }
            return m_PangoContext;
        }
    }

    [CCode (notify = false)]
    internal override Graphic.Operator operator {
        get {
            return m_Context != null ? (Graphic.Operator)m_Context.get_operator () : Graphic.Operator.OVER;
        }
        set {
            if (m_Context != null)
            {
                m_Context.set_operator ((global::Cairo.Operator)value);
            }
        }
    }

    [CCode (notify = false)]
    internal override Graphic.Transform transform {
        owned get {
            global::Cairo.Matrix matrix = m_Context.get_matrix ();

            return new Graphic.Transform.from_matrix (Graphic.Matrix (matrix.xx, matrix.yx,
                                                                      matrix.xy, matrix.yy,
                                                                      matrix.x0, matrix.y0));
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

    [CCode (notify = false)]
    public override unowned Graphic.Surface surface {
        get {
            return base.surface;
        }
        construct set {
            base.surface = value;
            if ((value as Surface).native != null)
            {
                m_Context = new global::Cairo.Context ((global::Cairo.Surface)(value as Surface).native);
                m_Context.set_fill_rule (global::Cairo.FillRule.EVEN_ODD);
                m_Context.set_antialias (global::Cairo.Antialias.SUBPIXEL);
            }
        }
    }

    [CCode (notify = false)]
    internal override double line_width {
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

    [CCode (notify = false)]
    internal override Graphic.LineJoin line_join {
        get {
            if (m_Context != null)
            {
                return (Graphic.LineJoin)m_Context.get_line_join ();
            }
            return Graphic.LineJoin.MITER;
        }
        set {
            if (m_Context != null)
            {
                m_Context.set_line_join ((global::Cairo.LineJoin)value);
            }
        }
    }

    [CCode (notify = false)]
    internal override Graphic.LineCap line_cap {
        get {
            if (m_Context != null)
            {
                return (Graphic.LineCap)m_Context.get_line_cap ();
            }
            return Graphic.LineCap.BUTT;
        }
        set {
            if (m_Context != null)
            {
                m_Context.set_line_cap ((global::Cairo.LineCap)value);
            }
        }
    }

    [CCode (notify = false)]
    internal override double[]? dash {
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

    [CCode (notify = false)]
    internal override unowned Graphic.Pattern pattern {
        get {
            return base.pattern;
        }
        set {
            if (m_TransformPatternObserver != null)
            {
                m_TransformPatternObserver.parent = null;
                m_TransformPatternObserver = null;
            }
            base.pattern = value;

            if (base.pattern != null)
            {
                m_TransformPatternObserver = base.pattern.transform.changed.add_object_observer (on_pattern_transform_changed);
            }

            on_pattern_transform_changed ();
        }
    }

    // methods
    public Context (Graphic.Surface inSurface)
    {
        base (inSurface);
    }

    private inline Graphic.Point
    floor_point (double inX, double inY)
    {
        Graphic.Point ret = Graphic.Point (inX, inY);
        m_Context.user_to_device (ref ret.x, ref ret.y);
        ret.x = GLib.Math.floor (ret.x);
        ret.y = GLib.Math.floor (ret.y);
        m_Context.device_to_user (ref ret.x, ref ret.y);
        return ret;
    }

    private inline Graphic.Point
    ceil_point (double inX, double inY)
    {
        Graphic.Point ret = Graphic.Point (inX, inY);
        m_Context.user_to_device (ref ret.x, ref ret.y);
        ret.x = GLib.Math.ceil (ret.x);
        ret.y = GLib.Math.ceil (ret.y);
        m_Context.device_to_user (ref ret.x, ref ret.y);
        return ret;
    }

    private void
    on_pattern_transform_changed ()
    {
        if (m_Context != null)
        {
            m_TransformPatternObserver.block = true;
            global::Cairo.Pattern? pattern = pattern_to_cairo (base.pattern);
            pattern.set_filter (global::Cairo.Filter.GOOD);

            if (pattern != null)
            {
                global::Cairo.Matrix matrix = global::Cairo.Matrix (base.pattern.transform.matrix.xx, base.pattern.transform.matrix.yx,
                                                                    base.pattern.transform.matrix.xy, base.pattern.transform.matrix.yy,
                                                                    base.pattern.transform.matrix.x0, base.pattern.transform.matrix.y0);
                pattern.set_matrix (matrix);

                m_Context.set_source (pattern);
            }
            m_TransformPatternObserver.block = false;
        }
    }

    private global::Cairo.Pattern?
    pattern_to_cairo (Graphic.Pattern inPattern)
    {
        global::Cairo.Pattern? pattern = null;

        if (inPattern is Graphic.Surface)
        {
            pattern = new global::Cairo.Pattern.for_surface ((global::Cairo.Surface)((Surface)inPattern).native);
        }
        else if (inPattern is Graphic.Image)
        {
            unowned Graphic.Image image = (Graphic.Image)inPattern;
            pattern = new global::Cairo.Pattern.for_surface ((global::Cairo.Surface)image.surface.native);
        }
        else if (inPattern is Graphic.Color)
        {
            pattern = new global::Cairo.Pattern.rgba (((Graphic.Color)inPattern).red,
                                                      ((Graphic.Color)inPattern).green,
                                                      ((Graphic.Color)inPattern).blue,
                                                      ((Graphic.Color)inPattern).alpha);
        }
        else if (inPattern is Graphic.LinearGradient)
        {
            unowned Graphic.LinearGradient? gradient = (Graphic.LinearGradient?)inPattern;

            pattern = new global::Cairo.Pattern.linear (gradient.start.x, gradient.start.y,
                                                        gradient.end.x,   gradient.end.y);
            foreach (unowned Object child in gradient)
            {
                if (child is Graphic.Gradient.ColorStop)
                {
                    unowned Graphic.Gradient.ColorStop? color_stop = (Graphic.Gradient.ColorStop?)child;
                    pattern.add_color_stop_rgba (color_stop.offset,
                                                 color_stop.color.red,
                                                 color_stop.color.green,
                                                 color_stop.color.blue,
                                                 color_stop.color.alpha);
                }
            }
        }
        else if (inPattern is Graphic.RadialGradient)
        {
            unowned Graphic.RadialGradient? gradient = (Graphic.RadialGradient?)inPattern;

            pattern = new global::Cairo.Pattern.radial (gradient.start.x, gradient.start.y, gradient.start_radius,
                                                        gradient.end.x,   gradient.end.y, gradient.end_radius);
            foreach (unowned Object child in gradient)
            {
                if (child is Graphic.Gradient.ColorStop)
                {
                    unowned Graphic.Gradient.ColorStop? color_stop = (Graphic.Gradient.ColorStop?)child;
                    pattern.add_color_stop_rgba (color_stop.offset,
                                                 color_stop.color.red,
                                                 color_stop.color.green,
                                                 color_stop.color.blue,
                                                 color_stop.color.alpha);
                }
            }
        }
        else if (inPattern is Graphic.MeshGradient)
        {
            unowned Graphic.MeshGradient? gradient = (Graphic.MeshGradient?)inPattern;

            global::Cairo.MeshPattern mesh_pattern = new global::Cairo.MeshPattern ();
            foreach (unowned Object child in gradient)
            {
                // Add mesh patch
                if (child is Graphic.MeshGradient.Patch)
                {
                    var patch = child as Graphic.MeshGradient.Patch;
                    mesh_pattern.begin_patch ();
                    set_pattern_path (mesh_pattern, patch.path);

                    // parse patch control
                    foreach (unowned Object child_patch in patch)
                    {
                        if (child_patch is Graphic.MeshGradient.Patch.CornerColor)
                        {
                            var corner_color = (Graphic.MeshGradient.Patch.CornerColor)child_patch;
                            Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "%u %s", corner_color.num, corner_color.color.to_string ());
                            mesh_pattern.set_corner_color_rgba (corner_color.num, corner_color.color.red, corner_color.color.green,
                                                                corner_color.color.blue, corner_color.color.alpha);
                        }
                        else if (child_patch is Graphic.MeshGradient.Patch.ControlPoint)
                        {
                            var control_point = (Graphic.MeshGradient.Patch.ControlPoint)child_patch;
                            mesh_pattern.set_control_point (control_point.num, control_point.point.x, control_point.point.y);
                        }
                    }
                    mesh_pattern.end_patch ();
                }
            }
            pattern = mesh_pattern;
        }

        return pattern;
    }

    private void
    set_pattern_path (global::Cairo.MeshPattern inPattern, Graphic.Path inPath)
    {
        switch (inPath.data_type)
        {
            case Graphic.Path.DataType.PATH:
                foreach (unowned Object child in inPath)
                {
                    set_pattern_path (inPattern, child as Graphic.Path);
                }
                break;

            case Graphic.Path.DataType.MOVETO:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "move to %g,%g", inPath.points[0].x, inPath.points[0].y);
                inPattern.move_to (inPath.points[0].x, inPath.points[0].y);
                break;

            case Graphic.Path.DataType.LINETO:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "line to %g,%g", inPath.points[0].x, inPath.points[0].y);
                inPattern.line_to (inPath.points[0].x, inPath.points[0].y);
                break;

            case Graphic.Path.DataType.CURVETO:
                Log.audit (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "curve to %g,%g %g,%g %g,%g", inPath.points[0].x, inPath.points[0].y,
                                                                                                     inPath.points[1].x, inPath.points[1].y,
                                                                                                     inPath.points[2].x, inPath.points[2].y);
                inPattern.curve_to (inPath.points[0].x, inPath.points[0].y,
                                    inPath.points[1].x, inPath.points[1].y,
                                    inPath.points[2].x, inPath.points[2].y);
                break;
        }
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

    internal override void
    save () throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.save ();
            status ();
            m_SaveCount++;
        }
        else
        {
            base.save ();
        }
    }

    internal override void
    restore () throws Graphic.Error
    {
        if (m_Context != null)
        {
            if (m_SaveCount > 0)
            {
                m_Context.restore ();
                status ();
                m_SaveCount--;
            }
        }
        else
        {
            base.restore ();
        }
    }

    internal override void
    status () throws Graphic.Error
    {
        if (m_Context != null)
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
                    throw new Graphic.Error.NO_MEMORY (@"$status");
                case global::Cairo.Status.INVALID_RESTORE:
                    throw new Graphic.Error.END_ELEMENT (@"$status");
                case global::Cairo.Status.NO_CURRENT_POINT:
                    throw new Graphic.Error.NO_CURRENT_POINT (@"$status");
                case global::Cairo.Status.INVALID_MATRIX:
                    throw new Graphic.Error.INVALID_MATRIX (@"$status");
                case global::Cairo.Status.NULL_POINTER:
                    throw new Graphic.Error.NULL_POINTER (@"$status");
                case global::Cairo.Status.INVALID_STRING:
                    throw new Graphic.Error.INVALID_STRING (@"$status");
                case global::Cairo.Status.INVALID_PATH_DATA:
                    throw new Graphic.Error.INVALID_PATH (@"$status");
                case global::Cairo.Status.SURFACE_FINISHED:
                    throw new Graphic.Error.SURFACE_FINISHED (@"$status");
                case global::Cairo.Status.SURFACE_TYPE_MISMATCH:
                    throw new Graphic.Error.SURFACE_TYPE_MISMATCH (@"$status");
                case global::Cairo.Status.PATTERN_TYPE_MISMATCH:
                    throw new Graphic.Error.PATTERN_TYPE_MISMATCH (@"$status");
                case global::Cairo.Status.INVALID_CONTENT:
                    throw new Graphic.Error.INVALID_CONTENT (@"$status");
                case global::Cairo.Status.INVALID_FORMAT:
                    throw new Graphic.Error.INVALID_FORMAT (@"$status");
                case global::Cairo.Status.INVALID_VISUAL:
                    throw new Graphic.Error.INVALID_VISUAL (@"$status");
                case global::Cairo.Status.FILE_NOT_FOUND:
                    throw new Graphic.Error.FILE_NOT_FOUND (@"$status");
                case global::Cairo.Status.INVALID_DASH:
                    throw new Graphic.Error.INVALID_DASH (@"$status");
                case global::Cairo.Status.INVALID_DSC_COMMENT:
                    throw new Graphic.Error.INVALID_DSC_COMMENT (@"$status");
                case global::Cairo.Status.INVALID_INDEX:
                    throw new Graphic.Error.INVALID_INDEX (@"$status");
                case global::Cairo.Status.CLIP_NOT_REPRESENTABLE:
                    throw new Graphic.Error.CLIP_NOT_REPRESENTABLE (@"$status");
                case global::Cairo.Status.TEMP_FILE_ERROR:
                    throw new Graphic.Error.TEMP_FILE_ERROR (@"$status");
                case global::Cairo.Status.INVALID_STRIDE:
                    throw new Graphic.Error.INVALID_STRIDE (@"$status");
                case global::Cairo.Status.FONT_TYPE_MISMATCH:
                    throw new Graphic.Error.FONT_TYPE_MISMATCH (@"$status");
                case global::Cairo.Status.USER_FONT_IMMUTABLE:
                    throw new Graphic.Error.FONT_TYPE_MISMATCH (@"$status");
                case global::Cairo.Status.USER_FONT_ERROR:
                    throw new Graphic.Error.USER_FONT_ERROR (@"$status");
                case global::Cairo.Status.NEGATIVE_COUNT:
                    throw new Graphic.Error.NEGATIVE_COUNT (@"$status");
                case global::Cairo.Status.INVALID_CLUSTERS:
                    throw new Graphic.Error.INVALID_CLUSTERS (@"$status");
                case global::Cairo.Status.INVALID_SLANT:
                    throw new Graphic.Error.INVALID_SLANT (@"$status");
                case global::Cairo.Status.INVALID_WEIGHT:
                    throw new Graphic.Error.INVALID_WEIGHT (@"$status");
                case global::Cairo.Status.INVALID_SIZE:
                    throw new Graphic.Error.INVALID_SIZE (@"$status");
                case global::Cairo.Status.USER_FONT_NOT_IMPLEMENTED:
                    throw new Graphic.Error.USER_FONT_NOT_IMPLEMENTED (@"$status");
                case global::Cairo.Status.DEVICE_TYPE_MISMATCH:
                    throw new Graphic.Error.DEVICE_TYPE_MISMATCH (@"$status");
                case global::Cairo.Status.DEVICE_ERROR:
                    throw new Graphic.Error.DEVICE_ERROR (@"$status");
                case global::Cairo.Status.INVALID_MESH_CONSTRUCTION:
                    throw new Graphic.Error.INVALID_MESH_CONSTRUCTION (@"$status");
                case global::Cairo.Status.DEVICE_FINISHED:
                    throw new Graphic.Error.DEVICE_FINISHED (@"$status");
                default:
                    throw new Graphic.Error.UNKNOWN ("a unknown error occured");
            }
        }
        else
        {
            base.status ();
        }
    }

    internal override void
    clip (Graphic.Path inPath) throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.new_path ();
            set_path (inPath);
            m_Context.clip ();
            status ();
        }
        else
        {
            base.clip (inPath);
        }
    }

    internal override void
    clip_region (Graphic.Region inRegion) throws Graphic.Error
    {
        if (m_Context != null)
        {
            foreach (unowned Graphic.Rectangle rect in inRegion)
            {
                // round rect to bounding integer rect
                var pos1 = floor_point (rect.origin.x, rect.origin.y);
                var pos2 = ceil_point (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);

                m_Context.rectangle (pos1.x, pos1.y, pos2.x - pos1.x, pos2.y - pos1.y);
            }
            m_Context.clip ();

            status ();
        }
        else
        {
            base.clip_region (inRegion);
        }
    }

    internal override void
    translate (Graphic.Point inOffset) throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.translate (inOffset.x, inOffset.y);
            status ();
        }
        else
        {
            base.translate (inOffset);
        }
    }

    internal override void
    mask (Graphic.Pattern inPattern) throws Graphic.Error
    {
        if (m_Context != null)
        {
            global::Cairo.Pattern? pattern = pattern_to_cairo (inPattern);
            status ();
            if (pattern != null)
            {
                m_Context.mask (pattern);
                status ();
            }
        }
        else
        {
            base.mask (inPattern);
        }
    }

    internal override void
    paint () throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.paint ();
            status ();
        }
        else
        {
            base.paint ();
        }
    }

    internal override void
    paint_with_alpha (double inAlpha) throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.paint_with_alpha (inAlpha);
            status ();
        }
        else
        {
            base.paint_with_alpha (inAlpha);
        }
    }

    internal override void
    fill (Graphic.Path inPath) throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.new_path ();
            set_path (inPath);
            m_Context.fill ();
            status ();
        }
        else
        {
            base.fill (inPath);
        }
    }

    internal override void
    stroke (Graphic.Path inPath) throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.new_path ();
            set_path (inPath);
            m_Context.stroke ();
            status ();
        }
        else
        {
            base.stroke (inPath);
        }
    }

    internal override void
    render (Graphic.Glyph inGlyph) throws Graphic.Error
    {
        if (m_Context != null)
        {
            m_Context.move_to (inGlyph.origin.x, inGlyph.origin.y);
            status ();
            Pango.cairo_show_layout (m_Context, (inGlyph as Glyph).layout);
            status ();
        }
        else
        {
            render (inGlyph);
        }
    }

    internal override Graphic.Rectangle
    get_path_area (Graphic.Path inPath) throws Graphic.Error
    {
        if (m_Context != null)
        {
            double x1, y1, x2, y2;

            m_Context.new_path ();
            set_path (inPath);
            m_Context.path_extents (out x1, out y1, out x2, out y2);
            status ();
            return Graphic.Rectangle (x1, y1, x2 - x1, y2 - y1);
        }

        return base.get_path_area (inPath);
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * chart.vala
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

public class Maia.Chart : Item
{
    // types
    /**
     * Chart direction
     */
    public enum Direction
    {
        /**
         * Right to left
         */
        RTL,
        /**
         * Left to right
         */
        LTR;

        public string
        to_string ()
        {
            switch (this)
            {
                case RTL:
                    return "right-to-left";

                case LTR:
                    return "left-to-right";
            }

            return "left-to-right";
        }

        public static Direction
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "right-to-left":
                    return RTL;

                case "left-to-right":
                    return LTR;
            }

            return LTR;
        }
    }

    // properties
    private Model          m_Model;
    private Graphic.Range  m_Range;
    private Graphic.Range  m_RangeModel = Graphic.Range (0, 0, 0, 0);
    private Graphic.Path   m_Path = null;
    private Graphic.Path   m_ReversePath = null;

    // accessors
    internal override string tag {
        get {
            return "Chart";
        }
    }

    /**
     * Title of chart
     */
    public string title { get; set; default = ""; }

    /**
     * Alignment of title ``left``, ``center`` or ``right``, default was ``left``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.LEFT; }

    /**
     * Model of chart
     */
    public Model model {
        get {
            return m_Model;
        }
        set {
            if (m_Model != null)
            {
                m_Model.row_added.disconnect (on_model_changed);
                m_Model.row_changed.disconnect (on_model_changed);
                m_Model.row_deleted.disconnect (on_model_changed);

                m_RangeModel = Graphic.Range (0, 0, 0, 0);
                m_Path = null;
                m_ReversePath = null;
            }

            m_Model = value;

            if (m_Model != null)
            {
                on_model_changed (0);

                m_Model.row_added.connect (on_model_changed);
                m_Model.row_changed.connect (on_model_changed);
                m_Model.row_deleted.connect (on_model_changed);
            }
        }
        default = null;
    }

    /**
     * Column name of x axis
     */
    public string x_axis { get; set; default = null; }

    /**
     * Column name of y axis
     */
    public string y_axis { get; set; default = null; }

    /**
     * Range of chart
     */
    public Graphic.Range range {
        get {
            if (m_RangeModel.is_empty () && model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
            {
                m_RangeModel = range_from_model (model, x_axis, y_axis);
            }

            return m_Range.is_empty () ? m_RangeModel : m_Range;
        }
        set {
            m_Range = value;
        }
        default = Graphic.Range (0, 0, 0, 0);
    }

    /**
     * Direction of chart
     */
    public Direction direction { get; set; default = Direction.LTR; }

    /**
     * Chart drawing has been smoothing or not
     */
    public bool smoothing { get; set; default = false; }

    /**
     * Path of chart
     */
    public Graphic.Path path {
        get {
            return m_Path;
        }
    }

    /**
     * Reverse path of chart
     */
    public Graphic.Path reverse_path {
        get {
            return m_ReversePath;
        }
    }

    /**
     * First point of chart
     */
    public Graphic.Point first_point {
        get {
            Graphic.Point ret = Graphic.Point (double.NAN, double.NAN);

            if (model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
            {
                for (int cpt = 0; cpt < model.nb_rows; ++cpt)
                {
                    Graphic.Point point = Graphic.Point ((double)model[x_axis][cpt], (double)model[y_axis][cpt]);
                    if (!point.x.is_nan () && !point.y.is_nan ())
                    {
                        ret = point;
                        break;
                    }
                }
            }

            return ret;
        }
    }

    /**
     * Last point of chart
     */
    public Graphic.Point last_point {
        get {
            Graphic.Point ret = Graphic.Point (double.NAN, double.NAN);

            if (model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
            {
                for (int cpt = (int)model.nb_rows - 1; cpt >= 0; --cpt)
                {
                    Graphic.Point point = Graphic.Point ((double)model[x_axis][cpt], (double)model[y_axis][cpt]);
                    if (!point.x.is_nan () && !point.y.is_nan ())
                    {
                        ret = point;
                        break;
                    }
                }
            }

            return ret;
        }
    }

    // signals
    public signal void changed ();

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Direction), attribute_to_chart_direction);

        GLib.Value.register_transform_func (typeof (Direction), typeof (string), chart_direction_to_string);
    }

    static void
    attribute_to_chart_direction (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Direction.from_string (inAttribute.get ());
    }

    static void
    chart_direction_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Direction)))
    {
        Direction val = (Direction)inSrc;

        outDest = val.to_string ();
    }

    public static Graphic.Range
    range_from_model (Model inModel, string inXColumn, string inYColumn)
        requires (inModel[inXColumn] != null)
        requires (inModel[inYColumn] != null)
    {
        Graphic.Range range = Graphic.Range (0, 0, 0, 0);
        uint nb = inModel.nb_rows;
        if (nb > 0)
        {
            range = Graphic.Range (double.MAX, double.MAX, double.MIN, double.MIN);

            for (uint cpt = 0; cpt < nb; ++cpt)
            {
                var point = Graphic.Point ((double)inModel[inXColumn][cpt], (double)inModel[inYColumn][cpt]);
                if (!point.x.is_nan () && !point.y.is_nan ())
                {
                    range.clamp (point);
                }
            }
        }

        return range;
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("first-point");
        not_dumpable_attributes.insert ("last-point");

        stroke_pattern = new Graphic.Color (0, 0, 0);
    }

    public Chart (string inId, string inTitle)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), title: inTitle);
    }

    private void
    on_model_changed (uint inRow)
    {
        if (area != null && !area.is_empty () && model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
        {
            m_RangeModel = range_from_model (model, x_axis, y_axis);
            m_Path = create_path ();
            m_ReversePath = create_reverse_path ();
            changed ();
        }
    }

    internal Graphic.Transform
    path_transform ()
    {
        Graphic.Transform transform = new Graphic.Transform.identity ();
        Graphic.Size range_size = range.size ();

        double scale_x = area.extents.size.width / range_size.width;
        double scale_y = area.extents.size.height / range_size.height;

        if (direction == Direction.LTR)
        {
            transform.scale (scale_x, -scale_y);
            transform.translate (-range.min.x, -range.max.y);
        }
        else
        {
            transform.scale (-scale_x, -scale_y);
            transform.translate (-range.max.x, -range.max.y);
        }

        return transform;
    }

    private Graphic.Path
    create_path ()
    {
        var path = new Graphic.Path ();

        if (model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
        {
            Graphic.Point? prev = null;

            for (int cpt = 0; cpt < model.nb_rows; ++cpt)
            {
                Graphic.Point point = Graphic.Point ((double)model[x_axis][cpt], (double)model[y_axis][cpt]);

                if (!point.x.is_nan () && !point.y.is_nan ())
                {
                    if (prev == null)
                    {
                        path.move_to (point.x, point.y);
                    }
                    else
                    {
                        if (!smoothing)
                        {
                            path.line_to (point.x, point.y);
                        }
                        else
                        {
                            path.curve_to (prev.x + (point.x - prev.x) / 2.0, prev.y,
                                           prev.x + (point.x - prev.x) / 2.0, point.y,
                                           point.x, point.y);
                        }
                    }

                    prev = point;
                }
            }
        }

        path.transform (path_transform ());

        return path;
    }

    private Graphic.Path
    create_reverse_path ()
    {
        var path = new Graphic.Path ();

        if (model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
        {
            Graphic.Point? prev = null;

            for (int cpt = (int)model.nb_rows - 1; cpt >= 0 ; --cpt)
            {
                Graphic.Point point = Graphic.Point ((double)model[x_axis][cpt], (double)model[y_axis][cpt]);

                if (!point.x.is_nan () && !point.y.is_nan ())
                {
                    if (prev == null)
                    {
                        path.move_to (point.x, point.y);
                    }
                    else
                    {
                        if (!smoothing)
                        {
                            path.line_to (point.x, point.y);
                        }
                        else
                        {
                            path.curve_to (prev.x + (point.x - prev.x) / 2.0, prev.y,
                                           prev.x + (point.x - prev.x) / 2.0, point.y,
                                           point.x, point.y);
                        }
                    }

                    prev = point;
                }
            }
        }

        path.transform (path_transform ());

        return path;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        if (area != null && !area.is_empty () && model != null && x_axis != null && y_axis != null && model[x_axis] != null && model[y_axis] != null)
        {
            m_RangeModel = range_from_model (model, x_axis, y_axis);
            m_Path = create_path ();
            m_ReversePath = create_reverse_path ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        if (m_Path != null)
        {
            inContext.save ();
            {
                inContext.pattern = stroke_pattern;
                inContext.stroke (m_Path);
            }
            inContext.restore ();
        }
    }
}

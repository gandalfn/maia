/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * chart-view.vala
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

public class Maia.ChartView : Group, ItemPackable
{
    // types
    public enum LegendPosition
    {
        NONE,
        NORTH_EST,
        NORTH,
        NORTH_WEST,
        WEST,
        SOUTH_WEST,
        SOUTH,
        SOUTH_EST,
        EST;

        public string
        to_string ()
        {
            switch (this)
            {
                case NORTH_EST:
                    return "north-est";

                case NORTH:
                    return "north";

                case NORTH_WEST:
                    return "north-west";

                case WEST:
                    return "west";

                case SOUTH_WEST:
                    return "south-west";

                case SOUTH:
                    return "south";

                case SOUTH_EST:
                    return "south-est";

                case EST:
                    return "est";
            }

            return "none";
        }

        public static LegendPosition
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "north-est":
                    return NORTH_EST;

                case "north":
                    return NORTH;

                case "north-west":
                    return NORTH_WEST;

                case "west":
                    return WEST;

                case "south-west":
                    return SOUTH_WEST;

                case "south":
                    return SOUTH;

                case "south-est":
                    return SOUTH_EST;

                case "est":
                    return EST;
            }

            return NONE;
        }
    }

    public enum Frame
    {
        NONE,
        IN,
        OUT;

        public string
        to_string ()
        {
            switch (this)
            {
                case IN:
                    return "in";
                case OUT:
                    return "out";
            }

            return "none";
        }

        public static Frame
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "in":
                    return IN;
                case "out":
                    return OUT;
            }

            return NONE;
        }
    }

    private class Legend : Grid
    {
        // properties
        private unowned ChartView m_ChartView;
        private uint m_NbItems = 0;

        // methods
        public Legend (string inId, ChartView inView)
        {
            base (inId);

            m_ChartView = inView;
        }

        public void
        add_chart (Chart inChart)
        {
            // Create chart line path
            Path path = new Path (@"legend-$(inChart.name)-line", "M 0 8 l 16 0");
            inChart.plug_property ("stroke-pattern", path, "stroke-pattern");
            inChart.plug_property ("line-width", path, "line-width");
            inChart.plug_property ("line-type", path, "line-type");
            if (m_NbItems == 0)
            {
                m_ChartView.plug_property ("legend-border", path, "top-padding");
            }
            m_ChartView.plug_property ("legend-border", path, "bottom-padding");
            m_ChartView.plug_property ("legend-border", path, "left-padding");
            m_ChartView.plug_property ("legend-border", path, "right-padding");
            path.size = Graphic.Size (16, 16);
            path.row = m_NbItems;
            path.column = 0;
            path.yfill = false;
            add (path);

            // Create chart legend label
            Label label = new Label (@"legend-$(inChart.name)-label", inChart.title);
            inChart.plug_property ("title", label, "text");
            if (m_NbItems == 0)
            {
                m_ChartView.plug_property ("legend-border", label, "top-padding");
            }
            m_ChartView.plug_property ("font-description", label, "font-description");
            m_ChartView.plug_property ("stroke-pattern", label, "stroke-pattern");
            m_ChartView.plug_property ("legend-border", label, "bottom-padding");
            m_ChartView.plug_property ("legend-border", label, "right-padding");
            label.row = m_NbItems;
            label.column = 1;
            label.alignment = Graphic.Glyph.Alignment.LEFT;
            add (label);

            // Increment the number of chart
            m_NbItems++;
        }

        public void
        add_point (ChartPoint inChartPoint)
        {
            if (inChartPoint.title != null)
            {
                // Create chartpoint path
                Path path = new Path (@"legend-$(inChartPoint.chart)-point-$m_NbItems-path", inChartPoint.path);
                inChartPoint.plug_property ("stroke-pattern", path, "stroke-pattern");
                inChartPoint.plug_property ("fill-pattern", path, "fill-pattern");
                inChartPoint.plug_property ("stroke-width", path, "line-width");
                if (m_NbItems == 0)
                {
                    m_ChartView.plug_property ("legend-border", path, "top-padding");
                }
                m_ChartView.plug_property ("legend-border", path, "bottom-padding");
                m_ChartView.plug_property ("legend-border", path, "left-padding");
                m_ChartView.plug_property ("legend-border", path, "right-padding");
                path.size = Graphic.Size (16, 16);
                path.row = m_NbItems;
                path.column = 0;
                path.yfill = false;
                add (path);

                // Create chartpoint legend label
                Label label = new Label (@"legend-$(inChartPoint.chart)-point-$m_NbItems-path", inChartPoint.title);
                inChartPoint.plug_property ("title", label, "text");
                if (m_NbItems == 0)
                {
                    m_ChartView.plug_property ("legend-border", label, "top-padding");
                }
                m_ChartView.plug_property ("legend-border", label, "bottom-padding");
                m_ChartView.plug_property ("legend-border", label, "right-padding");
                label.row = m_NbItems;
                label.column = 1;
                label.alignment = Graphic.Glyph.Alignment.LEFT;
                add (label);

                // Increment the number of chart
                m_NbItems++;
            }
        }
    }

    // static properties
    private static GLib.Quark s_AxisIndiceQuark;

    // properties
    private Model                     m_Model;
    private string                    m_ChartAxisName;
    private unowned Chart?            m_ChartAxis;
    private unowned Label             m_ZeroLabel;
    private unowned Label             m_XAxisLabel;
    private Core.Array<unowned Label> m_XAxis;
    private unowned Label             m_YAxisLabel;
    private Core.Array<unowned Label> m_YAxis;
    private double                    m_XLabelSize;
    private double                    m_YLabelSize;
    private double                    m_XAxisSize;
    private double                    m_YAxisSize;
    private Graphic.Rectangle         m_DrawingArea = Graphic.Rectangle (0, 0, 0, 0);
    private Graphic.Rectangle         m_ChartArea = Graphic.Rectangle (0, 0, 0, 0);
    private Graphic.Rectangle         m_LegendArea = Graphic.Rectangle (0, 0, 0, 0);
    private unowned Legend?           m_Legend;

    // accessors
    internal override string tag {
        get {
            return "ChartView";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    /**
     * The font description of chart
     */
    public string font_description { get; set; default = "Sans 12"; }

    /**
     * Title of chart view
     */
    public string title { get; set; default = null; }

    /**
     * Model of chart view
     */
    public Model model {
        get {
            return m_Model;
        }
        set {
            m_Model = value;

            foreach (unowned Core.Object child in this)
            {
                unowned Chart? chart = child as Chart;
                if (chart != null)
                {
                    chart.model = m_Model;
                }
            }

            on_axis_changed ();
        }
    }

   /**
     * Chart name to use for draw axis
     */
    public string chart_axis {
        get {
            return m_ChartAxisName;
        }
        set {
            if (m_ChartAxisName != value)
            {
                m_ChartAxisName = value;

                if (m_ChartAxis != null)
                {
                    m_ChartAxis.changed.disconnect (on_chart_changed);
                }

                m_ChartAxis = null;

                if (m_ChartAxisName != null)
                {
                    m_ChartAxis = find (GLib.Quark.from_string (m_ChartAxisName), false) as Chart;
                    if (m_ChartAxis != null)
                    {
                        m_ChartAxis.changed.connect (on_chart_changed);
                    }
                }

                on_axis_changed ();
            }
        }
        default = null;
    }

    /**
     * Border of view
     */
    public double border { get; set; default = 0.0; }

    /**
     * Grid is visible
     */
    public bool grid_visible { get; set; default = true; }

    /**
     * The font description of axis chart
     */
    public string axis_font_description { get; set; default = "Sans 6"; }

    /**
     * Label of x axis
     */
    public string x_axis_label { get; set; default = ""; }

    /**
     * Label of y axis
     */
    public string y_axis_label { get; set; default = ""; }

    /**
     * Unit of x axis
     */
    public string x_axis_unit { get; set; default = ""; }

    /**
     * Unit of y axis
     */
    public string y_axis_unit { get; set; default = ""; }

    /**
     * Max tick on x axis
     */
    public uint x_axis_ticks { get; set; default = 10; }

    /**
     * Max tick on y axis
     */
    public uint y_axis_ticks { get; set; default = 10; }

    /**
     * Size of ticks
     */
    public double tick_size { get; set; default = 5; }

    /**
     * Frame type
     */
    public Frame frame { get; set; default = Frame.NONE; }

    /**
     * Frame stroke color
     */
    public Graphic.Pattern frame_stroke { get; set; default = null; }

    /**
     * Frame fill pattern
     */
    public Graphic.Pattern frame_fill { get; set; default = null; }

    /**
     * Legend position
     */
    public LegendPosition legend { get; set; default = LegendPosition.NONE; }

    /**
     * Border of legend
     */
    public double legend_border { get; set; default = 5.0; }

    private Graphic.Rectangle drawing_area {
        get {
            if (m_DrawingArea.is_empty ())
            {
                m_DrawingArea = m_ChartArea;

                // Calculate area of drawing
                m_DrawingArea.size.resize (-m_YLabelSize, -m_XLabelSize);
                m_DrawingArea.size.resize (-m_YAxisSize, -m_XAxisSize);

                // Calculate position
                if (m_ChartAxis.range.min.y >= 0)
                {
                    m_DrawingArea.origin.x += m_YLabelSize + m_YAxisSize;
                }
            }

            return m_DrawingArea;
        }
    }

    // static methods
    static construct
    {
        s_AxisIndiceQuark = GLib.Quark.from_string ("MaiaChartViewAxisIndice");

        Manifest.Attribute.register_transform_func (typeof (LegendPosition), attribute_to_chart_legend_position);
        Manifest.Attribute.register_transform_func (typeof (Frame), attribute_to_chart_frame);

        GLib.Value.register_transform_func (typeof (LegendPosition), typeof (string), chart_legend_position_to_string);
        GLib.Value.register_transform_func (typeof (Frame), typeof (string), chart_frame_to_string);
    }

    static void
    attribute_to_chart_legend_position (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = LegendPosition.from_string (inAttribute.get ());
    }

    static void
    chart_legend_position_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (LegendPosition)))
    {
        LegendPosition val = (LegendPosition)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_chart_frame (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Frame.from_string (inAttribute.get ());
    }

    static void
    chart_frame_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Frame)))
    {
        Frame val = (Frame)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        stroke_pattern = new Graphic.Color (0, 0, 0);

        // Create array of axis labels
        m_XAxis = new Core.Array<unowned Label> ();
        m_YAxis = new Core.Array<unowned Label> ();

        // Connect onto x axis changed
        notify["x-axis"].connect (on_axis_changed);
        notify["x-axis-label"].connect (on_axis_changed);
        notify["x-axis-unit"].connect (on_axis_changed);

        // Connect onto x axis changed
        notify["y-axis"].connect (on_axis_changed);
        notify["y-axis-label"].connect (on_axis_changed);
        notify["y-axis-unit"].connect (on_axis_changed);

        // Create legend
        var lgd = new Legend ("chart-legend", this);
        lgd.parent = this;
        m_Legend = lgd;
        m_Legend.visible = legend != LegendPosition.NONE;

        // Connect onto legend changed
        notify["legend"].connect (on_legend_changed);

        // Connect onto size to set if size can be dumpable
        notify["size"].connect (on_size_changed);
    }

    public ChartView (string inId, string inTitle)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), title: inTitle);
    }

    private void
    on_size_changed ()
    {
        // Add property in manifest dump if size is not empty
        if (!size.is_empty ())
        {
            not_dumpable_attributes.remove ("size");
        }
        else
        {
            not_dumpable_attributes.insert ("size");
        }
    }

    private void
    on_chart_changed ()
    {
        need_update = true;
        geometry = null;
    }

    private double
    calculate_x_ticks ()
        requires (m_ChartAxis != null)
    {
        double xmin = m_ChartAxis.range.min.x;
        double xmax = m_ChartAxis.range.max.x;
        double amin = xmin, amax = xmax;
        double dx = m_ChartAxis.range.size ().width / (double)x_axis_ticks;
        xmin -= dx;
        xmax += dx;

        if (xmin == 0.0) xmin -= dx;
        if (xmax == 0.0) xmax += dx;

        double pmin = GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(xmin))) - 1.0;
        double pmax = GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(xmax))) - 1.0;

        xmin = GLib.Math.floor (xmin / GLib.Math.pow (10.0, pmin)) * GLib.Math.pow (10.0, pmin);
        xmax = GLib.Math.floor (xmax / GLib.Math.pow (10.0, pmax)) * GLib.Math.pow (10.0, pmax);

        double pstep = GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(dx)));
        double step = dx = GLib.Math.floor (dx / GLib.Math.pow(10.0, pstep)) * GLib.Math.pow(10.0, pstep);

        while (xmin >= amin) xmin -= dx;
        while (xmax <= amax) xmax += dx;

        double inc = GLib.Math.pow (10.0, GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(dx))));
        double mod5 = 5 * GLib.Math.pow (10.0, GLib.Math.floor (GLib.Math.log10 (step)));
        double mod10 = 10 * GLib.Math.pow (10.0, GLib.Math.floor (GLib.Math.log10 (step)));
        while ((step % mod5) != 0 && (step % mod10) != 0)
        {
            step += inc;
        }

        return step;
    }

    private double
    calculate_y_ticks ()
        requires (m_ChartAxis != null)
    {
        double ymin = m_ChartAxis.range.min.y;
        double ymax = m_ChartAxis.range.max.y;
        double amin = ymin, amax = ymax;
        double dy = m_ChartAxis.range.size ().height / (double)y_axis_ticks;
        ymin -= dy;
        ymax += dy;

        if (ymin == 0.0) ymin -= dy;
        if (ymax == 0.0) ymax += dy;

        double pmin = GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(ymin))) - 1.0;
        double pmax = GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(ymax))) - 1.0;

        ymin = GLib.Math.floor (ymin / GLib.Math.pow (10.0, pmin)) * GLib.Math.pow (10.0, pmin);
        ymax = GLib.Math.floor (ymax / GLib.Math.pow (10.0, pmax)) * GLib.Math.pow (10.0, pmax);

        double pstep = GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(dy)));
        double step = dy = GLib.Math.floor (dy / GLib.Math.pow(10.0, pstep)) * GLib.Math.pow(10.0, pstep);

        while (ymin >= amin) ymin -= dy;
        while (ymax <= amax) ymax += dy;

        double inc = GLib.Math.pow (10.0, GLib.Math.floor (GLib.Math.log10 (GLib.Math.fabs(dy))));
        double mod5 = 5 * GLib.Math.pow (10.0, GLib.Math.floor (GLib.Math.log10 (step)));
        double mod10 = 10 * GLib.Math.pow (10.0, GLib.Math.floor (GLib.Math.log10 (step)));
        while ((step % mod5) != 0 && (step % mod10) != 0)
        {
            step += inc;
        }

        return step;
    }

    private string
    format_indice (double inValue, string inUnit, string inPrefix = "")
    {
        string label = "%s%g".printf (inPrefix, inValue);
        if (inUnit == "wd")
        {
            uint all_day = (uint)inValue;
            uint day = all_day % 7;
            uint week = (all_day - day) / 7;
            label = @"$(week)w$(day)d";
        }

        return label;
    }

    private void
    on_legend_changed ()
    {
        m_Legend.visible = legend != LegendPosition.NONE;

        if (m_Legend.visible)
        {
            // clear content
            m_Legend.clear_childs ();

            // Add all chart in legend
            Core.List<unowned Chart> charts = find_by_type<unowned Chart> (false);
            foreach (unowned Chart chart in charts)
            {
                m_Legend.add_chart (chart);
            }

            // Add all chart point in legend
            Core.List<unowned ChartPoint> points = find_by_type<unowned ChartPoint> (false);
            foreach (unowned ChartPoint point in points)
            {
                m_Legend.add_point (point);
            }
        }
    }

    private void
    on_axis_changed ()
    {
        // clear x axis array
        foreach (unowned Label label in m_XAxis)
        {
            label.parent = null;
        }
        m_XAxis.clear ();

        // clear y axis array
        foreach (unowned Label label in m_YAxis)
        {
            label.parent = null;
        }
        m_YAxis.clear ();

        if (m_ChartAxis != null && !m_ChartAxis.range.size ().is_empty ())
        {
            // Create x axis label
            if (x_axis_label != "")
            {
                if (m_XAxisLabel == null)
                {
                    var label = new Label (@"x-axis-label", "");
                    label.xshrink = false;
                    plug_property ("stroke-pattern", label, "stroke-pattern");
                    plug_property ("font-description", label, "font-description");
                    label.parent = this;
                    m_XAxisLabel = label;
                }

                if (x_axis_unit != "")
                {
                    m_XAxisLabel.text = @"$x_axis_label ($x_axis_unit)";
                }
                else
                {
                    m_XAxisLabel.text = @"$x_axis_label";
                }
            }
            else if  (m_XAxisLabel != null)
            {
                m_XAxisLabel.parent = null;
                m_XAxisLabel = null;
            }

            // Create y axis label
            if (y_axis_label != "")
            {
                if (m_YAxisLabel == null)
                {
                    var label = new Label (@"y-axis-label", "");
                    label.xshrink = false;
                    label.transform = new Graphic.Transform.init_rotate (-GLib.Math.PI / 2.0);
                    plug_property ("stroke-pattern", label, "stroke-pattern");
                    plug_property ("font-description", label, "font-description");
                    label.parent = this;
                    m_YAxisLabel = label;
                }

                if (y_axis_unit != "")
                {
                    m_YAxisLabel.text = @"$y_axis_label ($y_axis_unit)";
                }
                else
                {
                    m_YAxisLabel.text = @"$y_axis_label";
                }
            }
            else if  (m_YAxisLabel != null)
            {
                m_YAxisLabel.parent = null;
                m_YAxisLabel = null;
            }

            // Create labels for -x axis
            double step = calculate_x_ticks ();
            int nb = (int)GLib.Math.ceil(m_ChartAxis.range.min.x / step);
            for (int cpt = 1; cpt < nb; ++cpt)
            {
                var label = new Label (@"x-axis-indice-minus-$cpt", format_indice (step * cpt, x_axis_unit, "-"));
                plug_property ("stroke-pattern", label, "stroke-pattern");
                plug_property ("axis-font-description", label, "font-description");
                label.parent = this;
                label.set_qdata<int> (s_AxisIndiceQuark, -(int)(step * cpt * 65535));
                m_XAxis.insert (label);
            }

            // Create labels for +x axis
            nb = (int)GLib.Math.ceil(m_ChartAxis.range.max.x / step);
            for (int cpt = 1; cpt < nb; ++cpt)
            {
                var label = new Label (@"x-axis-indice-plus-$cpt", format_indice (step * cpt, x_axis_unit));
                label.manifest_theme = manifest_theme;
                label.parent = this;
                plug_property ("stroke-pattern", label, "stroke-pattern");
                plug_property ("axis-font-description", label, "font-description");
                label.set_qdata<int> (s_AxisIndiceQuark, (int)(step * cpt * 65535));
                m_XAxis.insert (label);
            }

            // Create labels for -y axis
            step = calculate_y_ticks ();
            nb = (int)GLib.Math.ceil(m_ChartAxis.range.min.y / step);
            for (int cpt = 1; cpt < nb; ++cpt)
            {
                var label = new Label (@"y-axis-indice-minus-$cpt", format_indice (step * cpt, y_axis_unit, "-"));
                plug_property ("stroke-pattern", label, "stroke-pattern");
                plug_property ("axis-font-description", label, "font-description");
                label.parent = this;
                label.set_qdata<int> (s_AxisIndiceQuark, -(int)(step * cpt * 65535));
                m_YAxis.insert (label);
            }

            // Create labels for +y axis
            nb = (int)GLib.Math.ceil(m_ChartAxis.range.max.y / step);
            for (int cpt = 1; cpt < nb; ++cpt)
            {
                var label = new Label (@"y-axis-indice-plus-$cpt", format_indice (step * cpt, y_axis_unit));
                plug_property ("stroke-pattern", label, "stroke-pattern");
                plug_property ("axis-font-description", label, "font-description");
                label.parent = this;
                label.set_qdata<int> (s_AxisIndiceQuark, (int)(step * cpt * 65535));
                m_YAxis.insert (label);
            }

            // Create zero label
            if (m_ChartAxis.range.min.x >= 0 && m_ChartAxis.range.min.y >= 0)
            {
                if (m_ZeroLabel == null)
                {
                    var label = new Label (@"zero-label", "0");
                    plug_property ("stroke-pattern", label, "stroke-pattern");
                    plug_property ("axis-font-description", label, "font-description");
                    label.parent = this;
                    m_ZeroLabel = label;
                }
            }
            else if (m_ZeroLabel != null)
            {
                m_ZeroLabel.parent = null;
                m_ZeroLabel = null;
            }
        }
    }

    internal override void
    clear_childs ()
    {
        if (m_XAxis != null)
        {
            m_XAxis.clear ();
        }

        if (m_YAxis != null)
        {
            m_YAxis.clear ();
        }

        m_ChartAxis = null;
        m_ZeroLabel = null;
        m_XAxisLabel = null;
        m_YAxisLabel = null;
        m_Legend = null;

        base.clear_childs ();

        if (ref_count > 0)
        {
            // Create legend
            var lgd = new Legend ("chart-legend", this);
            lgd.parent = this;
            m_Legend = lgd;
            m_Legend.visible = legend != LegendPosition.NONE;

            on_axis_changed ();
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Chart || inObject is Label || inObject is ChartIntersect || inObject is ChartPoint || inObject is Legend;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        unowned Chart? chart = inObject as Chart;
        unowned ChartPoint? point = inObject as ChartPoint;

        if (chart != null)
        {
            if (chart.model == null && model != null)
            {
                chart.model = model;
            }

            on_legend_changed ();

            if (m_ChartAxis == null && m_ChartAxisName != null && m_ChartAxisName == chart.name)
            {
                m_ChartAxis = chart;
                m_ChartAxis.changed.connect (on_chart_changed);
                on_axis_changed ();
            }
        }
        else if (point != null)
        {
            on_legend_changed ();
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        unowned Chart? chart = inObject as Chart;
        unowned ChartPoint? point = inObject as ChartPoint;

        if (chart != null)
        {
            if (m_ChartAxis != null && m_ChartAxisName == chart.name)
            {
                m_ChartAxis.changed.disconnect (on_chart_changed);
                m_ChartAxis = null;
                on_axis_changed ();
            }
        }

        base.remove_child (inObject);

        if (chart != null || point != null)
        {
            on_legend_changed ();
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            m_ChartArea = area.extents;
            m_ChartArea.origin.translate (Graphic.Point (border, border));
            m_ChartArea.size.resize (-border * 2.0, -border * 2.0);
            m_DrawingArea = Graphic.Rectangle (0, 0, 0, 0);
            m_LegendArea = Graphic.Rectangle (0, 0, 0, 0);

            if (m_ChartAxis != null && !m_ChartAxis.range.size ().is_empty ())
            {
                // calculate the area of legend
                if (m_Legend.visible)
                {
                    var legend_size = m_Legend.size;
                    m_LegendArea = Graphic.Rectangle (m_ChartArea.origin.x, m_ChartArea.origin.y, legend_size.width, legend_size.height);

                    switch (legend)
                    {
                        case LegendPosition.NORTH_EST:
                            m_ChartArea.origin.x += m_LegendArea.size.width;
                            m_ChartArea.origin.y += m_LegendArea.size.height;
                            m_ChartArea.size.width -= m_LegendArea.size.width;
                            m_ChartArea.size.height -= m_LegendArea.size.height;
                            break;

                        case LegendPosition.NORTH:
                            m_LegendArea.origin.x += (m_ChartArea.size.width - m_LegendArea.size.width) / 2.0;
                            m_ChartArea.origin.y += m_LegendArea.size.height;
                            m_ChartArea.size.height -= m_LegendArea.size.height;
                            break;

                        case LegendPosition.NORTH_WEST:
                            m_LegendArea.origin.x += m_ChartArea.size.width - m_LegendArea.size.width;
                            m_ChartArea.origin.y += m_LegendArea.size.height;
                            m_ChartArea.size.width -= m_LegendArea.size.width;
                            m_ChartArea.size.height -= m_LegendArea.size.height;
                            break;

                        case LegendPosition.WEST:
                            m_LegendArea.origin.x += m_ChartArea.size.width - m_LegendArea.size.width;
                            m_LegendArea.origin.y += (m_ChartArea.size.height - m_LegendArea.size.height) / 2.0;
                            m_ChartArea.size.width -= m_LegendArea.size.width;
                            break;

                        case LegendPosition.SOUTH_WEST:
                            m_LegendArea.origin.x += m_ChartArea.size.width - m_LegendArea.size.width;
                            m_LegendArea.origin.y += m_ChartArea.size.height - m_LegendArea.size.height;
                            m_ChartArea.size.width -= m_LegendArea.size.width;
                            m_ChartArea.size.height -= m_LegendArea.size.height;
                            break;

                        case LegendPosition.SOUTH:
                            m_LegendArea.origin.y += m_ChartArea.size.height - m_LegendArea.size.height;
                            m_ChartArea.size.height -= m_LegendArea.size.height;
                            break;

                        case LegendPosition.SOUTH_EST:
                            m_LegendArea.origin.y += m_ChartArea.size.height - m_LegendArea.size.height;
                            m_ChartArea.origin.x += m_LegendArea.size.width;
                            m_ChartArea.size.width -= m_LegendArea.size.width;
                            m_ChartArea.size.height -= m_LegendArea.size.height;
                            break;

                        case LegendPosition.EST:
                            m_ChartArea.origin.x += m_LegendArea.size.width;
                            m_ChartArea.size.width -= m_LegendArea.size.width;
                            break;
                    }
                }


                // offset charts to axislabel
                m_YLabelSize = 0.0;
                if (m_YAxisLabel != null)
                {
                    var label_size = m_YAxisLabel.size;
                    var label_allocation = Graphic.Rectangle (m_ChartArea.origin.x, m_ChartArea.origin.y + ((m_ChartArea.size.height - label_size.height) / 2.0),
                                                              label_size.width, label_size.height);

                    if (m_ChartAxis.range.min.x >= 0)
                    {
                        m_YLabelSize += label_allocation.size.width;
                    }

                    m_YAxisLabel.update (inContext, new Graphic.Region (label_allocation));
                }

                m_XLabelSize = 0.0;
                if (m_XAxisLabel != null)
                {
                    var label_size = m_XAxisLabel.size;
                    var label_allocation = Graphic.Rectangle (m_ChartArea.origin.x + ((m_ChartArea.size.width - label_size.width) / 2.0),
                                                              m_ChartArea.origin.y + m_ChartArea.size.height - label_size.height,
                                                              label_size.width, label_size.height);

                    if (m_ChartAxis.range.min.y >= 0)
                    {
                        m_XLabelSize += label_allocation.size.height;
                    }

                    m_XAxisLabel.update (inContext, new Graphic.Region (label_allocation));
                }

                // Calculate the size of axis labels
                m_YAxisSize = 0.0;
                m_XAxisSize = 0.0;
                if (m_ChartAxis.range.min.y >= 0)
                {
                    foreach (unowned Label label in m_XAxis)
                    {
                        m_XAxisSize = double.max (m_XAxisSize, label.size.height);
                    }
                    m_XAxisSize += tick_size;
                }
                if (m_ChartAxis.range.min.x >= 0)
                {
                    foreach (unowned Label label in m_YAxis)
                    {
                        m_YAxisSize = double.max (m_YAxisSize, label.size.width);
                    }
                    m_YAxisSize += tick_size;
                }

                // Calculate transform area of charts
                var area_transform = new Graphic.Transform.identity ();
                area_transform.translate (drawing_area.origin.x, drawing_area.origin.y);

                if (m_ChartAxis.direction == Chart.Direction.LTR)
                {
                    area_transform.scale (drawing_area.size.width / m_ChartAxis.range.size ().width, -(drawing_area.size.height / m_ChartAxis.range.size ().height));
                    area_transform.translate (-m_ChartAxis.range.min.x, -m_ChartAxis.range.max.y);
                }
                else
                {
                    area_transform.scale (-(drawing_area.size.width / m_ChartAxis.range.size ().width), -(drawing_area.size.height / m_ChartAxis.range.size ().height));
                    area_transform.translate (-m_ChartAxis.range.max.x, -m_ChartAxis.range.max.y);
                }

                // calculate pos of origin
                var origin = Graphic.Point (0, 0);
                origin.transform (area_transform);

                // Update each x axis label
                foreach (unowned Label label in m_XAxis)
                {
                    Graphic.Point label_position = Graphic.Point ((double)label.get_qdata<int> (s_AxisIndiceQuark) / 65535.0, 0);
                    label_position.transform (area_transform);
                    var label_size = label.size;
                    label_position.x -= label_size.width / 2.0;
                    label_position.y = origin.y + tick_size;

                    label.update (inContext, new Graphic.Region (Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height)));
                }

                // Update each y axis label
                foreach (unowned Label label in m_YAxis)
                {
                    Graphic.Point label_position = Graphic.Point (0, (double)label.get_qdata<int> (s_AxisIndiceQuark) / 65535.0);
                    label_position.transform (area_transform);
                    var label_size = label.size;
                    label_position.x = origin.x - label_size.width - tick_size;
                    label_position.y -= label_size.height / 2.0;

                    label.update (inContext, new Graphic.Region (Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height)));
                }

                // Update position zero label
                if (m_ZeroLabel != null)
                {
                    Graphic.Point label_position = origin;
                    var label_size = m_ZeroLabel.size;
                    label_position.x = origin.x - label_size.width - tick_size;
                    label_position.y = origin.y + tick_size;

                    m_ZeroLabel.update (inContext, new Graphic.Region (Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height)));
                }

                // update legend
                if (m_Legend.visible)
                {
                    m_Legend.update (inContext, new Graphic.Region (m_LegendArea));
                }

                // Update all charts
                foreach (unowned Core.Object child in this)
                {
                    unowned Chart? chart = child as Chart;

                    if (chart != null)
                    {
                        chart.update (inContext, new Graphic.Region (drawing_area));
                    }
                }
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        if (m_ChartAxis != null && !m_ChartAxis.range.size ().is_empty ())
        {
            // Calculate transform area of charts
            var area_transform = new Graphic.Transform.identity ();
            area_transform.translate (drawing_area.origin.x, drawing_area.origin.y);

            if (m_ChartAxis.direction == Chart.Direction.LTR)
            {
                area_transform.scale (drawing_area.size.width / m_ChartAxis.range.size ().width, -(drawing_area.size.height / m_ChartAxis.range.size ().height));
                area_transform.translate (-m_ChartAxis.range.min.x, -m_ChartAxis.range.max.y);
            }
            else
            {
                area_transform.scale (-(drawing_area.size.width / m_ChartAxis.range.size ().width), -(drawing_area.size.height / m_ChartAxis.range.size ().height));
                area_transform.translate (-m_ChartAxis.range.max.x, -m_ChartAxis.range.max.y);
            }

            // calculate pos of origin
            var origin = Graphic.Point (0, 0);
            origin.transform (area_transform);

            // Create grid and ticks path
            var grid_path = new Graphic.Path ();
            var ticks_path = new Graphic.Path ();
            foreach (unowned Label label in m_XAxis)
            {
                Graphic.Point tick_position = Graphic.Point ((double)label.get_qdata<int> (s_AxisIndiceQuark) / 65535.0, 0);
                tick_position.transform (area_transform);

                grid_path.move_to (tick_position.x, drawing_area.origin.y);
                grid_path.rel_line_to (0, drawing_area.size.height);

                ticks_path.move_to (tick_position.x, origin.y - (tick_size / 2.0));
                ticks_path.rel_line_to (0, tick_size);
            }
            foreach (unowned Label label in m_YAxis)
            {
                Graphic.Point tick_position = Graphic.Point (0, (double)label.get_qdata<int> (s_AxisIndiceQuark) / 65535.0);
                tick_position.transform (area_transform);

                grid_path.move_to (drawing_area.origin.x, tick_position.y);
                grid_path.rel_line_to (drawing_area.size.width, 0);

                ticks_path.move_to (origin.x - (tick_size / 2.0), tick_position.y);
                ticks_path.rel_line_to (tick_size, 0);
            }

            // Create axis path
            var x_axis_path = new Graphic.Path ();
            x_axis_path.move_to (drawing_area.origin.x, origin.y);
            x_axis_path.rel_line_to (drawing_area.size.width, 0);

            var y_axis_path = new Graphic.Path ();
            y_axis_path.move_to (origin.x, drawing_area.origin.y);
            y_axis_path.rel_line_to (0, drawing_area.size.height);

            // Draw frame
            switch (frame)
            {
                case Frame.IN:
                    var shadow_area = drawing_area;
                    shadow_area.resize (Graphic.Size (-line_width, -line_width));

                    var frame_path = new Graphic.Path.from_rectangle (shadow_area);
                    if (frame_stroke != null)
                    {
                        inContext.pattern = frame_stroke;
                        inContext.stroke (frame_path);
                    }
                    if (frame_fill != null)
                    {
                        inContext.pattern = frame_fill;
                        inContext.fill (new Graphic.Path.from_rectangle (shadow_area));
                    }
                    break;

                case Frame.OUT:
                    var shadow_area = drawing_area;
                    shadow_area.resize (Graphic.Size (-line_width * 2, -line_width * 2));
                    shadow_area.translate (Graphic.Point (line_width, line_width));

                    var frame_path = new Graphic.Path.from_rectangle (shadow_area);
                    if (frame_stroke != null)
                    {
                        inContext.pattern = frame_stroke;
                        inContext.stroke (frame_path);
                    }
                    if (frame_fill != null)
                    {
                        inContext.pattern = frame_fill;
                        inContext.fill (new Graphic.Path.from_rectangle (shadow_area));
                    }
                    break;
            }

            inContext.pattern = stroke_pattern;

            // Draw grid
            if (grid_visible)
            {
                inContext.line_width = line_width / 2.0;
                inContext.dash = Graphic.LineType.DOT.to_dash (line_width);
                inContext.stroke (grid_path);
            }

            // Draw axis
            inContext.line_width = line_width;
            inContext.dash = Graphic.LineType.CONTINUE.to_dash (line_width);
            inContext.stroke (x_axis_path);
            inContext.stroke (y_axis_path);

            // Draw ticks
            inContext.stroke (ticks_path);


        }

        // Paint intersect
        Core.List<unowned ChartIntersect> intersects = find_by_type<unowned ChartIntersect> (false);
        foreach (unowned ChartIntersect intersect in intersects)
        {
            if (intersect.first_chart != "" && intersect.second_chart != "")
            {
                // Get charts
                unowned Chart? first = find (GLib.Quark.from_string (intersect.first_chart), false) as Chart;
                unowned Chart? second = find (GLib.Quark.from_string (intersect.second_chart), false) as Chart;

                if (first != null && second != null)
                {
                    // Get first point of first chart
                    var point1 = first.first_point;
                    // Get last point of second chart
                    var point2 = second.last_point;

                    // Draw intersect area
                    if (!point1.x.is_nan () && !point1.y.is_nan () && !point2.x.is_nan () && !point2.y.is_nan ())
                    {
                        // transform point to chart transform
                        point1.transform (first.path_transform ());
                        point2.transform (second.path_transform ());

                        // create path of intersect fill
                        var path = new Graphic.Path ();
                        path.add (first.path);
                        path.line_to (point2.x, point2.y);
                        path.add (second.reverse_path);
                        path.line_to (point1.x, point1.y);

                        // paint intersect
                        inContext.save ();
                        {
                            inContext.translate (drawing_area.origin);
                            inContext.pattern = intersect.fill_pattern;
                            inContext.fill (path);
                        }
                        inContext.restore ();
                    }
                }
            }
        }

        // Paint point position
        Core.List<unowned ChartPoint> points = find_by_type<unowned ChartPoint> (false);
        foreach (unowned ChartPoint point in points)
        {
            if (point.chart != null)
            {
                unowned Chart? chart = find (GLib.Quark.from_string (point.chart), false) as Chart;

                if (chart != null)
                {
                    var point_position = point.position;
                    if (!point_position.x.is_nan () && !point_position.y.is_nan ())
                    {
                        var origin = Graphic.Point (0, 0);
                        origin.transform (chart.path_transform ());
                        point_position.transform (chart.path_transform ());

                        // create point position path
                        var path = new Graphic.Path ();
                        path.move_to (point_position.x, point_position.y);
                        path.line_to (origin.x, point_position.y);
                        path.move_to (point_position.x, point_position.y);
                        path.line_to (point_position.x, origin.y);

                        // paint point position
                        inContext.save ();
                        {
                            inContext.dash = point.line_type.to_dash (line_width);
                            inContext.pattern = point.stroke_pattern;
                            inContext.translate (drawing_area.origin);
                            inContext.line_width = line_width / 2.0;
                            inContext.stroke (path);
                            inContext.dash = Graphic.LineType.CONTINUE.to_dash (line_width);
                            inContext.line_width = line_width;
                        }
                        inContext.restore ();
                    }
                }
            }
        }

        // paint childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Drawable)
            {
                unowned Drawable drawable = (Drawable)child;

                var area = area_to_child_item_space (drawable, inArea);

                drawable.draw (inContext, area);
            }
        }

        // Paint points
        foreach (unowned ChartPoint point in points)
        {
            if (point.chart != null)
            {
                unowned Chart? chart = find (GLib.Quark.from_string (point.chart), false) as Chart;

                if (chart != null)
                {
                    var point_position = point.position;
                    if (!point_position.x.is_nan () && !point_position.y.is_nan ())
                    {
                        point_position.transform (chart.path_transform ());

                        var path = new Graphic.Path.from_data (point.path);
                        var path_area = inContext.get_path_area (path);
                        double scale_x = point.size.width / path_area.size.width;
                        double scale_y = point.size.height / path_area.size.height;
                        path.transform (new Graphic.Transform.init_scale (scale_x, scale_y));

                        // paint point position
                        inContext.save ();
                        {
                            inContext.translate (drawing_area.origin);
                            inContext.translate (point_position);
                            inContext.translate (Graphic.Point (-(path_area.size.width * scale_x) / 2.0,
                                                                -(path_area.size.height * scale_y) / 2.0));
                            if (point.fill_pattern != null)
                            {
                                inContext.pattern = point.fill_pattern;
                                inContext.fill (path);
                            }
                            else if (point.stroke_pattern != null)
                            {
                                inContext.line_width = point.stroke_width;
                                inContext.pattern = point.stroke_pattern;
                                inContext.stroke (path);
                            }
                        }
                        inContext.restore ();
                    }
                }
            }
        }
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        // dump theme if any
        bool theme_dump = manifest_theme != null && !manifest_theme.get_qdata<bool> (Item.s_ThemeDumpQuark) && (parent == null || (parent as Manifest.Element).manifest_theme != manifest_theme);
        if (theme_dump)
        {
            ret += inPrefix + manifest_theme.dump (inPrefix) + "\n";
            manifest_theme.set_qdata<bool> (Item.s_ThemeDumpQuark, theme_dump);
        }

        // dump shortcuts and toolbox
        foreach (unowned Core.Object child in this)
        {
            if (child is Chart || child is ChartPoint || child is ChartIntersect)
            {
                ret += inPrefix + (child as Manifest.Element).dump (inPrefix) + "\n";
            }
        }

        if (theme_dump)
        {
            manifest_theme.set_qdata<bool> (Item.s_ThemeDumpQuark, false);
        }

        return ret;
    }
}

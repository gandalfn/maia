/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * scale-bar.vala
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

public class Maia.ScaleBar : Group, ItemPackable, ItemMovable
{
    // types
    public enum Placement
    {
        TOP,
        BOTTOM,
        LEFT,
        RIGHT;

        public string
        to_string ()
        {
            switch (this)
            {
                case TOP:
                    return "top";
                case BOTTOM:
                    return "bottom";
                case LEFT:
                    return "left";
                case RIGHT:
                    return "right";
            }

            return "";
        }

        public static Placement
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "top":
                    return TOP;
                case "bottom":
                    return BOTTOM;
                case "left":
                    return LEFT;
                case "right":
                    return RIGHT;
            }

            return TOP;
        }
    }

    // properties
    private Adjustment?               m_Adjustment = null;
    private unowned Label             m_SliderLabelLower = null;
    private unowned Label             m_SliderLabelUpper = null;
    private Core.Array<unowned Label> m_StepLabels = null;

    // accessors
    internal override string tag {
        get {
            return "ScaleBar";
        }
    }

    internal override bool can_focus { get; set; default = true; }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = true; }
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

    public Adjustment? adjustment {
        get {
            return m_Adjustment;
        }
        set {
            if (m_Adjustment != null)
            {
                m_Adjustment.notify["value"].disconnect (on_adjustment_value_changed);
                m_Adjustment.notify["lower"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["upper"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["page-size"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["step"].disconnect (on_adjustment_changed);
            }
            m_Adjustment = value;
            if (m_Adjustment != null)
            {
                m_Adjustment.notify["value"].connect (on_adjustment_value_changed);
                m_Adjustment.notify["lower"].connect (on_adjustment_changed);
                m_Adjustment.notify["upper"].connect (on_adjustment_changed);
                m_Adjustment.notify["page-size"].connect (on_adjustment_changed);
                m_Adjustment.notify["step"].connect (on_adjustment_changed);
            }
            on_adjustment_changed ();
        }
    }

    public Placement       placement             { get; set; default = Placement.RIGHT; }
    public string          font_description      { get; set; default = "Sans 8"; }
    public string          step_font_description { get; set; default = "Sans 8"; }
    public bool            display_slide_label   { get; set; default = true; }
    public double          label_border          { get; set; default = 2.0; }
    public Graphic.Pattern label_stroke_pattern  { get; set; default = new Graphic.Color (0, 0, 0); }
    public double          step_line_width       { get; set; default = 1.0; }
    public Graphic.Pattern step_stroke_pattern   { get; set; default = new Graphic.Color (0, 0, 0); }
    public bool            display_step_label    { get; set; default = true; }
    public bool            display_step_middle   { get; set; default = false; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Placement), attribute_to_scale_placement);

        GLib.Value.register_transform_func (typeof (Placement), typeof (string), scale_placement_to_string);
    }

    static void
    attribute_to_scale_placement (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Placement.from_string (inAttribute.get ());
    }

    static void
    scale_placement_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Placement)))
    {
        Placement val = (Placement)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("adjustment");

        // Create array label
        m_StepLabels = new Core.Array<unowned Label> ();

        // Default colors
        stroke_pattern     = new Graphic.Color (0, 0, 0);
        fill_pattern       = new Graphic.Color (0, 0, 0, 0.6);

        // connect onto font-description changed
        notify["step-font-description"].connect (on_adjustment_changed);
        notify["font-description"].connect (on_adjustment_changed);
        // connect onto slider width changed
        notify["slider-width"].connect (on_adjustment_changed);
        // connect onto placement changed
        notify["placement"].connect (on_adjustment_changed);

        notify["display-slide-label"].connect (on_adjustment_changed);
        notify["display-step-label"].connect (on_adjustment_changed);
    }

    public ScaleBar (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_adjustment_value_changed ()
    {
        if (display_slide_label)
        {
            // Add label for slider
            add_slider_label ();
        }

        damage.post ();
    }

    private void
    on_adjustment_changed ()
    {
        // Clear all childs
        clear_childs ();

        if (display_slide_label)
        {
            // Add label for slider
            add_slider_label ();
        }

        if (display_step_label)
        {
            // Add label foreach step
            add_step_labels ();
        }
    }

    private void
    add_slider_label ()
    {
        m_SliderLabelLower = null;
        m_SliderLabelUpper = null;

        if (adjustment != null && adjustment.page_size > 0)
        {
            var item_size = size;

            double upper = 0;
            double lower = 0;
            double val = adjustment.@value;

            if (val - (adjustment.page_size / 2) < adjustment.lower)
                val = adjustment.lower + (adjustment.page_size / 2);
            if (val + (adjustment.page_size / 2) > adjustment.upper)
                val = adjustment.upper - (adjustment.page_size / 2);

            lower = double.max (adjustment.lower, val - (adjustment.page_size / 2));
            upper = double.min (adjustment.upper, val + (adjustment.page_size / 2));

            double val_lower = (adjustment.upper - adjustment.lower) == 0 ? 0 : (lower - adjustment.lower) / (adjustment.upper - adjustment.lower);
            double val_upper = (adjustment.upper - adjustment.lower) == 0 ? 0 : (upper - adjustment.lower) / (adjustment.upper - adjustment.lower);

            var label_lower = new Label (@"$name-slider-lower", @"$lower");
            plug_property ("font-description", label_lower, "font-description");
            plug_property ("label-stroke-pattern", label_lower, "stroke-pattern");
            var label_lower_size = label_lower.size;

            var label_upper = new Label (@"$name-slider-upper", @"$upper");
            plug_property ("font-description", label_upper, "font-description");
            plug_property ("label-stroke-pattern", label_upper, "stroke-pattern");
            var label_upper_size = label_upper.size;

            switch (placement)
            {
                case Placement.TOP:
                    if ((item_size.width * val_lower) - label_lower_size.width - label_border >= 0)
                    {
                        label_lower.position = Graphic.Point ((item_size.width * val_lower) - label_lower_size.width - label_border, 0);

                        m_SliderLabelLower = label_lower;
                        add (label_lower);
                    }
                    if ((item_size.width * val_upper) + label_upper_size.width + label_border <= item_size.width)
                    {
                        label_upper.position = Graphic.Point ((item_size.width * val_upper) + label_upper_size.width + label_border, 0);

                        m_SliderLabelUpper = label_upper;
                        add (label_upper);
                    }
                    break;

                case Placement.BOTTOM:
                    if ((item_size.width * val_lower) - label_lower_size.width - label_border >= 0)
                    {
                        label_lower.position = Graphic.Point ((item_size.width * val_lower) - label_lower_size.width - label_border,
                                                              item_size.height - label_upper_size.height);

                        m_SliderLabelLower = label_lower;
                        add (label_lower);
                    }
                    if ((item_size.width * val_upper) + label_upper_size.width + label_border <= item_size.width)
                    {
                        label_upper.position = Graphic.Point ((item_size.width * val_upper) + label_border,
                                                              item_size.height - label_upper_size.height);

                        m_SliderLabelUpper = label_upper;
                        add (label_upper);
                    }
                    break;

                case Placement.LEFT:
                    if ((item_size.height * val_lower) - label_lower_size.height - label_border >= 0)
                    {
                        label_lower.position = Graphic.Point (0, (item_size.height * val_lower) - label_lower_size.height - label_border);

                        m_SliderLabelLower = label_lower;
                        add (label_lower);
                    }
                    if ((item_size.height * val_upper) + label_upper_size.height + label_border <= item_size.height)
                    {
                        label_upper.position = Graphic.Point (0, (item_size.height * val_upper) + label_border);

                        m_SliderLabelUpper = label_upper;
                        add (label_upper);
                    }
                    break;

                case Placement.RIGHT:
                    if ((item_size.height * val_lower) - label_lower_size.height - label_border >= 0)
                    {
                        label_lower.position = Graphic.Point (item_size.width - label_lower_size.width,
                                                              (item_size.height * val_lower) - label_lower_size.height - label_border);

                        m_SliderLabelLower = label_lower;
                        add (label_lower);
                    }
                    if ((item_size.height * val_upper) + label_upper_size.height + label_border <= item_size.height)
                    {
                        label_upper.position = Graphic.Point (item_size.width - label_upper_size.width,
                                                             (item_size.height * val_upper) + label_border);

                        m_SliderLabelUpper = label_upper;
                        add (label_upper);
                    }
                    break;
            }
        }
    }

    private void
    add_step_labels ()
    {
        m_StepLabels.clear ();

        if (adjustment != null && (adjustment.upper - adjustment.lower) > 0 && adjustment.step > 0)
        {
            int cpt = 0;
            var item_size = size;

            for (double step = adjustment.step; step < (adjustment.upper - adjustment.lower); step += adjustment.step, ++cpt)
            {
                double step_pos = (step - adjustment.lower) / (adjustment.upper - adjustment.lower);

                var label = new Label (@"$name-step-$cpt", @"$step");
                plug_property ("step-font-description", label, "font-description");
                plug_property ("step-stroke-pattern", label, "stroke-pattern");
                var label_size = label.size;

                switch (placement)
                {
                    case Placement.TOP:
                        if ((item_size.width * step_pos) - label_size.width - label_border >= 0)
                        {
                            label.position = Graphic.Point ((item_size.width * step_pos) - label_size.width - label_border,
                                                            (item_size.height / 2) - label_size.height - label_border);

                            m_StepLabels.insert (label);
                            add (label);
                        }
                        break;

                    case Placement.BOTTOM:
                        if ((item_size.width * step_pos) - label_size.width - label_border >= 0)
                        {
                            label.position = Graphic.Point ((item_size.width * step_pos) - label_size.width - label_border,
                                                            (item_size.height / 2) + label_border);

                            m_StepLabels.insert (label);
                            add (label);
                        }
                        break;

                    case Placement.LEFT:
                        if ((item_size.height * step_pos) - label_size.height - label_border >= 0)
                        {
                            label.position = Graphic.Point ((item_size.width / 2) + label_border,
                                                            (item_size.height * step_pos) - label_size.height - label_border);

                            m_StepLabels.insert (label);
                            add (label);
                        }
                        break;

                    case Placement.RIGHT:
                        if ((item_size.height * step_pos) - label_size.height - label_border >= 0)
                        {
                            label.position = Graphic.Point ((item_size.width / 2) - label_size.width - label_border,
                                                            (item_size.height * step_pos) - label_size.height - label_border);

                            m_StepLabels.insert (label);
                            add (label);
                        }
                        break;
                }
            }
        }
    }

    private Graphic.Path
    get_slider_path ()
    {
        Graphic.Path path = new Graphic.Path ();
        if (adjustment != null && adjustment.page_size > 0)
        {
            double upper = 0;
            double lower = 0;
            double val = adjustment.@value;

            if (val - (adjustment.page_size / 2) < adjustment.lower)
                val = adjustment.lower + (adjustment.page_size / 2);
            if (val + (adjustment.page_size / 2) > adjustment.upper)
                val = adjustment.upper - (adjustment.page_size / 2);

            lower = double.max (adjustment.lower, val - (adjustment.page_size / 2));
            upper = double.min (adjustment.upper, val + (adjustment.page_size / 2));

            double val_lower = (adjustment.upper - adjustment.lower) == 0 ? 0 : (lower - adjustment.lower) / (adjustment.upper - adjustment.lower);
            double val_upper = (adjustment.upper - adjustment.lower) == 0 ? 0 : (upper - adjustment.lower) / (adjustment.upper - adjustment.lower);

            var item_area = area;
            switch (placement)
            {
                case Placement.TOP:
                    double slide_pos = 0;
                    double slide_height = item_area.extents.size.height / 3;
                    path.rectangle (item_area.extents.size.width * val_lower, slide_pos,
                                    (item_area.extents.size.width * val_upper) - (item_area.extents.size.width * val_lower), slide_height);
                    break;

                case Placement.BOTTOM:
                    double slide_pos = 2 * (item_area.extents.size.height / 3);
                    double slide_height = item_area.extents.size.height / 3;
                    path.rectangle (item_area.extents.size.width * val_lower, slide_pos,
                                    (item_area.extents.size.width * val_upper) - (item_area.extents.size.width * val_lower), slide_height);
                    break;

                case Placement.LEFT:
                    double slide_pos = 0;
                    double slide_width = item_area.extents.size.width / 3;
                    path.rectangle (slide_pos, item_area.extents.size.height * val_lower,
                                    slide_width, (item_area.extents.size.height * val_upper) - (item_area.extents.size.height * val_lower));
                    break;

                case Placement.RIGHT:
                    double slide_pos = 2 * (item_area.extents.size.width / 3);
                    double slide_width = item_area.extents.size.width / 3;
                    path.rectangle (slide_pos, item_area.extents.size.height * val_lower,
                                    slide_width, (item_area.extents.size.height * val_upper) - (item_area.extents.size.height * val_lower));
                    break;

            }
        }

        return path;
    }

    private Graphic.Path
    get_scale_path ()
    {
        Graphic.Path path = new Graphic.Path ();

        if (adjustment != null && (adjustment.upper - adjustment.lower) > 0)
        {
            switch (placement)
            {
                case Placement.TOP:
                case Placement.BOTTOM:
                    path.move_to (0, area.extents.size.height / 2);
                    path.line_to (area.extents.size.width, area.extents.size.height  / 2);
                    break;

                case Placement.RIGHT:
                case Placement.LEFT:
                    path.move_to (area.extents.size.width / 2, 0);
                    path.line_to (area.extents.size.width / 2, area.extents.size.height);
                    break;
            }
        }

        return path;
    }

    private Graphic.Path
    get_step_path ()
    {
        Graphic.Path path = new Graphic.Path ();

        if (adjustment != null && (adjustment.upper - adjustment.lower) > 0 && adjustment.step > 0)
        {
            for (double step = adjustment.step; step < (adjustment.upper - adjustment.lower); step += adjustment.step)
            {
                double step_pos = (step - adjustment.lower) / (adjustment.upper - adjustment.lower);

                switch (placement)
                {
                    case Placement.TOP:
                        path.move_to (area.extents.size.width * step_pos, 0);
                        path.line_to (area.extents.size.width * step_pos, area.extents.size.height / 2);
                        break;

                    case Placement.BOTTOM:
                        path.move_to (area.extents.size.width * step_pos, area.extents.size.height / 2);
                        path.line_to (area.extents.size.width * step_pos, area.extents.size.height);
                        break;

                    case Placement.LEFT:
                        path.move_to (area.extents.size.width / 2, area.extents.size.height * step_pos);
                        path.line_to (area.extents.size.width, area.extents.size.height * step_pos);
                        break;

                    case Placement.RIGHT:
                        path.move_to (0, area.extents.size.height * step_pos);
                        path.line_to (area.extents.size.width / 2, area.extents.size.height * step_pos);
                        break;
                }
            }
        }

        return path;
    }

    private Graphic.Path
    get_step_middle_path ()
    {
        Graphic.Path path = new Graphic.Path ();

        if (adjustment != null && (adjustment.upper - adjustment.lower) > 0 && adjustment.step > 0)
        {
            for (double step = adjustment.step / 2.0; step < (adjustment.upper - adjustment.lower); step += adjustment.step)
            {
                double step_pos = (step - adjustment.lower) / (adjustment.upper - adjustment.lower);

                switch (placement)
                {
                    case Placement.TOP:
                        path.move_to (area.extents.size.width * step_pos, area.extents.size.height / 4);
                        path.line_to (area.extents.size.width * step_pos, area.extents.size.height / 2);
                        break;

                    case Placement.BOTTOM:
                        path.move_to (area.extents.size.width * step_pos, area.extents.size.height / 2);
                        path.line_to (area.extents.size.width * step_pos, 3 * (area.extents.size.height / 4));
                        break;

                    case Placement.LEFT:
                        path.move_to (area.extents.size.width / 2, area.extents.size.height * step_pos);
                        path.line_to (3 * (area.extents.size.width / 4), area.extents.size.height * step_pos);
                        break;

                    case Placement.RIGHT:
                        path.move_to (area.extents.size.width / 4, area.extents.size.height * step_pos);
                        path.line_to (area.extents.size.width / 2, area.extents.size.height * step_pos);
                        break;
                }
            }
        }

        return path;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Label;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;
            int cpt = 0;

            var item_area = area;

            if (display_slide_label && adjustment != null && adjustment.page_size > 0)
            {
                double upper = 0;
                double lower = 0;
                double val = adjustment.@value;

                if (val - (adjustment.page_size / 2) < adjustment.lower)
                    val = adjustment.lower + (adjustment.page_size / 2);
                if (val + (adjustment.page_size / 2) > adjustment.upper)
                    val = adjustment.upper - (adjustment.page_size / 2);

                lower = double.max (adjustment.lower, val - (adjustment.page_size / 2));
                upper = double.min (adjustment.upper, val + (adjustment.page_size / 2));

                double val_lower = (adjustment.upper - adjustment.lower) == 0 ? 0 : (lower - adjustment.lower) / (adjustment.upper - adjustment.lower);
                double val_upper = (adjustment.upper - adjustment.lower) == 0 ? 0 : (upper - adjustment.lower) / (adjustment.upper - adjustment.lower);

                switch (placement)
                {
                    case Placement.TOP:
                        if (m_SliderLabelLower != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point ((item_area.extents.size.width * val_lower) - label_size.width - label_border, 0);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelLower.update (inContext, new Graphic.Region (label_area));
                        }
                        if (m_SliderLabelUpper != null)
                        {
                            var label_size = m_SliderLabelUpper.size;
                            var label_position = Graphic.Point ((item_area.extents.size.width * val_upper) + label_border, 0);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelUpper.update (inContext, new Graphic.Region (label_area));
                        }
                        break;

                    case Placement.BOTTOM:
                        if (m_SliderLabelLower != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point ((item_area.extents.size.width * val_lower) - label_size.width - label_border,
                                                                item_area.extents.size.height - label_size.height);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelLower.update (inContext, new Graphic.Region (label_area));
                        }
                        if (m_SliderLabelUpper != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point ((item_area.extents.size.width * val_upper) + label_border,
                                                                item_area.extents.size.height - label_size.height);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelUpper.update (inContext, new Graphic.Region (label_area));
                        }
                        break;

                    case Placement.LEFT:
                        if (m_SliderLabelLower != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point (0, (item_area.extents.size.height * val_lower) - label_size.height - label_border);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelLower.update (inContext, new Graphic.Region (label_area));
                        }
                        if (m_SliderLabelUpper != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point (0, (item_area.extents.size.height * val_upper) + label_border);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelUpper.update (inContext, new Graphic.Region (label_area));
                        }
                        break;

                    case Placement.RIGHT:
                        if (m_SliderLabelLower != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point (item_area.extents.size.width - label_size.width,
                                                                (item_area.extents.size.height * val_lower) - label_size.height - label_border);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelLower.update (inContext, new Graphic.Region (label_area));
                        }
                        if (m_SliderLabelUpper != null)
                        {
                            var label_size = m_SliderLabelLower.size;
                            var label_position = Graphic.Point (item_area.extents.size.width - label_size.width,
                                                                (item_area.extents.size.height * val_upper) + label_border);
                            var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                            m_SliderLabelUpper.update (inContext, new Graphic.Region (label_area));
                        }
                        break;
                }
            }

            if (display_step_label && adjustment != null && (adjustment.upper - adjustment.lower) > 0 && adjustment.step > 0)
            {
                for (double step = adjustment.step; step < (adjustment.upper - adjustment.lower); step += adjustment.step, ++cpt)
                {
                    double step_pos = (step - adjustment.lower) / (adjustment.upper - adjustment.lower);
                    var label_size = m_StepLabels[cpt].size;

                    switch (placement)
                    {
                        case Placement.TOP:
                            if ((item_area.extents.size.width * step_pos) - label_size.width - label_border >= 0)
                            {
                                var label_position = Graphic.Point ((item_area.extents.size.width * step_pos) - label_size.width - label_border,
                                                                    (item_area.extents.size.height / 2) - label_size.height - label_border);
                                var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                                m_StepLabels[cpt].update (inContext, new Graphic.Region (label_area));
                            }
                            break;

                        case Placement.BOTTOM:
                            if ((item_area.extents.size.width * step_pos) - label_size.width - label_border >= 0)
                            {
                                var label_position = Graphic.Point ((item_area.extents.size.width * step_pos) - label_size.width - label_border,
                                                                    (item_area.extents.size.height / 2) + label_border);
                                var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                                m_StepLabels[cpt].update (inContext, new Graphic.Region (label_area));
                            }
                            break;

                        case Placement.LEFT:
                            if ((item_area.extents.size.height * step_pos) - label_size.height - label_border >= 0)
                            {
                                var label_position = Graphic.Point ((item_area.extents.size.width / 2) + label_border,
                                                                    (item_area.extents.size.height * step_pos) - label_size.height - label_border);
                                var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                                m_StepLabels[cpt].update (inContext, new Graphic.Region (label_area));
                            }
                            break;

                        case Placement.RIGHT:
                            if ((item_area.extents.size.height * step_pos) - label_size.height - label_border >= 0)
                            {
                                var label_position = Graphic.Point ((item_area.extents.size.width / 2) - label_size.width - label_border,
                                                                    (item_area.extents.size.height * step_pos) - label_size.height - label_border);
                                var label_area = Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height);
                                m_StepLabels[cpt].update (inContext, new Graphic.Region (label_area));
                            }
                            break;
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

        // Draw step scale
        if (step_stroke_pattern != null)
        {
            inContext.line_width = step_line_width;
            inContext.pattern = step_stroke_pattern;
            inContext.stroke (get_step_path ());

            if (display_step_middle)
            {
                inContext.stroke (get_step_middle_path ());
            }
        }

        // Draw main scale
        if (stroke_pattern != null)
        {
            inContext.line_width = line_width;
            inContext.pattern = stroke_pattern;
            inContext.stroke (get_scale_path ());
        }

        // Draw childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Drawable)
            {
                unowned Drawable drawable = (Drawable)child;

                var area = area_to_child_item_space (drawable, inArea);
                drawable.draw (inContext, area);
            }
        }

        // Draw slider
        if (fill_pattern != null)
        {
            inContext.pattern = fill_pattern;
            inContext.fill (get_slider_path ());
        }
    }
}

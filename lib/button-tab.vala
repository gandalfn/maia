/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * toggle-button.vala
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

public class Maia.ButtonTab : Toggle
{
    // properties
    private Core.Animator     m_IndicatorAnimator   = null;
    private uint              m_IndicatorTransition = 0;
    private double            m_IndicatorProgress   = 0.0;
    private bool              m_Highlight           = false;

    // accessors
    internal override string tag {
        get {
            return "ButtonTab";
        }
    }

    internal override string main_data {
        owned get {
            return @"Grid.$(name)-content {\n" +
                   @"    homogeneous: true;\n" +
                   @"    row-spacing: @spacing;\n" +
                   @"    Grid.$(name)_icon_label {\n" +
                   @"       column-spacing: @spacing;\n" +
                   @"       xexpand: true;\n" +
                   @"       xfill: true;\n" +
                   @"       Image.$(name)-image {\n"    +
                   @"           column: 1;\n"    +
                   @"           yfill: false;\n" +
                   @"           yexpand: true;\n" +
                   @"           xexpand: false;\n" +
                   @"           xfill: false;\n" +
                   @"           xlimp: true;\n" +
                   @"           filename: @icon-filename;\n" +
                   @"           state: @state;\n" +
                   @"           size: @icon-size;\n" +
                   @"       }\n" +
                   @"       Label.$(name)-label {\n"    +
                   @"           xfill: true;\n" +
                   @"           xexpand: true;\n" +
                   @"           xlimp: true;\n" +
                   @"           yfill: false;\n" +
                   @"           yexpand: true;\n" +
                   @"           hide-if-empty: true;\n" +
                   @"           alignment: @alignment;\n" +
                   @"           state: @label-state;\n" +
                   @"           font-description: @font-description;\n" +
                   @"           stroke-pattern: @stroke-pattern;\n" +
                   @"           text: @label;\n" +
                   @"       }\n" +
                   @"    }\n" +
                   @"    Label.$(name)-value {\n"    +
                   @"        row: 1;\n"    +
                   @"        xfill: true;\n" +
                   @"        xexpand: true;\n" +
                   @"        yfill: false;\n" +
                   @"        yexpand: true;\n" +
                   @"        ylimp: true;\n" +
                   @"        hide-if-empty: true;\n" +
                   @"        alignment: @alignment;\n" +
                   @"        state: @label-state;\n" +
                   @"        font-description: @font-description;\n" +
                   @"        stroke-pattern: @stroke-pattern;\n" +
                   @"        text: @value;\n" +
                   @"    }\n" +
                   @"}";
        }
    }

    internal State label_state { get; set; default = State.NORMAL; }

    [CCode (notify = false)]
    internal double indicator_progress {
        get {
            return m_IndicatorProgress;
        }
        set {
            m_IndicatorProgress = value;
            damage.post ();
        }
    }

    /**
     * Indicator placement
     */
    public Placement indicator_placement { get; set; default = Placement.BOTTOM; }

    /**
     * Indicator thickness
     */
    public double indicator_thickness { get; set; default = 5.0; }

    /**
     * Alignment of label ``left``, ``center`` or ``right``, default was ``center``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.CENTER; }

    /**
     * Content spacing
     */
    public double spacing { get; set; default = 5.0; }

    /**
     * The icon filename no icon if ``null``
     */
    public string icon_filename { get; set; default = null; }

    /**
     * The icon size
     */
    public Graphic.Size icon_size { get; set; default = Graphic.Size (0, 0); }

    /**
     * Value of tab
     */
    public string @value { get; set; default = null; }

    /**
     * Indicate if button is highlighted
     */
    public bool highlight {
        get {
            return m_Highlight;
        }
        set {
            if (m_Highlight != value)
            {
                m_Highlight = value;

                label_state = m_Highlight ? State.PRELIGHT : state;

                GLib.Signal.emit_by_name (this, "notify::highlight");

                damage.post ();
            }
        }
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("indicator-progress");

        // create switch animator
        m_IndicatorAnimator = new Core.Animator (30, 180);

        // connect activate changed
        notify["active"].connect (on_active_changed);
    }

    public ButtonTab (string inId, string? inLabel)
    {
        base (inId, inLabel);
    }

    private void
    on_active_changed ()
    {
        m_IndicatorAnimator.stop ();

        if (m_IndicatorTransition > 0)
        {
            m_IndicatorAnimator.remove_transition (m_IndicatorTransition);
        }
        m_IndicatorTransition = m_IndicatorAnimator.add_transition (0, 1, Core.Animator.ProgressType.LINEAR);
        GLib.Value from = m_IndicatorProgress;
        GLib.Value to = active ? 1.0 : 0.0;
        m_IndicatorAnimator.add_transition_property (m_IndicatorTransition, this, "indicator-progress", from, to);
        m_IndicatorAnimator.start ();
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size ret = Graphic.Size (0, 0);

        bool horizontal = (indicator_placement == Placement.TOP || indicator_placement == Placement.BOTTOM);

        if (main_content != null)
        {
            var area = Graphic.Rectangle (0, 0, horizontal ? border * 2.0 : 0, !horizontal ? border * 2.0 : 0);

            // Set position and size of indicator and label
            var indicator_area = Graphic.Rectangle (horizontal ? border : 0, !horizontal ? border : 0, indicator_thickness, indicator_thickness);
            var main_content_size = main_content.size;
            var main_content_area = Graphic.Rectangle (horizontal ? border : 0, !horizontal ? border : 0, main_content_size.width, main_content_size.height);

            switch (indicator_placement)
            {
                case Placement.TOP:
                    indicator_area.size.width = main_content_size.width;
                    main_content_area.origin.y = indicator_area.origin.y + indicator_area.size.height + spacing;
                    break;

                case Placement.BOTTOM:
                    indicator_area.size.width = main_content_size.width;
                    indicator_area.origin.y = main_content_area.origin.y + main_content_area.size.height + spacing;
                    break;

                case Placement.LEFT:
                    indicator_area.size.height = main_content_size.height;
                    main_content_area.origin.x = indicator_area.origin.x + indicator_area.size.width + spacing;
                    break;

                case Placement.RIGHT:
                    indicator_area.size.height = main_content_size.height;
                    indicator_area.origin.x = main_content_area.origin.x + main_content_area.size.width + spacing;
                    break;
            }

            area.union_ (indicator_area);
            area.union_ (main_content_area);

            ret = area.size;
            ret.resize (horizontal ? border : 0, !horizontal ? border : 0);
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            bool horizontal = (indicator_placement == Placement.TOP || indicator_placement == Placement.BOTTOM);

            if (main_content != null)
            {
                // Set position and size of main content
                var item_size = area.extents.size;
                item_size.resize (horizontal ? -border * 2.0 : 0, !horizontal ? -border * 2.0 : 0);
                var main_content_area = Graphic.Rectangle (horizontal ? border : 0, !horizontal ? border : 0, item_size.width, item_size.height);

                switch (indicator_placement)
                {
                    case Placement.TOP:
                        main_content_area.size.height -= indicator_thickness + spacing;
                        main_content_area.origin.y += (indicator_thickness + spacing) + double.max (0, (main_content_area.size.height - main_content.size.height) / 2.0);
                        main_content_area.size.height = main_content.size.height;
                        break;

                    case Placement.BOTTOM:
                        main_content_area.size.height -= indicator_thickness + spacing;
                        main_content_area.origin.y += double.max (0, (main_content_area.size.height - main_content.size.height) / 2.0);
                        main_content_area.size.height = main_content.size.height;
                        break;

                    case Placement.LEFT:
                        main_content_area.size.height -= indicator_thickness + spacing;
                        main_content_area.origin.y += double.max (0, (main_content_area.size.height - main_content.size.height) / 2.0);
                        main_content_area.size.height = main_content.size.height;
                        main_content_area.size.width -= indicator_thickness + spacing;
                        main_content_area.origin.x += indicator_thickness + spacing;
                        break;

                    case Placement.RIGHT:
                        main_content_area.size.height -= indicator_thickness + spacing;
                        main_content_area.origin.y += double.max (0, (main_content_area.size.height - main_content.size.height) / 2.0);
                        main_content_area.size.height = main_content.size.height;
                        main_content_area.size.width -= indicator_thickness + spacing;
                        break;
                }

                main_content.update (inContext, new Graphic.Region (main_content_area));
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            bool horizontal = (indicator_placement == Placement.TOP || indicator_placement == Placement.BOTTOM);

            // paint button background
            if (background_pattern[m_Highlight ? State.PRELIGHT : state] != null)
            {
                inContext.save ();
                {
                    unowned Graphic.Image? image = background_pattern[m_Highlight ? State.PRELIGHT : state] as Graphic.Image;
                    if (image != null)
                    {
                        var item_area = area;
                        Graphic.Size image_size = image.size;
                        double scale = double.max (image_size.width / item_area.extents.size.width,
                                                   image_size.height / item_area.extents.size.height);
                        var transform = new Graphic.Transform.identity ();
                        transform.scale (scale, scale);
                        inContext.translate (Graphic.Point ((item_area.extents.size.width - (image_size.width / scale)) / 2,
                                                            (item_area.extents.size.height - (image_size.height / scale)) / 2));
                        image.transform = transform;
                        inContext.pattern = background_pattern[state];
                    }
                    else
                    {
                        inContext.pattern = background_pattern[m_Highlight ? State.PRELIGHT : state];
                    }

                    inContext.paint ();
                }
                inContext.restore ();
            }

            var main_content_area = Graphic.Rectangle (0, 0, 0, 0);

            // paint main content
            if (main_content != null)
            {
                var child_area = area_to_child_item_space (main_content, inArea);
                main_content.draw (inContext, child_area);
                main_content_area = main_content.geometry.extents;
            }

            var item_size = area.extents.size;
            item_size.resize (horizontal ? -border * 2.0 : 0, !horizontal ? -border * 2.0 : 0);

            // paint indicator
            var indicator_area = Graphic.Rectangle (horizontal ? border : 0, !horizontal ? border : 0, indicator_thickness, indicator_thickness);
            switch (indicator_placement)
            {
                case Placement.TOP:
                    indicator_area.size.width = item_size.width;
                    break;

                case Placement.BOTTOM:
                    indicator_area.size.width = item_size.width;
                    indicator_area.origin.y = item_size.height - indicator_thickness;
                    break;

                case Placement.LEFT:
                    indicator_area.size.height = item_size.height;
                    break;

                case Placement.RIGHT:
                    indicator_area.size.height = item_size.height;
                    indicator_area.origin.x = item_size.width - indicator_thickness;
                    break;
            }

            Graphic.Path indicator = new Graphic.Path ();
            indicator.rectangle (indicator_area.origin.x, indicator_area.origin.y, indicator_area.size.width, indicator_area.size.height);

            var color_active = fill_pattern[State.ACTIVE] as Graphic.Color;
            var color_inactive = fill_pattern[State.NORMAL] as Graphic.Color;
            if (color_active != null)
            {
                if (active)
                {
                    if (color_inactive != null)
                    {
                        inContext.pattern = new Graphic.Color (color_inactive.red, color_inactive.green, color_inactive.blue, color_inactive.alpha * (1 - m_IndicatorProgress));
                        inContext.fill (indicator);
                    }

                    inContext.pattern = new Graphic.Color (color_active.red, color_active.green, color_active.blue, color_active.alpha * m_IndicatorProgress);
                    inContext.fill (indicator);
                }
                else
                {
                    inContext.pattern = new Graphic.Color (color_active.red, color_active.green, color_active.blue, color_active.alpha * m_IndicatorProgress);
                    inContext.fill (indicator);

                    if (color_inactive != null)
                    {
                        inContext.pattern = new Graphic.Color (color_inactive.red, color_inactive.green, color_inactive.blue, color_inactive.alpha * (1 - m_IndicatorProgress));
                        inContext.fill (indicator);
                    }
                }
            }
            else if (fill_pattern[state] != null)
            {
                inContext.pattern = fill_pattern[state];
                inContext.fill (indicator);
            }

            var border_path = new Graphic.Path ();
            switch (indicator_placement)
            {
                case Placement.TOP:
                case Placement.BOTTOM:
                    border_path.move_to (0, 0);
                    border_path.line_to (0, item_size.height);
                    border_path.move_to ((border * 2.0) + item_size.width, 0);
                    border_path.line_to ((border * 2.0) + item_size.width, item_size.height);
                    break;

                case Placement.LEFT:
                case Placement.RIGHT:
                    border_path.move_to (0, 0);
                    border_path.line_to (item_size.width, 0);
                    border_path.move_to (0, (border * 2.0) + item_size.height);
                    border_path.line_to (item_size.width, (border * 2.0) + item_size.height);
                    break;
            }

            if (stroke_pattern[state] != null)
            {
                inContext.pattern = stroke_pattern[state];
                inContext.stroke (border_path);
            }
        }
        inContext.restore ();
    }
}

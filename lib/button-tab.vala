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
    private bool               m_Highlight = false;
    private unowned Label?     m_Label;
    private unowned Rectangle? m_Indicator;

    // accessors
    internal override string tag {
        get {
            return "ButtonTab";
        }
    }

    /**
     * The border around label and indicator
     */
    public double border { get; set; default = 5.0; }

    /**
     * The highlight font color of button
     */
    public Graphic.Pattern stroke_highlight_pattern { get; set; default = null; }

    /**
     * The insensitive background color of button if not set the button does not draw any background
     */
    public Graphic.Pattern button_inactive_pattern { get; set; default = null; }

    /**
     * The active color of indicator if not set the button does not draw any indicator
     */
    public Graphic.Pattern indicator_pattern { get; set; default = new Graphic.Color (1, 1, 1); }

    /**
     * Indicator placement
     */
    public Placement indicator_placement { get; set; default = Placement.BOTTOM; }

    /**
     * Indicator thickness
     */
    public double indicator_thickness { get; set; default = 5.0; }

    /**
     * Indicator label spacing
     */
    public double spacing { get; set; default = 5.0; }

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

                if (m_Highlight)
                {
                    unplug_property("stroke-pattern", m_Label, "stroke-pattern");
                    plug_property("stroke-highlight-pattern", m_Label, "stroke-pattern");
                }
                else
                {
                    plug_property("stroke-pattern", m_Label, "stroke-pattern");
                    unplug_property("stroke-highlight-pattern", m_Label, "stroke-pattern");
                }

                GLib.Signal.emit_by_name (this, "notify::highlight");

                damage.post ();
            }
        }
    }

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
        // Get label
        m_Label = find (GLib.Quark.from_string (@"$(name)-label"), false) as Label;
        m_Label.visible = false;
        m_Label.hide_if_empty = true;

        // Create indicator
        var indicator = new Rectangle (@"$(name)-indicator");
        indicator.visible = true;
        indicator.parent = this;
        m_Indicator = indicator;
        plug_property ("indicator-pattern", m_Indicator, "fill-pattern");
    }

    public ButtonTab (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Label || inObject is Rectangle;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        // Get label item
        if (m_Label != null)
        {
            // Set position and size of indicator and label
            Graphic.Point indicator_position = Graphic.Point (border, border);
            Graphic.Size indicator_size = Graphic.Size (indicator_thickness, indicator_thickness);
            Graphic.Point label_position = Graphic.Point (border, border);
            Graphic.Size label_size = m_Label.size;

            switch (indicator_placement)
            {
                case Placement.TOP:
                    indicator_size.width = double.max (label_size.width, inSize.width);
                    label_position.y = indicator_position.y + indicator_size.height + spacing;
                    break;

                case Placement.BOTTOM:
                    indicator_size.width = double.max (label_size.width, inSize.width);
                    indicator_position.y = label_position.y + label_size.height + spacing;
                    break;

                case Placement.LEFT:
                    indicator_size.height = double.max (label_size.height, inSize.height);
                    label_position.x = indicator_position.x + indicator_size.width + spacing;
                    break;

                case Placement.RIGHT:
                    indicator_size.height = double.max (label_size.height, inSize.height);
                    indicator_position.x = label_position.x + label_size.width + spacing;
                    break;
            }

            m_Indicator.position = indicator_position;
            m_Indicator.size = indicator_size;
            m_Label.position = label_position;
        }

        Graphic.Size ret = base.size_request (inSize);
        ret.resize (border, border);

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");
#endif

            geometry = inAllocation;

            var item_area = area;

            // Set position and size of indicator and label
            Graphic.Point indicator_position = m_Indicator.position;
            Graphic.Size indicator_size = m_Indicator.size;
            Graphic.Point label_position = m_Label.position;
            Graphic.Size label_size = m_Label.size;

            switch (indicator_placement)
            {
                case Placement.TOP:
                    indicator_size.width = item_area.extents.size.width - (border * 2.0);
                    label_size.width = item_area.extents.size.width - (border * 2.0);
                    label_position.y += ((item_area.extents.size.height - label_position.y - border) - label_size.height) / 2.0;
                    break;

                case Placement.BOTTOM:
                    indicator_size.width = item_area.extents.size.width - (border * 2.0);
                    indicator_position.y = item_area.extents.size.height - border - indicator_size.height;
                    label_size.width = item_area.extents.size.width - (border * 2.0);
                    label_position.y += (item_area.extents.size.height - indicator_size.height - spacing - (border * 2.0) - label_size.height) / 2.0;
                    break;

                case Placement.LEFT:
                    indicator_size.height = item_area.extents.size.height - (border * 2.0);
                    label_size.width = item_area.extents.size.width - label_position.x - border;
                    label_position.y = (item_area.extents.size.height - (border * 2.0) - label_size.height) / 2.0;
                    break;

                case Placement.RIGHT:
                    indicator_size.height = item_area.extents.size.height - (border * 2.0);
                    indicator_position.x = item_area.extents.size.width - border - indicator_size.width;
                    label_size.width = item_area.extents.size.width - indicator_size.width - spacing - (border * 2.0);
                    label_position.y = (item_area.extents.size.height - (border * 2.0) - label_size.height) / 2.0;
                    break;
            }

            // Set label size allocation
            var label_allocation = new Graphic.Region (Graphic.Rectangle (label_position.x, label_position.y, label_size.width, label_size.height));
            m_Label.update (inContext, label_allocation);

            // Set indicator size allocation
            var indicator_allocation = new Graphic.Region (Graphic.Rectangle (indicator_position.x, indicator_position.y, indicator_size.width, indicator_size.height));
            m_Indicator.update (inContext, indicator_allocation);

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            Graphic.Path background = new Graphic.Path.from_region (area);

            // paint button background if is sensitive
            if (sensitive)
            {
                // paint button background if is highlighted
                if (highlight && fill_pattern[Item.State.PRELIGHT] != null)
                {
                    inContext.pattern = fill_pattern[Item.State.PRELIGHT];
                    inContext.fill (background);
                }
                // paint button background if is not active
                else if (!highlight && fill_pattern[Item.State.NORMAL] != null)
                {
                    inContext.pattern = fill_pattern[Item.State.NORMAL];
                    inContext.fill (background);
                }
            }
            // paint button background if is not sensitive
            else if (fill_pattern[Item.State.INSENSITIVE] != null)
            {
                inContext.pattern = fill_pattern[Item.State.INSENSITIVE];
                inContext.fill (background);
            }

            // paint childs
            foreach (unowned Core.Object child in this)
            {
                if (child is Drawable)
                {
                    unowned Drawable drawable = (Drawable)child;
                    if (drawable == m_Label || (drawable == m_Indicator && active))
                    {
                        drawable.draw (inContext, area_to_child_item_space (drawable, inArea));
                    }
                }
            }
        }
        inContext.restore ();
    }
}

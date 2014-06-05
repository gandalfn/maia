/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * progress-bar.vala
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

public class Maia.ProgressBar : Item, ItemPackable
{
    // properties
    private Adjustment? m_Adjustment = null;

    // accessors
    internal override string tag {
        get {
            return "ProgressBar";
        }
    }

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

    public Adjustment? adjustment {
        get {
            return m_Adjustment;
        }
        set {
            if (m_Adjustment != null)
            {
                m_Adjustment.notify["value"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["lower"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["upper"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["page-size"].disconnect (on_adjustment_changed);
            }
            m_Adjustment = value;
            if (m_Adjustment != null)
            {
                m_Adjustment.notify["value"].connect (on_adjustment_changed);
                m_Adjustment.notify["lower"].connect (on_adjustment_changed);
                m_Adjustment.notify["upper"].connect (on_adjustment_changed);
                m_Adjustment.notify["page-size"].connect (on_adjustment_changed);
            }
        }
    }

    public virtual Graphic.Rectangle slider_area {
        get {
            var slider = Graphic.Rectangle (0, 0, 0, 0);
            if (adjustment != null)
            {
                double val = (adjustment.upper - adjustment.lower) == 0 ? 0 : (adjustment.@value - adjustment.lower) / (adjustment.upper - adjustment.lower);

                if (orientation == Orientation.HORIZONTAL)
                {
                    slider = Graphic.Rectangle (0, 0, area.extents.size.width * val, area.extents.size.height);
                }
                else
                {
                    slider = Graphic.Rectangle (0, 0, area.extents.size.width, area.extents.size.height * val);
                }
            }

            return slider;
        }
    }

    public Orientation orientation  { get; set; default = Orientation.HORIZONTAL; }
    public double      round_border { get; set; default = 5; }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("adjustment");

        // Default colors
        background_pattern = new Graphic.Color (1, 1, 1);
        stroke_pattern     = new Graphic.Color (0, 0, 0);
        fill_pattern       = new Graphic.Color (0.6, 0.6, 0.6);
    }

    public ProgressBar (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_adjustment_changed ()
    {
        damage ();
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // Construct background rectangle
        var background = Graphic.Rectangle (0, 0, area.extents.size.width, area.extents.size.height);

        // Construct progress rectangle
        var progress = slider_area;

        // Set line width
        inContext.line_width = line_width;

        // Construct path
        var background_path = new Graphic.Path ();
        background_path.rectangle (background.origin.x, background.origin.y, background.size.width, background.size.height, round_border, round_border);

        var progress_path = new Graphic.Path ();
        progress_path.rectangle (progress.origin.x, progress.origin.y, progress.size.width, progress.size.height, round_border, round_border);

        // Paint background
        if (background_pattern != null)
        {
            inContext.pattern = background_pattern;
            inContext.fill (background_path);
        }
        if (stroke_pattern != null)
        {
            inContext.pattern = stroke_pattern;
            inContext.stroke (background_path);
        }

        // Paint progress
        if (fill_pattern != null)
        {
            inContext.pattern = fill_pattern;
            inContext.fill (progress_path);
        }
        if (stroke_pattern != null)
        {
            inContext.pattern = stroke_pattern;
            inContext.stroke (progress_path);
        }
    }
}

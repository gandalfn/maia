/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * seek-bar.vala
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

public class Maia.SeekBar : ProgressBar, ItemFocusable
{
    // properties
    private bool          m_InMove = false;
    private Graphic.Point m_InitialPos;
    private FocusGroup    m_FocusGroup = null;

    // accessors
    internal override string tag {
        get {
            return "SeekBar";
        }
    }

    internal bool can_focus   { get; set; default = true; }
    internal bool have_focus  { get; set; default = false; }
    internal int  focus_order { get; set; default = -1; }
    internal FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }

    internal override Graphic.Rectangle slider_area {
        get  {
            var slider = Graphic.Rectangle (0, 0, 0, 0);
            if (adjustment != null)
            {
                double val = (adjustment.upper - adjustment.lower) == 0 ? 0 : (adjustment.@value - adjustment.lower) / (adjustment.upper - adjustment.lower);
                double slide_size = adjustment.page_size / (adjustment.upper - adjustment.lower);

                if (adjustment.@value > adjustment.upper - adjustment.page_size)
                    val = (adjustment.upper - adjustment.lower) == 0 ? 0 : ((adjustment.upper - adjustment.page_size) - adjustment.lower) / (adjustment.upper - adjustment.lower);

                if (orientation == Orientation.HORIZONTAL)
                {
                    slider = Graphic.Rectangle (area.extents.size.width * val, 0, area.extents.size.width * slide_size, area.extents.size.height);
                }
                else
                {
                    slider = Graphic.Rectangle (0, area.extents.size.height * val, area.extents.size.width, area.extents.size.height * slide_size);
                }
            }

            return slider;
        }
    }

    // static methods
    static construct
    {
        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    // methods
    public SeekBar (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = inPoint in area;

        if (ret && inButton == 1)
        {
            bool inSlider = inPoint in slider_area;

            // Button press under slider grab focus
            if (inSlider)
            {
                grab_pointer (this);
                m_InitialPos = inPoint;
                m_InMove = true;
            }
            // Button press outside slide add page size to value
            else if (adjustment != null && (adjustment.upper - adjustment.lower) != 0 && !area.is_empty ())
            {
                if (orientation == Orientation.HORIZONTAL)
                {
                    double val= (inPoint.x / area.extents.size.width) * (adjustment.upper - adjustment.lower);
                    if (val < adjustment.@value)
                        adjustment.@value -= adjustment.page_size;
                    else
                        adjustment.@value += adjustment.page_size;
                }
                else
                {
                    double val= (inPoint.y / area.extents.size.height) * (adjustment.upper - adjustment.lower);
                    if (val < adjustment.@value)
                        adjustment.@value -= adjustment.page_size;
                    else
                        adjustment.@value += adjustment.page_size;
                }
            }
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = inPoint in area;

        // button release and button press under slider ungrab focus
        if (m_InMove && inButton == 1)
        {
            ungrab_pointer (this);
            m_InMove = false;
        }

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        // motion event with button press under slider move it
        if (m_InMove && adjustment != null)
        {
            var diff = inPoint;
            diff.subtract (m_InitialPos);
            m_InitialPos = inPoint;

            if (orientation == Orientation.HORIZONTAL)
            {
                double val = adjustment.@value + (diff.x / area.extents.size.width) * (adjustment.upper - adjustment.lower);
                adjustment.@value = double.min (val, adjustment.upper - adjustment.page_size);
            }
            else
            {
                double val = adjustment.@value + (diff.y / area.extents.size.height) * (adjustment.upper - adjustment.lower);
                adjustment.@value = double.min (val, adjustment.upper - adjustment.page_size);
            }
        }

        return ret;
    }

    internal override bool
    on_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        bool ret = inPoint in area;

        if (ret && adjustment != null)
        {
            switch (inScroll)
            {
                case Scroll.UP:
                    adjustment.@value -= 0.01 * (adjustment.upper - adjustment.lower);
                    break;

                case Scroll.DOWN:
                    adjustment.@value += 0.01 * (adjustment.upper - adjustment.lower);
                    break;
            }
        }

        return ret;
    }
}

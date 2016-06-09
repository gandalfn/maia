/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * viewport.vala
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

public class Maia.Viewport : Window
{
    // types
    public enum ScrollMode
    {
        NONE,
        PUSH,
        NATURAL_PUSH,
        ACCEL,
        NATURAL_ACCEL;

        public string
        to_string ()
        {
            switch (this)
            {
                case PUSH:
                    return "push";

                case ACCEL:
                    return "accel";

                case NATURAL_PUSH:
                    return "natural-push";

                case NATURAL_ACCEL:
                    return "natural-accel";
            }

            return "";
        }

        public static ScrollMode
        from_string (string inValue)
        {
            switch (inValue)
            {
                case "push":
                    return PUSH;

                case "accel":
                    return ACCEL;

                case "natural-push":
                    return NATURAL_PUSH;

                case "natural-accel":
                    return NATURAL_ACCEL;
            }

            return NONE;
        }
    }

    private struct ButtonStatus
    {
        bool          m_Pressed;
        Graphic.Point m_Origin;
    }

    // properties
    private Graphic.Rectangle m_VisibleArea = Graphic.Rectangle (0, 0, 0, 0);
    private Graphic.Region    m_ScrolledDamaged = null;
    private bool              m_ScrollDamage = false;
    private ButtonStatus      m_ButtonStatus;

    // accessors
    internal override string tag {
        get {
            return "Viewport";
        }
    }

    [CCode (notify = false)]
    public virtual Graphic.Rectangle visible_area {
        get {
            return m_VisibleArea;
        }
        set {
            if (!m_VisibleArea.equal (value))
            {
                bool is_scroll = m_VisibleArea.size.equal (value.size) &&
                                 !m_VisibleArea.origin.equal (value.origin);

                m_VisibleArea = value;

                if (is_scroll)
                {
                    // Remove old scrolled damage area
                    if (m_ScrolledDamaged != null && damaged != null)
                    {
                        damaged.subtract (m_ScrolledDamaged);
                    }

                    // Set new scrolled damage has visible area
                    m_ScrolledDamaged = new Graphic.Region (m_VisibleArea);

                    // Remove damaged area from scrolled damaged area
                    if (damaged != null)
                    {
                        m_ScrolledDamaged.subtract (damaged);
                        if (m_ScrolledDamaged.is_empty ())
                        {
                            m_ScrolledDamaged = null;
                        }

                        // Remove visible area from damaged area to force damage signal emission
                        damaged.subtract (new Graphic.Region (m_VisibleArea));
                    }

                    // Block childs damage
                    m_ScrollDamage = true;

                    // Send damage to launch redraw of visible area
                    damage.post (new Graphic.Region (m_VisibleArea));

                    // Unblock childs damage
                    m_ScrollDamage = false;
                }

                GLib.Signal.emit_by_name (this, "notify::visible-area");
            }
        }
    }

    /**
     * View scroll mode
     */
    public ScrollMode scroll_mode { get; set; default = ScrollMode.NONE; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (ScrollMode), attribute_to_scroll_mode);

        GLib.Value.register_transform_func (typeof (ScrollMode), typeof (string), scroll_mode_value_to_string);
    }

    static void
    attribute_to_scroll_mode (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = ScrollMode.from_string (inAttribute.get ());
    }

    static void
    scroll_mode_value_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (ScrollMode)))
    {
        ScrollMode val = (ScrollMode)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("visible-area");
    }

    /**
     * Create a new viewport
     */
    public Viewport (string inName)
    {
        base (inName, 1, 1);
    }

    internal override void
    on_damage (Graphic.Region? inArea = null)
    {
        base.on_damage (inArea);

        if (!m_ScrollDamage)
        {
            if (m_ScrolledDamaged != null)
            {
                m_ScrolledDamaged.subtract (inArea ?? area);
                if (m_ScrolledDamaged.is_empty ())
                {
                    m_ScrolledDamaged = null;
                }
            }
        }
    }

    internal override void
    on_draw (Graphic.Context inContext, Graphic.Region? inArea) throws Graphic.Error
    {
        if (visible && geometry != null && !geometry.is_empty () && damaged != null && !damaged.is_empty ())
        {
            var ctx = surface.context;

            // area to redraw must be limited to visible area
            var visible_damaged = new Graphic.Region (visible_area);
            if (inArea != null)
            {
                visible_damaged.intersect (inArea);
            }

            // subtract area damaged for scrolling but already drawn
            if (m_ScrolledDamaged != null)
            {
                damaged.subtract (m_ScrolledDamaged);
                m_ScrolledDamaged = null;
            }

            // get area not already drawn
            var damaged_area = new Graphic.Region (damaged.extents);
            if (visible_damaged != null)
            {
                damaged_area.intersect (visible_damaged);
            }

            if (!damaged_area.is_empty ())
            {
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"viewport $name damaged draw $(damaged_area.extents)");

                ctx.save ();
                {
                    ctx.line_width = line_width;
                    ctx.dash = line_type.to_dash (line_width);

                    // Apply the window transform
                    if (transform.have_rotate)
                    {
                        var t = transform.copy ();
                        t.apply_center_rotate (geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);
                        ctx.transform = t;
                    }
                    else
                    {
                        ctx.transform = transform;
                    }

                    // Clear area
                    ctx.operator = Graphic.Operator.SOURCE;

                    // set visible area offset
                    ctx.translate (visible_area.origin.invert ());

                    // Clip the damaged area
                    ctx.clip_region (damaged_area);

                    ctx.pattern = background_pattern[state] != null ? background_pattern[state] : new Graphic.Color (0, 0, 0, 0);
                    ctx.paint ();

                    // Set paint over by default
                    ctx.operator = Graphic.Operator.OVER;

                    // and paint content
                    paint (ctx, damaged_area);
                }
                ctx.restore ();

                repair.post (damaged_area);
            }
            swap_buffer ();
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        m_ScrolledDamaged = null;

        base.update (inContext, inAllocation);
    }



    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (ret && scroll_mode != ScrollMode.NONE)
        {
            m_ButtonStatus.m_Pressed = inButton == 1;
            m_ButtonStatus.m_Origin = inPoint;
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        m_ButtonStatus.m_Pressed = false;
        m_ButtonStatus.m_Origin = Graphic.Point (0, 0);

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        if (ret && m_ButtonStatus.m_Pressed && scroll_mode != ScrollMode.NONE)
        {
            double diffx = inPoint.x - m_ButtonStatus.m_Origin.x;
            double diffy = inPoint.y - m_ButtonStatus.m_Origin.y;

            if (GLib.Math.fabs (diffx) > GLib.Math.fabs (diffy))
            {
                switch (scroll_mode)
                {
                    case ScrollMode.PUSH:
                        scroll_event (diffx < 0 ? Scroll.LEFT : Scroll.RIGHT, Graphic.Point (0, 0));
                        break;

                    case ScrollMode.ACCEL:
                        scroll_event (diffx < 0 ? Scroll.LEFT : Scroll.RIGHT, Graphic.Point (0, 0));
                        break;

                    case ScrollMode.NATURAL_PUSH:
                        scroll_event (diffx < 0 ? Scroll.RIGHT : Scroll.LEFT, Graphic.Point (0, 0));
                        break;

                    case ScrollMode.NATURAL_ACCEL:
                        scroll_event (diffx < 0 ? Scroll.RIGHT : Scroll.LEFT, Graphic.Point (0, 0));
                        break;

                }
                m_ButtonStatus.m_Origin = inPoint;
            }
            else if (GLib.Math.fabs (diffx) < GLib.Math.fabs (diffy))
            {
                switch (scroll_mode)
                {
                    case ScrollMode.PUSH:
                        scroll_event (diffy < 0 ? Scroll.UP : Scroll.DOWN, Graphic.Point (0, 0));
                        break;

                    case ScrollMode.ACCEL:
                        scroll_event (diffy < 0 ? Scroll.UP : Scroll.DOWN, Graphic.Point (0, 0));
                        break;

                    case ScrollMode.NATURAL_PUSH:
                        scroll_event (diffy < 0 ? Scroll.DOWN : Scroll.UP, Graphic.Point (0, 0));
                        break;

                    case ScrollMode.NATURAL_ACCEL:
                        scroll_event (diffy < 0 ? Scroll.DOWN : Scroll.UP, Graphic.Point (0, 0));
                        break;

                }
                m_ButtonStatus.m_Origin = inPoint;
            }
        }

        return ret;
    }
}

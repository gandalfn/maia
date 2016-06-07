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
    // properties
    private Graphic.Rectangle m_VisibleArea = Graphic.Rectangle (0, 0, 0, 0);
    private Graphic.Region    m_ScrolledDamaged = null;
    private bool              m_ScrollDamage = false;

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

        if (ret)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_press_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        //GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
            }

            ret = true;
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        if (ret)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_release_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        //GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
            }

            ret = true;
        }

        return ret;
    }

    internal override void
    on_gesture (Gesture.Notification inNotification)
    {
        print(@"gesture type: $(inNotification.gesture_type)\n");
        switch (inNotification.gesture_type)
        {
            case Gesture.Type.PRESS:
            case Gesture.Type.RELEASE:
                inNotification.proceed = true;
                break;

            case Gesture.Type.HSCROLL:
                scroll_event (inNotification.position.x < 0 ? Scroll.LEFT : Scroll.RIGHT, Graphic.Point (0, 0));
                inNotification.proceed = true;
                break;

            case Gesture.Type.VSCROLL:
                scroll_event (inNotification.position.y < 0 ? Scroll.UP : Scroll.DOWN, Graphic.Point (0, 0));
                inNotification.proceed = true;
                break;
        }
    }
}

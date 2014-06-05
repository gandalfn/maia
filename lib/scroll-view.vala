/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * scroll-view.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

/**
 * An item which add scrollbar to its children
 *
 * =Manifest description:=
 *
 * {{{
 *      ScrollView.<id> {
 *          Label.<id> {
 *              text: '....';
 *          }
 *      }
 * }}}
 *
 */

public class Maia.ScrollView : Item
{
    // types
    [Flags]
    public enum Policy
    {
        NONE                 = 0,
        VERTICAL_SCROLLING   = 1 << 0,
        HORIZONTAL_SCROLLING = 1 << 1
    }

    // properties
    private Window        m_Window      = null;
    private Window        m_Viewport    = null;
    private unowned Item? m_Child       = null;
    private SeekBar       m_HSeekBar    = null;
    private SeekBar       m_VSeekBar    = null;
    private Adjustment    m_HAdjustment = null;
    private Adjustment    m_VAdjustment = null;
    private Graphic.Point m_PreviousPos = Graphic.Point (0, 0);

    // accessors
    internal override string tag {
        get {
            return "ScrollView";
        }
    }

    internal override Graphic.Transform transform {
        get {
            // return the base transform
            return base.transform;
        }
        set {
            // set transform of window and do not set item transform to avoid duplicate transform
            m_Window.transform = value;
        }
    }

    public Adjustment hadjustment {
        get {
            return m_HAdjustment;
        }
    }

    public Adjustment vadjustment {
        get {
            return m_VAdjustment;
        }
    }

    public Policy policy { get; set; default = Policy.VERTICAL_SCROLLING | Policy.HORIZONTAL_SCROLLING; }

    // methods
    construct
    {
        m_HAdjustment = new Adjustment ();
        m_HAdjustment.notify["value"].connect (on_adjustment_changed);
        m_HAdjustment.notify["lower"].connect (on_adjustment_settings_changed);
        m_HAdjustment.notify["upper"].connect (on_adjustment_settings_changed);

        m_VAdjustment = new Adjustment ();
        m_VAdjustment.notify["value"].connect (on_adjustment_changed);
        m_VAdjustment.notify["lower"].connect (on_adjustment_settings_changed);
        m_VAdjustment.notify["upper"].connect (on_adjustment_settings_changed);

        m_HSeekBar = new SeekBar (name + "_hseekbar");
        m_HSeekBar.orientation = Orientation.HORIZONTAL;
        m_HSeekBar.adjustment = m_HAdjustment;
        m_HSeekBar.size = Graphic.Size (10, 10);
        m_HSeekBar.parent = this;

        m_VSeekBar = new SeekBar (name + "_vseekbar");
        m_VSeekBar.orientation = Orientation.VERTICAL;
        m_VSeekBar.adjustment = m_VAdjustment;
        m_VSeekBar.size = Graphic.Size (10, 10);
        m_VSeekBar.parent = this;

        m_Viewport = new Window (name + "_viewport", 1, 1);
        m_Viewport.background_pattern = background_pattern;
        m_Viewport.parent = this;

        m_Window = new Window (name + "_window", 1, 1);
        m_Window.scroll_event.connect (on_window_scroll_event);
        m_Window.background_pattern = background_pattern;
        m_Window.parent = m_Viewport;

        notify["visible"].connect (on_visible_changed);
        notify["background-pattern"].connect (on_background_pattern_changed);
    }

    public ScrollView (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    ~ScrollView ()
    {
        m_Window.parent = null;
        m_Window = null;
        m_Viewport.parent = null;
        m_Viewport = null;
    }

    private void
    on_adjustment_settings_changed ()
    {
        m_HSeekBar.need_update = true;
        m_VSeekBar.need_update = true;
    }

    private void
    on_adjustment_changed ()
    {
        if (geometry != null)
        {
            // Calculate the move offset
            var diff = m_PreviousPos;
            diff.subtract (Graphic.Point(hadjustment.@value, vadjustment.@value));

            // Set new position
            m_PreviousPos = Graphic.Point(hadjustment.@value, vadjustment.@value);

            // Set the new window position
            m_Window.position = m_PreviousPos.invert ();

            // translate window geometry
            m_Window.geometry.translate (diff);

            // if scroll view is currently damaged translate damaged region
            if (damaged != null)
            {
                damaged.translate (diff);
            }

            // if we have a damaged area of window
            if (m_Window.damaged != null)
            {
                // we have the viewport area to redraw
                Graphic.Region redraw_area = m_Viewport.area.copy ();

                // Check if window must be redraw in this viewport area
                redraw_area.translate (m_PreviousPos);
                redraw_area.intersect (m_Window.damaged);

                if (!redraw_area.is_empty ())
                {
                    redraw_area.translate (m_PreviousPos.invert ());

                    // Damage scroll view
                    damage (redraw_area);
                }
            }
        }
    }

    private void
    on_background_pattern_changed ()
    {
        // set background pattern of window and viewport
        m_Window.background_pattern = background_pattern;
        m_Viewport.background_pattern = background_pattern;
    }

    private void
    on_visible_changed ()
    {
        if (visible != m_Window.visible)
        {
            m_Viewport.visible = visible;
            m_Window.visible = visible;
        }
    }

    private bool
    on_window_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        switch (inScroll)
        {
            case Scroll.UP:
                vadjustment.@value -= 0.01 * (vadjustment.upper - vadjustment.lower);
                break;

            case Scroll.DOWN:
                vadjustment.@value += 0.01 * (vadjustment.upper - vadjustment.lower);
                break;

            case Scroll.LEFT:
                hadjustment.@value -= 0.01 * (hadjustment.upper - hadjustment.lower);
                break;

            case Scroll.RIGHT:
                hadjustment.@value += 0.01 * (hadjustment.upper - hadjustment.lower);
                break;
        }

        return true;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (inObject == m_Window || inObject == m_Viewport || inObject == m_HSeekBar || inObject == m_VSeekBar)
        {
            base.insert_child (inObject);
        }
        else if (can_append_child (inObject) && m_Child == null)
        {
            m_Child = inObject as Item;

            inObject.parent = m_Window;

            m_Viewport.visible = visible;
            m_Window.visible = visible;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject == m_Child)
        {
            m_Child = null;
            m_Child.parent = null;

            m_Viewport.visible = false;
            m_Window.visible = false;
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Region area = new Graphic.Region (Graphic.Rectangle (0, 0, inSize.width, inSize.height));

        if (m_Child != null)
        {
            Graphic.Size child_size = m_Child.size;

            area.union_with_rect (Graphic.Rectangle (0, 0, child_size.width, child_size.height));
        }

        hadjustment.lower = area.extents.origin.x;
        hadjustment.upper = area.extents.size.width;

        vadjustment.lower = area.extents.origin.y;
        vadjustment.upper = area.extents.size.height;

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "scroll-view: %s %s", name, area.extents.size.to_string ());

        return base.size_request (inSize);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            // Set page size
            hadjustment.page_size = geometry.extents.size.width - m_VSeekBar.size.width;
            vadjustment.page_size = geometry.extents.size.height - m_HSeekBar.size.height;

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"$(geometry.extents)");

            var viewport_position = m_Viewport.position;
            var viewport_allocation = new Graphic.Region (Graphic.Rectangle (viewport_position.x, viewport_position.y,
                                                                             geometry.extents.size.width - m_VSeekBar.size.width,
                                                                             geometry.extents.size.height - m_HSeekBar.size.height));

            m_Viewport.update (inContext, viewport_allocation);

            // Update seekbar geometry
            m_HSeekBar.update (inContext, new Graphic.Region (Graphic.Rectangle (0, geometry.extents.size.height - m_HSeekBar.size.height,
                                                                                 geometry.extents.size.width - m_VSeekBar.size.width,
                                                                                 m_HSeekBar.size.height)));
            m_VSeekBar.update (inContext, new Graphic.Region (Graphic.Rectangle (geometry.extents.size.width - m_VSeekBar.size.width, 0,
                                                                                 m_VSeekBar.size.width,
                                                                                 geometry.extents.size.height - m_HSeekBar.size.height)));

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // draw viewport
        var viewport_area = area_to_child_item_space (m_Viewport, inArea);
        m_Viewport.draw (m_Viewport.surface.context, viewport_area);
        m_Viewport.swap_buffer ();

        // swap buffer of window, drawed under viewport
        m_Window.swap_buffer ();

        // draw seekbars
        m_HSeekBar.draw (inContext, area_to_child_item_space (m_HSeekBar, inArea));
        m_VSeekBar.draw (inContext, area_to_child_item_space (m_VSeekBar, inArea));
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
                if (child is SeekBar)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_press_event (inButton, point))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s", item.name);
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
            }
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
                if (child is SeekBar)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_release_event (inButton, point))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button release event in %s", item.name);
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
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
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        if (ret)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if ((child is SeekBar))
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.motion_event (point))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "%s motion event in %s", name, item.name);

                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
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
    on_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        bool ret = false;

        if (visible && geometry != null && inPoint in geometry)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is SeekBar)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.scroll_event (inScroll, point))
                    {
                        ret = true;
                        break;
                    }
                }

                child = child.prev ();
            }
        }

        if (ret) GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return ret;
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        ret += inPrefix + m_Child.dump (inPrefix) + "\n";

        return ret;
    }
}
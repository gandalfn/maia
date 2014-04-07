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
    private Window m_Window = null;
    private unowned Item? m_Child = null;
    private Adjustment m_HAdjustment = null;
    private Adjustment m_VAdjustment = null;
    private Graphic.Point m_PreviousPos = Graphic.Point (0, 0);

    // accessors
    internal override string tag {
        get {
            return "ScrollView";
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
        m_HAdjustment.changed.connect (on_adjustment_changed);

        m_VAdjustment = new Adjustment ();
        m_VAdjustment.changed.connect (on_adjustment_changed);

        notify["visible"].connect (on_visible_changed);
    }

    public ScrollView (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_adjustment_changed ()
    {
        // Calculate the previous visible area
        Graphic.Region old_area = geometry.copy ();
        old_area.translate (m_PreviousPos);
        
        m_Window.position = Graphic.Point (-GLib.Math.round (hadjustment.@value), -GLib.Math.round (vadjustment.@value));

        // if scroll view is currently damaged translate damaged region
        if (damaged != null)
        {
            m_PreviousPos.subtract (Graphic.Point(GLib.Math.round (hadjustment.@value), GLib.Math.round (vadjustment.@value)));
            damaged.translate (m_PreviousPos);
        }

        // Calculate the current visible area
        Graphic.Region area = geometry.copy ();
        m_PreviousPos = Graphic.Point(GLib.Math.round (hadjustment.@value), GLib.Math.round (vadjustment.@value));
        area.translate (m_PreviousPos);

        // The damaged area was the difference between previous and current area
        area.subtract (old_area);

        m_Window.damage (area);
    }

    private void
    on_visible_changed ()
    {
        if (visible != m_Window.visible)
        {
            m_Window.visible = visible;
        }
    }

    private bool
    on_window_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        switch (inScroll)
        {
            case Scroll.UP:
                vadjustment.@value -= 0.01 * vadjustment.upper;
                break;

            case Scroll.DOWN:
                vadjustment.@value += 0.01 * vadjustment.upper;
                break;

            case Scroll.LEFT:
                hadjustment.@value -= 0.01 * hadjustment.upper;
                break;

            case Scroll.RIGHT:
                hadjustment.@value += 0.01 * hadjustment.upper;
                break;
        }

        return true;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Item;
    }

    internal override void
    on_damage (Graphic.Region? inArea = null)
    {
        Graphic.Region damaged_area = (inArea ?? geometry).copy ();

        damaged_area.translate (Graphic.Point (hadjustment.@value, vadjustment.@value));

        base.on_damage (damaged_area);
    }

    internal override void
    on_child_damaged (Drawable inChild, Graphic.Region? inArea)
    {
        if (inChild.geometry != null)
        {
            Graphic.Region damaged_area;

            if (inArea == null)
            {
                damaged_area = inChild.geometry.copy ();
            }
            else
            {
                damaged_area = inArea.copy ();
            }

            damaged_area.translate (Graphic.Point (-hadjustment.@value, -vadjustment.@value));

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

            // damage item
            damage (damaged_area);
        }
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (can_append_child (inObject) && m_Child == null)
        {
            m_Child = inObject as Item;

            m_Window = new Window (name + "_window", 1, 1);
            m_Window.scroll_event.connect (on_window_scroll_event);
            inObject.parent = m_Window;

            base.insert_child (m_Window);

            m_Window.visible = true;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject == m_Child)
        {
            m_Window.scroll_event.disconnect (on_window_scroll_event);
            base.remove_child (m_Window);
            m_Window = null;
            m_Child = null;
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

        if (m_Window != null)
        {
            m_Window.size = area.extents.size;
        }

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "scroll-view: %s %s", name, area.extents.size.to_string ());

        return base.size_request (inSize);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            if (m_Child != null)
            {
                // Get child position and size
                var item_size     = m_Window.size_requested;

                // Set child size allocation
                var child_allocation = new Graphic.Region (Graphic.Rectangle (0, 0,
                                                                              double.max (item_size.width, geometry.extents.size.width),
                                                                              double.max (item_size.height, geometry.extents.size.height)));
                hadjustment.page_size = geometry.extents.size.width;
                vadjustment.page_size = geometry.extents.size.height;

                m_Window.update (m_Window.surface.context, child_allocation);
            }

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        if (m_Child != null)
        {
            Graphic.Region area = inArea.copy ();
            area.translate (Graphic.Point(hadjustment.@value, vadjustment.@value));

            m_Window.background_pattern = background_pattern;

            m_Window.draw (m_Window.surface.context, area);

            m_Window.swap_buffer ();
        }
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        ret += inPrefix + m_Child.dump (inPrefix) + "\n";

        return ret;
    }
}

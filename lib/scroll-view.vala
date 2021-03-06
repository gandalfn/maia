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

public class Maia.ScrollView : Item, ItemPackable
{
    // types
    [Flags]
    public enum Policy
    {
        NONE                 = 0,
        VERTICAL_SCROLLING   = 1 << 0,
        HORIZONTAL_SCROLLING = 1 << 1;

        public string
        to_string ()
        {
            string ret = "";

            if (VERTICAL_SCROLLING in this)
            {
                ret = "vertical";
            }

            if (HORIZONTAL_SCROLLING in this)
            {
                if (ret == "")
                    ret = "horizontal";
                else
                    ret += " | horizontal";
            }

            return ret;
        }

        public static Policy
        from_string (string inValue)
        {
            Policy ret = Policy.NONE;

            string[] values = inValue.split("|");

            foreach (unowned string? val in values)
            {
                switch (val.strip ().down ())
                {
                    case "vertical":
                        if (ret == Policy.NONE)
                            ret = Policy.VERTICAL_SCROLLING;
                        else
                            ret |= Policy.VERTICAL_SCROLLING;
                        break;

                    case "horizontal":
                        if (ret == Policy.NONE)
                            ret = Policy.HORIZONTAL_SCROLLING;
                        else
                            ret |= Policy.HORIZONTAL_SCROLLING;
                        break;
                }
            }

            return ret;
        }
    }

    // properties
    private Core.Animator     m_ScrollToAnimator    = null;
    private uint              m_ScrollToTransition  = 0;
    private Graphic.Transform m_ViewportTransform   = new Graphic.Transform.identity ();
    private unowned Viewport? m_Viewport            = null;
    private Item              m_Child               = null;
    private SeekBar           m_HSeekBar            = null;
    private SeekBar           m_VSeekBar            = null;
    private Adjustment        m_HAdjustment         = null;
    private Adjustment        m_VAdjustment         = null;

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
            m_ViewportTransform = value;
            if (m_Viewport != null)
            {
                m_Viewport.transform = m_ViewportTransform;
            }
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

    public double scroll_x {
        get {
            return m_HAdjustment.@value;
        }
        set {
            m_HAdjustment.@value = value;
        }
    }

    public double scroll_y {
        get {
            return m_VAdjustment.@value;
        }
        set {
            m_VAdjustment.@value = value;
        }
    }

    public Policy policy { get; set; default = Policy.VERTICAL_SCROLLING | Policy.HORIZONTAL_SCROLLING; }

    /**
     * View scroll mode
     */
    public Viewport.ScrollMode scroll_mode { get; set; default = Viewport.ScrollMode.NONE; }

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


    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Policy), attribute_to_policy);

        GLib.Value.register_transform_func (typeof (Policy), typeof (string), policy_value_to_string);
    }

    static void
    attribute_to_policy (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Policy.from_string (inAttribute.get ());
    }

    static void
    policy_value_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Policy)))
    {
        Policy val = (Policy)inSrc;

        outDest = val.to_string ();
    }

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

        m_ScrollToAnimator = new Core.Animator (30, 400);

        // create viewport
        var viewport = new Viewport (name + "_viewport");
        m_Viewport = viewport;
        m_Viewport.visible = false;
        m_Viewport.shadow_border = Window.Border.NONE;
        m_Viewport.scroll_event.connect (on_viewport_scroll_event);
        m_Viewport.transform = m_ViewportTransform;

        if (m_Child != null)
        {
            m_Child.notify["root"].disconnect (on_child_parent_changed);
            m_Child.parent = m_Viewport;
            m_Child.notify["root"].connect (on_child_parent_changed);
        }

        plug_property("background-pattern", m_Viewport, "background-pattern");
        plug_property("visible", m_Viewport, "visible");
        plug_property("need-update", m_Viewport, "need-update");
        plug_property("scroll-mode", m_Viewport, "scroll-mode");

        m_Viewport.parent = this;
    }

    public ScrollView (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
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
            // Get visible area
            var visible_area = m_Viewport.visible_area;

            // Get new position
            var pos = Graphic.Point(GLib.Math.floor (hadjustment.@value), GLib.Math.floor (vadjustment.@value));

            // Calculate the move offset
            var diff = visible_area.origin.invert ();
            diff.subtract (pos);

            // Set new position
            if (m_Viewport.geometry != null)
            {
                m_Viewport.geometry.translate (m_Viewport.geometry.extents.origin.invert ());
                m_Viewport.geometry.translate (pos.invert ());
            }

            m_Viewport.position = pos.invert ();

            // Set new visible area
            visible_area.origin = pos;
            m_Viewport.visible_area = visible_area.ceil ();
        }
    }

    private bool
    on_viewport_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        switch (inScroll)
        {
            case Scroll.UP:
                vadjustment.@value -= 0.01 * (vadjustment.upper - vadjustment.lower);
                break;

            case Scroll.DOWN:
                double val = vadjustment.@value + 0.01 * (vadjustment.upper - vadjustment.lower);
                vadjustment.@value = double.min (val, vadjustment.upper - vadjustment.page_size);
                break;

            case Scroll.LEFT:
                hadjustment.@value -= 0.01 * (hadjustment.upper - hadjustment.lower);
                break;

            case Scroll.RIGHT:
                double val = hadjustment.@value + 0.01 * (hadjustment.upper - hadjustment.lower);
                hadjustment.@value = double.min (val, hadjustment.upper - hadjustment.page_size);
                break;
        }

        return true;
    }

    private void
    on_child_parent_changed ()
    {
        if (m_Child != null && m_Viewport != null && m_Child.parent != m_Viewport)
        {
            m_Child.notify["root"].disconnect (on_child_parent_changed);
            m_Child.set_qdata<unowned Manifest.Element?> (Manifest.Element.s_InternalParent, null);
            m_Child = null;
        }
    }

    internal override Core.Object.Iterator
    iterator_begin ()
    {
        return m_Child == null ? iterator_begin () : m_Child.iterator_begin ();
    }

    internal override Core.Object.Iterator
    iterator_end ()
    {
        return m_Child == null ? iterator_end () : m_Child.iterator_end();
    }

    internal override unowned Core.Object?
    find (uint32 inId, bool inRecursive = true)
    {
        if (m_Child != null)
        {
            if (m_Child.id == inId)
            {
                return m_Child;
            }
            else
            {
                return m_Child.find (inId, inRecursive);
            }
        }
        return null;
    }

    internal override Core.List<unowned T?>
    find_by_type<T> (bool inRecursive = true)
    {
        Core.List<unowned T?> list = new Core.List<unowned T?> ();

        if (m_Child != null)
        {
            foreach (unowned T? c in m_Child.find_by_type<T> (inRecursive))
            {
                list.insert (c);
            }
        }

        return list;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (inObject == m_Viewport || inObject == m_HSeekBar || inObject == m_VSeekBar)
        {
            base.insert_child (inObject);
        }
        else if (can_append_child (inObject) && m_Child == null)
        {
            m_Child = inObject as Item;
            m_Child.set_qdata<unowned Manifest.Element?> (Manifest.Element.s_InternalParent, this);

            if (m_Viewport != null)
            {
                m_Child.parent = m_Viewport;
            }

            m_Child.notify["root"].connect (on_child_parent_changed);
        }
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Region area = new Graphic.Region (Graphic.Rectangle (0, 0, inSize.width, inSize.height));

        if (m_Child != null)
        {
            Graphic.Point child_position = m_Child.position;
            Graphic.Size child_size = m_Child.size;

            area.union_with_rect (Graphic.Rectangle (0, 0, child_position.x + child_size.width, child_position.y + child_size.height));
        }

        hadjustment.configure (area.extents.origin.x, double.max (area.extents.size.width, hadjustment.page_size), hadjustment.page_size);
        vadjustment.configure (area.extents.origin.y, double.max (area.extents.size.height, vadjustment.page_size), vadjustment.page_size);

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"scroll-view: $name $(area.extents.size)");
#endif

        Graphic.Size ret = inSize;

        var viewport_size = m_Viewport.size;
        ret.width += viewport_size.width;
        ret.height += viewport_size.height;

        if ((Policy.HORIZONTAL_SCROLLING in policy) && viewport_size.width > ret.width)
        {
            ret.height += m_HSeekBar.size.height;
        }

        if ((Policy.VERTICAL_SCROLLING in policy) && viewport_size.height > ret.height)
        {
            ret.width += m_VSeekBar.size.width;
        }

        return base.size_request (ret);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            var viewport_size = m_Viewport.size;

            m_HSeekBar.visible = (Policy.HORIZONTAL_SCROLLING in policy) && viewport_size.width > inAllocation.extents.size.width;
            m_VSeekBar.visible = (Policy.VERTICAL_SCROLLING in policy) && viewport_size.height > inAllocation.extents.size.height;

            geometry = inAllocation;

            // Set page size
            hadjustment.page_size = double.max (0, geometry.extents.size.width - (m_VSeekBar.visible ? m_VSeekBar.size.width : 0));
            vadjustment.page_size = double.max (0, geometry.extents.size.height - (m_HSeekBar.visible ? m_HSeekBar.size.height : 0));

            // Fix adjustment value
            if (hadjustment.@value + hadjustment.page_size > hadjustment.upper)
            {
                hadjustment.@value = hadjustment.upper - hadjustment.page_size;
            }
            if (vadjustment.@value + vadjustment.page_size > vadjustment.upper)
            {
                vadjustment.@value = vadjustment.upper - vadjustment.page_size;
            }

#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"$(geometry.extents)");
#endif

            m_Viewport.visible_area = Graphic.Rectangle (m_Viewport.visible_area.origin.x, m_Viewport.visible_area.origin.y,
                                                         double.max (0, geometry.extents.size.width - (m_VSeekBar.visible ? m_VSeekBar.size.width : 0)),
                                                         double.max (0, geometry.extents.size.height - (m_HSeekBar.visible ? m_HSeekBar.size.height : 0)));

            var viewport_position = convert_to_window_space(Graphic.Point (0, 0));
            viewport_size = m_Viewport.size;

            m_Viewport.update (inContext, new Graphic.Region (Graphic.Rectangle (viewport_position.x, viewport_position.y,
                                                                                 double.max (m_Viewport.visible_area.size.width, viewport_size.width),
                                                                                 double.max (m_Viewport.visible_area.size.height, viewport_size.height))));

            // Update seekbar geometry
            m_HSeekBar.update (inContext, new Graphic.Region (Graphic.Rectangle (0, geometry.extents.size.height - m_HSeekBar.size.height,
                                                                                 double.max (0, geometry.extents.size.width - (m_VSeekBar.visible ? m_VSeekBar.size.width : 0)),
                                                                                 m_HSeekBar.size.height)));
            m_VSeekBar.update (inContext, new Graphic.Region (Graphic.Rectangle (geometry.extents.size.width - m_VSeekBar.size.width, 0,
                                                                                 m_VSeekBar.size.width,
                                                                                 double.max (0, geometry.extents.size.height - (m_HSeekBar.visible ? m_HSeekBar.size.height : 0)))));

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // draw viewport
        var viewport_area = inArea.copy ();
        var viewport_position = m_Viewport.geometry.extents.origin;
        viewport_area.translate (viewport_position);
        var damaged_viewport_area = area_to_child_item_space (m_Viewport, viewport_area);
        damaged_viewport_area.translate (m_Viewport.visible_area.origin);
        m_Viewport.draw (inContext, damaged_viewport_area);

        // draw seekbars
        if (m_HSeekBar.visible)
        {
            m_HSeekBar.draw (inContext, area_to_child_item_space (m_HSeekBar, inArea));
        }

        if (m_VSeekBar.visible)
        {
            m_VSeekBar.draw (inContext, area_to_child_item_space (m_VSeekBar, inArea));
        }
    }

    internal override void
    scroll_to (Item inItem)
    {
        var pos = inItem.convert_to_window_space (Graphic.Point (0, 0));

        m_ScrollToAnimator.stop ();

        if (m_ScrollToTransition > 0)
        {
            m_ScrollToAnimator.remove_transition (m_ScrollToTransition);
        }
        m_ScrollToTransition = m_ScrollToAnimator.add_transition (0, 1, Core.Animator.ProgressType.EASE_IN_EASE_OUT);
        GLib.Value from = (double)vadjustment.@value;
        GLib.Value to = (double)double.min (pos.y, vadjustment.upper - vadjustment.page_size);
        m_ScrollToAnimator.add_transition_property (m_ScrollToTransition, this, "scroll-y", from, to);
        m_ScrollToAnimator.start ();
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
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s", item.name);
#endif
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
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
                if (child is SeekBar)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_release_event (inButton, point))
                    {
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button release event in %s", item.name);
#endif
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
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "%s motion event in %s", name, item.name);
#endif

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

        // dump theme if any
        bool theme_dump = manifest_theme != null && !manifest_theme.get_qdata<bool> (Item.s_ThemeDumpQuark) && (parent == null || (parent as Manifest.Element).manifest_theme != manifest_theme);
        if (theme_dump)
        {
            ret += inPrefix + manifest_theme.dump (inPrefix) + "\n";
            manifest_theme.set_qdata<bool> (Item.s_ThemeDumpQuark, theme_dump);
        }

        if (m_Child != null)
        {
            ret += inPrefix + m_Child.dump (inPrefix) + "\n";
        }

        if (theme_dump)
        {
            manifest_theme.set_qdata<bool> (Item.s_ThemeDumpQuark, false);
        }

        return ret;
    }

    internal bool
    animator_is_playing ()
    {
        return m_ScrollToAnimator.is_playing;
    }

    public Graphic.Region?
    get_visible_area (Item inItem)
    {
        Graphic.Region? ret = null;

        if (inItem.geometry != null)
        {
            Graphic.Point p1 = inItem.convert_to_window_space(Graphic.Point (0, 0));
            Graphic.Point p2 = inItem.convert_to_window_space(Graphic.Point (inItem.area.extents.size.width, inItem.area.extents.size.height));

            Graphic.Point pv1 = m_Viewport.convert_to_window_space(Graphic.Point (m_Viewport.visible_area.origin.x, m_Viewport.visible_area.origin.y));
            Graphic.Point pv2 = m_Viewport.convert_to_window_space(Graphic.Point (m_Viewport.visible_area.origin.x + m_Viewport.visible_area.size.width,
                                                                                  m_Viewport.visible_area.origin.y + m_Viewport.visible_area.size.height));

            Graphic.Rectangle item_area = Graphic.Rectangle (p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
            Graphic.Rectangle viewport_area = Graphic.Rectangle (pv1.x, pv1.y, pv2.x - pv1.x, pv2.y - pv1.y);

            item_area.intersect (viewport_area);

            if (!item_area.is_empty ())
            {
                p1 = inItem.convert_from_window_space (Graphic.Point (item_area.origin.x, item_area.origin.y));
                p2 = inItem.convert_from_window_space (Graphic.Point (item_area.origin.x + item_area.size.width,
                                                                      item_area.origin.y + item_area.size.height));

                ret = new Graphic.Region (Graphic.Rectangle (p1.x, p1.y, p2.x - p1.x, p2.y - p1.y));
            }
        }

        return ret;
    }
}

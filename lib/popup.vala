/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * popup.vala
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

public enum Maia.PopupPlacement
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

    public static PopupPlacement
    from_string (string inValue)
    {
        switch (inValue)
        {
            case "top":
                return PopupPlacement.TOP;

            case "bottom":
                return PopupPlacement.BOTTOM;

            case "left":
                return PopupPlacement.LEFT;

            case "right":
                return PopupPlacement.RIGHT;
        }

        return PopupPlacement.TOP;
    }
}

public class Maia.Popup : Group
{
    // properties
    private Core.Animator m_Animator;
    private uint          m_Transition = 0;
    private unowned Item  m_Content;
    private Window        m_Window;

    // accessors
    internal override string tag {
        get {
            return "Popup";
        }
    }

    internal double x {
        set {
            var dtransform = get_window_transform ();
            dtransform.add (new Graphic.Transform.init_translate (value, 0));
            m_Window.device_transform = dtransform;
            m_Window.damage ();
        }
    }

    internal double y {
        set {
            var dtransform = get_window_transform ();
            dtransform.add (new Graphic.Transform.init_translate (0, value));
            m_Window.device_transform = dtransform;
            m_Window.damage ();
        }
    }

    public unowned Item? content {
        get {
            return m_Content;
        }
    }

    public double         border    { get; set; default = 0.0; }
    public PopupPlacement placement { get; set; default = PopupPlacement.TOP; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (PopupPlacement), attribute_to_popup_placement);

        GLib.Value.register_transform_func (typeof (PopupPlacement), typeof (string), popup_placement_to_string);
    }

    static void
    attribute_to_popup_placement (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = PopupPlacement.from_string (inAttribute.get ());
    }

    static void
    popup_placement_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (PopupPlacement)))
    {
        PopupPlacement val = (PopupPlacement)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        // Create window
        m_Window = new Window (name + "_window", 1, 1);
        m_Window.set_qdata<unowned Object> (Item.s_PopupWindow, this);
        m_Window.depth = 32;
        m_Window.background_pattern = background_pattern;
        m_Window.transform = transform;
        m_Window.parent = Application.default;
        m_Window.border = border;

        // Add not dumpable attributes
        not_dumpable_attributes.insert ("content");

        // Create animator
        m_Animator = new Core.Animator (60, 250);

        // Connect onto background pattern change
        notify["background-pattern"].connect (on_background_pattern_changed);

        // Connect onto transform change
        notify["transform"].connect (on_transform_changed);

        // Connect onto window change
        notify["window"].connect (on_window_changed);

        // Connect onto border change
        notify["border"].connect (on_border_changed);
    }

    public Popup (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    ~Popup ()
    {
        m_Window.parent = null;
        m_Window = null;
    }

    private void
    on_background_pattern_changed ()
    {
        m_Window.background_pattern = background_pattern;
    }

    private void
    on_transform_changed ()
    {
        m_Window.transform = transform;
    }

    private void
    on_border_changed ()
    {
        m_Window.border = border;
    }

    private void
    on_window_changed ()
    {
        GLib.Signal.emit_by_name (m_Window, "notify::window");
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (can_append_child (inObject) && m_Content == null)
        {
            m_Content = inObject as Item;

            m_Content.parent = m_Window;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject == m_Content)
        {
            m_Content.parent = null;
        }
    }

    internal override unowned Core.Object?
    find (uint32 inId, bool inRecursive = true)
    {
        return m_Window == null ? null : m_Window.find (inId, inRecursive);
    }

    internal override string
    to_string ()
    {
        // Do not dump popup in manifest
        return "";
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        // Virtual item no size
        return Graphic.Size (0, 0);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        geometry = inAllocation;

        // Force content to fill the popup window
        m_Content.size = Graphic.Size (geometry.extents.size.width - (border * 4), geometry.extents.size.height - (border * 4));

        // set window size and position
        m_Window.position = convert_to_window_space (geometry.extents.origin);
        m_Window.device_transform = get_window_transform ();
    }

    internal override void
    on_draw (Graphic.Context inContext, Graphic.Region? inArea) throws Graphic.Error
    {
        // Draw nothing, popup is virtual item to plug window at position
    }

    internal override void
    on_show ()
    {
        // Show window when popup is visible
        m_Window.visible = true;

        m_Animator.stop ();

        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }

        GLib.Value from = (double)0;
        GLib.Value to = (double)0;

        // Create transition
        m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.SINUSOIDAL, null, on_show_animation_finished);

        // Get popup size
        var popup_size = m_Window.size;

        // Set animation property change
        switch (placement)
        {
            case PopupPlacement.BOTTOM:
                from = (double)(popup_size.height);
                to = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.TOP:
                from = (double)(-popup_size.height);
                to = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.RIGHT:
                from = (double)(popup_size.width);
                to = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;

            case PopupPlacement.LEFT:
                from = (double)(-popup_size.width);
                to = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;
        }

        // Start animation
        m_Animator.start ();

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        m_Animator.stop ();

        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }

        GLib.Value from = (double)0;
        GLib.Value to = (double)0;

        // Create transition
        m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.SINUSOIDAL, null, on_hide_animation_finished);

        // Get popup size
        var popup_size = m_Window.size;

        // Set animation property change
        switch (placement)
        {
            case PopupPlacement.BOTTOM:
                to = (double)(popup_size.height);
                from = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.TOP:
                to = (double)(-popup_size.height);
                from = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.RIGHT:
                to = (double)(popup_size.width);
                from = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;

            case PopupPlacement.LEFT:
                to = (double)(-popup_size.width);
                from = (double)0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;
        }

        // Start animation
        m_Animator.start ();
    }

    public Graphic.Transform
    get_window_transform ()
    {
        // Get stack of items
        GLib.SList<unowned Item> list = new GLib.SList<unowned Item?> ();
        for (unowned Core.Object? item = this; item != null; item = item.parent)
        {
            if (item is Item && !(item is Popup))
            {
                list.prepend (item as Item);
            }
        }

        // Apply transform foreach item
        Graphic.Transform ret = new Graphic.Transform.identity ();
        foreach (unowned Item item in list)
        {
            Graphic.Matrix matrix = item.transform.matrix;
            Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
            ret.add (item_transform);
        }

        return ret;
    }

    private void
    on_hide_animation_finished ()
    {
        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }

        base.on_hide ();

        // Hide window when popup is hidden
        m_Window.visible = false;
    }

    private void
    on_show_animation_finished ()
    {
        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;

            m_Window.grab_focus (m_Content);
        }
    }
}

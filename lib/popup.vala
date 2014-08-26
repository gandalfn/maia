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
    ABSOLUTE,
    TOP,
    BOTTOM,
    LEFT,
    RIGHT;

    public string
    to_string ()
    {
        switch (this)
        {
            case ABSOLUTE:
                return "absolute";

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
        switch (inValue.down ())
        {
            case "absolute":
                return PopupPlacement.ABSOLUTE;

            case "top":
                return PopupPlacement.TOP;

            case "bottom":
                return PopupPlacement.BOTTOM;

            case "left":
                return PopupPlacement.LEFT;

            case "right":
                return PopupPlacement.RIGHT;
        }

        return PopupPlacement.ABSOLUTE;
    }
}

public class Maia.Popup : Group
{
    // static properties
    private static unowned Popup s_PopupOpen = null;

    // properties
    private double          m_X = double.MIN;
    private double          m_Y = double.MIN;
    private Core.Animator   m_Animator;
    private uint            m_Transition = 0;
    private Item            m_Content;
    private unowned Window? m_Window;

    // accessors
    internal override string tag {
        get {
            return "Popup";
        }
    }

    internal double x {
        set {
            m_X = value;
            if (m_Window != null)
            {
                var dtransform = get_window_transform ();
                dtransform.add (new Graphic.Transform.init_translate (value, 0));
                m_Window.device_transform = dtransform;
                m_Window.damage ();
            }
        }
    }

    internal double y {
        set {
            m_Y = value;
            if (m_Window != null)
            {
                var dtransform = get_window_transform ();
                dtransform.add (new Graphic.Transform.init_translate (0, value));
                m_Window.device_transform = dtransform;
                m_Window.damage ();
            }
        }
    }

    public unowned Item? content {
        get {
            return m_Content;
        }
        set {
            if (m_Content != null)
            {
                m_Content.parent = null;
                m_Content = null;
            }
            if (value != null)
            {
                add (value);
            }
        }
    }

    public Graphic.Color  shadow_color  { get; set; default = new Graphic.Color (0, 0, 0); }
    public double         shadow_width  { get; set; default = 0.0; }
    public Window.Border  shadow_border { get; set; default = Window.Border.ALL; }
    public double         round_corner  { get; set; default = 5.0; }
    public bool           close_button  { get; set; default = false; }
    public double         border        { get; set; default = 0.0; }
    public PopupPlacement placement     { get; set; default = PopupPlacement.TOP; }
    public bool           animation     { get; set; default = true; }

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
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("content");

        // Create animator
        m_Animator = new Core.Animator (60, 250);

        // Connect onto window change
        notify["window"].connect (on_window_changed);

        // Connect onto border change
        notify["placement"].connect (on_placement_changed);
    }

    public Popup (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    ~Popup ()
    {
        if (s_PopupOpen == this)
        {
            s_PopupOpen = null;
        }

        if (m_Content != null)
        {
            m_Content.parent = null;
        }

        if (m_Window != null)
        {
            m_Window.weak_unref (on_window_destroyed);
            m_Window.set_qdata<unowned Object?> (Item.s_PopupWindow, null);
            m_Window.parent = null;
        }
    }

    private void
    create_window ()
    {
        var win = new Window (name + "_window", 1, 1);
        m_Window = win;
        m_Window.visible = false;
        m_Window.set_qdata<unowned Object> (Item.s_PopupWindow, this);
        m_Window.depth = 32;
        m_Window.parent = Application.default;
        m_Window.weak_ref (on_window_destroyed);

        // plug manifest path
        plug_property ("manifest-path", m_Window, "manifest-path");

        // plug theme to window
        plug_property ("manifest-theme", m_Window, "manifest-theme");

        // plug background pattern property to window
        plug_property ("background-pattern", m_Window, "background-pattern");

        // plug stroke pattern property to window
        plug_property ("stroke-pattern", m_Window, "stroke-pattern");

        // plug transform property to window
        plug_property ("transform", m_Window, "transform");

        // plug border property to window
        plug_property ("border", m_Window, "border");

        // plug shadow border property to window
        plug_property ("shadow-border", m_Window, "shadow-border");

        // plug shadow width property to window
        plug_property ("shadow-width", m_Window, "shadow-width");

        // plug shadow color property to window
        plug_property ("shadow-color", m_Window, "shadow-color");

        // plug round corner property to window
        plug_property ("round-corner", m_Window, "round-corner");

        // plug close button property to window
        plug_property ("close-button", m_Window, "close-button");

        m_Window.notify["visible"].connect (on_window_visible_changed);

        on_placement_changed ();
    }

    private void
    on_window_destroyed ()
    {
        m_Window = null;

        visible = false;
    }

    private void
    on_placement_changed ()
    {
        if (m_Window != null)
        {
            switch (placement)
            {
                case PopupPlacement.ABSOLUTE:
                    m_Window.shadow_border = Window.Border.LEFT  |
                                             Window.Border.RIGHT |
                                             Window.Border.TOP   |
                                             Window.Border.BOTTOM;
                    break;

                case PopupPlacement.BOTTOM:
                    m_Window.shadow_border = Window.Border.TOP;
                    break;

                case PopupPlacement.TOP:
                    m_Window.shadow_border = Window.Border.BOTTOM;
                    break;

                case PopupPlacement.RIGHT:
                    m_Window.shadow_border = Window.Border.LEFT;
                    break;

                case PopupPlacement.LEFT:
                    m_Window.shadow_border = Window.Border.RIGHT;
                    break;
            }
        }
    }

    private void
    on_window_changed ()
    {
        if (window == null || !window.visible)
        {
            animation = false;
            visible = false;
            animation = true;
        }
        if (m_Window != null)
        {
            GLib.Signal.emit_by_name (m_Window, "notify::window");
        }
    }

    private void
    on_window_visible_changed ()
    {
        if (visible != m_Window.visible)
        {
            visible = m_Window.visible;
        }
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (can_append_child (inObject) && m_Content == null)
        {
            m_Content = inObject as Item;

            if (m_Window != null)
            {
                m_Content.parent = m_Window;
            }
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject == m_Content)
        {
            m_Content.parent = null;
            m_Content = null;
        }
    }

    internal override unowned Core.Object?
    find (uint32 inId, bool inRecursive = true)
    {
        return m_Content == null ? null : m_Content.find (inId, inRecursive);
    }

    internal override Core.List<unowned T?>
    find_by_type<T> (bool inRecursive = true)
    {
        Core.List<unowned T?> list = new Core.List<unowned T?> ();

        if (m_Content != null)
        {
            foreach (unowned T? c in m_Content.find_by_type<T> (inRecursive))
            {
                list.insert (c);
            }
        }

        return list;
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
        if (visible)
        {
            geometry = inAllocation;

            // Force content to fill the popup window
            m_Content.size = Graphic.Size (geometry.extents.size.width - (border * 4), geometry.extents.size.height - (border * 4));

            if (m_Window != null)
            {
                // set window size and position
                var pos = convert_to_window_space(Graphic.Point (0, 0));
                m_Window.position = Graphic.Point (pos.x - shadow_width, pos.y);
                m_Window.device_transform = get_window_transform ();

                m_Window.update (inContext, new Graphic.Region (Graphic.Rectangle (m_Window.position.x,
                                                                                   m_Window.position.y,
                                                                                   m_Window.size.width,
                                                                                   m_Window.size.height)));
            }
        }
    }

    internal override void
    on_draw (Graphic.Context inContext, Graphic.Region? inArea) throws Graphic.Error
    {
        // Draw nothing, popup is virtual item to plug window at position
    }

    internal override void
    on_show ()
    {
        // Close all other popup open
        if (s_PopupOpen != null && s_PopupOpen != this)
        {
            s_PopupOpen.visible = false;
        }

        // Set popup has popup open
        s_PopupOpen = this;

        if (m_Window == null)
        {
            // Create window
            create_window ();
        }

        if (m_Content.parent == null)
        {
            m_Content.parent = m_Window;
        }

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

        // Get popup size
        var popup_size = m_Window.size;
        string prop = null;

        if (animation)
        {
            // Set animation property change
            switch (placement)
            {
                case PopupPlacement.BOTTOM:
                    if (m_Y != 0.0)
                    {
                        from = (double)(popup_size.height);
                        to = (double)0.0;
                        prop = "y";
                    }
                    break;

                case PopupPlacement.TOP:
                    if (m_Y != 0.0)
                    {
                        from = (double)(-popup_size.height);
                        to = (double)0.0;
                        prop = "y";
                    }
                    break;

                case PopupPlacement.RIGHT:
                    if (m_X != 0.0)
                    {
                        from = (double)(popup_size.width);
                        to = (double)0.0;
                        prop = "x";
                    }
                    break;

                case PopupPlacement.LEFT:
                    if (m_X != 0.0)
                    {
                        from = (double)(-popup_size.width);
                        to = (double)0.0;
                        prop = "x";
                    }
                    break;
            }
        }

        if (prop != null)
        {
            // Create transition
            m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.SINUSOIDAL, null, on_show_animation_finished);

            // Add property transitrion
            m_Animator.add_transition_property (m_Transition, this, prop, from, to);

            // Start animation
            m_Animator.start ();
        }

        base.on_show ();

        if (prop == null)
        {
            on_show_animation_finished ();
        }
    }

    internal override void
    on_hide ()
    {
        if (s_PopupOpen == this)
        {
            s_PopupOpen = null;
        }

        m_Animator.stop ();

        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }

        GLib.Value from = (double)0;
        GLib.Value to = (double)0;

        string prop = null;
        if (m_Window != null)
        {
            // Get popup size
            var popup_size = m_Window.size;

            if (animation)
            {
                // Set animation property change
                switch (placement)
                {
                    case PopupPlacement.BOTTOM:
                        if (m_Y != popup_size.height)
                        {
                            to = (double)(popup_size.height);
                            from = (double)0.0;
                            prop = "y";
                        }
                        break;

                    case PopupPlacement.TOP:
                        if (m_Y != -popup_size.height)
                        {
                            to = (double)(-popup_size.height);
                            from = (double)0.0;
                            prop = "y";
                        }
                        break;

                    case PopupPlacement.RIGHT:
                        if (m_X != popup_size.width)
                        {
                            to = (double)(popup_size.width);
                            from = (double)0.0;
                            prop = "x";
                        }
                        break;

                    case PopupPlacement.LEFT:
                        if (m_X != -popup_size.width)
                        {
                            to = (double)(-popup_size.width);
                            from = (double)0.0;
                            prop = "x";
                        }
                        break;
                }
            }
        }

        if (prop != null)
        {
            // Create transition
            m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.SINUSOIDAL, null, on_hide_animation_finished);

            // Add property transitrion
            m_Animator.add_transition_property (m_Transition, this, prop, from, to);

            // Start animation
            m_Animator.start ();
        }
        else
        {
            on_hide_animation_finished ();
        }
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
        if (m_Window != null)
        {
            m_Window.visible = false;
        }
    }

    private void
    on_show_animation_finished ()
    {
        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;

            if (m_Window != null && m_Content != null)
            {
                m_Window.grab_focus (m_Content);
            }
        }
    }
}

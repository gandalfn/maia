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
    private Graphic.Point m_InitialPosition = Graphic.Point (0, 0);
    private Graphic.Point m_CurrentPosition = Graphic.Point (0, 0);

    // accessors
    internal override string tag {
        get {
            return "Popup";
        }
    }

    internal double x {
        get {
            return m_CurrentPosition.x;
        }
        set {
            m_CurrentPosition.x = value;
            damage ();
        }
    }

    internal double y {
        get {
            return m_CurrentPosition.y;
        }
        set {
            m_CurrentPosition.y = value;
            damage ();
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
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("content");

        // Create animator
        m_Animator = new Core.Animator (30, 200);

        // Connect onto positon change
        notify["position"].connect (() => {
            m_InitialPosition = position;
        });
    }

    public Popup (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        // we can only only add one item
        return m_Content == null && base.can_append_child (inObject);
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        // the content item was added
        if (can_append_child (inObject) && inObject is Item)
        {
            m_Content = inObject as Item;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        // content item was removed
        if (inObject == m_Content)
        {
            m_Content = null;
        }
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
        if (m_Content != null && (m_Content.position.x != border / 2 || m_Content.position.y != border / 2))
        {
            m_Content.position = Graphic.Point (border / 2, border / 2);
        }

        Graphic.Size content_size = m_Content.size;

        content_size.resize (border, border);

        if (m_Content != null)
        {
            switch (placement)
            {
                case PopupPlacement.BOTTOM:
                    position.translate (Graphic.Point (0, -content_size.height));
                    break;

                case PopupPlacement.TOP:
                    position.translate (Graphic.Point (0, 0));
                    break;

                case PopupPlacement.LEFT:
                    position.translate (Graphic.Point (0, 0));
                    break;

                case PopupPlacement.RIGHT:
                    position.translate (Graphic.Point (-content_size.width, 0));
                    break;
            }
        }

        return content_size;
    }

    internal override void
    on_hide ()
    {
        repair ();
    }

    internal override void
    on_show ()
    {
        damage ();
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            // Get child position and size
            var item_position = m_Content.position;
            var item_size     = inAllocation.extents.size;
            item_size.resize (-border, -border);

            // Set child size allocation
            var child_allocation = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, item_size.width, item_size.height));
            m_Content.update (inContext, child_allocation);

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            var popup_area = area.copy ();
            var path_clip  = new Graphic.Path.from_region (popup_area);
            inContext.clip (path_clip);

            inContext.translate (Graphic.Point (x, y));
            inContext.clip (path_clip);

            base.paint (inContext, inArea);
        }
        inContext.restore ();
    }

    public void
    show ()
    {
        repair ();

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
        var popup_size = size_requested.is_empty () ? size : size_requested;

        // Set animation property change
        switch (placement)
        {
            case PopupPlacement.BOTTOM:
                from = (double)popup_size.height;
                to = (double)0.0;
                m_CurrentPosition.x = 0;
                m_CurrentPosition.y = popup_size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.TOP:
                from = (double)(-popup_size.height);
                to = (double)0.0;
                m_CurrentPosition.x = 0.0;
                m_CurrentPosition.y = - popup_size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.RIGHT:
                from = (double)popup_size.width;
                to = (double)0.0;
                m_CurrentPosition.x = popup_size.width;
                m_CurrentPosition.y = 0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;

            case PopupPlacement.LEFT:
                from = (double)(-popup_size.width);
                to = (double)0.0;
                m_CurrentPosition.x = popup_size.width;
                m_CurrentPosition.y = 0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;
        }

        // Show item
        visible = true;

        // Start animation
        m_Animator.start ();
    }

    public void
    hide ()
    {
        m_Animator.stop ();

        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }

        GLib.Value from = (double)0.0;
        GLib.Value to = (double)0.0;

        // Create transition
        m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.SINUSOIDAL, null, on_hide_animation_finished);

        // Get popup size
        var popup_size = size_requested.is_empty () ? size : size_requested;

        // Set animation property change
        switch (placement)
        {
            case PopupPlacement.BOTTOM:
                to = (double)popup_size.height;
                from = (double)0.0;
                m_CurrentPosition.x = 0.0;
                m_CurrentPosition.y = popup_size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.TOP:
                to = (double)(-popup_size.height);
                from = (double)0.0;
                m_CurrentPosition.x = 0.0;
                m_CurrentPosition.y = - popup_size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.RIGHT:
                to = (double)popup_size.width;
                from = (double)0.0;
                m_CurrentPosition.x = popup_size.width;
                m_CurrentPosition.y = 0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;

            case PopupPlacement.LEFT:
                to = (double)(-popup_size.width);
                from = (double)0.0;
                m_CurrentPosition.x = - popup_size.width;
                m_CurrentPosition.y = 0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;
        }

        // Start animation
        m_Animator.start ();
    }

    private void
    on_hide_animation_finished ()
    {
        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }

        // Hide item
        visible = false;
    }

    private void
    on_show_animation_finished ()
    {
        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
            m_Transition = 0;
        }
    }
}

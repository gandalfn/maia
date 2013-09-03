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
    RIGHT
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

    public double         border    { get; set; default = 0.0; }
    public PopupPlacement placement { get; set; default = PopupPlacement.TOP; }

    // methods
    construct
    {
        m_Animator = new Core.Animator (30, 200);
    }

    public Popup (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));

        notify["position"].connect (() => {
            m_InitialPosition = position;
        });
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
    size_request (Graphic.Size inSize)
    {
        if (m_Content != null)
        {
            m_Content.position = Graphic.Point (border / 2, border / 2);
        }

        Graphic.Size ret = base.size_request (inSize);

        ret.width = double.max (inSize.width, ret.width + border);
        ret.height = double.max (inSize.height, ret.height + border);

        if (m_Content != null)
        {
            switch (placement)
            {
                case PopupPlacement.TOP:
                    position.translate (Graphic.Point (0, -ret.height));
                    break;

                case PopupPlacement.BOTTOM:
                    position.translate (Graphic.Point (0, 0));
                    break;

                case PopupPlacement.RIGHT:
                    position.translate (Graphic.Point (0, 0));
                    break;

                case PopupPlacement.LEFT:
                    position.translate (Graphic.Point (-ret.width, 0));
                    break;
            }
        }

        return ret;
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
            item_size.resize(-border, 0);

            // Set child size allocation
            var child_allocation = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, item_size.width, item_size.height));
            m_Content.update (inContext, child_allocation);

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        inContext.save ();
        {
            var popup_area = geometry.copy ();
            popup_area.translate (geometry.extents.origin.invert ());
            var path_clip  = new Graphic.Path.from_region (popup_area);
            inContext.clip (path_clip);

            inContext.translate (Graphic.Point (x, y));
            inContext.clip (path_clip);

            base.paint (inContext);
        }
        inContext.restore ();
    }

    public void
    show ()
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
        m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.SINUSOIDAL, null, on_show_animation_finished);

        // Set animation property change
        switch (placement)
        {
            case PopupPlacement.TOP:
                from = (double)geometry.extents.size.height;
                to = (double)0.0;
                m_CurrentPosition.x = 0;
                m_CurrentPosition.y = geometry.extents.size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.BOTTOM:
                from = (double)(-geometry.extents.size.height);
                to = (double)0.0;
                m_CurrentPosition.x = 0.0;
                m_CurrentPosition.y = - geometry.extents.size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.LEFT:
                from = (double)geometry.extents.size.width;
                to = (double)0.0;
                m_CurrentPosition.x = geometry.extents.size.width;
                m_CurrentPosition.y = 0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;

            case PopupPlacement.RIGHT:
                from = (double)(-geometry.extents.size.width);
                to = (double)0.0;
                m_CurrentPosition.x = geometry.extents.size.width;
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

        // Set animation property change
        switch (placement)
        {
            case PopupPlacement.TOP:
                to = (double)geometry.extents.size.height;
                from = (double)0.0;
                m_CurrentPosition.x = 0.0;
                m_CurrentPosition.y = geometry.extents.size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.BOTTOM:
                to = (double)(-geometry.extents.size.height);
                from = (double)0.0;
                m_CurrentPosition.x = 0.0;
                m_CurrentPosition.y = - geometry.extents.size.height;
                m_Animator.add_transition_property (m_Transition, this, "y", from, to);
                break;

            case PopupPlacement.LEFT:
                to = (double)geometry.extents.size.width;
                from = (double)0.0;
                m_CurrentPosition.x = geometry.extents.size.width;
                m_CurrentPosition.y = 0.0;
                m_Animator.add_transition_property (m_Transition, this, "x", from, to);
                break;

            case PopupPlacement.RIGHT:
                to = (double)(-geometry.extents.size.width);
                from = (double)0.0;
                m_CurrentPosition.x = - geometry.extents.size.width;
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

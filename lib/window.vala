/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
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

public class Maia.Window : Grid
{
    // properties
    private Core.Event m_DamageEvent;
    private Core.Event m_GeometryEvent;
    private Core.Event m_VisibilityEvent;
    private Core.Event m_DeleteEvent;
    private Core.Event m_DestroyEvent;
    private Core.Event m_MouseEvent;
    private Core.Event m_KeyboardEvent;

    // accessors
    public override string tag {
        get {
            return "Window";
        }
    }

    public virtual Graphic.Surface? surface {
        get {
            return null;
        }
    }

    public Core.Event damage_event {
        get {
            return m_DamageEvent;
        }
        protected set {
            m_DamageEvent = value;
        }
    }

    public Core.Event geometry_event {
        get {
            return m_GeometryEvent;
        }
        protected set {
            m_GeometryEvent = value;
        }
    }

    public Core.Event visibility_event {
        get {
            return m_VisibilityEvent;
        }
        protected set {
            m_VisibilityEvent = value;
        }
    }

    public Core.Event destroy_event {
        get {
            return m_DestroyEvent;
        }
        protected set {
            m_DestroyEvent = value;
        }
    }

    public Core.Event delete_event {
        get {
            return m_DeleteEvent;
        }
        protected set {
            m_DeleteEvent = value;
        }
    }

    public Core.Event mouse_event {
        get {
            return m_MouseEvent;
        }
        protected set {
            m_MouseEvent = value;
        }
    }

    public Core.Event keyboard_event {
        get {
            return m_KeyboardEvent;
        }
        protected set {
            m_KeyboardEvent = value;
        }
    }

    // methods
    construct
    {
        // Subscribe to damage event
        m_DamageEvent.subscribe (on_damage_event);

        // Subscribe to geometry event
        m_GeometryEvent.subscribe (on_geometry_event);

        // Subscribe to visibility event
        m_VisibilityEvent.subscribe (on_visibility_event);

        // Subscribe to delete event
        m_DeleteEvent.subscribe (on_delete_event);

        // Subscribe to destroy event
        m_DestroyEvent.subscribe (on_destroy_event);

        // Subscribe to mouse event
        m_MouseEvent.subscribe (on_mouse_event);
    }

    /**
     * Create a new window
     */
    public Window (string inName, int inWidth, int inHeight)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), size: Graphic.Size (inWidth, inHeight));

        is_movable = true;
        is_resizable = true;
    }

    private void
    on_damage_event (Core.EventArgs? inArgs)
    {
        unowned DamageEventArgs? damage_args = inArgs as DamageEventArgs;

        if (damage_args != null)
        {
            var area = new Graphic.Region (damage_args.area);
            damage (area);
        }
    }

    private void
    on_geometry_event (Core.EventArgs? inArgs)
    {
        unowned GeometryEventArgs? geometry_args = inArgs as GeometryEventArgs;

        if (geometry_args != null)
        {
            if (geometry_args.area.size.width != size_requested.width ||
                geometry_args.area.size.height != size_requested.height)
            {
                size = geometry_args.area.size;
            }
        }
    }

    private void
    on_visibility_event (Core.EventArgs? inArgs)
    {
        unowned VisibilityEventArgs? visibility_args = inArgs as VisibilityEventArgs;

        if (visibility_args != null && visible != visibility_args.visible)
        {
            visible = visibility_args.visible;
        }
    }

    private void
    on_mouse_event (Core.EventArgs? inArgs)
    {
        unowned MouseEventArgs? mouse_args = inArgs as MouseEventArgs;

        if (mouse_args != null)
        {
            if ((mouse_args.flags & MouseEventArgs.EventFlags.MOTION) == MouseEventArgs.EventFlags.MOTION)
            {
                motion_event (mouse_args.position);
            }

            if ((mouse_args.flags & MouseEventArgs.EventFlags.BUTTON_PRESS) == MouseEventArgs.EventFlags.BUTTON_PRESS)
            {
                button_press_event (mouse_args.button, mouse_args.position);
            }

            if ((mouse_args.flags & MouseEventArgs.EventFlags.BUTTON_RELEASE) == MouseEventArgs.EventFlags.BUTTON_RELEASE)
            {
                button_release_event (mouse_args.button, mouse_args.position);
            }
        }
    }

    private void
    on_delete_event (Core.EventArgs? inArgs)
    {
        unowned DeleteEventArgs? delete_args = inArgs as DeleteEventArgs;

        if (delete_args != null)
        {
            delete_args.cancel = false;
        }
    }

    private void
    on_destroy_event (Core.EventArgs? inArgs)
    {
        // disconnect from application
        parent = null;
    }

    internal override void
    on_resize ()
    {
        // Force size request on resize
        var item_size = size;
        geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, item_size.width, item_size.height));

        // Call base on resize which reinitialize geometry
        base.on_resize ();
    }
}

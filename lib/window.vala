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

public class Maia.Window : Group
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
    protected unowned Item? focus_item         { get; set; default = null; }
    protected unowned Item? grab_pointer_item  { get; set; default = null; }
    protected unowned Item? grab_keyboard_item { get; set; default = null; }

    internal override string tag {
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
        m_DamageEvent.object_subscribe (on_damage_event);

        // Subscribe to geometry event
        m_GeometryEvent.object_subscribe (on_geometry_event);

        // Subscribe to visibility event
        m_VisibilityEvent.object_subscribe (on_visibility_event);

        // Subscribe to delete event
        m_DeleteEvent.object_subscribe (on_delete_event);

        // Subscribe to destroy event
        m_DestroyEvent.object_subscribe (on_destroy_event);

        // Subscribe to mouse event
        m_MouseEvent.object_subscribe (on_mouse_event);

        // Subscribe to keyboard event
        m_KeyboardEvent.object_subscribe (on_keyboard_event);

        // Connect onto signals from childs
        set_pointer_cursor.connect (on_set_pointer_cursor);
        move_pointer.connect (on_move_pointer);
        grab_focus.connect (on_grab_focus);
        grab_pointer.connect (on_grab_pointer);
        ungrab_pointer.connect (on_ungrab_pointer);
        grab_keyboard.connect (on_grab_keyboard);
        ungrab_keyboard.connect (on_ungrab_keyboard);
        scroll_to.connect (on_scroll_to);
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

    protected virtual void
    on_damage_event (Core.EventArgs? inArgs)
    {
        unowned DamageEventArgs? damage_args = inArgs as DamageEventArgs;

        if (damage_args != null)
        {
            var area = new Graphic.Region (damage_args.area);
            damage (area);
        }
    }

    protected virtual void
    on_geometry_event (Core.EventArgs? inArgs)
    {
        unowned GeometryEventArgs? geometry_args = inArgs as GeometryEventArgs;

        if (geometry_args != null)
        {
            var item_size = size_requested.is_empty () ? size : size_requested;
            if ((uint32)geometry_args.area.size.width != (uint32)item_size.width ||
                (uint32)geometry_args.area.size.height != (uint32)item_size.height)
            {
                size = geometry_args.area.size;
                geometry = null;
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

    protected virtual void
    on_mouse_event (Core.EventArgs? inArgs)
    {
        unowned MouseEventArgs? mouse_args = inArgs as MouseEventArgs;

        if (mouse_args != null)
        {
            if ((mouse_args.flags & MouseEventArgs.EventFlags.MOTION) == MouseEventArgs.EventFlags.MOTION)
            {
                // we have grab pointer item send event
                if (grab_pointer_item != null)
                {
                    grab_pointer_item.motion_event (grab_pointer_item.convert_to_item_space (mouse_args.position));
                }
                // else send event to window
                else
                {
                    motion_event (convert_to_item_space (mouse_args.position));
                }
            }

            if ((mouse_args.flags & MouseEventArgs.EventFlags.BUTTON_PRESS) == MouseEventArgs.EventFlags.BUTTON_PRESS)
            {
                // we have grab pointer item send event
                if (grab_pointer_item != null)
                {
                    grab_pointer_item.button_press_event (mouse_args.button, grab_pointer_item.convert_to_item_space (mouse_args.position));
                }
                // else send event to window
                else
                {
                    button_press_event (mouse_args.button, convert_to_item_space (mouse_args.position));
                }

                // scroll buttons
                if (mouse_args.button >= 4)
                {
                    Scroll scroll = Scroll.NONE;

                    switch (mouse_args.button)
                    {
                        case 4:
                            scroll = Scroll.UP;
                            break;

                        case 5:
                            scroll = Scroll.DOWN;
                            break;

                        case 6:
                            scroll = Scroll.LEFT;
                            break;

                        case 7:
                            scroll = Scroll.RIGHT;
                            break;
                    }

                    // we have grab pointer item send event
                    if (grab_pointer_item != null)
                    {
                        grab_pointer_item.scroll_event (scroll, grab_pointer_item.convert_to_item_space (mouse_args.position));
                    }
                    // else send event to window
                    else
                    {
                        scroll_event (scroll, convert_to_item_space (mouse_args.position));
                    }
                }
            }

            if ((mouse_args.flags & MouseEventArgs.EventFlags.BUTTON_RELEASE) == MouseEventArgs.EventFlags.BUTTON_RELEASE)
            {
                // we have grab pointer item send event
                if (grab_pointer_item != null)
                {
                    grab_pointer_item.button_release_event (mouse_args.button, grab_pointer_item.convert_to_item_space (mouse_args.position));
                }
                // else send event to window
                else
                {
                    button_release_event (mouse_args.button, convert_to_item_space (mouse_args.position));
                }
            }
        }
    }

    private void
    on_keyboard_event (Core.EventArgs? inArgs)
    {
        unowned KeyboardEventArgs? keyboard_args = inArgs as KeyboardEventArgs;

        if (keyboard_args != null)
        {
            switch (keyboard_args.state)
            {
                case KeyboardEventArgs.State.PRESS:
                    // we have grab keyboard item send event
                    if (grab_keyboard_item != null)
                    {
                        grab_keyboard_item.key_press_event (keyboard_args.key, keyboard_args.character);
                    }
                    // we have focus item send event
                    else if (focus_item != null)
                    {
                        focus_item.key_press_event (keyboard_args.key, keyboard_args.character);
                    }
                    break;

                case KeyboardEventArgs.State.RELEASE:
                    // we have grab keyboard item send event
                    if (grab_keyboard_item != null)
                    {
                        grab_keyboard_item.key_release_event (keyboard_args.key, keyboard_args.character);
                    }
                    // we have focus item send event
                    else if (focus_item != null)
                    {
                        focus_item.key_release_event (keyboard_args.key, keyboard_args.character);
                    }
                    break;
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

    protected virtual void
    on_set_pointer_cursor (Cursor inCursor)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"set pointer cursor $inCursor");
    }

    protected virtual void
    on_move_pointer (Graphic.Point inPosition)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"move pointer to $inPosition");
    }

    protected virtual void
    on_scroll_to (Item inItem)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll to %s", inItem.name);
    }

    protected virtual void
    on_grab_focus (Item? inItem)
    {
        if (inItem is Button)
            return;

        if (inItem == null)
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab focus");
        else
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);

        // Unset item have focus
        if (focus_item != null)
        {
            focus_item.have_focus = false;
        }

        // Set focused item
        focus_item = inItem;

        // Set item have focus
        if (inItem != null)
        {
            focus_item.have_focus = true;
        }

        // Set current item to toolbox
        foreach (unowned Toolbox toolbox in root.find_by_type<Toolbox> (false))
        {
            toolbox.current_item_changed (focus_item);
            break;
        }
    }

    protected virtual bool
    on_grab_pointer (Item inItem)
    {
        bool ret = false;

        // Can grab only nobody have already grab
        if (grab_pointer_item == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
            grab_pointer_item = inItem;
            ret = true;
        }

        return ret;
    }

    protected virtual void
    on_ungrab_pointer (Item inItem)
    {
        if (grab_pointer_item == inItem)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", grab_pointer_item.name);
            grab_pointer_item = null;
        }
    }

    protected virtual bool
    on_grab_keyboard (Item inItem)
    {
        bool ret = false;

        // Only focused item can grab keyboard
        if (grab_keyboard_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab keyboard %s", inItem.name);
            grab_keyboard_item = inItem;
            ret = true;
        }

        return ret;
    }

    protected virtual void
    on_ungrab_keyboard (Item inItem)
    {
        if (grab_keyboard_item == inItem)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab keyboard %s", grab_keyboard_item.name);
            grab_keyboard_item = null;
        }
    }

    internal override void
    on_move ()
    {
    }

    internal override void
    on_resize ()
    {
        // Force size request on resize
        var item_size = size;

        // keep old geometry
        Graphic.Region? old_geometry = geometry != null ? geometry.copy () : null;

        // reset item geometry
        geometry = new Graphic.Region (Graphic.Rectangle (0, 0, item_size.width, item_size.height));

        // damage parent
        if (old_geometry != null) (parent as Item).damage (old_geometry);
    }

    public virtual void
    swap_buffer ()
    {
    }
}

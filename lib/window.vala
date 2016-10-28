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
    // constants
    const double CLOSE_BUTTON_SIZE = 32;
    const double CLOSE_BUTTON_LINE_SIZE = 4;

    // types
    [Flags]
    public enum Border
    {
        NONE,
        LEFT,
        RIGHT,
        TOP,
        BOTTOM,
        ALL = LEFT | RIGHT | TOP | BOTTOM
    }

    public enum Type
    {
        TOPLEVEL,
        POPUP,
        CHILD
    }

    [Flags]
    public enum PositionPolicy
    {
        NONE,
        ALWAYS_CENTER,
        CLAMP_MONITOR
    }

    private class BindKey : Core.Object
    {
        public Modifier m_Modifier;
        public Key m_Key;

        public BindKey (Modifier inModifier, Key inKey)
        {
            m_Modifier = inModifier;
            m_Key = inKey;
        }

        internal override int
        compare (Core.Object inObject)
            requires (inObject is BindKey)
        {
            unowned BindKey other = inObject as BindKey;

            return ((int)m_Modifier - (int)other.m_Modifier) + ((int)m_Key - (int)other.m_Key);
        }
    }

    // properties
    private Core.Animator      m_Animator;
    private uint               m_Transition = 0;
    private Graphic.Surface    m_Background;
    private Graphic.Surface    m_CloseButton;
    private bool               m_OverCloseButton = false;
    private Core.Event         m_DamageEvent;
    private Core.EventListener m_DamageListener;
    private Core.Event         m_GeometryEvent;
    private Core.EventListener m_GeometryListener;
    private Core.Event         m_VisibilityEvent;
    private Core.EventListener m_VisibilityListener;
    private Core.Event         m_DeleteEvent;
    private Core.EventListener m_DeleteListener;
    private Core.Event         m_DestroyEvent;
    private Core.EventListener m_DestroyListener;
    private Core.Event         m_MouseEvent;
    private Core.EventListener m_MouseListener;
    private Core.Event         m_KeyboardEvent;
    private Core.EventListener m_KeyboardListener;
    private Core.Set<BindKey>  m_BindKeys;

    // accessors
    protected unowned ItemFocusable? focus_item { get; set; default = null; }
    protected unowned Item? grab_pointer_item   { get; set; default = null; }
    protected unowned Item? grab_keyboard_item  { get; set; default = null; }

    internal override string tag {
        get {
            return "Window";
        }
    }

    internal double close_button_scale { get; set; default = 0.75; }

    public Type window_type { get; set; default = Type.CHILD; }

    public PositionPolicy position_policy { get; set; default = PositionPolicy.NONE; }

    public unowned uint32 foreign { get; construct; default = 0; }

    public double border { get; set; default = 0.0; }

    public Graphic.Color shadow_color { get; set; default = new Graphic.Color (0, 0, 0); }

    public double shadow_width { get; set; default = 0.0; }

    public Border shadow_border { get; set; default = Border.NONE; }

    public double round_corner { get; set; default = 0.0; }

    public bool close_button { get; set; default = false; }

    public virtual bool decorated { get; set; default = true; }

    public virtual uint8 depth { get; set; }

    public virtual Window? transient_for { get; set; default = null; }

    public virtual Graphic.Surface? surface {
        get {
            return null;
        }
    }

    public unowned Popup? popup {
        get {
            return get_qdata<unowned Popup?> (Item.s_PopupWindow);
        }
    }

    public Graphic.Transform device_transform { get; set; default = new Graphic.Transform.identity (); }

    [CCode (notify = false)]
    public virtual Core.List<unowned Maia.InputDevice>? input_devices { owned get; set; }

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
        not_dumpable_attributes.insert ("device-transform");
        not_dumpable_attributes.insert ("input-device");

        // Create animator
        m_Animator = new Core.Animator (60, 200);

        // Subscribe to damage event
        m_DamageListener = m_DamageEvent.object_subscribe (on_damage_event);

        // Subscribe to geometry event
        m_GeometryListener = m_GeometryEvent.object_subscribe (on_geometry_event);

        // Subscribe to visibility event
        m_VisibilityListener = m_VisibilityEvent.object_subscribe (on_visibility_event);

        // Subscribe to delete event
        m_DeleteListener = m_DeleteEvent.object_subscribe (on_delete_event);

        // Subscribe to destroy event
        m_DestroyListener = m_DestroyEvent.object_subscribe (on_destroy_event);

        // Subscribe to mouse event
        m_MouseListener = m_MouseEvent.object_subscribe (on_mouse_event);

        // Subscribe to keyboard event
        m_KeyboardListener = m_KeyboardEvent.object_subscribe (on_keyboard_event);

        // Connect onto signals from childs
        set_pointer_cursor.connect (on_set_pointer_cursor);
        move_pointer.connect (on_move_pointer);
        grab_focus.connect (on_grab_focus);
        grab_pointer.connect (on_grab_pointer);
        ungrab_pointer.connect (on_ungrab_pointer);
        grab_keyboard.connect (on_grab_keyboard);
        ungrab_keyboard.connect (on_ungrab_keyboard);
        scroll_to.connect (on_scroll_to);

        // Connect onto close button scale changed
        notify["close-button-scale"].connect (on_close_button_scale_changed);

        // On background pattern changed recreate close button
        notify["background-pattern"].connect (create_close_button);

        // On stroke pattern changed recreate close button
        notify["stroke-pattern"].connect (create_close_button);
    }

    /**
     * Create a new window
     */
    public Window (string inName, int inWidth, int inHeight)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), size: Graphic.Size (inWidth, inHeight));

        is_movable = true;
        is_resizable = true;

        create_close_button ();
    }

    /**
     * Create a foreign window
     */
    public Window.from_foreign (string inName, uint32 inForeign)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), foreign: inForeign);

        is_movable = true;
        is_resizable = true;
    }

    ~Window ()
    {
        if (m_DamageListener != null) m_DamageListener.parent = null;
        if (m_GeometryListener != null) m_GeometryListener.parent = null;
        if (m_VisibilityListener != null) m_VisibilityListener.parent = null;
        if (m_DeleteListener != null) m_DeleteListener.parent = null;
        if (m_DestroyListener != null) m_DestroyListener.parent = null;
        if (m_MouseListener != null) m_MouseListener.parent = null;
        if (m_KeyboardListener != null) m_KeyboardListener.parent = null;
    }

    private void
    on_close_button_scale_changed ()
    {
        if (visible)
        {
            var button_area = Graphic.Rectangle (area.extents.size.width - shadow_width - (CLOSE_BUTTON_SIZE + CLOSE_BUTTON_LINE_SIZE) / 2.0,
                                                 shadow_width - (CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0,
                                                 CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE);
            damage_area (new Graphic.Region (button_area));
        }
    }

    private void
    create_close_button ()
    {
        try
        {
            m_CloseButton = new Graphic.Surface ((uint)CLOSE_BUTTON_SIZE, (uint)CLOSE_BUTTON_SIZE);
            m_CloseButton.clear ();

            var background = new Graphic.Path ();
            background.arc (CLOSE_BUTTON_SIZE / 2.0, CLOSE_BUTTON_SIZE / 2.0,
                            ((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0), ((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0),
                            0, 2 * GLib.Math.PI);

            var foreground = new Graphic.Path ();
            foreground.arc (CLOSE_BUTTON_SIZE / 2.0, CLOSE_BUTTON_SIZE / 2.0,
                            ((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0), ((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0),
                            0, 2 * GLib.Math.PI);
            foreground.move_to (CLOSE_BUTTON_SIZE / 2.0, CLOSE_BUTTON_SIZE / 2.0);
            foreground.rel_line_to (-(((CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE) / 2.0),
                                    -(((CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE) / 2.0));
            foreground.rel_line_to ((CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE,
                                    (CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE);
            foreground.move_to (CLOSE_BUTTON_SIZE / 2.0, CLOSE_BUTTON_SIZE / 2.0);
            foreground.rel_line_to (((CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE) / 2.0,
                                    -(((CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE) / 2.0));
            foreground.rel_line_to (-((CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE),
                                    (CLOSE_BUTTON_SIZE / 2.0) - CLOSE_BUTTON_LINE_SIZE);

            var ctx = m_CloseButton.context;
            ctx.pattern = background_pattern[state] ?? new Graphic.Color (1, 1, 1);
            ctx.fill (background);
            ctx.line_width = CLOSE_BUTTON_LINE_SIZE;
            ctx.pattern = stroke_pattern[state] ?? new Graphic.Color (0, 0, 0);
            ctx.stroke (foreground);
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"Error on create window close button: $(err.message)");
        }
    }

    protected virtual void
    on_damage_event (Core.EventArgs? inArgs)
    {
        unowned DamageEventArgs? damage_args = inArgs as DamageEventArgs;

        if (damage_args != null)
        {
            try
            {
                // the area is in window with transform
                // invert the window transform to have area in window coordinate space
                Graphic.Rectangle damage_area = damage_args.area;
                var matrix = transform.matrix;
                matrix.invert ();
                damage_area.transform (new Graphic.Transform.from_matrix (matrix));

                var area = new Graphic.Region (damage_area);
                damage.post (area);

#if MAIA_DEBUG
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"$name damage event $(area.extents)");
#endif
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"error on convert damage area in window coordinate space : $(err.message)");
            }
        }
    }

    protected virtual void
    on_geometry_event (Core.EventArgs? inArgs)
    {
        unowned GeometryEventArgs? geometry_args = inArgs as GeometryEventArgs;

        if (geometry_args != null && geometry != null && window == null)
        {
            try
            {
                // the size is in window with transform
                // invert the window transform to have size in window coordinate space
                Graphic.Size window_size = geometry_args.area.size;
                window_size.transform (new Graphic.Transform.invert (transform));

                if ((uint32)GLib.Math.ceil (geometry_args.area.origin.x) != (uint32)GLib.Math.ceil (position.x) ||
                    (uint32)GLib.Math.ceil (geometry_args.area.origin.y) != (uint32)GLib.Math.ceil (position.y))
                {
                    position = geometry_args.area.origin;
                }

                if ((uint32)GLib.Math.ceil (window_size.width)  != (uint32)GLib.Math.ceil (size.width) ||
                    (uint32)GLib.Math.ceil (window_size.height) != (uint32)GLib.Math.ceil (size.height))
                {
                    need_update = true;
                    size = window_size;
                }
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"error on convert size in window coordinate space : $(err.message)");
            }
        }
    }

    protected virtual void
    on_visibility_event (Core.EventArgs? inArgs)
    {
    }

    protected virtual void
    on_mouse_event (Core.EventArgs? inArgs)
    {
        unowned MouseEventArgs? mouse_args = inArgs as MouseEventArgs;

        if (mouse_args != null && visible)
        {
            var pos = mouse_args.position;

            try
            {
                // the current mouse position is in window with transform
                // invert the window transform to have position in window coordinate space
                pos.transform (new Graphic.Transform.invert (transform));

                // window is under popup invert parent transform
                if (popup != null)
                {
                    pos.transform (new Graphic.Transform.from_matrix (popup.get_window_transform ().matrix_invert));
                }

                // Motion event
                if ((mouse_args.flags & MouseEventArgs.EventFlags.MOTION) == MouseEventArgs.EventFlags.MOTION)
                {
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"$name $pos");
#endif

                    // we have grab pointer item send event
                    if (grab_pointer_item != null)
                    {
                        print(@"$name window grab $(grab_pointer_item.name) mouse event: $(pos) position: $(mouse_args.position)\n");
                        grab_pointer_item.motion_event (grab_pointer_item.convert_from_window_space (mouse_args.position));
                    }
                    // else send event to window
                    else
                    {
                        var item_area = area;
                        if (item_area != null &&
                            pos.x >= item_area.extents.size.width - shadow_width - (((CLOSE_BUTTON_SIZE + CLOSE_BUTTON_LINE_SIZE) / 2.0) * close_button_scale) &&
                            pos.y >= shadow_width - (((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0) * close_button_scale) &&
                            pos.x < item_area.extents.size.width - shadow_width - (((CLOSE_BUTTON_SIZE + CLOSE_BUTTON_LINE_SIZE) / 2.0) * close_button_scale) + (CLOSE_BUTTON_SIZE * close_button_scale) &&
                            pos.y < shadow_width - (((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0) * close_button_scale) + (CLOSE_BUTTON_SIZE * close_button_scale))
                        {
                            if (!m_OverCloseButton)
                            {
                                m_OverCloseButton = true;

                                m_Animator.stop ();

                                if (m_Transition > 0)
                                {
                                    m_Animator.remove_transition (m_Transition);
                                    m_Transition = 0;
                                }

                                GLib.Value from = (double)close_button_scale;
                                GLib.Value to = (double)1.0;

                                m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.EASE_IN_EASE_OUT, null, null);
                                m_Animator.add_transition_property (m_Transition, this, "close-button-scale", from, to);
                                m_Animator.start ();
                            }
                        }
                        else
                        {
                            if (m_OverCloseButton)
                            {
                                m_OverCloseButton = false;

                                m_Animator.stop ();

                                if (m_Transition > 0)
                                {
                                    m_Animator.remove_transition (m_Transition);
                                    m_Transition = 0;
                                }

                                GLib.Value from = (double)close_button_scale;
                                GLib.Value to = (double)0.75;

                                m_Transition = m_Animator.add_transition (0.0, 1.0, Core.Animator.ProgressType.EXPONENTIAL, null, null);
                                m_Animator.add_transition_property (m_Transition, this, "close-button-scale", from, to);
                                m_Animator.start ();
                            }

                            print(@"$name window mouse event: $(pos) position: $(mouse_args.position)\n");
                            motion_event (pos);
                        }
                    }
                }

                // Button press event
                if ((mouse_args.flags & MouseEventArgs.EventFlags.BUTTON_PRESS) == MouseEventArgs.EventFlags.BUTTON_PRESS)
                {
                    // we have grab pointer item send event
                    if (grab_pointer_item != null)
                    {
                        print(@"$name window grab $(grab_pointer_item.name) button press event: $(pos) position: $(mouse_args.position)\n");
                        grab_pointer_item.button_press_event (mouse_args.button, grab_pointer_item.convert_from_window_space (mouse_args.position));
                    }
                    // else send event to window
                    else
                    {
                        print(@"$name window button press: $(pos) position: $(mouse_args.position)\n");
                        button_press_event (mouse_args.button, pos);
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
                            grab_pointer_item.scroll_event (scroll, grab_pointer_item.convert_from_window_space (pos));
                        }
                        // else send event to window
                        else
                        {
                            scroll_event (scroll, pos);
                        }
                    }
                }

                // Button release event
                if ((mouse_args.flags & MouseEventArgs.EventFlags.BUTTON_RELEASE) == MouseEventArgs.EventFlags.BUTTON_RELEASE)
                {
                    // we have grab pointer item send event
                    if (grab_pointer_item != null)
                    {
                        grab_pointer_item.button_release_event (mouse_args.button, grab_pointer_item.convert_from_window_space (mouse_args.position));
                    }
                    // else send event to window
                    else if (m_OverCloseButton)
                    {
                        visible = false;
                    }
                    else
                    {
                        button_release_event (mouse_args.button, pos);
                    }
                }
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"error on convert position in window coordinate space : $(err.message)");
            }
        }
    }

    protected virtual void
    on_keyboard_event (Core.EventArgs? inArgs)
    {
        unowned KeyboardEventArgs? keyboard_args = inArgs as KeyboardEventArgs;

        if (keyboard_args != null && visible)
        {
            switch (keyboard_args.state)
            {
                case KeyboardEventArgs.State.PRESS:
                    var bind = new BindKey (keyboard_args.modifier, keyboard_args.key);

                    if (m_BindKeys != null && bind in m_BindKeys)
                    {
                        key_press_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    // we have grab keyboard item send event
                    else if (grab_keyboard_item != null)
                    {
                        grab_keyboard_item.key_press_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    // we have focus item send event
                    else if (focus_item != null)
                    {
                        focus_item.key_press_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    else
                    {
                        key_press_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    break;

                case KeyboardEventArgs.State.RELEASE:
                    var bind = new BindKey (keyboard_args.modifier, keyboard_args.key);

                    if (m_BindKeys != null && bind in m_BindKeys)
                    {
                        key_release_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    // we have grab keyboard item send event
                    if (grab_keyboard_item != null)
                    {
                        grab_keyboard_item.key_release_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    // we have focus item send event
                    else if (focus_item != null)
                    {
                        focus_item.key_release_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    else
                    {
                        key_release_event (keyboard_args.modifier, keyboard_args.key, keyboard_args.character);
                    }
                    break;
            }
        }
    }

    protected virtual void
    on_delete_event (Core.EventArgs? inArgs)
    {
        unowned DeleteEventArgs? delete_args = inArgs as DeleteEventArgs;

        if (delete_args != null)
        {
            delete_args.cancel = false;
        }
    }

    protected virtual void
    on_destroy_event (Core.EventArgs? inArgs)
    {
        // disconnect from application
        parent = null;
    }

    protected virtual void
    on_set_pointer_cursor (Cursor inCursor)
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"set pointer cursor $inCursor");
#endif
    }

    protected virtual void
    on_move_pointer (Graphic.Point inBorder)
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"move pointer to $inBorder");
#endif
    }

    protected virtual void
    on_scroll_to (Item inItem)
    {
#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll to %s", inItem.name);
#endif
    }

    protected virtual void
    on_grab_focus (Item? inItem)
    {
        unowned ItemFocusable? item = inItem as ItemFocusable;

        if (item != null && item is Button)
            return;

#if MAIA_DEBUG
        if (item == null)
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab focus");
        else
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);
#endif

        // Unset item have focus
        if (focus_item != null)
        {
            focus_item.have_focus = false;
        }

        // Set focused item
        focus_item = item;

        // Set item have focus
        if (focus_item != null)
        {
            focus_item.have_focus = true;
        }
    }

    protected virtual bool
    on_grab_pointer (Item inItem)
    {
        bool ret = false;

        // Can grab only nobody have already grab
        if (grab_pointer_item == null)
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
#endif
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
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", grab_pointer_item.name);
#endif
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
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab keyboard %s", inItem.name);
#endif
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
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab keyboard %s", grab_keyboard_item.name);
#endif
            grab_keyboard_item = null;
        }
    }

    internal override int
    compare (Core.Object inOther)
    {
        unowned Window? other = inOther as Window;
        if (other != null)
        {
            return 0;
        }

        return base.compare (inOther);
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Region area = new Graphic.Region ();

        double x1_border = border + (!(Border.LEFT in shadow_border) ? 0 : shadow_width);
        double y1_border = border + (!(Border.TOP in shadow_border) ? 0 : shadow_width);

        foreach (unowned Core.Object child in this)
        {
            if (child is Item && !(child is Popup))
            {
                unowned Item item = (Item)child;
                Graphic.Point item_position = item.position;

                if (item_position.x < x1_border || item_position.y < y1_border)
                {
                    if (item_position.x < x1_border) item_position.x = x1_border;
                    if (item_position.y < y1_border) item_position.y = y1_border;
                    item.position = item_position;
                }

                Graphic.Size item_size = item.size;

                area.union_with_rect (Graphic.Rectangle (0, 0, item_position.x + item_size.width, item_position.y + item_size.height));
            }
        }

        var ret = area.extents.size;
        ret.resize (border + (!(Border.RIGHT in shadow_border) ? 0 : shadow_width),
                    border + (!(Border.BOTTOM in shadow_border) ? 0 : shadow_width));

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "window: %s %s", name, ret.to_string ());
#endif

        return ret;
    }

    internal override void
    on_hide ()
    {
        base.on_hide ();

        // We have a focus item unset
        if (focus_item != null)
        {
            grab_focus (null);
        }

        // We have a grab pointer
        if (grab_pointer_item != null)
        {
            ungrab_pointer (grab_pointer_item);
        }

        // We have a grab keyboard
        if (grab_keyboard_item != null)
        {
            ungrab_keyboard (grab_keyboard_item);
        }

        if (m_Animator != null)
        {
            m_Animator.stop ();

            if (m_Transition > 0)
            {
                m_Animator.remove_transition (m_Transition);
                m_Transition = 0;
            }
        }

        m_OverCloseButton = false;

        close_button_scale = 0.75;
    }

    internal override void
    on_move ()
    {
    }

    internal override void
    on_resize ()
    {
        // keep old geometry
        Graphic.Region? old_geometry = geometry != null ? geometry.copy () : null;

        // damage parent
        if (old_geometry != null && parent != null && parent is Item) (parent as Item).damage.post (old_geometry);

        // reset item geometry
        need_update = true;
    }

    internal override void
    on_draw (Graphic.Context inContext, Graphic.Region? inArea) throws Graphic.Error
    {
        if (visible && geometry != null && !geometry.is_empty () && damaged != null && !damaged.is_empty ())
        {
            var ctx = surface.context;

            var damaged_area = damaged.copy ();
            if (inArea != null)
            {
                damaged_area.intersect (inArea);
            }

            if (!damaged_area.is_empty ())
            {
                Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, @"window $name damaged draw $(damaged_area.extents)");

                ctx.save ();
                {
                    ctx.line_width = line_width;
                    ctx.transform = device_transform;

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

                    // Clip the damaged area
                    ctx.clip_region (damaged_area);

                    if (m_Background != null)
                    {
                        ctx.pattern = m_Background;
                        ctx.paint ();
                    }
                    else
                    {
                        ctx.pattern = background_pattern[state] != null ? background_pattern[state] : new Graphic.Color (0, 0, 0, 0);
                        ctx.paint ();
                    }

                    // Set paint over by default
                    ctx.operator = Graphic.Operator.OVER;

                    // and paint content
                    paint (ctx, damaged_area);
                }
                ctx.restore ();

                repair.post (damaged_area);
            }
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (!inAllocation.extents.is_empty () && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            Graphic.Region item_area = area;

            // Paint shadow if needed
            if (shadow_width > 0)
            {
                m_Background = new Graphic.Surface ((uint)area.extents.size.width, (uint)area.extents.size.height);
                m_Background.clear ();
                var ctx = m_Background.context;
                ctx.operator = Graphic.Operator.SOURCE;

                var shadow_area = Graphic.Rectangle (!(Border.LEFT in shadow_border) ? 0 : shadow_width,
                                                     !(Border.TOP in shadow_border) ? 0 : shadow_width,
                                                     item_area.extents.size.width - ((!(Border.RIGHT in shadow_border) ? 0 : shadow_width) * 2),
                                                     item_area.extents.size.height - ((!(Border.BOTTOM in shadow_border) ? 0 : shadow_width) * 2));
                var path = new Graphic.Path ();
                path.rectangle (shadow_area.origin.x, shadow_area.origin.y, shadow_area.size.width, shadow_area.size.height, round_corner > 0 ? round_corner : 0, round_corner > 0 ? round_corner : 0);

                if (!(Border.LEFT in shadow_border))
                {
                    if (!(Border.TOP in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x, shadow_area.origin.y, round_corner, round_corner);
                    }
                    if (!(Border.BOTTOM in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x, shadow_area.origin.y + shadow_area.size.height - round_corner, round_corner, round_corner);
                    }
                }

                if (!(Border.RIGHT in shadow_border))
                {
                    if (!(Border.TOP in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x + shadow_area.size.width - round_corner, shadow_area.origin.y, round_corner, round_corner);
                    }
                    if (!(Border.BOTTOM in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x + shadow_area.size.width - round_corner, shadow_area.origin.y + shadow_area.size.height - round_corner, round_corner, round_corner);
                    }
                }

                if (!(Border.TOP in shadow_border))
                {
                    if (!(Border.LEFT in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x, shadow_area.origin.y, round_corner, round_corner);
                    }
                    if (!(Border.RIGHT in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x + shadow_area.size.width - round_corner, shadow_area.origin.y, round_corner, round_corner);
                    }
                }

                if (!(Border.BOTTOM in shadow_border))
                {
                    if (!(Border.LEFT in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x, shadow_area.origin.y + shadow_area.size.height - round_corner, round_corner, round_corner);
                    }
                    if (!(Border.RIGHT in shadow_border))
                    {
                        path.rectangle (shadow_area.origin.x + shadow_area.size.width - round_corner, shadow_area.origin.y + shadow_area.size.height - round_corner, round_corner, round_corner);
                    }
                }

                ctx.pattern = shadow_color ?? new Graphic.Color (0, 0, 0);
                ctx.fill (path);

                m_Background.exponential_blur ((int)(shadow_width / 2));

                ctx.operator = Graphic.Operator.SOURCE;
                ctx.pattern = background_pattern[state] != null ? background_pattern[state] : new Graphic.Color (0, 0, 0, 0);
                ctx.fill (path);
            }

            foreach (unowned Core.Object child in this)
            {
                if (child is Item && !(child is Popup))
                {
                    unowned Item item = (Item)child;

                    // Get child position and size
                    var item_position = item.position;
                    var item_size     = item.size;

                    // Set child size allocation
                    var area_size = item_area.extents.size;
                    area_size.resize (-(border + (!(Border.LEFT in shadow_border) ? 0 : shadow_width) + border + (!(Border.RIGHT in shadow_border) ? 0 : shadow_width)),
                                      -(border + (!(Border.TOP in shadow_border) ? 0 : shadow_width) + border + (!(Border.BOTTOM in shadow_border) ? 0 : shadow_width)));

                    var child_allocation = Graphic.Rectangle (item_position.x, item_position.y,
                                                              item_position.x + item_size.width < (area_size.width - (border + (!(Border.RIGHT in shadow_border) ? 0 : shadow_width))) ? area_size.width : item_size.width,
                                                              item_position.y + item_size.height < (area_size.height - (border + (!(Border.BOTTOM in shadow_border) ? 0 : shadow_width))) ? area_size.height : item_size.height);

                    // Update child allocation
                    item.update (inContext, new Graphic.Region (child_allocation));
                }
                else if (child is Popup)
                {
                    unowned Popup popup = (Popup)child;

                    // Get child position and size
                    var popup_position = popup.position;
                    var popup_size     = popup.content.size;

                    var popup_allocation = Graphic.Rectangle (popup_position.x, popup_position.y, popup_size.width, popup_size.height);
                    popup.update (inContext, new Graphic.Region (popup_allocation));
                }
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Drawable)
            {
                unowned Drawable drawable = (Drawable)child;

                var child_area = area_to_child_item_space (drawable, inArea);
                drawable.draw (inContext, child_area);
            }
        }

        // Draw close button
        if (close_button)
        {
            inContext.save ();
            {
                var button_pos = Graphic.Point (area.extents.size.width - shadow_width - (((CLOSE_BUTTON_SIZE + CLOSE_BUTTON_LINE_SIZE) / 2.0) * close_button_scale),
                                                shadow_width - (((CLOSE_BUTTON_SIZE - CLOSE_BUTTON_LINE_SIZE) / 2.0) * close_button_scale));

                inContext.operator = Graphic.Operator.OVER;
                inContext.translate (button_pos);
                inContext.transform = new Graphic.Transform.init_scale (close_button_scale, close_button_scale);
                inContext.pattern = m_CloseButton;
                inContext.paint ();
            }
            inContext.restore ();
        }
    }

    public virtual bool
    grab_key (Modifier inModifier, Key inKey)
    {
        bool ret = false;

        if (m_BindKeys == null)
        {
            m_BindKeys = new Core.Set<BindKey> ();
        }
        var bind = new BindKey (inModifier, inKey);
        if (!(bind in m_BindKeys))
        {
            m_BindKeys.insert (bind);
            ret = true;
        }

        return ret;
    }

    public virtual bool
    ungrab_key (Modifier inModifier, Key inKey)
    {
        bool ret = false;

        if (m_BindKeys == null)
        {
            m_BindKeys = new Core.Set<BindKey> ();
        }
        var bind = new BindKey (inModifier, inKey);
        if (bind in m_BindKeys)
        {
            m_BindKeys.remove (bind);
            ret = true;
        }

        return ret;
    }

    public virtual void
    swap_buffer ()
    {
    }

    public virtual void
    flush ()
    {
    }
}

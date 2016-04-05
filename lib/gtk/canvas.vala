/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * canvas.vala
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

internal class Maia.Gtk.Canvas : global::Gtk.Widget, Maia.Canvas
{
    // properties
    private unowned global::Gtk.Widget? m_Toplevel = null;
    private bool m_HaveFocus = false;
    private Window m_WindowGate = null;
    private Window m_Window = null;
    private Item? m_Root = null;
    private Core.Notifications m_Notifications = new Core.Notifications ();

    // accessors
    internal new Window window {
        get {
            return m_Window;
        }
    }

    internal Item root {
        get {
            return m_Root;
        }
        set {
            if (m_Root != null)
            {
                m_Root.parent = null;
            }
            m_Root = value;
            if (m_Window != null && m_Root != null)
            {
                m_Root.parent = m_Window;
                GLib.Signal.emit_by_name (m_Window, "notify::window");
            }

            queue_resize ();
        }
    }

    internal Core.Notifications notifications {
        get {
            return m_Notifications;
        }
    }

    // methods
    construct
    {
        set_has_window (true);
        can_focus = true;
    }

    public Canvas ()
    {
    }

    ~Canvas ()
    {
        if (m_Window != null)
        {
            m_Window.parent = null;
        }
    }

    private static inline void
    send_keyboard_event (Gdk.Window inWindow, Gdk.EventKey inEvent)
    {
        X.Event? evt = X.Event ();
        unowned X.KeyEvent? xkey = (X.KeyEvent?)evt;

        xkey.type = (inEvent.type == Gdk.EventType.KEY_PRESS) ? X.EventType.KeyPress : X.EventType.KeyRelease;
        xkey.window = Gdk.x11_drawable_get_xid (inWindow);
        xkey.root = Gdk.x11_drawable_get_xid (inWindow.get_screen ().get_root_window ());
        xkey.subwindow = X.None;
        xkey.time = inEvent.time;
        xkey.x = 0;
        xkey.y = 0;
        xkey.x_root = 0;
        xkey.y_root = 0;
        xkey.state = inEvent.state;
        xkey.keycode = inEvent.hardware_keycode;
        xkey.same_screen = true;

        Gdk.error_trap_push ();
        Gdk.x11_display_get_xdisplay(inWindow.get_display ()).send_event (Gdk.x11_drawable_get_xid (inWindow), true, X.EventMask.KeyPressMask | X.EventMask.KeyReleaseMask, ref evt);
        inWindow.get_display ().sync ();
        Gdk.error_trap_pop ();
    }

    private void
    on_window_grab_focus (Item? inItem)
    {
        // Set widget has focus
        if (inItem != null)
        {
            grab_focus ();
        }
    }

    private void
    on_focus_changed ()
    {
        // On widget focus lost unset all item with grab focus
        // and then parent can regrab input focus
        if (!is_focus)
        {
            m_Window.grab_focus (null);
            m_HaveFocus = false;
        }
    }

    private bool
    on_key_press_event (Gdk.EventKey inEvent)
    {
        if (m_Window != null && m_HaveFocus)
        {
            uint32 xid;
            m_Window.get ("xid", out xid);

            send_keyboard_event (Gdk.Window.foreign_new ((Gdk.NativeWindow)xid), inEvent);
        }

        return false;
    }

    private bool
    on_key_release_event (Gdk.EventKey inEvent)
    {
        if (m_Window != null && m_HaveFocus)
        {
            uint32 xid;
            m_Window.get ("xid", out xid);

            send_keyboard_event (Gdk.Window.foreign_new ((Gdk.NativeWindow)xid), inEvent);
        }

        return false;
    }

    private void
    on_window_focus_changed (global::Gtk.Widget? inWidget)
    {
        if (m_HaveFocus != (inWidget == this))
        {
            m_HaveFocus = inWidget == this;

            // On widget focus lost unset all item with grab focus
            // and then parent can regrab input focus
            if (!m_HaveFocus)
            {
                m_Window.grab_focus (null);
            }
        }
    }

    private void
    on_toplevel_map ()
    {
        if (is_realized () && is_mapped () && visible)
        {
            window.visible = true;
        }
    }

    private void
    on_toplevel_unmap ()
    {
        window.visible = false;
    }

    internal override void
    realize ()
    {
        Gdk.WindowAttr attributes = Gdk.WindowAttr ();

        // Set widget was realized
        set_realized (true);
        set_has_window (true);

        // Create widget window
        attributes.visual = get_visual ();
        attributes.colormap = get_colormap ();
        attributes.x = allocation.x;
        attributes.y = allocation.y;
        attributes.width = allocation.width;
        attributes.height = allocation.height;
        attributes.wclass = Gdk.WindowClass.INPUT_OUTPUT;
        attributes.window_type = Gdk.WindowType.CHILD;
        attributes.event_mask = Gdk.EventMask.FOCUS_CHANGE_MASK;
        int attributes_mask = Gdk.WindowAttributesType.X        |
                              Gdk.WindowAttributesType.Y        |
                              Gdk.WindowAttributesType.COLORMAP |
                              Gdk.WindowAttributesType.VISUAL;

        // widget window
        ((global::Gtk.Widget)this).window = new Gdk.Window (get_parent_window (), attributes, attributes_mask);
        ((global::Gtk.Widget)this).window.set_user_data (this);
        ((global::Gtk.Widget)this).window.set_back_pixmap (null, false);
        style = style.attach (((global::Gtk.Widget)this).window);

        ((global::Gtk.Widget)this).window.get_display ().sync ();

        hierarchy_changed (get_toplevel ());

        // Create gate window from gtk window
        m_WindowGate = new Window.from_foreign (@"$name-gtk-canvas-parent", (uint32)Gdk.x11_drawable_get_xid (((global::Gtk.Widget)this).window));

        // Create maia window
        m_Window = new Maia.Window (@"$name-gtk-canvas-window", allocation.width, allocation.height);
        m_Window.visible = false;
        m_Window.depth = (uint8)get_visual ().get_depth ();
        var color_bg = style.bg[global::Gtk.StateType.NORMAL];
        m_Window.background_pattern[State.NORMAL] = new Graphic.Color ((double)color_bg.red / 65535.0, (double)color_bg.green / 65535.0, (double)color_bg.blue / 65535.0);
        m_Window.position = Graphic.Point (0, 0);
        m_Window.size = Graphic.Size (allocation.width, allocation.height);
        m_Window.grab_focus.connect (on_window_grab_focus);

        // Set canvas window
        m_Window.set_data<unowned Window?> ("MaiaCanvasWindow", m_WindowGate);
        GLib.Signal.emit_by_name (m_Window, "notify::window");

        // Set root parent has window
        if (m_Root != null) m_Root.parent = m_Window;

        m_Window.flush ();

        // Add window to application in same time this launch window notify for reparent
        Application.@default.add (m_Window);
    }

    internal override void
    unrealize ()
    {
        if (m_Root != null)
        {
            m_Root.parent = null;
        }

        m_Root = null;

        if (m_Window != null)
        {
            m_Window.parent = null;
        }

        m_Window = null;

        m_WindowGate = null;

        base.unrealize ();
    }

    internal override void
    hierarchy_changed (global::Gtk.Widget? inOldTopLevel)
    {
        if (m_Toplevel != get_toplevel ())
        {
            if (m_Toplevel != null)
            {
                if (m_Toplevel is global::Gtk.Window)
                {
                    (m_Toplevel as global::Gtk.Window).set_focus.connect  (on_window_focus_changed);
                }
                m_Toplevel.map.disconnect  (on_toplevel_map);
                m_Toplevel.unmap.disconnect  (on_toplevel_unmap);
                m_Toplevel.notify["is-focus"].disconnect (on_focus_changed);
                m_Toplevel.key_press_event.disconnect (on_key_press_event);
                m_Toplevel.key_release_event.disconnect (on_key_release_event);
            }

            m_Toplevel = get_toplevel ();
            if (m_Toplevel != null)
            {
                if (m_Toplevel is global::Gtk.Window)
                {
                    (m_Toplevel as global::Gtk.Window).set_focus.connect  (on_window_focus_changed);
                }
                m_Toplevel.map.connect_after  (on_toplevel_map);
                m_Toplevel.unmap.connect_after  (on_toplevel_unmap);
                m_Toplevel.notify["is-focus"].connect (on_focus_changed);
                m_Toplevel.key_press_event.connect (on_key_press_event);
                m_Toplevel.key_release_event.connect (on_key_release_event);
            }
        }
    }

    internal override void
    map ()
    {
        base.map ();

        m_Window.visible = true;
    }

    internal override void
    unmap ()
    {
        m_Window.visible = false;

        base.unmap ();
    }

    internal override void
    size_request (out global::Gtk.Requisition outRequisition)
    {
        outRequisition = global::Gtk.Requisition ();
        if (window != null)
        {
            outRequisition.width = (int)(window.size.width);
            outRequisition.height = (int)(window.size.height);
        }

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "canvas size: %i,%i", outRequisition.width, outRequisition.height);
#endif
    }

    internal override void
    size_allocate (Gdk.Rectangle inAllocation)
    {
        allocation = (global::Gtk.Allocation)inAllocation;

        if (get_realized ())
        {
            ((global::Gtk.Widget)this).window.move_resize (inAllocation.x, inAllocation.y, inAllocation.width, inAllocation.height);

            m_Window.position = Graphic.Point (0, 0);
            m_Window.size = Graphic.Size (inAllocation.width, inAllocation.height);

#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"window size: $(inAllocation.width) $(inAllocation.height)");
#endif
        }

#if MAIA_DEBUG
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"alllocation: $(inAllocation.x) $(inAllocation.y) $(inAllocation.width) $(inAllocation.height)");
#endif
    }
}

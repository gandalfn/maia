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
    private Window m_WindowGate = null;
    private Window m_Window = null;
    private Item m_Root = null;

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
            }

            queue_resize ();
        }
    }

    // methods
    construct
    {
        set_has_window (true);
        can_focus = true;
        has_focus = true;

        notify["is-focus"].connect (on_focus_changed);
    }

    public Canvas ()
    {
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
        Gdk.x11_display_get_xdisplay(inWindow.get_display ()).send_event (Gdk.x11_drawable_get_xid (inWindow), false, X.EventMask.NoEventMask, ref evt);
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
        }
    }

    internal override void
    realize ()
    {
        Gdk.WindowAttr attributes = Gdk.WindowAttr ();

        // Set widget was realized
        set_realized (true);

        // Create widget window
        attributes.visual = get_visual ();
        attributes.colormap = get_colormap ();
        attributes.x = allocation.x;
        attributes.y = allocation.y;
        attributes.width = allocation.width;
        attributes.height = allocation.height;
        attributes.wclass = Gdk.WindowClass.INPUT_OUTPUT;
        attributes.window_type = Gdk.WindowType.CHILD;
        attributes.event_mask = Gdk.EventMask.STRUCTURE_MASK | Gdk.EventMask.FOCUS_CHANGE_MASK;
        int attributes_mask = Gdk.WindowAttributesType.X        |
                              Gdk.WindowAttributesType.Y        |
                              Gdk.WindowAttributesType.COLORMAP |
                              Gdk.WindowAttributesType.VISUAL;

        // widget window
        ((global::Gtk.Widget)this).window = new Gdk.Window (get_parent_window (), attributes, attributes_mask);
        ((global::Gtk.Widget)this).window.set_user_data (this);
        ((global::Gtk.Widget)this).window.set_back_pixmap (null, false);
        style = style.attach (((global::Gtk.Widget)this).window);

        ((global::Gtk.Widget)this).window.show ();
        ((global::Gtk.Widget)this).window.get_display ().sync ();

        // Create gate window from gtk window
        m_WindowGate = new Window.from_foreign (@"$name-gtk-canvas-parent", (uint32)Gdk.x11_drawable_get_xid (((global::Gtk.Widget)this).window));

        // Create maia window
        m_Window = new Maia.Window (@"$name-gtk-canvas-window", allocation.width, allocation.height);
        var color_bg = style.bg[global::Gtk.StateType.NORMAL];
        m_Window.background_pattern = new Graphic.Color ((double)color_bg.red / 65535.0, (double)color_bg.green / 65535.0, (double)color_bg.blue / 65535.0);
        m_Window.position = Graphic.Point (0, 0);
        m_Window.size = Graphic.Size (allocation.width, allocation.height);
        m_Window.grab_focus.connect (on_window_grab_focus);

        // Set canvas window
        m_Window.set_data<unowned Window?> ("MaiaCanvasWindow", m_WindowGate);

        // Set root parent has window
        if (m_Root != null) m_Root.parent = m_Window;

        m_Window.flush ();

        // Add window to application in same time this launch window notify for reparent
        Application.@default.add (m_Window);
    }

    internal override void
    map ()
    {
        m_Window.visible = true;

        base.map ();
    }

    internal override void
    unmap ()
    {
        m_Window.visible = false;

        base.unmap ();
    }

    internal override bool
    key_press_event (Gdk.EventKey inEvent)
    {
        if (m_Window != null && is_focus)
        {
            uint32 xid;
            m_Window.get ("xid", out xid);

            send_keyboard_event (Gdk.Window.foreign_new ((Gdk.NativeWindow)xid), inEvent);
        }

        return false;
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

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "canvas size: %i,%i", outRequisition.width, outRequisition.height);
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

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"window size: $(inAllocation.width) $(inAllocation.height)");
        }

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"alllocation: $(inAllocation.x) $(inAllocation.y) $(inAllocation.width) $(inAllocation.height)");
    }

    internal override bool
    expose_event (Gdk.EventExpose inEvent)
    {
        return true;
    }

    public GLib.List<unowned global::Gtk.Button>
    get_shortcut_buttons ()
    {
        GLib.List<unowned global::Gtk.Button> list = new GLib.List<unowned global::Gtk.Button> ();

        unowned Document? doc = root as Document;
        if (doc != null)
        {
            foreach (unowned Maia.Shortcut child in doc.shortcuts)
            {
                list.prepend ((child as Shortcut).button);
            }
            list.reverse ();
        }

        return list;
    }
}

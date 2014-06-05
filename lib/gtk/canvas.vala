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

public class Maia.Gtk.Canvas : global::Gtk.Widget, Maia.Canvas
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
            if (m_Window != null)
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

    private void
    send_configure ()
    {
        Gdk.Event evt = new Gdk.Event (Gdk.EventType.CONFIGURE);

        evt.configure.window = (Gdk.Window)((global::Gtk.Widget)this).window.ref ();
        evt.configure.send_event = (char)true;
        evt.configure.x = allocation.x;
        evt.configure.y = allocation.y;
        evt.configure.width = allocation.width;
        evt.configure.height = allocation.height;

        event (evt);
    }

    private bool
    on_window_button_press_event (uint inButton, Graphic.Point inPosition)
    {
        // Set widget has focus
        grab_focus ();

        return true;
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
        // Set widget was realized
        set_realized (true);

        // Create window
        m_Window = new Maia.Window (@"$name-gtk-canvas-window", allocation.width, allocation.height);
        m_Window.background_pattern = new Graphic.Color (1, 1, 1);
        m_Window.position = Graphic.Point (allocation.x, allocation.y);
        m_Window.size = Graphic.Size (allocation.width, allocation.height);
        m_Window.button_press_event.connect (on_window_button_press_event);
        m_Window.grab_focus.connect (on_window_grab_focus);

        // Create gate window from gtk parent window
        m_WindowGate = new Window.from_foreign (@"$name-gtk-canvas-parent", (uint32)Gdk.x11_drawable_get_xid (get_parent_window ()));

        // Set canvas window
        m_Window.set_data<unowned Window?> ("MaiaCanvasWindow", m_WindowGate);

        // Set root parent has window
        if (m_Root != null) m_Root.parent = m_Window;

        // Show window
        m_Window.visible = true;
        m_Window.flush ();

        // Add window to application in same time this launch window notify for reparent
        Application.@default.add (m_Window);

        // Create gdk window from maia window
        uint32 xid;
        m_Window.get ("xid", out xid);

        // Attach window to widget
        ((global::Gtk.Widget)this).window = Gdk.Window.foreign_new ((Gdk.NativeWindow)xid).ref () as Gdk.Window;
        ((global::Gtk.Widget)this).window.set_user_data (this);
        style = style.attach (((global::Gtk.Widget)this).window);

        send_configure ();
    }

    internal override void
    size_request (out global::Gtk.Requisition outRequisition)
    {
        outRequisition = global::Gtk.Requisition ();
        outRequisition.width = (int)(window.size.width);
        outRequisition.height = (int)(window.size.height);

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "canvas size: %i,%i", outRequisition.width, outRequisition.height);
    }

    internal override void
    size_allocate (Gdk.Rectangle inAllocation)
    {
        allocation = (global::Gtk.Allocation)inAllocation;

        if (get_realized ())
        {
            m_Window.position = Graphic.Point (inAllocation.x, inAllocation.y);
            m_Window.size = Graphic.Size (inAllocation.width, inAllocation.height);

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"window size: $(inAllocation.width) $(inAllocation.height)");

            send_configure ();
        }

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"alllocation: $(inAllocation.x) $(inAllocation.y) $(inAllocation.width) $(inAllocation.height)");
    }

    internal override bool
    button_press_event (Gdk.EventButton inEvent)
    {
        // grab focus on button press event
        grab_focus ();

        return false;
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

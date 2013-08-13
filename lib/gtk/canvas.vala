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

public class Maia.Gtk.Canvas : global::Gtk.Widget, Maia.Drawable, Maia.Canvas
{
    // properties
    private Graphic.Surface m_Buffer;
    private Item m_Root = null;
    private Core.Pair<global::Gtk.Adjustment, global::Gtk.Adjustment> m_Adjust;

    // accessors
    internal Core.Timeline timeline { get; set; default = null; }
    internal Graphic.Region geometry { get; protected set; default = null; }
    internal Graphic.Region damaged { get; protected set; default = null; }
    internal Graphic.Transform transform { get; set; default = new Graphic.Transform.identity (); }

    internal Item root {
        get {
            return m_Root;
        }
        set {
            if (m_Root != null)
            {
                m_Root.damage.disconnect (on_root_damage);
            }
            m_Root = value;
            if (m_Root != null)
            {
                m_Root.damage.connect (on_root_damage);
            }
        }
    }
    internal unowned Item? focus_item         { get; set; default = null; }
    internal unowned Item? grab_pointer_item  { get; set; default = null; }
    internal unowned Item? grab_keyboard_item { get; set; default = null; }

    internal Maia.Graphic.Surface surface {
        get {
            return m_Buffer;
        }
    }

    // static methods
    static construct
    {
        // Initialize backends
        Maia.GdkPixbuf.init ();
        Maia.Cairo.init ();
        Maia.Rsvg.init ();

        // Override Image item
        Core.Any.delegate (typeof (Maia.Image),        typeof (Image));
        Core.Any.delegate (typeof (Maia.Model),        typeof (Model));
        Core.Any.delegate (typeof (Maia.Model.Column), typeof (Model.Column));

        // Set scroll adjustments signal id
        set_scroll_adjustments_signal = GLib.Signal.lookup ("on_set_scroll_adjustments", typeof (Canvas));
    }

    // methods
    construct
    {
        set_has_window (true);
        set_redraw_on_allocate (false);
        can_focus = true;
        has_focus = true;

        register ();
    }

    public Canvas ()
    {
    }

    internal virtual signal void
    on_set_scroll_adjustments (global::Gtk.Adjustment? inHAdjustment, global::Gtk.Adjustment? inVAdjustment)
    {
        // Disconnect all scroll signal
        if (m_Adjust != null && m_Adjust.first != null)
        {
            m_Adjust.first.value_changed.disconnect (on_scroll);
        }
        if (m_Adjust != null && m_Adjust.second != null)
        {
            m_Adjust.second.value_changed.disconnect (on_scroll);
        }

        // Set adjustements
        m_Adjust = new Core.Pair<global::Gtk.Adjustment, global::Gtk.Adjustment> (inHAdjustment, inVAdjustment);

        // Connect scroll signals
        if (m_Adjust.first != null)
        {
            m_Adjust.first.value_changed.connect (on_scroll);
        }
        if (m_Adjust.second != null)
        {
            m_Adjust.second.value_changed.connect (on_scroll);
        }
    }

    private void
    on_scroll ()
    {
        unowned Document? document = root as Document;
        if (document != null)
        {
            document.position = Graphic.Point (m_Adjust.first != null ? m_Adjust.first.@value : 0,
                                               m_Adjust.second != null ? m_Adjust.second.@value : 0);
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "scroll to %s", document.position.to_string ());

            damage ();
        }
    }

    private void
    on_root_damage (Graphic.Region? inArea)
    {
        try
        {
            m_Buffer.context.save ();
            m_Buffer.context.pattern = new Graphic.Color (1, 1, 1, 1);
            if (inArea != null)
            {
                var path = new Graphic.Path.from_region (inArea);
                m_Buffer.context.fill (path);
            }
            else
            {
                m_Buffer.context.paint ();
            }
            m_Buffer.context.restore ();
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, err.message);
        }
    }

    private void
    send_configure ()
    {
        Gdk.Event evt = new Gdk.Event (Gdk.EventType.CONFIGURE);

        evt.configure.window = (Gdk.Window)window.ref ();
        evt.configure.send_event = (char)true;
        evt.configure.x = allocation.x;
        evt.configure.y = allocation.y;
        evt.configure.width = allocation.width;
        evt.configure.height = allocation.height;

        event (evt);
    }

    internal void
    resize ()
    {
        if (geometry != null && !geometry.is_empty () && root != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "width: %u, height: %u", (uint)geometry.extents.size.width,
                                                                                               (uint)geometry.extents.size.height);

            m_Buffer = new Maia.Graphic.Surface ((uint)geometry.extents.size.width,
                                                 (uint)geometry.extents.size.height);
            try
            {
                m_Buffer.context.pattern = new Graphic.Color (1, 1, 1, 1);
                m_Buffer.context.paint ();
            }
            catch (Graphic.Error err)
            {
                Log.error (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, err.message);
            }

            root.geometry = null;

            unowned Document? document = root as Document;
            if (m_Adjust != null && document != null)
            {
                if (m_Adjust.first != null)
                {
                    m_Adjust.first.configure (document.position.x, 0, document.size.width, 1, 1, geometry.extents.size.width);
                }

                if (m_Adjust.second != null)
                {
                    m_Adjust.second.configure (document.position.y, 0, document.size.height, 1, 1, geometry.extents.size.height);
                }
            }
        }
        else
        {
            m_Buffer = null;
        }
    }

    internal void
    draw (Graphic.Context inContext) throws Graphic.Error
    {
        if (root != null)
        {
            root.update (surface.context, geometry);

            root.draw (surface.context);
        }

        if (window != null)
        {
            window.invalidate_rect (null, true);
            window.process_updates (true);
            repair ();
        }
    }

    internal void
    on_set_pointer_cursor (Cursor inCursor)
    {
        if (window != null)
        {
            window.set_cursor (new Gdk.Cursor (convert_cursor_to_gdk_cursor (inCursor)));
        }
    }

    internal bool
    on_grab_pointer (Item inItem)
    {
        bool ret = false;

        // Can grab only nobody have already grab
        if (grab_pointer_item == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);

            var status = Gdk.pointer_grab (window, true,
                                           Gdk.EventMask.POINTER_MOTION_MASK      |
                                           Gdk.EventMask.POINTER_MOTION_HINT_MASK |
                                           Gdk.EventMask.BUTTON_MOTION_MASK       |
                                           Gdk.EventMask.BUTTON_PRESS_MASK        |
                                           Gdk.EventMask.BUTTON_RELEASE_MASK      |
                                           Gdk.EventMask.SCROLL_MASK, window, null,
                                           Gdk.CURRENT_TIME);

            if (status == Gdk.GrabStatus.SUCCESS)
            {
                grab_pointer_item = inItem;
                ret = true;
            }
        }

        return ret;
    }

    internal void
    on_ungrab_pointer (Item inItem)
    {
        if (grab_pointer_item == inItem)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", grab_pointer_item.name);

            Gdk.pointer_ungrab (Gdk.CURRENT_TIME);
            grab_pointer_item = null;
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
        attributes.event_mask = Gdk.EventMask.EXPOSURE_MASK            |
                                Gdk.EventMask.POINTER_MOTION_MASK      |
                                Gdk.EventMask.POINTER_MOTION_HINT_MASK |
                                Gdk.EventMask.BUTTON_MOTION_MASK       |
                                Gdk.EventMask.BUTTON_PRESS_MASK        |
                                Gdk.EventMask.BUTTON_RELEASE_MASK      |
                                Gdk.EventMask.KEY_PRESS_MASK           |
                                Gdk.EventMask.KEY_RELEASE_MASK         |
                                Gdk.EventMask.SCROLL_MASK;
        int attributes_mask = Gdk.WindowAttributesType.X        |
                              Gdk.WindowAttributesType.Y        |
                              Gdk.WindowAttributesType.COLORMAP |
                              Gdk.WindowAttributesType.VISUAL;

        window = new Gdk.Window (get_parent_window (), attributes, attributes_mask);
        window.set_user_data (this);
        window.set_back_pixmap (null, false);
        style = style.attach (window);

        send_configure ();
    }

    internal override void
    show ()
    {
        base.show ();
        timeline.start ();

        grab_focus ();
    }

    internal override void
    hide ()
    {
        timeline.stop ();
        base.hide ();
    }

    internal override void
    size_request (out global::Gtk.Requisition outRequisition)
    {
        outRequisition = global::Gtk.Requisition ();
        if (root != null)
        {
            Graphic.Size size = root.size;
            unowned Document? document = root as Document;

            if (document != null && m_Adjust != null)
            {
                if (m_Adjust.first != null)
                    outRequisition.width = document.border_width * 2;
                else
                    outRequisition.width = (int)(size.width);
                if (m_Adjust.second != null)
                    outRequisition.height = document.border_width * 2;
                else
                    outRequisition.height = (int)(size.height);
            }
            else
            {
                outRequisition.width = (int)(size.width);
                outRequisition.height = (int)(size.height);
            }

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "root size: %i,%i", outRequisition.width, outRequisition.height);
        }
    }

    internal override void
    size_allocate (Gdk.Rectangle inAllocation)
    {
        allocation = (global::Gtk.Allocation)inAllocation;

        if (get_realized ())
        {
            window.move_resize (inAllocation.x, inAllocation.y, inAllocation.width, inAllocation.height);

            send_configure ();
        }

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "alllocation: %i %i", inAllocation.width, inAllocation.height);

        geometry = new Graphic.Region (Graphic.Rectangle (0, 0, inAllocation.width, inAllocation.height));
    }

    internal override bool
    key_press_event (Gdk.EventKey inEvent)
    {
        // we have grab keyboard item send event
        if (grab_keyboard_item != null)
        {
            unichar car = Gdk.keyval_to_unicode (inEvent.keyval);
            grab_keyboard_item.key_press_event (convert_gdk_key_to_key ((Gdk.Key)inEvent.keyval), car);
        }
        // we have focus item send event
        else if (focus_item != null)
        {
            unichar car = Gdk.keyval_to_unicode (inEvent.keyval);
            focus_item.key_press_event (convert_gdk_key_to_key ((Gdk.Key)inEvent.keyval), car);
        }

        return true;
    }

    internal override bool
    key_release_event (Gdk.EventKey inEvent)
    {
        // we have grab keyboard item send event
        if (grab_keyboard_item != null)
        {
            unichar car = Gdk.keyval_to_unicode (inEvent.keyval);
            grab_keyboard_item.key_release_event (convert_gdk_key_to_key ((Gdk.Key)inEvent.keyval), car);
        }
        // we have focus item send event
        else if (focus_item != null)
        {
            unichar car = Gdk.keyval_to_unicode (inEvent.keyval);
            focus_item.key_release_event (convert_gdk_key_to_key ((Gdk.Key)inEvent.keyval), car);
        }

        return true;
    }

    internal override bool
    button_press_event (Gdk.EventButton inEvent)
    {
        Graphic.Point point = Graphic.Point (inEvent.x, inEvent.y);

        // grab focus on button press event
        grab_focus ();

        // we have grab pointer item send event
        if (grab_pointer_item != null)
        {
            grab_pointer_item.button_press_event (inEvent.button, grab_pointer_item.convert_to_item_space (point));
        }
        // else send event to root
        else if (root != null)
        {
            root.button_press_event (inEvent.button, point);
        }

        return true;
    }

    internal override bool
    button_release_event (Gdk.EventButton inEvent)
    {
        Graphic.Point point = Graphic.Point (inEvent.x, inEvent.y);

        // we have grab pointer item send event
        if (grab_pointer_item != null)
        {
            grab_pointer_item.button_release_event (inEvent.button, grab_pointer_item.convert_to_item_space (point));
        }
        // else send event to root
        else if (root != null)
        {
            root.button_release_event (inEvent.button, point);
        }

        return true;
    }

    internal override bool
    motion_notify_event (Gdk.EventMotion inEvent)
    {
        if (inEvent.is_hint)
        {
            Graphic.Point point = Graphic.Point (inEvent.x, inEvent.y);

            // we have grab pointer item send event
            if (grab_pointer_item != null)
            {
                grab_pointer_item.motion_event (grab_pointer_item.convert_to_item_space (point));
            }
            // else send event to root
            else if (root != null)
            {
                root.motion_event (point);
            }

            // Get pointer position for hint motion
            double x, y;
            Gdk.ModifierType mod;
            window.get_pointer (out x, out y, out mod);
        }

        return true;
    }

    internal override bool
    scroll_event (Gdk.EventScroll inEvent)
    {
        bool ret = false;

        Graphic.Point point = Graphic.Point (inEvent.x, inEvent.y);

        // we have grab pointer item send event
        if (grab_pointer_item != null)
        {
            ret = grab_pointer_item.scroll_event (convert_gdk_scrolldirection_to_scroll (inEvent.direction),
                                                  grab_pointer_item.convert_to_item_space (point));
        }
        // else send event to root
        else if (root != null)
        {
            ret = root.scroll_event (convert_gdk_scrolldirection_to_scroll (inEvent.direction), point);
        }

        return ret;
    }

    internal override bool
    expose_event (Gdk.EventExpose inEvent)
    {
        if (surface != null)
        {
            try
            {
                var widget_surface = new Surface (this);
                widget_surface.context.operator = Graphic.Operator.SOURCE;
                widget_surface.context.pattern = surface;
                widget_surface.context.paint ();
            }
            catch (Graphic.Error err)
            {
                critical (err.message);
            }
        }

        return true;
    }
}

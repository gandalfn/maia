/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.Window : Maia.Window
{
    // properties
    private View          m_View;
    private unowned Item? m_ParentWindow = null;
    private int           m_Monitor = -1;

    // accessors
    [CCode (notify = false)]
    public override uint8 depth {
        get {
            return m_View != null ? m_View.depth : 0;
        }
        set {
            if (m_View != null)
            {
                m_View.depth = value;
            }
        }
    }

    [CCode (notify = false)]
    public override Maia.Window? transient_for {
        get {
            return base.transient_for;
        }
        set {
            if (transient_for != value)
            {
                if (base.transient_for != null)
                {
                    base.transient_for.notify["position"].disconnect (on_window_parent_move);
                }

                base.transient_for = value;

                if (value != null)
                {
                    value.notify["position"].connect (on_window_parent_move);
                }

                if (m_View != null && value is Window)
                {
                    m_View.transient_for = (value as Window).m_View;
                }
            }
        }
    }

    public override Graphic.Surface? surface {
        get {
            return m_View != null ? m_View.surface : null;
        }
    }

    [CCode (notify = false)]
    public override Core.List<unowned Maia.InputDevice>? input_devices {
        owned get {
            if (m_View != null)
            {
                return m_View.input_devices;
            }
            return null;
        }
        set {
            if (m_View != null)
            {
                m_View.input_devices = value;
            }
        }
    }

    public uint32 xid {
        get {
            return m_View != null ? m_View.xid : 0;
        }
    }

    public unowned View? view {
        get {
            return m_View;
        }
    }

    [CCode (notify = false)]
    public int monitor {
        get {
            return m_Monitor;
        }
        set {
            if (m_Monitor != value)
            {
                m_Monitor = value;

                if (m_View != null && m_Monitor >= 0)
                {
                    unowned Monitor? monitor = m_View.screen.get_monitor (m_Monitor);
                    if (monitor != null)
                    {
                        m_View.position = monitor.geometry.origin;
                    }
                }
            }
        }
        default = -1;
    }

    // methods
    public Window (string inName, int inWidth, int inHeight)
    {
        base (inName, inWidth, inHeight);
    }

    private void
    on_main_window_changed ()
    {
        if (m_View != null && m_ParentWindow != window)
        {
            if (m_ParentWindow != null)
            {
                m_ParentWindow.notify["view"].disconnect (on_parent_view_changed);
                m_ParentWindow.notify["visible-area"].disconnect (on_viewport_parent_visible_area_changed);
            }

            m_ParentWindow = window;

            if (m_ParentWindow != null)
            {
                m_ParentWindow.notify["view"].connect (on_parent_view_changed);
                m_ParentWindow.notify["visible-area"].connect (on_viewport_parent_visible_area_changed);
            }
        }

        on_parent_view_changed ();
    }

    private void
    on_close_button_changed ()
    {
        if (m_View != null && (window_type == Type.TOPLEVEL || window_type == Type.POPUP))
        {
            m_View.override_redirect = close_button || window_type == Type.POPUP;
        }
    }

    private void
    on_decorated_changed ()
    {
        if (m_View != null)
        {
            m_View.decorated = decorated;
        }
    }

    private void
    on_parent_view_changed ()
    {
        if (m_View != null && (window_type == Type.TOPLEVEL || window_type == Type.POPUP))
        {
            m_View.parent = null;
        }

        if (m_ParentWindow != null && m_View != null)
        {
            unowned Window? parent_window = m_ParentWindow as Window;

            if (parent_window == null)
            {
                unowned Viewport? parent_viewport = m_ParentWindow as Viewport;

                m_View.parent = parent_viewport == null ? null : parent_viewport.view;

                on_viewport_parent_visible_area_changed ();
            }
            else
            {
                m_View.parent = parent_window.view;

                on_window_parent_move ();
            }

        }
        else if (m_View != null)
        {
            m_View.parent = null;
        }
    }

    private void
    on_window_parent_move ()
    {
        unowned Window? parent_window = m_ParentWindow as Window;
        if (parent_window != null && m_View != null)
        {
            if (m_View.override_redirect || window_type == Type.POPUP)
            {
                var pos = position;

                if (PositionPolicy.ALWAYS_CENTER in position_policy)
                {
                    Graphic.Rectangle monitorGeometry =  m_View.screen.get_monitor_at (Graphic.Point (0, 0)).geometry;
                    if (m_View.parent != null)
                    {
                        pos = Graphic.Point (m_View.parent.position.x + (m_View.parent.size.width - size.width) / 2, m_View.parent.position.y + (m_View.parent.size.height - size.height) / 2);
                    }
                    else
                    {
                        pos = Graphic.Point (monitorGeometry.origin.x + (monitorGeometry.size.width - size.width) / 2, monitorGeometry.origin.y + (monitorGeometry.size.height - size.height) / 2);
                    }
                }

                try
                {
                    Graphic.Rectangle geo = Graphic.Rectangle (0, 0, 0, 0);
                    geo.origin = pos;
                    geo.size = m_View.size;
                    geo.size.resize (border * 2, border * 2);
                    geo.size.transform (new Graphic.Transform.invert (m_View.device_transform));
                    if (PositionPolicy.CLAMP_MONITOR in position_policy)
                    {
                        Graphic.Point root_pos = parent_window.view.root_position;
                        geo.origin.translate (root_pos);
                        geo.clamp (m_View.screen.get_monitor_at (geo.origin).geometry);
                        geo.origin.translate (root_pos.invert ());
                    }

                    m_View.position = Graphic.Point (double.max (geo.origin.x, 0), double.max (geo.origin.y, 0));
                }
                catch (Graphic.Error err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"error on convert position in window coordinate space : $(err.message)");
                }
            }
            else
            {
                m_View.position = position;
            }
        }
    }

    private void
    on_viewport_parent_visible_area_changed ()
    {
        unowned Viewport? parent_viewport = (Viewport)m_ParentWindow;
        if (parent_viewport != null && m_View != null)
        {
            if (m_View.override_redirect || window_type == Type.POPUP)
            {
                var pos = position;

                if (PositionPolicy.ALWAYS_CENTER in position_policy)
                {
                    var monitor = m_View.screen.get_monitor_at (Graphic.Point (0, 0));
                    if (monitor != null)
                    {
                        var monitorGeometry = monitor.geometry;
                        pos = Graphic.Point (monitorGeometry.origin.x + (monitorGeometry.size.width - size.width) / 2, monitorGeometry.origin.y + (monitorGeometry.size.height - size.height) / 2);
                    }
                }
                else
                {
                    pos.translate (parent_viewport.visible_area.origin.invert ());
                }

                try
                {
                    Graphic.Rectangle geo = Graphic.Rectangle (0, 0, 0, 0);
                    geo.origin = pos;
                    geo.size = m_View.size;
                    geo.size.resize (border * 2, border * 2);
                    geo.size.transform (new Graphic.Transform.invert (m_View.device_transform));
                    if (PositionPolicy.CLAMP_MONITOR in position_policy)
                    {
                        Graphic.Point root_pos = parent_viewport.view.root_position;
                        geo.origin.translate (root_pos);
                        var monitor = m_View.screen.get_monitor_at (geo.origin);
                        if (monitor != null)
                        {
                            geo.clamp (monitor.geometry);
                        }
                        geo.origin.translate (root_pos.invert ());
                    }

                    m_View.position = Graphic.Point (double.max (geo.origin.x, 0), double.max (geo.origin.y, 0));
                }
                catch (Graphic.Error err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"error on convert size in window coordinate space : $(err.message)");
                }
            }
            else
            {
                var pos = position;
                pos.translate (parent_viewport.visible_area.origin.invert ());
                m_View.position = pos;
            }
        }
    }

    private void
    on_device_transform_changed ()
    {
        if (m_View != null)
        {
            m_View.device_transform = device_transform;
            if (m_View.backbuffer != null)
            {
                m_View.backbuffer.clear ();
            }
        }
    }

    private void
    on_repair (Core.Notification inNotification)
    {
        if (m_View != null)
        {
            unowned Maia.Drawable.RepairNotification notification = (Maia.Drawable.RepairNotification)inNotification;

            // Add swap damaged
            if (m_View.damaged != null)
                m_View.damaged.union_ (notification.area ?? area);
            else
                m_View.damaged = (notification.area ?? area).copy ();

            m_View.updated.post ();
        }
    }

    internal override void
    delegate_construct ()
    {
        not_dumpable_attributes.insert ("xid");
        not_dumpable_attributes.insert ("depth");

        // Connect onto repair signal
        repair.add_object_observer (on_repair);

        // Get foreign xid if set
        if (foreign != 0)
        {
            m_View = new View.foreign (foreign);
        }
        else
        {
            m_View = new View ((int)size.width, (int)size.height);
            m_View.decorated = decorated;
        }

        // Create event
        damage_event     = new Core.Event ("damage",     ((int)m_View.xid).to_pointer ());
        geometry_event   = new Core.Event ("geometry",   ((int)m_View.xid).to_pointer ());
        visibility_event = new Core.Event ("visibility", ((int)m_View.xid).to_pointer ());
        delete_event     = new Core.Event ("delete",     ((int)m_View.xid).to_pointer ());
        destroy_event    = new Core.Event ("destroy",    ((int)m_View.xid).to_pointer ());
        mouse_event      = new Core.Event ("mouse",      ((int)m_View.xid).to_pointer ());
        keyboard_event   = new Core.Event ("keyboard",   ((int)m_View.xid).to_pointer ());

        // window is hidden by default
        visible = false;

        // set main window has this window
        window = this;

        // connect onto window changed
        notify["window"].connect (on_main_window_changed);

        // connect onto window-type changed
        notify["window-type"].connect (on_parent_view_changed);

        // connect onto close button changed
        notify["close-button"].connect (on_close_button_changed);

        // connect onto close button changed
        notify["decorated"].connect (on_decorated_changed);

        // connect onto device transform changed
        notify["device-transform"].connect (on_device_transform_changed);
        m_View.device_transform = device_transform;

        m_View.transform = transform;
    }

    internal override void
    on_transform_changed ()
    {
        base.on_transform_changed ();

        if (m_View != null)
        {
            m_View.transform = transform;
        }
    }

    internal override void
    on_destroy_event (Core.EventArgs? inArgs)
    {
        m_View = null;

        base.on_destroy_event (inArgs);
    }

    internal override void
    on_move ()
    {
        base.on_move ();

        unowned Viewport? parent_viewport = m_ParentWindow as Viewport;
        unowned Window? parent_window     = m_ParentWindow as Window;
        if (parent_viewport != null)
        {
            on_viewport_parent_visible_area_changed ();
        }
        else if (parent_window != null)
        {
            on_window_parent_move ();
        }
        else if (m_View != null)
        {
            if (m_View.override_redirect || window_type == Type.POPUP)
            {
                var pos = position;

                if (PositionPolicy.ALWAYS_CENTER in position_policy)
                {
                    var monitor = m_View.screen.get_monitor_at (Graphic.Point (0, 0));
                    if (monitor != null)
                    {
                        Graphic.Rectangle monitorGeometry =  monitor.geometry;
                        pos = Graphic.Point (monitorGeometry.origin.x + (monitorGeometry.size.width - size.width) / 2, monitorGeometry.origin.y + (monitorGeometry.size.height - size.height) / 2);
                    }
                }

                Graphic.Rectangle geo = Graphic.Rectangle (0, 0, 0, 0);
                geo.origin = pos;
                geo.size = m_View.size;
                geo.size.resize (border * 2, border * 2);
                if (PositionPolicy.CLAMP_MONITOR in position_policy)
                {
                    Graphic.Point root_pos = parent_viewport.view.root_position;
                    geo.origin.translate (root_pos);
                    var monitor = m_View.screen.get_monitor_at (geo.origin);
                    if (monitor != null)
                    {
                        geo.clamp (monitor.geometry);
                    }
                    geo.origin.translate (root_pos.invert ());
                }

                m_View.position = Graphic.Point (double.max (geo.origin.x, 0), double.max (geo.origin.y, 0));
            }
        }
    }

    internal override void
    on_geometry_event (Core.EventArgs? inArgs)
    {
        unowned GeometryEventArgs? geometry_args = inArgs as GeometryEventArgs;

        if (decorated)
        {
            var geometry_area = geometry_args.area;
            geometry_area.origin = m_View.root_position;

            base.on_geometry_event (new GeometryEventArgs (geometry_area.origin.x, geometry_area.origin.y, geometry_area.size.width, geometry_area.size.height));
        }
        else
        {
            base.on_geometry_event (inArgs);
        }
    }

    internal override void
    on_mouse_event (Core.EventArgs? inArgs)
    {
        unowned MouseEventArgs? mouse_args = inArgs as MouseEventArgs;

        if (mouse_args != null)
        {
            var pos = mouse_args.position;
            base.on_mouse_event (new MouseEventArgs (mouse_args.flags, mouse_args.button, pos.x, pos.y));
        }
    }

    internal override void
    on_show ()
    {
        if (m_View != null)
        {
            m_View.show ();
            application.sync ();
            if (m_Monitor >= 0)
            {
                unowned Monitor? monitor = m_View.screen.get_monitor (m_Monitor);
                if (monitor != null)
                {
                    m_View.position = Graphic.Point (-1, -1);
                    application.sync ();
                    m_View.position = monitor.geometry.origin;
                    application.sync ();
                }
            }
        }

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        base.on_hide ();

        if (m_View != null)
        {
            m_View.hide ();
        }
    }

    internal override bool
    on_grab_pointer (Item inItem)
    {
        bool ret = base.on_grab_pointer (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_pointer_item != null && m_View != null)
        {
            m_View.grab_pointer (!(grab_pointer_item is Popup));
        }

        return ret;
    }

    internal override void
    on_ungrab_pointer (Item inItem)
    {
        if (grab_pointer_item == inItem)
        {
            m_View.ungrab_pointer ();
        }

        base.on_ungrab_pointer (inItem);
    }

    internal override bool
    on_grab_keyboard (Item inItem)
    {
        bool ret = base.on_grab_keyboard (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_keyboard_item != null && m_View != null)
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
#endif
            m_View.grab_keyboard ();
        }

        return ret;
    }

    internal override void
    on_ungrab_keyboard (Item inItem)
    {
        base.on_ungrab_keyboard (inItem);

        if (grab_keyboard_item == null && m_View != null)
        {
            m_View.ungrab_keyboard ();
        }
    }

    internal override void
    on_set_pointer_cursor (Cursor inCursor)
    {
        if (m_View != null)
        {
            m_View.set_pointer_cursor (inCursor);
        }
    }

    internal override void
    on_move_pointer (Graphic.Point inPosition)
    {
        if (m_View != null)
        {
            m_View.move_pointer (inPosition);
        }
    }

    internal override bool
    grab_key (Modifier inModifier, Key inKey)
    {
        bool ret = base.grab_key (inModifier, inKey);

        if (ret)
        {
            m_View.grab_key (inModifier, inKey);
        }

        return ret;
    }

    internal override bool
    ungrab_key (Modifier inModifier, Key inKey)
    {
        bool ret = base.ungrab_key (inModifier, inKey);

        if (ret)
        {
            m_View.ungrab_key (inModifier, inKey);
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        if (geometry != null && m_View != null)
        {
            m_View.size = geometry.extents.size;
        }
    }

    internal override void
    swap_buffer ()
    {
        if (m_View != null)
        {
            m_View.swap_buffer ();
        }
    }
}

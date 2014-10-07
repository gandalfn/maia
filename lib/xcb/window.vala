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
    private View              m_View;
    private unowned Viewport? m_ParentViewport = null;

    // accessors
    public override uint8 depth {
        get {
            return m_View.depth;
        }
        set {
            m_View.depth = value;
        }
    }

    public override Graphic.Surface? surface {
        get {
            return m_View.surface;
        }
    }

    public uint32 xid {
        get {
            return m_View.xid;
        }
    }

    public unowned View? view {
        get {
            return m_View;
        }
    }

    // methods
    public Window (string inName, int inWidth, int inHeight)
    {
        base (inName, inWidth, inHeight);
    }

    private void
    on_main_window_changed ()
    {
        unowned Window? parent_window = window as Window;

        if (m_ParentViewport != null)
        {
            m_ParentViewport.notify["visible-area"].disconnect (on_viewport_parent_visible_area_changed);
        }
        if (parent_window == null)
        {
            m_ParentViewport = window as Viewport;

            m_View.parent = m_ParentViewport == null ? null : m_ParentViewport.view;

            if (m_ParentViewport != null)
            {
                m_ParentViewport.notify["visible-area"].connect (on_viewport_parent_visible_area_changed);
                on_viewport_parent_visible_area_changed ();
            }
        }
        else
        {
            m_ParentViewport = null;
            m_View.parent = parent_window.view;
        }
    }

    private void
    on_viewport_parent_visible_area_changed ()
    {
        if (m_ParentViewport != null)
        {
            var pos = position;
            pos.translate (m_ParentViewport.visible_area.origin.invert ());
            m_View.position = pos;
        }
    }

    private void
    on_device_transform_changed ()
    {
        m_View.device_transform = device_transform;
        if (m_View.backbuffer != null)
        {
            m_View.backbuffer.clear ();
        }
    }

    private void
    on_repair (Graphic.Region? inArea)
    {
        // Add swap damaged
        if (m_View.damaged != null)
            m_View.damaged.union_ (inArea ?? area);
        else
            m_View.damaged = (inArea ?? area).copy ();

        m_View.updated ();
    }

    internal override void
    delegate_construct ()
    {
        not_dumpable_attributes.insert ("xid");
        not_dumpable_attributes.insert ("depth");

        // Connect onto repair signal
        repair.connect (on_repair);

        // Get foreign xid if set
        if (foreign != 0)
        {
            m_View = new View.foreign (foreign);
        }
        else
        {
            m_View = new View ((int)size.width, (int)size.height);
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

        // connect onto device transform changed
        notify["device-transform"].connect (on_device_transform_changed);
        m_View.device_transform = device_transform;

        m_View.transform = transform;
    }

    internal override void
    on_transform_changed ()
    {
        base.on_transform_changed ();

        m_View.transform = transform;
    }

    internal override void
    on_move ()
    {
        base.on_move ();

        if (m_ParentViewport != null)
        {
            on_viewport_parent_visible_area_changed ();
        }
        else
        {
            m_View.position = position;
        }
    }

    internal override void
    on_resize ()
    {
        m_View.size = size;

        base.on_resize ();
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
        base.on_show ();

        m_View.show ();
    }

    internal override void
    on_hide ()
    {
        m_View.hide ();

        base.on_hide ();
    }

    internal override bool
    on_grab_pointer (Item inItem)
    {
        bool ret = base.on_grab_pointer (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_pointer_item != null)
        {
            m_View.grab_pointer ();
        }

        return ret;
    }

    internal override void
    on_ungrab_pointer (Item inItem)
    {
        base.on_ungrab_pointer (inItem);

        m_View.ungrab_pointer ();
    }

    internal override bool
    on_grab_keyboard (Item inItem)
    {
        bool ret = base.on_grab_keyboard (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_keyboard_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
            m_View.grab_keyboard ();
        }

        return ret;
    }

    internal override void
    on_ungrab_keyboard (Item inItem)
    {
        base.on_ungrab_keyboard (inItem);

        if (grab_keyboard_item == null)
        {
            m_View.ungrab_keyboard ();
        }
    }

    internal override void
    on_set_pointer_cursor (Cursor inCursor)
    {
        m_View.set_pointer_cursor (inCursor);
    }

    internal override void
    on_move_pointer (Graphic.Point inPosition)
    {
        m_View.move_pointer (inPosition);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        if (geometry != null)
        {
            m_View.size = geometry.extents.size;
        }
    }

    internal override void
    swap_buffer ()
    {
        m_View.swap_buffer ();
    }
}

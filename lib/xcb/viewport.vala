/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * viewport.vala
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

internal class Maia.Xcb.Viewport : Maia.Viewport
{
    // properties
    private PixmapSlices m_Slices;
    private View         m_View;
    private Core.Event   m_DamageEvent;
    private Core.Event   m_GeometryEvent;
    private Core.Event   m_VisibilityEvent;
    private Core.Event   m_DestroyEvent;
    private Core.Event   m_MouseEvent;
    private Core.Event   m_KeyboardEvent;

    // accessors
    public unowned View? view {
        get {
            return m_View;
        }
    }

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

    public override Graphic.Rectangle visible_area {
        get {
            return base.visible_area;
        }
        set {
            if (!base.visible_area.equal (value))
            {
                if (!base.visible_area.is_empty ())
                {
                    m_Slices.set (m_View.backbuffer, base.visible_area.origin, base.visible_area);
                }

                base.visible_area = value;

                m_View.size = value.size;

                if (m_View.backbuffer != null)
                {
                    m_Slices.get (m_View.backbuffer, value.origin, value);
                }

                var view_size = m_View.size;
                view_size.transform (m_View.device_transform);
                m_View.damaged = new Graphic.Region (Graphic.Rectangle (0, 0, view_size.width, view_size.height));
            }
        }
    }

    public uint32 xid {
        get {
            return m_View.xid;
        }
    }

    // methods
    public Viewport (string inName)
    {
        base (inName);
    }

    private void
    create_view ()
    {
        if (m_View == null)
        {
            // Get foreign xid if set
            if (foreign != 0)
            {
                m_View = new View.foreign (foreign);
            }
            else
            {
                m_View = new View ((int)visible_area.size.width, (int)visible_area.size.height);
                m_View.managed = false;
            }

            // Create event
            m_DamageEvent     = new Core.Event ("damage",     ((int)m_View.xid).to_pointer ());
            m_GeometryEvent   = new Core.Event ("geometry",   ((int)m_View.xid).to_pointer ());
            m_VisibilityEvent = new Core.Event ("visibility", ((int)m_View.xid).to_pointer ());
            m_DestroyEvent    = new Core.Event ("destroy",    ((int)m_View.xid).to_pointer ());
            m_MouseEvent      = new Core.Event ("mouse",      ((int)m_View.xid).to_pointer ());
            m_KeyboardEvent   = new Core.Event ("keyboard",   ((int)m_View.xid).to_pointer ());

            // Subscribe to damage event
            m_DamageEvent.object_subscribe (on_view_damage_event);

            // Subscribe to geometry event
            m_GeometryEvent.object_subscribe (on_view_geometry_event);

            // Subscribe to visibility event
            m_VisibilityEvent.object_subscribe (on_view_visibility_event);

            // Subscribe to destroy event
            m_DestroyEvent.object_subscribe (on_view_destroy_event);

            // Subscribe to mouse event
            m_MouseEvent.object_subscribe (on_view_mouse_event);

            // Subscribe to keyboard event
            m_KeyboardEvent.object_subscribe (on_view_keyboard_event);

            // set parent
            on_main_window_changed ();

            // set device transform
            on_device_transform_changed ();

            // set transform
            on_transform_changed ();
        }
    }

    private void
    on_main_window_changed ()
    {
        if (m_View != null)
        {
            unowned Window? parent_window = window as Window;

            if (parent_window == null)
            {
                unowned Viewport? parent_viewport = window as Viewport;

                m_View.parent = parent_viewport == null ? null : parent_viewport.view;
            }
            else
            {
                m_View.parent = parent_window.view;
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
    on_transform_changed ()
    {
        if (m_View != null)
        {
            m_View.transform = transform;
        }
    }

    private void
    on_repair (Graphic.Region? inArea)
    {
        if (m_View != null)
        {
            // Translate area to visible area
            var damaged_area = new Graphic.Region (visible_area);
            damaged_area.intersect (inArea ?? area);
            damaged_area.translate (visible_area.origin.invert ());

            // Add swap damaged
            if (m_View.damaged != null)
                m_View.damaged.union_ (damaged_area);
            else
                m_View.damaged = damaged_area.copy ();

            // update slice pixmap
//~             foreach (var rect in (inArea ?? area))
//~             {
//~                 m_Slices.set (m_View.backbuffer, visible_area.origin, rect);
//~             }

            m_View.updated ();
        }
    }

    private void
    on_view_damage_event (Core.EventArgs? inArgs)
    {
        unowned DamageEventArgs? damage_args = inArgs as DamageEventArgs;

        if (damage_args != null)
        {
            Graphic.Rectangle damage_area = damage_args.area;
            damage_area.translate (visible_area.origin);
            damage_event.publish (new DamageEventArgs (damage_area.origin.x, damage_area.origin.y, damage_area.size.width, damage_area.size.height));
        }
    }

    private void
    on_view_geometry_event (Core.EventArgs? inArgs)
    {
        geometry_event.publish (inArgs);
    }

    private void
    on_view_visibility_event (Core.EventArgs? inArgs)
    {
        visibility_event.publish (inArgs);
    }

    private void
    on_view_destroy_event (Core.EventArgs? inArgs)
    {
        m_View = null;
    }

    private void
    on_view_mouse_event (Core.EventArgs? inArgs)
    {
        unowned MouseEventArgs? mouse_args = inArgs as MouseEventArgs;

        if (mouse_args != null)
        {
            var pos = mouse_args.position;
            pos.translate (visible_area.origin);
            mouse_event.publish (new MouseEventArgs (mouse_args.flags, mouse_args.button, pos.x, pos.y));
        }
    }

    private void
    on_view_keyboard_event (Core.EventArgs? inArgs)
    {
        keyboard_event.publish (inArgs);
    }

    internal override void
    delegate_construct ()
    {
        not_dumpable_attributes.insert ("xid");
        not_dumpable_attributes.insert ("depth");

        // Connect onto repair signal
        repair.connect (on_repair);

        // create view
        create_view ();

        // Create pixmap slices
        m_Slices = new PixmapSlices (m_View.screen_num, m_View.depth, Graphic.Size (1000, 1000),
                                     Graphic.Size (double.max (1, size.width), double.max (1, size.height)));

        // Create event
        damage_event     = new Core.Event ("damage",     this);
        geometry_event   = new Core.Event ("geometry",   this);
        visibility_event = new Core.Event ("visibility", this);
        delete_event     = new Core.Event ("delete",     this);
        destroy_event    = new Core.Event ("destroy",    this);
        mouse_event      = new Core.Event ("mouse",      this);
        keyboard_event   = new Core.Event ("keyboard",   this);

        // window is hidden by default
        visible = false;

        // set main window has this window
        window = this;

        // connect onto window changed
        notify["window"].connect (on_main_window_changed);

        // connect onto device transform changed
        notify["device-transform"].connect (on_device_transform_changed);

        // connect onto transform changed
        notify["transform"].connect (on_transform_changed);
    }

    internal override void
    on_resize ()
    {
        // resize slice
        m_Slices.size = size;

        base.on_resize ();
    }

    internal override void
    on_show ()
    {
        if (m_View == null)
        {
            create_view ();
        }

        m_View.show ();

        base.on_show ();
    }

    internal override void
    on_hide ()
    {
        if (m_View != null)
        {
            m_View.hide ();
        }

        base.on_hide ();
    }

    internal override bool
    on_grab_pointer (Item inItem)
    {
        bool ret = base.on_grab_pointer (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_pointer_item != null && m_View != null)
        {
            m_View.grab_pointer ();
        }

        return ret;
    }

    internal override void
    on_ungrab_pointer (Item inItem)
    {
        base.on_ungrab_pointer (inItem);

        if (m_View != null)
        {
            m_View.ungrab_pointer ();
        }
    }

    internal override bool
    on_grab_keyboard (Item inItem)
    {
        bool ret = base.on_grab_keyboard (inItem);

        // an item was grabbed grab pointer
        if (ret && grab_keyboard_item != null && m_View != null)
        {
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
            var pos = inPosition;
            pos.translate (visible_area.origin);
            m_View.move_pointer (pos);
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        if (geometry != null)
        {
            m_Slices.size = geometry.extents.size;
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

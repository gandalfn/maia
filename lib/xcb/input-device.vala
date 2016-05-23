/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * input-device.vala
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

public class Maia.Xcb.InputDevice : Maia.InputDevice
{
    // properties
    private string                             m_Name;
    private Maia.InputDevice.Type              m_Type;
    private bool                               m_Core;
    private bool                               m_Open;
    private Core.Set<unowned View>             m_Views;
    private global::Xcb.Input.InputClassInfo[] m_ClassInfos = {};
    private global::Xcb.Util.KeySymbols        m_Symbols;
    private uint32                             m_Attachment = 0;
    private unowned InputDevice                m_MasterDevice;

    // accessors
    internal override string name {
        get {
            return m_Name;
        }
    }

    internal override Maia.InputDevice.Type device_type {
        get {
            return m_Type;
        }
    }

    [CCode (notify = false)]
    internal override bool master {
        get {
            return m_Core || (m_MasterDevice != null && m_MasterDevice.id == m_Attachment);
        }
        set {
            if (master != value && m_MasterDevice != null)
            {
                if (value)
                {
                    attach_to_core ();
                }
                else
                {
                    detach_from_core ();
                }
            }
        }
    }

    internal InputDevice master_device {
        set {
            m_MasterDevice = value;
        }
    }

    // static methods
    private static global::Xcb.ModMask
    modifier_to_mod_mask (Modifier inModifier)
    {
        global::Xcb.ModMask ret = (global::Xcb.ModMask)0;

        if (Maia.Modifier.SHIFT in inModifier)
        {
            ret |= global::Xcb.ModMask.SHIFT;
        }

        if (Maia.Modifier.CONTROL in inModifier)
        {
            ret |= global::Xcb.ModMask.CONTROL;
        }

        if (Maia.Modifier.ALT in inModifier)
        {
            ret |= global::Xcb.ModMask.ONE;
        }

        if (Maia.Modifier.SUPER in inModifier)
        {
            ret |= global::Xcb.ModMask.FOUR;
        }

        return ret;
    }

    // methods
    public InputDevice (uint32 inId, string inName, Maia.InputDevice.Type inType, bool inCore, uint32 inAttachment)
    {
        GLib.Object (id: inId);

        m_Name = inName;
        m_Type = inType;
        m_Core = inCore;
        m_Attachment = inAttachment;

        m_Views = new Core.Set<unowned View> ();
    }

    ~InputDevice ()
    {
        close_device ();
    }

    private void
    open_device ()
    {
        if (!m_Open)
        {
            var reply = ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).open_device ((uint8)id).reply ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, null);
            if (reply != null)
            {
                for (int cpt = 0; cpt < reply.class_info_length; ++cpt)
                {
                    m_ClassInfos += reply.class_info[cpt];
                }

                m_Open = true;
            }
        }
    }

    private void
    close_device ()
    {
        if (m_Open)
        {
            ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).open_device ((uint8)id);
        }
    }

    private global::Xcb.Input.EventClass
    get_event_class (global::Xcb.Input.InputClass inClass, bool inPress)
    {
        global::Xcb.Input.EventClass ret = 0;

        open_device ();

        foreach (var class_info in m_ClassInfos)
        {
            if (class_info.class_id == inClass)
            {
                uint32 type = class_info.event_type_base + (inPress ? 0 : 1);
                return (global::Xcb.Input.EventClass)((id << 8) | type);
            }
        }

        return ret;
    }

    private void
    attach_to_core ()
    {
        if (m_MasterDevice != null)
        {
            if (m_Attachment != 0 && m_MasterDevice != null && m_MasterDevice.id != m_Attachment)
            {
                unowned global::Xcb.Input.HierarchyChange[] detach = (global::Xcb.Input.HierarchyChange[])GLib.malloc0 (sizeof (global::Xcb.Input.DetachSlave));
                detach.length = 1;
                ((global::Xcb.Input.DetachSlave?)detach).type = global::Xcb.Input.HierarchyChangeType.DETACH_SLAVE;
                ((global::Xcb.Input.DetachSlave?)detach).len = (uint16)sizeof (global::Xcb.Input.DetachSlave) / 4;
                ((global::Xcb.Input.DetachSlave?)detach).deviceid = (global::Xcb.Input.DeviceId)id;

                ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_change_hierarchy (detach);
                GLib.free (detach);

                unowned global::Xcb.Input.HierarchyChange[] remove = (global::Xcb.Input.HierarchyChange[])GLib.malloc0 (sizeof (global::Xcb.Input.RemoveMaster));
                detach.length = 1;
                ((global::Xcb.Input.RemoveMaster?)remove).type = global::Xcb.Input.HierarchyChangeType.REMOVE_MASTER;
                ((global::Xcb.Input.RemoveMaster?)remove).len = (uint16)sizeof (global::Xcb.Input.RemoveMaster) / 4;
                ((global::Xcb.Input.RemoveMaster?)remove).deviceid = (global::Xcb.Input.DeviceId)m_Attachment;
                ((global::Xcb.Input.RemoveMaster?)remove).return_mode = global::Xcb.Input.ChangeMode.FLOAT;

                ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_change_hierarchy (remove);
                GLib.free (remove);

                m_Attachment = 0;
            }

            unowned global::Xcb.Input.HierarchyChange[] attach = (global::Xcb.Input.HierarchyChange[])GLib.malloc0 (sizeof (global::Xcb.Input.AttachSlave));
            attach.length = 1;
            ((global::Xcb.Input.AttachSlave?)attach).type = global::Xcb.Input.HierarchyChangeType.ATTACH_SLAVE;
            ((global::Xcb.Input.AttachSlave?)attach).deviceid = (global::Xcb.Input.DeviceId)id;
            ((global::Xcb.Input.AttachSlave?)attach).len = (uint16)sizeof (global::Xcb.Input.AttachSlave) / 4;
            ((global::Xcb.Input.AttachSlave?)attach).master = (global::Xcb.Input.DeviceId)m_MasterDevice.id;

            var cookie = ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_change_hierarchy_checked (attach);
            if (((global::Xcb.Input.Connection)Maia.Xcb.application.connection).request_check (cookie) == null)
            {
                // set master
                m_Attachment = m_MasterDevice.id;
            }
            GLib.free (attach);
        }
    }

    private void
    detach_from_core ()
    {
        if (m_MasterDevice != null)
        {
            if (m_Attachment != 0 && m_MasterDevice.id == m_Attachment)
            {
                unowned global::Xcb.Input.HierarchyChange[] detach = (global::Xcb.Input.HierarchyChange[])GLib.malloc0 (sizeof (global::Xcb.Input.DetachSlave));
                detach.length = 1;
                ((global::Xcb.Input.DetachSlave?)detach).type = global::Xcb.Input.HierarchyChangeType.DETACH_SLAVE;
                ((global::Xcb.Input.DetachSlave?)detach).len = (uint16)sizeof (global::Xcb.Input.DetachSlave) / 4;
                ((global::Xcb.Input.DetachSlave?)detach).deviceid = (global::Xcb.Input.DeviceId)id;

                ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_change_hierarchy (detach);
                GLib.free (detach);

                m_Attachment = 0;
            }

            string main_name = @"main - $id";

            // Create main device
            unowned global::Xcb.Input.HierarchyChange[] addmaster = (global::Xcb.Input.HierarchyChange[])GLib.malloc0 (sizeof (global::Xcb.Input.AddMaster) + main_name.length);
            addmaster.length = 1;
            ((global::Xcb.Input.AddMaster?)addmaster).len = (uint16)(sizeof (global::Xcb.Input.AddMaster) / 4) + (uint16)main_name.length;
            ((global::Xcb.Input.AddMaster?)addmaster).type = global::Xcb.Input.HierarchyChangeType.ADD_MASTER;
            ((global::Xcb.Input.AddMaster?)addmaster).send_core = (uint8)true;
            ((global::Xcb.Input.AddMaster?)addmaster).enable = (uint8)true;
            ((global::Xcb.Input.AddMaster?)addmaster).name_len = (uint16)main_name.length;
            unowned string? name = (string)((global::Xcb.Input.AddMaster*)addmaster + 1);
            GLib.Memory.copy (name, main_name, main_name.length);

            ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_change_hierarchy (addmaster);
            GLib.free ((void*)addmaster);

            uint32 main_id = 0;
            if (device_type == Maia.InputDevice.Type.KEYBOARD)
            {
                main_name += " keyboard";
            }
            else
            {
                main_name += " pointer";
            }
            // Search main device id
            var devicesInfo = ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_query_device (global::Xcb.Input.Device.ALL).reply (((global::Xcb.Input.Connection)Maia.Xcb.application.connection), null);
            if (devicesInfo != null)
            {
                foreach (unowned global::Xcb.Input.XIDeviceInfo? info in devicesInfo)
                {
                    if (info.name == main_name)
                    {
                        main_id = (uint32)info.deviceid;
                        break;
                    }
                }
            }

            if (main_id != 0)
            {
                unowned global::Xcb.Input.HierarchyChange[] attach = (global::Xcb.Input.HierarchyChange[])GLib.malloc0 (sizeof (global::Xcb.Input.AttachSlave));
                attach.length = 1;
                ((global::Xcb.Input.AttachSlave?)attach).type = global::Xcb.Input.HierarchyChangeType.ATTACH_SLAVE;
                ((global::Xcb.Input.AttachSlave?)attach).deviceid = (global::Xcb.Input.DeviceId)id;
                ((global::Xcb.Input.AttachSlave?)attach).len = (uint16)sizeof (global::Xcb.Input.AttachSlave) / 4;
                ((global::Xcb.Input.AttachSlave?)attach).master = (global::Xcb.Input.DeviceId)main_id;
    
                var cookie = ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).xi_change_hierarchy_checked (attach);
                if (((global::Xcb.Input.Connection)Maia.Xcb.application.connection).request_check (cookie) == null)
                {
                    // set master
                    m_Attachment = main_id;
                }
                GLib.free (attach);
            }
        }
    }

    private void
    on_view_destroyed (GLib.Object inObject)
    {
        unowned View view = inObject as View;

        m_Views.remove (view);
    }

    internal override string
    to_string ()
    {
        string ret = @"$id\n";
        ret += @"\t$name\n";
        ret += @"\t$device_type\n";
        ret += "\t%s".printf (master ? "master" : "slave");

        return ret;
    }

    internal new bool
    contains (View inView)
    {
        return inView in m_Views;
    }

    internal void
    associate_view (View inView)
    {
        if (!(inView in m_Views))
        {
            m_Views.insert (inView);
            inView.weak_ref (on_view_destroyed);
        }
    }

    internal void
    unassociate_view (View inView)
    {
        if (inView in m_Views)
        {
            m_Views.remove (inView);
            inView.weak_unref (on_view_destroyed);
        }
    }

    internal void
    watch_events (View inView)
    {
        if (inView in m_Views)
        {
            unowned global::Xcb.Input.EventMask[] masks = (global::Xcb.Input.EventMask[])GLib.malloc0 (sizeof (global::Xcb.Input.EventMask) + sizeof (uint32));
            masks.length = 1;
            masks[0].deviceid = (uint16)id;
            masks[0].mask_len = 1;
            unowned uint32* mask = (uint32*)((global::Xcb.Input.EventMask*)masks + 1);
            global::Xcb.Input.EventClass[] event_class = {};
            switch (device_type)
            {
                case Maia.InputDevice.Type.POINTER:
                    *mask = 1 << global::Xcb.Input.EventType.BUTTON_PRESS           |
                            1 << global::Xcb.Input.EventType.DEVICE_BUTTON_PRESS    |
                            1 << global::Xcb.Input.EventType.BUTTON_RELEASE         |
                            1 << global::Xcb.Input.EventType.DEVICE_BUTTON_RELEASE  |
                            1 << global::Xcb.Input.EventType.MOTION                 |
                            1 << global::Xcb.Input.EventType.DEVICE_MOTION_NOTIFY;

                    event_class += get_event_class (global::Xcb.Input.InputClass.BUTTON, false);
                    event_class += get_event_class (global::Xcb.Input.InputClass.BUTTON, true);
                    event_class += get_event_class (global::Xcb.Input.InputClass.VALUATOR, false);
                    break;

                case Maia.InputDevice.Type.KEYBOARD:
                    *mask = 1 << global::Xcb.Input.EventType.KEY_PRESS          |
                            1 << global::Xcb.Input.EventType.DEVICE_KEY_PRESS   |
                            1 << global::Xcb.Input.EventType.KEY_RELEASE        |
                            1 << global::Xcb.Input.EventType.DEVICE_KEY_RELEASE;

                    event_class += get_event_class (global::Xcb.Input.InputClass.KEY, false);
                    event_class += get_event_class (global::Xcb.Input.InputClass.KEY, true);
                    break;
            }
            ((global::Xcb.Input.Window)inView.xid).xi_select_events ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, masks);

            ((global::Xcb.Input.Window)inView.xid).select_extension_event ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, event_class);

            GLib.free (masks);
        }
    }

    internal void
    unwatch_events (View inView)
    {
        if (inView in m_Views)
        {
            unowned global::Xcb.Input.EventMask[] masks = (global::Xcb.Input.EventMask[])GLib.malloc0 (sizeof (global::Xcb.Input.EventMask) + sizeof (uint32));
            masks.length = 1;
            masks[0].deviceid = (uint16)id;
            masks[0].mask_len = 1;
            unowned uint32* mask = (uint32*)((global::Xcb.Input.EventMask*)masks + 1);
            *mask = 0;

            ((global::Xcb.Input.Window)inView.xid).xi_select_events ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, masks);

            GLib.free (masks);
        }
    }

    internal void
    grab_key (View inView, Modifier inModifier, Key inKey)
    {
        if (inView in m_Views)
        {
            if (m_Symbols == null)
            {
                m_Symbols = new global::Xcb.Util.KeySymbols (Maia.Xcb.application.connection);
            }

            global::Xcb.Input.EventClass[] event_class = {};
            event_class += get_event_class (global::Xcb.Input.InputClass.KEY, false);
            event_class += get_event_class (global::Xcb.Input.InputClass.KEY, true);

            global::Xcb.ModMask mask = modifier_to_mod_mask (inModifier);
            global::Xcb.Keysym keysym = convert_key_to_xcb_keysym (inKey);
            global::Xcb.Keycode[]? keycode = m_Symbols.get_keycode (keysym);

            if (keycode != null)
            {
                var cookie = ((global::Xcb.Input.Window)inView.xid).grab_device_key ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, (uint16)mask,
                                                                                     (uint8)id, (uint8)id, (uint8)keycode[0], global::Xcb.GrabMode.ASYNC, global::Xcb.GrabMode.ASYNC,
                                                                                     true, event_class);
                global::Xcb.GenericError? err = Maia.Xcb.application.connection.request_check (cookie);
                if (err != null)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, @"Error on grab key $(err.error_code)");
                }
            }
        }
    }

    internal void
    ungrab_key (View inView, Modifier inModifier, Key inKey)
    {
        if (inView in m_Views)
        {
            if (m_Symbols == null)
            {
                m_Symbols = new global::Xcb.Util.KeySymbols (Maia.Xcb.application.connection);
            }

            global::Xcb.ModMask mask = modifier_to_mod_mask (inModifier);
            global::Xcb.Keysym keysym = convert_key_to_xcb_keysym (inKey);
            global::Xcb.Keycode[]? keycode = m_Symbols.get_keycode (keysym);

            if (keycode != null)
            {
                var cookie = ((global::Xcb.Input.Window)inView.xid).ungrab_device_key ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, (uint16)mask,
                                                                                       (uint8)id, (uint8)keycode[0], (uint8)id);
                global::Xcb.GenericError? err = Maia.Xcb.application.connection.request_check (cookie);
                if (err != null)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, @"Error on grab key $(err.error_code)");
                }
            }
        }
    }

    internal void
    grab (View inView)
    {
        if (inView in m_Views)
        {
            global::Xcb.Input.EventClass[] event_class = {};

            switch (device_type)
            {
                case Maia.InputDevice.Type.POINTER:
                    event_class += get_event_class (global::Xcb.Input.InputClass.BUTTON, false);
                    event_class += get_event_class (global::Xcb.Input.InputClass.BUTTON, true);
                    event_class += get_event_class (global::Xcb.Input.InputClass.VALUATOR, false);
                    break;

                case Maia.InputDevice.Type.KEYBOARD:
                    event_class += get_event_class (global::Xcb.Input.InputClass.KEY, false);
                    event_class += get_event_class (global::Xcb.Input.InputClass.KEY, true);
                    break;
            }

            ((global::Xcb.Input.Window)inView.xid).grab_device ((global::Xcb.Input.Connection)Maia.Xcb.application.connection, global::Xcb.CURRENT_TIME,
                                                                global::Xcb.GrabMode.ASYNC, global::Xcb.GrabMode.ASYNC, true, (uint8)id, event_class);
        }
    }

    internal void
    ungrab (View inView)
    {
        if (inView in m_Views)
        {
            ((global::Xcb.Input.Connection)Maia.Xcb.application.connection).ungrab_device (global::Xcb.CURRENT_TIME, (uint8)id);
        }
    }

    internal void
    wrap_pointer (View inView, Graphic.Point inPosition)
    {
        if (inView in m_Views)
        {
            var pos = inView.root_position;
            pos.x += inPosition.x;
            pos.y += inPosition.y;

            ((global::Xcb.Input.Window)inView.screen.xscreen.root).xi_warp_pointer ((global::Xcb.Input.Connection)Maia.Xcb.application.connection,
                                                                                    (global::Xcb.Input.Window)inView.screen.xscreen.root, 0, 0, 0, 0,
                                                                                    (global::Xcb.Input.Fp1616)((int32)pos.x << 16),
                                                                                    (global::Xcb.Input.Fp1616)((int32)pos.y << 16),
                                                                                    (global::Xcb.Input.DeviceId)m_Attachment);
        }
    }
}

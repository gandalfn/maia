/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * input-devices.vala
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

public class Maia.Xcb.InputDevices : Maia.InputDevices
{
    // static properties
    static bool s_Initialized = false;

    // properties
    private InputDevice[] m_MasterDevices = {};

    // accessors
    public InputDevice[] master_devices {
        get {
            return m_MasterDevices;
        }
    }

    // methods
    public InputDevices (global::Xcb.Connection inConnection)
    {
        if (!s_Initialized)
        {
            // Query damage extensionn
            inConnection.prefetch_extension_data (ref global::Xcb.Damage.extension);
            unowned global::Xcb.QueryExtensionReply? extension_reply = inConnection.get_extension_data (ref global::Xcb.Input.extension);
            if (extension_reply != null && extension_reply.present)
            {
                var version_reply = ((global::Xcb.Input.Connection)inConnection).xi_query_version (2, 0).reply ((global::Xcb.Input.Connection)inConnection, null);
                if (version_reply != null)
                {
                    s_Initialized = true;
                }
            }
        }

        if (s_Initialized)
        {
            var devicesInfo = ((global::Xcb.Input.Connection)inConnection).xi_query_device (global::Xcb.Input.Device.ALL).reply (((global::Xcb.Input.Connection)inConnection), null);
            if (devicesInfo == null)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.MAIN, @"error on get input devices list");
            }

            foreach (unowned global::Xcb.Input.XIDeviceInfo? info in devicesInfo)
            {
                Maia.InputDevice.Type device_type = Maia.InputDevice.Type.NONE;
                bool is_core = false;

                var reply = ((global::Xcb.Input.Connection)inConnection).get_device_control (global::Xcb.Input.DeviceControl.CORE, (uint8)info.deviceid).reply (((global::Xcb.Input.Connection)inConnection), null);
                if (reply != null)
                {
                    unowned global::Xcb.Input.DeviceCoreState? state = (global::Xcb.Input.DeviceCoreState?)((global::Xcb.Input.GetDeviceControlReply*)reply + 1);
                    is_core = (bool)state.iscore;
                }

                if (is_core && (info.type == global::Xcb.Input.DeviceType.MASTER_POINTER || info.type == global::Xcb.Input.DeviceType.MASTER_KEYBOARD))
                {
                    if (info.type == global::Xcb.Input.DeviceType.MASTER_POINTER)
                    {
                        device_type = Maia.InputDevice.Type.POINTER;
                    }
                    else if (info.type == global::Xcb.Input.DeviceType.MASTER_KEYBOARD)
                    {
                        device_type = Maia.InputDevice.Type.KEYBOARD;
                    }

                    m_MasterDevices += new InputDevice ((uint32)info.deviceid, info.name, device_type, true, info.attachment);
                }
                else if (info.type == global::Xcb.Input.DeviceType.SLAVE_POINTER || info.type == global::Xcb.Input.DeviceType.SLAVE_KEYBOARD)
                {
                    if (info.type == global::Xcb.Input.DeviceType.SLAVE_POINTER)
                    {
                        device_type = Maia.InputDevice.Type.POINTER;
                    }
                    else if (info.type == global::Xcb.Input.DeviceType.SLAVE_KEYBOARD)
                    {
                        device_type = Maia.InputDevice.Type.KEYBOARD;
                    }

                    var device = new InputDevice ((uint32)info.deviceid, info.name, device_type, false, info.attachment);
                    add (device);
                    device.ref ();
                }
            }

            foreach (unowned Maia.InputDevice device in this)
            {
                foreach (unowned InputDevice master in m_MasterDevices)
                {
                    if (device.device_type == master.device_type)
                    {
                        (device as InputDevice).master_device = master;
                        break;
                    }
                }
            }
        }
    }

    internal override void
    delegate_construct ()
    {
        if (Maia.Xcb.application != null && Maia.Xcb.application.input_devices != null)
        {
            foreach (unowned Maia.InputDevice device in Maia.Xcb.application.input_devices)
            {
                add (device);
            }
        }
    }

    internal void
    watch_events (View inView)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            xcb_device.watch_events (inView);
        }
    }

    internal void
    unwatch_events (View inView)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            xcb_device.unwatch_events (inView);
        }
    }

    internal void
    grab_pointer (View inView)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.POINTER)
            {
                xcb_device.grab (inView);
            }
        }
    }

    internal void
    ungrab_pointer (View inView)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.POINTER)
            {
                xcb_device.ungrab (inView);
            }
        }
    }

    internal void
    grab_keyboard (View inView)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.KEYBOARD)
            {
                xcb_device.grab (inView);
            }
        }
    }

    internal void
    ungrab_keyboard (View inView)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.KEYBOARD)
            {
                xcb_device.ungrab (inView);
            }
        }
    }

    internal void
    grab_key (View inView, Modifier inModifier, Key inKey)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.KEYBOARD)
            {
                xcb_device.grab_key (inView, inModifier, inKey);
            }
        }
    }

    internal void
    ungrab_key (View inView, Modifier inModifier, Key inKey)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.KEYBOARD)
            {
                xcb_device.ungrab_key (inView, inModifier, inKey);
            }
        }
    }

    internal void
    wrap_pointer (View inView, Graphic.Point inPosition)
    {
        foreach (unowned Maia.InputDevice device in this)
        {
            unowned InputDevice xcb_device = device as InputDevice;
            if (xcb_device.device_type == Maia.InputDevice.Type.POINTER)
            {
                xcb_device.wrap_pointer (inView, inPosition);
            }
        }
    }
}

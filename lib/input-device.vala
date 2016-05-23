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

public abstract class Maia.InputDevice : Core.Object
{
    // type
    public enum Type
    {
        NONE,
        POINTER,
        KEYBOARD;

        public string
        to_string ()
        {
            switch (this)
            {
                case POINTER:
                    return "pointer";

                case KEYBOARD:
                    return "keyboard";
            }

            return "";
        }
    }

    // accessors
    /**
     * Device name
     */
    public abstract string name { get; }

    /**
     * Device type
     */
    public abstract Type device_type { get; }

    /**
     * Indicate is device was master
     */
    [CCode (notify = false)]
    public abstract bool master { get; set; }

    // methods
    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override int
    compare (Core.Object inObject)
        requires (inObject is InputDevice)
    {
        return (int)(id - inObject.id);
    }
}

public class Maia.InputDevices : Core.Object
{
    // types
    public class Iterator
    {
        // properties
        internal unowned InputDevices m_Devices;
        internal int                  m_Index;

        // methods
        internal Iterator (InputDevices inDevices)
        {
            m_Devices = inDevices;
            m_Index = -1;
        }

        internal Iterator.begin (InputDevices inDevices)
        {
            m_Devices = inDevices;
            m_Index = 0;
        }

        internal Iterator.end (InputDevices inDevices)
        {
            m_Devices = inDevices;
            m_Index = m_Devices.length;
        }

        public bool
        next ()
        {
            m_Index++;

            return m_Index < m_Devices.length;
        }

        public unowned InputDevice
        get ()
        {
            return m_Devices[m_Index];
        }

        public bool
        compare (Iterator inIter)
        {
            return m_Devices == inIter.m_Devices && m_Index == inIter.m_Index;
        }
    }

    // properties
    private Core.Array<unowned InputDevice> m_Devices = new Core.Array<unowned InputDevice> ();

    // accessors
    public virtual int length {
        get {
            return m_Devices.length;
        }
    }

    // methods
    public InputDevices ()
    {
    }

    private void
    on_device_destroyed (GLib.Object inObject)
    {
        unowned InputDevice device = inObject as InputDevice;

        m_Devices.remove (device);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    /**
     * Returns the input device at the specified index.
     *
     * @param inIndex zero-based index of the input device to be returned
     *
     * @return the InputDevice at the specified index
     */
    public virtual new unowned InputDevice?
    @get (int inIndex)
    {
        return m_Devices[inIndex];
    }

    /**
     * Returns a Iterator that can be used for simple iteration of input devices.
     *
     * @return a Iterator that can be used for simple iteration of input devices
     */
    public new Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    /**
     * Returns first Iterator of input devices.
     *
     * @return the first Iterator of input devices
     */
    public new Iterator
    iterator_begin ()
    {
        return new Iterator.begin (this);
    }

    /**
     * Returns last Iterator of input devices.
     *
     * @return the last Iterator of input devices
     */
    public new Iterator
    iterator_end ()
    {
        return new Iterator.end (this);
    }

    /**
     * Add input device to list
     *
     * @param inDevice input device to add
     */
    public new virtual void
    add (InputDevice inDevice)
    {
        if (!(inDevice in m_Devices))
        {
            m_Devices.insert (inDevice);
            inDevice.weak_ref (on_device_destroyed);
        }
    }

    /**
     * Remove input device from list
     *
     * @param inDevice input device to add
     */
    public new virtual void
    remove (InputDevice inDevice)
    {
        if (inDevice in m_Devices)
        {
            m_Devices.remove (inDevice);
            inDevice.weak_unref (on_device_destroyed);
        }
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * message.vala
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

public class Maia.Core.Message : GLib.Object
{
    // properties
    private uint8[] m_Raw = {};

    // accessors
    public uint8[] raw {
        get {
            return m_Raw;
        }
    }

    public uint length {
        get {
            return m_Raw.length;
        }
        construct {
            if (value > 0)
            {
                resize (value);
            }
        }
    }

    // methods
    /**
     * Provides the message abstraction for send to dispatcheer
     *
     * @param inLength The number of bytes of the message
     */
     public Message (uint inLength)
     {
        GLib.Object (length: inLength);
     }

    /**
     * Provides the message abstraction for send to dispatcheer
     *
     * @param inBuffer This buffer contains the message.
     * @param inOffset The offset of the message in the buffer.
     * @param inLength The number of bytes of the message.
     */
    public Message.from_data (uint8[] inBuffer, uint inOffset = 0, uint inLength = -1)
    {
        if (inLength < 0) inLength = inBuffer.length;
        GLib.Object (length: (inLength - inOffset));
        GLib.Memory.copy (m_Raw, &inBuffer[inOffset], sizeof (uint8) * inLength);
    }

    /**
     * Resize the buffer size
     *
     * @param inLength new length of messsage buffer
     */
    protected void
    resize (uint inLength)
    {
        m_Raw.resize ((int)inLength);
    }

    /**
     * Return the string representation of the message.
     *
     * @param inOffset The offset where to begin display in message
     * @param inNumBytes The number of bytes to display
     *
     * @return the string representation of the message
     */
    public string
    to_string (uint inOffset = 0, uint inNumBytes = 0)
        requires (inOffset + inNumBytes < m_Raw.length)
    {
        if (inNumBytes == 0) inNumBytes = m_Raw.length - inOffset;

        GLib.StringBuilder builder = new GLib.StringBuilder();

        builder.append("%02x".printf (m_Raw[inOffset]));

        if (inNumBytes > 1)
        {
            for (int counter = 1; counter < inNumBytes; counter++)
            {
                builder.append(" ");
                builder.append("%02x".printf (m_Raw[inOffset + counter]));
            }
        }
        return builder.str;
    }

    /**
     * Return the string raw representation of the message.
     *
     * @param inOffset The offset where to begin display in message
     * @param inNumBytes The number of bytes to display
     *
     * @return the string raw representation of the message
     */
    public string
    to_raw_string (uint inOffset = 0, uint inNumBytes = 0)
        requires (inOffset + inNumBytes < m_Raw.length)
    {
        if (inNumBytes == 0) inNumBytes = m_Raw.length - inOffset;

        GLib.StringBuilder builder = new GLib.StringBuilder ();

        for (int counter = 0; counter < inNumBytes; counter++)
        {
            if (m_Raw[inOffset + counter] > 0)
                builder.append_c ((char)m_Raw[inOffset + counter]);
        }

        return builder.str;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     *
     * @return value
     */
    public new uint8
    @get (uint inIndex)
        requires (inIndex < m_Raw.length)
    {
        return m_Raw[inIndex];
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public new void
    set (uint inIndex, uint8 inValue)
    {
        if (inIndex >= m_Raw.length)
        {
            m_Raw.resize ((int)inIndex + 1);
        }
        m_Raw[inIndex] = inValue;
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back (uint8 inValue)
    {
        uint ret = m_Raw.length;
        set(m_Raw.length, inValue);
        return ret;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     *
     * @return value
     */
    public uint16
    get_uint16 (uint inIndex)
        requires (inIndex + 1 < m_Raw.length)
    {
        uint16 ret = 0;
        ret |= (uint16)(m_Raw[inIndex + 0] << 8);
        ret |= (uint16)m_Raw[inIndex + 1];

        return ret;
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public void
    set_uint16 (uint inIndex, uint16 inValue)
    {
        if (inIndex + 1 >= m_Raw.length)
        {
            m_Raw.resize ((int)inIndex + 2);
        }
        m_Raw[inIndex + 0] = (uint8)((inValue >> 8) & 0xff);
        m_Raw[inIndex + 1] = (uint8)(inValue & 0xff);
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back_uint16 (uint16 inValue)
    {
        uint ret = m_Raw.length;
        set_uint16 (m_Raw.length, inValue);
        return ret;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     *
     * @return value
     */
    public uint32
    get_uint32 (uint inIndex)
        requires (inIndex + 3 < m_Raw.length)
    {
        uint32 ret = 0;
        ret |= (uint32)(m_Raw[inIndex + 0] << 24);
        ret |= (uint32)(m_Raw[inIndex + 1] << 16);
        ret |= (uint32)(m_Raw[inIndex + 2] << 8);
        ret |= (uint32)m_Raw[inIndex  + 3];

        return ret;
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public void
    set_uint32 (uint inIndex, uint32 inValue)
    {
        if (inIndex + 3 >= m_Raw.length)
        {
            m_Raw.resize ((int)inIndex + 4);
        }
        m_Raw[inIndex + 0] = (uint8)((inValue >> 24) & 0xff);
        m_Raw[inIndex + 1] = (uint8)((inValue >> 16) & 0xff);
        m_Raw[inIndex + 2] = (uint8)((inValue >> 8) & 0xff);
        m_Raw[inIndex + 3] = (uint8)(inValue & 0xff);
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back_uint32 (uint32 inValue)
    {
        uint ret = m_Raw.length;
        set_uint32 (m_Raw.length, inValue);
        return ret;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     *
     * @return value
     */
    public uint64
    get_uint64 (uint inIndex)
        requires (inIndex + 7 < m_Raw.length)
    {
        uint64 ret = 0;
        ret |= (uint64)(m_Raw[inIndex + 0] << 56);
        ret |= (uint64)(m_Raw[inIndex + 1] << 48);
        ret |= (uint64)(m_Raw[inIndex + 2] << 40);
        ret |= (uint64)(m_Raw[inIndex + 3] << 32);
        ret |= (uint64)(m_Raw[inIndex + 4] << 24);
        ret |= (uint64)(m_Raw[inIndex + 5] << 16);
        ret |= (uint64)(m_Raw[inIndex + 6] << 8);
        ret |= (uint64)(m_Raw[inIndex + 7]);

        return ret;
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public void
    set_uint64 (uint inIndex, uint64 inValue)
    {
        if (inIndex + 7 >= m_Raw.length)
        {
            m_Raw.resize ((int)inIndex + 8);
        }
        m_Raw[inIndex + 0] = (uint8)((inValue >> 56) & 0xff);
        m_Raw[inIndex + 1] = (uint8)((inValue >> 48) & 0xff);
        m_Raw[inIndex + 2] = (uint8)((inValue >> 40) & 0xff);
        m_Raw[inIndex + 3] = (uint8)((inValue >> 32) & 0xff);
        m_Raw[inIndex + 4] = (uint8)((inValue >> 24) & 0xff);
        m_Raw[inIndex + 5] = (uint8)((inValue >> 16) & 0xff);
        m_Raw[inIndex + 6] = (uint8)((inValue >> 8) & 0xff);
        m_Raw[inIndex + 7] = (uint8)(inValue & 0xff);
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back_uint64 (uint64 inValue)
    {
        uint ret = m_Raw.length;
        set_uint64 (m_Raw.length, inValue);
        return ret;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     *
     * @return value
     */
    public double
    get_double (uint inIndex)
        requires (inIndex + 3 < m_Raw.length)
    {
        uint32 val = get_uint32 (inIndex);

        return *((double*)(&val));
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public void
    set_double (uint inIndex, double inValue)
    {
        if (inIndex + 3 >= m_Raw.length)
        {
            m_Raw.resize ((int)inIndex + 4);
        }
        set_uint32 (inIndex, *((uint32*)(&inValue)));
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back_double (double inValue)
    {
        uint ret = m_Raw.length;
        set_double (m_Raw.length, inValue);
        return ret;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     * @param inLength string length
     *
     * @return value
     */
    public string
    get_string (uint inIndex, uint inLength)
        requires (inIndex + inLength < m_Raw.length)
    {
        if (inLength == 0) inLength = m_Raw.length;

        GLib.StringBuilder builder = new GLib.StringBuilder ();

        for (uint cpt = inIndex; cpt < inLength; ++cpt)
        {
            if (m_Raw[cpt] > 0)
                builder.append_c ((char)m_Raw[cpt]);
        }

        return builder.str;
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public void
    set_string (uint inIndex, string inValue)
    {
        set_array (inIndex, inValue.data);
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back_string (string inValue)
    {
        uint ret = m_Raw.length;
        set_string (m_Raw.length, inValue);
        return ret;
    }

    /**
     * Get value at inIndex
     *
     * @param inIndex position index of value to get
     * @param inFormat variant format type
     *
     * @return value
     */
    public GLib.Variant
    get_variant (uint inIndex, string inFormat)
        requires (inIndex < m_Raw.length)
    {
        var data = new GLib.ByteArray ();
        data.append (m_Raw[inIndex:m_Raw.length]);
        var type = new GLib.VariantType (inFormat);

        return GLib.Variant.new_from_data<GLib.ByteArray> (type, data.data, true, data);
    }

    /**
     * Set inValue at inPos
     *
     * @param inIndex position index of value to set
     * @param inValue the new value
     */
    public void
    set_variant (uint inIndex, GLib.Variant inValue)
    {
        unowned uint8[] data = (uint8[])inValue.get_data ();
        data.length = (int)inValue.get_size ();
        set_array (inIndex, data, (uint)inValue.get_size ());
    }

    /**
     * Set inValue at end of message
     *
     * @param inValue the new value
     */
    public uint
    push_back_variant (GLib.Variant inValue)
    {
        uint ret = m_Raw.length;
        set_variant (m_Raw.length, inValue);
        return ret;
    }

    /**
     * Set array at inIndex
     *
     * @param inIndex position index of array to get
     * @param inArray the new array value
     * @param inNumBytes the number of bytes to copy
     */
    public void
    set_array (uint inIndex, uint8[] inArray, uint inNumBytes = 0)
    {
        if (inIndex + (inNumBytes == 0 ? inArray.length : inNumBytes) > m_Raw.length)
        {
            m_Raw.resize ((int)inIndex + (int)(inNumBytes == 0 ? inArray.length : inNumBytes));
        }
        GLib.Memory.copy (&m_Raw[inIndex], inArray, sizeof (uint8) * (inNumBytes == 0 ? inArray.length : inNumBytes));
    }

    /**
     * Set inValue at end of message
     *
     * @param inArray the new array value
     * @param inNumBytes the number of bytes to copy
     */
    public uint
    push_back_array (uint8[] inArray, uint inNumBytes = 0)
    {
        uint ret = m_Raw.length;
        set_array (m_Raw.length, inArray, inNumBytes);
        return ret;
    }

    /**
     * Copy data inMessage in this
     *
     * @param inMessage message to copy to
     */
    public void
    copy (Message inMessage)
        requires (inMessage.m_Raw.length <= m_Raw.length)
    {
        resize (inMessage.length);
        GLib.Memory.copy (m_Raw, inMessage.m_Raw, sizeof (uint8) * inMessage.m_Raw.length);
    }
}

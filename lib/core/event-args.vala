/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-args.vala
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

public abstract class Maia.Core.EventArgs : GLib.Object, Core.Serializable
{
    // types
    internal class ProtocolBuffer : Core.Object
    {
        // properties
        private string           m_Buffer;
        private string           m_Root;
        private Protocol.Message m_Message;

        // accessors
        public Protocol.Message message {
            get {
                return m_Message;
            }
        }

        // methods
        public ProtocolBuffer (string inName, string inRoot, string inBuffer) throws ProtocolError, ParseError
        {
            GLib.Object (id: GLib.Quark.from_string (inName));

            m_Root = inRoot;
            m_Buffer = inBuffer;

            Protocol.Buffer buffer = new Protocol.Buffer.from_data (m_Buffer, m_Buffer.length);
            m_Message = buffer[m_Root];
        }

        internal override int
        compare (Object inOther)
        {
            return (int)(id - inOther.id);
        }

        public int
        compare_with_id (uint32 inId)
        {
            return (int)(id - inId);
        }
    }

    // static properties
    private static int s_Sequence = 1;
    private static Set<ProtocolBuffer> s_EventArgsProtocolBuffers;
    private static Map<string, string> s_EventArgsTypes;

    // properties
    private Protocol.Message? m_Message;

    // accessors
    [CCode (notify = false)]
    public virtual GLib.Variant serialize {
        owned get {
            GLib.Variant ret = null;
            if (m_Message != null)
            {
                ret = m_Message.serialize;
            }

            return ret;
        }
        set {
            if (m_Message != null)
            {
                m_Message.serialize = value;
            }
        }
    }
    public int sequence { get; construct; }

    // static methods
    static construct
    {
        if (s_EventArgsProtocolBuffers == null)
        {
            s_EventArgsProtocolBuffers = new Set<ProtocolBuffer> ();
        }
    }

    public static void
    register_protocol (string inTypeName, string inMessage, string inBuffer)
    {
        if (s_EventArgsProtocolBuffers == null)
        {
            s_EventArgsProtocolBuffers = new Set<ProtocolBuffer> ();
        }

        try
        {
            ProtocolBuffer buffer = new ProtocolBuffer (inTypeName, inMessage, inBuffer);
            s_EventArgsProtocolBuffers.insert (buffer);
        }
        catch (GLib.Error error)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Error on register protocol $inMessage for $(inTypeName): $(error.message)");
        }
    }

    public static void
    register_type_name (string inTypeName, string inName)
    {
        if (s_EventArgsTypes == null)
        {
            s_EventArgsTypes = new Map<string, string> ();
        }

        s_EventArgsTypes[inTypeName] = inName;
    }

    internal static string
    get_type_name (GLib.Type inType)
    {
        if (s_EventArgsTypes != null && inType.name () in s_EventArgsTypes)
        {
            return s_EventArgsTypes[inType.name ()];
        }

        return inType.name ();
    }

    internal static GLib.Type
    get_type_from_name (string inName)
    {
//~         if (s_EventArgsTypes != null)
//~         {
//~             foreach (unowned Pair<string, string> pair in s_EventArgsTypes)
//~             {
//~                 if (pair.second == inName)
//~                 {
//~                     return GLib.Type.from_name (pair.first);
//~                 }
//~             }
//~         }

        return GLib.Type.from_name (inName);
    }

    // methods
    construct
    {
        get_protocol_buffer_message ();
    }

    public EventArgs ()
    {
        GLib.Object (sequence: GLib.AtomicInt.add (ref s_Sequence, 1));
    }

    private unowned Protocol.Message?
    get_message (string inFieldName)
    {
        unowned Protocol.Message? msg = null;

        if (m_Message != null)
        {
            // field is in instance message
            if (inFieldName in m_Message)
            {
                msg = m_Message;
            }
            else
            {
                // search in parent class
                for (GLib.Type p = get_type ().parent (); msg == null && p != typeof (EventArgs) && p != 0; p = p.parent ())
                {
                    unowned ProtocolBuffer? buffer = s_EventArgsProtocolBuffers.search<uint32> ((uint32)GLib.Quark.from_string (p.name ()), ProtocolBuffer.compare_with_id);

                    if (buffer != null && buffer.message.name != m_Message.name)
                    {
                        // search field message
                        foreach (unowned Core.Object child in m_Message)
                        {
                            unowned Protocol.Field? field = child as Protocol.Field;

                            // found field message
                            if (field != null && field.field_type == Protocol.Field.Type.MESSAGE)
                            {
                                Protocol.Message? message = (Protocol.Message)field[0];

                                // field message matches message type of parent
                                if (message != null && message.name == buffer.message.name && inFieldName in message)
                                {
                                    msg = message;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }

        return msg;
    }

    protected void
    get_protocol_buffer_message ()
    {
        if (m_Message == null)
        {
            unowned ProtocolBuffer? buffer = s_EventArgsProtocolBuffers.search<uint32> ((uint32)GLib.Quark.from_string (get_type ().name ()), ProtocolBuffer.compare_with_id);
            if (buffer == null)
            {
                for (GLib.Type p = get_type ().parent (); buffer == null && p != typeof (EventArgs) && p != 0; p = p.parent ())
                {
                    buffer = s_EventArgsProtocolBuffers.search<uint32> ((uint32)GLib.Quark.from_string (p.name ()), ProtocolBuffer.compare_with_id);
                }
            }
            if (buffer != null)
            {
                m_Message = buffer.message.copy () as Protocol.Message;
            }
        }
    }

    public virtual void
    accumulate (EventArgs inArgs)
        requires (inArgs.get_type ().is_a (get_type ()))
    {
        if (m_Message != null && inArgs.m_Message != null)
        {
            m_Message = inArgs.m_Message.copy () as Protocol.Message;
        }
    }

    public EventArgs
    copy ()
    {
        return GLib.Object.new (get_type (), sequence: sequence, serialize: serialize) as EventArgs;
    }

    public bool
    contains (string inName)
    {
        bool ret = false;

        unowned Protocol.Message msg = get_message (inName);
        if (msg != null)
        {
            ret = inName in msg;
        }

        return ret;
    }

    public bool
    is_array (string inName)
    {
        bool ret = false;

        unowned Protocol.Message msg = get_message (inName);
        if (msg != null)
        {
            ret = msg.is_array (inName);
        }

        return ret;
    }

    public int
    get_field_length (string inName)
    {
        int ret = 0;
        unowned Protocol.Message msg = get_message (inName);
        if (msg != null)
        {
            ret = msg.get_field_length (inName);
        }

        return ret;
    }

    public new GLib.Value?
    @get (string inName, int inIndex = 0)
    {
        GLib.Value? ret = null;

        unowned Protocol.Message msg = get_message (inName);
        if (msg != null)
        {
            ret = msg[inName, inIndex];
        }

        return ret;
    }

    public new void
    @set (string inName, int inIndex, GLib.Value inVal)
    {
        unowned Protocol.Message msg = get_message (inName);
        if (msg != null)
        {
            msg[inName, inIndex] = inVal;
        }
    }

    public void
    clear (string inName)
    {
        unowned Protocol.Message msg = get_message (inName);
        if (msg != null)
        {
            msg.clear (inName);
        }
    }

    public void
    resize (string inName, uint inSize)
    {
        unowned Protocol.Message msg = get_message (inName);
        if (msg != null && msg.is_array (inName))
        {
            msg.resize (inName, inSize);
        }
    }

    public int
    add_value (string inName, GLib.Value inVal)
    {
        int ret = -1;
        unowned Protocol.Message msg = get_message (inName);

        if (msg != null && msg.is_array (inName))
        {
            ret = msg.add_value (inName, inVal);
        }

        return ret;
    }
}

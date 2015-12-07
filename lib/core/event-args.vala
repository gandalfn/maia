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

public abstract class Maia.Core.EventArgs : GLib.Object
{
    // static properties
    private static int s_Sequence = 1;
    private static GLib.Quark s_EventArgsProtoBufferQuark;

    // properties
    private unowned Protocol.Message? m_Message;

    // accessors
    public virtual GLib.Variant serialize {
        owned get {
            GLib.Variant ret = null;
            if (m_Message != null)
            {
                ret = m_Message.to_variant ();
            }

            return ret;
        }
        set {
            if (m_Message != null)
            {
                m_Message.set_variant (value);
            }
        }
    }
    public int sequence { get; construct; }

    // static methods
    static construct
    {
        s_EventArgsProtoBufferQuark = GLib.Quark.from_string ("MaiaCoreEventArgsProtoBufferQuark");
    }

    public static void
    register_protocol (GLib.Type inType, string inMessage, string inBuffer)
    {
        try
        {
            Protocol.Buffer buffer = new Protocol.Buffer.from_data (inBuffer, inBuffer.length);
            Protocol.Message msg = buffer[inMessage];
            inType.set_qdata (s_EventArgsProtoBufferQuark, (owned)msg);
        }
        catch (GLib.Error error)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Error on register protocol $inMessage for $(inType.name()): $(error.message)");
        }
    }

    public static void
    register_protocol_from_filename (GLib.Type inType, string inMessage, string inFilename)
    {
        try
        {
            Protocol.Buffer buffer = new Protocol.Buffer (inFilename);
            Protocol.Message msg = buffer[inMessage];
            inType.set_qdata (s_EventArgsProtoBufferQuark, (owned)msg);
        }
        catch (GLib.Error error)
        {
            Log.error (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Error on register protocol $inMessage for $(inType.name()): $(error.message)");
        }
    }

    // methods
    construct
    {
        m_Message = (Protocol.Message?)get_type ().get_qdata (s_EventArgsProtoBufferQuark);
    }

    public EventArgs ()
    {
        GLib.Object (sequence: GLib.AtomicInt.add (ref s_Sequence, 1));
    }

    public virtual void
    accumulate (EventArgs inArgs)
        requires (inArgs.get_type ().is_a (get_type ()))
    {
    }

    public EventArgs
    copy ()
    {
        return GLib.Object.new (get_type (), sequence: sequence, serialize: serialize) as EventArgs;
    }

    public new unowned Protocol.Field?
    @get (string inName)
    {
        unowned Protocol.Field? ret = null;

        if (m_Message != null)
        {
            ret = m_Message.get (inName);
        }

        return ret;
    }
}

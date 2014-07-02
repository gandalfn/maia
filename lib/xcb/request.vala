/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * request.vala
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

internal enum Maia.Xcb.CompressAction
{
    KEEP,
    REMOVE,
    REMOVE_CURRENT,
    REMOVE_BOTH
}

internal abstract class Maia.Xcb.Request : Core.Object
{
    // static properties
    private static int s_Sequence = 1;

    // accessors
    public int sequence { get; construct; }
    public unowned Window window { get; construct; }

    // methods
    public Request (Window inWindow)
    {
        GLib.Object (sequence: GLib.AtomicInt.add (ref s_Sequence, 1), window: inWindow);
    }

    public abstract void run ();
    public abstract CompressAction compress (Request inRequest);

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (window.window == null && other.window.window != null)
            return -1;

        if (window.window != null && other.window.window == null)
            return 1;

        if (window.window == null && other.window.window == null)
            return sequence - other.sequence;

        if (window.xid == ((Window)other.window.window).xid)
            return -1;

        if (((Window)window.window).xid == other.window.xid)
            return 1;

        return sequence - other.sequence;
    }
}

internal class Maia.Xcb.MapRequest : Request
{
    // methods
    public MapRequest (Window inWindow)
    {
        base (inWindow);
    }

    internal override void
    run ()
    {
        // Map window
        ((global::Xcb.Window)window.xid).map (window.connection);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (window == inRequest.window && inRequest is MapRequest)
            return CompressAction.REMOVE_CURRENT;
        else if (window == inRequest.window && inRequest is UnmapRequest)
            return CompressAction.REMOVE_BOTH;

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence map window $(window.name) xid: $(window.xid)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (window.xid == other.window.xid && other is ReparentRequest)
            return 1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.UnmapRequest : Request
{
    // methods
    public UnmapRequest (Window inWindow)
    {
        base (inWindow);
    }

    internal override void
    run ()
    {
        // Unmap window
        ((global::Xcb.Window)window.xid).unmap (window.connection);

        // Damage parent window
        if (window.window != null)
        {
            char[] data = new char[32];
            unowned global::Xcb.ExposeEvent? evt = (global::Xcb.ExposeEvent?)data;
            evt.window = ((Window)window.window).xid;
            evt.response_type = global::Xcb.EventType.EXPOSE;
            evt.x = (int16)GLib.Math.floor (window.m_WindowGeometry.origin.x);
            evt.y = (int16)GLib.Math.floor (window.m_WindowGeometry.origin.y);
            evt.width = (uint16)GLib.Math.ceil (window.m_WindowGeometry.size.width);
            evt.height = (uint16)GLib.Math.ceil (window.m_WindowGeometry.size.height);

            ((global::Xcb.Window)((Window)window.window).xid).send_event (window.connection, false, global::Xcb.EventMask.EXPOSURE, data);
        }
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (window == inRequest.window && inRequest is MapRequest)
            return CompressAction.REMOVE_BOTH;
        else if (window == inRequest.window && inRequest is UnmapRequest)
            return CompressAction.REMOVE_CURRENT;

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence unmap window $(window.name) xid: $(window.xid)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (window.xid == other.window.xid && other is ReparentRequest)
            return 1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.ReparentRequest : Request
{
    // methods
    public ReparentRequest (Window inWindow)
    {
        base (inWindow);
    }

    internal override void
    run ()
    {
        if (window.window != null)
        {
            var pos = window.geometry != null ? window.geometry.extents.origin : Graphic.Point (0, 0);

            // Reparent window under parent_window
            ((global::Xcb.Window)window.xid).reparent (window.connection, ((Window)window.window).xid, (int16)GLib.Math.floor (pos.x),
                                                                                                       (int16)GLib.Math.floor (pos.y));
        }
        else
        {
            // Reparent window under root
            unowned global::Xcb.Screen screen = window.connection.roots[window.screen_num];

            ((global::Xcb.Window)window.xid).reparent (window.connection, screen.root,
                                                       (int16)GLib.Math.floor (window.position.x),
                                                       (int16)GLib.Math.floor (window.position.y));
        }
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (window == inRequest.window && inRequest is ReparentRequest)
            return CompressAction.REMOVE_CURRENT;

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence reparent window $(window.name) parent: $(window.window.name)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (window.xid == other.window.xid && (other is MapRequest || other is UnmapRequest))
            return -1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.MoveRequest : Request
{
    // accessors
    public Graphic.Point position { get; set; }

    // methods
    public MoveRequest (Window inWindow, Graphic.Point inPosition)
    {
        base (inWindow);

        position = inPosition;
    }

    internal override void
    run ()
    {
        Graphic.Point window_position = position;
        uint16 mask = global::Xcb.ConfigWindow.X |
                      global::Xcb.ConfigWindow.Y;
        uint32[] values = { (uint32)GLib.Math.floor (window_position.x), (uint32)GLib.Math.floor (window_position.y) };
        ((global::Xcb.Window)window.xid).configure (window.connection, mask, values);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (window == inRequest.window && inRequest is MoveRequest)
        {
            return CompressAction.REMOVE_CURRENT;
        }

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence move window $(window.name) xid: $(window.xid) position: $(position)";
    }
}

internal class Maia.Xcb.ResizeRequest : Request
{
    // accessors
    public Graphic.Size size { get; set; }

    // methods
    public ResizeRequest (Window inWindow, Graphic.Size inSize)
    {
        base (inWindow);

        size = inSize;
    }

    internal override void
    run ()
    {
        Graphic.Size window_size = size;

        uint16 mask = global::Xcb.ConfigWindow.WIDTH  |
                      global::Xcb.ConfigWindow.HEIGHT |
                      global::Xcb.ConfigWindow.BORDER_WIDTH;
        uint32[] values = { (uint32)GLib.Math.ceil (window_size.width), (uint32)GLib.Math.ceil (window_size.height), 0 };
        ((global::Xcb.Window)window.xid).configure (window.connection, mask, values);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (window == inRequest.window && inRequest is ResizeRequest)
        {
            return CompressAction.REMOVE_CURRENT;
        }

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence resize window $(window.name) xid: $(window.xid) size: $(size)";
    }
}

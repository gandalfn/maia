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
    public unowned View view { get; construct; }

    // methods
    public Request (View inView)
    {
        GLib.Object (sequence: GLib.AtomicInt.add (ref s_Sequence, 1), view: inView);
    }

    public abstract void run ();
    public abstract CompressAction compress (Request inRequest);

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.parent == null && other.view.parent != null)
            return -1;

        if (view.parent != null && other.view.parent == null)
            return 1;

        if (view.parent == null && other.view.parent == null)
            return sequence - other.sequence;

        if (view.xid == other.view.parent.xid)
            return -1;

        if (view.parent.xid == other.view.xid)
            return 1;

        return sequence - other.sequence;
    }
}

internal class Maia.Xcb.MapRequest : Request
{
    // methods
    public MapRequest (View inView)
    {
        base (inView);
    }

    internal override void
    run ()
    {
        // Map window
        ((global::Xcb.Window)view.xid).map (view.connection);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (view.xid == inRequest.view.xid && inRequest is MapRequest)
            return CompressAction.REMOVE_CURRENT;
        else if (view.xid == inRequest.view.xid && inRequest is UnmapRequest)
            return CompressAction.REMOVE_BOTH;

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence map xid: $(view.xid)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.xid == other.view.xid && (other is ReparentRequest || other is ResizeRequest || other is MoveRequest))
            return 1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.UnmapRequest : Request
{
    // methods
    public UnmapRequest (View inView)
    {
        base (inView);
    }

    internal override void
    run ()
    {
        // Unmap window
        ((global::Xcb.Window)view.xid).unmap (view.connection);

        // Damage parent window
        if (view.parent != null)
        {
            var view_size = view.size;
            view_size.transform (view.device_transform);

            char[] data = new char[32];
            unowned global::Xcb.ExposeEvent? evt = (global::Xcb.ExposeEvent?)data;
            evt.window = view.parent.xid;
            evt.response_type = global::Xcb.EventType.EXPOSE;
            evt.x = (int16)GLib.Math.floor (view.position.x);
            evt.y = (int16)GLib.Math.floor (view.position.y);
            evt.width = (uint16)GLib.Math.ceil (view_size.width);
            evt.height = (uint16)GLib.Math.ceil (view_size.height);

            ((global::Xcb.Window)view.parent.xid).send_event (view.connection, false, global::Xcb.EventMask.EXPOSURE, data);
        }
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (view.xid == inRequest.view.xid && inRequest is MapRequest)
            return CompressAction.REMOVE_BOTH;
        else if (view.xid == inRequest.view.xid && inRequest is UnmapRequest)
            return CompressAction.REMOVE_CURRENT;

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence unmap xid: $(view.xid)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.xid == other.view.xid && other is ReparentRequest)
            return 1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.ReparentRequest : Request
{
    // methods
    public ReparentRequest (View inView)
    {
        base (inView);
    }

    internal override void
    run ()
    {
        if (view.parent != null)
        {
            // Reparent window under parent_window
            ((global::Xcb.Window)view.xid).reparent (view.connection, view.parent.xid, (int16)GLib.Math.floor (view.position.x),
                                                                                       (int16)GLib.Math.floor (view.position.y));
        }
        else
        {
            // Reparent window under root
            unowned global::Xcb.Screen screen = view.connection.roots[view.screen_num];

            ((global::Xcb.Window)view.xid).reparent (view.connection, screen.root, (int16)GLib.Math.floor (view.position.x),
                                                                                   (int16)GLib.Math.floor (view.position.y));
        }
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (view.xid == inRequest.view.xid && inRequest is ReparentRequest)
            return CompressAction.REMOVE_CURRENT;

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence reparent window $(view.xid) parent: $(view.parent.xid)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.xid == other.view.xid && (other is MapRequest || other is UnmapRequest))
            return -1;
        else if (view.xid == other.view.xid && (other is MoveRequest || other is ResizeRequest))
            return 1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.MoveRequest : Request
{
    // methods
    public MoveRequest (View inView)
    {
        base (inView);
    }

    internal override void
    run ()
    {
        uint16 mask = global::Xcb.ConfigWindow.X |
                      global::Xcb.ConfigWindow.Y;
        print(@"move to $(GLib.Math.floor (view.position.x)), $((uint32)GLib.Math.floor (view.position.y)), position $(view.position)\n");
        uint32[] values = { (uint32)GLib.Math.floor (view.position.x), (uint32)GLib.Math.floor (view.position.y) };
        ((global::Xcb.Window)view.xid).configure (view.connection, mask, values);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (view.xid == inRequest.view.xid && inRequest is MoveRequest)
        {
            return CompressAction.REMOVE_CURRENT;
        }

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence move xid: $(view.xid) position: $(view.position)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.xid == other.view.xid && (other is MapRequest || other is ReparentRequest))
            return -1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.ResizeRequest : Request
{
    // methods
    public ResizeRequest (View inView)
    {
        base (inView);
    }

    internal override void
    run ()
    {
        var view_size = view.size;
        view_size.transform (view.device_transform);
        uint16 mask = global::Xcb.ConfigWindow.WIDTH  |
                      global::Xcb.ConfigWindow.HEIGHT |
                      global::Xcb.ConfigWindow.BORDER_WIDTH;
        uint32[] values = { (uint32)GLib.Math.ceil (view_size.width), (uint32)GLib.Math.ceil (view_size.height), 0 };
        print(@"resize to $(view_size)\n");
        ((global::Xcb.Window)view.xid).configure (view.connection, mask, values);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (view.xid == inRequest.view.xid && inRequest is ResizeRequest)
        {
            return CompressAction.REMOVE_CURRENT;
        }

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence resize xid: $(view.xid) size: $(view.size)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.xid == other.view.xid && (other is MapRequest || other is ReparentRequest))
            return -1;

        return base.compare (inOther);
    }
}

internal class Maia.Xcb.OverrideRedirectRequest : Request
{
    private bool m_Enable;

    // methods
    public OverrideRedirectRequest (View inView, bool inEnable)
    {
        base (inView);

        m_Enable = inEnable;
    }

    internal override void
    run ()
    {
        uint32 mask = global::Xcb.Cw.OVERRIDE_REDIRECT;
        uint32[] values = { m_Enable ? 1 : 0 };

        ((global::Xcb.Window)view.xid).change_attributes (view.connection, mask, values);
    }

    internal override CompressAction
    compress (Request inRequest)
    {
        if (view.xid == inRequest.view.xid && inRequest is OverrideRedirectRequest)
        {
            if ((inRequest as OverrideRedirectRequest).m_Enable == m_Enable)
            {
                return CompressAction.REMOVE_CURRENT;
            }
            else if ((inRequest as OverrideRedirectRequest).m_Enable != m_Enable)
            {
                return CompressAction.REMOVE_BOTH;
            }
        }

        return CompressAction.KEEP;
    }

    internal override string
    to_string ()
    {
        return @"sequence: $sequence override redirect $m_Enable xid: $(view.xid) size: $(view.size)";
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is Request)
    {
        unowned Request other = (Request)inOther;

        if (view.xid == other.view.xid && (other is MapRequest || other is ReparentRequest))
            return -1;

        return base.compare (inOther);
    }
}

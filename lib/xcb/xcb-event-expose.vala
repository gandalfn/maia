/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-event-expose.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

internal class Maia.XcbEventExposeArgs : EventArgs
{
    // properties
    private Region m_Area;

    // accessors
    public Region area {
        get {
            return m_Area;
        }
    }

    // methods
    public XcbEventExposeArgs (Xcb.ExposeEvent inXcbExposeEvent)
    {
        m_Area = new Region.raw_rectangle (inXcbExposeEvent.x, inXcbExposeEvent.y,
                                           inXcbExposeEvent.width, inXcbExposeEvent.height);
    }
}

internal class Maia.XcbEventExposeListener : EventListener
{
    // methods
    public XcbEventExposeListener (XcbEventExpose inEvent, XcbEventExpose.Callback inCallback)
    {
        base (inEvent);
        func = (a) => {
            XcbEventExposeArgs args = (XcbEventExposeArgs)a;
            inCallback (args.area);
        };
    }
}

internal class Maia.XcbEventExpose : XcbEvent
{
    // types
    public delegate void Callback (Region inExposeArea);

    // accessors
    public override uint32 mask {
        get {
            return Xcb.EventMask.EXPOSURE;
        }
    }

    // methods
    public XcbEventExpose (Xcb.Window inWindow)
    {
        base (Xcb.EXPOSE, ((uint)inWindow).to_pointer ());
    }

    public XcbEventExpose.from_xcb_event (Xcb.GenericEvent inEvent)
    {
        Xcb.ExposeEvent evt = (Xcb.ExposeEvent)inEvent;
        XcbEventExposeArgs args = new XcbEventExposeArgs (evt);
        base.with_args (Xcb.EXPOSE, ((uint)evt.window).to_pointer (), args);
    }

    public new void
    listen (Callback inCallback, Dispatcher inDispatcher = Dispatcher.self ())
    {
        XcbEventExposeListener event_listener = new XcbEventExposeListener (this, inCallback);
        inDispatcher.add_listener (event_listener);
    }
}
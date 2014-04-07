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

internal class Maia.Xcb.RequestQueue : Object
{
    // types
    private abstract class Request : Object
    {
        public unowned Window window { get; construct; }

        public Request (Window inWindow)
        {
            GLib.Object (window: inWindow);
        }

        public abstract void run ();
    }

    private class MapRequest : Request
    {
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
    }

    private class UnmapRequest : Request
    {
        public UnmapRequest (Window inWindow)
        {
            base (inWindow);
        }

        internal override void
        run ()
        {
            // Unmap window
            ((global::Xcb.Window)window.xid).unmap (window.connection);
        }
    }

    private class MoveRequest : Request
    {
        public Graphic.Point position { get; set; }

        public MoveRequest (Window inWindow, Graphic.Point inPosition)
        {
            base (inWindow);

            position = inPosition;
        }

        internal override void
        run ()
        {
            uint16 mask = global::Xcb.ConfigWindow.X |
                          global::Xcb.ConfigWindow.Y;
            uint32[] values = { (uint32)position.x, (uint32)position.y };
            ((global::Xcb.Window)window.xid).configure (window.connection, mask, values);
        }
    }

    private class ResizeRequest : Request
    {
        public Graphic.Size size { get; set; }

        public ResizeRequest (Window inWindow, Graphic.Size inSize)
        {
            base (inWindow);

            size = inSize;
        }

        internal override void
        run ()
        {
            uint16 mask = global::Xcb.ConfigWindow.WIDTH  |
                          global::Xcb.ConfigWindow.HEIGHT |
                          global::Xcb.ConfigWindow.BORDER_WIDTH;
            uint32[] values = { (uint32)size.width, (uint32)size.height, 0 };
            ((global::Xcb.Window)window.xid).configure (window.connection, mask, values);
        }
    }

    // accessors
    public bool have_map {
        get {
            bool ret = false;

            foreach (unowned Request request in m_Requests)
            {
                if (request.window.xid == m_Window.xid)
                {
                    if (request is MapRequest)
                        ret = true;
                    else if (request is UnmapRequest)
                        ret = false;
                }
            }

            return ret;
        }
    }

    public bool have_unmap {
        get {
            bool ret = false;

            foreach (unowned Request request in m_Requests)
            {
                if (request.window.xid == m_Window.xid)
                {
                    if (request is MapRequest)
                        ret = false;
                    else if (request is UnmapRequest)
                        ret = true;
                }
            }

            return ret;
        }
    }

    // properties
    private unowned Window      m_Window;
    private Core.Queue<Request> m_Requests;

    // methods
    public RequestQueue (Window inWindow)
    {
        m_Window = inWindow;
        m_Requests = new Core.Queue<Request> ();
    }

    public void
    push_map ()
    {
        if (!have_map)
        {
            var request = new MapRequest (m_Window);
            m_Requests.push (request);
        }
    }

    public void
    push_unmap ()
    {
        if (!have_unmap)
        {
            var request = new UnmapRequest (m_Window);
            m_Requests.push (request);
        }
    }

    public void
    push_move (Graphic.Point inPosition)
    {
        bool have_move = false;

        // Compress move event
        foreach (unowned Request request in m_Requests)
        {
            unowned MoveRequest? move_request = request as MoveRequest;

            if (move_request != null && request.window.xid == m_Window.xid)
            {
                move_request.position = inPosition;
                have_move = true;
                break;
            }
        }

        if (!have_move)
        {
            var request = new MoveRequest (m_Window, inPosition);
            m_Requests.push (request);
        }
    }

    public void
    push_resize (Graphic.Size inSize)
    {
        bool have_resize = false;

        // Compress resize event
        foreach (unowned Request request in m_Requests)
        {
            unowned ResizeRequest? resize_request = request as ResizeRequest;

            if (resize_request != null && request.window.xid == m_Window.xid)
            {
                resize_request.size = inSize;
                have_resize = true;
                break;
            }
        }

        if (!have_resize)
        {
            var request = new ResizeRequest (m_Window, inSize);
            m_Requests.push (request);
        }
    }

    public void
    flush ()
    {
        Request? request = null;

        while ((request = m_Requests.pop ()) != null)
        {
            request.run ();
        }
    }
}

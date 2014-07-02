/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * application.vala
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

using Xcb.Render;

internal class Maia.Xcb.Application : Core.Object
{
    // properties
    private global::Xcb.Connection            m_Connection;
    private int                               m_DefaultScreen;
    private ConnectionWatch                   m_Watch;
    private Atoms                             m_Atoms;
    private global::Xcb.Util.CursorContext    m_Cursors;
    private global::Xcb.Render.Pictvisual?[,] m_VisualCache;
    private Core.Queue<Request>               m_RequestQueue;
    private Core.Set<unowned Window>          m_Windows;

    // accessors
    public global::Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public int default_screen {
        get {
            return m_DefaultScreen;
        }
    }

    public Atoms atoms {
        get {
            return m_Atoms;
        }
    }

    public global::Xcb.Util.CursorContext cursors {
        get {
            return m_Cursors;
        }
    }

    // methods
    public Application (string? inDisplay = null)
    {
        GLib.Object (id: inDisplay != null ? GLib.Quark.from_string (inDisplay) : 0);

        // Connect onto xorg
        m_Connection = new global::Xcb.Connection (inDisplay, out m_DefaultScreen);

        m_Connection.prefetch_maximum_request_length ();

        // Create request queue
        m_RequestQueue = new Core.Queue<Request>.sorted ();

        // Create atoms
        m_Atoms = new Atoms (m_Connection);

        // Watch xorg connection for events
        m_Watch = new ConnectionWatch (m_Connection);

        // Create cursor context
        m_Cursors = global::Xcb.Util.CursorContext.create (m_Connection, m_Connection.roots[m_DefaultScreen]);

        // Create visual cache
        m_VisualCache = new Pictvisual?[m_Connection.roots.length, 5];
        var reply = ((global::Xcb.Render.Connection)m_Connection).query_pict_formats ().reply (m_Connection);
        if (reply != null)
        {
            for (int cpt = 0; cpt < m_Connection.roots.length; ++cpt)
            {
                unowned global::Xcb.Render.Pictforminfo? info;

                info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.ARGB_32);
                if (info != null)
                    m_VisualCache[cpt, 32 / 8] = find_visual_from_info (reply, cpt, info);
                info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.RGB_24);
                if (info != null)
                    m_VisualCache[cpt, 24 / 8] = find_visual_from_info (reply, cpt, info);
                info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.A_8);
                if (info != null)
                    m_VisualCache[cpt, 8 / 8] = find_visual_from_info (reply, cpt, info);
                info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.A_1);
                if (info != null)
                    m_VisualCache[cpt, 1 / 8] = find_visual_from_info (reply, cpt, info);
            }
        }
        else
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on get visual cache");
        }

        // Create window list
        m_Windows = new Core.Set<Window> ();
        m_Windows.compare_func = Window.compare_xcb;
    }

    private unowned global::Xcb.Render.Pictvisual?
    find_visual_from_info (global::Xcb.Render.QueryPictFormatsReply inReply, int inScreen, global::Xcb.Render.Pictforminfo inInfo)
    {
        unowned global::Xcb.Screen screen = connection.roots[inScreen];

        foreach (unowned global::Xcb.Depth? depth in screen)
        {
            foreach (unowned global::Xcb.Visualtype? visual in depth)
            {
                switch (visual._class)
                {
                    case global::Xcb.VisualClass.TRUE_COLOR:
                        if (inInfo.type != global::Xcb.Render.PictType.DIRECT)
                            continue;
                        break;

                    case global::Xcb.VisualClass.DIRECT_COLOR:
                        continue;

                    case global::Xcb.VisualClass.STATIC_GRAY:
                    case global::Xcb.VisualClass.GRAY_SCALE:
                    case global::Xcb.VisualClass.STATIC_COLOR:
                    case global::Xcb.VisualClass.PSEUDO_COLOR:
                        if (inInfo.type != global::Xcb.Render.PictType.INDEXED)
                            continue;
                        break;
                }

                unowned global::Xcb.Render.Pictvisual? info = global::Xcb.Render.Util.find_visual_format (inReply, visual.visual_id);

                if (info != null && inInfo.id == info.format)
                    return info;
            }
        }

        return null;
    }

    public global::Xcb.Visualid
    find_visual_from_depth (int inScreen, uint inDepth)
    {
        return m_VisualCache[inScreen, inDepth / 8] != null ? m_VisualCache[inScreen, inDepth / 8].visual : global::Xcb.NONE;
    }

    public global::Xcb.Render.Pictformat
    find_format_from_depth (int inScreen, uint inDepth)
    {
        return m_VisualCache[inScreen, inDepth / 8] != null ? m_VisualCache[inScreen, inDepth / 8].format : global::Xcb.NONE;
    }

    public bool
    have_map (Window inWindow)
    {
        bool found = false;

        foreach (unowned Request request in m_RequestQueue)
        {
            if (request.window == inWindow && request is MapRequest)
            {
                found = true;
            }
            else if (found && request.window == inWindow && request is UnmapRequest)
            {
                found = false;
            }
        }

        return found;
    }

    public bool
    have_unmap (Window inWindow)
    {
        bool found = false;

        foreach (unowned Request request in m_RequestQueue)
        {
            if (request.window == inWindow && request is UnmapRequest)
            {
                found = true;
            }
            else if (found && request.window == inWindow && request is MapRequest)
            {
                found = false;
            }
        }

        return found;
    }

    public void
    push_request (Request inRequest)
    {
        CompressAction compressed = CompressAction.KEEP;

        // Check if resquest must be compress
        foreach (unowned Request request in m_RequestQueue)
        {
            compressed = request.compress (inRequest);

            if (compressed == CompressAction.REMOVE_CURRENT ||
                compressed == CompressAction.REMOVE_BOTH)
            {
                m_RequestQueue.remove (request);
                break;
            }
            else if (compressed == CompressAction.REMOVE)
            {
                break;
            }
        }

        // Add request if not already exist in queue
        if (compressed != CompressAction.REMOVE && compressed != CompressAction.REMOVE_BOTH)
        {
            m_RequestQueue.push (inRequest);
        }

        // Reparent request resort all requests in the queue
        if (inRequest is ReparentRequest)
        {
            Core.List<unowned Request> requests = new Core.List<unowned Request> ();
            foreach (unowned Request request in m_RequestQueue)
            {
                requests.insert (request);
            }

            foreach (unowned Request request in requests)
            {
                m_RequestQueue.reorder (request);
            }
        }
    }

    public void
    flush ()
    {
        if (m_RequestQueue.length > 0)
        {
            Request? request = null;
            while ((request = m_RequestQueue.pop ()) != null)
            {
                request.run ();
            }
            sync ();
        }
    }

    public void
    sync ()
    {
        m_Connection.get_input_focus ().reply (m_Connection);
    }

    public void
    register_window (Window inWindow)
    {
        m_Windows.insert (inWindow);
    }

    public void
    unregister_window (Window inWindow)
    {
        m_Windows.remove (inWindow);
    }

    public unowned Window?
    lookup_window (uint32 inXid)
    {
        return m_Windows.search<uint32> (inXid, Window.compare_with_xid);
    }
}

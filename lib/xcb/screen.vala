/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * screen.vala
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

internal class Maia.Xcb.Screen : Core.Object
{
    // properties
    private unowned global::Xcb.Connection? m_Connection;
    private Graphic.Rectangle               m_Geometry = Graphic.Rectangle (0, 0, 0, 0);
    private global::Xcb.Render.Pictvisual?  m_VisualCache[5];
    private Monitor[]                       m_Monitors = {};

    // accessors
    public unowned global::Xcb.Screen? xscreen {
        get {
            return connection.roots[(int)id];
        }
    }

    public global::Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public Graphic.Rectangle geometry {
        get {
            return m_Geometry;
        }
    }

    // methods
    public Screen (global::Xcb.Connection inConnection, int inNum)
    {
        GLib.Object (id: inNum);

        // set connection
        m_Connection = inConnection;

        // Get screen geometry
        unowned global::Xcb.Screen? screen = connection.roots[inNum];
        if (screen != null)
        {
            m_Geometry = Graphic.Rectangle (0, 0, (double)screen.width_in_pixels, (double)screen.height_in_pixels);
        }

        var reply = ((global::Xcb.Render.Connection)connection).query_pict_formats ().reply (connection);
        if (reply != null)
        {
            unowned global::Xcb.Render.Pictforminfo? info;

            info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.ARGB_32);
            if (info != null)
                m_VisualCache[32 / 8] = find_visual_from_info (reply, info);
            info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.RGB_24);
            if (info != null)
                m_VisualCache[24 / 8] = find_visual_from_info (reply, info);
            info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.A_8);
            if (info != null)
                m_VisualCache[8 / 8] = find_visual_from_info (reply, info);
            info = global::Xcb.Render.Util.find_standard_format (reply, global::Xcb.Render.Util.PictStandard.A_1);
            if (info != null)
                m_VisualCache[1 / 8] = find_visual_from_info (reply, info);
        }

        if (screen != null)
        {
            var reply_res = ((global::Xcb.RandR.Window)screen.root).get_screen_resources (connection).reply (connection);
            if (reply_res != null)
            {
                for (int cpt = 0; cpt < reply_res.outputs_length; ++cpt)
                {
                    var reply_output_info = reply_res.outputs[cpt].get_info (connection, reply_res.config_timestamp).reply (connection);
                    if (reply_output_info != null)
                    {
                        if (reply_output_info.connection != global::Xcb.RandR.ConnectionType.DISCONNECTED && reply_output_info.crtc != global::Xcb.NONE)
                        {
                            var reply_get_crtc_info = reply_output_info.crtc.get_info (connection, reply_res.config_timestamp).reply (connection);
                            if (reply_get_crtc_info != null)
                            {
                                m_Monitors += new Monitor (reply_get_crtc_info);
                            }
                        }
                    }
                }
            }
        }
    }

    private unowned global::Xcb.Render.Pictvisual?
    find_visual_from_info (global::Xcb.Render.QueryPictFormatsReply inReply, global::Xcb.Render.Pictforminfo inInfo)
    {
        unowned global::Xcb.Screen? screen = connection.roots[(int)id];

        if (screen != null)
        {
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
        }

        return null;
    }

    public global::Xcb.Visualid
    find_visual_from_depth (uint inDepth)
    {
        return m_VisualCache[inDepth / 8] != null ? m_VisualCache[inDepth / 8].visual : global::Xcb.NONE;
    }

    public global::Xcb.Render.Pictformat
    find_format_from_depth (uint inDepth)
    {
        return m_VisualCache[inDepth / 8] != null ? m_VisualCache[inDepth / 8].format : global::Xcb.NONE;
    }

    public unowned Monitor?
    get_monitor_at (Graphic.Point inPosition)
    {
        foreach (unowned Monitor monitor in m_Monitors)
        {
            if (inPosition in monitor.geometry)
            {
                return monitor;
            }
        }

        return null;
    }
}

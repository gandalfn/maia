/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-workspace.vala
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

internal class Maia.XcbWorkspace : WorkspaceProxy
{
    // properties
    private uint            m_Num            = 0;
    private Xcb.Screen      m_XcbScreen      = null;
    private Xcb.VisualType? m_XcbVisual      = null;
    private Region          m_Geometry       = null;
    private bool            m_DoubleBuffered = true;

    private Window          m_Root           = null;

    // accessors
    public Xcb.Screen xcb_screen {
        get {
            return m_XcbScreen;
        }
    }

    public Xcb.VisualType? xcb_visual {
        get {
            if (m_XcbScreen != null && m_XcbVisual == null)
            {
                for (Xcb.DepthIterator depth_iter = m_XcbScreen.allowed_depths_iterator ();
                     depth_iter.rem > 0 && m_XcbVisual == null;
                     Xcb.DepthIterator.next (ref depth_iter))
                {
                    for (Xcb.VisualTypeIterator visual_iter = depth_iter.data.visuals_iterator ();
                         visual_iter.rem > 0 && m_XcbVisual == null;
                         Xcb.VisualTypeIterator.next(ref visual_iter))
                    {
                        if (visual_iter.data.visual_id == m_XcbScreen.root_visual)
                        {
                            m_XcbVisual = visual_iter.data;
                        }
                    }
                }
            }

            return m_XcbVisual;
        }
    }

    [CCode (notify = false)]
    public override Region geometry {
        get {
            if (m_Geometry == null)
            {
                m_Geometry = new Region.raw_rectangle (0, 0,
                                                       m_XcbScreen.width_in_pixels,
                                                       m_XcbScreen.height_in_pixels);
            }

            return m_Geometry;
        }
        internal set {
        }
    }

    [CCode (notify = false)]
    public override bool double_buffered {
        get {
            return m_DoubleBuffered;
        }
        set {
            m_DoubleBuffered = value;
        }
    }

    public override unowned GraphicDevice? back_buffer {
        get {
            return null;
        }
    }

    public override unowned GraphicDevice? front_buffer {
        get {
            return null;
        }
    }

    public override uint num {
        get {
            return m_Num;
        }
    }

    public override Window root {
        get {
            if (m_Root == null)
            {
                m_Root = new Window.foreign (m_XcbScreen.root, (Workspace)delegator);
                ((XcbWindow)m_Root.proxy).event_mask = 0;
            }

            return m_Root;
        }
    }

    // events
    private XcbCreateWindowEvent m_CreateWindowEvent = null;
    private XcbDestroyWindowEvent m_DestroyWindowEvent = null;
    private XcbReparentWindowEvent m_ReparentWindowEvent = null;

    public override CreateWindowEvent create_window_event {
        get {
            if (m_CreateWindowEvent == null)
            {
                m_CreateWindowEvent = new XcbCreateWindowEvent ((XcbWindow)root.proxy);
            }
            return m_CreateWindowEvent;
        }
    }

    public override DestroyWindowEvent destroy_window_event {
        get {
            if (m_DestroyWindowEvent == null)
            {
                m_DestroyWindowEvent = new XcbDestroyWindowEvent ((XcbWindow)root.proxy);
            }
            return m_DestroyWindowEvent;
        }
    }

    public override ReparentWindowEvent reparent_window_event {
        get {
            if (m_ReparentWindowEvent == null)
            {
                m_ReparentWindowEvent = new XcbReparentWindowEvent ((XcbWindow)root.proxy);
            }
            return m_ReparentWindowEvent;
        }
    }

    public override DamageEvent damage_event {
        get {
            return root.damage_event;
        }
    }

    // methods
    public void
    init (Xcb.Screen inScreen, uint inNum)
    {
        m_Num = inNum;
        m_XcbScreen = inScreen;
    }
}
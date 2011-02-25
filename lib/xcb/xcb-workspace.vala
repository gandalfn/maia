/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    private uint            m_Num       = 0;
    private Xcb.Screen      m_XcbScreen = null;
    private Xcb.VisualType? m_XcbVisual = null;
    private Region          m_Geometry  = null;

    private Window          m_Root      = null;

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
                m_Root = GLib.Object.new (typeof (Window), parent: delegator) as Window;
                m_Root.delegate_cast<XcbWindow> ().foreign (m_XcbScreen.root);
            }

            return m_Root;
        }
    }

    // Events
    public override DamageEvent damage_event {
        get {
            return root.damage_event;
        }
    }

    // Methods
    public void
    init (Xcb.Screen inScreen, uint inNum)
    {
        m_Num = inNum;
        m_XcbScreen = inScreen;
    }

    public override Window
    create_window (Region inGeometry)
    {
        Window window = GLib.Object.new (typeof (Window), parent: delegator) as Window;
        window.delegate_cast<XcbWindow> ().create (inGeometry);

        return window;
    }
}
/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-xcb-workspace.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.XcbWorkspace : WorkspaceProxy
{
    // properties
    private uint            m_Num       = 0;
    private Xcb.Screen      m_XcbScreen = null;
    private Xcb.VisualType? m_XcbVisual = null;

    // accessors
    internal Xcb.Screen xcb_screen {
        get {
            return m_XcbScreen;
        }
        set {
            m_XcbScreen = value;
        }
    }

    internal Xcb.VisualType? xcb_visual {
        get {
            if (m_XcbScreen != null && m_XcbVisual == null)
            {
                for (Xcb.DepthIterator depth_iter = m_XcbScreen.allowed_depths_iterator (); 
                     depth_iter.rem != 0 && m_XcbVisual == null; 
                     Xcb.DepthIterator.next (out depth_iter))
                {
                    for (Xcb.VisualTypeIterator visual_iter = depth_iter.data.visuals_iterator (); 
                         visual_iter.rem != 0 && m_XcbVisual == null; 
                         Xcb.VisualTypeIterator.next(out visual_iter))
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

    public override uint num {
        get {
            return m_Num;
        }
        set {
            m_Num = value;
        }
    }

    // methods
}
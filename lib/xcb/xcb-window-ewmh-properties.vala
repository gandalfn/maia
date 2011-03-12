/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-ewmh-properties.vala
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

internal class Maia.XcbWindowEWMHProperties : XcbRequest
{
    // properties
    private XcbWindowProperty<uint32> m_HintType;

    // accessors
    public WindowHintType hint_type {
        get {
            if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DESKTOP])
                return WindowHintType.DESKTOP;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NORMAL])
                return WindowHintType.NORMAL;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DIALOG])
                return WindowHintType.DIALOG;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_SPLASH])
                return WindowHintType.SPLASH;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_UTILITY])
                return WindowHintType.UTILITY;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DND])
                return WindowHintType.DND;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLTIP])
                return WindowHintType.TOOLTIP;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NOTIFICATION])
                return WindowHintType.NOTIFICATION;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLBAR])
                return WindowHintType.TOOLBAR;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_COMBO])
                return WindowHintType.COMBO;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DROPDOWN_MENU])
                return WindowHintType.DROPDOWN_MENU;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_POPUP_MENU])
                return WindowHintType.POPUP_MENU;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_MENU])
                return WindowHintType.MENU;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DOCK])
                return WindowHintType.DOCK;
            else
                return WindowHintType.UNKNOWN;
        }
        set {
            switch (value)
            {
                case WindowHintType.DESKTOP:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DESKTOP];
                    break;
                case WindowHintType.NORMAL:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NORMAL];
                    break;
                case WindowHintType.DIALOG:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DIALOG];
                    break;
                case WindowHintType.SPLASH:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_SPLASH];
                    break;
                case WindowHintType.UTILITY:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_UTILITY];
                    break;
                case WindowHintType.DND:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DND];
                    break;
                case WindowHintType.TOOLTIP:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLTIP];
                    break;
                case WindowHintType.NOTIFICATION:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NOTIFICATION];
                    break;
                case WindowHintType.TOOLBAR:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLBAR];
                    break;
                case WindowHintType.COMBO:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_COMBO];
                    break;
                case WindowHintType.DROPDOWN_MENU:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DROPDOWN_MENU];
                    break;
                case WindowHintType.POPUP_MENU:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_POPUP_MENU];
                    break;
                case WindowHintType.MENU:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_MENU];
                    break;
                case WindowHintType.DOCK:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DOCK];
                    break;
            }
        }
    }

    // methods
    public XcbWindowEWMHProperties (XcbWindow inWindow)
    {
        base (inWindow);

        m_HintType = new XcbWindowProperty<uint32> (inWindow,
                                                    XcbAtomType._NET_WM_WINDOW_TYPE,
                                                    Xcb.AtomType.ATOM,
                                                    XcbWindowProperty.Format.U32);
    }

    public override void
    query ()
    {
        // query hint type property
        m_HintType.query ();
    }

    public override void
    commit ()
    {
        // commit hint type property
        m_HintType.commit ();
    }
}
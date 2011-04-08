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
    private XcbWindowProperty<string> m_WMName;

    // accessors
    public Window.HintType hint_type {
        get {
            if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DESKTOP])
                return Window.HintType.DESKTOP;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NORMAL])
                return Window.HintType.NORMAL;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DIALOG])
                return Window.HintType.DIALOG;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_SPLASH])
                return Window.HintType.SPLASH;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_UTILITY])
                return Window.HintType.UTILITY;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DND])
                return Window.HintType.DND;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLTIP])
                return Window.HintType.TOOLTIP;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NOTIFICATION])
                return Window.HintType.NOTIFICATION;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLBAR])
                return Window.HintType.TOOLBAR;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_COMBO])
                return Window.HintType.COMBO;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DROPDOWN_MENU])
                return Window.HintType.DROPDOWN_MENU;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_POPUP_MENU])
                return Window.HintType.POPUP_MENU;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_MENU])
                return Window.HintType.MENU;
            else if (m_HintType[0] == window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DOCK])
                return Window.HintType.DOCK;
            else
                return Window.HintType.UNKNOWN;
        }
        set {
            switch (value)
            {
                case Window.HintType.DESKTOP:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DESKTOP];
                    break;
                case Window.HintType.NORMAL:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NORMAL];
                    break;
                case Window.HintType.DIALOG:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DIALOG];
                    break;
                case Window.HintType.SPLASH:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_SPLASH];
                    break;
                case Window.HintType.UTILITY:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_UTILITY];
                    break;
                case Window.HintType.DND:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DND];
                    break;
                case Window.HintType.TOOLTIP:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLTIP];
                    break;
                case Window.HintType.NOTIFICATION:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_NOTIFICATION];
                    break;
                case Window.HintType.TOOLBAR:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_TOOLBAR];
                    break;
                case Window.HintType.COMBO:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_COMBO];
                    break;
                case Window.HintType.DROPDOWN_MENU:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DROPDOWN_MENU];
                    break;
                case Window.HintType.POPUP_MENU:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_POPUP_MENU];
                    break;
                case Window.HintType.MENU:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_MENU];
                    break;
                case Window.HintType.DOCK:
                    m_HintType[0] = window.xcb_desktop.atoms[XcbAtomType._NET_WM_WINDOW_TYPE_DOCK];
                    break;
            }
        }
    }

    public string name {
        get {
            audit ("XcbWindowEWMHProperties.name.get", "%s", m_WMName[0]);
            return m_WMName[0];
        }
        construct set {
            m_WMName[0] = value;
        }
    }

    [CCode (notify = false)]
    public override XcbWindow window {
        get {
            return base.window;
        }
        construct set {
            base.window = value;

            m_HintType = new XcbWindowProperty<uint32> (value,
                                                        XcbAtomType._NET_WM_WINDOW_TYPE,
                                                        Xcb.AtomType.ATOM,
                                                        XcbWindowProperty.Format.U32,
                                                        () => {
                                                            notify_property ("hint-type");
                                                        });

            m_WMName = new XcbWindowProperty<string> (value,
                                                      XcbAtomType._NET_WM_NAME,
                                                      Xcb.AtomType.STRING,
                                                      XcbWindowProperty.Format.U8,
                                                      () => {
                                                          audit (GLib.Log.METHOD, "name changed");
                                                          notify_property ("name");
                                                      });
        }
    }

    // methods
    construct
    {
        GLib.BindingFlags flags = GLib.BindingFlags.BIDIRECTIONAL;

        if (!(window.delegator as Window).is_foreign)
            flags |= GLib.BindingFlags.SYNC_CREATE;

        window.delegator.bind_property ("hint-type", this, "hint-type", flags);
        //window.delegator.bind_property ("name", this, "name", flags);
    }

    public XcbWindowEWMHProperties (XcbWindow inWindow)
    {
        base (inWindow);
    }

    ~XcbWindowEWMHProperties ()
    {
        m_HintType.parent = null;
        m_WMName.parent = null;
    }

    public override void
    query ()
    {
        // query hint type property
        m_HintType.query ();

        // query name property
        m_WMName.query ();
    }

    public override void
    commit ()
    {
        // commit hint type property
        m_HintType.commit ();

        // commit name property
        m_WMName.commit ();
    }
}
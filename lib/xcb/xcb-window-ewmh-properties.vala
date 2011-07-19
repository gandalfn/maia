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

    // observers
    private unowned Notification1.Observer<Object, string>? m_WindowPropertyObserver;

    // accessors
    [CCode (notify = false)]
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
            on_property_changed ("hint-type");
        }
    }

    [CCode (notify = false)]
    public string name {
        get {
            audit ("XcbWindowEWMHProperties.name.get", "%s", m_WMName[0]);
            return m_WMName[0];
        }
        construct set {
            m_WMName[0] = value;
            on_property_changed ("name");
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
                                                            on_property_changed ("hint-type");
                                                        });

            m_WMName = new XcbWindowProperty<string> (value,
                                                      XcbAtomType._NET_WM_NAME,
                                                      Xcb.AtomType.STRING,
                                                      XcbWindowProperty.Format.U8,
                                                      () => {
                                                          audit (GLib.Log.METHOD, "name changed");
                                                          on_property_changed ("name");
                                                      });
        }
    }

    // methods
    construct
    {
        m_WindowPropertyObserver = window.delegator.property_changed.watch (on_window_property_changed);

        if (!((Window)window.delegator).is_foreign)
        {
            ((Window)window.delegator).hint_type = hint_type;
            ((Window)window.delegator).name = name;
        }
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

    private void
    on_window_property_changed (Object inObject, string inName)
    {
        switch (inName)
        {
            case "name":
                m_WMName[0] = ((Window)inObject).name;
                break;
        }
    }

    internal override void
    on_property_changed (string inName)
    {
        switch (inName)
        {
            case "name":
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = true;
                ((Window)window.delegator).name = name;
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = false;
                break;

            case "hint-type":
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = true;
                ((Window)window.delegator).hint_type = hint_type;
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = false;
                break;
        }

        base.on_property_changed (inName);
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
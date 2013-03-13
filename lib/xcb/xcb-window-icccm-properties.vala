/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-icccm-properties.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
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

internal class Maia.XcbWindowICCCMProperties : XcbRequest
{
    // properties
    private XcbWindowProperty<uint32> m_WMProtocols;
    private XcbWindowProperty<string> m_WMName;
    private XcbWindowProperty<uint32> m_WMState;
    private Xcb.Atom                  m_WMDeleteWindowAtom;
    private Xcb.Atom                  m_WMTakeFocusAtom;

    // accessors
    [CCode (notify = false)]
    public bool delete_event {
        get {
            return m_WMDeleteWindowAtom in m_WMProtocols;
        }
        set {
            if (value)
                m_WMProtocols.insert (m_WMDeleteWindowAtom);
            else
                m_WMProtocols.remove (m_WMDeleteWindowAtom);
        }
    }

    [CCode (notify = false)]
    public bool take_focus {
        get {
            return m_WMTakeFocusAtom in m_WMProtocols;
        }
        set {
            if (value)
                m_WMProtocols.insert (m_WMTakeFocusAtom);
            else
                m_WMProtocols.remove (m_WMTakeFocusAtom);
        }
    }

    public string name {
        get {
            return m_WMName[0];
        }
        construct set {
            m_WMName[0] = value;
        }
    }

    public Window.State wm_state {
        get {
            if (!m_WMState.is_set ())
                return Window.State.UNSET;
            else if (m_WMState[0] == Xcb.WMStateType.WITHDRAWN)
                return Window.State.HIDDEN;
            else if (m_WMState[0] == Xcb.WMStateType.NORMAL)
                return Window.State.VISIBLE;
            else if (m_WMState[0] == Xcb.WMStateType.ICONIC)
                return Window.State.ICONIC;

            return Window.State.UNSET;
        }
    }

    [CCode (notify = false)]
    public override XcbWindow window {
        get {
            return base.window;
        }
        construct set {
            base.window = value;
            XcbDesktop desktop = window.xcb_desktop;

            m_WMProtocols = new XcbWindowProperty<uint32> (value,
                                                           XcbAtomType.WM_PROTOCOLS,
                                                           Xcb.AtomType.ATOM,
                                                           XcbWindowProperty.Format.U32);

            m_WMName = new XcbWindowProperty<string> (value,
                                                      XcbAtomType.WM_NAME,
                                                      Xcb.AtomType.STRING,
                                                      XcbWindowProperty.Format.U8,
                                                      () => {
                                                          notify_property ("name");
                                                      });

            m_WMState = new XcbWindowProperty<uint32> (value,
                                                       XcbAtomType.WM_STATE,
                                                       desktop.atoms [XcbAtomType.WM_STATE],
                                                       XcbWindowProperty.Format.U32,
                                                       () => {
                                                           notify_property ("state");
                                                       });
            m_WMState.query ();

            m_WMDeleteWindowAtom = desktop.atoms [XcbAtomType.WM_DELETE_WINDOW];
            m_WMTakeFocusAtom = desktop.atoms [XcbAtomType.WM_TAKE_FOCUS];
        }
    }

    // methods
    construct
    {
        notify["name"].connect (() => {
            ((Window)window.delegator).name = name;
        });
        notify["state"].connect (() => {
            ((Window)window.delegator).state = wm_state;
        });

        window.delegator.notify["name"].connect (() => {
            m_WMName[0] = ((Window)window.delegator).name;
            m_WMName.commit ();
        });
        if (!((Window)window.delegator).is_foreign)
        {
            m_WMName[0] = ((Window)window.delegator).name;
            m_WMName.commit ();
        }
    }

    public XcbWindowICCCMProperties (XcbWindow inWindow)
    {
        base (inWindow);
    }

    ~XcbWindowICCCMProperties ()
    {
        m_WMProtocols = null;
        m_WMName = null;
        m_WMState = null;
    }

    public override void
    query ()
    {
        // query wm protocols properties
        m_WMProtocols.query ();

        // query wm name property
        m_WMName.query ();
    }

    public override void
    commit ()
    {
        // commit wm protocols properties
        m_WMProtocols.commit ();

        // commit wm name property
        m_WMName.commit ();
    }
}

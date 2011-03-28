/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-icccm-properties.vala
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

internal class Maia.XcbWindowICCCMProperties : XcbRequest
{
    // properties
    private XcbWindowProperty<uint32> m_WMProtocols;
    private XcbWindowProperty<string> m_WMName;
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

    [CCode (notify = false)]
    public string name {
        get {
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

            m_WMProtocols = new XcbWindowProperty<uint32> (value,
                                                       XcbAtomType.WM_PROTOCOLS,
                                                       Xcb.AtomType.ATOM,
                                                       XcbWindowProperty.Format.U32);

            m_WMName = new XcbWindowProperty<string> (value,
                                                      XcbAtomType.WM_NAME,
                                                      Xcb.AtomType.STRING,
                                                      XcbWindowProperty.Format.U8);

            XcbDesktop desktop = window.xcb_desktop;
            m_WMDeleteWindowAtom = desktop.atoms [XcbAtomType.WM_DELETE_WINDOW];
            m_WMTakeFocusAtom = desktop.atoms [XcbAtomType.WM_TAKE_FOCUS];
        }
    }

    // methods
    public XcbWindowICCCMProperties (XcbWindow inWindow)
    {
        base (inWindow);
    }

    public override string
    to_string ()
    {
        string ret = "    name = %s\n".printf (name);
        ret += "    delete event = %s\n".printf (delete_event.to_string ());
        ret += "    take focus = %s\n".printf (take_focus.to_string ());

        return ret;
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

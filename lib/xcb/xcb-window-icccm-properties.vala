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

    // observers
    private unowned Notification1.Observer<Object, string>? m_WindowPropertyObserver;

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
            audit ("XcbWindowICCCMProperties.name.get", "%s", m_WMName[0]);
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

            m_WMProtocols = new XcbWindowProperty<uint32> (value,
                                                           XcbAtomType.WM_PROTOCOLS,
                                                           Xcb.AtomType.ATOM,
                                                           XcbWindowProperty.Format.U32);

            m_WMName = new XcbWindowProperty<string> (value,
                                                      XcbAtomType.WM_NAME,
                                                      Xcb.AtomType.STRING,
                                                      XcbWindowProperty.Format.U8,
                                                      () => {
                                                          audit (GLib.Log.METHOD, "name changed");
                                                          on_property_changed ("name");
                                                      });

            XcbDesktop desktop = window.xcb_desktop;
            m_WMDeleteWindowAtom = desktop.atoms [XcbAtomType.WM_DELETE_WINDOW];
            m_WMTakeFocusAtom = desktop.atoms [XcbAtomType.WM_TAKE_FOCUS];
        }
    }

    // methods
    construct
    {
        m_WindowPropertyObserver = window.delegator.property_changed.watch (on_window_property_changed);
        if (!((Window)window.delegator).is_foreign)
        {
            m_WMName[0] = ((Window)window.delegator).name;
        }
    }

    public XcbWindowICCCMProperties (XcbWindow inWindow)
    {
        base (inWindow);
    }

    ~XcbWindowICCCMProperties ()
    {
        m_WMProtocols.parent = null;
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
                audit (GLib.Log.METHOD, "name changed %s", name);
                ((Window)window.delegator).name = name;
                if (m_WindowPropertyObserver != null) m_WindowPropertyObserver.block = false;
                break;
        }
        base.on_property_changed (inName);
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

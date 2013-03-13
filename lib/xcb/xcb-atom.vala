/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-atom.vala
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

// types
[CCode (cprefix="")]
internal enum Maia.XcbAtomType
{
    WM_PROTOCOLS,
    WM_DELETE_WINDOW,
    WM_TAKE_FOCUS,
    WM_NAME,
    WM_STATE,

    _NET_WM_NAME,
    _NET_WM_VISIBLE_NAME,

    _NET_WM_ICON_NAME,
    _NET_WM_VISIBLE_ICON_NAME,

    _NET_WM_DESKTOP,

    _NET_WM_WINDOW_TYPE,
    _NET_WM_WINDOW_TYPE_DESKTOP,
    _NET_WM_WINDOW_TYPE_DOCK,
    _NET_WM_WINDOW_TYPE_TOOLBAR,
    _NET_WM_WINDOW_TYPE_MENU,
    _NET_WM_WINDOW_TYPE_UTILITY,
    _NET_WM_WINDOW_TYPE_SPLASH,
    _NET_WM_WINDOW_TYPE_DIALOG,
    _NET_WM_WINDOW_TYPE_DROPDOWN_MENU,
    _NET_WM_WINDOW_TYPE_POPUP_MENU,
    _NET_WM_WINDOW_TYPE_TOOLTIP,
    _NET_WM_WINDOW_TYPE_NOTIFICATION,
    _NET_WM_WINDOW_TYPE_COMBO,
    _NET_WM_WINDOW_TYPE_DND,
    _NET_WM_WINDOW_TYPE_NORMAL,

    _NET_WM_STATE,
    _NET_WM_STATE_MODAL,
    _NET_WM_STATE_STICKY,
    _NET_WM_STATE_MAXIMIZED_VERT,
    _NET_WM_STATE_MAXIMIZED_HORZ,
    _NET_WM_STATE_SHADED,
    _NET_WM_STATE_SKIP_TASKBAR,
    _NET_WM_STATE_SKIP_PAGER,
    _NET_WM_STATE_HIDDEN,
    _NET_WM_STATE_FULLSCREEN,
    _NET_WM_STATE_ABOVE,
    _NET_WM_STATE_BELOW,
    _NET_WM_STATE_DEMANDS_ATTENTION,
    _NET_WM_STATE_FOCUSED,

    N;
}

internal class Maia.XcbAtoms
{
    // properties
    private unowned XcbApplication m_Application;
    private Xcb.Atom[]             m_Atoms;

    // methods
    public XcbAtoms (XcbApplication inApplication)
    {
        m_Application = inApplication;

        m_Atoms = new Xcb.Atom[XcbAtomType.N];
        Xcb.InternAtomCookie[] cookies = new Xcb.InternAtomCookie[XcbAtomType.N];

        for (int cpt = 0; cpt < (int)XcbAtomType.N; ++cpt)
        {
            string name = ((XcbAtomType)cpt).to_string ();
            cookies[cpt] = m_Application.connection.intern_atom (false,
                                                                 name.to_utf8 ());
        }

        for (int cpt = 0; cpt < (int)XcbAtomType.N; ++cpt)
        {
            Xcb.InternAtomReply reply = cookies [cpt].reply (m_Application.connection);
            if (reply == null)
            {
                m_Atoms[cpt] = Xcb.AtomType.NONE;
            }
            else
            {
                m_Atoms[cpt] = reply.atom;
            }
        }
    }

    public new Xcb.Atom
    @get (XcbAtomType inType)
    {
        return m_Atoms[inType];
    }
}

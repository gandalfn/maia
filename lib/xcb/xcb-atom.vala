/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-atom.vala
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

// types
[CCode (cprefix="")]
internal enum Maia.XcbAtomType
{
    WM_PROTOCOLS,
    WM_DELETE_WINDOW,
    WM_TAKE_FOCUS,
    WM_NAME,

    _NET_WM_NAME,

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

    N;
}

internal struct Maia.XcbAtom
{
    // properties
    public XcbAtomType m_Type;
    public Xcb.Atom    m_XcbAtom;

    // methods
    public XcbAtom (XcbAtomType inType, Xcb.Atom inXcbAtom)
    {
        m_Type = inType;
        m_XcbAtom = inXcbAtom;
    }

    public int
    compare (XcbAtom? inOther)
    {
        return m_Type - inOther.m_Type;
    }

    public int
    compare_with_type (XcbAtomType inType)
    {
        return m_Type - inType;
    }
}

internal class Maia.XcbAtoms : Set<XcbAtom?>
{
    // properties
    private unowned XcbDesktop m_XcbDesktop;

    // methods
    public XcbAtoms (XcbDesktop inDesktop)
    {
        m_XcbDesktop = inDesktop;
        compare_func = XcbAtom.compare;

        Xcb.InternAtomCookie[] cookies = new Xcb.InternAtomCookie[XcbAtomType.N];

        for (int cpt = 0; cpt < (int)XcbAtomType.N; ++cpt)
        {
            string name = ((XcbAtomType)cpt).to_string ();
            cookies[cpt] = m_XcbDesktop.connection.intern_atom (false,
                                                                (uint16)name.length, 
                                                                name);
        }

        for (int cpt = 0; cpt < (int)XcbAtomType.N; ++cpt)
        {
            Xcb.InternAtomReply reply = cookies [cpt].reply (m_XcbDesktop.connection);
            if (reply == null)
            {
                XcbAtom atom = XcbAtom ((XcbAtomType)cpt, Xcb.AtomType.NONE);
                insert (atom);
            }
            else
            {
                XcbAtom atom = XcbAtom ((XcbAtomType)cpt, reply.atom);
                insert (atom);
            }
        }
    }

    public new Xcb.Atom
    @get (XcbAtomType inType)
    {
        unowned XcbAtom? atom = search<XcbAtomType> (inType, (ValueCompareFunc<XcbAtomType>)XcbAtom.compare_with_type);

        return atom != null ? atom.m_XcbAtom : Xcb.AtomType.NONE;
    }
}
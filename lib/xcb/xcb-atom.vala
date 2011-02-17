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
internal enum Maia.XcbAtomType
{
    WM_PROTOCOLS,
    WM_DELETE_WINDOW,

    N;

    public string?
    to_string ()
    {
        switch (this)
        {
            case WM_PROTOCOLS:
                return "WM_PROTOCOLS";
            case WM_DELETE_WINDOW:
                return "WM_DELETE_WINDOW";
        }

        return null;
    }
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
        return m_Type < inOther.m_Type ? -1 : (m_Type > inOther.m_Type ? 1 : 0);
    }
}

internal class Maia.XcbAtoms : Set<XcbAtom?>
{
    // properties
    private XcbDesktop m_XcbDesktop;

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
}
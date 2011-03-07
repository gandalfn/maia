/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-window-property.vala
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

internal class Maia.XcbWindowProperty<V>
{
    // properties
    private XcbWindow             m_Window;
    private Array<V>              m_Values;
    private Xcb.Atom              m_Property;
    private Xcb.Atom              m_Type;
    private uint8                 m_Size;
    private bool                  m_QueryPending = false;
    private Xcb.GetPropertyCookie m_Cookie;

    // methods
    public XcbWindowProperty (XcbWindow inWindow, XcbAtomType inProperty,
                              Xcb.Atom inType, uint8 inSize)
    {
        m_Window = inWindow;
        m_Values = new Array<V> ();
        m_Property = m_Window.xcb_desktop.atoms[inProperty];
        m_Type = inType;
        m_Size = inSize;
    }

    public void
    query ()
    {
        m_Values.clear ();

        XcbDesktop desktop = m_Window.xcb_desktop;
        m_Cookie = m_Window.xcb_window.get_property (desktop.connection, false,
                                                     m_Property, m_Type,
                                                     0, uint32.MAX);

        m_QueryPending = true;
    }

    public new unowned V?
    @get (int inIndex)
    {
        if (m_QueryPending)
        {
            XcbDesktop desktop = m_Window.xcb_desktop;
            Xcb.GetPropertyReply reply = m_Cookie.reply (desktop.connection);
            char* values = reply.get_value ();
            char* pos = values;
            int length = reply.get_length ();

            for (int cpt = 0; cpt < length; ++cpt)
            {
                V val = (V)pos;
                pos = pos + (m_Size / 8);
                m_Values.insert (val);
            }
            GLib.free (values);

            m_QueryPending = false;
        }

        return m_Values.at (inIndex);
    }

    public new bool
    contains (V inValue)
    {
        return inValue in m_Values;
    }

    public void
    insert (V inValue)
    {
        m_Values.insert (inValue);
    }

    public void
    remove (V inValue)
    {
        m_Values.remove (inValue);
    }

    public void
    commit ()
    {
        XcbDesktop desktop = m_Window.xcb_desktop;
        int n = m_Values.nb_items;
        char** values = GLib.Slice.alloc ((m_Size / 8) * n);
        char* pos = (char*)values;

        foreach (V val in m_Values)
        {
            GLib.Memory.copy (pos, &val, (m_Size / 8));
            pos = pos + (m_Size / 8);
        }

        m_Window.xcb_window.change_property (desktop.connection, Xcb.PropMode.REPLACE,
                                             m_Property, m_Type, m_Size, n, values);

        GLib.Slice.free ((m_Size / 8) * n, values);
    }
}
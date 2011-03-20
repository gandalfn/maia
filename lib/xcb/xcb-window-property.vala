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

internal class Maia.XcbWindowProperty<V> : XcbRequest
{
    // types
    public enum Format
    {
        U8  = 8,
        U16 = 16,
        U32 = 32
    }

    // properties
    private Xcb.Atom              m_Property;
    private Xcb.Atom              m_Type;
    private Format                m_Format;
    private Array<V>              m_Values;

    // methods
    public XcbWindowProperty (XcbWindow inWindow, XcbAtomType inProperty,
                              Xcb.Atom inType, Format inFormat)
    {
        base (inWindow);
        m_Property = window.xcb_desktop.atoms[inProperty];
        m_Type = inType;
        m_Format = inFormat;
        m_Values = new Array<V> ();
    }

    protected override void
    on_reply ()
    {
        m_Values.clear ();

        XcbDesktop desktop = window.xcb_desktop;
        Xcb.GetPropertyReply reply = ((Xcb.GetPropertyCookie?)cookie).reply (desktop.connection);

        switch (m_Format)
        {
            case Format.U32:
                {
                    uint32* values = reply.get_value ();
                    int length = reply.get_length ();

                    for (int cpt = 0; cpt < length; ++cpt)
                    {
                        V val = (V)(ulong)values[cpt];
                        m_Values.insert (val);
                    }
                    delete values;
                }
                break;

            case Format.U16:
                {
                    uint16* values = reply.get_value ();
                    int length = reply.get_length ();

                    for (int cpt = 0; cpt < length; ++cpt)
                    {
                        V val = (V)(ulong)values[cpt];
                        m_Values.insert (val);
                    }
                    delete values;
                }
                break;

            case Format.U8:
                {
                    if (typeof (V) == typeof (string))
                    {
                        string data = (string)reply.get_value ();
                        int length = reply.get_length ();
                        if (data.validate (length))
                        {
                            m_Values[0] = data.substring (0, length);
                        }
                    }
                    else
                    {
                        uint8* values = reply.get_value ();
                        int length = reply.get_length ();

                        for (int cpt = 0; cpt < length; ++cpt)
                        {
                            V val = (V)(ulong)values[cpt];
                            m_Values.insert (val);
                        }
                        delete values;
                    }
                }
                break;
        }
    }

    public override void
    on_commit ()
    {
        XcbDesktop desktop = window.xcb_desktop;
        char** values = null;
        int n = m_Values.nb_items;

        switch (m_Format)
        {
            case Format.U32:
                {
                    uint32* vals = new uint32[n];

                    int cpt = 0;
                    foreach (V val in m_Values)
                    {
                        vals[cpt] = (uint32)(ulong)val;
                        cpt++;
                    }
                    values = (char**)vals;
                }
                break;

             case Format.U16:
                {
                    uint16* vals = new uint16[n];

                    int cpt = 0;
                    foreach (V val in m_Values)
                    {
                        vals[cpt] = (uint16)(ulong)val;
                        cpt++;
                    }
                    values = (char**)vals;
                }
                break;

             case Format.U8:
                {
                    if (typeof (V) == typeof (string))
                    {
                        string data = (string)m_Values[0];
                        if (data != null)
                        {
                            n = data.length;
                            values = (char**)data.substring (0, n);
                        }
                        else
                        {
                            n = 0;
                        }
                    }
                    else
                    {
                        uint8* vals = new uint8[n];

                        int cpt = 0;
                        foreach (V val in m_Values)
                        {
                            vals[cpt] = (uint8)(ulong)val;
                            cpt++;
                        }
                        values = (char**)vals;
                    }
                }
                break;
        }

        ((Xcb.Window)window.id).change_property (desktop.connection, Xcb.PropMode.REPLACE,
                                                 m_Property, m_Type, m_Format, n, values);

        delete values;

        base.on_commit ();
    }

    public override void
    query ()
    {
        XcbDesktop desktop = window.xcb_desktop;
        cookie = ((Xcb.Window)window.id).get_property (desktop.connection, false,
                                                       m_Property, m_Type,
                                                       0, uint32.MAX);
    }

    public new unowned V?
    @get (int inIndex)
    {
        query_finish ();

        return inIndex < m_Values.nb_items ? m_Values[inIndex] : null;
    }

    public new void
    @set (int inIndex, V inValue)
    {
        m_Values[inIndex] = inValue;
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
}
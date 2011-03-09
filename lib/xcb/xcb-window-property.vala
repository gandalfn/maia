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

internal class Maia.XcbWindowProperty<V> : Array<V>
{
    // types
    public enum Format
    {
        U8  = 8,
        U16 = 16,
        U32 = 32
    }

    // properties
    private unowned XcbWindow     m_Window;
    private Xcb.Atom              m_Property;
    private Xcb.Atom              m_Type;
    private Format                m_Format;
    private bool                  m_QueryPending = false;
    private Xcb.GetPropertyCookie m_Cookie;

    // methods
    public XcbWindowProperty (XcbWindow inWindow, XcbAtomType inProperty,
                              Xcb.Atom inType, Format inFormat)
    {
        m_Window = inWindow;
        m_Property = m_Window.xcb_desktop.atoms[inProperty];
        m_Type = inType;
        m_Format = inFormat;
    }

    public void
    query ()
    {
        clear ();

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
            switch (m_Format)
            {
                case Format.U32:
                    {
                        uint32* values = reply.get_value ();
                        int length = reply.get_length ();

                        for (int cpt = 0; cpt < length; ++cpt)
                        {
                            V val = (V)(ulong)values[cpt];
                            insert (val);
                        }
                        GLib.free (values);
                    }
                    break;

                case Format.U16:
                    {
                        uint16* values = reply.get_value ();
                        int length = reply.get_length ();

                        for (int cpt = 0; cpt < length; ++cpt)
                        {
                            V val = (V)(ulong)values[cpt];
                            insert (val);
                        }
                        GLib.free (values);
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
                                string val = data.substring (0, length);
                                insert (val);
                            }
                        }
                        else
                        {
                            uint8* values = reply.get_value ();
                            int length = reply.get_length ();

                            for (int cpt = 0; cpt < length; ++cpt)
                            {
                                V val = (V)(ulong)values[cpt];
                                insert (val);
                            }
                            GLib.free (values);
                        }
                    }
                    break;
            }
            m_QueryPending = false;
        }

        return inIndex < nb_items ? at (inIndex) : null;
    }

    public void
    commit ()
    {
        XcbDesktop desktop = m_Window.xcb_desktop;
        char** values = null;
        int n = nb_items;

        switch (m_Format)
        {
            case Format.U32:
                {
                    uint32* vals = GLib.malloc (sizeof (uint32) * n);

                    int cpt = 0;
                    foreach (V val in this)
                    {
                        vals[cpt] = (uint32)(ulong)val;
                        cpt++;
                    }
                    values = (char**)vals;
                }
                break;

             case Format.U16:
                {
                    uint16* vals = GLib.malloc (sizeof (uint16) * n);

                    int cpt = 0;
                    foreach (V val in this)
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
                        string data = (string)at(0);
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
                        uint8* vals = GLib.malloc (sizeof (uint8) * n);

                        int cpt = 0;
                        foreach (V val in this)
                        {
                            vals[cpt] = (uint8)(ulong)val;
                            cpt++;
                        }
                        values = (char**)vals;
                    }
                }
                break;
        }

        m_Window.xcb_window.change_property (desktop.connection, Xcb.PropMode.REPLACE,
                                             m_Property, m_Type, m_Format, n, values);

        GLib.free (values);
    }
}
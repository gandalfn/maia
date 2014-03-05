/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * application.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.Application : Core.Object
{
    // properties
    private global::Xcb.Connection         m_Connection;
    private int                            m_DefaultScreen;
    private ConnectionWatch                m_Watch;
    private Atoms                          m_Atoms;
    private global::Xcb.Util.CursorContext m_Cursors;

    // accessors
    public global::Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public int default_screen {
        get {
            return m_DefaultScreen;
        }
    }

    public Atoms atoms {
        get {
            return m_Atoms;
        }
    }

    public global::Xcb.Util.CursorContext cursors {
        get {
            return m_Cursors;
        }
    }
    
    // methods
    public Application (string? inDisplay = null)
    {
        GLib.Object (id: inDisplay != null ? GLib.Quark.from_string (inDisplay) : 0);

        m_Connection = new global::Xcb.Connection (inDisplay, out m_DefaultScreen);
        m_Atoms = new Atoms (m_Connection);
        m_Watch = new ConnectionWatch (m_Connection);
        m_Cursors = global::Xcb.Util.CursorContext.create (m_Connection, m_Connection.roots[m_DefaultScreen]);
    }
}

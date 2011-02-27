/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * application.vala
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

namespace Maia.XcbBackend
{
    [CCode (cprefix = "MaiaXcbBackend", lower_case_cprefix = "maia_xcb_backend_")]
    internal extern Maia.Application create_application ();
}

public abstract class Maia.Application : Object
{
    // static properties
    static Application s_Default = null;

    // properties
    private Dispatcher m_Dispatcher;

    // accessors
    public Dispatcher dispatcher {
        get {
            return m_Dispatcher;
        }
    }

    public abstract Desktop desktop { get; }

    // static methods
    public static Application
    create ()
    {
        if (s_Default == null)
        {
            s_Default = Maia.XcbBackend.create_application ();
        }
        return s_Default;
    }

    public static new Application?
    @get ()
    {
        return s_Default;
    }

    // methods
    construct 
    {
        m_Dispatcher = new Dispatcher ();
    }

    public void
    run ()
    {
        m_Dispatcher.run ();
    }

    public void
    quit ()
    {
        m_Dispatcher.finish ();
    }
}
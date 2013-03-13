/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-cookie.vala
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

internal abstract class Maia.XcbCookie : Task
{
    // properties
    protected unowned XcbApplication? m_Application;

    // methods
    public XcbCookie (XcbApplication inApplication, Xcb.VoidCookie inCookie)
    {
        base ();
        m_Application = inApplication;
        id = inCookie.sequence;
        parent = m_Application.dispatcher;
        state = Task.State.READY;
    }

    public override void
    run ()
    {
        state = Task.State.TERMINATED;
        parent = null;
    }
}

internal class Maia.XcbVoidCookie : XcbCookie
{
    // types
    public delegate void Callback (XcbVoidCookie inCookie);

    // properties
    private Xcb.GenericError? m_Error;
    private Callback          m_Func;

    // accessors
    public Xcb.GenericError? error {
        get {
            return m_Error;
        }
    }

    // methods
    public XcbVoidCookie (XcbApplication inApplication, Xcb.VoidCookie inCookie, owned Callback inCallback)
    {
        base (inApplication, inCookie);
        m_Func = (owned)inCallback;
    }

    public override void
    run ()
    {
        m_Error = m_Application.connection.request_check ({ id });
        m_Func (this);

        base.run ();
    }
}

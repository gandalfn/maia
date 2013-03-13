/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-request.vala
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

internal abstract class Maia.XcbRequest : Object
{
    // types
    public enum State
    {
        IDLE,
        QUERYING,
        COMMITING
    }

    // properties
    private unowned XcbWindow m_Window;
    private Xcb.VoidCookie?   m_Cookie = null;
    private State             m_State = State.IDLE;

    // accessors
    public State state {
        get {
            read_lock ();
            State ret = m_State;
            read_unlock ();
            return ret;
        }
    }

    [CCode (notify = false)]
    public virtual XcbWindow window {
        get {
            return m_Window;
        }
        construct set {
            m_Window = value;
        }
    }

    [CCode (notify = false)]
    public Xcb.VoidCookie? cookie {
        get {
            read_lock ();
            unowned Xcb.VoidCookie? ret = m_Cookie;
            read_unlock ();
            return ret;
        }
        set {
            write_lock ();
            m_Cookie = value;
            write_unlock ();
        }
    }

    // methods
    public XcbRequest (XcbWindow inWindow)
    {
        GLib.Object (window: inWindow);
    }

    ~XcbRequest ()
    {
        Log.audit ("~XcbRequest", "Destroy request");

        if (cookie != null)
        {
            m_Window.xcb_desktop.connection.discard_reply (m_Cookie.sequence);
            cookie = null;
        }
    }

    protected virtual void
    on_reply ()
    {
        write_lock ();
        m_State = State.IDLE;
        write_unlock ();
    }

    protected virtual void
    on_commit ()
    {
        write_lock ();
        m_State = State.IDLE;
        write_unlock ();
    }

    public void
    query_finish ()
    {
        Log.audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

        if (cookie != null)
        {
            Log.debug (GLib.Log.METHOD, "Flush query");

            on_reply ();
            cookie = null;
        }
    }

    public void
    process ()
    {
        switch (state)
        {
            case State.QUERYING:
                query_finish ();
                break;
            case State.COMMITING:
                on_commit ();
                break;
            default:
                break;
        }
    }

    public virtual void
    query ()
    {
        if (state == State.IDLE)
        {
            write_lock ();
            m_State = State.QUERYING;
            write_unlock ();
            m_Window.xcb_desktop.add_request (this);
        }
    }

    public virtual void
    commit ()
    {
        if (state == State.QUERYING)
        {
            if (m_Cookie != null)
            {
                m_Window.xcb_desktop.connection.discard_reply (m_Cookie.sequence);
                m_Cookie = null;
            }
            write_lock ();
            m_State = State.COMMITING;
            write_unlock ();
        }
        else if (state == State.IDLE)
        {
            write_lock ();
            m_State = State.COMMITING;
            write_unlock ();

            m_Window.xcb_desktop.add_request (this);
        }
    }
}

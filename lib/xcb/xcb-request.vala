/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-request.vala
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
            return m_State;
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
            return m_Cookie;
        }
        set {
            m_Cookie = value;
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

        if (m_State != State.IDLE)
        {
            m_Window.xcb_desktop.remove_request (this);
        }

        if (m_Cookie != null)
        {
            m_Window.xcb_desktop.connection.discard_reply (m_Cookie.sequence);
            m_Cookie = null;
        }
    }

    protected virtual void
    on_reply ()
    {
        m_State = State.IDLE;
    }

    protected virtual void
    on_commit ()
    {
        m_State = State.IDLE;
    }

    public void
    query_finish ()
    {
        Log.audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

        if (m_Cookie != null)
        {
            Log.debug (GLib.Log.METHOD, "Flush query");

            on_reply ();
            m_Cookie = null;
        }
    }

    public void
    process ()
    {
        switch (m_State)
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
        rw_lock.write_lock ();
        if (m_State == State.IDLE)
        {
            m_State = State.QUERYING;
            rw_lock.write_unlock ();
            m_Window.xcb_desktop.add_request (this);
        }
        else
        {
            rw_lock.write_unlock ();
        }
    }

    public virtual void
    commit ()
    {
        rw_lock.write_lock ();
        if (m_State == State.QUERYING)
        {
            if (m_Cookie != null)
            {
                m_Window.xcb_desktop.connection.discard_reply (m_Cookie.sequence);
                m_Cookie = null;
            }
            m_State = State.COMMITING;
            rw_lock.write_unlock ();
        }
        else if (m_State == State.IDLE)
        {
            m_State = State.COMMITING;
            rw_lock.write_unlock ();
            m_Window.xcb_desktop.add_request (this);
        }
        else
        {
            rw_lock.write_unlock ();
        }
    }
}

/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    // properties
    private unowned XcbWindow m_Window;
    private Xcb.VoidCookie?   m_Cookie = null;
    private bool              m_IsQueryQueued = false;
    private bool              m_IsCommitQueued = false;

    // accessors
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
        audit ("~XcbRequest", "Destroy request");
        cookie = null;
    }

    protected virtual void
    on_reply ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);
        m_IsQueryQueued = false;
    }

    public virtual void
    on_commit ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);
        m_IsCommitQueued = false;
        m_IsQueryQueued = false;
        m_Cookie = null;
    }

    public void
    query_finish ()
    {
        audit (GLib.Log.METHOD, "xid: 0x%x", m_Window.id);

        if (m_Cookie != null)
        {
            debug (GLib.Log.METHOD, "Flush query");

            on_reply ();
            m_Cookie = null;
        }
    }

    public virtual void
    query ()
    {
        if (!m_IsQueryQueued)
        {
            m_IsQueryQueued = true;
            m_Window.xcb_desktop.add_query_request (this);
        }
    }

    public virtual void
    commit ()
    {
        if (!m_IsCommitQueued)
        {
            m_IsCommitQueued = true;
            m_Window.xcb_desktop.add_commit_request (this);
        }
    }
}
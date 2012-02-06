/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * workspace.vala
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

public class Maia.Workspace : View
{
    // properties
    private unowned WorkspaceProxy m_Proxy;
    private QueueDrawEvent         m_EventQueueDraw;

    // events
    internal override DamageEvent damage_event {
        get {
            return m_Proxy.damage_event;
        }
    }

    public QueueDrawEvent queue_draw_event {
        get {
            return m_EventQueueDraw;
        }
    }

    public CreateWindowEvent create_window_event {
        get {
            return m_Proxy.create_window_event;
        }
    }

    public DestroyWindowEvent destroy_window_event {
        get {
            return m_Proxy.destroy_window_event;
        }
    }

    public ReparentWindowEvent reparent_window_event {
        get {
            return m_Proxy.reparent_window_event;
        }
    }

    // accessors
    public unowned WorkspaceProxy? proxy {
        get {
            return m_Proxy;
        }
    }

    public uint num {
        get {
            return m_Proxy.num;
        }
    }

    [CCode (notify = false)]
    internal override Region geometry {
        get {
            return m_Proxy.geometry;
        }
        internal set {
        }
    }

    [CCode (notify = false)]
    internal override bool double_buffered {
        get {
            return m_Proxy.double_buffered;
        }
        set {
            m_Proxy.double_buffered = value;
        }
    }

    internal override unowned GraphicDevice? back_buffer {
        get {
            return m_Proxy.back_buffer;
        }
    }

    internal override unowned GraphicDevice? front_buffer {
        get {
            return m_Proxy.front_buffer;
        }
    }

    public Window root {
        get {
            return m_Proxy.root;
        }
    }

    // methods
    public Workspace (Desktop inDesktop)
    {
        Log.audit (GLib.Log.METHOD, "Create workspace");

        GLib.Object (parent: inDesktop);

        m_Proxy = delegate_cast<WorkspaceProxy> ();
        m_EventQueueDraw = new QueueDrawEvent (this);
    }

    internal override string
    to_string ()
    {
        string ret = "";

        rw_lock.read_lock ();
        iterator ().foreach ((window) => {
            ret += window.to_string () + "\n";
            return true;
        });
        ret += "\n";
        rw_lock.read_unlock ();

        return ret;
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Window;
    }

    public void
    queue_draw (Window? inWindow, Region inArea)
    {
        m_EventQueueDraw.post (new QueueDrawEventArgs (inWindow, inArea));
    }
}

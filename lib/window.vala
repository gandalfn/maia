/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
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

public class Maia.Window : View
{
    // types
    public enum HintType
    {
        UNKNOWN,
        DESKTOP,
        NORMAL,
        DIALOG,
        SPLASH,
        UTILITY,
        DND,
        TOOLTIP,
        NOTIFICATION,
        TOOLBAR,
        COMBO,
        DROPDOWN_MENU,
        POPUP_MENU,
        MENU,
        DOCK
    }

    // properties
    private bool                m_Foreign = false;
    private unowned WindowProxy m_Proxy;
    private string              m_Name = null;

    // events
    public override DamageEvent damage_event {
        get {
            return m_Proxy.damage_event;
        }
    }

    public DeleteEvent delete_event {
        get {
            return m_Proxy.delete_event;
        }
    }

    // accessors
    [CCode (notify = false)]
    public string name {
        get {
            return m_Name;
        }
        construct set {
            m_Name = value;
        }
    }

    [CCode (notify = false)]
    public override Object parent {
        get {
            return base.parent;
        }
        construct set {
            unowned Object? parent = base.parent;

            if (parent != null && parent is Workspace)
            {
                (parent as Workspace).stack.remove (this);
            }

            base.parent = value;

            if (value != null && value is Workspace && m_Proxy != null)
            {
                debug ("Maia.Window.parent.set", "insert in workspace stack %s", m_Foreign.to_string ());
                (value as Workspace).stack.insert (this);
            }
        }
    }

    public unowned Workspace? workspace {
        get {
            unowned Object? p = parent;
            for (; p != null && !(p is Workspace); p = p.parent);

            if (p != null && p is Workspace)
                return p as Workspace;

            return null;
        }
    }

    [CCode (notify = false)]
    public bool is_foreign {
        get {
            return m_Foreign;
        }
        construct {
            m_Foreign = value;
        }
    }

    [CCode (notify = false)]
    public unowned WindowProxy proxy {
        get {
            return m_Proxy;
        }
        set {
            if (m_Proxy == null)
            {
                m_Proxy = value;
                assert(m_Proxy != null);

                if (parent is Workspace)
                {
                    (parent as Workspace).stack.insert (this);
                }
            }
        }
    }

    [CCode (notify = false)]
    public override Region geometry {
        get {
            return m_Proxy.geometry;
        }
        set {
            m_Proxy.geometry = value;
        }
    }

    [CCode (notify = false)]
    public HintType hint_type {
        get {
            return m_Proxy.hint_type;
        }
        set {
            m_Proxy.hint_type = value;
        }
    }

    // methods
    construct
    {
        audit ("Maia.Window.construct", "create window");

        proxy = delegate_cast<WindowProxy> ();
    }

    public Window (string inName, int inWidth, int inHeight)
        requires (Application.self != null)
    {
        Workspace workspace = Application.default.desktop.default_workspace;
        Region geometry = new Region.raw_rectangle (0, 0, inWidth, inHeight);
        GLib.Object (name: inName, parent: workspace, geometry: geometry);

        unowned Dispatcher? dispatcher = Application.self;
        m_Proxy.damage_event.listen (on_damage_event, dispatcher);
        m_Proxy.delete_event.listen (on_delete_event, dispatcher);
    }

    public Window.foreign (uint32 inId, Workspace inWorkspace)
    {
        GLib.Object (id: inId, is_foreign: true, parent: inWorkspace);

        unowned Dispatcher? dispatcher = Application.self;
        m_Proxy.damage_event.listen (on_damage_event, dispatcher);
    }

    private void
    on_damage_event (DamageEventArgs inArgs)
    {
        Maia.audit (GLib.Log.METHOD, "%s", inArgs.area.to_string ());
        on_paint (inArgs.area);
    }

    private void
    on_delete_event ()
    {
        Maia.audit (GLib.Log.METHOD, "");
        on_destroy ();
    }

    protected virtual void
    on_paint (Region inExposeArea)
    {
    }

    protected virtual void
    on_destroy ()
    {
        m_Proxy.destroy ();
    }

    public override string
    to_string ()
    {
        return m_Proxy.to_string ();
    }

    public void
    show ()
    {
        m_Proxy.show ();
    }

    public void
    hide ()
    {
        m_Proxy.hide ();
    }
}
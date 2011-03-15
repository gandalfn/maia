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
    private unowned WindowProxy m_Proxy;

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
    public override Region geometry {
        get {
            return m_Proxy.geometry;
        }
    }

    public HintType hint_type {
        get {
            return m_Proxy.hint_type;
        }
        set {
            m_Proxy.hint_type = value;
        }
    }

    // methods
    public Window (string inName, Region inGeometry)
        requires (Application.self != null)
    {
        Workspace workspace = Application.default.desktop.default_workspace;
        GLib.Object (name: inName, parent: workspace);

        workspace.create_window (this, inGeometry);

        m_Proxy = delegate_cast<WindowProxy> ();
        assert (m_Proxy != null);

        unowned Dispatcher? dispatcher = Application.self;
        m_Proxy.damage_event.listen (on_damage_event, dispatcher);
        m_Proxy.delete_event.listen (on_delete_event, dispatcher);
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
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
    internal override DamageEvent damage_event {
        get {
            return m_Proxy.damage_event;
        }
    }

    internal DeleteEvent delete_event {
        get {
            return m_Proxy.delete_event;
        }
    }

    // accessors
    public unowned WindowProxy proxy {
        get {
            return m_Proxy;
        }
    }

    [CCode (notify = false)]
    internal override Region geometry {
        get {
            return m_Proxy.geometry;
        }
        set {
            m_Proxy.geometry = value;
        }
    }

    public unowned Workspace? workspace {
        get {
            unowned Workspace? ret = null;
            for (unowned Object? p = parent; p != null; p = p.parent)
            {
                if (p is Workspace)
                {
                    ret = (Workspace)p;
                    break;
                }
            }

            return ret;
        }
    }

    public string name { get; construct set; default = null; }
    public bool is_foreign { get; construct; default = false; }
    public bool is_viewable { get; protected set; default = false; }
    public bool is_input_only { get; protected set; default = false; }
    public HintType hint_type { get; set; default = HintType.NORMAL; }

    // methods
    construct
    {
        audit ("Maia.Window.construct", "create window %u", ref_count);

        m_Proxy = delegate_cast<WindowProxy> ();
        assert(m_Proxy != null);
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
        audit(GLib.Log.METHOD, "%u", ref_count);
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

    internal override string
    to_string ()
    {
        string ret = @"$id [label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td>";

        if (name != null)
            ret += @"name: $name<br/>";
        ret += "id: 0x%x<br/>".printf (id);
        ret += @"foreign: $is_foreign<br/>";
        ret += @"viewable: $is_viewable<br/>";
        ret += @"input only: $is_input_only<br/>";
        ret += @"wm type: $hint_type<br/>";
        if (geometry != null)
            ret += @"geometry: $geometry";
        ret += "</td></tr></table>>];\n";

        foreach (unowned Object object in this)
        {
            ret += (object as Window).to_string ();
            ret += "%s -> %s;\n".printf (id.to_string (), (object as Window).id.to_string ());
        }

        return ret;
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

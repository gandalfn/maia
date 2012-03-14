/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    public enum State
    {
        UNSET,
        HIDDEN,
        VISIBLE,
        ICONIC
    }

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
    private string              m_Name = null;
    private State               m_State = State.HIDDEN;
    private bool                m_IsForeign = false;
    private bool                m_IsViewable = false;
    private bool                m_IsInputOnly = false;
    private HintType            m_HintType = HintType.NORMAL;

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

    internal GeometryEvent geometry_event {
        get {
            return m_Proxy.geometry_event;
        }
    }

    // accessors
    public unowned WindowProxy proxy {
        get {
            return m_Proxy;
        }
    }

    internal override Region geometry {
        get {
            return m_Proxy.geometry;
        }
        set {
            m_Proxy.geometry = value;
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

    public string name {
        get {
            return m_Name;
        }
        construct set {
            m_Name = value;
        }
    }

    public State state {
        get {
            return m_State;
        }
        set {
            m_State = value;
        }
    }

    [CCode (notify = false)]
    public bool is_foreign {
        get {
            return m_IsForeign;
        }
        construct {
            m_IsForeign = value;
        }
    }

    public bool is_viewable {
        get {
            return m_IsViewable;
        }
        set {
            m_IsViewable = value;
        }
    }

    public bool is_input_only {
        get {
            return m_IsInputOnly;
        }
        set {
            m_IsInputOnly = value;
        }
    }

    public HintType hint_type {
        get {
            return m_HintType;
        }
        set {
            m_HintType = value;
        }
    }

    // methods
    construct
    {
        Log.audit ("Maia.Window.construct", "create window %u", ref_count);

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
        m_Proxy.geometry_event.listen (on_geometry_event, dispatcher);
        m_Proxy.delete_event.listen (on_delete_event, dispatcher);
    }

    public Window.foreign (uint32 inId, Workspace inWorkspace)
    {
        GLib.Object (id: inId, is_foreign: true, parent: inWorkspace);

        unowned Dispatcher? dispatcher = Application.self;
        m_Proxy.damage_event.listen (on_damage_event, dispatcher);
        m_Proxy.geometry_event.listen (on_geometry_event, dispatcher);
        Log.audit(GLib.Log.METHOD, "%u", ref_count);
    }

    private void
    on_geometry_event (GeometryEventArgs inArgs)
    {
        Log.audit (GLib.Log.METHOD, "%s", inArgs.geometry.to_string ());
        geometry = inArgs.geometry;
        on_move_resize (inArgs.geometry);
    }

    private void
    on_damage_event (DamageEventArgs inArgs)
    {
        Log.audit (GLib.Log.METHOD, "%s", inArgs.area.to_string ());

        // Paint window
        if (double_buffered)
        {
            m_Proxy.back_buffer.rw_lock.write_lock ();
            on_paint (inArgs.area);
            m_Proxy.back_buffer.rw_lock.write_unlock ();

            ((Desktop)workspace.parent).flush ();

            workspace.queue_draw (this, inArgs.area);
        }
        else
        {
            on_paint (inArgs.area);
            ((Desktop)workspace.parent).flush ();
        }
    }

    private void
    on_delete_event ()
    {
        Log.audit (GLib.Log.METHOD, "");
        on_destroy ();
    }

    protected virtual void
    on_move_resize (Region inNewGeometry)
    {
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
        string ret = "";

        ret += "id: 0x%x\n".printf (id);
        if (name != null)
            ret += "name: %s\n".printf (name);
        ret += "id: 0x%x\n".printf (id);
        ret += "state: " + state.to_string () + "\n";
        ret += "foreign: " + is_foreign.to_string () + "\n";
        ret += "viewable: " + is_viewable.to_string () + "\n";
        ret += "input only: " + is_input_only.to_string () + "\n";
        ret += "wm type: " + hint_type.to_string () + "\n";
        if (geometry != null)
            ret += "geometry: " + geometry.to_string () + "\n";

        iterator ().foreach ((object) => {
            ret += "--\n%s\n--\n".printf (((Window)object).to_string ());
            return true;
        });

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

    public void
    queue_draw ()
    {
        damage_event.post (new DamageEventArgs (geometry));
    }

    public GraphicContext
    create_context ()
    {
        if (!double_buffered)
        {
            return m_Proxy.front_buffer.create_context ();
        }

        return m_Proxy.back_buffer.create_context ();
    }
}

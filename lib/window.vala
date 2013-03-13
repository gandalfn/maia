/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
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

public class Maia.Window : DoubleBufferView
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

    // accessors
    /**
     * The workspace where window is located on
     */
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

    /**
     * Window name
     */
    public string name { get; construct set; default = null; }

    /**
     * The type of window
     */
    public HintType hint_type { get; set; default = HintType.NORMAL; }

    // methods
    construct
    {
        Log.audit ("Maia.Window.construct", "create window %u", ref_count);

        //damage_event.listen (on_damage_event, workspace.dispatcher);
        //geometry_event.listen (on_geometry_event, workspace.dispatcher);
    }

    /**
     * Create a new window managed by maia
     *
     * @param inName the name of window
     * @param inWidth the initial width of window
     * @param inHeight the initial height of window
     */
    public Window (string inName, int inWidth, int inHeight)
    {
        Workspace workspace = Application.default.default_workspace;
        Graphic.Region geometry = Graphic.Region.create (Graphic.Rectangle (0, 0, inWidth, inHeight));
        GLib.Object (parent: workspace, name: inName, geometry: geometry);
    }

    private void
    on_damage_event (DamageEventArgs inArgs)
    {
        Log.audit (GLib.Log.METHOD, "%s", inArgs.area.extents.to_string ());
        draw (inArgs.area);
    }

    private void
    on_geometry_event (GeometryEventArgs inArgs)
    {
        Log.audit (GLib.Log.METHOD, "%s", inArgs.geometry.extents.to_string ());

        if (geometry == null || !geometry.equal (inArgs.geometry))
        {
            Graphic.Rectangle old_clipbox = geometry.extents;
            Graphic.Rectangle new_clipbox = inArgs.geometry.extents;

            geometry = inArgs.geometry;

            if (old_clipbox.origin.x != new_clipbox.origin.x ||
                old_clipbox.origin.y != new_clipbox.origin.y)
            {
                on_move ();
            }

            if (old_clipbox.size.width != new_clipbox.size.width ||
                old_clipbox.size.height != new_clipbox.size.height)
            {
                on_resize ();

                damage ();
            }
        }
    }

    private void
    on_delete_event ()
    {
        Log.audit (GLib.Log.METHOD, "");
        on_destroy ();
    }

    protected virtual void
    on_move ()
    {
    }

    protected virtual void
    on_resize ()
    {
    }

    protected virtual void
    on_destroy ()
    {
    }

    internal override string
    to_string ()
    {
        string ret = "";

        ret += "id: 0x%x\n".printf (id);
        if (name != null)
            ret += "name: %s\n".printf (name);
        ret += "id: 0x%x\n".printf (id);
        ret += "visible: " + visible.to_string () + "\n";
        ret += "hint type: " + hint_type.to_string () + "\n";
        if (geometry != null)
            ret += "geometry: " + geometry.extents.to_string () + "\n";

        foreach (unowned Object object in this)
        {
            ret += "--\n%s\n--\n".printf ((object as Window).to_string ());
        }

        return ret;
    }
}

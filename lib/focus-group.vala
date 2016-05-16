/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * focus-group.vala
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

public class Maia.FocusGroup : Core.Object, Manifest.Element
{
    // types
    private static int
    compare_focusable (ItemFocusable inA, ItemFocusable inB)
    {
        if (inA.focus_order <= 0 && inB.focus_order <= 0)
        {
            return -1;
        }

        if (inA.focus_order <= 0 && inB.focus_order >= 0)
        {
            return 1;
        }

        if (inA.focus_order >= 0 && inB.focus_order <= 0)
        {
            return -1;
        }

        return inA.focus_order - inB.focus_order;
    }

    // properties
    private Core.Array<unowned ItemFocusable> m_Items;
    private int                               m_Current = -1;
    private unowned Window?                   m_Window = null;
    
    // accessors
    internal string tag {
        get {
            return "FocusGroup";
        }
    }

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    /**
     * {@inheritDoc}
     */
    [CCode (notify = false)]
    public override unowned Core.Object? parent {
        get {
            return base.parent;
        }
        construct set {
            if (parent != null && parent is Item)
            {
                (parent as Item).notify["window"].disconnect (on_window_changed);
            }

            base.parent = value;

            if (parent != null && parent is Item)
            {
                (parent as Item).notify["window"].connect (on_window_changed);
            }

            on_window_changed ();
        }
    }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public GLib.List<unowned ItemFocusable> items {
        owned get {
            GLib.List<unowned ItemFocusable> ret = new GLib.List<unowned ItemFocusable> ();
            foreach (unowned ItemFocusable item in m_Items)
            {
                ret.append (item);
            }
            return ret;
        }
    }

    public ItemFocusable current {
        get {
            return m_Current >= 0 ? m_Items[m_Current] : null;
        }
    }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (FocusGroup), attribute_to_focus_group);

        GLib.Value.register_transform_func (typeof (FocusGroup), typeof (string), focus_group_to_value_string);
    }

    static void
    attribute_to_focus_group (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        unowned Core.Object object = inAttribute.owner as Core.Object;
        unowned FocusGroup? focus_group = null;

        GLib.Quark id  = GLib.Quark.from_string (inAttribute.get ());
        for (unowned Core.Object item = object; item != null; item = item.parent)
        {
            unowned View? view = item.parent as View;

            // If owned is in view search model in cell first
            if (view != null)
            {
                focus_group = item.find (id, false) as FocusGroup;
                if (focus_group != null) break;
            }
            // We not found model in view parents search in root
            else if (item.parent == null)
            {
                focus_group = item.find (id) as FocusGroup;
            }
        }

        outValue = focus_group;
    }

    static void
    focus_group_to_value_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (FocusGroup)))
    {
        unowned FocusGroup val = (FocusGroup)inSrc;

        outDest = val.name;
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("name");

        // Create item array
        m_Items = new Core.Array<unowned ItemFocusable>.sorted ();
        m_Items.compare_func = compare_focusable;

        // Connect onto window changed
        notify["window"].connect (on_window_changed);
    }

    public FocusGroup (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_grab_focus_changed (Item? inItem)
    {
        unowned ItemFocusable? item_focusable = inItem as ItemFocusable;

        if (item_focusable != null)
        {
            if (m_Current < 0 || (m_Current >= 0 && m_Items[m_Current] != item_focusable))
            {
                bool found = false;
                m_Current = 0;
                foreach (unowned ItemFocusable item in m_Items)
                {
                    if (item == item_focusable)
                    {
                        found = true;
                        break;
                    }
                    m_Current++;
                }

                if (!found) m_Current = -1;
            }
        }
        else
        {
            m_Current = -1;
        }
    }

    private void
    on_window_changed ()
    {
        if (m_Window != null)
        {
            m_Window.grab_focus.disconnect (on_grab_focus_changed);
        }

        if (parent is Item && (parent as Item).window != null)
        {
            m_Window = (parent as Item).window;
            m_Window.grab_focus.connect (on_grab_focus_changed);
        }
    }

    private void
    on_item_destroyed (GLib.Object inChild)
        requires (inChild is ItemFocusable)
    {
        m_Items.remove (inChild as ItemFocusable);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    public new void
    add (ItemFocusable inItem)
    {
        bool found = false;
        foreach (unowned ItemFocusable item in m_Items)
        {
            if (inItem == item)
            {
                found = true;
                break;
            }
        }
        if (!found)
        {
            m_Items.insert (inItem);
            inItem.weak_ref (on_item_destroyed);
        }
        else
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_PARSING, "Duplicate item %s in %s focus group", inItem.name, name);
        }
    }

    public void
    remove (ItemFocusable inItem)
    {
        bool found = false;
        foreach (unowned ItemFocusable item in m_Items)
        {
            if (inItem == item)
            {
                found = true;
                break;
            }
        }
        if (found)
        {
            m_Items.remove (inItem);
            inItem.weak_unref (on_item_destroyed);
        }
    }

    public new void
    prev ()
    {
        if (m_Current >= 0)
        {
            m_Current--;
        }

        if (parent is Item && (parent as Item).window != null)
        {
            (parent as Item).window.grab_focus (m_Current >= 0 ? m_Items[m_Current] : null);
        }
    }

    public new void
    next ()
    {
        m_Current++;
        if (m_Current >= m_Items.length)
        {
            m_Current = -1;
        }

        if (parent is Item && (parent as Item).window != null)
        {
            (parent as Item).window.grab_focus (m_Current >= 0 ? m_Items[m_Current] : null);
        }
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * toolbox.vala
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

public class Maia.Toolbox : Popup
{
    // accessors
    internal override string tag {
        get {
            return "Toolbox";
        }
    }

    // signals
    /**
     * Signal emitted when a tool button with add or add-parent action
     * is pressed
     *
     * @param inItem the item to add
     * @param inParent if ``true`` add inItem to parent of focus item
     */
    public signal void add_item (Item inItem, bool inParent);

    /**
     * Signal emitted when a tool button with remove action is pressed
     */
    public signal void remove_item ();

    /**
     * Signal emitted when the current focus item has changed
     *
     * @param inItem the current focus item ``null`` if no item selected
     */
    public signal void current_item_changed (Item? inItem);

    // methods
    construct
    {
        // Create grid content
        Grid grid = new Grid ("%s-content".printf (((GLib.Quark)id).to_string ()));
        add (grid);
    }

    public Toolbox (string inId)
    {
        base (inId);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return content == null ? base.can_append_child (inObject) : (content as Grid).can_append_child (inObject);
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (content != null)
        {
            (content as Grid).insert_child (inObject);
        }
        else
        {
            base.insert_child (inObject);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject != content)
        {
            (content as Grid).remove_child (inObject);
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        if (content != null)
        {
            ret += (content as Item).dump_childs (inPrefix);
        }

        return ret;
    }
}

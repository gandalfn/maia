/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * model.vala
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

public abstract class Maia.Model : Core.Object, Manifest.Element
{
    // types
    public abstract class Column : Core.Object, Manifest.Element
    {
        // accessors
        internal string tag {
            get {
                return "Column";
            }
        }

        internal string characters { get; set; default = null; }
        internal string manifest_path { get; set; default = null; }
        internal Core.Set<Manifest.Style> manifest_styles { get; set; default = null; }

        public string name {
            owned get {
                return ((GLib.Quark)id).to_string ();
            }
        }

        public unowned Model? model {
            get {
                return parent as Model;
            }
        }

        public int column { get; set; default = -1; }

        // methods
        construct
        {
            // Add not dumpable attributes
            not_dumpable_attributes.insert ("name");
            not_dumpable_attributes.insert ("model");
        }

        internal override bool
        can_append_child (Core.Object inObject)
        {
            // column can not have childs
            return false;
        }

        public abstract new GLib.Value @get (uint inPath);
    }

    // accessors
    internal string tag {
        get {
            return "Model";
        }
    }

    internal string characters { get; set; default = null; }
    internal string manifest_path { get; set; default = null; }
    internal Core.Set<Manifest.Style> manifest_styles { get; set; default = null; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public abstract uint nb_rows { get; }

    // signals
    [Signal (detailed = true)]
    public signal void value_changed (uint inRow);

    public virtual signal void
    row_added (uint inRow)
    {
        foreach (unowned Core.Object child in this)
        {
            if (child is Column)
            {
                unowned Column column = (Column)child;

                value_changed[column.name] (inRow);
            }
        }
    }

    public virtual signal void
    row_changed (uint inRow)
    {
        foreach (unowned Core.Object child in this)
        {
            if (child is Column)
            {
                unowned Column column = (Column)child;

                value_changed[column.name] (inRow);
            }
        }
    }

    public signal void row_deleted    (uint inRow);
    public signal void rows_reordered (uint[] inNewOrder);

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("name");
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Column;
    }

    internal override int
    compare (Core.Object inOther)
    {
        int ret =  0;

        if (inOther is Item)
        {
            // Item always after
            ret = -1;
        }
        else
        {
            ret = base.compare (inOther);
        }

        return ret;
    }

    public new unowned Column?
    @get (string inColumnName)
    {
        return find (GLib.Quark.from_string (inColumnName), false) as Column;
    }
}

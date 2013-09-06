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

public class Maia.Gtk.Model : Maia.Model
{
    // types
    public class Column : Maia.Model.Column
    {
        // methods
        internal override new GLib.Value
        @get (uint inPath)
        {
            unowned global::Gtk.TreeModel treemodel = ((Model)model).treemodel;

            if (column >= 0 && treemodel != null && inPath < treemodel.iter_n_children(null))
            {
                global::Gtk.TreeIter iter;
                if (treemodel.get_iter_from_string (out iter, "%u".printf (inPath)))
                {
                    GLib.Value val;
                    treemodel.get_value (iter, column, out val);
                    return val;
                }
            }

            return GLib.Value (GLib.Type.INVALID);
        }
    }

    // properties
    private global::Gtk.TreeModel m_TreeModel;

    // accessors
    public global::Gtk.TreeModel treemodel {
        get {
            return m_TreeModel;
        }
        construct set {
            if (m_TreeModel != null)
            {
                m_TreeModel.foreach(on_each_model_iter_remove);

                m_TreeModel.row_inserted.disconnect(on_row_inserted);
                m_TreeModel.row_changed.disconnect(on_row_changed);
                m_TreeModel.row_deleted.disconnect(on_row_deleted);
                m_TreeModel.rows_reordered.disconnect(on_rows_reordered);
            }
            m_TreeModel = value;
            if (m_TreeModel != null)
            {
                m_TreeModel.row_inserted.connect(on_row_inserted);
                m_TreeModel.row_changed.connect(on_row_changed);
                m_TreeModel.row_deleted.connect(on_row_deleted);
                m_TreeModel.rows_reordered.connect(on_rows_reordered);

                m_TreeModel.foreach(on_each_model_iter_add);
            }
        }
    }

    // methods
    public Model (global::Gtk.TreeModel inTreeModel)
    {
        GLib.Object (treemodel: inTreeModel);
    }

    private void
    on_row_inserted (global::Gtk.TreePath inPath, global::Gtk.TreeIter inIter)
    {
        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            uint row = convert_tree_path_to_row (inPath);
            row_added (row);
        }
    }

    private void
    on_row_changed (global::Gtk.TreePath inPath, global::Gtk.TreeIter inIter)
    {
        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            uint row = convert_tree_path_to_row (inPath);
            row_changed (row);
        }
    }

    private void
    on_row_deleted (global::Gtk.TreePath inPath)
    {
        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            uint row = convert_tree_path_to_row (inPath);
            row_deleted (row);
        }
    }

    private void
    on_rows_reordered (global::Gtk.TreePath inPath, global::Gtk.TreeIter? inIter, int* inNewOrder)
    {
        unowned uint[]? new_order = (uint[]?)inNewOrder;
        if (new_order != null)
        {
            rows_reordered (new_order);
        }
    }

    private bool
    on_each_model_iter_remove (global::Gtk.TreeModel inModel, global::Gtk.TreePath inPath, global::Gtk.TreeIter inIter)
    {
        on_row_deleted (inPath);

        return false;
    }

    private bool
    on_each_model_iter_add(global::Gtk.TreeModel inModel, global::Gtk.TreePath inPath, global::Gtk.TreeIter inIter)
    {
        on_row_inserted (inPath, inIter);

        return false;
    }

    public global::Gtk.TreePath
    convert_row_to_tree_path (uint inRow)
    {
        return new global::Gtk.TreePath.from_string (@"$inRow");
    }

    public uint
    convert_tree_path_to_row (global::Gtk.TreePath inPath)
    {
        uint row = 0;

        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            row = (uint)inPath.get_indices()[0];
        }

        return row;
    }

    public bool
    convert_row_to_tree_iter (uint inRow, out global::Gtk.TreeIter outIter)
    {
        bool ret = false;
        outIter = global::Gtk.TreeIter ();

        if (m_TreeModel != null)
        {
            global::Gtk.TreePath path = convert_row_to_tree_path (inRow);
            ret = m_TreeModel.get_iter (out outIter, path);
        }

        return ret;
    }

    public bool
    convert_tree_iter_to_row (global::Gtk.TreeIter inIter, out uint outRow)
    {
        bool ret = false;
        outRow = 0;

        if (m_TreeModel != null)
        {
            global::Gtk.TreePath? path = m_TreeModel.get_path (inIter);
            outRow = convert_tree_path_to_row (path);
            ret = true;
        }

        return ret;
    }
}

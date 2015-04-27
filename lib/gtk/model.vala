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

internal class Maia.Gtk.Model : Maia.Model
{
    // types
    public class Column : Maia.Model.Column
    {
        // methods
        public Column (string inId)
        {
            GLib.Object (id: GLib.Quark.from_string (inId));
        }

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

        internal override void
        @set (uint inPath, GLib.Value inValue)
        {
            unowned global::Gtk.TreeModel treemodel = ((Model)model).treemodel;

            if (column >= 0 && treemodel != null && inPath < treemodel.iter_n_children(null))
            {
                global::Gtk.TreeIter iter;
                if (treemodel.get_iter_from_string (out iter, "%u".printf (inPath)))
                {
                    bool found = false;
                    while (!found)
                    {
                        if (treemodel is global::Gtk.ListStore)
                        {
                            ((global::Gtk.ListStore)treemodel).set_value (iter, column, inValue);
                            found = true;
                        }
                        else if (treemodel is global::Gtk.TreeStore)
                        {
                            ((global::Gtk.TreeStore)treemodel).set_value (iter, column, inValue);
                            found = true;
                        }
                        else if (treemodel is global::Gtk.TreeModelFilter)
                        {
                            var parentmodel = ((global::Gtk.TreeModelFilter)treemodel).child_model;
                            ((global::Gtk.TreeModelFilter)treemodel).convert_iter_to_child_iter (out iter, iter);
                            treemodel = parentmodel;
                        }
                        else if (treemodel is global::Gtk.TreeModelSort)
                        {
                            var parentmodel = ((global::Gtk.TreeModelSort)treemodel).child_model;
                            ((global::Gtk.TreeModelSort)treemodel).convert_iter_to_child_iter (out iter, iter);
                            treemodel = parentmodel;
                        }
                        else
                        {
                            found = true;
                        }
                    }
                }
            }
        }
    }

    // properties
    private global::Gtk.TreeModel m_TreeModel;
    private Model                 m_Model = null;
    private Maia.Model.FilterFunc m_FilterFunc;

    // accessors
    internal override uint nb_rows {
        get {
            return m_TreeModel != null ? (uint)m_TreeModel.iter_n_children (null) : 0;
        }
    }

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

    private uint
    convert_tree_path_to_row (global::Gtk.TreePath inPath)
    {
        uint row = 0;

        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            row = (uint)inPath.get_indices()[0];
        }

        return row;
    }

    private bool
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
            new_order.length = m_TreeModel.iter_n_children (inIter);
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

    private bool
    on_filter_func (global::Gtk.TreeModel inModel, global::Gtk.TreeIter inIter)
    {
        uint row = 0;

        if (inModel == m_Model.m_TreeModel && m_Model.convert_tree_iter_to_row (inIter, out row))
        {
            return m_FilterFunc (m_Model, row);
        }

        return false;
    }

    internal override void
    construct_model (Column[] inColumns)
    {
        int cpt = 0;

        GLib.Type[] columns = {};
        foreach (Column column in inColumns)
        {
            // Add column type
            columns += column.column_type;

            // Set column num
            column.column = cpt;

            // Add column to model
            add (column);

            cpt++;
        }

        treemodel = new global::Gtk.ListStore.newv (columns);
    }

    internal override void
    construct_model_filter (Maia.Model inModel, owned Maia.Model.FilterFunc inFunc)
        requires (inModel is Model)
    {
        // Set parent model
        m_Model = inModel as Model;

        // Get column
        foreach (var child in m_Model)
        {
            unowned Maia.Model.Column? column =  child as Maia.Model.Column;
            if (column != null)
            {
                add (new Maia.Model.Column.with_column (column.name, column.column));
            }
        }

        // Set filter func
        m_FilterFunc = (owned)inFunc;

        // Create filter model
        treemodel = new global::Gtk.TreeModelFilter (m_Model.m_TreeModel, null);

        // Set filter func
        (treemodel as global::Gtk.TreeModelFilter).set_visible_func (on_filter_func);
    }

    internal override bool
    append_row (out uint outRow)
    {
        unowned global::Gtk.TreeModel? model = m_TreeModel;
        global::Gtk.TreeIter iter;
        global::Gtk.TreeIter? parent_iter = null;
        bool found = false;

        outRow = 0;
        while (!found)
        {
            if (model is global::Gtk.ListStore)
            {
                ((global::Gtk.ListStore)model).append (out iter);
                return convert_tree_iter_to_row (iter, out outRow);
            }
            else if (model is global::Gtk.TreeStore)
            {
                ((global::Gtk.TreeStore)model).append (out iter, parent_iter);
                return convert_tree_iter_to_row (iter, out outRow);
            }
            else if (model is global::Gtk.TreeModelFilter)
            {
                var parentmodel = ((global::Gtk.TreeModelFilter)model).child_model;
                if (parent_iter == null)
                {
                    if (!parentmodel.get_iter (out parent_iter, ((global::Gtk.TreeModelFilter)model).virtual_root))
                    {
                        parent_iter = null;
                    }
                }
                else
                {
                    ((global::Gtk.TreeModelFilter)model).convert_iter_to_child_iter (out parent_iter, parent_iter);
                }
                model = parentmodel;
                found = true;
            }
            else if (treemodel is global::Gtk.TreeModelSort)
            {
                var parentmodel = ((global::Gtk.TreeModelSort)treemodel).child_model;
                treemodel = parentmodel;
            }
            else
            {
                found = true;
            }
        }

        return false;
    }

    internal override void
    remove_row (uint inPath)
    {
        unowned global::Gtk.TreeModel? model = m_TreeModel;
        global::Gtk.TreeIter iter;
        if (model.get_iter_from_string (out iter, "%u".printf (inPath)))
        {
            bool found = false;
            while (!found)
            {
                if (model is global::Gtk.ListStore)
                {
                    ((global::Gtk.ListStore)model).remove (iter);
                    found = true;
                }
                else if (model is global::Gtk.TreeStore)
                {
                    ((global::Gtk.TreeStore)model).remove (ref iter);
                    found = true;
                }
                else if (model is global::Gtk.TreeModelFilter)
                {
                    var parentmodel = ((global::Gtk.TreeModelFilter)model).child_model;
                    ((global::Gtk.TreeModelFilter)model).convert_iter_to_child_iter (out iter, iter);
                    model = parentmodel;
                }
                else if (model is global::Gtk.TreeModelSort)
                {
                    var parentmodel = ((global::Gtk.TreeModelSort)model).child_model;
                    ((global::Gtk.TreeModelSort)model).convert_iter_to_child_iter (out iter, iter);
                    model = parentmodel;
                }
                else
                {
                    found = true;
                }
            }
        }
    }

    internal override void
    set_valuesv (uint inRow, va_list inList)
    {
        global::Gtk.TreeIter iter;
        if (m_TreeModel.get_iter_from_string (out iter, "%u".printf (inRow)))
        {
            int[] columns = {};
            GLib.Value[] values = {};

            while (true)
            {
                // Get column name
                unowned string? columnName = inList.arg ();
                if (columnName == null)
                {
                    break;
                }
                // Get column
                unowned Column? column = find(GLib.Quark.from_string (columnName), false) as Column;
                if (column != null)
                {
                    // Get value
                    GLib.Type type_column = m_TreeModel.get_column_type (column.column);
                    GLib.Value val = GLib.Value (type_column);
                    string? error = null;
                    GLib.ValueCollect.get (ref val, inList, 0, ref error);
                    if (error == null)
                    {
                        values += val;
                        columns += column.column;
                    }
                }
            }

            // set values in tree model
            unowned global::Gtk.TreeModel? model = m_TreeModel;
            bool found = false;
            while (!found)
            {
                if (model is global::Gtk.ListStore)
                {
                    ((global::Gtk.ListStore)model).set_valuesv (iter, columns, values);
                    found = true;
                }
                else if (model is global::Gtk.TreeStore)
                {
                    ((global::Gtk.TreeStore)model).set_valuesv (iter, columns, values);
                    found = true;
                }
                else if (model is global::Gtk.TreeModelFilter)
                {
                    var parentmodel = ((global::Gtk.TreeModelFilter)model).child_model;
                    ((global::Gtk.TreeModelFilter)model).convert_iter_to_child_iter (out iter, iter);
                    model = parentmodel;
                }
                else if (model is global::Gtk.TreeModelSort)
                {
                    var parentmodel = ((global::Gtk.TreeModelSort)model).child_model;
                    ((global::Gtk.TreeModelSort)model).convert_iter_to_child_iter (out iter, iter);
                    model = parentmodel;
                }
                else
                {
                    found = true;
                }
            }
        }
    }
}

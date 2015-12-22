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

public class Maia.Model : Core.Object, Manifest.Element
{
    // types
    public class Column : Core.Object, Manifest.Element
    {
        // accessors
        internal string tag {
            get {
                return "Column";
            }
        }

        internal string         characters     { get; set; default = null; }
        internal string         style          { get; set; default = null; }
        internal string         manifest_path  { get; set; default = null; }
        internal Manifest.Theme manifest_theme { get; set; default = null; }

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
        public GLib.Type column_type { get; set; default = GLib.Type.INVALID; }

        // methods
        construct
        {
            // Add not dumpable attributes
            not_dumpable_attributes.insert ("name");
            not_dumpable_attributes.insert ("model");
            not_dumpable_attributes.insert ("column");
        }

        public Column (string inId)
        {
            GLib.Object (id: GLib.Quark.from_string (inId));
        }

        public Column.with_type (string inId, GLib.Type inType)
        {
            GLib.Object (id: GLib.Quark.from_string (inId));
            column_type = inType;
        }

        public Column.with_column (string inId, int inColumn)
        {
            GLib.Object (id: GLib.Quark.from_string (inId));
            column = inColumn;
        }

        internal override bool
        can_append_child (Core.Object inObject)
        {
            // column can not have childs
            return false;
        }

//~         internal string
//~         dump_attributes (string inPrefix)
//~         {
//~             return inPrefix + @"column-type: $(column_type.name ());\n";
//~         }

        public virtual string
        get_string_value (uint inPath)
        {
            GLib.Value val = GLib.Value(typeof(string));
            get(inPath).transform (ref val);
            return (string)val;
        }

        public virtual new GLib.Value
        @get (uint inPath)
        {
            return GLib.Value (column_type);
        }

        public virtual new void
        @set (uint inPath, GLib.Value inValue)
        {
        }
    }

    // delegate
    public delegate bool FilterFunc (Model inModel, uint inPath);

    // accessors
    internal string tag {
        get {
            return "Model";
        }
    }

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public virtual uint nb_rows {
        get {
            return 0;
        }
    }

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
        not_dumpable_attributes.insert ("nb-rows");
    }

    [CCode (sentinel = "NULL")]
    public Model (string inId, ...)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));

        va_list list = va_list ();
        Column[] columns = {};
        while (true)
        {
            // Get column name
            string? columnName = list.arg ();
            if (columnName == null)
            {
                break;
            }

            // Get column type
            GLib.Type type = list.arg ();
            if (type == GLib.Type.INVALID)
            {
                break;
            }

            // Create column
            columns += new Column.with_type (columnName, type);
        }
        if (columns.length > 0)
        {
            construct_model_with_columns (columns);
        }
    }

    public Model.with_columns (string inId, Column[] inColumns)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));

        construct_model_with_columns (inColumns);
    }

    [CCode (sentinel = "NULL")]
    public Model.foreign (string inId, ...)
    {
        va_list list = va_list ();

        this.foreignv (inId, list);
    }

    [CCode (sentinel = "NULL")]
    public Model.foreign_with_columns (string inId, Column[] inColumns, ...)
    {
        va_list list = va_list ();

        this.foreign_with_columnsv (inId, inColumns, list);
    }


    public Model.foreignv (string inId, va_list inList)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));

        while (true)
        {
            // Get property name
            unowned string? propertyName = inList.arg ();
            if (propertyName == null)
            {
                break;
            }

            // Search property
            unowned GLib.ParamSpec? param = get_class ().find_property (propertyName);
            if (param != null)
            {
                // Get value
                GLib.Value val = GLib.Value (param.value_type);
                string? error = null;
                GLib.ValueCollect.get (ref val, inList, 0, ref error);
                if (error == null)
                {
                    set_property (propertyName, val);
                }
            }
        }
    }

    public Model.foreign_with_columnsv (string inId, Column[] inColumns, va_list inList)
    {
        this.foreignv (inId, inList);

        foreach (unowned Column column in inColumns)
        {
            add (column);
        }
    }

    public Model.filter (string inId, Model inModel, owned FilterFunc inFunc)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));

        construct_model_filter (inModel, (owned)inFunc);
    }

    protected virtual void
    construct_model ()
    {

    }

    protected virtual void
    construct_model_with_columns (Column[] inColumns)
    {

    }

    protected virtual void
    construct_model_filter (Model inModel, owned FilterFunc inFunc)
    {
    }

    protected virtual void
    set_valuesv (uint inRow, va_list inList)
    {
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

    internal void
    on_finish_read_manifest ()
    {
        if (first () != null)
        {
            construct_model ();
        }
    }

    internal string
    dump_characters (string inPrefix)
    {
        string ret = "";

        if (nb_rows > 0)
        {
            ret += inPrefix + "[\n";
            for (int cpt = 0; cpt < nb_rows; ++cpt)
            {
                ret += inPrefix + @"\tRow.$(cpt) {\n";

                foreach (unowned Core.Object? child in this)
                {
                    unowned Column? column = child as Column;
                    if (column != null)
                    {
                        ret += inPrefix + @"\t\t$(column.name): $((string)this[column.name].get_string_value(cpt));\n";
                    }
                }
                ret += inPrefix + @"\t}\n";
            }
            ret += inPrefix + "]\n";
        }

        return ret;
    }

    public virtual bool
    append_row (out uint outPath)
    {
        outPath = 0;
        return false;
    }

    public virtual void
    remove_row (uint inPath)
    {
    }

    public virtual void
    refilter ()
    {
    }

    [CCode (sentinel = "NULL")]
    public void
    set_values (uint inRow, ...)
    {
        va_list list = va_list ();
        set_valuesv (inRow, list);
    }

    public new unowned Column?
    @get (string inColumnName)
    {
        return find (GLib.Quark.from_string (inColumnName), false) as Column;
    }
}

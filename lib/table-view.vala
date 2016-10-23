/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * table-view-column.vala
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

public class Maia.TableView : Maia.Grid
{
    // types
    private class Row : Core.Object
    {
        // properties
        private unowned TableView                m_View;
        private uint                             m_Row;
        private Core.Array<unowned ItemPackable> m_Items;

        // accesors
        [CCode (notify = false)]
        public uint row {
            get {
                return m_Row;
            }
            set {
                if (m_Row != value)
                {
                    m_Row = value;

                    foreach (unowned ItemPackable item in m_Items)
                    {
                        item.row = m_Row + 1;
                    }
                }
            }
        }

        public Graphic.Region geometry {
            owned get {
                var ret = new Graphic.Region ();
                foreach (unowned ItemPackable item in m_Items)
                {
                    ret.union_ (item.geometry);
                }

                return ret;
            }
        }

        // methods
        public Row (TableView inView, uint inRow)
        {
            m_View = inView;
            m_Row = inRow;

            // Create row items
            m_Items = new Core.Array<unowned ItemPackable> ();
            int cpt = 0;
            foreach (unowned TableViewColumn column in m_View.view_columns)
            {
                ItemPackable? item = column.create_cell ();

                item.row = m_Row + 1;
                item.column = cpt;

                m_View.add (item);
                m_Items.insert (item);
                item.button_press_event.connect (on_item_button_press);
                item.button_release_event.connect (on_item_button_release);

                cpt++;
            }
        }

        ~Row ()
        {
            foreach (unowned Item item in m_Items)
            {
                item.button_press_event.disconnect (on_item_button_press);
                item.button_release_event.disconnect (on_item_button_release);
                item.parent = null;
            }
        }

        private bool
        on_item_button_press (Item inItem, uint inButton, Graphic.Point inPoint)
        {
            if (inButton == 1)
            {
                m_View.m_RowClicked = (int)row;
            }

            return true;
        }

        private bool
        on_item_button_release (Item inItem, uint inButton, Graphic.Point inPoint)
        {
            if (inButton == 1)
            {
                if (m_View.m_RowClicked == row)
                {
                    m_View.row_clicked (row);
                }

                m_View.m_RowClicked = -1;
            }

            return true;
        }

        internal override int
        compare (Core.Object inObject)
            requires (inObject is Row)
        {
            return (int)m_Row - (int)(inObject as Row).m_Row;
        }

        public new bool
        contains (ItemPackable item)
        {
            return item in m_Items;
        }

        public int
        compare_with_row (uint inRow)
        {
            return (int)m_Row - (int)inRow;
        }
    }

    // delegates
    public delegate bool SetPropertyFunc (GLib.Object inObject, string inProperty, string inColumnName, uint inRow);

    // properties
    private Model                       m_Model = null;
    private bool                        m_HideIfEmpty = false;
    internal unowned SetPropertyFunc    m_SetPropertyFunc = null;
    private int                         m_RowHightlighted = -1;
    private Core.Array<TableViewColumn> m_Columns = new Core.Array<TableViewColumn> ();
    private Core.Set<Row>               m_Rows = new Core.Set<Row> ();
    private int                         m_RowClicked = -1;

    // signals
    [HasEmitter]
    public signal void row_clicked (uint inRow);

    // accessors
    internal override string tag {
        get {
            return "TableView";
        }
    }

    public Model model {
        get {
            return m_Model;
        }
        set {
            if (m_Model != value)
            {
                if (m_Model != null)
                {
                    // Remove all rows
                    for (uint cpt = 0; cpt < m_Model.nb_rows; ++cpt)
                    {
                        m_Model.row_deleted (cpt);
                    }

                    m_Model.row_added.disconnect (on_row_added);
                    m_Model.row_deleted.disconnect (on_row_deleted);
                    m_Model.rows_reordered.disconnect (on_rows_reordered);
                }

                m_Model = value;

                foreach (unowned TableViewColumn column in m_Columns)
                {
                    column.model = m_Model;
                }

                if (m_Model != null)
                {
                    m_Model.row_added.connect (on_row_added);
                    m_Model.row_deleted.connect (on_row_deleted);
                    m_Model.rows_reordered.connect (on_rows_reordered);

                    // Add all row already inserted
                    for (uint cpt = 0; cpt < m_Model.nb_rows; ++cpt)
                    {
                        m_Model.row_added (cpt);
                    }
                }
            }
        }
    }

    public int highlighted_row {
        get {
            return m_RowHightlighted;
        }
        set {
            if (m_RowHightlighted != value)
            {
                m_RowHightlighted = value;
                damage.post ();
            }
        }
    }

    internal Core.Array<TableViewColumn> view_columns {
        get {
            return m_Columns;
        }
    }

    /**
     * If true hide view if model is empty
     */
    [CCode (notify = false)]
    public bool hide_if_model_empty {
        get {
            return m_HideIfEmpty;
        }
        set {
            if (m_HideIfEmpty != value)
            {
                m_HideIfEmpty = value;
                if (m_HideIfEmpty && visible && (m_Model == null || m_Model.nb_rows == 0))
                {
                    visible = false;
                    int count = get_qdata<int> (Item.s_CountHide);
                    count++;
                    set_qdata<int> (Item.s_CountHide, count);
                    not_dumpable_attributes.insert ("visible");
                }
                else if (!m_HideIfEmpty && !visible)
                {
                    int count = get_qdata<int> (Item.s_CountHide);
                    count = int.max (count - 1, 0);
                    if (count == 0)
                    {
                        visible = true;
                        not_dumpable_attributes.remove ("visible");
                    }
                    set_qdata<int> (Item.s_CountHide, count);
                }
            }
        }
    }

    /**
     * Header pattern
     */
    public Graphic.Pattern header_pattern { get; set; default = null; }

    // static methods
    static construct
    {
        // Ref Mpdel class to register model transform
        typeof (Model).class_ref ();
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("highlighted-row");

        // Add notifications
        notifications.add (new Manifest.Document.AttributeBindAddedNotification ("attribute-bind-added"));

        // connect onto item over pointer changed
        notify["item-over-pointer"].connect (on_pointer_over_changed);

        // set default layout
        layout = Grid.Layout.LINEAR;
    }

    public TableView (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_pointer_over_changed ()
    {
        if (m_RowHightlighted >= 0)
        {
            // Get current row highlighted
            unowned Row? row = m_Rows.search<uint> (m_RowHightlighted, Row.compare_with_row);

            // Item highlighted does not change
            if (item_over_pointer is ItemPackable && (item_over_pointer as ItemPackable) in row) return;

            // Unset highlighted item
            highlighted_row = -1;
        }

        // An item is over pointer
        if (item_over_pointer != null && item_over_pointer is ItemPackable)
        {
            // Search row of item over pointer
            foreach (unowned Row row in m_Rows)
            {
                if ((item_over_pointer as ItemPackable) in row)
                {
                    highlighted_row = (int)row.row;
                }
            }
        }
    }

    private void
    shift (uint inRow)
    {
        Core.List<Row> list = new Core.List<Row> ();
        foreach (unowned Row row in m_Rows)
        {
            list.insert (row);
        }

        m_Rows.clear ();
        foreach (unowned Row row in list)
        {
            if (row.row >= inRow)
            {
                row.row++;
            }
            m_Rows.insert (row);
        }
    }

    private void
    unshift (uint inRow)
    {
        Core.List<Row> list = new Core.List<Row> ();
        foreach (unowned Row row in m_Rows)
        {
            list.insert (row);
        }

        m_Rows.clear ();
        foreach (unowned Row row in list)
        {
            if (row.row > inRow)
            {
                row.row--;
            }
            m_Rows.insert (row);
        }
    }

    private void
    on_row_added (uint inRow)
    {
        if (m_HideIfEmpty && !visible)
        {
            int count = get_qdata<int> (Item.s_CountHide);
            count = int.max (count - 1, 0);

            if (count == 0)
            {
                visible = true;
                not_dumpable_attributes.remove ("visible");
            }
            set_qdata<int> (Item.s_CountHide, count);
        }

        // Shift current items
        shift (inRow);

        // Add new row
        m_Rows.insert (new Row (this, inRow));
    }

    private void
    on_row_deleted (uint inRow)
    {
        // Get item at row
        unowned Row? row = m_Rows.search<uint> (inRow, Row.compare_with_row);
        if (row != null)
        {
            // remove row
            m_Rows.remove (row);

            // unshift all siblings item
            unshift (inRow);

            if (m_HideIfEmpty && visible && m_Model.nb_rows == 0)
            {
                visible = false;
                int count = get_qdata<int> (Item.s_CountHide);
                count++;
                set_qdata<int> (Item.s_CountHide, count);
                not_dumpable_attributes.insert ("visible");
            }
        }
    }

    private void
    on_rows_reordered (uint[] inNewOrder)
    {
        Core.List<Row> list = new Core.List<Row> ();
        foreach (unowned Row row in m_Rows)
        {
            list.insert (row);
        }
        m_Rows.clear ();

        m_Rows.clear ();
        foreach (unowned Row row in list)
        {
            for (int cpt = 0; cpt < inNewOrder.length; ++cpt)
            {
                if (inNewOrder[cpt] != cpt && row.row == inNewOrder[cpt])
                {
                    row.row = cpt;
                }
            }
            m_Rows.insert (row);
        }
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (inObject is TableViewColumn)
        {
            unowned TableViewColumn column = inObject as TableViewColumn;
            column.model = m_Model;

            var header = column.header;
            header.row = 0;
            header.column = m_Columns.length;
            add (header);

            m_Columns.insert (column);

            m_Rows.clear ();
            if (m_Model != null)
            {
                for (uint cpt = 0; cpt < m_Model.nb_rows; ++cpt)
                {
                    on_row_added (cpt);
                }
            }
        }
        else
        {
            base.insert_child (inObject);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject is TableViewColumn)
        {
            unowned TableViewColumn column = inObject as TableViewColumn;
            m_Columns.remove (column);
            column.header.parent = null;

            m_Rows.clear ();
            if (m_Model != null)
            {
                for (uint cpt = 0; cpt < m_Model.nb_rows; ++cpt)
                {
                    on_row_added (cpt);
                }
            }
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        Graphic.Color color = fill_pattern[state] as Graphic.Color ?? new Graphic.Color (0.7, 0.7, 0.7);
        Graphic.Color shade = new Graphic.Color.shade (color, 0.6);

        if (header_pattern != null)
        {
            var col_geo = new Graphic.Region ();
            foreach (unowned TableViewColumn column in m_Columns)
            {
                col_geo.union_ (column.header.geometry);
            }


            var col_area = col_geo.extents;
            col_area.translate (Graphic.Point (0, -(row_spacing / 2.0)));
            col_area.resize (Graphic.Size (0, row_spacing));

            var path = new Graphic.Path.from_rectangle (col_area);
            inContext.pattern = header_pattern;
            inContext.fill (path);

            if (stroke_pattern[state] != null)
            {
                path = new Graphic.Path ();
                for (int cpt = 0; cpt < col_geo.length - 1; ++cpt)
                {
                    var rect = col_geo[cpt];
                    path.move_to (rect.origin.x + rect.size.width + (column_spacing / 2.0), col_area.origin.y);
                    path.line_to (rect.origin.x + rect.size.width + (column_spacing / 2.0), col_area.origin.y + col_area.size.height);
                }

                inContext.pattern = stroke_pattern[state];
                inContext.stroke (path);
            }
        }

        foreach (unowned Row row in m_Rows)
        {
            var row_geo = row.geometry;
            var row_area = row_geo.extents;
            row_area.translate (Graphic.Point (0, -(row_spacing / 2.0)));
            row_area.resize (Graphic.Size (0, row_spacing));

            if (row.row == m_RowHightlighted && fill_pattern[State.PRELIGHT] != null)
            {
                var path = new Graphic.Path.from_rectangle (row_area);
                inContext.pattern = fill_pattern[State.PRELIGHT];
                inContext.fill (path);
            }
            else
            {
                var path = new Graphic.Path.from_rectangle (row_area);
                inContext.pattern = (row.row % 2) == 0 ? color : shade;
                inContext.fill (path);
            }

            if (stroke_pattern[state] != null)
            {
                var path = new Graphic.Path ();
                for (int cpt = 0; cpt < row_geo.length - 2; ++cpt)
                {
                    var rect = row_geo[cpt];
                    path.move_to (rect.origin.x + rect.size.width + (column_spacing / 2.0), row_area.origin.y);
                    path.line_to (rect.origin.x + rect.size.width + (column_spacing / 2.0), row_area.origin.y + row_area.size.height);
                }

                inContext.pattern = stroke_pattern[state];
                inContext.stroke (path);
            }
        }

        base.paint (inContext, inArea);
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";
        foreach (unowned TableViewColumn column in m_Columns)
        {
            ret += inPrefix + column.dump (inPrefix) + "\n";
        }
        return ret;
    }

    public void
    set_property_func (SetPropertyFunc? inFunc)
    {
        m_SetPropertyFunc = inFunc;
    }

    public bool
    get_item_row (ItemPackable inItem, out uint outRow)
    {
        bool ret = false;

        outRow = 0;

        // Search row of item over pointer
        foreach (unowned Row row in m_Rows)
        {
            if (inItem in row)
            {
                outRow = row.row;
                ret = true;
                break;
             }
        }

        return ret;
    }
}

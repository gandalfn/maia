/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * grid.vala
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

public class Maia.Grid : Group, ItemPackable, ItemMovable
{
    // types
    private struct LineSizeAllocation
    {
        public Graphic.Size size;
        public uint nb_expands;
        public uint nb_shrinks;
    }

    private struct SizeAllocation
    {
        public unowned Grid grid;
        LineSizeAllocation[] rows;
        LineSizeAllocation[] columns;
        Graphic.Size size;
        Graphic.Rectangle[,] child_allocations;

        public SizeAllocation (Grid inGrid)
        {
            grid = inGrid;

            rows = {};
            columns = {};

            uint nb_rows = 0;
            uint nb_columns = 0;

            foreach (unowned Core.Object child in inGrid)
            {
                if (child is ItemPackable)
                {
                    unowned ItemPackable item = (ItemPackable)child;
                    Graphic.Size item_size = item.size;

                    // count the number of rows
                    nb_rows = uint.max (nb_rows, item.row + 1);

                    // count the number of columns
                    nb_columns = uint.max (nb_columns, item.column + 1);

                    // resize arrays
                    if (item.rows > 1) nb_rows = uint.max (nb_rows, item.row + item.rows);
                    if (item.columns > 1) nb_columns = uint.max (nb_columns, item.column + item.columns);

                    if (rows.length < nb_rows) rows.resize ((int)nb_rows);
                    if (columns.length < nb_columns) columns.resize ((int)nb_columns);

                    // cumulate the width of all rows
                    rows[item.row].size.width += (item_size.width / item.columns) + item.left_padding + item.right_padding;
                    // keep the max height of row
                    rows[item.row].size.height = double.max (rows[item.row].size.height, (item_size.height / item.rows) + item.top_padding + item.bottom_padding);

                    // keep the max width of columns
                    columns[item.column].size.width = double.max (columns[item.column].size.width, (item_size.width / item.columns) + item.left_padding + item.right_padding);
                    // cumulate the height of all columns
                    columns[item.column].size.height += (item_size.height / item.rows) + item.top_padding + item.bottom_padding;

                    // count the number of xexpand in row
                    rows[item.row].nb_expands += item.xexpand ? 1 : 0;
                    // count the number of shrink in row
                    rows[item.row].nb_shrinks += item.xshrink ? 1 : 0;
                    // count the number of yexpand in column
                    columns[item.column].nb_expands += item.yexpand ? 1 : 0;
                    // count the number of yexpand in column
                    columns[item.column].nb_shrinks += item.yshrink ? 1 : 0;

                    if (item.columns > 1)
                    {
                        for (int cpt = 1; cpt < item.columns; ++cpt)
                        {
                            rows[item.row].size.width += (item_size.width / item.columns);
                            rows[item.row].nb_expands += item.xexpand ? 1 : 0;

                            columns[item.column + cpt].size.width = double.max (columns[item.column + cpt].size.width,
                                                                                columns[item.column].size.width + item.left_padding + item.right_padding);
                            columns[item.column + cpt].size.height += (item_size.height / item.rows) + item.top_padding + item.bottom_padding;
                            columns[item.column + cpt].nb_expands += item.yexpand ? 1 : 0;
                        }
                    }

                    if (item.rows > 1)
                    {
                        for (int cpt = 1; cpt < item.rows; ++cpt)
                        {
                            rows[item.row + cpt].size.width += (item_size.width / item.columns) + item.left_padding + item.right_padding;
                            rows[item.row + cpt].size.height = double.max (rows[item.row + cpt].size.height,
                                                                           rows[item.row].size.height + item.top_padding + item.bottom_padding);
                            rows[item.row + cpt].nb_expands += item.xexpand ? 1 : 0;

                            columns[item.column].size.height += (item_size.height / item.rows);
                            columns[item.column].nb_expands += item.yexpand ? 1 : 0;
                        }
                    }
                }
            }

            // Get max size
            Graphic.Size max = Graphic.Size (0, 0);

            if (grid.homogeneous)
            {
                // Search the max height of row
                foreach (LineSizeAllocation row in rows)
                {
                    max.height = double.max (max.height, row.size.height);
                }
                // Search the max width of column
                foreach (LineSizeAllocation column in columns)
                {
                    max.width = double.max (max.width, column.size.width);
                }

                // size is the max size of cell * dimension
                size = Graphic.Size ((max.width * columns.length) + (grid.column_spacing * (columns.length - 1)),
                                     (max.height * rows.length) + (grid.row_spacing * (rows.length - 1)));

            }
            else
            {
                size = Graphic.Size (0, 0);

                // the maximal width size is the max width row
                foreach (LineSizeAllocation row in rows)
                {
                    size.width = double.max (size.width, row.size.width);
                }
                if (columns.length > 1)
                {
                    size.width += grid.column_spacing * (columns.length - 1);
                }

                // the maximal height size is the max height column
                foreach (LineSizeAllocation column in columns)
                {
                    size.height = double.max (size.height, column.size.height);
                }
                if (rows.length > 1)
                {
                    size.height += grid.row_spacing * (rows.length - 1);
                }
            }

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s size : %s", grid.name, size.to_string ());
        }

        public void
        size_allocate (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s size allocation : %s", grid.name, inAllocation.extents.to_string ());

            if (rows.length > 0 || columns.length > 0)
            {
                // Get page break list
                unowned Core.List<Document.PageBreak>? page_breaks = grid.get_qdata<Core.List<Document.PageBreak>> (Document.s_PageBreakQuark);

                if (grid.homogeneous)
                {
                    Graphic.Rectangle allocation = inAllocation.extents;

                    child_allocations = new Graphic.Rectangle [rows.length, columns.length];
                    for (int i = 0; i < rows.length; ++i)
                    {
                        for (int j = 0; j < columns.length; ++j)
                        {
                            child_allocations[i, j].size.width = (allocation.size.width - (grid.column_spacing * (columns.length - 1))) / columns.length;
                            child_allocations[i, j].size.height = (allocation.size.height - (grid.row_spacing * (rows.length - 1))) / rows.length;

                            if (i > 0)
                                child_allocations[i, j].origin.y = child_allocations[i - 1, j].origin.y + grid.row_spacing + child_allocations[i - 1, j].size.height;
                            if (j > 0)
                                child_allocations[i, j].origin.x = child_allocations[i, j - 1].origin.x + grid.column_spacing + child_allocations[i, j - 1].size.width;
                        }
                    }

                    uint prev_row = 0;
                    double delta = 0.0;
                    foreach (unowned Core.Object child in grid)
                    {
                        if (child is ItemPackable)
                        {
                            unowned ItemPackable item = (ItemPackable)child;

                            // calculate allocation of item
                            allocation = Graphic.Rectangle (child_allocations[item.row, item.column].origin.x,
                                                            child_allocations[item.row, item.column].origin.y, 0, 0);

                            Graphic.Size item_size = item.size;

                            if (item.xfill)
                            {
                                allocation.size.width = child_allocations[item.row, item.column].size.width;
                            }
                            else
                            {
                                allocation.size.width = double.min (item_size.width, child_allocations[item.row, item.column].size.width);
                                allocation.origin.x += (child_allocations[item.row, item.column].size.width - item_size.width) * item.xalign;
                            }

                            if (item.yfill)
                            {
                                allocation.size.height = child_allocations[item.row, item.column].size.height;
                            }
                            else
                            {
                                allocation.size.height = double.min (item_size.height, child_allocations[item.row, item.column].size.height);
                                allocation.origin.y += (child_allocations[item.row, item.column].size.height - item_size.height) * item.yalign;
                            }

                            if (page_breaks != null)
                            {
                                double y = allocation.origin.y;

                                foreach (unowned Document.PageBreak? page_break in page_breaks)
                                {
                                    if (item.row >= page_break.row)
                                    {
                                        Graphic.Point origin = grid.convert_to_item_space (Graphic.Point (0, page_break.start));
                                        Graphic.Point final = grid.convert_to_item_space (Graphic.Point (0, page_break.end));

                                        if (item.row == page_break.row)
                                        {
                                            y = final.y;
                                            page_break.start = grid.convert_to_root_space (allocation.origin).y;
                                        }
                                        else
                                        {
                                            y = allocation.origin.y;
                                            y += final.y - origin.y;
                                        }
                                    }
                                }

                                if (y != allocation.origin.y)
                                    allocation.origin.y = y;
                            }

                            if (item.row > prev_row)
                            {
                                allocation.origin.y += delta;
                            }

                            // suppress padding from item allocation
                            allocation.origin.x += item.left_padding;
                            allocation.origin.y += item.top_padding;
                            allocation.size.width -= item.left_padding + item.right_padding;
                            allocation.size.height -= item.top_padding + item.bottom_padding;

                            // update item
                            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "update %s: %s", item.name, allocation.to_string ());
                            item.update (inContext, new Graphic.Region (allocation));

                            prev_row = item.row;

                            // item is a grid take its delta
                            unowned Grid? item_grid = item as Grid;
                            if (item_grid != null)
                            {
                                delta += item_grid.get_page_break_delta ();
                            }
                        }
                        else if (child is Item)
                        {
                            unowned Item item = (Item)child;
                            var item_position = item.position;
                            var item_size = item.size;
                            item.update (inContext, new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y,
                                                                                           item_size.width, item_size.height)));
                        }
                    }
                }
                else
                {
                    // Get natural size
                    Graphic.Size natural = Graphic.Size (0, 0);

                    uint nb_rows = 0, nb_columns = 0;
                    foreach (LineSizeAllocation row in rows)
                    {
                        natural.height += row.size.height;
                        if (row.size.height > 0) nb_columns++;
                    }

                    foreach (LineSizeAllocation column in columns)
                    {
                        natural.width += column.size.width;
                        if (column.size.width > 0) nb_rows++;
                    }

                    Graphic.Rectangle allocation = inAllocation.extents;

                    // Calculate the the size of shrink
                    double xshrink = 0;
                    if (grid.xshrink)
                        xshrink = double.max (natural.width - allocation.size.width, 0);

                    double yshrink = 0;
                    if (grid.yshrink)
                        yshrink = double.max (natural.height - allocation.size.height, 0);

                    // Calculate the the size of padding
                    double xpadding = double.max (allocation.size.width - natural.width, 0);
                    double spacing_column = double.max (grid.column_spacing * (nb_columns - 1), 0);
                    double spacing_row = double.max (grid.column_spacing * (nb_columns - 1), 0);
                    if (nb_columns > 1 && xpadding > spacing_column)
                        xpadding -= spacing_column;
                    double ypadding = double.max (allocation.size.height - natural.height, 0);
                    if (nb_rows > 1 && ypadding > spacing_row)
                        ypadding -= spacing_row;

                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s natural: %s padding: %g,%g", grid.name, natural.to_string (), xpadding, ypadding);

                    // append padding
                    child_allocations = new Graphic.Rectangle [rows.length, columns.length];
                    foreach (unowned Core.Object child in grid)
                    {
                        if (child is ItemPackable)
                        {
                            unowned ItemPackable item = (ItemPackable)child;

                            Graphic.Size extra = Graphic.Size (0, 0);

                            // calculate the extra space
                            if (item.xexpand)
                            {
                                extra.width += xpadding / rows[item.row].nb_expands;
                            }

                            if (item.yexpand)
                            {
                                extra.height += ypadding / columns[item.column].nb_expands;
                            }

                            // remove the shrink space
                            if (item.xshrink)
                            {
                                extra.width -= xshrink / rows[item.row].nb_shrinks;
                            }

                            if (item.yshrink)
                            {
                                extra.height -= yshrink / columns[item.column].nb_shrinks;
                            }

                            child_allocations[item.row, item.column].size.width = double.max (child_allocations[item.row, item.column].size.width,
                                                                                              columns[item.column].size.width + extra.width);

                            child_allocations[item.row, item.column].size.height = double.max (child_allocations[item.row, item.column].size.height,
                                                                                               rows[item.row].size.height + extra.height);

                            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s child %s extra: %s", grid.name, item.name, extra.to_string ());
                            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s child %s row: %g, column: %g", grid.name, item.name, columns[item.column].size.width, rows[item.row].size.height);
                            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s child %s rows %u columns %u allocation: %s", grid.name, item.name, item.rows, item.columns, child_allocations[item.row, item.column].to_string ());
                        }
                    }

                    // Update childs
                    uint prev_row = 0;
                    double delta = 0.0;
                    foreach (unowned Core.Object child in grid)
                    {
                        if (child is ItemPackable)
                        {
                            unowned ItemPackable item = (ItemPackable)child;

                            // calculate size of multiple columns
                            if (item.columns > 1)
                            {
                                for (int cpt = 1; cpt < item.columns; ++cpt)
                                {
                                    child_allocations[item.row, item.column + cpt].size.width = double.max (child_allocations[item.row, item.column + cpt].size.width,
                                                                                                            child_allocations[item.row, item.column].size.width);
                                    child_allocations[item.row, item.column + cpt].size.height = double.max (child_allocations[item.row, item.column + cpt].size.height,
                                                                                                             child_allocations[item.row, item.column].size.height);
                                }
                            }

                            // calculate size of multiple rows
                            if (item.rows > 1)
                            {
                                for (int cpt = 1; cpt < item.rows; ++cpt)
                                {
                                    child_allocations[item.row + cpt, item.column].size.width = double.max (child_allocations[item.row + cpt, item.column].size.width,
                                                                                                            child_allocations[item.row, item.column].size.width);
                                    child_allocations[item.row + cpt, item.column].size.height = double.max (child_allocations[item.row + cpt, item.column].size.height,
                                                                                                             child_allocations[item.row, item.column].size.height);
                                }
                            }

                            // calculate position
                            if (item.row > 0)
                            {
                                child_allocations[item.row, item.column].origin.y = grid.row_spacing + child_allocations[item.row - 1, item.column].origin.y + child_allocations[item.row - 1, item.column].size.height;
                            }

                            if (item.column > 0)
                            {
                                child_allocations[item.row, item.column].origin.x = grid.column_spacing + child_allocations[item.row, item.column - 1].origin.x + child_allocations[item.row, item.column - 1].size.width;
                            }

                            if (item.columns > 1)
                            {
                                for (int cpt = 1; cpt < item.columns; ++cpt)
                                {
                                    child_allocations[item.row, item.column + cpt].origin.x = grid.column_spacing + child_allocations[item.row, item.column + cpt - 1].origin.x + child_allocations[item.row, item.column + cpt - 1].size.width;
                                    child_allocations[item.row, item.column + cpt].origin.y = child_allocations[item.row, item.column + cpt - 1].origin.y;
                                }
                            }

                            if (item.rows > 1)
                            {
                                for (int cpt = 1; cpt < item.rows; ++cpt)
                                {
                                    child_allocations[item.row + cpt, item.column].origin.x = child_allocations[item.row + cpt - 1, item.column].origin.x;
                                    child_allocations[item.row + cpt, item.column].origin.y = grid.row_spacing + child_allocations[item.row + cpt - 1, item.column].origin.y + child_allocations[item.row + cpt - 1, item.column].size.height;
                                }
                            }

                            Graphic.Rectangle area = child_allocations[item.row, item.column];

                            // If item is under multiple row add height of each row
                            if (item.rows > 1)
                            {
                                for (int cpt = 1; cpt < item.rows; ++cpt)
                                {
                                    area.size.height += grid.row_spacing + child_allocations[item.row + cpt, item.column].size.height;
                                }
                            }

                            // If item is under multiple columns add width of each column
                            if (item.columns > 1)
                            {
                                for (int cpt = 1; cpt < item.columns; ++cpt)
                                {
                                    area.size.width += grid.column_spacing + child_allocations[item.row, item.column + cpt].size.width;
                                }
                            }

                            // calculate allocation of item
                            allocation = Graphic.Rectangle (area.origin.x, area.origin.y, 0, 0);

                            Graphic.Size item_size = item.size_requested;

                            if (page_breaks != null)
                            {
                                double y = allocation.origin.y;

                                foreach (unowned Document.PageBreak? page_break in page_breaks)
                                {
                                    if (item.row >= page_break.row)
                                    {
                                        Graphic.Point origin = grid.convert_to_item_space (Graphic.Point (0, page_break.start));
                                        Graphic.Point final = grid.convert_to_item_space (Graphic.Point (0, page_break.end));

                                        if (item.row == page_break.row)
                                        {
                                            y = final.y;
                                            page_break.start = grid.convert_to_root_space (allocation.origin).y;
                                        }
                                        else
                                        {
                                            y = allocation.origin.y;
                                            y += final.y - origin.y;
                                        }
                                    }
                                }

                                if (y != allocation.origin.y)
                                    allocation.origin.y = y;
                            }

                            if (item.row > prev_row)
                            {
                                allocation.origin.y += delta;
                            }

                            if (item.xfill)
                            {
                                allocation.size.width = area.size.width - item.left_padding - item.right_padding;
                                allocation.origin.x += item.left_padding;
                            }
                            else if (item.xexpand)
                            {
                                if (item.xshrink)
                                    allocation.size.width = double.min (item_size.width, area.size.width - item.left_padding - item.right_padding);
                                else
                                    allocation.size.width = item_size.width;

                                allocation.origin.x += item.left_padding + ((area.size.width - item.left_padding - item.right_padding) - allocation.size.width) * item.xalign;
                            }
                            else
                            {
                                if (item.xshrink)
                                    allocation.size.width = double.min (item_size.width, area.size.width - item.left_padding - item.right_padding);
                                else
                                    allocation.size.width = item_size.width;
                                allocation.origin.x += item.left_padding;
                            }

                            if (item.yfill)
                            {
                                allocation.size.height = area.size.height - item.top_padding - item.bottom_padding;
                                allocation.origin.y += item.top_padding;
                            }
                            else if (item.yexpand)
                            {
                                if (item.yshrink)
                                    allocation.size.height = double.min (item_size.height, area.size.height - item.top_padding - item.bottom_padding);
                                else
                                    allocation.size.height = item_size.height;

                                allocation.origin.y += item.top_padding + ((area.size.height - item.top_padding - item.bottom_padding) - allocation.size.height) * item.yalign;
                            }
                            else
                            {
                                if (item.yshrink)
                                    allocation.size.height = double.min (item_size.height, area.size.height - item.top_padding - item.bottom_padding);
                                else
                                    allocation.size.height = item_size.height;
                                allocation.origin.y += item.top_padding;
                            }

                            // update item
                            Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "update %s: %s", item.name, allocation.to_string ());
                            item.update (inContext, new Graphic.Region (allocation));

                            prev_row = item.row;

                            // item is a grid take its delta
                            unowned Grid? item_grid = item as Grid;
                            if (item_grid != null)
                            {
                                delta += item_grid.get_page_break_delta ();
                            }
                        }
                        else if (child is Item)
                        {
                            unowned Item item = (Item)child;
                            var item_position = item.position;
                            var item_size = item.size;
                            item.update (inContext, new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y,
                                                                                           item_size.width, item_size.height)));
                        }
                    }
                }
            }
        }

        public bool
        get_row_area (uint inRow, out Graphic.Rectangle outArea)
        {
            bool ret = false;

            outArea = Graphic.Rectangle (0, 0, 0, 0);
            if (inRow < rows.length && child_allocations != null)
            {
                outArea.origin = child_allocations[inRow, 0].origin;
                for (int cpt = 0; cpt < columns.length; ++cpt)
                {
                    outArea.size.width += child_allocations[inRow, cpt].size.width;
                    outArea.size.height = double.max (outArea.size.height, child_allocations[inRow, cpt].size.height);
                }

                ret = true;
            }
            return ret;
        }

        public bool
        get_row_size (uint inRow, out Graphic.Size outSize)
        {
            bool ret = false;

            outSize = Graphic.Size (0, 0);
            if (inRow < rows.length)
            {
                outSize.height = double.max (outSize.height, rows[inRow].size.height);
                for (int cpt = 0; cpt < columns.length; ++cpt)
                {
                    outSize.width += columns[cpt].size.width;
                }

                ret = true;
            }
            return ret;
        }
    }

    // properties
    SizeAllocation m_Allocation;

    // accessors
    internal override string tag {
        get {
            return "Grid";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    public bool   homogeneous       { get; set; default = false; }
    public double row_spacing       { get; set; default = 0; }
    public double column_spacing    { get; set; default = 0; }

    public double border_line_width { get; set; default = 0; }
    public double grid_line_width   { get; set; default = 0; }

    // methods
    public Grid (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is ItemPackable || inObject is ToggleGroup || inObject is Model || inObject is Popup;
    }

    private double
    get_page_break_delta ()
    {
        double ret = 0;

        unowned Core.List<Document.PageBreak>? page_breaks = get_qdata<unowned Core.List<Document.PageBreak>> (Document.s_PageBreakQuark);
        if (page_breaks != null)
        {
            foreach (unowned Document.PageBreak page_break in page_breaks)
            {
                var start = convert_to_item_space (Graphic.Point (0, page_break.start));
                var end = convert_to_item_space (Graphic.Point (0, page_break.end));

                ret = end.y - start.y;
            }
        }

        foreach (unowned Core.Object child in this)
        {
            unowned Grid? grid = child as Grid;
            if (grid != null)
            {
                ret += grid.get_page_break_delta ();
            }
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "%s allocation: %s", name, inAllocation.extents.to_string ());

            // Set geometry
            geometry = inAllocation;

            // Allocate each childs
            m_Allocation.size_allocate (inContext, inAllocation);

            // Some child delta exist add it to geometry
            double delta = get_page_break_delta ();
            if (delta > 0)
            {
                var s = inAllocation.extents.size;
                s.resize (0, delta);
                geometry.resize (s);
            }

            damage ();
        }
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        m_Allocation = SizeAllocation (this);

        Graphic.Size ret = Graphic.Size (double.max (m_Allocation.size.width, inSize.width),
                                         double.max (m_Allocation.size.height, inSize.height));

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint childs
        Graphic.Path grid = new Graphic.Path ();
        foreach (unowned Core.Object child in this)
        {
            if (child is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)child;

                item.draw (inContext);

                if (item.row < m_Allocation.child_allocations.length[0] &&
                    item.column < m_Allocation.child_allocations.length[1])
                {
                    // paint grid
                    Graphic.Region area = new Graphic.Region (m_Allocation.child_allocations[item.row, item.column]);
                    if (item.columns > 0)
                    {
                        for (int cpt = 1; cpt < item.columns; ++cpt)
                        {
                            area.union_with_rect (m_Allocation.child_allocations[item.row, item.column + cpt]);
                        }
                    }

                    if (item.rows > 0)
                    {
                        for (int cpt = 1; cpt < item.rows; ++cpt)
                        {
                            area.union_with_rect (m_Allocation.child_allocations[item.row + cpt, item.column]);
                        }
                    }

                    grid.rectangle (area.extents.origin.x, area.extents.origin.y,
                                    area.extents.size.width, area.extents.size.height);
                }
            }
            else if (child is Item)
            {
                unowned Item item = (Item)child;
                item.draw (inContext);
            }
        }

        // paint grid
        if (stroke_pattern != null)
        {
            if (grid_line_width > 0)
            {
                inContext.pattern = stroke_pattern;
                inContext.line_width = grid_line_width;
                inContext.stroke (grid);
            }

            // paint border
            if (border_line_width > 0)
            {
                var area = geometry.copy ();
                area.translate (geometry.extents.origin.invert ());
                Graphic.Path path = new Graphic.Path.from_region (area);

                inContext.pattern = stroke_pattern;
                inContext.line_width = border_line_width;
                inContext.stroke (path);
            }
        }
    }

    internal bool
    get_row_area (uint inRow, out Graphic.Rectangle outArea)
    {
        return m_Allocation.get_row_area (inRow, out outArea);
    }

    internal bool
    get_row_size (uint inRow, out Graphic.Size outSize)
    {
        return m_Allocation.get_row_size (inRow, out outSize);
    }
}

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

        public LineSizeAllocation ()
        {
            size = Graphic.Size (0, 0);
            nb_expands = 0;
            nb_shrinks = 0;
        }
    }

    private struct SizeAllocation
    {
        public unowned Grid grid;
        LineSizeAllocation[] rows;
        LineSizeAllocation[] columns;
        Core.Set<uint> visible_rows;
        Core.Set<uint> visible_columns;
        Graphic.Size size;
        Graphic.Rectangle[,] child_allocations;

        public SizeAllocation (Grid inGrid)
        {
            grid = inGrid;

            rows = new LineSizeAllocation[1];
            columns = new LineSizeAllocation[1];

            visible_rows = new Core.Set<int> ();
            visible_columns = new Core.Set<int> ();

            uint nb_rows = 0;
            uint nb_columns = 0;

            foreach (unowned Core.Object child in inGrid)
            {
                if (child is ItemPackable)
                {
                    unowned ItemPackable item = (ItemPackable)child;

                    Graphic.Size item_size = item.size;

                    if (item.visible)
                    {
                        visible_rows.insert (item.row);
                        visible_columns.insert (item.column);

                        for (int cpt = 0; cpt < item.rows; ++cpt)
                        {
                            visible_rows.insert (item.row + cpt);
                        }
                        for (int cpt = 0; cpt < item.columns; ++cpt)
                        {
                            visible_columns.insert (item.column + cpt);
                        }
                    }

                    // count the number of rows
                    nb_rows = uint.max (nb_rows, item.row + 1);

                    // count the number of columns
                    nb_columns = uint.max (nb_columns, item.column + 1);

                    // resize arrays
                    if (item.rows > 1) nb_rows = uint.max (nb_rows, item.row + item.rows);
                    if (item.columns > 1) nb_columns = uint.max (nb_columns, item.column + item.columns);

                    if (rows.length < nb_rows)
                    {
                        rows.resize ((int)nb_rows);
                    }
                    if (columns.length < nb_columns)
                    {
                        columns.resize ((int)nb_columns);
                    }

                    // cumulate the width of all rows
                    if (item.visible || !item.xlimp)
                    {
                        rows[item.row].size.width += (item_size.width / item.columns) + item.left_padding + item.right_padding;
                    }

                    // keep the max height of row
                    if (item.visible || !item.ylimp)
                    {
                        rows[item.row].size.height = double.max (rows[item.row].size.height, (item_size.height / item.rows) + item.top_padding + item.bottom_padding);
                    }

                    // keep the max width of columns
                    if (item.visible || !item.xlimp)
                    {
                        columns[item.column].size.width = double.max (columns[item.column].size.width, (item_size.width / item.columns) + item.left_padding + item.right_padding);
                    }

                    // cumulate the height of all columns
                    if (item.visible || !item.ylimp)
                    {
                        columns[item.column].size.height += (item_size.height / item.rows) + item.top_padding + item.bottom_padding;
                    }

                    if (item.visible || !item.xlimp)
                    {
                        // count the number of xexpand in row
                        rows[item.row].nb_expands += item.xexpand ? 1 : 0;
                        // count the number of shrink in row
                        rows[item.row].nb_shrinks += item.xshrink ? 1 : 0;
                    }

                    if (item.visible || !item.ylimp)
                    {
                        // count the number of yexpand in column
                        columns[item.column].nb_expands += item.yexpand ? 1 : 0;
                        // count the number of yexpand in column
                        columns[item.column].nb_shrinks += item.yshrink ? 1 : 0;
                    }

                    if (item.columns > 1 && (item.visible || !item.xlimp))
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

                    if (item.rows > 1 && (item.visible || !item.ylimp))
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

            rows.length = (int)nb_rows;
            columns.length = (int)nb_columns;

            // Get max size
            Graphic.Size max = Graphic.Size (0, 0);

            if (grid.homogeneous)
            {
                for (int cpt = 0; cpt < rows.length || cpt < columns.length; ++cpt)
                {
                    if (cpt < rows.length) max.height = double.max (max.height, rows[cpt].size.height);
                    if (cpt < columns.length) max.width = double.max (max.width, columns[cpt].size.width);
                }

                // size is the max size of cell * dimension
                size = Graphic.Size ((max.width * columns.length) + (grid.column_spacing * (columns.length - 1)),
                                     (max.height * rows.length) + (grid.row_spacing * (rows.length - 1)));

            }
            else
            {
                size = Graphic.Size (0, 0);

                for (int cpt = 0; cpt < rows.length || cpt < columns.length; ++cpt)
                {
                    if (cpt < rows.length) size.height += rows[cpt].size.height;
                    if (cpt < columns.length) size.width += columns[cpt].size.width;;
                }

                // the maximal width size is the max width row
                if (visible_rows.length > 1)
                {
                    size.height += grid.row_spacing * (visible_rows.length - 1);
                }

                // the maximal height size is the max height column
                if (visible_columns.length > 1)
                {
                    size.width += grid.column_spacing * (visible_columns.length - 1);
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

                            if (item.row < rows.length && item.column < columns.length)
                            {
                                // calculate size of multiple columns
                                if (item.columns > 1)
                                {
                                    for (int cpt = 1; cpt < item.columns; ++cpt)
                                    {
                                        child_allocations[item.row, item.column].size.width += child_allocations[item.row, item.column + cpt].size.width;
                                    }
                                }

                                // calculate size of multiple rows
                                if (item.rows > 1)
                                {
                                    for (int cpt = 1; cpt < item.rows; ++cpt)
                                    {
                                        child_allocations[item.row, item.column].size.height += child_allocations[item.row + cpt, item.column].size.height;
                                    }
                                }

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

                                bool is_page_break = false;
                                if (page_breaks != null)
                                {
                                    double y = allocation.origin.y;

                                    foreach (unowned Document.PageBreak? page_break in page_breaks)
                                    {
                                        if (item.row >= page_break.row)
                                        {
                                            Graphic.Point origin = grid.convert_from_window_space (Graphic.Point (0, page_break.start));
                                            Graphic.Point final = grid.convert_from_window_space (Graphic.Point (0, page_break.end));

                                            if (item.row == page_break.row)
                                            {
                                                y = final.y;
                                                page_break.start = grid.convert_to_window_space (allocation.origin).y;
                                                is_page_break = true;
                                            }
                                            else
                                            {
                                                y = allocation.origin.y;
                                                y += final.y - origin.y;
                                                is_page_break = true;
                                            }
                                        }
                                    }

                                    if (y != allocation.origin.y)
                                        allocation.origin.y = y;
                                }

                                if (!is_page_break && item.row > prev_row)
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

                    for (int cpt = 0; cpt < rows.length || cpt < columns.length; ++cpt)
                    {
                        if (cpt < rows.length) natural.height += rows[cpt].size.height;
                        if (cpt < columns.length) natural.width += columns[cpt].size.width;
                    }
                    if (visible_rows.length > 1)
                    {
                        natural.height += grid.row_spacing * (visible_rows.length - 1);
                    }
                    if (visible_columns.length > 1)
                    {
                        natural.width += grid.column_spacing * (visible_columns.length - 1);
                    }

                    Graphic.Rectangle allocation = inAllocation.extents;

                    // Calculate the the size of shrink
                    double xshrink = 0;
                    if (grid.xshrink)
                        xshrink = double.max (natural.width - allocation.size.width, 0);

                    double yshrink = 0;
                    if (grid.yshrink)
                        yshrink = double.max (natural.height - allocation.size.height, 0);

                    // Calculate the the size of xpadding
                    double xpadding = double.max (allocation.size.width - natural.width, 0);

                    // Calculate the the size of ypadding
                    double ypadding = double.max (allocation.size.height - natural.height, 0);

                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s natural: %s padding: %g,%g", grid.name, natural.to_string (), xpadding, ypadding);

                    // append padding
                    child_allocations = new Graphic.Rectangle [rows.length, columns.length];
                    foreach (unowned Core.Object child in grid)
                    {
                        if (child is ItemPackable)
                        {
                            unowned ItemPackable item = (ItemPackable)child;

                            if (item.row < rows.length && item.column < columns.length)
                            {
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

                                if (grid.row_spacing > 0 && visible_rows.length > 1 && item.row in visible_rows)
                                {
                                    double spacing = grid.row_spacing;
                                    bool found_first = false;
                                    bool found_last = false;
                                    for (uint cpt = 0; !found_first && cpt < item.row; ++cpt)
                                    {
                                        found_first = cpt in visible_rows;
                                    }
                                    for (uint cpt = item.row + 1; !found_last && cpt < rows.length; ++cpt)
                                    {
                                        found_last = cpt in visible_rows;
                                    }
                                    if (!found_first || !found_last)
                                    {
                                        spacing /= 2;
                                    }
                                    extra.height += spacing;
                                }

                                if (grid.column_spacing > 0 && visible_columns.length > 1 && item.column in visible_columns)
                                {
                                    double spacing = grid.column_spacing;
                                    bool found_first = false;
                                    bool found_last = false;
                                    for (uint cpt = 0; !found_first && cpt < item.column; ++cpt)
                                    {
                                        found_first = cpt in visible_columns;
                                    }
                                    for (uint cpt = item.column + 1; !found_last && cpt < columns.length; ++cpt)
                                    {
                                        found_last = cpt in visible_columns;
                                    }
                                    if (!found_first || !found_last)
                                    {
                                        spacing /= 2;
                                    }
                                    extra.width += spacing;
                                }

                                if (item.visible || !item.xlimp)
                                {
                                    child_allocations[item.row, item.column].size.width = double.max (child_allocations[item.row, item.column].size.width,
                                                                                                      columns[item.column].size.width + extra.width);
                                }

                                if (item.visible || !item.ylimp)
                                {
                                    child_allocations[item.row, item.column].size.height = double.max (child_allocations[item.row, item.column].size.height,
                                                                                                       rows[item.row].size.height + extra.height);
                                }

                                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s child %s extra: %s", grid.name, item.name, extra.to_string ());
                                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s child %s row: %g, column: %g", grid.name, item.name, columns[item.column].size.width, rows[item.row].size.height);
                                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s child %s rows %u columns %u allocation: %s", grid.name, item.name, item.rows, item.columns, child_allocations[item.row, item.column].to_string ());
                            }
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

                            if (item.row < rows.length && item.column < columns.length)
                            {
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
                                    if (child_allocations[item.row - 1, item.column].size.height == 0)
                                    {
                                        bool found = false;
                                        for (int row = (int)item.row - 1; row > 0; --row)
                                        {
                                            if (child_allocations[row, item.column].size.height != 0)
                                            {
                                                child_allocations[item.row, item.column].origin.y = child_allocations[row, item.column].origin.y + child_allocations[row, item.column].size.height;
                                                child_allocations[row + 1, item.column].size.width = child_allocations[item.row, item.column].size.width;
                                                found = true;
                                                break;
                                            }
                                        }

                                        if (!found)
                                        {
                                            child_allocations[item.row, item.column].origin.y = child_allocations[0, item.column].origin.y + child_allocations[0, item.column].size.height;
                                            child_allocations[0, item.column].size.width = child_allocations[item.row, item.column].size.width;
                                        }
                                    }
                                    else
                                    {
                                        child_allocations[item.row, item.column].origin.y = child_allocations[item.row - 1, item.column].origin.y + child_allocations[item.row - 1, item.column].size.height;
                                    }
                                }

                                if (item.column > 0)
                                {
                                    if (child_allocations[item.row, item.column - 1].size.width == 0)
                                    {
                                        bool found = false;
                                        for (int column = (int)item.column - 1; column > 0; --column)
                                        {
                                            if (child_allocations[item.row, column].size.width != 0)
                                            {
                                                child_allocations[item.row, item.column].origin.x = child_allocations[item.row, column].origin.x + child_allocations[item.row, column].size.width;
                                                child_allocations[item.row, column + 1].size.height = child_allocations[item.row, item.column].size.height;
                                                found = true;
                                                break;
                                            }
                                        }

                                        if (!found)
                                        {
                                            child_allocations[item.row, item.column].origin.x = child_allocations[item.row, 0].origin.x + child_allocations[item.row, 0].size.width;
                                            child_allocations[item.row, 0].size.height = child_allocations[item.row, item.column].size.height;
                                        }
                                    }
                                    else
                                    {
                                        child_allocations[item.row, item.column].origin.x = child_allocations[item.row, item.column - 1].origin.x + child_allocations[item.row, item.column - 1].size.width;
                                    }
                                }

                                if (item.columns > 1)
                                {
                                    for (int cpt = 1; cpt < item.columns; ++cpt)
                                    {
                                        child_allocations[item.row, item.column + cpt].origin.x = child_allocations[item.row, item.column + cpt - 1].origin.x + child_allocations[item.row, item.column + cpt - 1].size.width;
                                        child_allocations[item.row, item.column + cpt].origin.y = child_allocations[item.row, item.column + cpt - 1].origin.y;
                                    }
                                }

                                if (item.rows > 1)
                                {
                                    for (int cpt = 1; cpt < item.rows; ++cpt)
                                    {
                                        child_allocations[item.row + cpt, item.column].origin.x = child_allocations[item.row + cpt - 1, item.column].origin.x;
                                        child_allocations[item.row + cpt, item.column].origin.y = child_allocations[item.row + cpt - 1, item.column].origin.y + child_allocations[item.row + cpt - 1, item.column].size.height;
                                    }
                                }

                                Graphic.Rectangle area = child_allocations[item.row, item.column];

                                double row_spacing = 0;
                                if (grid.row_spacing > 0 && rows.length > 1 && item.row in visible_rows)
                                {
                                    row_spacing = grid.row_spacing;
                                    bool found_first = false;
                                    bool found_last = false;
                                    for (uint cpt = 0; !found_first && cpt < item.row; ++cpt)
                                    {
                                        found_first = cpt in visible_rows;
                                    }
                                    for (uint cpt = item.row + 1; !found_last && cpt < rows.length; ++cpt)
                                    {
                                        found_last = cpt in visible_rows;
                                    }
                                    if (!found_first || !found_last)
                                    {
                                        row_spacing /= 2;
                                    }
                                    else
                                    {
                                        area.origin.y += row_spacing / 2;
                                    }
                                }

                                double column_spacing = 0;
                                if (grid.column_spacing > 0 && columns.length > 1 && item.column in visible_columns)
                                {
                                    column_spacing = grid.column_spacing;
                                    bool found_first = false;
                                    bool found_last = false;
                                    for (uint cpt = 0; !found_first && cpt < item.column; ++cpt)
                                    {
                                        found_first = cpt in visible_columns;
                                    }
                                    for (uint cpt = item.column + 1; !found_last && cpt < columns.length; ++cpt)
                                    {
                                        found_last = cpt in visible_columns;
                                    }
                                    if (!found_first || !found_last)
                                    {
                                        column_spacing /= 2;
                                    }
                                    else
                                    {
                                        area.origin.x += column_spacing / 2;
                                    }
                                }

                                area.size.width = double.max (area.size.width - column_spacing, 0);
                                area.size.height = double.max (area.size.height - row_spacing, 0);

                                // If item is under multiple row add height of each row
                                if (item.rows > 1)
                                {
                                    for (int cpt = 1; cpt < item.rows; ++cpt)
                                    {
                                        area.size.height += child_allocations[item.row + cpt, item.column].size.height - row_spacing;
                                    }
                                }

                                // If item is under multiple columns add width of each column
                                if (item.columns > 1)
                                {
                                    for (int cpt = 1; cpt < item.columns; ++cpt)
                                    {
                                        area.size.width += child_allocations[item.row, item.column + cpt].size.width - column_spacing;
                                    }
                                }

                                // calculate allocation of item
                                allocation = Graphic.Rectangle (area.origin.x, area.origin.y, 0, 0);

                                Graphic.Size item_size = item.size;
                                bool is_page_break = false;
                                if (page_breaks != null)
                                {
                                    double y = allocation.origin.y;

                                    foreach (unowned Document.PageBreak? page_break in page_breaks)
                                    {
                                        if (item.row >= page_break.row)
                                        {
                                            Graphic.Point origin = grid.convert_from_window_space (Graphic.Point (0, page_break.start));
                                            Graphic.Point final = grid.convert_from_window_space (Graphic.Point (0, page_break.end));

                                            if (item.row == page_break.row)
                                            {
                                                y = final.y;
                                                page_break.start = grid.convert_to_window_space (allocation.origin).y;
                                                is_page_break = true;
                                            }
                                            else
                                            {
                                                y = allocation.origin.y;
                                                y += final.y - origin.y;
                                                is_page_break = true;
                                            }
                                        }
                                    }

                                    if (y != allocation.origin.y)
                                    {
                                        allocation.origin.y = y;
                                    }
                                }

                                if (!is_page_break && item.row > prev_row)
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

                                    allocation.origin.x += item.left_padding + (double.max (0, area.size.width - item.left_padding - item.right_padding) - allocation.size.width) * item.xalign;
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

                                    allocation.origin.y += item.top_padding + (double.max (0, area.size.height - item.top_padding - item.bottom_padding) - allocation.size.height) * item.yalign;
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
                                if (item_grid != null && item_grid.visible)
                                {
                                    delta += item_grid.get_page_break_delta ();
                                }
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
    private SizeAllocation m_Allocation;

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
    internal bool   xshrink { get; set; default = true; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
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

    private double
    get_page_break_delta ()
    {
        double ret = 0;

        unowned Core.List<Document.PageBreak>? page_breaks = get_qdata<unowned Core.List<Document.PageBreak>> (Document.s_PageBreakQuark);
        if (page_breaks != null)
        {
            foreach (unowned Document.PageBreak page_break in page_breaks)
            {
                var start = convert_from_window_space (Graphic.Point (0, page_break.start));
                var end = convert_from_window_space (Graphic.Point (0, page_break.end));

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

    private void
    on_child_changed ()
    {
        need_update = true;
        geometry = null;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is ItemPackable || inObject is ToggleGroup || inObject is Model || inObject is Popup;
    }

    internal override void
    insert_child (Core.Object inChild)
    {
        base.insert_child (inChild);

        unowned ItemPackable? item = inChild as ItemPackable;
        if (item != null)
        {
            notify["row"].connect (on_child_changed);
            notify["column"].connect (on_child_changed);
            notify["xexpand"].connect (on_child_changed);
            notify["xfill"].connect (on_child_changed);
            notify["xalign"].connect (on_child_changed);
            notify["xshrink"].connect (on_child_changed);
            notify["xlimp"].connect (on_child_changed);
            notify["yexpand"].connect (on_child_changed);
            notify["yfill"].connect (on_child_changed);
            notify["yalign"].connect (on_child_changed);
            notify["yshrink"].connect (on_child_changed);
            notify["ylimp"].connect (on_child_changed);
        }
    }

    internal override void
    remove_child (Core.Object inChild)
    {
        unowned ItemPackable? item = inChild as ItemPackable;
        if (item != null)
        {
            notify["row"].disconnect (on_child_changed);
            notify["column"].disconnect (on_child_changed);
            notify["xexpand"].disconnect (on_child_changed);
            notify["xfill"].disconnect (on_child_changed);
            notify["xalign"].disconnect (on_child_changed);
            notify["xshrink"].disconnect (on_child_changed);
            notify["xlimp"].disconnect (on_child_changed);
            notify["yexpand"].disconnect (on_child_changed);
            notify["yfill"].disconnect (on_child_changed);
            notify["yalign"].disconnect (on_child_changed);
            notify["yshrink"].disconnect (on_child_changed);
            notify["ylimp"].disconnect (on_child_changed);
        }

        base.remove_child (inChild);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && m_Allocation.grid != null && (geometry == null || !geometry.equal (inAllocation)))
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

            damage_area ();
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
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
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

                if (item.damaged != null && !item.damaged.is_empty ())
                {
                    item.draw (inContext, area_to_child_item_space (item, inArea));

                    if (item.row < m_Allocation.child_allocations.length[0] && item.column < m_Allocation.child_allocations.length[1])
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

                        double row_spacing = 0;
                        if (this.row_spacing > 0 && m_Allocation.rows.length > 1)
                        {
                            row_spacing = this.row_spacing;
                            if (item.row == 0) row_spacing /= 2;
                            if (item.row == m_Allocation.rows.length - 1) row_spacing /= 2;
                        }

                        double column_spacing = 0;
                        if (this.column_spacing > 0 && m_Allocation.columns.length > 1)
                        {
                            column_spacing = this.column_spacing;
                            if (item.column == 0) column_spacing /= 2;
                            if (item.column == m_Allocation.columns.length - 1) column_spacing /= 2;
                        }

                        grid.rectangle (area.extents.origin.x, area.extents.origin.y,
                                        area.extents.size.width - column_spacing, area.extents.size.height - row_spacing);
                    }
                }
            }
            else if (child is Item)
            {
                unowned Item item = (Item)child;
                item.draw (inContext, area_to_child_item_space (item, inArea));
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
    get_row_size (uint inRow, out Graphic.Size outSize)
    {
        m_Allocation = SizeAllocation (this);
        return m_Allocation.get_row_size (inRow, out outSize);
    }
}

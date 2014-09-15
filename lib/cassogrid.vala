/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cassogrid.vala
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

public class Maia.CassoGrid : Group, ItemPackable, ItemMovable
{
    // types
    private struct Area
    {
        public unowned Cassowary.Box? box;
        public bool xexpand;
        public bool yexpand;
        public uint rows;
        public uint columns;
    }

    private struct SizeAllocation
    {
        public unowned CassoGrid  grid;
        public Cassowary.Box box;
        public Core.Array<Core.Array<Area?>> boxes;
        public Graphic.Size size;
        public uint[] row_nb_expands;
        public uint[] column_nb_expands;

        public SizeAllocation (CassoGrid inGrid)
        {
            uint max_row = 0, max_column = 0;

            // create expand arrays
            row_nb_expands = {};
            column_nb_expands = {};

            // create boxes array
            boxes = new Core.Array<Core.Array<Area?>> ();

            // set current grid
            grid = inGrid;

            try
            {
                // Create grid box allocation
                box = new Cassowary.Box (grid.name);
                box.set_position (Graphic.Point (0, 0));

                // Parse all child item
                foreach (unowned Core.Object child in grid)
                {
                    unowned ItemPackable item = child as ItemPackable;

                    if (item != null)
                    {
                        int row = (int)item.row;
                        int column = (int)item.column;
                        int rows = (int)item.rows;
                        int columns = (int)item.columns;

                        // Create item box allocation
                        var item_box = new Cassowary.Box (item.name);

                        // Set size request
                        item_box.set_size_request (item.size);

                        // Resize box array
                        if (boxes.length < row + 1)
                        {
                            while (boxes.length < row + 1)
                            {
                                boxes.insert (new Core.Array<Area?> ());
                            }
                        }
                        if (boxes[row].length < column + 1)
                        {
                            while (boxes[row].length < column + 1)
                            {
                                boxes[row].insert (null);
                            }
                        }

                        // Set current item box
                        boxes[row][column] = { item_box, item.xexpand, item.yexpand, rows, columns };

                        // Calculate bounds of grid
                        max_row = uint.max (max_row, row);
                        max_column = uint.max (max_column, column);

                        // Resize arrays of expand
                        if (row_nb_expands.length < row + 1) row_nb_expands.resize (row + 1);
                        if (column_nb_expands.length < column + 1) column_nb_expands.resize (column + 1);

                        // Set current expand
                        if (item.xexpand) row_nb_expands[row]++;
                        if (item.yexpand) column_nb_expands[column]++;

                        Cassowary.Box.Position position = Cassowary.Box.Position.FREE;

                        // Current item under first row attach to top of box allocation of grid
                        if (row == 0)
                        {
                            position |= Cassowary.Box.Position.TOP;
                        }
                        else
                        {
                            bool below_set = false, same_set = false;
                            for (int cpt = 1; !below_set && !same_set && row - cpt >= 0; ++cpt)
                            {
                                if (boxes[row - cpt] != null)
                                {
                                    // Set current item below item box on same column and previous row
                                    if (boxes[row - cpt][column] != null)
                                    {
                                        if (!below_set)
                                        {
                                            item_box.below (boxes[row - cpt][column].box, grid.row_spacing,
                                                            cpt == 1 ? Cassowary.Strength.required : Cassowary.Strength.strong);
                                            below_set = true;
                                        }
                                        if (rows == 1)
                                        {
                                            if (!same_set && boxes[row - cpt][column].columns == 1)
                                            {
                                                item_box.same_width (boxes[row - cpt][column].box);
                                                same_set = true;
                                            }
                                        }
                                        else
                                        {
                                            same_set = true;
                                        }
                                        break;
                                    }
                                }
                            }
                        }

                        // Current item under first column attach to left of box allocation of grid
                        if (column == 0)
                        {
                            position |= Cassowary.Box.Position.LEFT;
                        }
                        else
                        {
                            if (boxes[row] != null)
                            {
                                bool right_set = false, same_set = false;

                                for (int cpt = 1; !right_set && !same_set && column - cpt >= 0; ++cpt)
                                {
                                    // Set current item right of item box on same row and previous column
                                    if (boxes[row][column - cpt] != null)
                                    {
                                        if (!right_set)
                                        {
                                            item_box.right_of (boxes[row][column - cpt].box, grid.column_spacing);
                                            right_set = true;
                                        }

                                        if (columns == 1)
                                        {
                                            if (!same_set && boxes[row][column - cpt].rows == 1)
                                            {
                                                item_box.same_height (boxes[row][column - cpt].box);
                                                same_set = true;
                                            }
                                        }
                                        else
                                        {
                                            same_set = true;
                                        }

                                        break;
                                    }
                                }
                            }
                        }

                        // Add item box in allocation box
                        box.add_box (item_box, position);
                    }
                }

                // Parse all item box to attach box under last row, last column and set multiple columns/rows
                for (int row = 0; row < boxes.length; ++row)
                {
                    for (int column = 0; column < boxes[row].length; ++column)
                    {
                        // item box in last row attach to bottom of grid allocation box
                        if (row == max_row)
                        {
                            box.attach (boxes[row][column].box, Cassowary.Box.Position.BOTTOM);
                        }
                        // item box in last collumn attach to right of grid allocation box
                        if (column == max_column)
                        {
                            box.attach (boxes[row][column].box, Cassowary.Box.Position.RIGHT);
                        }

                        // box on multiple rows
                        if (boxes[row][column].rows > 1)
                        {
                            uint rows = boxes[row][column].rows;

                            // Search the most nearest box to set above of
                            if (boxes.length > row + rows)
                            {
                                unowned Cassowary.Box? under = null;

                                // item box in last row attach to bottom of grid allocation box
                                if (row + rows - 1 == max_row)
                                {
                                    box.attach (boxes[row][column].box, Cassowary.Box.Position.BOTTOM);
                                }
                                // A box is available at row + rows and same column
                                else if (boxes[(int)row + (int)rows].length > column && boxes[(int)row + (int)rows][(int)column] != null)
                                {
                                    under = boxes[(int)row + (int)rows][(int)column].box;
                                }
                                else
                                {
                                    // Check of column before this column
                                    if (column > 0)
                                    {
                                        for (int cpt = column - 1; cpt >= 0; --cpt)
                                        {
                                            if (boxes[(int)row + (int)rows][cpt] != null)
                                            {
                                                under = boxes[(int)row + (int)rows][cpt].box;
                                                break;
                                            }
                                        }
                                    }

                                    // Check of column after this column
                                    if (under == null)
                                    {
                                        for (int cpt = column + 1; cpt < boxes[(int)row + (int)rows].length; ++cpt)
                                        {
                                            if (boxes[(int)row + (int)rows][cpt] != null)
                                            {
                                                under = boxes[(int)row + (int)rows][cpt].box;
                                                break;
                                            }
                                        }
                                    }
                                }

                                // we found a box set this box above
                                if (under != null)
                                {
                                    boxes[(int)row][(int)column].box.above (under, grid.row_spacing);
                                }

                                // Add nb expand
                                if (boxes[(int)row][(int)column].xexpand)
                                {
                                    for (int cpt = row + 1; cpt < row_nb_expands.length && cpt < row + rows; ++cpt)
                                    {
                                        row_nb_expands[cpt]++;
                                    }
                                }

                                // set right of column - 1 item rows
                                if (column > 0)
                                {
                                    for (int cpt = row + 1; cpt < boxes.length && cpt < row + rows; ++cpt)
                                    {
                                        if (boxes[cpt].length > column - 1 && boxes[cpt][(int)column - 1].box != null)
                                        {
                                            boxes[(int)row][(int)column].box.right_of (boxes[cpt][(int)column - 1].box, grid.column_spacing);
                                        }
                                    }
                                }

                                // set left of column + 1 item rows
                                if (column + 1 < max_column)
                                {
                                    for (int cpt = row + 1; cpt < boxes.length && cpt < row + rows; ++cpt)
                                    {
                                        if (boxes[cpt].length > column + 1 && boxes[cpt][(int)column + 1].box != null)
                                        {
                                            boxes[(int)row][(int)column].box.left_of (boxes[cpt][(int)column + 1].box, grid.column_spacing);
                                        }
                                    }
                                }
                            }
                        }

                        // box on multiple columns
                        if (boxes[(int)row][(int)column].columns > 1)
                        {
                            uint columns = boxes[(int)row][(int)column].columns;
                            unowned Cassowary.Box? right = null;

                            // item box in last column attach to right of grid allocation box
                            if (column + columns - 1 == max_column)
                            {
                                box.attach (boxes[row][column].box, Cassowary.Box.Position.RIGHT);
                            }
                            // A box is available at column + columns and same row
                            else if (boxes[(int)row].length > column + columns)
                            {
                                right = boxes[(int)row][(int)column + (int)columns].box;
                            }
                            else
                            {
                                // Check of row before this row
                                if (row > 0)
                                {
                                    for (int cpt = row - 1; cpt >= 0; --cpt)
                                    {
                                        if (boxes[cpt].length > column + columns && boxes[cpt][(int)column + (int)columns] != null)
                                        {
                                            right = boxes[cpt][(int)column + (int)columns].box;
                                            break;
                                        }
                                    }
                                }

                                // Check of row after this row
                                if (right == null)
                                {
                                    for (int cpt = row + 1; cpt < boxes.length; ++cpt)
                                    {
                                        if (boxes[cpt].length > column + columns && boxes[cpt][(int)column + (int)columns] != null)
                                        {
                                            right = boxes[cpt][(int)column + (int)columns].box;
                                            break;
                                        }
                                    }
                                }
                            }

                            if (right != null)
                            {
                                boxes[(int)row][(int)column].box.left_of (right, grid.column_spacing);
                            }

                            // Add nb expand
                            if (boxes[(int)row][(int)column].yexpand)
                            {
                                for (int cpt = column + 1; cpt < column_nb_expands.length && cpt < column + columns; ++cpt)
                                {
                                    column_nb_expands[cpt]++;
                                }
                            }

                            // set below row -1 item columns
                            if (row > 0)
                            {
                                for (int cpt = column + 1; cpt < boxes[(int)row - 1].length && cpt < column + columns; ++cpt)
                                {
                                    if (boxes[(int)row - 1][cpt].box != null)
                                    {
                                        boxes[(int)row][(int)column].box.below (boxes[(int)row - 1][cpt].box, grid.row_spacing);
                                    }
                                }
                            }

                            // set above row + 1 columns
                            if (row + 1 < boxes.length)
                            {
                                for (int cpt = column + 1; cpt < boxes[(int)row + 1].length && cpt < column + columns; ++cpt)
                                {
                                    if (boxes[(int)row + 1][cpt].box != null)
                                    {
                                        boxes[(int)row][(int)column].box.above (boxes[(int)row + 1][cpt].box, grid.row_spacing);
                                    }
                                }
                            }
                        }
                    }
                }

                // Build constraints for grid allocation box
                var solver = new Cassowary.SimplexSolver ();
                solver.auto_solve = false;
                box.build_constraints (solver);
                solver.solve ();

                // Keep size of allocation which is size requested
                size = box.size;

                // Set size request of box
                box.set_size_request (size);
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"grid $(grid.name) size request error: $(err.message)");
            }

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s size : %s", grid.name, size.to_string ());
        }

        public void
        size_allocate (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "grid %s size allocation : %s", grid.name, inAllocation.extents.to_string ());

            try
            {
                // Parse all box item allocation
                for (int row = 0; row < boxes.length; ++row)
                {
                    for (int column = 0; column < boxes[row].length; ++column)
                    {
                        double xexpand = (inAllocation.extents.size.width - size.width) / (double)row_nb_expands[row];
                        double yexpand = (inAllocation.extents.size.height - size.height) / (double)column_nb_expands[column];

                        // Set the expand area for box item which is: grid.size_allocation - grid.size_request / nb_expands
                        boxes[row][column].box.set_expand (Graphic.Point (boxes[row][column].xexpand ? xexpand : 0,
                                                                          boxes[row][column].yexpand ? yexpand : 0),
                                                           Cassowary.Strength.strong);
                    }
                }

                // Set the fill area for grid allocation
                box.set_expand (Graphic.Point (inAllocation.extents.size.width - size.width,
                                               inAllocation.extents.size.height - size.height));

                // Calculate the new size of item box
                var solver = new Cassowary.SimplexSolver ();
                solver.auto_solve = false;
                box.build_constraints (solver);
                solver.solve ();

                // Set size allocation for each item
                foreach (unowned Core.Object child in grid)
                {
                    if (child is ItemPackable)
                    {
                        unowned ItemPackable item = (ItemPackable)child;

                        Graphic.Rectangle area = Graphic.Rectangle (boxes[(int)item.row][(int)item.column].box.origin.x,
                                                                    boxes[(int)item.row][(int)item.column].box.origin.y,
                                                                    boxes[(int)item.row][(int)item.column].box.size.width,
                                                                    boxes[(int)item.row][(int)item.column].box.size.height);

                        item.update (inContext, new Graphic.Region (area));
                    }
                }
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"grid $(grid.name) size allocation error: $(err.message)");
            }
        }
    }

    // properties
    private SizeAllocation m_Allocation;

    // accessors
    internal override string tag {
        get {
            return "CassoGrid";
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
    public CassoGrid (string inId)
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
            unowned CassoGrid? grid = child as CassoGrid;
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

                    if (item.row < m_Allocation.boxes.length && item.column < m_Allocation.boxes[(int)item.row].length)
                    {
                        // paint grid
                        Graphic.Rectangle item_area = Graphic.Rectangle (m_Allocation.boxes[(int)item.row][(int)item.column].box.origin.x,
                                                                         m_Allocation.boxes[(int)item.row][(int)item.column].box.origin.y,
                                                                         m_Allocation.boxes[(int)item.row][(int)item.column].box.size.width,
                                                                         m_Allocation.boxes[(int)item.row][(int)item.column].box.size.height);

                        grid.rectangle (item_area.origin.x, item_area.origin.y,
                                        item_area.size.width, item_area.size.height);
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
}

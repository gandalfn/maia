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
    private struct SizeAllocation
    {
        public unowned CassoGrid  grid;
        public Cassowary.Box box;
        public Graphic.Size  size;

        public SizeAllocation (CassoGrid inGrid)
        {
            grid = inGrid;

            try
            {
                box = new Cassowary.Box (grid.name);

                foreach (unowned Core.Object child in grid)
                {
                    if (child is ItemPackable)
                    {
                        unowned ItemPackable item = (ItemPackable)child;
                        var item_box = new Cassowary.Box (item.name);

                        unowned ItemPackable? prev_item = item.prev () as ItemPackable;
                        unowned Cassowary.Box? prev_box = item_box.prev () as Cassowary.Box;

                        if (prev_item != null && prev_box != null && prev_item.row == item.row  && prev_item.column != item.column)
                        {
                            print (@"$(item.name) right of $(prev_item.name)\n");
                            item_box.right_of (prev_box, grid.column_spacing);
                        }

                        if (prev_item != null && prev_item.row != item.row)
                        {
                            unowned Cassowary.Box? pb = prev_box;
                            for (unowned Core.Object? prev = prev_item; prev != null && pb != null; prev = prev.prev (), pb = (Cassowary.Box)pb.prev ())
                            {
                                unowned ItemPackable? p =  prev as ItemPackable;
                                if (p.column == item.column)
                                {
                                    print (@"$(item.name) below $(p.name)\n");
                                    item_box.below (pb, grid.row_spacing);
                                }
                            }
                        }

                        Cassowary.Box.Position position = Cassowary.Box.Position.FREE;

                        if (item.row == 0)
                        {
                            position |= Cassowary.Box.Position.LEFT;
                        }
                        if (item.column == 0)
                        {
                            position |= Cassowary.Box.Position.TOP;
                        }

                        box.add_box (item_box, position);

                        print(@"$(box)\n");
                        item_box.set_size (item.size);
                    }
                }
            
                box.build_constraints (new Cassowary.SimplexSolver ());
                size = box.size;
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
                box.set_size (inAllocation.extents.size);

                box.build_constraints (new Cassowary.SimplexSolver ());

                unowned Cassowary.Box? item_box = (Cassowary.Box)box.first ();

                foreach (unowned Core.Object child in grid)
                {
                    if (child is ItemPackable)
                    {
                        unowned ItemPackable item = (ItemPackable)child;

                        Graphic.Rectangle area = Graphic.Rectangle (item_box.origin.x, item_box.origin.y, item_box.size.width, item_box.size.height);

                        item.update (inContext, new Graphic.Region (area));

                        item_box = (Cassowary.Box)item_box.next ();
                    }
                }
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"grid $(grid.name) size request error: $(err.message)");
            }
        }

        public bool
        get_row_size (uint inRow, out Graphic.Size outSize)
        {
            bool ret = false;

            outSize = Graphic.Size (0, 0);
//~             if (inRow < rows.length)
//~             {
//~                 outSize.height = double.max (outSize.height, rows[inRow].size.height);
//~                 for (int cpt = 0; cpt < columns.length; ++cpt)
//~                 {
//~                     outSize.width += columns[cpt].size.width;
//~                 }
//~ 
//~                 ret = true;
//~             }
            return ret;
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
    construct
    {
        not_dumpable_attributes.insert ("size");
    }

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

//~                     if (item.row < m_Allocation.child_allocations.length[0] && item.column < m_Allocation.child_allocations.length[1])
//~                     {
//~                         // paint grid
//~                         Graphic.Region area = new Graphic.Region (m_Allocation.child_allocations[item.row, item.column]);
//~                         if (item.columns > 0)
//~                         {
//~                             for (int cpt = 1; cpt < item.columns; ++cpt)
//~                             {
//~                                 area.union_with_rect (m_Allocation.child_allocations[item.row, item.column + cpt]);
//~                             }
//~                         }
//~ 
//~                         if (item.rows > 0)
//~                         {
//~                             for (int cpt = 1; cpt < item.rows; ++cpt)
//~                             {
//~                                 area.union_with_rect (m_Allocation.child_allocations[item.row + cpt, item.column]);
//~                             }
//~                         }
//~ 
//~                         double row_spacing = 0;
//~                         if (this.row_spacing > 0 && m_Allocation.rows.length > 1)
//~                         {
//~                             row_spacing = this.row_spacing;
//~                             if (item.row == 0) row_spacing /= 2;
//~                             if (item.row == m_Allocation.rows.length - 1) row_spacing /= 2;
//~                         }
//~ 
//~                         double column_spacing = 0;
//~                         if (this.column_spacing > 0 && m_Allocation.columns.length > 1)
//~                         {
//~                             column_spacing = this.column_spacing;
//~                             if (item.column == 0) column_spacing /= 2;
//~                             if (item.column == m_Allocation.columns.length - 1) column_spacing /= 2;
//~                         }
//~ 
//~                         grid.rectangle (area.extents.origin.x, area.extents.origin.y,
//~                                         area.extents.size.width - column_spacing, area.extents.size.height - row_spacing);
//~                     }
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

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * item-packable.vala
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

public interface Maia.ItemPackable : Item
{
    // accessors
    /**
     * The row to place the item in.
     */
    public abstract uint   row     { get; set; default = 0; }
    /**
     * The column to place the item in.
     */
    public abstract uint   column  { get; set; default = 0; }
    /**
     * The number of rows that the item spans.
     */
    public abstract uint   rows    { get; set; default = 1; }
    /**
     * The number of columns that the item spans.
     */
    public abstract uint   columns { get; set; default = 1; }

    /**
     * If the item expands horizontally as the parent expands.
     */
    public abstract bool   xexpand { get; set; default = true; }
    /**
     * If the item fills all horizontal allocated space.
     */
    public abstract bool   xfill   { get; set; default = true; }
    /**
     * If the item can shrink smaller than its requested size horizontally.
     */
    public abstract bool   xshrink { get; set; default = false; }
    /**
     * If the item can limp to zero if the size horizontally was zero.
     */
    public abstract bool   xlimp   { get; set; default = false; }
    /**
     * The horizontal position of the item within its allocated space. 0.0 is left-aligned, 1.0 is right-aligned.
     */
    public abstract double xalign  { get; set; default = 0.5; }

    /**
     * If the item expands vertically as the parent expands.
     */
    public abstract bool   yexpand { get; set; default = true; }
    /**
     * If the item fills all vertically allocated space.
     */
    public abstract bool   yfill   { get; set; default = true; }
    /**
     * If the item can shrink smaller than its requested size vertically.
     */
    public abstract bool   yshrink { get; set; default = false; }
    /**
     * If the item can limp to zero if the size vertically was zero.
     */
    public abstract bool   ylimp   { get; set; default = false; }
    /**
     * The vertical position of the item within its allocated space. 0.0 is top-aligned, 1.0 is bottom-aligned.
     */
    public abstract double yalign  { get; set; default = 0.5; }

    /**
     * Extra space to add above the item.
     */
    public abstract double top_padding    { get; set; default = 0; }
    /**
     * Extra space to add below the item.
     */
    public abstract double bottom_padding { get; set; default = 0; }
    /**
     * Extra space to add to the left of the item.
     */
    public abstract double left_padding   { get; set; default = 0; }
    /**
     * Extra space to add to the right of the item.
     */
    public abstract double right_padding  { get; set; default = 0; }

    /**
     * The background cell Pattern of Item
     */
    public abstract Graphic.Pattern backcell_pattern { get; set; default = null; }
}

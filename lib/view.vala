/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * togglebutton.vala
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

public class Maia.View : Grid, ItemPackable
{
    // types
    public class Cell : Core.Object, Manifest.Element
    {
        // properties
        internal override string tag {
            get {
                return "View";
            }
        }

        internal override string characters { get; set; default = null; }

        // methods
        public Cell (string inId)
        {
            GLib.Object (id: GLib.Quark.from_string (inId));
        }
    }

    // properties
    private unowned Model m_Model = null;

    // accessors
    internal override string tag {
        get {
            return "View";
        }
    }

    internal override string characters { get; set; default = null; }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    public Model model {
        get {
            return m_Model;
        }
        set {
            if (m_Model != null)
            {
                m_Model.row_added.disconnect (on_row_added);
                m_Model.row_changed.disconnect (on_row_changed);
                m_Model.row_deleted.disconnect (on_row_deleted);
                m_Model.rows_reordered.disconnect (on_rows_reordered);
            }

            m_Model = value;

            if (m_Model != null)
            {
                m_Model.row_added.connect (on_row_added);
                m_Model.row_changed.connect (on_row_changed);
                m_Model.row_deleted.connect (on_row_deleted);
                m_Model.rows_reordered.connect (on_rows_reordered);
            }
        }
        default = null;
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("model");
    }

    public View (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_row_added (uint inRow)
    {

    }

    private void
    on_row_changed (uint inRow)
    {
    }

    private void
    on_row_deleted (uint inRow)
    {
    }

    private void
    on_rows_reordered (uint[] inNewOrder)
    {
    }

    internal bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Item || inObject is Cell;
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view.vala
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

public class Maia.View : Maia.Grid
{
    // delegates
    public delegate bool SetPropertyFunc (GLib.Object inObject, string inProperty, string inColumnName, uint inRow);

    // properties
    private string m_ModelName = null;
    private unowned Model m_Model = null;
    private SetPropertyFunc m_SetPropertyFunc = null;
    private int m_RowHightlighted = -1;
    private Manifest.Document m_Document = null;

    // signals
    public signal void row_clicked (uint inRow);

    // accessors
    internal override string tag {
        get {
            return "View";
        }
    }

    public uint lines { get; set; default = 1; }
    public Orientation orientation { get; set; default = Orientation.VERTICAL; }

    public string model_name {
        get {
            return m_ModelName;
        }
        set {
            m_ModelName = value;
            model = find_model (value);
        }
        default = null;
    }

    public unowned Model model {
        owned get {
            if (m_ModelName != null && m_Model == null)
            {
                m_Model = find_model (m_ModelName);

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
            return m_Model;
        }
        set {
            if (m_Model != null)
            {
                m_Model.row_added.disconnect (on_row_added);
                m_Model.row_deleted.disconnect (on_row_deleted);
                m_Model.rows_reordered.disconnect (on_rows_reordered);

                // Remove all rows
                for (uint cpt = 0; cpt < m_Model.nb_rows; ++cpt)
                {
                    m_Model.row_deleted (cpt);
                }
            }

            m_Model = value;

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

    // static methods
    private static void
    on_bind_value_changed (Manifest.AttributeBind inAttribute, Object inSrc, string inProperty)
    {
        // Search the direct child of view
        unowned Core.Object? child = (Core.Object)inAttribute.owner;
        for (; child.parent != null && !(child.parent is View); child = child.parent);

        unowned ItemPackable? item = child as ItemPackable;
        unowned View? view = item != null ? item.parent as View : null;

        unowned Model? model = inSrc as Model;
        if (item != null && view != null && model != null)
        {
            // Get row num of child
            uint row_num = 0;
            if (view.orientation == Orientation.HORIZONTAL)
                row_num = (item.column * view.lines) + item.row;
            else
                row_num = (item.row * view.lines) + item.column;

            string column_name = inAttribute.get ();
            if (view.m_SetPropertyFunc == null ||
                !view.m_SetPropertyFunc (inAttribute.owner, inProperty, column_name, row_num))
            {
                // search the associated column
                unowned Model.Column? column = model[column_name];
                if (column != null)
                {
                    // Set value of property
                    inAttribute.owner.set_property (inProperty, column[row_num]);
                }
                else
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE,
                                  "Error on bind %s invalid %s column name", inProperty, inAttribute.get ());
                }
            }
        }
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("model");

        notify["item-over-pointer"].connect (on_pointer_over_changed);
        notify["root"].connect (on_root_change);
    }

    public View (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_root_change ()
    {
        if (m_ModelName != null && m_Model == null)
        {
            model_name = m_ModelName;
        }
    }

    private inline unowned Model?
    find_model (string? inName)
    {
        unowned Model? model = null;

        if (inName != null)
        {
            for (unowned Core.Object item = parent; item != null; item = item.parent)
            {
                unowned View? view = item.parent as View;

                // If view is in view search model in cell first
                if (view != null)
                {
                    model = item.find (GLib.Quark.from_string (inName), false) as Model;
                    if (model != null) break;
                }
                // We not found model in view parents search in root
                else if (item.parent == null)
                {
                    model = item.find (GLib.Quark.from_string (inName)) as Model;
                }
            }
        }

        return model;
    }

    private void
    on_pointer_over_changed ()
    {
        if (fill_pattern != null)
        {
            if (m_RowHightlighted >= 0)
            {
                Graphic.Rectangle area;

                if (get_row_area (m_RowHightlighted, out area))
                {
                    area.size.width = geometry.extents.size.width;
                    damage (new Graphic.Region (area));
                }
                m_RowHightlighted = -1;
            }

            if (item_over_pointer != null && item_over_pointer is ItemPackable)
            {
                unowned ItemPackable item = item_over_pointer as ItemPackable;
                uint row;
                if (get_item_row (item, out row))
                {
                    if (m_RowHightlighted != row)
                    {
                        m_RowHightlighted = (int)row;
                        Graphic.Rectangle area;
                        if (get_row_area (m_RowHightlighted, out area))
                        {
                            area.size.width = geometry.extents.size.width;
                            damage (new Graphic.Region (area));
                        }
                    }
                }
            }
        }
    }

    private void
    on_template_attribute_bind (Manifest.AttributeBind inAttribute, string inProperty)
    {
        if (m_Model != null)
        {
            string signal_name = "value-changed::%s".printf (inAttribute.get ());

            if (!inAttribute.is_bind (signal_name, inProperty))
            {
                inAttribute.bind (m_Model, signal_name, inProperty, on_bind_value_changed);
            }
        }
    }

    private bool
    on_item_button_press (Item inItem, uint inButton, Graphic.Point inPoint)
    {
        if (inButton == 1)
        {
            unowned ItemPackable item = (ItemPackable)inItem;
            uint row;
            if (get_item_row (item, out row))
            {
                row_clicked (row);
            }
        }

        return true;
    }

    private ItemPackable?
    create_cell (uint inRow)
    {
        // parse template
        try
        {
            if (m_Document == null && characters != null && characters.length > 0)
            {
                m_Document = new Manifest.Document.from_buffer (characters, characters.length);
                m_Document.path = manifest_path;
                m_Document.styles = manifest_styles;
                m_Document.attribute_bind_added.connect (on_template_attribute_bind);
            }

            if (m_Document != null)
            {
                ItemPackable? item = m_Document.get (null) as ItemPackable;

                if (item != null)
                {
                    item.id = GLib.Quark.from_string ("%s-%u".printf (item.name, inRow));
                }

                return item;
            }
        }
        catch (Core.ParseError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                          "Error on parsing cell %s: %s", name, err.message);
        }

        return null;
    }

    private void
    shift (uint inRow)
    {
        foreach (unowned Core.Object child in this)
        {
            if (child is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)child;

                uint pos = 0;

                if (orientation == Orientation.HORIZONTAL)
                    pos = (item.column * lines) + item.row;
                else
                    pos = (item.row * lines) + item.column;

                if (pos >= inRow)
                {
                    item.id = GLib.Quark.from_string ("%s-%u".printf (item.name, inRow));

                    if (orientation == Orientation.HORIZONTAL)
                    {
                        item.row = (pos + 1) % lines;
                        item.column = (pos + 1) / lines;
                    }
                    else
                    {
                        item.row = (pos + 1) / lines;
                        item.column = (pos + 1) % lines;
                    }

                    item.reorder ();
                }
            }
        }
    }

    private void
    unshift (uint inRow)
    {
        foreach (unowned Core.Object child in this)
        {
            if (child is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)child;

                uint pos = 0;

                if (orientation == Orientation.HORIZONTAL)
                    pos = (item.column * lines) + item.row;
                else
                    pos = (item.row * lines) + item.column;

                if (pos > inRow)
                {
                    item.id = GLib.Quark.from_string ("%s-%u".printf (item.name, inRow));

                    if (orientation == Orientation.HORIZONTAL)
                    {
                        item.row = (pos - 1) % lines;
                        item.column = (pos - 1) / lines;
                    }
                    else
                    {
                        item.row = (pos - 1) / lines;
                        item.column = (pos - 1) % lines;
                    }

                    item.reorder ();
                }
            }
        }
    }

    private void
    on_row_added (uint inRow)
    {
        ItemPackable? item = create_cell (inRow);
        if (item != null)
        {
            // Shift current items
            shift (inRow);

            // Attach item to view
            if (orientation == Orientation.HORIZONTAL)
            {
                item.row = inRow % lines;
                item.column = inRow / lines;
            }
            else
            {
                item.row = inRow / lines;
                item.column = inRow % lines;
            }
            add (item);

            // connect onto cell button press
            item.button_press_event.connect (on_item_button_press);
        }
        else
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                          "Error on parsing cell: could not found any item packable in cell template");
        }
    }

    private void
    on_row_deleted (uint inRow)
    {
        // Get item at row
        unowned ItemPackable? item = get_item (inRow);

        if (item != null)
        {
            // disconnect from cell button press
            item.button_press_event.disconnect (on_item_button_press);

            // dettach item
            item.parent = null;

            // unshift all siblings item
            unshift (inRow);
        }
    }

    private void
    on_rows_reordered (uint[] inNewOrder)
    {
        foreach (unowned Core.Object child in this)
        {
            if (child is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)child;

                uint pos = 0;

                if (orientation == Orientation.HORIZONTAL)
                    pos = (item.column * lines) + item.row;
                else
                    pos = (item.row * lines) + item.column;

                if (pos < inNewOrder.length)
                {
                    item.id = GLib.Quark.from_string ("%s-%u".printf (item.name, pos));

                    if (orientation == Orientation.HORIZONTAL)
                    {
                        item.row = inNewOrder[pos] % lines;
                        item.column = inNewOrder[pos] / lines;
                    }
                    else
                    {
                        item.row = inNewOrder[pos] / lines;
                        item.column = inNewOrder[pos] % lines;
                    }

                    item.reorder ();
                }
            }
        }

        geometry = null;
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_RowHightlighted >= 0 && fill_pattern != null)
        {
            Graphic.Rectangle area;

            if (get_row_area (m_RowHightlighted, out area))
            {
                area.size.width = geometry.extents.size.width;
                var path = new Graphic.Path.from_region (new Graphic.Region (area));
                inContext.pattern = fill_pattern;
                inContext.fill (path);
            }
        }

        base.paint (inContext);
    }

    public void
    set_property_func (owned SetPropertyFunc? inFunc)
    {
        m_SetPropertyFunc = (owned)inFunc;
    }

    public unowned ItemPackable?
    get_item (uint inRow)
    {
        foreach (unowned Core.Object child in this)
        {
            if (child is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)child;

                uint pos = 0;

                if (orientation == Orientation.HORIZONTAL)
                    pos = (item.column * lines) + item.row;
                else
                    pos = (item.row * lines) + item.column;

                if (pos == inRow)
                    return item;
            }
        }

        return null;
    }

    public bool
    get_item_row (ItemPackable inItem, out uint outRow)
    {
        bool ret = false;

        outRow = 0;

        foreach (unowned Core.Object child in this)
        {
            if (child == inItem)
            {
                if (orientation == Orientation.VERTICAL)
                {
                    outRow = inItem.column + inItem.row * lines;
                }
                else
                {
                    outRow = inItem.row + inItem.column * lines;
                }
                ret = true;
            }
        }

        return ret;
    }
}

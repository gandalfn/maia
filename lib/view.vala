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
    // properties
    private unowned Model m_Model = null;

    // accessors
    internal override string tag {
        get {
            return "View";
        }
    }

    public uint lines { get; set; default = 1; }
    public Orientation orientation { get; set; default = Orientation.VERTICAL; }

    public string model {
        owned get {
            return m_Model != null ? m_Model.name : null;
        }
        set {
            if (m_Model != null)
            {
                m_Model.row_added.disconnect (on_row_added);
                m_Model.row_deleted.disconnect (on_row_deleted);
                m_Model.rows_reordered.disconnect (on_rows_reordered);
            }

            m_Model = root.find (GLib.Quark.from_string (value)) as Model;

            if (m_Model != null)
            {
                m_Model.row_added.connect (on_row_added);
                m_Model.row_deleted.connect (on_row_deleted);
                m_Model.rows_reordered.connect (on_rows_reordered);
            }
        }
        default = null;
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

            // search the associated column
            unowned Model.Column? column = model[inAttribute.get ()];
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

    // methods
    public View (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
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

    private ItemPackable?
    create_cell (uint inRow)
    {
        // parse template
        try
        {
            var document = new Manifest.Document.from_buffer (characters, characters.length);
            document.attribute_bind_added.connect (on_template_attribute_bind);

            ItemPackable? item = document.get (null) as ItemPackable;

            if (item != null)
            {
                item.id = GLib.Quark.from_string ("%s-%u".printf (item.name, inRow));
            }

            return item;
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
            item.parent = this;
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
                }
            }
        }

        geometry = null;
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
}

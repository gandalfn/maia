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

public class Maia.TableViewColumn : Item
{
    // delegates
    public delegate bool SetPropertyFunc (GLib.Object inObject, string inProperty, string inColumnName, uint inRow);

    // properties
    private Manifest.Document m_Document = null;

    // accessors
    internal override string tag {
        get {
            return "TableViewColumn";
        }
    }

    public string label { get; set; default = null; }
    public Model model { get; set; default = null; }

    // static methods
    private static void
    on_bind_value_changed (Manifest.AttributeBind inAttribute, Object inSrc, string inProperty, uint inRow)
    {
        // Search the direct child of table view
        unowned Core.Object? child = (Core.Object)inAttribute.owner;
        for (; child.parent != null && !(child.parent is TableView); child = child.parent);

        unowned ItemPackable? item = child as ItemPackable;
        unowned TableView? view = item != null ? item.parent as TableView : null;

        unowned Model? model = inSrc as Model;
        if (item != null && view != null && model != null)
        {
            // Get row num of child
            uint row_num;

            if (view.get_item_row (item, out row_num) && row_num == inRow)
            {
                string column_name = inAttribute.get ();
                if (view.m_SetPropertyFunc == null || !view.m_SetPropertyFunc (inAttribute.owner, inProperty, column_name, row_num))
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
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("model");
    }

    public TableViewColumn (string inId, Model inModel)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), model: inModel);
    }

    private void
    on_template_attribute_bind (Core.Notification inNotification)
    {
        unowned Manifest.Document.AttributeBindAddedNotification? notification = inNotification as Manifest.Document.AttributeBindAddedNotification;
        if (notification != null && model != null)
        {
            string signal_name = "value-changed::%s".printf (notification.attribute.get ());

            if (!notification.attribute.is_bind (signal_name, notification.property))
            {
                notification.attribute.bind_with_arg1<uint> (model, signal_name, notification.property, on_bind_value_changed);
            }
        }
    }

    internal ItemPackable?
    create_cell ()
    {
        // parse template
        try
        {
            if (m_Document == null && characters != null && characters.length > 0)
            {
                m_Document = new Manifest.Document.from_buffer (characters, characters.length);
                m_Document.path = manifest_path;
                m_Document.theme = manifest_theme;
                m_Document.notifications["attribute-bind-added"].add_object_observer (on_template_attribute_bind);
            }

            if (m_Document != null)
            {
                return m_Document.get () as ItemPackable;
            }
        }
        catch (Core.ParseError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, @"Error on parsing cell $(name): $(err.message)");
        }

        return null;
    }

    internal override string
    dump_characters (string inPrefix)
    {
        string ret = "";

        // parse template
        try
        {
            if (characters != null && characters.length > 0)
            {
                var document = new Manifest.Document.from_buffer (characters, characters.length);
                document.path = manifest_path;
                document.theme = manifest_theme;

                ItemPackable? item = document.get (null) as ItemPackable;

                if (item != null)
                {
                    ret += inPrefix + "[\n";
                    ret += inPrefix + "\t" + item.dump (inPrefix + "\t");
                    ret += inPrefix + "]\n";
                }
            }
        }
        catch (Core.ParseError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                          "Error on parsing cell %s: %s", name, err.message);
        }

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
    }

    internal override string
    dump_childs (string inPrefix)
    {
        return "";
    }
}

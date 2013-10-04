/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * combo.vala
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

public class Maia.Combo : Group, ItemPackable, ItemMovable
{
    // properties
    private Popup                 m_Popup  = null;
    private unowned View?         m_View   = null;
    private unowned ItemPackable? m_Active = null;

    // accessors
    internal override string tag {
        get {
            return "Combo";
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

    public unowned View view {
        get {
            return m_View;
        }
    }

    public Graphic.Color highlight_color { get; set; default = new Graphic.Color (0.2, 0.2, 0.2); }

    public int active_row {
        get {
            if (m_View != null && m_Active != null)
            {
                uint row;

                if (m_View.get_item_row (m_Active, out row))
                {
                    return (int)row;
                }
            }

            return -1;
        }
        set {
            if (m_View != null && value >= 0)
            {
                m_Active = m_View.get_item (value);
            }
            else
            {
                m_Active = null;
            }

            damage ();
        }
    }
    // signals
    public signal void changed ();

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("popup-progress");
        not_dumpable_attributes.insert ("view");

        // Create arrow
        string id_arrow = "%s-arrow".printf (name);
        var arrow_item = new Path (id_arrow, "");
        add (arrow_item);

        notify["stroke-pattern"].connect (() => {
            arrow_item.fill_pattern = stroke_pattern;
        });

        notify["root"].connect (() => {
            if (m_Popup != null)
            {
                m_Popup.parent = root;
            }
        });

        arrow_item.button_press_event.connect (on_button_press);

        // Connect onto button press
        button_press_event.connect (on_button_press);

        stroke_pattern = new Graphic.Color (0, 0, 0);
    }

    public Combo (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private bool
    on_button_press (uint inButton, Graphic.Point inPoint)
    {
        if (m_Popup.visible)
            m_Popup.hide ();
        else
            m_Popup.show ();

        damage ();
        return true;
    }

    private void
    on_row_clicked (uint inRow)
    {
        if (m_View != null)
        {
            m_Active = m_View.get_item (inRow);
            m_Popup.hide ();
            changed ();
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Label || inObject is Path;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (inObject is View && m_Popup == null)
        {
            m_Popup = new Popup ("%s-popup".printf (name));
            m_Popup.add (inObject);
            m_Popup.layer = 100;
            m_Popup.visible = false;
            m_Popup.placement = PopupPlacement.TOP;
            m_Popup.background_pattern = fill_pattern;
            m_Popup.notify["visible"].connect (() => {
                damage ();
            });

            if (root.can_append_child(m_Popup))
            {
                root.add (m_Popup);
            }

            m_View = inObject as View;
            m_View.fill_pattern = highlight_color;
            m_View.row_clicked.connect (on_row_clicked);
        }
        else
        {
            base.insert_child (inObject);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject == m_View)
        {
            m_View.row_clicked.disconnect (on_row_clicked);
            m_View.parent = null;
            m_View = null;
            m_Popup.parent = null;
            m_Popup = null;
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size childs_size = Graphic.Size (0, 0);
        Graphic.Size view_size = Graphic.Size (0, 0);

        if (m_Popup != null && m_Popup.parent != null && m_Popup.parent != root)
        {
            m_Popup.parent = root;
        }

        // Get size of first view child
        if (m_View != null)
        {
            view_size = m_View.size;
        }

        // Get size of arrow
        string id_arrow = "%s-arrow".printf (name);
        unowned Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
        if (arrow_item != null)
        {
            Graphic.Size row_size = Graphic.Size (0, 0);

            if (m_View != null)
            {
                if (m_View.get_row_size (0, out row_size))
                {
                    arrow_item.path = "M 3,3 L %g,3 L %g,%g Z".printf (row_size.height - 3,
                                                                       3 + (row_size.height - 6) / 2.0,
                                                                       row_size.height - 3);
                    arrow_item.size = Graphic.Size (row_size.height, row_size.height);
                }
            }

            var arrow_size = arrow_item.size;
            if (row_size.width > 0)
            {
                childs_size.width = row_size.width + arrow_size.width + ((3 * arrow_size.width) / 2);
            }
            else
            {
                childs_size.width = arrow_size.width * 2;
            }

            if (row_size.height > 0)
            {
                childs_size.height = row_size.height + arrow_size.height;
            }
            else
            {
                childs_size.height = arrow_size.height * 2;
            }

            if (m_Popup != null)
            {
                m_Popup.border = arrow_size.width / 2;
            }
        }

        return childs_size;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            // Update arrow position
            string id_arrow = "%s-arrow".printf (name);
            unowned Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
            if (arrow_item != null)
            {
                var arrow_size = arrow_item.size_requested;
                var arrow_area = Graphic.Rectangle (inAllocation.extents.size.width - ((3 * arrow_size.width) / 2),
                                                    arrow_size.height / 2,
                                                    arrow_size.width, arrow_size.height);

                arrow_item.update (inContext, new Graphic.Region (arrow_area));

                if (m_Popup != null)
                {
                    var start = convert_to_root_space (Graphic.Point (arrow_size.width / 2, arrow_size.height + arrow_size.height / 2));

                    start = (root as Item).convert_to_item_space (start);

                    if (m_Popup.position.x != start.x || m_Popup.position.y != start.y)
                    {
                        m_Popup.position = start;
                    }
                }
            }

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint childs
        var area = new Graphic.Region ();
        foreach (unowned Core.Object child in this)
        {
            if (child is Path)
            {
                unowned Path path = (Path)child;
                area.union_ (path.geometry);
                path.draw (inContext, area_to_child_item_space (path, inArea));
            }
        }

        if (m_Active != null)
        {
            inContext.save ();
            {
                Graphic.Point active_pos = Graphic.Point (0, 0);

                string id_arrow = "%s-arrow".printf (name);
                unowned Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
                if (arrow_item != null)
                {
                    var arrow_size = arrow_item.size_requested;
                    active_pos = Graphic.Point (arrow_size.width / 2, arrow_size.height / 2);
                }

                var active_origin = m_Active.geometry.extents.origin;
                m_Active.geometry.translate (active_origin.invert ());
                var active_area = m_Active.geometry.copy ();
                m_Active.geometry.translate (active_pos);

                area.union_ (m_Active.geometry);
                var active_damaged = m_Active.damaged != null ? m_Active.damaged.copy () : null;

                if (active_damaged == null)
                {
                    m_Active.damaged = active_area;
                }

                m_Active.draw (inContext, area_to_child_item_space (m_Active, inArea));

                m_Active.damaged = active_damaged;
                m_Active.geometry.translate (active_pos.invert ());
                m_Active.geometry.translate (active_origin);
            }
            inContext.restore ();
        }

        if (m_Popup.visible)
        {
            var path = new Graphic.Path ();
            path.rectangle (area.extents.origin.x, area.extents.origin.y, area.extents.size.width, area.extents.size.height);
            inContext.pattern = stroke_pattern;
            inContext.dash = { 1, 1 };
            inContext.line_width = 0.5;
            inContext.stroke (path);
        }
    }
}

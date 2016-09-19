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

public class Maia.Combo : Group, ItemPackable, ItemMovable, ItemFocusable
{
    /**
     * Event args provided by Combo on chaned event
     */
    public class ChangedEventArgs : Core.EventArgs
    {
        // properties
        private int m_ActiveRow;

        // accessors
        [CCode (notify = false)]
        internal override GLib.Variant serialize {
            owned get {
                return new GLib.Variant ("(i)", m_ActiveRow);
            }
            set {
                if (value != null)
                {
                    value.get ("(i)", out m_ActiveRow);
                }
                else
                {
                    m_ActiveRow = -1;
                }
            }
        }

        /**
         * Active row on changed event
         */
        public int active_row {
            get {
                return m_ActiveRow;
            }
        }

        // methods
        internal ChangedEventArgs (int inActiveRow)
        {
            base ();

            m_ActiveRow = inActiveRow;
        }
    }
    // properties
    private Popup                 m_Popup      = null;
    private Model                 m_Model      = null;
    private unowned View?         m_View       = null;
    private unowned ItemPackable? m_Active     = null;
    private unowned FocusGroup?   m_FocusGroup = null;

    // accessors
    internal override string tag {
        get {
            return "Combo";
        }
    }

    internal bool   can_focus   { get; set; default = true; }
    internal bool   have_focus  { get; set; default = false; }
    internal int    focus_order { get; set; default = -1; }
    internal FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
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

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    public unowned View view {
        get {
            return m_View;
        }
    }

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
            if (value != active_row)
            {
                if (m_View != null && value >= 0)
                {
                    m_Active = m_View.get_item (value);

                    changed.publish (new ChangedEventArgs (value));

                    damage.post ();
                }
                else if (m_Active != null)
                {
                    m_Active = null;

                    changed.publish (new ChangedEventArgs (-1));

                    damage.post ();
                }
            }
        }
    }

    [CCode (notify = false)]
    public Model model {
        get {
            return m_Model;
        }
        set {
            if (m_Model != value)
            {
                m_Model = value;
                if (m_View != null)
                {
                    m_View.model = m_Model;
                }
            }
        }
    }

    // events
    public Core.Event changed { get; private set; }

    // static methods
    static construct
    {
        // Ref Mpdel class to register model transform
        typeof (Model).class_ref ();

        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("popup-progress");
        not_dumpable_attributes.insert ("view");

        have_focus = false;

        // Create event
        changed = new Core.Event ("changed", this);

        // Create arrow
        string id_arrow = "%s-arrow".printf (name);
        var arrow_item = new Path (id_arrow, "");
        plug_property ("stroke-pattern", arrow_item, "fill-pattern");
        add (arrow_item);

        arrow_item.button_press_event.connect (on_button_press);

        // Connect onto button press
        button_press_event.connect (on_button_press);

        // Connect onto focus change
        notify["have-focus"].connect (on_focus_changed);

        fill_pattern[State.PRELIGHT] = new Graphic.Color (0.2, 0.2, 0.2);
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        // Create popup
        m_Popup = new Popup ("%s-popup".printf (name));
        m_Popup.visible = false;
        m_Popup.shadow_width = 7;
        m_Popup.round_corner = 3;
        m_Popup.window_type = Window.Type.POPUP;
        m_Popup.position_policy = Window.PositionPolicy.CLAMP_MONITOR;
        m_Popup.visible = false;
        m_Popup.placement = PopupPlacement.TOP;


        plug_property ("fill-pattern", m_Popup, "background-pattern");

        add (m_Popup);
    }

    public Combo (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_view_need_update_changed ()
    {
        need_update |= m_View.need_update;
    }

    private void
    on_view_geometry_changed ()
    {
        if (m_View.geometry == null)
        {
            need_update = true;
            geometry = null;
        }
    }

    private void
    on_focus_changed ()
    {
        // popup is open and focus has been lost close popup
        if (!have_focus && m_Popup.visible)
        {
            m_Popup.visible = false;
        }
    }

    private bool
    on_button_press (uint inButton, Graphic.Point inPoint)
    {
        if (inButton == 1)
        {
            if (m_Popup.visible)
            {
                m_Popup.visible = false;
                have_focus = false;
            }
            else
            {
                m_View.geometry = null;
                m_View.need_update = true;
                m_Popup.visible = true;
                have_focus = true;

                uint row = 0;
                if (m_Active != null && m_View.get_item_row (m_Active, out row))
                {
                    m_View.highlighted_row = (int)row;
                }
                else
                {
                    m_View.highlighted_row = -1;
                }
            }

            damage.post ();
        }

        return true;
    }

    private void
    on_row_clicked (uint inRow)
    {
        if (m_View != null)
        {
            m_Popup.visible = false;
            have_focus = false;
            active_row = (int)inRow;
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Label || inObject is Path || inObject is Popup || inObject is Model;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (inObject is View)
        {
            if (m_View != null) m_View.parent = null;
            m_View = inObject as View;
            plug_property ("fill-pattern", m_View, "fill-pattern");
            m_View.notify["need-update"].connect (on_view_need_update_changed);
            m_View.notify["geometry"].connect (on_view_geometry_changed);
            m_View.row_clicked.connect (on_row_clicked);
            m_View.state = State.PRELIGHT;
            m_View.model = m_Model;
            m_Popup.add (m_View);

            need_update = true;
            geometry = null;
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
            unplug_property ("fill-pattern", m_View, "fill-pattern");
            m_View.row_clicked.disconnect (on_row_clicked);
            m_View.notify["need-update"].disconnect (on_view_need_update_changed);
            m_View.notify["geometry"].disconnect (on_view_geometry_changed);
            m_View.parent = null;
            m_View = null;
        }
        else
        {
            base.remove_child (inObject);
        }
    }

    internal override void
    on_child_resized (Drawable inChild)
    {
        if (inChild != (Drawable)m_Popup)
        {
            base.on_child_resized (inChild);
        }
        else
        {
            damage.post ();
        }
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size childs_size = Graphic.Size (0, 0);

        // Get size of arrow
        string id_arrow = "%s-arrow".printf (name);
        unowned Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
        if (arrow_item != null)
        {
            Graphic.Size row_size = Graphic.Size (0, 0);

            if (m_View != null)
            {
                int row = 0;
                Graphic.Size tmp_size;
                while (m_View.get_row_size (row, out tmp_size))
                {
                    row_size.width = double.max (tmp_size.width, row_size.width);
                    row_size.height = double.max (tmp_size.height, row_size.height);
                    row++;
                }

                if (row_size.width > 0 && row_size.height > 0)
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
                childs_size.width = row_size.width + arrow_size.width;
            }
            else
            {
                childs_size.width = arrow_size.width;
            }

            if (row_size.height > 0)
            {
                childs_size.height = row_size.height;
            }
            else
            {
                childs_size.height = arrow_size.height;
            }

            m_Popup.border = arrow_size.width / 4;

            childs_size.width += arrow_size.width / 2;
            childs_size.height += arrow_size.width / 2;
        }

        return childs_size;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");
#endif

            geometry = inAllocation;

            Graphic.Region item_area = area;

            // Update arrow position
            string id_arrow = "%s-arrow".printf (name);
            unowned Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
            var arrow_size = Graphic.Size (0, 0);
            if (arrow_item != null)
            {
                arrow_size = arrow_item.size;
                var arrow_area = Graphic.Rectangle (double.max (item_area.extents.size.width - arrow_size.width, 0), 0,
                                                    arrow_size.width, arrow_size.height);

                arrow_item.update (inContext, new Graphic.Region (arrow_area));
            }

            var toplevel_window = toplevel;
            if (toplevel_window != null && m_Popup.visible)
            {
                m_Popup.transient_for = toplevel_window;
            }

            // Set popup geometry
            m_Popup.position = Graphic.Point (0, arrow_size.height);
            Graphic.Size popup_size = Graphic.Size (m_Popup.size.width < item_area.extents.size.width || m_Popup.size.width > item_area.extents.size.width ? item_area.extents.size.width : m_Popup.size.width,
                                                    m_Popup.size.height < item_area.extents.size.height || m_Popup.size.height > item_area.extents.size.height ? item_area.extents.size.height : m_Popup.size.height);


            var popup_area = Graphic.Rectangle (m_Popup.position.x, m_Popup.position.y, popup_size.width + (m_Popup.border * 2), popup_size.height + (m_Popup.border * 2));

            bool force = !m_Popup.visible;
            if (force)
            {
                m_Popup.animation = false;
                m_Popup.visible = true;
                m_Popup.animation = true;
            }
            m_Popup.update (inContext, new Graphic.Region (popup_area));
            if (force)
            {
                m_Popup.animation = false;
                m_Popup.visible = false;
                m_Popup.animation = true;
            }
            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint childs
        var draw_area = new Graphic.Region ();
        foreach (unowned Core.Object child in this)
        {
            if (child is Path)
            {
                unowned Path path = (Path)child;
                if (path.geometry != null)
                {
                    draw_area.union_ (path.geometry);
                    path.draw (inContext, area_to_child_item_space (path, inArea));
                }
            }
        }


        if (m_Active != null)
        {
            inContext.save ();
            {
                if (m_Active.geometry != null)
                {
                    var active_origin = m_Active.geometry.extents.origin;
                    m_Active.geometry.translate (active_origin.invert ());
                    var active_area = m_Active.geometry.copy ();

                    draw_area.union_ (m_Active.geometry);

                    var active_damaged = m_Active.damaged != null ? m_Active.damaged.copy () : null;

                    if (active_damaged == null)
                    {
                        m_Active.damaged = active_area;
                    }

                    m_Active.draw (inContext, area_to_child_item_space (m_Active, inArea));

                    m_Active.damaged = active_damaged;
                    m_Active.geometry.translate (active_origin);
                }
            }
            inContext.restore ();
        }

        var path = new Graphic.Path ();
        path.rectangle (draw_area.extents.origin.x, draw_area.extents.origin.y, draw_area.extents.size.width, draw_area.extents.size.height);

        if (have_focus)
        {
            inContext.pattern = stroke_pattern[state];
            inContext.dash = { 1, 1 };
            inContext.line_width = 0.5;
            inContext.stroke (path);

            m_Popup.draw (inContext, m_Popup.geometry);
        }
    }

    internal override string
    dump_childs (string inPrefix)
    {
        return "";
    }
}

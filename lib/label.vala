/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * label.vala
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

public class Maia.Label : Item, ItemMovable, ItemPackable, ItemFocusable
{
    // properties
    private string          m_Text = null;
    private bool            m_HideIfEmpty = false;
    private Graphic.Glyph   m_Glyph = null;
    private Graphic.Surface m_FakeSurface = null;
    private FocusGroup      m_FocusGroup = null;

    // accessors
    internal override string tag {
        get {
            return "Label";
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

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    internal bool can_focus  {
        get {
            return parent is DrawingArea;
        }
        set {
        }
    }
    internal bool have_focus  { get; set; default = false; }
    internal int  focus_order { get; set; default = -1; }
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

    /**
     * Indicate if label text is translated
     */
    public bool                        translatable     { get; set; default = true; }

    /**
     * The font description of label
     */
    public string                      font_description { get; set; default = "Sans 12"; }

    /**
     * Alignment of label ``left``, ``center`` or ``right``, default was ``center``
     */
    public Graphic.Glyph.Alignment     alignment        { get; set; default = Graphic.Glyph.Alignment.CENTER; }

    /**
     * Wrap mode of label can be ``char`` or ``word``, default was ``word``
     */
    public Graphic.Glyph.WrapMode      wrap_mode        { get; set; default = Graphic.Glyph.WrapMode.WORD; }

    /**
     * Ellipsize mode of label can be ``none``, ``start``, ``middle`` or ``end``, default was ``none``
     */
    public Graphic.Glyph.EllipsizeMode ellipsize_mode   { get; set; default = Graphic.Glyph.EllipsizeMode.NONE; }

    /**
     * Text of label
     */
    [CCode (notify = false)]
    public string text {
        get {
            return m_Text;
        }
        set {
            if (m_Text != value)
            {
                m_Text = value;

                on_layout_property_changed ();

                notify_property ("text");
            }
        }
        default = null;
    }

    /**
     * Shade color of label
     */
    public Graphic.Color shade_color { get; set; default = null; }

    /**
     * If true hide label if text is empty
     */
    [CCode (notify = false)]
    public bool hide_if_empty {
        get {
            return m_HideIfEmpty;
        }
        set {
            if (m_HideIfEmpty != value)
            {
                m_HideIfEmpty = value;
                if (m_HideIfEmpty && visible && (text == null || text.length == 0))
                {
                    visible = false;
                    int count = get_qdata<int> (Item.s_CountHide);
                    count++;
                    set_qdata<int> (Item.s_CountHide, count);
                    not_dumpable_attributes.insert ("visible");
                }
                else if (!m_HideIfEmpty && !visible)
                {
                    int count = get_qdata<int> (Item.s_CountHide);
                    count = int.max (count - 1, 0);
                    if (count == 0)
                    {
                        visible = true;
                        not_dumpable_attributes.remove ("visible");
                    }
                    set_qdata<int> (Item.s_CountHide, count);
                }
            }
        }
    }

    // static methods
    static construct
    {
        // Ref Grid class to register grid quarks
        typeof (Grid).class_ref ();

        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();

        Manifest.Attribute.register_transform_func (typeof (Label), attribute_to_label);

        GLib.Value.register_transform_func (typeof (Label), typeof (string), label_to_value_string);
    }

    static void
    attribute_to_label (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        unowned Core.Object object = inAttribute.owner as Core.Object;
        unowned Label? label = null;

        GLib.Quark id  = GLib.Quark.from_string (inAttribute.get ());
        for (unowned Core.Object item = object; item != null; item = item.parent)
        {
            unowned View? view = item.parent as View;

            // If owned is in view search model in cell first
            if (view != null)
            {
                label = item.find (id, false) as Label;
                if (label != null) break;
            }
            // We not found model in view parents search in root
            else if (item.parent == null)
            {
                label = item.find (id) as Label;
            }
        }

        outValue = label;
    }

    static void
    label_to_value_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Label)))
    {
        unowned Label val = (Label)inSrc;

        outDest = val.name;
    }

    // methods
    construct
    {
        // Default color
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        // connect onto layout properties changed
        notify["window"].connect (on_window_changed);
        notify["alignment"].connect (on_layout_property_changed);
        notify["wrap-mode"].connect (on_layout_property_changed);
        notify["font-description"].connect (on_layout_property_changed);

        // connect onto draw properties changed
        notify["stroke-pattern"].connect (on_draw_property_changed);
        notify["shade-color"].connect (on_draw_property_changed);

        // Create a fake surface to calculate the size of path
        m_FakeSurface = new Graphic.Surface (1, 1);
    }

    /**
     * Create a new Label
     *
     * @param inId id of label item
     * @param inLabel the initial text of label
     */
    public Label (string inId, string inLabel)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), text: inLabel);
    }

    private void
    on_window_changed ()
    {
        // unset glyph
        m_Glyph = null;

        // Create a fake surface to calculate the size of path
        m_FakeSurface = new Graphic.Surface (1, 1);

        // Set transform
        m_FakeSurface.context.transform = to_window_transform ();

        // unset geometry to force update
        need_update = true;
        geometry = null;
    }

    private void
    on_layout_property_changed ()
    {
        if (text != null && text.length > 0)
        {
            if (m_HideIfEmpty && !visible)
            {
                int count = get_qdata<int> (Item.s_CountHide);
                count = int.max (count - 1, 0);

                if (count == 0)
                {
                    visible = true;
                    not_dumpable_attributes.remove ("visible");
                }
                set_qdata<int> (Item.s_CountHide, count);
            }
            else if (visible)
            {
                m_Glyph = new Graphic.Glyph (font_description);
                m_Glyph.alignment = alignment;
                m_Glyph.wrap = wrap_mode;
                m_Glyph.ellipsize = ellipsize_mode;
                m_Glyph.text = translatable ? translate (text) : text;

                // Reset wrap if any
                m_Glyph.size = Graphic.Size (0, 0);

                // update layout
                m_Glyph.update (m_FakeSurface.context);

                // get glyph size
                var item_size = m_Glyph.size;

                var item_area = area;

                if (item_area != null)
                {
                    if (item_area.extents.size.width < item_size.width || item_area.extents.size.height < item_size.height)
                    {
                        var glyph_size = m_Glyph.size;
                        if (xshrink && item_area.extents.size.width < item_size.width)
                        {
                            glyph_size.width = item_area.extents.size.width;
                        }
                        if (yshrink && item_area.extents.size.height < item_size.height)
                        {
                            glyph_size.height = item_area.extents.size.height;
                        }
                        m_Glyph.size = glyph_size;
                        m_Glyph.update (m_FakeSurface.context);

                        if (item_area.extents.size.width < m_Glyph.size.width || item_area.extents.size.height < m_Glyph.size.height)
                        {
                            m_Glyph = null;
                            geometry = null;
                            need_update = true;
                        }
                        else
                        {
                            damage.post ();
                        }
                    }
                    else
                    {
                        damage.post ();
                    }
                }
                else
                {
                    m_Glyph = null;
                    geometry = null;
                    need_update = true;
                }
            }
        }
        else if (m_HideIfEmpty && visible && (text == null || text.length == 0))
        {
            visible = false;
            int count = get_qdata<int> (Item.s_CountHide);
            count++;
            set_qdata<int> (Item.s_CountHide, count);
            not_dumpable_attributes.insert ("visible");
        }
        else
        {
            m_Glyph = null;
            geometry = null;
            need_update = true;
        }
    }

    private void
    on_draw_property_changed ()
    {
        damage.post ();
    }

    private inline unowned string?
    translate (string? inString)
    {
        string package = LibIntl.textdomain (null);
        return inString != null ? inString.length > 0 ? LibIntl.dgettext (package, inString) : "" : null;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        if (text != null && text.length > 0)
        {
            if (m_Glyph == null)
            {
                m_Glyph = new Graphic.Glyph (font_description);
                m_Glyph.alignment = alignment;
                m_Glyph.wrap = wrap_mode;
                m_Glyph.ellipsize = ellipsize_mode;
                m_Glyph.text = translatable ? translate (text) : text;
            }

            if (m_Glyph != null)
            {
                if (!get_qdata<bool> (Grid.s_Reallocate))
                {
                    // Reset wrap if any
                    m_Glyph.size = Graphic.Size (0, 0);
                }

                // update layout
                m_Glyph.update (m_FakeSurface.context);

                // set new size
                size = m_Glyph.size;
            }
        }

        return base.size_request (inSize);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        bool reallocate = false;
        var allocation = inAllocation.extents;

        if (m_Glyph != null && ((xshrink && inAllocation.extents.size.width < m_Glyph.size.width) ||
                                (yshrink && inAllocation.extents.size.height < m_Glyph.size.height)))
        {
            var glyph_size = Graphic.Size (0, 0);
            if (xshrink && allocation.size.width < size.width)
            {
                glyph_size.width = allocation.size.width;
                reallocate = true;
            }
            if (yshrink && allocation.size.height < size.height)
            {
                glyph_size.height = allocation.size.height;
                reallocate = true;
            }
            if (reallocate)
            {
                m_Glyph.size = glyph_size;
                m_Glyph.update (inContext);
            }
            glyph_size = m_Glyph.size;

            glyph_size.transform (transform);
            allocation.size.width = double.max (glyph_size.width, allocation.size.width);
            allocation.size.height = double.max (glyph_size.height, allocation.size.height);
        }

        base.update (inContext, new Graphic.Region (allocation));

        set_qdata<bool> (Grid.s_Reallocate, reallocate);
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint text
        if (m_Glyph != null && stroke_pattern[state] != null)
        {
            inContext.save ();
            {
                var pos = Graphic.Point (0, 0);
                var glyph_size = m_Glyph.size;
                var item_size = area.extents.size;
                m_Glyph.size = item_size;

                if (shade_color != null)
                {
                    inContext.pattern = new Graphic.Color.shade (shade_color, 0.8);
                    pos.translate (Graphic.Point (-1, -1));
                    m_Glyph.origin = pos;
                    inContext.render (m_Glyph);

                    inContext.pattern = new Graphic.Color.shade (shade_color, 1.2);
                    pos.translate (Graphic.Point (2, 2));
                    m_Glyph.origin = pos;
                    inContext.render (m_Glyph);

                    pos.translate (Graphic.Point (-1, -1));
                }

                m_Glyph.origin = pos;
                inContext.pattern = stroke_pattern[state];
                inContext.render (m_Glyph);

                m_Glyph.size = glyph_size;
            }
            inContext.restore ();
        }
    }
}

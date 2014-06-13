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

public class Maia.Label : Item, ItemMovable, ItemPackable
{
    // properties
    private Graphic.Glyph m_Glyph;
    private Graphic.Surface m_FakeSurface;

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

    internal override bool can_focus  {
        get {
            return parent is DrawingArea;
        }
        set {
            base.can_focus = value;
        }
    }

    /**
     * Indicate if label text is translated
     */
    public bool                        translatable     { get; set; default = true; }

    /**
     * The font description of label
     */
    public string                      font_description { get; set; default = ""; }

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
    public string                      text             { get; set; default = null; }

    /**
     * Shade color of label
     */
    public Graphic.Color               shade_color      { get; set; default = null; }

    /**
     * If true hide label if text is empty
     */
    public bool                        hide_if_empty    { get; set; default = false; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Graphic.Glyph.Alignment), attribute_to_alignment);
        Manifest.Attribute.register_transform_func (typeof (Graphic.Glyph.WrapMode), attribute_to_wrap_mode);
        Manifest.Attribute.register_transform_func (typeof (Graphic.Glyph.EllipsizeMode), attribute_to_ellipsize_mode);

        GLib.Value.register_transform_func (typeof (Graphic.Glyph.Alignment), typeof (string), alignment_to_string);
        GLib.Value.register_transform_func (typeof (Graphic.Glyph.WrapMode), typeof (string), wrap_mode_to_string);
        GLib.Value.register_transform_func (typeof (Graphic.Glyph.EllipsizeMode), typeof (string), ellipsize_mode_to_string);
    }

    static void
    attribute_to_alignment (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Graphic.Glyph.Alignment.from_string (inAttribute.get ());
    }

    static void
    alignment_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Glyph.Alignment)))
    {
        Graphic.Glyph.Alignment val = (Graphic.Glyph.Alignment)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_wrap_mode (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Graphic.Glyph.WrapMode.from_string (inAttribute.get ());
    }

    static void
    wrap_mode_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Glyph.WrapMode)))
    {
        Graphic.Glyph.WrapMode val = (Graphic.Glyph.WrapMode)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_ellipsize_mode (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Graphic.Glyph.EllipsizeMode.from_string (inAttribute.get ());
    }

    static void
    ellipsize_mode_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Graphic.Glyph.EllipsizeMode)))
    {
        Graphic.Glyph.EllipsizeMode val = (Graphic.Glyph.EllipsizeMode)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("size");

        // Default color
        stroke_pattern = new Graphic.Color (0, 0, 0);

        // Default font
        font_description = "Sans 12";

        // connect onto layout properties changed
        notify["root"].connect (on_root_changed);
        notify["text"].connect (on_layout_property_changed);
        notify["alignment"].connect (on_layout_property_changed);
        notify["wrap-mode"].connect (on_layout_property_changed);
        notify["font-description"].connect (on_layout_property_changed);

        // connect onto draw properties changed
        notify["stroke-pattern"].connect (on_draw_property_changed);
        notify["shade-color"].connect (on_draw_property_changed);

        // connect onto hide_if_empty
        notify["hide-if-empty"].connect (on_hide_if_empty_changed);
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
    on_root_changed ()
    {
        // Create a fake surface to calculate the size of path
        m_FakeSurface = new Graphic.Surface (1, 1);

        // Get stack of items
        GLib.SList<unowned Item> list = new GLib.SList<unowned Item?> ();
        for (unowned Core.Object? item = this; item != null; item = item.parent)
        {
            if (item is Item)
            {
                list.append (item as Item);
            }
        }

        // Apply transform of all parents to fake surface
        foreach (unowned Item item in list)
        {
            m_FakeSurface.context.transform = item.transform;
        }
    }

    private void
    on_hide_if_empty_changed ()
    {
        if (hide_if_empty && visible && (text == null || text.length == 0))
        {
            visible = false;
            int count = get_qdata<int> (Item.s_CountHide);
            count++;
            set_qdata<int> (Item.s_CountHide, count);
        }
        else if (!hide_if_empty && !visible)
        {
            int count = get_qdata<int> (Item.s_CountHide);
            count = int.max (count - 1, 0);
            if (count == 0)
            {
                visible = true;
            }
            set_qdata<int> (Item.s_CountHide, count);
        }
    }

    private void
    on_layout_property_changed ()
    {
        m_Glyph = null;

        var item_size = size;

        if (hide_if_empty && visible && (text == null || text.length == 0))
        {
            visible = false;
            int count = get_qdata<int> (Item.s_CountHide);
            count++;
            set_qdata<int> (Item.s_CountHide, count);
        }
        else if (hide_if_empty && !visible && text != null && text.length > 0)
        {
            int count = get_qdata<int> (Item.s_CountHide);
            count = int.max (count - 1, 0);

            if (count == 0)
            {
                visible = true;
            }
            set_qdata<int> (Item.s_CountHide, count);
        }
        else if (area != null)
        {
            if (area.extents.size.width < item_size.width || area.extents.size.height < item_size.height)
            {
                var glyph_size = m_Glyph.size;
                if (xshrink && area.extents.size.width < item_size.width)
                {
                    glyph_size.width = area.extents.size.width;
                }
                if (yshrink && area.extents.size.height < item_size.height)
                {
                    glyph_size.height = area.extents.size.height;
                }
                m_Glyph.size = glyph_size;
                m_Glyph.update (m_FakeSurface.context);

                if (area.extents.size.width < m_Glyph.size.width || area.extents.size.height < m_Glyph.size.height)
                {
                    m_Glyph = null;
                    geometry = null;
                }
                else
                {
                    damage();
                }
            }
            else
            {
                damage();
            }
        }
        need_update = true;
    }

    private void
    on_draw_property_changed ()
    {
        damage ();
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
                // Reset wrap if any
                m_Glyph.size = Graphic.Size (0, 0);

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
        var allocation = inAllocation.extents;
        if (m_Glyph != null && ((xshrink && inAllocation.extents.size.width < m_Glyph.size.width) ||
                                (yshrink && inAllocation.extents.size.height < m_Glyph.size.height)))
        {
            var glyph_size = m_Glyph.size;
            if (xshrink && allocation.size.width < size.width)
            {
                glyph_size.width = allocation.size.width;
            }
            if (yshrink && allocation.size.height < size.height)
            {
                glyph_size.height = allocation.size.height;
            }
            m_Glyph.size = glyph_size;
            glyph_size = m_Glyph.size;

            glyph_size.transform (transform);
            allocation.size.width = double.max (glyph_size.width, allocation.size.width);
            allocation.size.height = double.max (glyph_size.height, allocation.size.height);
        }

        base.update (inContext, new Graphic.Region (allocation));
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint text
        if (m_Glyph != null && stroke_pattern != null)
        {
            inContext.save ();
            {
                var pos = Graphic.Point (0, 0);
                var glyph_size = m_Glyph.size;
                m_Glyph.size = area.extents.size;

                inContext.translate (Graphic.Point (0, (area.extents.size.height - glyph_size.height) / 2.0));
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
                inContext.pattern = stroke_pattern;
                inContext.render (m_Glyph);

                m_Glyph.size = glyph_size;
            }
            inContext.restore ();
        }
    }
}

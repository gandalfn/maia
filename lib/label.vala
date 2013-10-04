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

    internal override bool can_focus  {
        get {
            return parent is DrawingArea;
        }
        set {
            base.can_focus = value;
        }
    }

    public bool                        translatable     { get; set; default = true; }
    public string                      font_description { get; set; default = ""; }
    public Graphic.Glyph.Alignment     alignment        { get; set; default = Graphic.Glyph.Alignment.CENTER; }
    public Graphic.Glyph.WrapMode      wrap_mode        { get; set; default = Graphic.Glyph.WrapMode.WORD; }
    public Graphic.Glyph.EllipsizeMode ellipsize_mode   { get; set; default = Graphic.Glyph.EllipsizeMode.NONE; }
    public string                      text             { get; set; default = null; }
    public Graphic.Color               shade_color      { get; set; default = null; }

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
        // Default color
        stroke_pattern = new Graphic.Color (0, 0, 0);

        // Default font
        font_description = "Sans 12";

        // connect onto layout properties changed
        notify["root"].connect (on_layout_property_changed);
        notify["text"].connect (on_layout_property_changed);
        notify["alignment"].connect (on_layout_property_changed);
        notify["wrap-mode"].connect (on_layout_property_changed);
        notify["font-description"].connect (on_layout_property_changed);

        // connect onto draw properties changed
        notify["stroke-pattern"].connect (on_draw_property_changed);
        notify["shade-color"].connect (on_draw_property_changed);
    }

    public Label (string inId, string inLabel)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), text: inLabel);
    }

    private void
    on_layout_property_changed ()
    {
        m_Glyph = null;
        if (geometry != null)
        {
            var item_size = size;
            if (geometry.extents.size.width < item_size.width || geometry.extents.size.height < item_size.height)
            {
                var glyph_size = m_Glyph.size;
                if (xshrink && geometry.extents.size.width < item_size.width)
                {
                    glyph_size.width = geometry.extents.size.width;
                }
                if (yshrink && geometry.extents.size.height < item_size.height)
                {
                    glyph_size.height = geometry.extents.size.height;
                }
                m_Glyph.size = glyph_size;
                update_layout ();

                if (geometry.extents.size.width < m_Glyph.size.width || geometry.extents.size.height < m_Glyph.size.height)
                {
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

    private void
    update_layout ()
    {
        if (m_Glyph != null)
        {
            // Create a fake surface to calculate the size of path
            var fake_surface = new Graphic.Surface (1, 1);

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
                fake_surface.context.transform = item.transform;
            }

            m_Glyph.update (fake_surface.context);
        }
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
                update_layout ();

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
            if (xshrink && allocation.size.width < size_requested.width)
            {
                glyph_size.width = allocation.size.width;
            }
            if (yshrink && allocation.size.height < size_requested.height)
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
            unowned Document? doc = get_qdata<unowned Document> (Document.s_PageNumQuark);
            if (doc != null)
            {
                m_Glyph.text = "%u".printf (doc.current_page);
            }

            inContext.save ();
            {
                var pos = Graphic.Point (0, 0);
                var glyph_size = m_Glyph.size;
                m_Glyph.size = geometry.extents.size;
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

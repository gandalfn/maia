/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * document.vala
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

public class Maia.Document : Item
{
    // properties
    private Graphic.Surface         m_PageShadow;
    private Core.List<Page>         m_Pages;
    private Core.List<unowned Page> m_VisiblePages;

    // accessors
    internal override string tag {
        get {
            return "Document";
        }
    }

    internal override string characters { get; set; default = null; }

    internal override Graphic.Point origin {
        get {
            return position.invert ();
        }
    }

    public PageFormat format    { get; construct set; default = PageFormat.A4; }
    public double top_margin    { get; construct set; default = 0.25; }
    public double bottom_margin { get; construct set; default = 0.25; }
    public double left_margin   { get; construct set; default = 0.25; }
    public double right_margin  { get; construct set; default = 0.25; }

    public uint resolution { get; set; default = 96; }

    public int  border_width { get; set; default = 0; }
    public uint nb_pages {
        get {
            return m_Pages.length;
        }
    }

    public string header { get; set; default = null; }
    public string footer { get; set; default = null; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (PageFormat), attribute_to_page_format);

        GLib.Value.register_transform_func (typeof (PageFormat), typeof (string), page_format_to_string);
    }

    static void
    attribute_to_page_format (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = PageFormat.from_string (inAttribute.get ());
    }

    static void
    page_format_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (PageFormat)))
    {
        PageFormat val = (PageFormat)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("nb-pages");

        // create pages list
        m_Pages = new Core.List<Page> ();

        // create visible pages list
        m_VisiblePages = new Core.List<unowned Page> ();

        // connect onto border width and format change to create page shadow
        notify["format"].connect (on_page_shadow_change);
        notify["border-width"].connect (on_page_shadow_change);

        // connect onto position changed
        notify["position"].connect (on_position_changed);
    }

    public Document (string inId, PageFormat inFormat)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), format: inFormat);
    }

    ~Document ()
    {
        m_Pages.clear ();
        m_VisiblePages.clear ();
    }

    private void
    on_page_shadow_change ()
    {
        if (border_width > 0)
        {
            try
            {
                // Create page shadow
                var page_size = format.to_size (resolution);
                m_PageShadow = new Graphic.Surface ((uint)(page_size.width + border_width * 2), (uint)(page_size.height + border_width * 2));
                m_PageShadow.clear ();

                // Draw a black rectangle
                m_PageShadow.context.pattern = new Graphic.Color (0, 0, 0);
                var page_geometry = format.to_region (resolution);
                page_geometry.translate (Graphic.Point (border_width, border_width));
                var path = new Graphic.Path.from_region (page_geometry);
                m_PageShadow.context.fill (path);

                // Blur black rectangle for shadow
                m_PageShadow.exponential_blur (border_width / 2);

                // Paint white rectangle in page area
                m_PageShadow.context.pattern = new Graphic.Color (1, 1, 1);
                m_PageShadow.context.fill (path);
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "Error on page shadow: %s", err.message);
            }
        }
        else
        {
            m_PageShadow = null;
        }
    }

    private void
    append_page ()
    {
        // Create new page
        var page = new Page (this, m_Pages.length + 1);

        // Add header if any
        if (header != null)
        {
            unowned Item? header_item = find (GLib.Quark.from_string (header), false) as Item;
            if (header_item != null)
            {
                // we found header add to page
                page.header = header_item;
            }
            else
            {
                Log.error (GLib.Log.METHOD, Log.Category.CANVAS_PARSING, "Could not find %s header item in document", header);
            }
        }

        // Add footer if any
        if (footer != null)
        {
            unowned Item? footer_item = find (GLib.Quark.from_string (footer), false) as Item;
            if (footer_item != null)
            {
                // we found header add to page
                page.footer = footer_item;
            }
            else
            {
                Log.error (GLib.Log.METHOD, Log.Category.CANVAS_PARSING, "Could not find %s footer item in document", header);
            }
        }

        // Add page to list of page
        m_Pages.insert (page);
    }

    private void
    paginate_item (Item inItem, ref Graphic.Point inoutCurrentPosition)
    {
        // Get last page
        unowned Page? page = m_Pages.last ();

        if (inItem != page.header && inItem != page.footer)
        {
            // Get item allocated size
            var item_size = inItem.size;

            // Check if item size + current position does not overlap two page
            var page_content = page.content_geometry;
            if (inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
            {
                bool page_added = false;

                // Check if childs can be split in pages
                foreach (unowned Core.Object child in inItem)
                {
                    if (child is View)
                    {
                        unowned Item? child_item = child as Item;
                        if (child_item != null)
                        {
                            paginate_item (child_item, ref inoutCurrentPosition);
                            page_added = true;
                        }
                    }
                }

                if (!page_added)
                {
                    // Append a new page
                    append_page  ();

                    // Set current page
                    page = m_Pages.last ();

                    // Update current position
                    inoutCurrentPosition = page.content_geometry.extents.origin;
                }
            }

            // Add item to this page
            page.add (inItem);

            // Set item position
            inItem.position = inoutCurrentPosition;

            // Set width has page if item is direct child
            if (inItem.parent == this)
            {
                item_size.width = page.content_geometry.extents.size.width;
                inItem.size = item_size;
            }

            // Add item height to current position
            inoutCurrentPosition.y += item_size.height;
        }
    }

    private void
    paginate ()
    {
        // Clear page list
        m_Pages.clear ();

        // Clear visible page list
        m_VisiblePages.clear ();

        // Add first page
        append_page ();

        // Set current position
        Graphic.Point current_position = m_Pages.last ().content_geometry.extents.origin;

        // Parse all childs
        foreach (unowned Core.Object child in this)
        {
            unowned Item? item = child as Item;
            if (item != null);
            {
                paginate_item (item, ref current_position);
            }
        }
    }

    private void
    on_position_changed ()
    {
        if (geometry != null)
        {
            // Clear visible page list
            m_VisiblePages.clear ();

            // Get visible area
            var visible_area = geometry.copy ();
            visible_area.translate (position);

            // Update each page
            foreach (unowned Page page in m_Pages)
            {
                // If page is in document geometry add it to visible pages
                if (visible_area.contains_rectangle (page.geometry.extents) != Graphic.Region.Overlap.OUT)
                {
                    m_VisiblePages.insert (page);
                    page.damage (visible_area);
                }
                else if (m_VisiblePages.length > 0)
                {
                    break;
                }
            }
        }
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        // Paginate
        paginate ();

        // Calculate the size
        var page_size = format.to_size (resolution);
        page_size.resize (border_width * 2.0, border_width * 2.0);
        page_size.height *= m_Pages.length;
        page_size.transform (transform);

        return page_size;
    }

    internal override void
    on_child_damaged (Drawable inChild, Graphic.Region? inArea)
    {
        if (inChild.geometry != null)
        {
            unowned Page first = m_Pages.first ();
            if (first != null && (first.header == inChild || first.footer == inChild))
            {
                foreach (unowned Page page in m_VisiblePages)
                {
                    if (inChild == page.header)
                    {
                        var position = Graphic.Point (page.geometry.extents.origin.x + Core.convert_inch_to_pixel (left_margin),
                                                      page.geometry.extents.origin.y + Core.convert_inch_to_pixel (top_margin));

                        inChild.geometry.translate (inChild.geometry.extents.origin.invert ());
                        inChild.geometry.translate (position);
                    }
                    else if (inChild == page.footer)
                    {
                        var position = Graphic.Point (page.geometry.extents.origin.x + Core.convert_inch_to_pixel (left_margin),
                                                      page.geometry.extents.size.height - inChild.geometry.extents.size.height - Core.convert_inch_to_pixel (bottom_margin));

                        inChild.geometry.translate (inChild.geometry.extents.origin.invert ());
                        inChild.geometry.translate (position);
                    }

                    Graphic.Region damaged_area;

                    if (inArea == null)
                    {
                        damaged_area = inChild.geometry.copy ();
                    }
                    else
                    {
                        damaged_area = inArea.copy ();
                        damaged_area.transform (inChild.transform);
                        damaged_area.translate (inChild.geometry.extents.origin);
                    }

                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

                    // Remove the offset of scrolling
                    damaged_area.translate (position.invert ());
                    damaged_area.transform (transform);

                    // damage item
                    damage (damaged_area);
                }
            }
            else
            {
                Graphic.Region damaged_area;

                if (inArea == null)
                {
                    damaged_area = inChild.geometry.copy ();
                }
                else
                {
                    damaged_area = inArea.copy ();
                    damaged_area.transform (inChild.transform);
                    damaged_area.translate (inChild.geometry.extents.origin);
                }

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

                // Remove the offset of scrolling
                damaged_area.translate (position.invert ());
                damaged_area.transform (transform);

                // damage item
                damage (damaged_area);
            }
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            if (m_Pages.first () != null)
            {
                unowned Page first = m_Pages.first ();
                if (first.header != null && first.header.geometry == null)
                {
                    var item_size = first.header.size;
                    Graphic.Region header_allocation = new Graphic.Region (Graphic.Rectangle (geometry.extents.origin.x, geometry.extents.origin.y,
                                                                                              first.content_geometry.extents.size.width, item_size.height));

                    first.header.update (inContext, header_allocation);
                }

                if (first.footer != null && first.footer.geometry == null)
                {
                    var item_size = first.footer.size;
                    Graphic.Region footer_allocation = new Graphic.Region (Graphic.Rectangle (geometry.extents.origin.x, geometry.extents.origin.y,
                                                                                              first.content_geometry.extents.size.width, item_size.height));

                    first.footer.update (inContext, footer_allocation);
                }
            }

            on_position_changed ();

            // Update each page
            foreach (unowned Page page in m_Pages)
            {
                page.update (inContext);
            }

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        if (background_pattern != null)
        {
            inContext.save ();
            {
                unowned Graphic.Image? image = background_pattern as Graphic.Image;
                if (image != null)
                {
                    Graphic.Size image_size = image.size;
                    double scale = double.max (geometry.extents.size.width / image.size.width, geometry.extents.size.height / image.size.height);
                    image_size.width *= scale;
                    image_size.height *= scale;
                    (background_pattern as Graphic.Image).size = image_size;

                    inContext.pattern = background_pattern;
                    inContext.translate (Graphic.Point ((geometry.extents.size.width - image_size.width) / 2,
                                                        (geometry.extents.size.height - image_size.height) / 2));
                }
                else
                {
                    inContext.pattern = background_pattern;
                }

                inContext.paint ();
            }
            inContext.restore ();
        }

        // paint visible pages
        bool header_damaged = false;
        bool footer_damaged = false;
        foreach (unowned Page page in m_VisiblePages)
        {
            inContext.save ();
            {
                var page_position = Graphic.Point (0, ((format.to_size ().height + (border_width* 2.0)) * (page.num - 1)));
                var offset = position;
                page_position.translate (offset.invert ());

                inContext.translate (page_position);
                if (border_width > 0 && m_PageShadow != null)
                {
                    inContext.pattern = m_PageShadow;
                    inContext.paint ();
                }
            }
            inContext.restore ();

            inContext.save ();
            {
                if (page.header != null)
                {
                    if (header_damaged)
                    {
                        page.header.damage ();
                    }
                    else if (page.header.damaged != null)
                    {
                        header_damaged = true;
                    }
                }

                if (page.footer != null)
                {
                    if (footer_damaged)
                    {
                        page.footer.damage ();
                    }
                    else if (page.footer.damaged != null)
                    {
                        footer_damaged = true;
                    }
                }

                var offset = position;
                inContext.translate (offset.invert ());
                page.draw (inContext);
            }
            inContext.restore ();
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (ret)
        {
            try
            {
                // Translate point onto offset of visible area
                Graphic.Point point = inPoint;
                Graphic.Matrix matrix = transform.matrix;
                matrix.invert ();
                Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                point.transform (item_transform);
                point.translate (position);

                foreach (unowned Page page in m_VisiblePages)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $point");

                    // point under child
                    if (page.button_press_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        ret = false;
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        break;
                    }
                }
            }
            catch (Graphic.Error err)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
            }
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        if (ret)
        {
            try
            {
                // Translate point onto offset of visible area
                Graphic.Point point = inPoint;
                Graphic.Matrix matrix = transform.matrix;
                matrix.invert ();
                Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                point.transform (item_transform);
                point.translate (position);

                foreach (unowned Page page in m_VisiblePages)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $point");

                    // point under child
                    if (page.button_release_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        ret = false;
                        GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                        break;
                    }
                }
            }
            catch (Graphic.Error err)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
            }
        }

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        if (ret)
        {
            try
            {
                // Translate point onto offset of visible area
                Graphic.Point point = inPoint;
                Graphic.Matrix matrix = transform.matrix;
                matrix.invert ();
                Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                point.transform (item_transform);
                point.translate (position);

                foreach (unowned Page page in m_VisiblePages)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $point");

                    // point under child
                    if (page.motion_event (point))
                    {
                        // event occurate under child stop signal
                        ret = false;
                        GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                        break;
                    }
                }
            }
            catch (Graphic.Error err)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
            }
        }

        return ret;
    }

    internal override bool
    on_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        bool ret = false;

        if (geometry != null && inPoint in geometry)
        {
            try
            {
                // Translate point onto offset of visible area
                Graphic.Point point = inPoint;
                Graphic.Matrix matrix = transform.matrix;
                matrix.invert ();
                Graphic.Transform item_transform = new Graphic.Transform.from_matrix (matrix);
                point.transform (item_transform);
                point.translate (position);

                foreach (unowned Page page in m_VisiblePages)
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $point");

                    // point under child
                    if (page.scroll_event (inScroll, point))
                    {
                        // event occurate under child stop signal
                        ret = true;
                        break;
                    }
                }
            }
            catch (Graphic.Error err)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
            }
        }

        GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return ret;
    }
}

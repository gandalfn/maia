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
    // static
    internal static GLib.Quark s_PageBreakQuark;
    internal static GLib.Quark s_PageNumQuark;
    public static GLib.Quark s_PageBeginQuark;
    public static GLib.Quark s_PageTotalQuark;

    // types
    internal class PageBreak : GLib.Object
    {
        public unowned Document document;
        public uint num;
        public unowned Grid grid;
        public uint row;
        public double start;
        public double end;

        public PageBreak (Document inDocument, uint inNum, Grid inGrid, uint inRow, double inEnd, double inStart)
        {
            document = inDocument;
            num = inNum;
            grid = inGrid;
            row = inRow;
            start = inStart;
            end = inEnd;
        }
    }

    // properties
    private Graphic.Surface              m_PageShadow;
    private Core.List<Page>              m_Pages;
    private Core.List<unowned Page>      m_VisiblePages;
    private Core.List<unowned PageBreak> m_PageBreaks;
    private uint                         m_CurrentPage = 0;

    // accessors
    internal override string tag {
        get {
            return "Document";
        }
    }

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
    internal uint current_page {
        get {
            return m_CurrentPage;
        }
    }

    public string header { get; set; default = null; }
    public string footer { get; set; default = null; }

    public unowned Item? item_over_pointer { get; set; default = null; }

    // static methods
    static construct
    {
        s_PageBreakQuark = GLib.Quark.from_string ("MaiaDocumentPageBreakQuark");
        s_PageNumQuark = GLib.Quark.from_string ("MaiaDocumentPageNumQuark");
        s_PageBeginQuark = GLib.Quark.from_string ("MaiaDocumentPageBeginQuark");
        s_PageTotalQuark = GLib.Quark.from_string ("MaiaDocumentPageTotalQuark");

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
        not_dumpable_attributes.insert ("item-over-pointer");

        // create pages list
        m_Pages = new Core.List<Page> ();

        // create visible pages list
        m_VisiblePages = new Core.List<unowned Page> ();

        // create page break list
        m_PageBreaks = new Core.List<unowned PageBreak> ();

        // connect onto border width and format change to create page shadow
        notify["format"].connect (on_page_shadow_change);
        notify["border-width"].connect (on_page_shadow_change);
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
    add_page_break (PageBreak inPageBreak)
    {
        // try to get the list of break page in grid
        unowned Core.List<PageBreak>? list = inPageBreak.grid.get_qdata<unowned Core.List<PageBreak>?> (s_PageBreakQuark);

        // no page break create it
        if (list == null)
        {
            // Create the new list of page break for this grid
            Core.List<PageBreak>* new_list = new Core.List<PageBreak> ();

            // Set floating property with this list
            inPageBreak.grid.set_qdata_full (s_PageBreakQuark, new_list, (p) => {
                // The grid object has been destroyed remove all page break in document
                unowned Core.List<PageBreak>? l = (Core.List<PageBreak>)p;
                foreach (unowned PageBreak page_break in l)
                {
                    page_break.document.m_PageBreaks.remove (page_break);
                }

                // And finally delete the list
                unowned Core.List<PageBreak>* ptr = (Core.List<PageBreak>*)p;
                delete ptr;
            });

            // Set list from new list
            list = (Core.List<PageBreak>?)new_list;
        }

        // insert page break in grid list
        list.insert (inPageBreak);

        // insert page in document page break
        m_PageBreaks.insert (inPageBreak);
    }

    private void
    clear_page_breaks ()
    {
        Core.Set<unowned Grid> grids = new Core.Set<unowned Grid> ();

        // Parse all page_break and get grid
        foreach (unowned PageBreak page_break in m_PageBreaks)
        {
            grids.insert (page_break.grid);
        }

        // Remove floating property foreach grid
        foreach (unowned Grid grid in grids)
        {
            grid.set_qdata (s_PageBreakQuark, null);
        }

        // Finally clear page break list
        m_PageBreaks.clear ();
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
                page_size.resize (border_width * 2, border_width * 2);
                page_size.transform (transform);
                m_PageShadow = new Graphic.Surface ((uint)page_size.width, (uint)page_size.height);
                m_PageShadow.clear ();

                // Draw a black rectangle
                m_PageShadow.context.pattern = new Graphic.Color (0, 0, 0);
                var page_geometry = format.to_region (resolution);
                page_geometry.translate (Graphic.Point (border_width, border_width));
                page_geometry.transform (transform);
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
    paginate_child_item (Item inRoot, Item inItem, ref Graphic.Point inoutCurrentPosition, ref unowned Page inoutPage)
    {
        if (inItem != inoutPage.header && inItem != inoutPage.footer && inItem.visible)
        {
            bool add_height = true;

            // Get item allocated size
            var item_size = inItem.size;

            if (inItem is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)inItem;

                var page_content = inoutPage.content_geometry;
                inoutCurrentPosition.y += item.top_padding;
                item_size.height += item.bottom_padding;

                // Check if item size + current position does not overlap two page
                if (inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
                {
                    // Check if item can be added in new
                    if (item_size.height <= page_content.extents.size.height)
                    {
                        // Item can be added in new page
                        append_page  ();

                        // Set current page
                        inoutPage = m_Pages.last ();

                        // Update current position
                        var start = convert_to_root_space (inoutCurrentPosition);
                        inoutCurrentPosition = inoutPage.content_geometry.extents.origin;

                        // Convert positions to root space
                        var end = convert_to_root_space (inoutCurrentPosition);

                        // Add page break
                        PageBreak page_break = new PageBreak (this,
                                                              inoutPage.num,
                                                              item.parent as Grid, item.row,
                                                              end.y,
                                                              start.y);
                        add_page_break (page_break);
                    }
                    else if (inItem is Grid)
                    {

                        var pos = inoutCurrentPosition;

                        // Check if childs can be split in pages
                        uint last_row = 0;
                        foreach (unowned Core.Object child in inItem)
                        {
                            unowned ItemPackable? child_item = child as ItemPackable;
                            if (child_item != null)
                            {
                                paginate_child_item (inRoot, child_item, ref pos, ref inoutPage);
                                if (child_item.row > last_row)
                                {
                                    pos.y += (child_item.row - last_row) * (inItem as Grid).row_spacing;
                                    last_row = child_item.row;
                                }
                            }
                        }

                        inoutCurrentPosition.y = pos.y;
                        add_height = false;
                    }
                }
            }

            // Add root item to this page
            inoutPage.add (inRoot);

            if (inRoot.position.x == 0 && inRoot.position.y == 0)
            {
                inRoot.position = inoutCurrentPosition;
            }

            // Add the height of item to current position
            if (add_height)
            {
                inoutCurrentPosition.y += item_size.height;
            }
        }
    }

    private void
    paginate_item (Item inItem, ref Graphic.Point inoutCurrentPosition)
    {
        // Get last page
        unowned Page? page = m_Pages.last ();

        if (inItem != page.header && inItem != page.footer &&  !(inItem is Popup) && inItem.visible)
        {
            bool add_item_in_page = true;

            // Get item allocated size
            var item_size = inItem.size;

            // Check if item size + current position does not overlap two page
            var page_content = page.content_geometry;
            if (inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
            {
                // Append a new page
                append_page  ();

                // Set current page
                page = m_Pages.last ();

                // Update current position
                page_content = page.content_geometry;
                inoutCurrentPosition = page_content.extents.origin;

                // Item continue to not fit in page try to split child
                if (inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
                {
                    if (inItem is Grid)
                    {
                        add_item_in_page = false;

                        inItem.position = Graphic.Point (0, 0);

                        var pos = inoutCurrentPosition;
                        uint last_row = 0;

                        foreach (unowned Core.Object child in inItem)
                        {
                            unowned ItemPackable child_item = child as ItemPackable;
                            if (child_item != null)
                            {
                                paginate_child_item (inItem, child_item, ref pos, ref page);
                                if (child_item.row > last_row)
                                {
                                    pos.y += (child_item.row - last_row) * (inItem as Grid).row_spacing;
                                    last_row = child_item.row;
                                }
                            }
                        }

                        inoutCurrentPosition.y = pos.y;
                    }
                }
            }

            if (add_item_in_page)
            {
                // Add item to this page
                page.add (inItem);

                // Set item position
                inItem.position = inoutCurrentPosition;

                // Add item height to current position
                inoutCurrentPosition.y += item_size.height;
            }


            // Set width has page if item is direct child
            if (inItem.parent == this && item_size.width != page.content_geometry.extents.size.width)
            {
                item_size.width = page.content_geometry.extents.size.width;
                inItem.size = item_size;
            }
        }
    }

    private void
    paginate ()
    {
        uint old_nb_pages = nb_pages;

        // Clear page list
        m_Pages.clear ();

        // Clear visible page list
        m_VisiblePages.clear ();

        // Clear page breaks
        clear_page_breaks ();

        // Add first page
        append_page ();

        // Set size of header
        unowned Page? page = m_Pages.last ();

        if (page.header != null)
        {
            var item_size = page.header.size;

            // Set width has page
            if (item_size.width != page.content_geometry.extents.size.width)
            {
                item_size.width = page.content_geometry.extents.size.width;
                page.header.size = item_size;
            }
        }

        // Set size of footer
        if (page.footer != null)
        {
            var item_size = page.footer.size;

            // Set width has page
            if (item_size.width != page.content_geometry.extents.size.width)
            {
                item_size.width = page.content_geometry.extents.size.width;
                page.footer.size = item_size;
            }
        }

        // Set current position
        Graphic.Point current_position = m_Pages.last ().content_geometry.extents.origin;

        // Parse all childs
        foreach (unowned Core.Object child in this)
        {
            unowned Item? item = child as Item;
            if (item != null && item.visible)
            {
                paginate_item (item, ref current_position);
            }
        }

        // Try to get report nb pages
        uint nb = get_qdata<uint> (s_PageTotalQuark);
        if (nb == 0)
        {
            nb = nb_pages;
        }
        // Check if nb pages change if change emit signal for bind
        if (old_nb_pages != nb)
        {
            GLib.Signal.emit_by_name (this, "notify::nb_pages");
        }
    }

    private static void
    on_bind_value_changed (Manifest.AttributeBind inAttribute, Object inSrc, string inProperty)
    {
        if (inAttribute.get () == "nb_pages" || inAttribute.get () == "page_num")
        {
            uint nb = inSrc.get_qdata<uint> (s_PageTotalQuark);
            if (nb == 0)
            {
                nb = (inSrc as Document).nb_pages;
            }
            inAttribute.owner.set_property (inProperty, nb);
        }
    }

    private void
    on_attribute_bind_added (Manifest.AttributeBind inAttribute, string inProperty)
    {
        string name = inAttribute.get ();
        if (name == "page_num" || name == "nb_pages")
        {
            string signal_name = "notify::nb_pages";

            if (!inAttribute.is_bind (signal_name, inProperty))
            {
                inAttribute.bind (this, signal_name, inProperty, on_bind_value_changed);
            }

            if (name == "page_num")
            {
                inAttribute.owner.set_qdata<unowned Document> (s_PageNumQuark, this);
            }
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return base.can_append_child (inObject) || inObject is Shortcut;
    }

    internal override void
    on_read_manifest (Manifest.Document inDocument) throws Core.ParseError
    {
        inDocument.attribute_bind_added.connect (on_attribute_bind_added);
    }

    internal override void
    on_move ()
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

            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "Damage document %s", visible_area.extents.to_string ());
            damage (geometry);
        }
    }

    internal override void
    on_resize ()
    {
        damage ();
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
        size = page_size;
        page_size.transform (transform);

        return page_size;
    }

    internal override void
    on_child_damaged (Drawable inChild, Graphic.Region? inArea)
    {
        if (inChild is Popup)
        {
            base.on_child_damaged (inChild,  inArea);
        }
        else if (inChild.geometry != null)
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
                                                      page.geometry.extents.origin.y + page.geometry.extents.size.height  -
                                                      Core.convert_inch_to_pixel (bottom_margin) -
                                                      page.footer.geometry.extents.size.height);

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
                    Graphic.Region header_allocation = new Graphic.Region (Graphic.Rectangle (first.content_geometry.extents.origin.x, first.content_geometry.extents.origin.y - item_size.height,
                                                                                              first.content_geometry.extents.size.width, item_size.height));

                    first.header.update (inContext, header_allocation);
                }

                if (first.footer != null && first.footer.geometry == null)
                {
                    var item_size = first.footer.size;
                    Graphic.Region footer_allocation = new Graphic.Region (Graphic.Rectangle (first.content_geometry.extents.origin.x,
                                                                                              first.content_geometry.extents.origin.y + first.content_geometry.extents.size.height,
                                                                                              first.content_geometry.extents.size.width, item_size.height));

                    first.footer.update (inContext, footer_allocation);
                }
            }

            on_move ();

            // Update each page
            foreach (unowned Page page in m_Pages)
            {
                page.update (inContext);
            }

            foreach (unowned Core.Object child in this)
            {
                unowned Popup? popup = child as Popup;
                if (popup != null)
                {
                    var popup_position = popup.position;
                    var popup_size = popup.size;

                    popup.update (inContext, new Graphic.Region (Graphic.Rectangle (popup_position.x, popup_position.y, popup_size.width, popup_size.height)));
                }
            }
        }
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint visible pages
        bool header_damaged = false;
        foreach (unowned Page page in m_VisiblePages)
        {
            uint delta = get_qdata<uint> (s_PageBeginQuark);
            m_CurrentPage = page.num + delta;

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
                    else if (page.header.damaged != null && !page.header.damaged.is_empty ())
                    {
                        header_damaged = true;
                    }
                }

                foreach (unowned PageBreak page_break in m_PageBreaks)
                {
                    if (page_break.num == page.num && (page_break.grid.damaged == null || page_break.grid.damaged.is_empty ()))
                    {
                        Graphic.Point start_root, end_root;
                        start_root = page_break.grid.convert_to_root_space(Graphic.Point (0, 0));
                        end_root = page_break.grid.convert_to_root_space(Graphic.Point (page_break.grid.geometry.extents.size.width,
                                                                                        page_break.grid.geometry.extents.size.height));
                        Graphic.Point offset = Graphic.Point (0, page_break.end);

                        start_root.y = offset.y;

                        Graphic.Point start = page_break.grid.convert_to_item_space(start_root);
                        Graphic.Point end = page_break.grid.convert_to_item_space(end_root);

                        var damage_area = new Graphic.Region (Graphic.Rectangle (start.x, start.y, end.x - start.x, end.y - start.y));

                        page_break.grid.damage (damage_area);

                        break;
                    }
                }

                var offset = position;
                inContext.translate (offset.invert ());

                page.draw (inContext);
            }
            inContext.restore ();
        }

        inContext.save ();
        {
            foreach (unowned Core.Object child in this)
            {
                unowned Popup? popup = child as Popup;
                if (popup != null)
                {
                    popup.draw (inContext);
                }
            }
        }
        inContext.restore ();
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;

        try
        {
            // Check if event occur under popup
            foreach (unowned Core.Object child in this)
            {
                unowned Popup? popup = child as Popup;
                if (popup != null)
                {
                    var point = convert_to_root_space (inPoint);

                    var offset = popup.position.invert ();
                    var point_transform = new Graphic.Transform.identity ();
                    point_transform.translate (offset.x, offset.y);

                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    point_transform.add (transform_invert);

                    point.transform (point_transform);

                    // point under popup
                    if (popup.button_press_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        return false;
                    }
                }
            }

            foreach (unowned Page page in m_VisiblePages)
            {
                var point = convert_to_root_space (inPoint);
                var offset = origin.invert ();
                var point_transform = new Graphic.Transform.identity ();
                point_transform.translate (offset.x, offset.y);

                var matrix = transform.matrix;
                matrix.invert ();
                var transform_invert = new Graphic.Transform.from_matrix (matrix);
                point_transform.add (transform_invert);

                point.transform (point_transform);

                // point under child
                if (page.button_press_event (inButton, point))
                {
                    ret = true;
                    // event occurate under child stop signal
                    GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                    break;
                }
            }
        }
        catch (Graphic.Error err)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
        }

        if (!ret || !can_focus)
        {
            GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
        }
        else if (can_focus)
        {
            grab_focus (this);
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;

        try
        {
            // Check if event occur under popup
            foreach (unowned Core.Object child in this)
            {
                unowned Popup? popup = child as Popup;
                if (popup != null)
                {
                    var point = convert_to_root_space (inPoint);

                    var offset = popup.position.invert ();
                    var point_transform = new Graphic.Transform.identity ();
                    point_transform.translate (offset.x, offset.y);

                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    point_transform.add (transform_invert);

                    point.transform (point_transform);

                    // point under popup
                    if (popup.button_release_event (inButton, point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                        return false;
                    }
                }
            }

            foreach (unowned Page page in m_VisiblePages)
            {
                var point = convert_to_root_space (inPoint);
                var offset = origin.invert ();
                var point_transform = new Graphic.Transform.identity ();
                point_transform.translate (offset.x, offset.y);

                var matrix = transform.matrix;
                matrix.invert ();
                var transform_invert = new Graphic.Transform.from_matrix (matrix);
                point_transform.add (transform_invert);

                point.transform (point_transform);

                // point under child
                if (page.button_release_event (inButton, point))
                {
                    ret = true;
                    // event occurate under child stop signal
                    GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                    break;
                }
            }
        }
        catch (Graphic.Error err)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
        }

        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
        }

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = false;

        try
        {
            // Check if event occur under popup
            foreach (unowned Core.Object child in this)
            {
                unowned Popup? popup = child as Popup;
                if (popup != null)
                {
                    var point = convert_to_root_space (inPoint);

                    var offset = popup.position.invert ();
                    var point_transform = new Graphic.Transform.identity ();
                    point_transform.translate (offset.x, offset.y);

                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    point_transform.add (transform_invert);

                    point.transform (point_transform);

                    // point under popup
                    if (popup.motion_event (point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                        return false;
                    }
                }
            }

            foreach (unowned Page page in m_VisiblePages)
            {
                var point = convert_to_root_space (inPoint);
                var offset = origin.invert ();
                var point_transform = new Graphic.Transform.identity ();
                point_transform.translate (offset.x, offset.y);

                var matrix = transform.matrix;
                matrix.invert ();
                var transform_invert = new Graphic.Transform.from_matrix (matrix);
                point_transform.add (transform_invert);

                point.transform (point_transform);

                // point under child
                unowned Item? item = page.motion_event (point);
                if (item != null)
                {
                    // if item over pointer change unset pointer over for old item
                    if (item_over_pointer !=  null && item != item_over_pointer && item_over_pointer.pointer_over)
                    {
                        item_over_pointer.pointer_over = false;
                        item_over_pointer = item;
                    }

                    // event occurate under child stop signal
                    ret = true;
                    GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                    break;
                }
            }
        }
        catch (Graphic.Error err)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "error on convert point to page coordinates: %s", err.message);
        }

        // if item over pointer set unset it
        if (!ret)
        {
            GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);

            if (item_over_pointer !=  null && item_over_pointer.pointer_over)
            {
                item_over_pointer.pointer_over = false;
                item_over_pointer = null;
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
                // Check if event occur under popup
                foreach (unowned Core.Object child in this)
                {
                    unowned Popup? popup = child as Popup;
                    if (popup != null)
                    {
                        var point = convert_to_root_space (inPoint);

                        var offset = popup.position.invert ();
                        var point_transform = new Graphic.Transform.identity ();
                        point_transform.translate (offset.x, offset.y);

                        var matrix = transform.matrix;
                        matrix.invert ();
                        var transform_invert = new Graphic.Transform.from_matrix (matrix);
                        point_transform.add (transform_invert);

                        point.transform (point_transform);

                        // point under popup
                        if (popup.scroll_event (inScroll, point))
                        {
                            return true;
                        }
                    }
                }

                foreach (unowned Page page in m_VisiblePages)
                {
                    var point = convert_to_root_space (inPoint);
                    var offset = origin.invert ();
                    var point_transform = new Graphic.Transform.identity ();
                    point_transform.translate (offset.x, offset.y);

                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    point_transform.add (transform_invert);

                    point.transform (point_transform);

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

    public void
    draw_page (Graphic.Context inContext, uint inPageNum) throws Graphic.Error
    {
        inContext.save ();
        {
            foreach (unowned Page? page in m_Pages)
            {
                if (page.num == inPageNum)
                {
                    uint delta = get_qdata<uint> (s_PageBeginQuark);
                    m_CurrentPage = page.num + delta;

                    foreach (unowned PageBreak page_break in m_PageBreaks)
                    {
                        if (page_break.num == page.num && (page_break.grid.damaged == null || page_break.grid.damaged.is_empty ()))
                        {
                            Graphic.Point start_root, end_root;
                            start_root = page_break.grid.convert_to_root_space(Graphic.Point (0, 0));
                            end_root = page_break.grid.convert_to_root_space(Graphic.Point (page_break.grid.geometry.extents.size.width,
                                                                                            page_break.grid.geometry.extents.size.height));
                            Graphic.Point offset = Graphic.Point (0, page_break.end);

                            start_root.y = offset.y;


                            Graphic.Point start = page_break.grid.convert_to_item_space(start_root);
                            Graphic.Point end = page_break.grid.convert_to_item_space(end_root);

                            var damage_area = new Graphic.Region (Graphic.Rectangle (start.x, start.y, end.x - start.x, end.y - start.x));

                            page_break.grid.damage (damage_area);

                            break;
                        }
                    }

                    var page_position = Graphic.Point (0, ((format.to_size ().height + (border_width* 2.0)) * (page.num - 1)));
                    inContext.translate (page_position.invert ());
                    if (page.header != null) page.header.damage ();
                    if (page.footer != null) page.footer.damage ();
                    page.draw (inContext);
                    break;
                }
            }
        }
        inContext.restore ();
    }
}

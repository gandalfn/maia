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
    internal static GLib.Quark s_HeaderFooterQuark;
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
    private Core.List<unowned Item>      m_Items;
    private Graphic.Surface              m_PageShadow;
    private Core.List<Page>              m_Pages;
    private Core.List<unowned PageBreak> m_PageBreaks;

    // accessors
    internal override string tag {
        get {
            return "Document";
        }
    }

    public PageFormat format    { get; construct set; default = PageFormat.A4; }
    public double top_margin    { get; construct set; default = 0.12; }
    public double bottom_margin { get; construct set; default = 0.12; }
    public double left_margin   { get; construct set; default = 0.12; }
    public double right_margin  { get; construct set; default = 0.12; }

    public uint resolution { get; set; default = 96; }

    public int  border_width { get; set; default = 0; }
    public uint nb_pages {
        get {
            return m_Pages.length;
        }
    }

    public string header { get; set; default = null; }
    public string footer { get; set; default = null; }

    public unowned Item? item_over_pointer { get; set; default = null; }

    // static methods
    static construct
    {
        s_HeaderFooterQuark = GLib.Quark.from_string ("MaiaDocumentHeaderFooter");
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
        not_dumpable_attributes.insert ("current-page");
        not_dumpable_attributes.insert ("nb-pages");
        not_dumpable_attributes.insert ("item-over-pointer");
        not_dumpable_attributes.insert ("size");

        // create pages list
        m_Pages = new Core.List<Page> ();

        // create items list
        m_Items = new Core.List<unowned Item> ();

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
        clear_page_breaks ();
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

        // unset geometry to repaginate
        need_update = true;
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
    paginate_grid (Item inRoot, Grid inGrid, ref unowned Page inoutPage, ref Graphic.Point inoutCurrentPosition)
    {
        Graphic.Size row_size;
        int row = 0;
        while (inGrid.get_row_size (row, out row_size))
        {
            // Get page geometry
            var page_content = inoutPage.content_geometry;

            // Check if row can be added in page
            if (inoutCurrentPosition.y + row_size.height <= page_content.extents.origin.y + page_content.extents.size.height)
            {
                // Add grid in page
                inoutPage.add (inRoot);

                if (inRoot.position.y == 0)
                {
                    inRoot.position = inoutCurrentPosition;
                }

                inoutCurrentPosition.y += row_size.height;
            }
            // Check if grid row can be append in new page
            else if (row_size.height <= page_content.extents.size.height)
            {
                // Item can be added in new page
                append_page  ();

                // Set current page
                inoutPage = m_Pages.last ();

                // Update current position
                var start = convert_to_window_space (inoutCurrentPosition);
                inoutCurrentPosition = inoutPage.content_geometry.extents.origin;

                // Convert positions to window space
                var end = convert_to_window_space (inoutCurrentPosition);

                // Add page break
                PageBreak page_break = new PageBreak (this,
                                                      inoutPage.num,
                                                      inGrid, row,
                                                      end.y,
                                                      start.y);
                add_page_break (page_break);

                // Add root item to this page
                inoutPage.add (inRoot);

                if (inRoot.position.y == 0)
                {
                    inRoot.position = inoutCurrentPosition;
                }

                // Update current position
                inoutCurrentPosition.y += row_size.height;
            }
            else
            {
                // Parse all child in grid
                foreach (unowned Core.Object child in inGrid)
                {
                    unowned Grid? grid = child as Grid;
                    if (grid != null && grid.visible)
                    {
                        paginate_grid (inRoot, grid, ref inoutPage, ref inoutCurrentPosition);
                    }
                }
            }

            row++;
        }
    }

    private void
    paginate_item (Item inItem, ref Graphic.Point inoutCurrentPosition)
    {
        // Get last page
        unowned Page? page = m_Pages.last ();
        bool add_item_in_page = true;

        // Get item allocated size
        var item_size = inItem.size;

        // Check if item size + current position does not overlap two page
        var page_content = page.content_geometry;

        // If does not are on first page and item does not fit in end of page add a page
        if (page.num > 1 && inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
        {
            // Item can be added in new page
            append_page  ();

            // Set current page
            page = m_Pages.last ();

            // Update current position
            inoutCurrentPosition = page.content_geometry.extents.origin;
        }

        // Item do not fit in page try to split child
        if (inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
        {
            unowned Grid? grid = inItem as Grid;
            if (grid != null)
            {
                grid.position = Graphic.Point (0, 0);

                paginate_grid (grid, grid, ref page, ref inoutCurrentPosition);

                add_item_in_page = false;
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
    }

    private void
    paginate ()
    {
        // Clear page list
        m_Pages.clear ();

        // Clear page breaks
        clear_page_breaks ();

        // Add first page
        append_page ();

        // Set current position
        Graphic.Point current_position = m_Pages.last ().content_geometry.extents.origin;

        // Parse all childs
        foreach (unowned Item item in m_Items)
        {
            if (item != null && item.visible)
            {
                paginate_item (item, ref current_position);
            }
        }

        // emit signal for bind
        GLib.Signal.emit_by_name (this, "notify::nb_pages");
    }

    private static void
    on_bind_value_changed (Manifest.AttributeBind inAttribute, Object inSrc, string inProperty)
    {
        if (inAttribute.get () == "nb_pages")
        {
            uint nb = inSrc.get_qdata<uint> (s_PageTotalQuark);
            if (nb == 0)
            {
                nb = (inSrc as Document).nb_pages;
            }
            inAttribute.owner.set_property (inProperty, nb);
        }
        else if (inAttribute.get () == "page_num")
        {
            uint num = 0;
            uint start = 0;

            unowned Document doc = inSrc as Document;
            if (doc == null)
            {
                num = inSrc.get_qdata<uint> (s_PageNumQuark);
                start = ((inSrc as Core.Object).parent as Document).get_qdata<uint> (s_PageBeginQuark);
            }
            else
            {
                unowned Core.Object? item = inAttribute.owner as Core.Object;
                for (; item.parent != null && item.parent != doc; item = item.parent);

                num = item.get_qdata<uint> (s_PageNumQuark);
                start = doc.get_qdata<uint> (s_PageBeginQuark);
            }

            inAttribute.owner.set_property (inProperty, num + start);
        }
    }

    internal void
    on_attribute_bind_added (Manifest.AttributeBind inAttribute, string inProperty)
    {
        string name = inAttribute.get ();
        if (name == "nb_pages")
        {
            string signal_name = "notify::nb_pages";

            if (!inAttribute.is_bind (signal_name, inProperty))
            {
                inAttribute.bind (this, signal_name, inProperty, on_bind_value_changed);
            }
        }

        if (name == "page_num")
        {
            string signal_name = "notify::page_num";

            unowned Core.Object? item = inAttribute.owner as Core.Object;
            if (item != null)
            {
                // search the direct child of document which own page num property
                for (; item.parent != null && item.parent != this; item = item.parent);

                inAttribute.bind (item, signal_name, inProperty, on_bind_value_changed);

                // bind start page changed to add offset on report save
                inAttribute.bind (this, "notify::start_page", inProperty, on_bind_value_changed);
            }
        }
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        if (can_append_child (inObject))
        {
            unowned Item? item = inObject as Item;

            if (item != null)
            {
                bool is_header_footer = item.get_qdata (s_HeaderFooterQuark) || item.name == header || item.name == footer;
                if (!is_header_footer)
                {
                    m_Items.insert (item);
                }
            }
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        unowned Item? item = inObject as Item;

        if (item != null && m_Items != null)
        {
            bool is_header_footer = item.get_qdata (s_HeaderFooterQuark) || item.name == header || item.name == footer;
            if (!is_header_footer)
            {
                m_Items.remove (item);
            }
        }

        base.remove_child (inObject);
    }

    internal override void
    on_read_manifest (Manifest.Document inDocument) throws Core.ParseError
    {
        inDocument.attribute_bind_added.connect (on_attribute_bind_added);
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
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            // Update each page
            foreach (unowned Page page in m_Pages)
            {
                page.update (inContext);
            }
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint visible pages
        foreach (unowned Page page in m_Pages)
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
                page.draw (inContext, inArea);
            }
            inContext.restore ();
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;

        foreach (unowned Page page in m_Pages)
        {
            // point under child
            if (page.button_press_event (inButton, inPoint))
            {
                ret = true;
                // event occurate under child stop signal
                GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                break;
            }
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

        foreach (unowned Page page in m_Pages)
        {
            // point under child
            if (page.button_release_event (inButton, inPoint))
            {
                ret = true;
                // event occurate under child stop signal
                GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                break;
            }
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

        foreach (unowned Page page in m_Pages)
        {
            // point under child
            unowned Item? item = page.motion_event (inPoint);
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
            foreach (unowned Page page in m_Pages)
            {
                // point under child
                if (page.scroll_event (inScroll, inPoint))
                {
                    // event occurate under child stop signal
                    ret = true;
                    break;
                }
            }
        }

        GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return ret;
    }

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        // dump all others childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Manifest.Element && !(child is Item))
            {
                ret += inPrefix + (child as Manifest.Element).dump (inPrefix) + "\n";
            }
        }

        // dump item
        foreach (unowned Item item in m_Items)
        {
            ret += inPrefix + item.dump (inPrefix) + "\n";
        }

        return ret;
    }

    public virtual async void
    save (string inPdfFilename, double inDpi, GLib.Cancellable? inCancellable = null) throws Graphic.Error
    {
        throw new Graphic.Error.NOT_IMPLEMENTED ("Document save not implemented");
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
                    inContext.save ();
                    {
                        inContext.translate (page.geometry.extents.origin.invert ());
                        page.draw (inContext, page.geometry);
                    }
                    inContext.restore ();
                    break;
                }
            }
        }
        inContext.restore ();
    }
}

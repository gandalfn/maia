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
    private Core.List<unowned Item>      m_Items;
    private Core.List<unowned Popup>     m_Popups;
    private Core.List<unowned Shortcut>  m_Shortcuts;
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
    internal uint current_page {
        get {
            return m_CurrentPage;
        }
    }

    public string header { get; set; default = null; }
    public string footer { get; set; default = null; }

    public unowned Item? item_over_pointer { get; set; default = null; }

    public Graphic.Region? visible_area {
        owned get {
            Graphic.Region? ret = area.copy ();

            if (ret != null)
            {
                ret.translate (position);
            }

            return ret;
        }
    }

    public Core.List<unowned Shortcut>? shortcuts {
        get {
            return m_Shortcuts;
        }
    }

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
        not_dumpable_attributes.insert ("current-page");
        not_dumpable_attributes.insert ("nb-pages");
        not_dumpable_attributes.insert ("item-over-pointer");
        not_dumpable_attributes.insert ("size");

        // create pages list
        m_Pages = new Core.List<Page> ();

        // create items list
        m_Items = new Core.List<unowned Item> ();

        // create popups list
        m_Popups = new Core.List<unowned Popup> ();

        // create shortcuts list
        m_Shortcuts = new Core.List<unowned Shortcut> ();

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

        // unset geometry to repaginate
        geometry = null;
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
            var item_size = inItem.size_requested;

            if (inItem is ItemPackable)
            {
                unowned ItemPackable item = (ItemPackable)inItem;

                var page_content = inoutPage.content_geometry;
                inoutCurrentPosition.y += item.top_padding;
                item_size.height += item.bottom_padding;

                // Check if item size + current position does not overlap two page
                if (inoutCurrentPosition.y + item_size.height > page_content.extents.origin.y + page_content.extents.size.height)
                {
                    // Check if item can be added in new page
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
                            if (child_item != null && child_item.visible)
                            {
                                paginate_child_item (inRoot, child_item, ref pos, ref inoutPage);
                                if (child_item.row > last_row)
                                {
                                    pos.y += (inItem as Grid).row_spacing;
                                    last_row = child_item.row;
                                }
                            }
                        }

                        if (inoutCurrentPosition.y != pos.y)
                        {
                            inoutCurrentPosition.y = pos.y;
                            add_height = false;
                        }
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
                if (inItem is Grid)
                {
                    inItem.position = Graphic.Point (0, 0);

                    var pos = inoutCurrentPosition;
                    uint last_row = 0;

                    foreach (unowned Core.Object child in inItem)
                    {
                        unowned ItemPackable child_item = child as ItemPackable;
                        if (child_item != null && child_item.visible)
                        {
                            paginate_child_item (inItem, child_item, ref pos, ref page);
                            if (child_item.row > last_row)
                            {
                                pos.y += (inItem as Grid).row_spacing;
                                last_row = child_item.row;
                            }
                        }
                    }

                    if (inoutCurrentPosition.y != pos.y)
                    {
                        inoutCurrentPosition.y = pos.y;
                        add_item_in_page = false;
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
        foreach (unowned Item item in m_Items)
        {
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
            inAttribute.owner.set_qdata<unowned Document> (s_PageNumQuark, this);
        }
    }

    private Graphic.Point
    convert_to_document_space (Graphic.Point inPoint) throws Graphic.Error
    {
        var point = inPoint;
        var offset = position;
        var point_transform = new Graphic.Transform.identity ();
        point_transform.translate (offset.x, offset.y);

        var matrix = transform.matrix;
        matrix.invert ();
        var transform_invert = new Graphic.Transform.from_matrix (matrix);
        point_transform.add (transform_invert);

        point.transform (point_transform);

        return point;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        if (can_append_child (inObject))
        {
            if (inObject is Popup)
            {
                m_Popups.insert (inObject as Popup);
            }
            else if (inObject is Shortcut)
            {
                m_Shortcuts.insert (inObject as Shortcut);
            }
            else if (inObject is Item)
            {
                m_Items.insert (inObject as Item);
            }
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject is Popup && m_Popups != null)
        {
            m_Popups.remove (inObject as Popup);
        }
        else if (inObject is Shortcut && m_Shortcuts != null)
        {
            m_Shortcuts.remove (inObject as Shortcut);
        }
        else if (inObject is Item && m_Items != null)
        {
            m_Items.remove (inObject as Item);
        }

        base.remove_child (inObject);
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
    on_damage (Graphic.Region? inArea = null)
    {
        Graphic.Region damaged_area;
        if (inArea == null)
        {
            damaged_area = area.copy ();
        }
        else
        {
            damaged_area = inArea.copy ();
        }
        damaged_area.translate (position);

        base.on_damage (damaged_area);
    }

    internal override void
    on_move ()
    {
        if (geometry != null)
        {
            // Clear visible page list
            m_VisiblePages.clear ();

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

            // Update each popup
            foreach (unowned Popup popup in m_Popups)
            {
                // Toolbox popup move with document
                if (popup is Toolbox && popup.geometry != null)
                {
                    popup.geometry.translate (popup.geometry.extents.origin.invert ());
                    popup.geometry.translate (popup.position);
                    popup.geometry.translate (position);
                }

                if (popup != null && popup.visible)
                {
                    popup.damage ();
                }
            }
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "Damage document %s", visible_area.extents.to_string ());
            damage ();
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
        if (inChild.geometry != null)
        {
            if (!(inChild is Popup))
            {
                foreach (unowned Page page in m_VisiblePages)
                {
                    Graphic.Region damaged_area;

                    if (inArea == null)
                    {
                        damaged_area = inChild.geometry.copy ();
                    }
                    else
                    {
                        damaged_area = inChild.area_to_parent_item_space (inArea);
                    }

                    if (inChild == page.header)
                    {
                        var position = Graphic.Point (page.geometry.extents.origin.x + Core.convert_inch_to_pixel (left_margin),
                                                      page.geometry.extents.origin.y + Core.convert_inch_to_pixel (top_margin));

                        damaged_area = inChild.geometry.copy ();
                        damaged_area.translate (inChild.geometry.extents.origin.invert ());
                        damaged_area.translate (position);
                    }
                    else if (inChild == page.footer)
                    {
                        var position = Graphic.Point (page.geometry.extents.origin.x + Core.convert_inch_to_pixel (left_margin),
                                                      page.geometry.extents.origin.y + page.geometry.extents.size.height  -
                                                      Core.convert_inch_to_pixel (bottom_margin) -
                                                      page.footer.geometry.extents.size.height);

                        damaged_area = inChild.geometry.copy ();
                        damaged_area.translate (inChild.geometry.extents.origin.invert ());
                        damaged_area.translate (position);
                    }

                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

                    // Remove the offset of scrolling
                    damaged_area.translate (position.invert ());

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
                    damaged_area = inChild.area_to_parent_item_space (inArea);
                }

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "child item %s damaged, damage %s", (inChild as Item).name, damaged_area.extents.to_string ());

                // Remove the offset of scrolling
                damaged_area.translate (position.invert ());

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

            on_move ();

            // Update each page
            foreach (unowned Page page in m_Pages)
            {
                uint delta = get_qdata<uint> (s_PageBeginQuark);
                m_CurrentPage = page.num + delta;

                page.update (inContext);
            }

            foreach (unowned Popup popup in m_Popups)
            {
                var popup_position = popup.position;
                if (popup is Toolbox)
                {
                    popup_position.translate (position);
                }
                var popup_size = popup.size;

                popup.update (inContext, new Graphic.Region (Graphic.Rectangle (popup_position.x, popup_position.y, popup_size.width, popup_size.height)));
            }
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint visible pages
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
                inContext.translate (position.invert ());

                page.draw (inContext, inArea);
            }
            inContext.restore ();
        }

        foreach (unowned Popup popup in m_Popups)
        {
            inContext.save ();
            {
                var area = inArea.copy ();
                inContext.translate (position.invert ());
                area.translate (position);
                popup.draw (inContext, area_to_child_item_space (popup, area));
            }
            inContext.restore ();
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;

        try
        {
            var point = convert_to_root_space (inPoint);

            // Check if event occur under popup
            foreach (unowned Popup popup in m_Popups)
            {
                if (popup is Toolbox)
                {
                    unowned Toolbox? toolbox = (Toolbox)popup;

                    // convert point to toolbox space
                    var toolbox_point = point;
                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    toolbox_point.transform (transform_invert);
                    toolbox_point.translate (toolbox.position.invert ());

                    // point under toolbox
                    if (toolbox.button_press_event (inButton, toolbox_point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        return false;
                    }
                }
                else
                {
                    // convert point to popup space
                    var popup_point = convert_to_document_space (point);
                    popup_point.translate (popup.position.invert ());

                    // point under popup
                    if (popup.button_press_event (inButton, popup_point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        return false;
                    }
                }
            }

            foreach (unowned Page page in m_VisiblePages)
            {
                // point under child
                if (page.button_press_event (inButton, convert_to_document_space (point)))
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
            var point = convert_to_root_space (inPoint);

            // Check if event occur under popup
            foreach (unowned Popup popup in m_Popups)
            {
                if (popup is Toolbox)
                {
                    unowned Toolbox? toolbox = (Toolbox)popup;

                    // convert point to toolbox space
                    var toolbox_point = point;
                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    toolbox_point.transform (transform_invert);
                    toolbox_point.translate (toolbox.position.invert ());

                    // point under toolbox
                    if (toolbox.button_release_event (inButton, toolbox_point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                        return false;
                    }
                }
                else
                {
                    // convert point to popup space
                    var popup_point = convert_to_document_space (point);
                    popup_point.translate (popup.position.invert ());

                    // point under popup
                    if (popup.button_release_event (inButton, popup_point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                        return false;
                    }
                }
            }

            foreach (unowned Page page in m_VisiblePages)
            {
                // point under child
                if (page.button_release_event (inButton, convert_to_document_space (point)))
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
            var point = convert_to_root_space (inPoint);

            // Check if event occur under popup
            foreach (unowned Popup popup in m_Popups)
            {
                if (popup is Toolbox)
                {
                    unowned Toolbox? toolbox = (Toolbox)popup;

                    // convert point to toolbox space
                    var toolbox_point = point;
                    var matrix = transform.matrix;
                    matrix.invert ();
                    var transform_invert = new Graphic.Transform.from_matrix (matrix);
                    toolbox_point.transform (transform_invert);
                    toolbox_point.translate (toolbox.position.invert ());

                    // point under toolbox
                    if (toolbox.motion_event (toolbox_point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                        return false;
                    }
                }
                else
                {
                    // convert point to popup space
                    var popup_point = convert_to_document_space (point);
                    popup_point.translate (popup.position.invert ());

                    // point under popup
                    if (popup.motion_event (popup_point))
                    {
                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                        return false;
                    }
                }
            }

            foreach (unowned Page page in m_VisiblePages)
            {
                // point under child
                unowned Item? item = page.motion_event (convert_to_document_space (point));
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
            var point = convert_to_root_space (inPoint);

            try
            {
                // Check if event occur under popup
                foreach (unowned Popup popup in m_Popups)
                {
                    if (popup is Toolbox)
                    {
                        unowned Toolbox? toolbox = (Toolbox)popup;

                        // convert point to toolbox space
                        var toolbox_point = point;
                        var matrix = transform.matrix;
                        matrix.invert ();
                        var transform_invert = new Graphic.Transform.from_matrix (matrix);
                        toolbox_point.transform (transform_invert);
                        toolbox_point.translate (toolbox.position.invert ());

                        // point under toolbox
                        if (toolbox.scroll_event (inScroll, toolbox_point))
                        {
                            return true;
                        }
                    }
                    else
                    {
                        // convert point to popup space
                        var popup_point = convert_to_document_space (point);
                        popup_point.translate (popup.position.invert ());

                        // point under popup
                        if (popup.scroll_event (inScroll, popup_point))
                        {
                          return true;
                        }
                    }
                }

                foreach (unowned Page page in m_VisiblePages)
                {
                    // point under child
                    if (page.scroll_event (inScroll, convert_to_document_space (point)))
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

    internal override string
    dump_childs (string inPrefix)
    {
        string ret = "";

        // dump shortcuts
        foreach (unowned Shortcut shortcut in m_Shortcuts)
        {
            ret += inPrefix + shortcut.dump (inPrefix) + "\n";
        }

        // dump popup
        foreach (unowned Popup popup in m_Popups)
        {
            if (popup is Toolbox)
            {
                ret += inPrefix + popup.dump (inPrefix) + "\n";
            }
        }

        // dump all others childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Manifest.Element && !(child is Shortcut) && !(child is Popup) && !(child is Item))
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

                    var page_position = Graphic.Point (0, ((format.to_size ().height + (border_width* 2.0)) * (page.num - 1)));
                    inContext.translate (page_position.invert ());

                    if (page.header != null) page.header.damage ();
                    if (page.footer != null) page.footer.damage ();

                    page.draw (inContext, page.geometry);
                    break;
                }
            }
        }
        inContext.restore ();
    }

    public Graphic.Region
    get_item_visible_area (Item inItem)
    {
        Graphic.Region ret = new Graphic.Region ();

        if (inItem.visible && inItem.area != null)
        {
            Graphic.Point start = convert_to_item_space (inItem.convert_to_root_space (Graphic.Point (0, 0)));
            Graphic.Point end = convert_to_item_space (inItem.convert_to_root_space (Graphic.Point (inItem.area.extents.size.width, inItem.area.extents.size.height)));
            Graphic.Rectangle item_area = Graphic.Rectangle (start.x, start.y, start.x + end.x, start.y + end.y);

            ret = new Graphic.Region (item_area);
            ret.intersect (visible_area);

            if (!ret.is_empty ())
            {
                start = inItem.convert_to_item_space (convert_to_root_space (Graphic.Point (ret.extents.origin.x, ret.extents.origin.y)));
                end = inItem.convert_to_item_space (convert_to_root_space (Graphic.Point (ret.extents.origin.x + ret.extents.size.width, ret.extents.origin.y + ret.extents.size.height)));
                ret = new Graphic.Region (Graphic.Rectangle (start.x, start.y, start.x + end.x, start.y + end.y));
            }
        }

        return ret;
    }
}

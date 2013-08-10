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
    private uint m_NbPages = 0;
    private Graphic.Surface m_PageShadow;
    private Core.List<unowned Page> m_VisiblePages;

    // accessors
    internal override string tag {
        get {
            return "Document";
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
            return m_NbPages;
        }
    }

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

        // create visible pages list
        m_VisiblePages = new Core.List<unowned Page> ();

        // create first page
        var page = new Page (name + "-" + (m_NbPages + 1).to_string (), m_NbPages + 1);
        page.parent = this;

        // connect onto border width and format change to create page shadow
        notify["format"].connect (on_page_shadow_change);
        notify["border-width"].connect (on_page_shadow_change);
    }

    public Document (string inId, PageFormat inFormat)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), format: inFormat);
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
                m_PageShadow.exponential_blur (border_width);

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
    on_item_page_changed (Item inItem)
    {
        // Get last page
        unowned Page page = last () as Page;

        // Item has a page num
        if (inItem.page > 0)
        {
            if (m_NbPages >= inItem.page)
            {
                // Search page in child
                foreach (unowned Core.Object child in this)
                {
                    if (child is Page)
                    {
                        // we found page
                        if (((Page)child).num == inItem.page)
                        {
                            page = (Page)child;
                            break;
                        }
                    }
                }
            }
            else
            {
                // Create missing pages
                for (int cpt = (int)m_NbPages + 1; cpt <= inItem.page; ++cpt)
                {
                    var new_page = new Page (name + "-" + cpt.to_string (), cpt);
                    new_page.parent = this;
                    page = new_page;
                }
            }
        }

        // Append child in Page
        inItem.parent = page;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Page || inObject is ToggleGroup || inObject is Model;
    }

    internal override void
    insert_child (Core.Object inChild)
    {
        // If child is a page append child in document
        if (inChild is Page)
        {
            // Add page to document
            base.insert_child (inChild);

            // Connect onto item page changed
            ((Page)inChild).item_page_changed.connect (on_item_page_changed);

            // Increment counter of pages
            m_NbPages++;
        }
        // If child is not a page append child in good page
        else if (inChild is Item)
        {
            on_item_page_changed ((Item)inChild);
        }
        else
        {
            base.insert_child (inChild);
        }
    }

    internal override void
    remove_child (Core.Object inChild)
    {
        if (inChild is Page)
        {
            // Disconnect from item page changed
            ((Page)inChild).item_page_changed.disconnect (on_item_page_changed);

            // Decrement the counter of pages
            m_NbPages--;
        }

        base.remove_child (inChild);
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        var page_size = format.to_size (resolution);
        page_size.resize (border_width * 2.0, border_width * 2.0);
        page_size.height *= m_NbPages;

        return page_size;
    }

    internal override void
    on_child_damaged (Drawable inChild, Graphic.Region? inArea)
    {
        if (!(inChild is Page))
        {
            base.on_child_damaged (inChild, inArea);
        }
        else if (inChild.geometry != null)
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

            // damage item
            damage (damaged_area);
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            // Clear visible page list
            m_VisiblePages.clear ();

            // Get visible area
            var visible_area = inAllocation.copy ();
            visible_area.translate (position);
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "visible area: %s\n", visible_area.extents.to_string ());

            // Update page geometry
            foreach (unowned Core.Object child in this)
            {
                if (child is Page)
                {
                    Page page = (Page)child;

                    // Get paper size
                    Graphic.Region child_allocation = format.to_region ();

                    // Add margins
                    Graphic.Size child_size = child_allocation.extents.size;
                    child_size.resize (-Core.convert_inch_to_pixel (left_margin) - Core.convert_inch_to_pixel (right_margin),
                                       -Core.convert_inch_to_pixel (top_margin) - Core.convert_inch_to_pixel (bottom_margin));
                    child_allocation.resize (child_size);
                    child_allocation.translate (get_page_position (page.num));
                    child_allocation.translate (Graphic.Point (Core.convert_inch_to_pixel (left_margin), Core.convert_inch_to_pixel (top_margin)));

                    // Update page geometry
                    page.update (inContext, child_allocation);

                    // If page is in document geometry add it to visible pages
                    if (visible_area.contains_rectangle (page.geometry.extents) != Graphic.Region.Overlap.OUT)
                    {
                        m_VisiblePages.insert (page);
                    }
                }
            }


            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        // paint background
        if (background != null)
        {
            inContext.save ();
            {
                unowned Graphic.Image? image = background as Graphic.Image;
                if (image != null)
                {
                    Graphic.Size image_size = image.size;
                    double scale = double.max (geometry.extents.size.width / image.size.width, geometry.extents.size.height / image.size.height);
                    image_size.width *= scale;
                    image_size.height *= scale;
                    (background as Graphic.Image).size = image_size;

                    inContext.pattern = background;
                    inContext.translate (Graphic.Point ((geometry.extents.size.width - image_size.width) / 2,
                                                        (geometry.extents.size.height - image_size.height) / 2));
                }
                else
                {
                    inContext.pattern = background;
                }

                inContext.paint ();
            }
            inContext.restore ();
        }

        // paint visible pages
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
                var offset = position;
                inContext.translate (offset.invert ());
                page.draw (inContext);
            }
            inContext.restore ();
        }
    }

    internal override string
    to_string ()
    {
        string ret = dump_declaration ();

        if (ret != "")
        {
            ret += " {\n";

            ret += dump_attributes ();

            foreach (unowned Core.Object child in this)
            {
                if (child is Page)
                {
                    ret += (child as Page).dump_childs ();
                }
                else
                {
                    ret += (child as Manifest.Element).dump_childs ();
                }
            }

            ret += "}\n";
        }

        return ret;
    }

    internal Graphic.Point
    get_page_position (uint inPageNum)
    {
        return Graphic.Point (border_width, border_width + ((format.to_size ().height + (border_width* 2.0)) * (inPageNum - 1)));
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (ret)
        {
            // Translate point onto offset of visible area
            Graphic.Point point = inPoint;
            point.translate (position);

            foreach (unowned Page page in m_VisiblePages)
            {
                var child_point = convert_to_child_item_space (page, point);

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $child_point");

                // point under child
                if (page.button_press_event (inButton, child_point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "press event in %s document %s", page.name, name);

                    // event occurate under child stop signal
                    ret = false;
                    GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                    break;
                }
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
            // Translate point onto offset of visible area
            Graphic.Point point = inPoint;
            point.translate (position);

            foreach (unowned Page page in m_VisiblePages)
            {
                var child_point = convert_to_child_item_space (page, point);

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $child_point");

                // point under child
                if (page.button_release_event (inButton, child_point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "release event in %s document %s", page.name, name);

                    // event occurate under child stop signal
                    ret = false;
                    GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                    break;
                }
            }
        }

        return ret;
    }

    internal override bool
    on_motion_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inButton, inPoint);

        if (ret)
        {
            // Translate point onto offset of visible area
            Graphic.Point point = inPoint;
            point.translate (position);

            foreach (unowned Page page in m_VisiblePages)
            {
                var child_point = convert_to_child_item_space (page, point);

                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"inPoint: $inPoint point: $child_point");

                // point under child
                if (page.motion_event (inButton, child_point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "motion event in %s document %s", page.name, name);

                    // event occurate under child stop signal
                    ret = false;
                    GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                    break;
                }
            }
        }

        return ret;
    }
}

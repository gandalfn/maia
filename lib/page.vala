/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * page.vala
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

public enum Maia.PageFormat
{
    A4,
    LETTER;

    public string
    to_string ()
    {
        switch (this)
        {
            case A4:
                return "a4";
            case LETTER:
                return "letter";
        }

        return "a4";
    }

    public Graphic.Size
    to_size (double inDpi = 96)
    {
        switch (this)
        {
            case A4:
                return Graphic.Size (Core.convert_mm_to_pixel (210, inDpi), Core.convert_mm_to_pixel (297, inDpi));
            case LETTER:
                return Graphic.Size (Core.convert_inch_to_pixel (8.5, inDpi), Core.convert_inch_to_pixel (11, inDpi));
        }

        return Graphic.Size (0, 0);
    }

    public Graphic.Region
    to_region (double inDpi = 96)
    {
        Graphic.Size size = to_size (inDpi);
        return new Graphic.Region (Graphic.Rectangle (0, 0, size.width, size.height));
    }

    public static PageFormat
    from_string (string inFormat)
    {
        switch (inFormat.down ())
        {
            case "a4":
                return PageFormat.A4;
            case "letter":
                return PageFormat.LETTER;
        }

        return PageFormat.A4;
    }
}

internal class Maia.Page : GLib.Object
{
    // properties
    private unowned Document        m_Document;
    private Core.List<unowned Item> m_Childs;

    // accessors
    public uint num { get; set; default = 1; }
    public unowned Item? header { get; set; default = null; }
    public unowned Item? footer { get; set; default = null; }


    public Graphic.Region geometry {
        owned get {
            // Get formal position of page
            var position = Graphic.Point (m_Document.border_width,
                                          m_Document.border_width + ((m_Document.format.to_size ().height + (m_Document.border_width * 2.0)) * (num - 1)));

            // Get formal page size
            var size = m_Document.format.to_size ();

            return new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));
        }
    }

    public Graphic.Region content_geometry {
        owned get {
            // Get formal position of page
            var position = Graphic.Point (m_Document.border_width,
                                          m_Document.border_width + ((m_Document.format.to_size ().height + (m_Document.border_width * 2.0)) * (num - 1)));

            // Add margins
            position.translate (Graphic.Point (Core.convert_inch_to_pixel (m_Document.left_margin),
                                               Core.convert_inch_to_pixel (m_Document.top_margin)));

            // Add header height
            if (m_Document.header != null)
            {
                double height = header.size_requested.height;
                if (height == 0)
                    height = header.size.height;

                position.translate (Graphic.Point (0, height));
            }

            // Get formal page size
            var size = m_Document.format.to_size ();

            // Suppress margins
            size.resize (-Core.convert_inch_to_pixel (m_Document.left_margin + m_Document.right_margin),
                         -Core.convert_inch_to_pixel (m_Document.top_margin + m_Document.bottom_margin));

            // Suppress header height
            if (m_Document.header != null)
            {
                double height = header.size_requested.height;
                if (height == 0)
                    height = header.size.height;
                size.resize (0, -height);
            }

            // Suppress footer height
            if (m_Document.footer != null)
            {
                double height = footer.size_requested.height;
                if (height == 0)
                    height = footer.size.height;
                size.resize (0, -height);
            }

            return new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));
        }
    }

    // methods
    public Page (Document inDocument, uint inPageNum)
    {
        m_Document = inDocument;
        m_Childs = new Core.List<unowned Item> ();
        num = inPageNum;
    }

    public void
    add (Item inItem)
    {
        if (inItem != header && inItem != footer && !(inItem in m_Childs))
        {
            // Insert child in list
            m_Childs.insert (inItem);
        }
    }

    public void
    damage (Graphic.Region inArea)
    {
        var area = inArea.copy ();
        area.translate (m_Document.position);

        if (header != null && header.geometry != null && header.visible)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

            header.geometry.translate (header.geometry.extents.origin.invert ());
            header.geometry.translate (position);

            var child_area = area.copy ();
            child_area.intersect (header.geometry);
            child_area.translate (header.geometry.extents.origin.invert ());
            if (!child_area.is_empty () && (header.damaged == null ||
                header.damaged.contains_rectangle (child_area.extents) != Graphic.Region.Overlap.IN))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "Damage page %u item %s : %s", num, header.name, child_area.extents.to_string ());
                header.damage (child_area);
            }
        }

        if (footer != null && footer.geometry != null && footer.visible)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + geometry.extents.size.height  -
                                          Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                          footer.geometry.extents.size.height);


            footer.geometry.translate (footer.geometry.extents.origin.invert ());
            footer.geometry.translate (position);

            var child_area = area.copy ();
            child_area.intersect (footer.geometry);
            child_area.translate (footer.geometry.extents.origin.invert ());
            if (!child_area.is_empty () && (footer.damaged == null ||
                footer.damaged.contains_rectangle (child_area.extents) != Graphic.Region.Overlap.IN))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "Damage page %u item %s : %s", num, footer.name, child_area.extents.to_string ());
                footer.damage (child_area);
            }
        }

        foreach (unowned Item child in m_Childs)
        {
            if (child.geometry != null && child.visible)
            {
                var child_area = m_Document.area_to_child_item_space (child, area);
                if (!child_area.is_empty () && (child.damaged == null ||
                    child.damaged.contains_rectangle (child_area.extents) != Graphic.Region.Overlap.IN))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "Damage page %u item %s : %s", num, child.name, child_area.extents.to_string ());
                    child.damage (child_area);
                }
            }
        }
    }

    public void
    update (Graphic.Context inContext) throws Graphic.Error
    {
        if (header != null)
        {
            inContext.save ();
            {
                var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                              geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

                var size = Graphic.Size (content_geometry.extents.size.width, header.size_requested.height);

                var header_geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));

                header.update (inContext, header_geometry);

                header.damage ();
            }
            inContext.restore ();
        }

        if (footer != null)
        {
            inContext.save ();
            {
                var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                              geometry.extents.origin.y + geometry.extents.size.height  -
                                              Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                              footer.size_requested.height);

                var size = Graphic.Size (content_geometry.extents.size.width, footer.size_requested.height);

                var footer_geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));

                footer.update (inContext, footer_geometry);

                footer.damage ();
            }
            inContext.restore ();
        }

        foreach (unowned Item child in m_Childs)
        {
            if (child.geometry == null)
            {
                // Get child position and size
                var item_position = child.position;
                var item_size     = child.size_requested;

                // Set child size allocation
                var child_allocation = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, content_geometry.extents.size.width, item_size.height));
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Update page %u item %s", num, child.name);
                child.update (inContext, child_allocation);
            }
        }
    }

    public void
    draw (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, "Draw page %u", num);

        inContext.save ();
        {
            if (header != null && header.geometry != null)
            {
                inContext.save ();
                {
                    var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                                  geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

                    header.geometry.translate (header.geometry.extents.origin.invert ());
                    header.geometry.translate (position);

                    var area = inArea.copy ();
                    area.translate (m_Document.position);

                    header.draw (inContext, m_Document.area_to_child_item_space (header, area));
                }
                inContext.restore ();
            }

            if (footer != null && footer.geometry != null)
            {
                inContext.save ();
                {
                    var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                                  geometry.extents.origin.y + geometry.extents.size.height  -
                                                  Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                                  footer.geometry.extents.size.height);


                    footer.geometry.translate (footer.geometry.extents.origin.invert ());
                    footer.geometry.translate (position);

                    var area = inArea.copy ();
                    area.translate (m_Document.position);

                    footer.draw (inContext, m_Document.area_to_child_item_space (footer, area));
                }
                inContext.restore ();
            }


            foreach (unowned Item item in m_Childs)
            {
                var area = inArea.copy ();
                area.translate (m_Document.position);
                area.intersect (geometry);
                var damaged_area = m_Document.area_to_child_item_space (item, area);

                if (!damaged_area.is_empty ())
                {
                    item.draw (inContext, damaged_area);
                }
            }
        }
        inContext.restore ();
    }

    public bool
    button_press_event (uint inButton, Graphic.Point inPoint)
    {
        // parse child from last to first since item has sorted by layer
        Core.Iterator<unowned Item> iter = m_Childs.end ();
        if (iter.get () != null)
        {
            do
            {
                // Transform point to item coordinate space
                Graphic.Point point = m_Document.convert_to_child_item_space (iter.get (), inPoint);

                // point under child
                if (iter.get ().button_press_event (inButton, point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", iter.get ().name, num);
                    return true;
                }
            } while (iter.prev ());
        }

        // Check if event is under header
        if (header != null && header.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

            header.geometry.translate (header.geometry.extents.origin.invert ());
            header.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (header, inPoint);

            if (header.button_press_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in header %s page %u", header.name, num);
                return true;
            }
        }


        // Check if event is under footer
        if (footer != null && footer.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + geometry.extents.size.height  -
                                          Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                          footer.geometry.extents.size.height);

            footer.geometry.translate (footer.geometry.extents.origin.invert ());
            footer.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (footer, inPoint);

            if (footer.button_press_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in footer %s page %u", footer.name, num);
                return true;
            }
        }

        return false;
    }

    public bool
    button_release_event (uint inButton, Graphic.Point inPoint)
    {
        // parse child from last to first since item has sorted by layer
        Core.Iterator<unowned Item> iter = m_Childs.end ();
        if (iter.get () != null)
        {
            do
            {
                // Transform point to item coordinate space
                Graphic.Point point = m_Document.convert_to_child_item_space (iter.get (), inPoint);

                // point under child
                if (iter.get ().button_release_event (inButton, point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button release event in %s page %u", iter.get ().name, num);
                    return true;
                }
            } while (iter.prev ());
        }

        // Check if event is under header
        if (header != null && header.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

            header.geometry.translate (header.geometry.extents.origin.invert ());
            header.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (header, inPoint);

            if (header.button_release_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button release event in header %s page %u", header.name, num);
                return true;
            }
        }


        // Check if event is under footer
        if (footer != null && footer.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + geometry.extents.size.height  -
                                          Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                          footer.geometry.extents.size.height);

            footer.geometry.translate (footer.geometry.extents.origin.invert ());
            footer.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (footer, inPoint);

            if (footer.button_release_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button release event in footer %s page %u", footer.name, num);
                return true;
            }
        }

        return false;
    }

    public unowned Item?
    motion_event (Graphic.Point inPoint)
    {
        // parse child from last to first since item has sorted by layer
        Core.Iterator<unowned Item> iter = m_Childs.end ();
        if (iter.get () != null)
        {
            do
            {
                // Transform point to item coordinate space
                Graphic.Point point = m_Document.convert_to_child_item_space (iter.get (), inPoint);

                // point under child
                if (iter.get ().motion_event (point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "motion event in %s page %u", iter.get ().name, num);
                    return iter.get ();
                }
            } while (iter.prev ());
        }

        // Check if event is under header
        if (header != null && header.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

            header.geometry.translate (header.geometry.extents.origin.invert ());
            header.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (header, inPoint);

            if (header.motion_event (point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "motion event in header %s page %u", header.name, num);
                return header;
            }
        }


        // Check if event is under footer
        if (footer != null && footer.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + geometry.extents.size.height  -
                                          Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                          footer.geometry.extents.size.height);

            footer.geometry.translate (footer.geometry.extents.origin.invert ());
            footer.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (footer, inPoint);

            if (footer.motion_event (point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "motion event in footer %s page %u", footer.name, num);
                return footer;
            }
        }

        return null;
    }

    public bool
    scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        // parse child from last to first since item has sorted by layer
        Core.Iterator<unowned Item> iter = m_Childs.end ();
        if (iter.get () != null)
        {
            do
            {
                // Transform point to item coordinate space
                Graphic.Point point = m_Document.convert_to_child_item_space (iter.get (), inPoint);

                // point under child
                if (iter.get ().scroll_event (inScroll, point))
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll event in %s page %u", iter.get ().name, num);
                    return true;
                }
            } while (iter.prev ());
        }

        // Check if event is under header
        if (header != null && header.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

            header.geometry.translate (header.geometry.extents.origin.invert ());
            header.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (header, inPoint);

            if (header.scroll_event (inScroll, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll event in header %s page %u", header.name, num);
                return true;
            }
        }


        // Check if event is under footer
        if (footer != null && footer.geometry != null)
        {
            var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                          geometry.extents.origin.y + geometry.extents.size.height  -
                                          Core.convert_inch_to_pixel (m_Document.bottom_margin) -
                                          footer.geometry.extents.size.height);

            footer.geometry.translate (footer.geometry.extents.origin.invert ());
            footer.geometry.translate (position);

            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (footer, inPoint);

            if (footer.scroll_event (inScroll, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "scroll event in footer %s page %u", footer.name, num);
                return true;
            }
        }

        return false;
    }
}

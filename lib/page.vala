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
    private unowned Item?           m_Header = null;
    private unowned Item?           m_Footer = null;
    private Core.List<unowned Item> m_Childs;

    // accessors
    public uint num { get; set; default = 1; }

    public unowned Item? header {
        get {
            return m_Header;
        }
        set {
            if (m_Header != null)
            {
                m_Childs.remove (m_Header);
                m_Header.parent = null;
                m_Header = null;
            }
            try
            {
                var new_header = value.duplicate (@"$(value.name)-$(num)", m_Document.on_attribute_bind_added) as Item;
                m_Header = new_header;
                m_Header.set_qdata<bool> (Document.s_HeaderFooterQuark, true);
                m_Childs.insert (m_Header);
                m_Header.parent = m_Document;
                m_Header.set_qdata<uint>(Document.s_PageNumQuark, num);
                GLib.Signal.emit_by_name (m_Header, "notify::page_num");
            }
            catch (GLib.Error err)
            {
                Log.error (GLib.Log.METHOD, Log.Category.CANVAS_LAYOUT, @"Error on duplicate header $(value.name): $(err.message)");
                m_Header = null;
            }
        }
    }

    public unowned Item? footer {
        get {
            return m_Footer;
        }
        set {
            if (m_Footer != null)
            {
                m_Childs.remove (m_Footer);
                m_Footer.parent = null;
                m_Footer = null;
            }
            try
            {
                var new_footer = value.duplicate (@"$(value.name)-$(num)", m_Document.on_attribute_bind_added) as Item;
                m_Footer = new_footer;
                m_Footer.set_qdata<bool> (Document.s_HeaderFooterQuark, true);
                m_Childs.insert (m_Footer);
                m_Footer.parent = m_Document;
                m_Footer.set_qdata<uint>(Document.s_PageNumQuark, num);
                GLib.Signal.emit_by_name (m_Footer, "notify::page_num");
            }
            catch (GLib.Error err)
            {
                Log.error (GLib.Log.METHOD, Log.Category.CANVAS_LAYOUT, @"Error on duplicate footer $(value.name): $(err.message)");
                m_Footer = null;
            }
        }
    }

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
            if (m_Header != null)
            {
                position.translate (Graphic.Point (0, m_Header.size.height));
            }

            // Get formal page size
            var size = m_Document.format.to_size ();

            // Suppress margins
            size.resize (-Core.convert_inch_to_pixel (m_Document.left_margin + m_Document.right_margin),
                         -Core.convert_inch_to_pixel (m_Document.top_margin + m_Document.bottom_margin));

            // Suppress header height
            if (m_Header != null)
            {
                size.resize (0, -m_Header.size.height);
            }

            // Suppress footer height
            if (m_Footer != null)
            {
                size.resize (0, -m_Footer.size.height);
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

    ~Page ()
    {
        foreach (unowned Item item in m_Childs)
        {
            item.steal_qdata<uint>(Document.s_PageNumQuark);
        }

        if (m_Header != null)
        {
            m_Header.parent = null;
            m_Header = null;
        }

        if (m_Footer != null)
        {
            m_Footer.parent = null;
            m_Footer = null;
        }
    }

    public void
    add (Item inItem)
    {
        if (!(inItem in m_Childs))
        {
            // Insert child in list
            m_Childs.insert (inItem);

            // Set page num
            inItem.set_qdata<uint>(Document.s_PageNumQuark, num);
            GLib.Signal.emit_by_name (inItem, "notify::page_num");
        }
    }

    public void
    update (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_Header != null)
        {
            inContext.save ();
            {
                var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                              geometry.extents.origin.y + Core.convert_inch_to_pixel (m_Document.top_margin));

                var size = Graphic.Size (content_geometry.extents.size.width, m_Header.size.height);

                var header_geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));

                m_Header.update (inContext, header_geometry);
            }
            inContext.restore ();
        }

        if (m_Footer != null)
        {
            inContext.save ();
            {
                var position = Graphic.Point (geometry.extents.origin.x + Core.convert_inch_to_pixel (m_Document.left_margin),
                                              geometry.extents.origin.y + geometry.extents.size.height  -
                                                Core.convert_inch_to_pixel (m_Document.bottom_margin) - m_Footer.size.height);

                var size = Graphic.Size (content_geometry.extents.size.width, footer.size.height);

                var footer_geometry = new Graphic.Region (Graphic.Rectangle (position.x, position.y, size.width, size.height));

                m_Footer.update (inContext, footer_geometry);
            }
            inContext.restore ();
        }

        foreach (unowned Item child in m_Childs)
        {
            if (child != m_Header && child != m_Footer)
            {
                // Get child position and size
                var item_position = child.position;
                var item_size     = child.size;

                // Set child size allocation
                var child_allocation = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, content_geometry.extents.size.width, item_size.height));

                child.update (inContext, child_allocation);
            }
        }
    }

    public void
    draw (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        var area = inArea.copy ();
        area.intersect (geometry);

        if (!area.is_empty ())
        {
            inContext.save ();
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, "Draw page %u", num);

                foreach (unowned Item item in m_Childs)
                {
                    var damaged_area = m_Document.area_to_child_item_space (item, area);

                    if (!damaged_area.is_empty ())
                    {
                        item.draw (inContext, damaged_area);
                    }
                }
            }
            inContext.restore ();
        }
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
        if (m_Header != null && m_Header.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Header, inPoint);

            // point under child
            if (m_Header.button_press_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Header.name, num);
                return true;
            }
        }

        // Check if event is under footer
        if (m_Footer != null && m_Footer.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Footer, inPoint);

            // point under child
            if (m_Footer.button_press_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Footer.name, num);
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
        if (m_Header != null && m_Header.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Header, inPoint);

            // point under child
            if (m_Header.button_release_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Header.name, num);
                return true;
            }
        }

        // Check if event is under footer
        if (m_Footer != null && m_Footer.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Footer, inPoint);

            // point under child
            if (m_Footer.button_release_event (inButton, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Footer.name, num);
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
        if (m_Header != null && m_Header.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Header, inPoint);

            // point under child
            if (m_Header.motion_event (point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Header.name, num);
                return m_Header;
            }
        }

        // Check if event is under footer
        if (m_Footer != null && m_Footer.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Footer, inPoint);

            // point under child
            if (m_Footer.motion_event (point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Footer.name, num);
                return m_Footer;
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
        if (m_Header != null && m_Header.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Header, inPoint);

            // point under child
            if (m_Header.scroll_event (inScroll, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Header.name, num);
                return true;
            }
        }

        // Check if event is under footer
        if (m_Footer != null && m_Footer.geometry != null)
        {
            // Transform point to item coordinate space
            Graphic.Point point = m_Document.convert_to_child_item_space (m_Footer, inPoint);

            // point under child
            if (m_Footer.scroll_event (inScroll, point))
            {
                Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "button press event in %s page %u", m_Footer.name, num);
                return true;
            }
        }

        return false;
    }
}

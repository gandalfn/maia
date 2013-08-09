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

internal class Maia.Page : Group
{
    // accessors
    internal override string tag {
        get {
            return "Page";
        }
    }

    public uint num { get; set; default = 1; }

    // signals
    public signal void item_page_changed (Item inItem);

    // methods
    public Page (string inId, uint inPageNum)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), num: inPageNum);
    }

    private void
    on_item_page_changed (GLib.Object inObject, GLib.ParamSpec inSpec)
    {
        unowned Item item = (Item)inObject;

        if (item.page != num)
        {
            item_page_changed (item);
        }
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        if (can_append_child (inObject) && inObject is Item)
        {
            unowned Item item = (Item)inObject;

            // update the page num of item
            if (item.page == 0)
            {
                item.page = num;
            }

            // Connect onto item page changed
            item.notify["page"].connect (on_item_page_changed);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        if (inObject is Item)
        {
            // Disconnect from item page changed
            ((Item)inObject).notify["page"].disconnect (on_item_page_changed);
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.info (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "allocation: %s", inAllocation.extents.to_string ());

            geometry = inAllocation;

            foreach (unowned Core.Object child in this)
            {
                if (child is Item)
                {
                    Item item = (Item)child;

                    // Get child position and size
                    var item_position = item.position;

                    // Set child size allocation
                    var child_allocation = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, inAllocation.extents.size.width, inAllocation.extents.size.height));
                    item.update (inContext, child_allocation);
                }
            }

            damage ();
        }
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * group.vala
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

public class Maia.Group : Item
{
    // accessors
    internal override string tag {
        get {
            return "Group";
        }
    }

    public unowned Item? item_over_pointer { get; set; default = null; }

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("item-over-pointer");
    }

    public Group (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    protected virtual Graphic.Size
    childs_size_request ()
    {
        Graphic.Region area = new Graphic.Region ();

        foreach (unowned Core.Object child in this)
        {
            if (child is Item && !(child is Popup))
            {
                unowned Item item = (Item)child;
                Graphic.Point item_position = item.position;
                Graphic.Size item_size = item.size;
                area.union_with_rect (Graphic.Rectangle (0, 0, item_position.x + item_size.width, item_position.y + item_size.height));
            }
        }

        return area.extents.size;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Region area = new Graphic.Region (Graphic.Rectangle (0, 0, inSize.width, inSize.height));

        Graphic.Size child_size = childs_size_request ();

        area.union_with_rect (Graphic.Rectangle (0, 0, child_size.width, child_size.height));

        size = Graphic.Size (area.extents.origin.x + area.extents.size.width, area.extents.origin.y + area.extents.size.height);

        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "group: %s %s", name, Graphic.Size (area.extents.origin.x + area.extents.size.width, area.extents.origin.y + area.extents.size.height).to_string ());

        return base.size_request (inSize);
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            foreach (unowned Core.Object child in this)
            {
                if (child is Item && !(child is Popup))
                {
                    unowned Item item = (Item)child;

                    // Get child position and size
                    var item_position = item.position;
                    var item_size     = item.size;

                    // Set child size allocation
                    var child_allocation = new Graphic.Region (Graphic.Rectangle (item_position.x, item_position.y, item_size.width, item_size.height));
                    item.update (inContext, child_allocation);
                }
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // paint childs
        foreach (unowned Core.Object child in this)
        {
            if (child is Drawable)
            {
                unowned Drawable drawable = (Drawable)child;

                var area = area_to_child_item_space (drawable, inArea);
                drawable.draw (inContext, area);
            }
        }
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (ret)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_press_event (inButton, point))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"button press event in $(item.name)");

                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonPressEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
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
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.button_release_event (inButton, point))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"button release event in $(item.name)");

                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdButtonReleaseEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
            }

            ret = true;
        }

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        if (ret)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if ((child is Item))
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.motion_event (point))
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "%s motion event in %s", name, item.name);

                        // if item over pointer change unset pointer over for old item
                        if (item_over_pointer != null && item_over_pointer is Item && item != item_over_pointer && item_over_pointer.pointer_over)
                        {
                            item_over_pointer.pointer_over = false;
                        }

                        item_over_pointer = item;

                        // event occurate under child stop signal
                        GLib.Signal.stop_emission (this, mc_IdMotionEvent, 0);
                        break;
                    }
                }

                child = child.prev ();
            }

            ret = true;
        }
        // if item over pointer set unset it
        else if (item_over_pointer !=  null && item_over_pointer.pointer_over)
        {
            item_over_pointer.pointer_over = false;
            item_over_pointer = null;
        }

        return ret;
    }

    internal override bool
    on_scroll_event (Scroll inScroll, Graphic.Point inPoint)
    {
        bool ret = false;

        if (visible && geometry != null && inPoint in geometry)
        {
            // parse child from last to first since item has sorted by layer
            unowned Core.Object? child = last ();
            while (child != null)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Transform point to item coordinate space
                    Graphic.Point point = convert_to_child_item_space (item, inPoint);

                    // point under child
                    if (item.scroll_event (inScroll, point))
                    {
                        ret = true;
                        break;
                    }
                }

                child = child.prev ();
            }
        }

        if (ret) GLib.Signal.stop_emission (this, mc_IdScrollEvent, 0);

        return ret;
    }
}

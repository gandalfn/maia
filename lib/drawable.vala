/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawable.vala
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

public interface Maia.Drawable : GLib.Object
{
    // accessors
    public abstract Graphic.Region    geometry  { get; set; default = null; }
    public abstract Graphic.Region    damaged   { get; set; default = null; }
    public abstract Graphic.Transform transform { get; set; default = new Graphic.Transform.identity (); }

    // signals
    /**
     * Damage drawable
     *
     * @param inArea area to damage
     */
    [Signal (run = "first")]
    public virtual signal void
    damage (Graphic.Region? inArea = null)
    {
        if (geometry != null && !geometry.is_empty ())
        {
            if (inArea != null)
            {
                var area = inArea.copy ();
                area.translate (geometry.extents.origin);
                area.intersect (geometry);
                area.translate (geometry.extents.origin.invert ());
                if (!area.is_empty ())
                {
                    if (damaged == null)
                    {
                        damaged = area;
                    }
                    else
                    {
                        damaged.union_ (area);
                    }
                }
                else
                {
                    GLib.Signal.stop_emission_by_name (this, "damage");
                }
            }
            else
            {
                var area = new Graphic.Region (geometry.extents);
                area.translate (geometry.extents.origin.invert ());
                if (damaged == null || !damaged.equal (area))
                {
                    damaged = area;
                }
                else
                {
                    GLib.Signal.stop_emission_by_name (this, "damage");
                }
            }
        }
        else
        {
            GLib.Signal.stop_emission_by_name (this, "damage");
        }
    }

    /**
     * Repair drawable
     *
     * @param inArea area to damage
     */
    [Signal (run = "first")]
    public virtual signal void
    repair (Graphic.Region? inArea = null)
    {
        if (geometry != null && !geometry.is_empty () && damaged != null && !damaged.is_empty ())
        {
            if (inArea != null)
            {
                damaged.subtract (inArea);
            }
            else
            {
                var area = new Graphic.Region (geometry.extents);
                area.translate (geometry.extents.origin.invert ());
                damaged.subtract (area);
            }

            if (damaged.is_empty ()) damaged = null;
        }
        else
        {
            GLib.Signal.stop_emission_by_name (this, "repair");
        }
    }

    // methods
    /**
     * Convert a point in a child of drawable coordinate space
     *
     * @param inChild a child of drawable
     * @param inPoint point to convert
     *
     * @return Graphic.Point in child drawable coordinate space
     */
    public Graphic.Point
    convert_to_child_item_space (Drawable inChild, Graphic.Point inPoint)
    {
        // Transform point to item coordinate space
        Graphic.Point point = inPoint;

        try
        {
            var matrix = inChild.transform.matrix;
            matrix.invert ();
            var child_transform = new Graphic.Transform.from_matrix (matrix);

            point.transform (child_transform);

            if (inChild.geometry != null)
            {
                point.translate (inChild.geometry.extents.origin.invert ());
            }
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on convert %s to child item space: %s",
                          inPoint.to_string (), err.message);
        }

        return point;
    }

    /**
     * Convert a area in a child of drawable coordinate space
     *
     * @param inChild a child of item
     * @param inArea area to convert
     *
     * @return Graphic.Region in child drawable coordinate space
     */
    public Graphic.Region
    area_to_child_item_space (Drawable inChild, Graphic.Region? inArea = null)
    {
        Graphic.Region area = new Graphic.Region ();

        if (geometry != null && inChild.geometry != null)
        {
            // Transform area to item coordinate space
            if (inArea == null)
            {
                area = geometry.copy ();
                area.translate (geometry.extents.origin.invert ());
            }
            else
            {
                area = inArea.copy ();
            }
            area.intersect (inChild.geometry);

            try
            {
                var matrix = inChild.transform.matrix;
                matrix.invert ();
                var child_transform = new Graphic.Transform.from_matrix (matrix);

                area.transform (child_transform);

                if (inChild.geometry != null)
                {
                    area.translate (inChild.geometry.extents.origin.invert ());
                }
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on convert area %s to child item space: %s",
                              inArea.extents.to_string (), err.message);
            }
        }

        return area;
    }

    /**
     * Convert a point to parent drawable coordinate space
     *
     * @param inPoint point to convert
     *
     * @return Graphic.Point in parent drawable coordinate space
     */
    public Graphic.Point
    convert_to_parent_item_space (Graphic.Point inPoint)
    {
        // Transform point to item coordinate space
        Graphic.Point point = inPoint;
        point.transform (transform);
        if (geometry != null)
        {
            point.translate (geometry.extents.origin);
        }

        return point;
    }

    /**
     * Convert an area to parent drawable coordinate space
     *
     * @param inArea area to convert
     *
     * @return Graphic.Region in parent item coordinate space
     */
    public Graphic.Region
    area_to_parent_item_space (Graphic.Region inArea)
    {
        // Transform point to item coordinate space
        Graphic.Region area = inArea.copy ();
        area.transform (transform);
        if (geometry != null)
        {
            area.translate (geometry.extents.origin);
        }

        return area;
    }

    /**
     * Draw drawable
     *
     * @param inContext to draw drawable
     * @param inArea area to draw
     *
     * @throws Graphic.Error when something goes wrong
     */
    public abstract void draw (Graphic.Context inContext, Graphic.Region? inArea = null) throws Graphic.Error;
}

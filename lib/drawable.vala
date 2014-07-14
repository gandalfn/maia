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
    [CCode (notify = false)]
    public abstract Graphic.Region    geometry  { get; set; default = null; }
    [CCode (notify = false)]
    public abstract Graphic.Region    damaged   { get; set; default = null; }
    public abstract Graphic.Transform transform { get; set; default = new Graphic.Transform.identity (); }
    public Graphic.Region? area {
        owned get {
            Graphic.Region ret = null;

            if (geometry != null)
            {
                ret = geometry.copy ();
                try
                {
                    ret.translate (geometry.extents.origin.invert ());

                    var matrix = transform.matrix;
                    matrix.invert ();
                    var invert_transform = new Graphic.Transform.from_matrix (matrix);

                    if (transform.matrix.xy != 0 || transform.matrix.yx != 0)
                    {
                        var center = Graphic.Point(geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);

                        ret.translate (center.invert ());
                        ret.transform (invert_transform);
                        ret.translate (center);
                    }
                    else
                        ret.transform (invert_transform);
                }
                catch (Graphic.Error err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on get child area: %s", err.message);
                    ret = null;
                }
            }

            return ret;
        }
    }

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
        if (area != null && !area.is_empty ())
        {
            var damaged_area = area.copy ();

            if (inArea != null)
            {
                damaged_area.intersect (inArea);

                if (!damaged_area.is_empty ())
                {
                    if (damaged == null)
                    {
                        damaged = damaged_area;
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "area %s damage %s", damaged_area.extents.to_string (), damaged.extents.to_string ());
                    }
                    else if (damaged.contains_rectangle (damaged_area.extents) !=  Graphic.Region.Overlap.IN)
                    {
                        damaged.union_ (damaged_area);
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "area %s damage %s", damaged_area.extents.to_string (), damaged.extents.to_string ());
                    }
                    else
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged $((this as Item).name)");
                        GLib.Signal.stop_emission_by_name (this, "damage");
                    }
                }
                else
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"empty damaged region $((this as Item).name)");
                    GLib.Signal.stop_emission_by_name (this, "damage");
                }
            }
            else
            {
                if (damaged == null || !damaged.equal (damaged_area))
                {
                    damaged = damaged_area;
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "all damage %s", damaged.extents.to_string ());
                }
                else
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged $((this as Item).name)");
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
        if (area != null && !area.is_empty () && damaged != null && !damaged.is_empty ())
        {
            if (inArea != null)
            {
                damaged.subtract (inArea);
            }
            else
            {
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
     * Damage area of this drawable and its childs without emitting any signal
     *
     * @param inArea area to damage
     */
    public void
    damage_area (Graphic.Region? inArea = null)
    {
        if (area != null && !area.is_empty ())
        {
            var damaged_area = area.copy ();

            if (inArea != null)
            {
                damaged_area.intersect (inArea);

                if (!damaged_area.is_empty ())
                {
                    if (damaged == null)
                    {
                        damaged = damaged_area;
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "area %s damage %s", damaged_area.extents.to_string (), damaged.extents.to_string ());
                    }
                    else if (damaged.contains_rectangle (damaged_area.extents) !=  Graphic.Region.Overlap.IN)
                    {
                        damaged.union_ (damaged_area);
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "area %s damage %s", damaged_area.extents.to_string (), damaged.extents.to_string ());
                    }
                    else
                    {
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged $((this as Item).name)");
                        return;
                    }
                }
                else
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"empty damaged region $((this as Item).name)");
                    return;
                }
            }
            else
            {
                if (damaged == null || !damaged.equal (damaged_area))
                {
                    damaged = damaged_area;
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "all damage %s", damaged.extents.to_string ());
                }
                else
                {
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged $((this as Item).name)");
                    return;
                }
            }
        }
        else
        {
            return;
        }

        // Damage childs
        unowned Core.Object? self = this as Core.Object;
        if (self != null)
        {
            foreach (unowned Core.Object? child in self)
            {
                unowned Drawable? drawable = child as Drawable;
                if (drawable != null)
                {
                    drawable.damage_area (area_to_child_item_space (drawable, inArea));
                }
            }
        }
     }

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

        if (inChild.geometry != null)
        {
            try
            {
                point.translate (inChild.geometry.extents.origin.invert ());

                var matrix = inChild.transform.matrix;
                matrix.invert ();
                var child_transform = new Graphic.Transform.from_matrix (matrix);

                if (child_transform.matrix.xy != 0 || child_transform.matrix.yx != 0)
                {
                    var center = Graphic.Point(inChild.geometry.extents.size.width / 2.0, inChild.geometry.extents.size.height / 2.0);

                    point.translate (center);
                    point.transform (child_transform);
                    point.translate (center.invert ());
                }
                else
                    point.transform (child_transform);
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on convert %s to child item space: %s",
                              inPoint.to_string (), err.message);
            }
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
        Graphic.Region child_area = new Graphic.Region ();

        if (geometry != null && inChild.geometry != null)
        {
            // Transform area to item coordinate space
            if (inArea == null)
            {
                child_area = area.copy ();
            }
            else
            {
                child_area = inArea.copy ();
            }

            child_area.intersect (inChild.geometry);

            try
            {
                child_area.translate (inChild.geometry.extents.origin.invert ());

                var matrix = inChild.transform.matrix;
                matrix.invert ();
                var child_transform = new Graphic.Transform.from_matrix (matrix);

                if (child_transform.matrix.xy != 0 || child_transform.matrix.yx != 0)
                {
                    var center = Graphic.Point(inChild.geometry.extents.size.width / 2.0, inChild.geometry.extents.size.height / 2.0);

                    child_area.translate (center);
                    child_area.transform (child_transform);
                    child_area.translate (center.invert ());
                }
                else
                    child_area.transform (child_transform);
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "Error on convert area %s to child item space: %s",
                              inArea.extents.to_string (), err.message);
            }
        }

        return child_area;
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
        if (geometry != null)
        {
            if (transform.matrix.xy != 0 || transform.matrix.yx != 0)
            {
                var center = Graphic.Point(geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);

                point.translate (center);
                point.transform (transform);
                point.translate (center.invert ());
            }
            else
            {
                point.transform (transform);
            }

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

        if (geometry != null)
        {
            if (transform.matrix.xy != 0 || transform.matrix.yx != 0)
            {
                var center = Graphic.Point(geometry.extents.size.width / 2.0, geometry.extents.size.height / 2.0);

                area.translate (center);
                area.transform (transform);
                area.translate (center.invert ());
            }
            else
            {
                area.transform (transform);
            }

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

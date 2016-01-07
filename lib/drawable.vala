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
    public virtual Graphic.Region? area {
        owned get {
            Graphic.Region ret = null;

            if (geometry != null)
            {
                var ext = geometry.extents;
                ext.reverse_transform (transform);
                ext.translate (ext.origin.invert ());
                ext.transform (new Graphic.Transform.init_scale ((ext.size.width / ext.size.height) / (geometry.extents.size.width / geometry.extents.size.height),
                                                                 (ext.size.height / ext.size.width) / (geometry.extents.size.height / geometry.extents.size.width)));
                ret = new Graphic.Region (ext);
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
        Graphic.Region item_area = area;
        if (item_area != null && !item_area.is_empty ())
        {
            var damaged_area = item_area;

            if (inArea != null)
            {
                damaged_area.intersect (inArea);

                if (!damaged_area.is_empty ())
                {
                    if (damaged == null)
                    {
                        damaged = damaged_area;
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "area %s damage %s", damaged_area.extents.to_string (), damaged.extents.to_string ());
#endif
                    }
                    else if (damaged.contains_rectangle (damaged_area.extents) !=  Graphic.Region.Overlap.IN)
                    {
                        damaged.union_ (damaged_area);
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "area %s damage %s", damaged_area.extents.to_string (), damaged.extents.to_string ());
#endif
                    }
                    else
                    {
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged $((this as Item).name)");
#endif
                        GLib.Signal.stop_emission_by_name (this, "damage");
                    }
                }
                else
                {
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"empty damaged region $((this as Item).name)");
#endif
                    GLib.Signal.stop_emission_by_name (this, "damage");
                }
            }
            else
            {
                if (damaged == null || !damaged.equal (damaged_area))
                {
                    damaged = damaged_area;
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, "all damage %s", damaged.extents.to_string ());
#endif
                }
                else
                {
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged $((this as Item).name)");
#endif
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
        Graphic.Region item_area = area;
        if (item_area != null && !item_area.is_empty () && damaged != null && !damaged.is_empty ())
        {
            if (inArea != null)
            {
                damaged.subtract (inArea);
            }
            else
            {
                damaged.subtract (item_area);
            }

            if (damaged.is_empty ()) damaged = null;
        }
        else
        {
            GLib.Signal.stop_emission_by_name (this, "repair");
        }
    }

    // methods
    private void
    child_damage_area (Graphic.Region inArea)
    {
        // Damage childs
        unowned Core.Object? self = this as Core.Object;
        if (self != null)
        {
            foreach (unowned Core.Object? child in self)
            {
                unowned Drawable? drawable = child as Drawable;
                if (drawable != null)
                {
                    var child_damaged_area = area_to_child_item_space (drawable, inArea);
                    if (!child_damaged_area.is_empty ())
                    {
                        drawable.damage_area (child_damaged_area);
                    }
                }
            }
        }
    }

    protected virtual void
    on_damage_area (Graphic.Region inArea)
    {
    }

    /**
     * Damage area of this drawable and its childs without emitting any signal
     *
     * @param inArea area to damage
     */
    public void
    damage_area (Graphic.Region? inArea = null)
    {
        Graphic.Region item_area = area;
        if (item_area != null && !item_area.is_empty ())
        {
            var damaged_area = item_area;

            if (inArea != null)
            {
                damaged_area.intersect (inArea);

                if (!damaged_area.is_empty ())
                {
                    if (damaged == null)
                    {
                        damaged = damaged_area;
                        child_damage_area (damaged_area);
                        on_damage_area (damaged_area);
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"area $(damaged_area.extents) damage $(damaged.extents)");
#endif
                    }
                    else if (damaged.contains_rectangle (damaged_area.extents) !=  Graphic.Region.Overlap.IN)
                    {
                        damaged.union_ (damaged_area);
                        child_damage_area (damaged_area);
                        on_damage_area (damaged_area);
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"area $(damaged_area.extents) damage $(damaged.extents)");
#endif
                    }
                    else
                    {
#if MAIA_DEBUG
                        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged");
#endif
                    }
                }
                else
                {
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"empty damaged region");
#endif
                }
            }
            else
            {
                if (damaged == null || !damaged.equal (damaged_area))
                {
                    damaged = damaged_area;
                    child_damage_area (damaged_area);
                    on_damage_area (damaged_area);
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"all damage $(damaged.extents)");
#endif
                }
                else
                {
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_DAMAGE, @"region is already damaged");
#endif
                }
            }
        }
    }

    /**
     * Repair area of this drawable and its childs without emitting any signal
     *
     * @param inArea area to damage
     */
    public void
    repair_area (Graphic.Region? inArea = null)
    {
        Graphic.Region item_area = area;
        if (item_area != null && !item_area.is_empty () && damaged != null && !damaged.is_empty ())
        {
            if (inArea != null)
            {
                damaged.subtract (inArea);
            }
            else
            {
                damaged.subtract (item_area);
            }

            if (damaged.is_empty ()) damaged = null;

            // repair childs
            unowned Core.Object? self = this as Core.Object;
            if (self != null)
            {
                foreach (unowned Core.Object? child in self)
                {
                    unowned Drawable? drawable = child as Drawable;
                    if (drawable != null)
                    {
                        var child_damaged_area = area_to_child_item_space (drawable, inArea);
                        if (!child_damaged_area.is_empty ())
                        {
                            repair_area (child_damaged_area);
                        }
                    }
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
            point.translate (inChild.geometry.extents.origin.invert ());

            try
            {
                if (inChild.transform.have_rotate)
                {
                    var t = inChild.transform.copy ();
                    t.apply_center_rotate (inChild.geometry.extents.size.width / 2.0, inChild.geometry.extents.size.height / 2.0);
                    var ti = new Graphic.Transform.invert (t);

                    point.transform (ti);

                    var temp = inChild.geometry.copy ();
                    temp.translate (inChild.geometry.extents.origin.invert ());
                    temp.transform (ti);

                    point.translate (temp.extents.origin.invert ());
                }
                else
                {
                    point.transform (new Graphic.Transform.invert (inChild.transform));
                }
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
                child_area = area;
            }
            else
            {
                child_area = inArea.copy ();
            }

            child_area.intersect (inChild.geometry);

            child_area.translate (inChild.geometry.extents.origin.invert ());

            try
            {
                if (inChild.transform.have_rotate)
                {
                    var t = inChild.transform.copy ();
                    t.apply_center_rotate (inChild.geometry.extents.size.width / 2.0, inChild.geometry.extents.size.height / 2.0);
                    var ti = new Graphic.Transform.invert (t);

                    child_area.transform (ti);

                    var temp = inChild.geometry.copy ();
                    temp.translate (inChild.geometry.extents.origin.invert ());
                    temp.transform (ti);

                    child_area.translate (temp.extents.origin.invert ());
                }
                else
                {
                    child_area.transform (new Graphic.Transform.invert (inChild.transform));
                }
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
            if (transform.have_rotate)
            {
                var area_size = area.extents.size;

                var t = transform.copy ();
                t.apply_center_rotate (area_size.width / 2.0, area_size.height / 2.0);
                point.transform (t);

                var temp = area;
                temp.transform (t);

                point.translate (temp.extents.origin.invert ());
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
        Graphic.Region parent_area = inArea.copy ();

        if (geometry != null)
        {
            if (transform.have_rotate)
            {
                var area_size = area.extents.size;

                var t = transform.copy ();
                t.apply_center_rotate (area_size.width / 2.0, area_size.height / 2.0);
                parent_area.transform (t);

                var temp = area;
                temp.transform (t);

                parent_area.translate (temp.extents.origin.invert ());
            }
            else
            {
                parent_area.transform (transform);
            }

            parent_area.translate (geometry.extents.origin);
        }

        return parent_area;
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

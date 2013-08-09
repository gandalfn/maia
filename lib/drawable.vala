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
    public abstract Graphic.Region    geometry  { get; protected set; default = null; }
    public abstract Graphic.Region    damaged   { get; protected set; default = null; }
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
                damaged = area;
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
            var area = inArea ?? geometry.copy ();
            area.translate (geometry.extents.origin.invert ());
            damaged.subtract (area);
        }
        else
        {
            GLib.Signal.stop_emission_by_name (this, "repair");
        }
    }

    // methods
    /**
     * Draw drawable
     *
     * @param inContext to draw drawable
     *
     * @throws Graphic.Error when something goes wrong
     */
    public abstract void draw (Graphic.Context inContext) throws Graphic.Error;
}

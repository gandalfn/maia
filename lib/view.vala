/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view.vala
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

public class Maia.View : Input
{
    // properties
    private Graphic.Region? m_DamagedArea = null;

    // events
    public DamageEvent damage_event { get; set; default = null; }
    public RepairEvent repair_event { get; set; default = null; }

    // accessors
    /**
     * The view visibility
     */
    public virtual bool visible { get; set; default = false; }

    /**
     * The damaged area of view
     */
    public virtual Graphic.Region? damaged_area {
        get {
            return m_DamagedArea;
        }
    }

    /**
     * Set at ``true`` if view contains a damaged area
     */
    public bool is_damaged {
        get {
            return m_DamagedArea != null && !m_DamagedArea.is_empty ();
        }
    }

    /**
     * Graphic device of view
     */
    public virtual Graphic.Device? device {
        get {
            return null;
        }
    }

    // methods
    /**
     * Called when view need to be repaint
     *
     * @param inContext graphic context of view
     * @param inArea area to repaint
     */
    public virtual signal void
    paint (Graphic.Context inContext, Graphic.Region inArea)
    {
    }

    /**
     * Damage view inArea
     *
     * @param inArea area of view to damage if null damage all view
     */
    public virtual void
    damage (Graphic.Region? inArea = null)
    {
        // If view has no geometry do nothing
        if (geometry == null || geometry.is_empty ()) return;

        // Add area to damaged area
        if (inArea != null)
        {
            // Substract area outside geometry
            Graphic.Region area = inArea.copy ();
            area.translate (geometry.extents.origin);
            area.intersect (geometry);
            area.translate ( { -geometry.extents.origin.x, -geometry.extents.origin.y });

            if (m_DamagedArea == null)
                m_DamagedArea = area;
            else
                m_DamagedArea.union_ (area);

            // Emit damage event
            if (damage_event != null)
            {
                damage_event.post (new DamageEventArgs (area));
            }
        }
        else
        {
            // Copy geometry to damaged area
            Graphic.Region area = geometry.copy ();
            area.translate ( { -geometry.extents.origin.x, -geometry.extents.origin.y });

            m_DamagedArea = area;

            // Emit damage event
            if (damage_event != null)
            {
                damage_event.post (new DamageEventArgs (area));
            }
        }
    }

    /**
     * Draw damaged view area
     *
     * @param inArea damaged area to repair if null repair all damaged area
     */
    public virtual void
    draw (Graphic.Region? inArea = null)
    {
        Log.audit (GLib.Log.METHOD, "%s", inArea != null ? inArea.extents.to_string () : "all");

        // If view has no geometry do nothing
        if (geometry == null || geometry.is_empty ()) return;

        // No device created return
        if (device == null) return;

        // If area is null repair all damaged view areas
        if (inArea == null)
        {
            Log.debug (GLib.Log.METHOD, "Paint all");

            Graphic.Region area = geometry.copy ();
            area.translate ({ -geometry.extents.origin.x, -geometry.extents.origin.y });

            // Repaint view
            Graphic.Context context = new Graphic.Context (device);
            paint (context, area);

            // Clear damaged area
            m_DamagedArea = null;

            // Emit repair event
            if (repair_event != null)
            {
                repair_event.post (new RepairEventArgs (geometry));
            }
        }
        // Repair the specified area
        else if (m_DamagedArea != null)
        {
            Log.debug (GLib.Log.METHOD, "Paint area");

            // Keep only the area inside geometry
            Graphic.Region area = inArea.copy ();
            area.translate (geometry.extents.origin);
            area.intersect (geometry);
            area.translate ({ -geometry.extents.origin.x, -geometry.extents.origin.y });

            // Repaint view
            Graphic.Context context = new Graphic.Context (device);
            paint (context, area);

            // Remove repaired area
            m_DamagedArea.subtract (area);

            // If damaged area is empty destroy it
            if (m_DamagedArea.is_empty ())
                m_DamagedArea = null;

            // Emit repair event
            if (repair_event != null)
            {
                repair_event.post (new RepairEventArgs (area));
            }
        }
    }
}

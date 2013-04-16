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
    private uint m_Layer = 0;
    private uint m_Row = 0;
    private uint m_Column = 0;

    // events
    public DamageEvent damage_event { get; set; default = null; }

    // TODO: repair event is really needed ?
    public RepairEvent repair_event { get; set; default = null; }

    // accessors
    /**
     * {@inheritDoc}
     */
    [CCode (notify = false)]
    public override Graphic.Region geometry {
        get {
            return base.geometry;
        }
        construct set {
            if (value != null && base.geometry != null)
            {
                Graphic.Rectangle old_clipbox = base.geometry.extents;
                Graphic.Rectangle new_clipbox = value.extents;

                Log.debug ("View.geometry", "old: %s new: %s", old_clipbox.to_string (),
                                                               new_clipbox.to_string ());
                base.geometry = value;

                // TODO: very simplistic childs allocation must be improved
                if (old_clipbox.size.width  != new_clipbox.size.width ||
                    old_clipbox.size.height != new_clipbox.size.height)
                {
                    check_child_allocation ();
                }
            }
            else
            {
                base.geometry = value;
                check_child_allocation ();
            }
        }
    }

    /**
     * The view visibility
     */
    public virtual bool visible { get; set; default = false; }

    /**
     * The view layer
     */
    public uint layer {
        get {
            return m_Layer;
        }
        construct set {
            m_Layer = value;
            reorder ();
        }
    }

    /**
     * The view row position in parent
     */
    public uint row {
        get {
            return m_Row;
        }
        construct set {
            m_Row = value;
            reorder ();
        }
    }

    /**
     * The view column position in parent
     */
    public uint column {
        get {
            return m_Column;
        }
        construct set {
            m_Column = value;
            reorder ();
        }
    }

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

    /**
     * The natural size of view
     */
    public virtual Graphic.Size natural_size {
        get {
            return geometry == null ? Graphic.Size (0, 0) : geometry.extents.size;
        }
    }

    // methods
    private void
    check_child_allocation ()
    {
        foreach (unowned Object child in this)
        {
            View view = child as View;
            Graphic.Size natural = view.natural_size;
            if (!natural.is_empty ())
            {
                if (view.geometry != null)
                {
                    double x = 0;
                    double y = 0;

                    x = view.geometry.extents.origin.x;
                    y = view.geometry.extents.origin.y;

                    view.geometry.resize (natural);

                    double dx = -x + (geometry.extents.size.width - natural.width) / 2.0;
                    double dy = -y + (geometry.extents.size.height - natural.height) / 2.0;
                    view.geometry.translate (Graphic.Point (dx, dy));

                    view.notify_property ("width");
                    view.notify_property ("height");
                }
                else
                {
                    view.geometry = new Graphic.Region (Graphic.Rectangle (0, 0, natural.width, natural.height));
                }
            }
        }
    }

    protected override void
    insert_child (Object inObject)
    {
        base.insert_child (inObject);

        if (geometry != null)
        {
            check_child_allocation ();
        }
    }

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
        }
        else
        {
            // Copy geometry to damaged area
            Graphic.Region area = geometry.copy ();
            area.translate ( { -geometry.extents.origin.x, -geometry.extents.origin.y });

            m_DamagedArea = area;
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

    /**
     * {@inheritDoc}
     */
    internal override int
    compare (Object inObject)
    {
        // First order by layer position
        int diff = (int)m_Layer - (int)(inObject as View).m_Layer;
        if (diff != 0)
        {
            return diff;
        }

        // Second order by row position
        diff = (int)m_Row - (int)(inObject as View).m_Row;
        if (diff != 0)
        {
            return diff;
        }

        // Thrid order by column position
        diff = (int)m_Column - (int)(inObject as View).m_Column;
        if (diff != 0)
        {
            return diff;
        }

        // Finally keep order of base object
        return base.compare (inObject);
    }
}

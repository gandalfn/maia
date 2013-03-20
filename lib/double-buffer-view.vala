/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * double-buffer-view.vala
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

public class Maia.DoubleBufferView : View
{
    // accessors
    /**
     * Indicate if view is double buffered
     */
    [CCode (notify = false)]
    public bool double_buffered { get; construct set; default = true; }

    /**
     * The graphic device of front buffer
     */
    protected virtual Graphic.Device? front_device {
        get {
            return null;
        }
    }

    // methods
    /**
     * Swap front and back buffer
     *
     * @param inArea the region of view to be swapped if null swap all view
     */
    public virtual void
    swap_buffer (Graphic.Region? inArea = null)
    {
        if (double_buffered)
        {
            Graphic.Region? area = geometry.copy ();

            // Only repair the specified area
            if (inArea != null)
                area.intersect (inArea);

            // Swap buffer
            try
            {
                Log.audit (GLib.Log.METHOD, "Swap buffer");
                Graphic.Context ctx = new Graphic.Context (front_device);
                ctx.save ();
                ctx.clip (new Graphic.Path.from_region (area));
                ctx.pattern = device;
                ctx.paint ();
                ctx.restore ();
            }
            catch (Graphic.Error err)
            {
                Log.error (GLib.Log.METHOD, "Error on swap buffer: %s", err.message);
            }
        }
    }
}

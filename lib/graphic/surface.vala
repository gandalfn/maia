/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * surface.vala
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

public class Maia.Graphic.Surface : Pattern, Core.Serializable
{
    // types
    /**
     *  Format is used to identify the memory format of surface data.
     */
    public enum Format
    {
        /**
         * no such format exists or is supported.
         */
        INVALID,
        /**
         * each pixel is a 1-bit quantity holding an alpha value.
         */
        A1,
        /**
         * each pixel is a 8-bit quantity holding an alpha value.
         */
        A8,
        /**
         * each pixel is a 32-bit quantity, with the upper 8 bits unused,
         * red, green, and blue are stored in the remaining 24 bits in that order.
         */
        RGB24,
        /**
         * each pixel is a 32-bit quantity, with alpha in the upper 8 bits,
         * then red, then green, then blue.
         */
        ARGB32;

        public int
        bits_per_pixel ()
        {
            switch (this)
            {
                case A1:
                    return 1;
                case A8:
                    return 8;
                case RGB24:
                case ARGB32:
                    return 32;
            }

            return 0;
        }

        public int
        stride_for_width (int inWidth)
        {
            int bpp = bits_per_pixel ();

            if (bpp <= 0)
                return -1;

            if ((uint) (inWidth) >= (int32.MAX - 7) / (uint) (bpp))
                return -1;

            return (int)(((bpp * inWidth + 7) / 8 + sizeof (uint32) - 1) & -sizeof (uint32));
        }
    }

    // properties
    private Context m_Context;

    // accessors
    /**
     * Size of the surface
     */
    [CCode (notify = false)]
    public virtual Graphic.Size size { get; construct set; default = Graphic.Size (0, 0); }

    /**
     * Format of the surface
     */
    [CCode (notify = false)]
    public Format format { get; construct set; default = Format.INVALID; }

    /**
     * Get a pointer to the data of the surface, for direct inspection or modification.
     */
    [CCode (notify = false)]
    public uchar* data { get; construct; default = null; }

    /**
     * The native pointer of the surface
     */
    [CCode (notify = false)]
    public virtual void* native { get; construct set; }

    /**
     * The Device of the surface
     */
    [CCode (notify = false)]
    public virtual unowned Device? device { get; construct set; default = null; }

    /**
     * The base Surface of the surface
     */
    [CCode (notify = false)]
    public virtual Graphic.Surface surface { construct set {} }

    /**
     * The Context of the surface
     */
    [CCode (notify = false)]
    public Context context {
        get {
            if (m_Context == null)
            {
                m_Context = new Context (this);
            }
            return m_Context;
        }
    }

    [CCode (notify = false)]
    public virtual GLib.Variant serialize {
        owned get {
            GLib.Variant ret = null;
            return ret;
        }
        set {
        }
    }

    // methods
    public Surface (uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (format: Graphic.Surface.Format.ARGB32, size: size);
    }

    public Surface.with_format (Graphic.Surface.Format inFormat, uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (format: inFormat, size: size);
    }

    public Surface.similar (Surface inSurface, uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (format: inSurface.format, size: size, surface: inSurface);
    }

    public Surface.from_device (Device inDevice, uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (size: size, device: inDevice);
    }

    public Surface.from_native (void* inNativeSurface, uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (size: size, native: inNativeSurface);
    }

    public Surface.from_data (Format inFormat, uchar* inData, uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (size: size, format: inFormat, data: inData);
    }

    /**
     * Checks whether an error has previously occurred for this surface.
     */
    public virtual void
    status  () throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context status not implemented");
    }

    /**
     * Clears the internal surface, making all pixels fully transparent.
     */
    public virtual void
    clear () throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Clear surface not implemented");
    }

    /**
     * Performs a blur operation on the internal surface.
     *
     * @param inRadius the blur radius
     * @param inProcessCount the number of times to perform the operation
     */
    public virtual void
    fast_blur (int inRadius, int inProcessCount = 1) throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Fast blur not implemented");
    }

    /**
     * Performs a blur operation on the internal surface, using an
     * exponential blurring algorithm. This method is usually the fastest
     * and produces good-looking results (though not quite as good as gaussian's).
     *
     * @param inRadius the blur radius
     */
    public virtual void
    exponential_blur (int inRadius) throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Exponential blur not implemented");
    }

    /**
     * Performs a blur operation on the internal surface, using a
     * gaussian blurring algorithm. This method is very slow, albeit producing
     * debatably the best-looking results, and in most cases developers should
     * use the exponential blurring algorithm instead.
     *
     * @param inRadius the blur radius
     */
    public virtual void
    gaussian_blur (int inRadius) throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Gaussian blur not implemented");
    }

    /**
     * Fill surface with random noise
     */
    public virtual void
    render_noise () throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Render noise not implemented");
    }

    /**
     * Do any pending drawing for the surface and also restore any temporary modifications
     * has made to the surface's state.
     */
    public virtual void
    flush () throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Flush not implemented");
    }

    /**
     * Dump surface content under png
     *
     * @param inFilename png filename to dump surface
     */
    public virtual void
    dump (string inFilename) throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Flush not implemented");
    }
}

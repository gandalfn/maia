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

public class Maia.Graphic.Surface : Pattern
{
    // types
    public enum Format
    {
        INVALID,
        A1,
        A8,
        RGB24,
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

            return (int)((((bpp)*(inWidth) + 7) / 8 + sizeof (uint32) - 1) & -sizeof (uint32));
        }
    }

    // properties
    private Context m_Context;

    // accessors
    public Graphic.Size size { get; construct set; default = Graphic.Size (0, 0); }

    public Format format { get; construct; default = Format.INVALID; }

    public uchar* data { get; construct; default = null; }

    public virtual void* native { get; construct set; }

    public virtual Device device { get; construct set; default = null; }

    public Context context {
        get {
            if (m_Context == null)
            {
                m_Context = new Context (this);
            }
            return m_Context;
        }
    }

    // methods
    public Surface (uint inWidth, uint inHeight)
        requires (inWidth > 0 && inHeight > 0)
    {
        var size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (size: size);
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
     * Clears the internal {@link Maia.Graphic.Surface}, making all pixels fully transparent.
     */
    public virtual void
    clear () throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Clear surface not implemented");
    }

    /**
     * Performs a blur operation on the internal {@link Maia.Graphic.Surface}.
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
     * Performs a blur operation on the internal {@link Maia.Graphic.Surface}, using an
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
     * Performs a blur operation on the internal {@link Maia.Graphic.Surface}, using a
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
}

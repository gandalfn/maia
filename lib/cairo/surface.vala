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

internal class Maia.Cairo.Surface : Graphic.Surface
{
    // constants
    const int cAlphaPrecision = 16;
    const int cParamPrecision = 7;

    // static
    private static uint s_Seed;

    // properties
    private global::Cairo.Surface m_Surface = null;

    // accessors
    [CCode (notify = false)]
    public override Graphic.Size size {
        get {
            return base.size;
        }
        construct set {
            if (!size.equal (value))
            {
                base.size = value;

                if (!size.is_empty () && device != null)
                {
                    resize_device_surface ();
                }
                else
                {
                    m_Surface = null;
                }
            }
        }
    }

    [CCode (notify = false)]
    public override void* native {
        get {
            if (device == null && m_Surface == null && !size.is_empty ())
            {
                if (format != Graphic.Surface.Format.INVALID && data != null)
                {
                    m_Surface = new global::Cairo.ImageSurface.for_data ((uchar[])data, format_to_cairo_format (format),
                                                                         (int)GLib.Math.ceil (size.width), (int)GLib.Math.ceil (size.height),
                                                                         format.stride_for_width ((int)GLib.Math.ceil (size.width)));
                }
                else
                {
                    m_Surface = new global::Cairo.ImageSurface (format_to_cairo_format (format != Graphic.Surface.Format.INVALID ? format : Graphic.Surface.Format.ARGB32),
                                                                (int)GLib.Math.ceil (size.width), (int)GLib.Math.ceil (size.height));
                }
            }

            return m_Surface;
        }
        construct set {
            if (device == null)
            {
                m_Surface = (global::Cairo.Surface)value;
            }
        }
    }

    [CCode (notify = false)]
    public override Graphic.Surface surface {
        construct set {
            if (value is Surface && !size.is_empty ())
            {
                m_Surface = new global::Cairo.Surface.similar ((global::Cairo.Surface)((value as Surface).native),
                                                                global::Cairo.Content.COLOR_ALPHA,
                                                                (int)GLib.Math.ceil (size.width), (int)GLib.Math.ceil (size.height));
            }
        }
    }

    [CCode (notify = false)]
    public override unowned Graphic.Device? device {
        get {
            return base.device;
        }
        construct set {
            base.device = value;
            if (base.device != null)
            {
                m_Surface = null;

                create_surface_from_device ();
            }
        }
    }

    [CCode (notify = false)]
    public override GLib.Variant serialize {
        owned get {
            if (native != null)
            {
                unowned global::Cairo.ImageSurface image = m_Surface.map_to_image (null);
                int width = image.get_width ();
                int height = image.get_height ();
                int stride = image.get_stride ();
                unowned uint32[] image_data = (uint32[])image.get_data ();
                image_data.length = (stride / 4) * height;
                unowned GLib.Variant data = GLib.VariantFixed.new<uint32> (new GLib.VariantType("u"), image_data, sizeof (uint32));
                GLib.Variant ret = new GLib.Variant ("(iiiiv)", (int)format, width, height, stride, data);
                m_Surface.unmap_image (image);

                return ret;
            }

            return base.serialize;
        }
        set {
            int format, width, height, stride;
            GLib.VariantFixed data;
            value.get ("(iiiiv)", out format, out width, out height, out stride, out data);
            this.format = (Graphic.Surface.Format)format;
            this.size = Graphic.Size (width, height);

            if (native != null)
            {
                unowned uint32[] image_data = data.get<uint32> (sizeof (uint32));

                global::Cairo.ImageSurface? image = new global::Cairo.ImageSurface.for_data ((uchar[])image_data, format_to_cairo_format (this.format), width, height, stride);

                var ctx = new global::Cairo.Context (m_Surface);
                ctx.set_operator (global::Cairo.Operator.SOURCE);
                ctx.set_source_surface (image, 0, 0);
                ctx.paint ();
            }
        }
    }

    // static methods
    private static global::Cairo.Format
    format_to_cairo_format (Graphic.Surface.Format inFormat)
    {
        switch (inFormat)
        {
            case Graphic.Surface.Format.A1:
                return global::Cairo.Format.A1;
            case Graphic.Surface.Format.A8:
                return global::Cairo.Format.A8;
            case Graphic.Surface.Format.RGB24:
                return global::Cairo.Format.RGB24;
            case Graphic.Surface.Format.ARGB32:
                return global::Cairo.Format.ARGB32;
        }

        return global::Cairo.Format.ARGB32;
    }


    // methods
    public Surface (global::Cairo.Surface? inSurface, uint inWidth, uint inHeight)
    {
        Graphic.Size size = Graphic.Size ((double)inWidth, (double)inHeight);
        GLib.Object (native: inSurface, size: size);
    }

    ~Surface ()
    {
        m_Surface = null;
    }

    private void
    create_surface_from_device ()
    {
        if (device != null)
        {
            switch (device.backend)
            {
                case "xcb/window":
                case "xcb/pixmap":
                case "xcb/drawable":
                    uint32 xid;
                    int screen_num;
                    unowned Xcb.Connection connection;
                    uint32 visual;

                    ((GLib.Object)device).get ("xid", out xid,
                                               "screen-num", out screen_num,
                                               "connection", out connection,
                                               "visual", out visual);

                    unowned global::Xcb.Screen screen = connection.roots[screen_num];
                    Xcb.Visualtype? visual_type = null;

                    foreach (unowned global::Xcb.Depth? depth in screen)
                    {
                        foreach (unowned global::Xcb.Visualtype? vis in depth)
                        {
                            if (vis.visual_id == visual)
                            {
                                visual_type = vis;
                                break;
                            }
                        }
                        if (visual_type != null) break;
                    }

                    m_Surface = new global::Cairo.XcbSurface (connection,
                                                              (Xcb.Drawable)xid, visual_type,
                                                              (int)GLib.Math.ceil (size.width), (int)GLib.Math.ceil (size.height));

                    break;
            }
        }
    }

    private void
    resize_device_surface ()
    {
        if (device != null)
        {
            switch (device.backend)
            {
                case "xcb/window":
                    ((global::Cairo.XcbSurface)m_Surface).set_size ((int)GLib.Math.ceil (size.width), (int)GLib.Math.ceil (size.height));
                    break;

                case "xcb/drawable":
                case "xcb/pixmap":
                    create_surface_from_device ();
                    break;
            }
        }
    }

    private void
    exponential_blur_columns (uint8* inPixels, int inWidth, int inHeight, int inStartCol, int inEndCol, int inStartY, int inEndY, int inAlpha)
    {
        for (var columnIndex = inStartCol; columnIndex < inEndCol; columnIndex++)
        {
            // blur columns
            uint8 *column = inPixels + columnIndex * 4;

            var zA = column[0] << cParamPrecision;
            var zR = column[1] << cParamPrecision;
            var zG = column[2] << cParamPrecision;
            var zB = column[3] << cParamPrecision;

            // Top to Bottom
            for (var index = inWidth * (inStartY + 1); index < (inEndY - 1) * inWidth; index += inWidth)
                exponential_blur_inner (&column[index * 4], ref zA, ref zR, ref zG, ref zB, inAlpha);

            // Bottom to Top
            for (var index = (inEndY - 2) * inWidth; index >= inStartY; index -= inWidth)
                exponential_blur_inner (&column[index * 4], ref zA, ref zR, ref zG, ref zB, inAlpha);
        }
    }

    private void
    exponential_blur_rows (uint8* inPixels, int inWidth, int inHeight, int inStartRow, int inEndRow, int inStartX, int inEndX, int inAlpha)
    {
        for (var rowIndex = inStartRow; rowIndex < inEndRow; rowIndex++)
        {
            // Get a pointer to our current row
            uint8* row = inPixels + rowIndex * inWidth * 4;

            var zA = row[inStartX + 0] << cParamPrecision;
            var zR = row[inStartX + 1] << cParamPrecision;
            var zG = row[inStartX + 2] << cParamPrecision;
            var zB = row[inStartX + 3] << cParamPrecision;

            // Left to Right
            for (var index = inStartX + 1; index < inEndX; index++)
                exponential_blur_inner (&row[index * 4], ref zA, ref zR, ref zG, ref zB, inAlpha);

            // Right to Left
            for (var index = inEndX - 2; index >= inStartX; index--)
                exponential_blur_inner (&row[index * 4], ref zA, ref zR, ref zG, ref zB, inAlpha);
        }
    }

    private static inline void
    exponential_blur_inner (uint8* inPixels, ref int inZA, ref int inZR, ref int inZG, ref int inZB, int inAlpha)
    {
        inZA += (inAlpha * ((inPixels[0] << cParamPrecision) - inZA)) >> cAlphaPrecision;
        inZR += (inAlpha * ((inPixels[1] << cParamPrecision) - inZR)) >> cAlphaPrecision;
        inZG += (inAlpha * ((inPixels[2] << cParamPrecision) - inZG)) >> cAlphaPrecision;
        inZB += (inAlpha * ((inPixels[3] << cParamPrecision) - inZB)) >> cAlphaPrecision;

        inPixels[0] = (uint8) (inZA >> cParamPrecision);
        inPixels[1] = (uint8) (inZR >> cParamPrecision);
        inPixels[2] = (uint8) (inZG >> cParamPrecision);
        inPixels[3] = (uint8) (inZB >> cParamPrecision);
    }

    private void
    gaussian_blur_horizontal (double* inSrc, double* inDest, double* inKernel, int inGaussWidth,
                              int inWidth, int inHeight, int startRow, int endRow, int[,] inShift)
    {
        uint32 cur_pixel = startRow * inWidth * 4;

        for (var y = startRow; y < endRow; y++)
        {
            for (var x = 0; x < inWidth; x++)
            {
                for (var k = 0; k < inGaussWidth; k++)
                {
                    var source = cur_pixel + inShift[x, k];

                    inDest[cur_pixel + 0] += inSrc[source + 0] * inKernel[k];
                    inDest[cur_pixel + 1] += inSrc[source + 1] * inKernel[k];
                    inDest[cur_pixel + 2] += inSrc[source + 2] * inKernel[k];
                    inDest[cur_pixel + 3] += inSrc[source + 3] * inKernel[k];
                }

                cur_pixel += 4;
            }
        }
    }

    private void
    gaussian_blur_vertical (double* inSrc, double* inDest, double* inKernel, int inGaussWidth,
                            int inWidth, int inHeight, int inStartCol, int inEndCol, int[,] inShift)
    {
        uint32 cur_pixel = inStartCol * 4;

        for (var y = 0; y < inHeight; y++)
        {
            for (var x = inStartCol; x < inEndCol; x++)
            {
                for (var k = 0; k < inGaussWidth; k++)
                {
                    var source = cur_pixel + inShift[y, k];

                    inDest[cur_pixel + 0] += inSrc[source + 0] * inKernel[k];
                    inDest[cur_pixel + 1] += inSrc[source + 1] * inKernel[k];
                    inDest[cur_pixel + 2] += inSrc[source + 2] * inKernel[k];
                    inDest[cur_pixel + 3] += inSrc[source + 3] * inKernel[k];
                }

                cur_pixel += 4;
            }
            cur_pixel += (inWidth - inEndCol + inStartCol) * 4;
        }
    }

    private static double[]
    build_gaussian_kernel (int inGaussWidth)
        requires (inGaussWidth % 2 == 1)
    {
        var inKernel = new double[inGaussWidth];

        // Maximum value of curve
        var sd = 255.0;

        // inWidth of curve
        var range = inGaussWidth;

        // Average value of curve
        var mean = range / sd;

        for (var i = 0; i < inGaussWidth / 2 + 1; i++)
            inKernel[inGaussWidth - i - 1] = inKernel[i] = Math.pow (Math.sin (((i + 1) * (Math.PI / 2) - mean) / range), 2) * sd;

        // normalize the values
        var gaussSum = 0.0;
        foreach (var d in inKernel)
            gaussSum += d;

        for (var i = 0; i < inKernel.length; i++)
            inKernel[i] = inKernel[i] / gaussSum;

        return inKernel;
    }

    internal override void
    clear () throws Graphic.Error
    {
        context.save ();
        {
            var operator = context.operator;
            context.pattern = new Graphic.Color (0, 0, 0, 0);
            context.operator = Graphic.Operator.SOURCE;
            context.paint ();
            context.operator = operator;
        }
        context.restore ();
    }

    internal override void
    status () throws Graphic.Error
    {
        global::Cairo.Status status = m_Surface.status ();

        switch (status)
        {
            case global::Cairo.Status.SUCCESS:
                break;
            case global::Cairo.Status.NO_MEMORY:
                throw new Graphic.Error.NO_MEMORY ("out of memory");
            case global::Cairo.Status.INVALID_RESTORE:
                throw new Graphic.Error.END_ELEMENT ("call end element without matching begin element");
            case global::Cairo.Status.NO_CURRENT_POINT:
                throw new Graphic.Error.NO_CURRENT_POINT ("no current point defined");
            case global::Cairo.Status.INVALID_MATRIX:
                throw new Graphic.Error.INVALID_MATRIX ("invalid matrix (not invertible)");
            case global::Cairo.Status.NULL_POINTER:
                throw new Graphic.Error.NULL_POINTER ("null pointer");
            case global::Cairo.Status.INVALID_STRING:
                throw new Graphic.Error.INVALID_STRING ("input string not valid UTF-8");
            case global::Cairo.Status.INVALID_PATH_DATA:
                throw new Graphic.Error.INVALID_PATH ("input path not valid");
            case global::Cairo.Status.SURFACE_FINISHED:
                throw new Graphic.Error.SURFACE_FINISHED ("the target surface has been finished");
            case global::Cairo.Status.SURFACE_TYPE_MISMATCH:
                throw new Graphic.Error.SURFACE_TYPE_MISMATCH ("the surface type is not appropriate for the operation");
            case global::Cairo.Status.PATTERN_TYPE_MISMATCH:
                throw new Graphic.Error.PATTERN_TYPE_MISMATCH ("the pattern type is not appropriate for the operation");
            default:
                throw new Graphic.Error.UNKNOWN ("a unknown error occured");
        }
    }

    internal override void
    fast_blur (int inRadius, int inProcessCount = 1) throws Graphic.Error
    {
        if (inRadius < 1 || inProcessCount < 1)
            return;

        int w = (int)size.width;
        int h = (int)size.height;
        int channels = int.max (1, format.bits_per_pixel () / 8);

        if (inRadius > w - 1 || inRadius > h - 1)
            return;

        uint8 *pixels = (uint8*)data;
        Graphic.Surface? original = null;
        if (pixels == null)
        {
            original = new Graphic.Surface ((uint)w, (uint)h);
            var cr = original.context;

            cr.operator = Graphic.Operator.SOURCE;
            cr.pattern = this;
            cr.paint ();

            pixels = ((global::Cairo.ImageSurface)((Surface)original).m_Surface).get_data ();
            channels = 4;
        }
        var buffer = new uint8[w * h * channels];

        var vmin = new int[int.max (w, h)];
        var vmax = new int[int.max (w, h)];

        var div = 2 * inRadius + 1;
        var dv = new uint8[256 * div];
        for (var i = 0; i < dv.length; i++)
            dv[i] = (uint8) (i / div);

        switch (channels)
        {
            case 1:
                while (inProcessCount-- > 0)
                {
                    for (var x = 0; x < w; x++)
                    {
                        vmin[x] = int.min (x + inRadius + 1, w - 1);
                        vmax[x] = int.max (x - inRadius, 0);
                    }

                    for (var y = 0; y < h; y++)
                    {
                        var asum = 0;

                        uint32 cur_pixel = y * w * channels;

                        asum += inRadius * pixels[cur_pixel + 0];

                        for (var i = 0; i <= inRadius; i++)
                        {
                            asum += pixels[cur_pixel];

                            cur_pixel += channels;
                        }

                        cur_pixel = y * w * channels;

                        for (var x = 0; x < w; x++)
                        {
                            uint32 p1 = (y * w + vmin[x]) * channels;
                            uint32 p2 = (y * w + vmax[x]) * channels;

                            buffer[cur_pixel] = dv[asum];

                            asum += pixels[p1] - pixels[p2];

                            cur_pixel += channels;
                        }
                    }

                    for (var y = 0; y < h; y++)
                    {
                        vmin[y] = int.min (y + inRadius + 1, h - 1) * w;
                        vmax[y] = int.max (y - inRadius, 0) * w;
                    }

                    for (var x = 0; x < w; x++)
                    {
                        var asum = 0;

                        uint32 cur_pixel = x * channels;

                        asum += inRadius * buffer[cur_pixel];

                        for (var i = 0; i <= inRadius; i++)
                        {
                            asum += buffer[cur_pixel];

                            cur_pixel += w * channels;
                        }

                        cur_pixel = x * channels;

                        for (var y = 0; y < h; y++)
                        {
                            uint32 p1 = (x + vmin[y]) * channels;
                            uint32 p2 = (x + vmax[y]) * channels;

                            pixels[cur_pixel] = dv[asum];

                            asum += buffer[p1] - buffer[p2];

                            cur_pixel += w * channels;
                        }
                    }
                }
                break;

            case 4:
                while (inProcessCount-- > 0)
                {
                    for (var x = 0; x < w; x++)
                    {
                        vmin[x] = int.min (x + inRadius + 1, w - 1);
                        vmax[x] = int.max (x - inRadius, 0);
                    }

                    for (var y = 0; y < h; y++)
                    {
                        var asum = 0, rsum = 0, gsum = 0, bsum = 0;

                        uint32 cur_pixel = y * w * channels;

                        asum += inRadius * pixels[cur_pixel + 0];
                        rsum += inRadius * pixels[cur_pixel + 1];
                        gsum += inRadius * pixels[cur_pixel + 2];
                        bsum += inRadius * pixels[cur_pixel + 3];

                        for (var i = 0; i <= inRadius; i++)
                        {
                            asum += pixels[cur_pixel + 0];
                            rsum += pixels[cur_pixel + 1];
                            gsum += pixels[cur_pixel + 2];
                            bsum += pixels[cur_pixel + 3];

                            cur_pixel += channels;
                        }

                        cur_pixel = y * w * channels;

                        for (var x = 0; x < w; x++)
                        {
                            uint32 p1 = (y * w + vmin[x]) * channels;
                            uint32 p2 = (y * w + vmax[x]) * channels;

                            buffer[cur_pixel + 0] = dv[asum];
                            buffer[cur_pixel + 1] = dv[rsum];
                            buffer[cur_pixel + 2] = dv[gsum];
                            buffer[cur_pixel + 3] = dv[bsum];

                            asum += pixels[p1 + 0] - pixels[p2 + 0];
                            rsum += pixels[p1 + 1] - pixels[p2 + 1];
                            gsum += pixels[p1 + 2] - pixels[p2 + 2];
                            bsum += pixels[p1 + 3] - pixels[p2 + 3];

                            cur_pixel += channels;
                        }
                    }

                    for (var y = 0; y < h; y++)
                    {
                        vmin[y] = int.min (y + inRadius + 1, h - 1) * w;
                        vmax[y] = int.max (y - inRadius, 0) * w;
                    }

                    for (var x = 0; x < w; x++)
                    {
                        var asum = 0, rsum = 0, gsum = 0, bsum = 0;

                        uint32 cur_pixel = x * channels;

                        asum += inRadius * buffer[cur_pixel + 0];
                        rsum += inRadius * buffer[cur_pixel + 1];
                        gsum += inRadius * buffer[cur_pixel + 2];
                        bsum += inRadius * buffer[cur_pixel + 3];

                        for (var i = 0; i <= inRadius; i++)
                        {
                            asum += buffer[cur_pixel + 0];
                            rsum += buffer[cur_pixel + 1];
                            gsum += buffer[cur_pixel + 2];
                            bsum += buffer[cur_pixel + 3];

                            cur_pixel += w * channels;
                        }

                        cur_pixel = x * channels;

                        for (var y = 0; y < h; y++)
                        {
                            uint32 p1 = (x + vmin[y]) * channels;
                            uint32 p2 = (x + vmax[y]) * channels;

                            pixels[cur_pixel + 0] = dv[asum];
                            pixels[cur_pixel + 1] = dv[rsum];
                            pixels[cur_pixel + 2] = dv[gsum];
                            pixels[cur_pixel + 3] = dv[bsum];

                            asum += buffer[p1 + 0] - buffer[p2 + 0];
                            rsum += buffer[p1 + 1] - buffer[p2 + 1];
                            gsum += buffer[p1 + 2] - buffer[p2 + 2];
                            bsum += buffer[p1 + 3] - buffer[p2 + 3];

                            cur_pixel += w * channels;
                        }
                    }
                }
                break;
        }


        if (data == null && original != null)
        {
            ((Surface)original).m_Surface.mark_dirty ();

            context.operator = Graphic.Operator.SOURCE;
            context.pattern  = original;
            context.paint ();
            context.operator = Graphic.Operator.OVER;
        }
        else
        {
            m_Surface.mark_dirty ();
        }
    }

    internal override void
    exponential_blur (int inRadius) throws Graphic.Error
    {
        if (inRadius < 1)
            return;

        int alpha = (int) ((1 << cAlphaPrecision) * (1.0 - Math.exp (-2.3 / (inRadius + 1.0))));
        int height = (int)size.height;
        int width = (int)size.width;

        var original = new Graphic.Surface ((uint)width, (uint)height);
        var cr = original.context;

        cr.operator = Graphic.Operator.SOURCE;
        cr.pattern = this;
        cr.paint ();

        uint8 *pixels = ((global::Cairo.ImageSurface)((Surface)original).m_Surface).get_data ();

        // Process Rows
        exponential_blur_rows (pixels, width, height, height / 2, height, 0, width, alpha);
        exponential_blur_rows (pixels, width, height, 0, height / 2, 0, width, alpha);

        // Process Columns
        exponential_blur_columns (pixels, width, height, width / 2, width, 0, height, alpha);
        exponential_blur_columns (pixels, width, height, 0, width / 2, 0, height, alpha);

        ((Surface)original).m_Surface.mark_dirty ();

        context.operator = Graphic.Operator.SOURCE;
        context.pattern  = original;
        context.paint ();
        context.operator = Graphic.Operator.OVER;
    }

    internal override void
    gaussian_blur (int inRadius) throws Graphic.Error
    {
        var gausswidth = inRadius * 2 + 1;
        var kernel = build_gaussian_kernel (gausswidth);

        int width = (int)size.width;
        int height = (int)size.height;

        var original = new Graphic.Surface ((uint)width, (uint)height);
        var cr = original.context;

        cr.operator = Graphic.Operator.SOURCE;
        cr.pattern = this;
        cr.paint ();

        uint8 *src = ((global::Cairo.ImageSurface)((Surface)original).m_Surface).get_data ();

        var size = height * ((global::Cairo.ImageSurface)((Surface)original).m_Surface).get_stride ();

        var abuffer = new double[size];
        var bbuffer = new double[size];

        // Copy image to double[] for faster horizontal pass
        for (var i = 0; i < size; i++)
            abuffer[i] = (double) src[i];

        // Precompute horizontal shifts
        var shiftar = new int[int.max (width, height), gausswidth];
        for (var x = 0; x < width; x++)
        {
            for (var k = 0; k < gausswidth; k++)
            {
                var shift = k - inRadius;
                if (x + shift <= 0 || x + shift >= width)
                    shiftar[x, k] = 0;
                else
                    shiftar[x, k] = shift * 4;
            }
        }

        // Horizontal Pass
        gaussian_blur_horizontal (abuffer, bbuffer, kernel, gausswidth, width, height, height / 2, height, shiftar);
        gaussian_blur_horizontal (abuffer, bbuffer, kernel, gausswidth, width, height, 0, height / 2, shiftar);

        // Clear buffer
        Posix.memset (abuffer, 0, sizeof(double) * size);

        // Precompute vertical shifts
        shiftar = new int[int.max (width, height), gausswidth];
        for (var y = 0; y < height; y++)
        {
            for (var k = 0; k < gausswidth; k++)
            {
                var shift = k - inRadius;
                if (y + shift <= 0 || y + shift >= height)
                    shiftar[y, k] = 0;
                else
                    shiftar[y, k] = shift * width * 4;
            }
        }

        // Vertical Pass
        gaussian_blur_vertical (bbuffer, abuffer, kernel, gausswidth, width, height, width / 2, width, shiftar);
        gaussian_blur_vertical (bbuffer, abuffer, kernel, gausswidth, width, height, 0, width / 2, shiftar);

        // Save blurred image to original uint8[]
        for (var i = 0; i < size; i++)
            src[i] = (uint8) abuffer[i];

        ((Surface)original).m_Surface.mark_dirty ();

        context.operator = Graphic.Operator.SOURCE;
        context.pattern  = original;
        context.paint ();
        context.operator = Graphic.Operator.OVER;
    }

    internal override void
    render_noise () throws Graphic.Error
    {
        int width = (int)size.width;
        int height = (int)size.height;

        Graphic.Surface? original = null;
        uint8 *src = (uint8*)data;
        int size = 0;
        if (src == null || format != Graphic.Surface.Format.A8)
        {
            original = new Graphic.Surface.with_format (Graphic.Surface.Format.A8, (uint)width, (uint)height);
            src = ((global::Cairo.ImageSurface)((Surface)original).native).get_data ();
            size = height * ((global::Cairo.ImageSurface)((Surface)original).native).get_stride ();
        }
        else
        {
            size = height * ((global::Cairo.ImageSurface)native).get_stride ();
        }

        for (var i = 0; i < size; i++)
        {
            s_Seed = (214013 * s_Seed + 2531011);
            src[i] = (uint8)(((s_Seed >> 16) & 0x7FFF) % 255);
        }

        if (original != null)
        {
            ((Surface)original).m_Surface.mark_dirty ();

            context.operator = Graphic.Operator.SOURCE;
            context.pattern  = original;
            context.paint ();
            context.operator = Graphic.Operator.OVER;
        }
        else
        {
            m_Surface.mark_dirty ();
        }
    }

    internal override void
    flush () throws Graphic.Error
    {
        m_Surface.flush ();
        status ();
    }

    internal override void
    dump (string inFilename) throws Graphic.Error
    {
        m_Surface.write_to_png (inFilename);
        status ();
    }
}

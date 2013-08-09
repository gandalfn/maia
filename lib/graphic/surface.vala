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
    // properties
    private Context m_Context;

    // accessors
    public Graphic.Size size { get; construct set; default = Graphic.Size (0, 0); }

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
     * @param radius the blur radius
     * @param process_count the number of times to perform the operation
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
     * @param radius the blur radius
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
     * @param radius the blur radius
     */
    public virtual void
    gaussian_blur (int inRadius) throws Graphic.Error
    {
        throw new Error.NOT_IMPLEMENTED ("Gaussian blur not implemented");
    }
}

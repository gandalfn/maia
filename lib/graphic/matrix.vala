/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * matrix.vala
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

[CCode (has_type_id = false)]
public struct Maia.Graphic.Matrix
{
    public double xx;
    public double yx;
    public double xy;
    public double yy;
    public double x0;
    public double y0;

    public Matrix (double inXX, double inYX,
                   double inXY, double inYY,
                   double inX0, double inY0)
    {
        xx = inXX;
        yx = inYX;
        xy = inXY;
        yy = inYY;
        x0 = inX0;
        y0 = inY0;
    }

    public Matrix.identity ()
    {
        xx = 1;
        yx = 0;
        xy = 0;
        yy = 1;
        x0 = 0;
        y0 = 0;
    }

    private inline double
    compute_determinant ()
    {
        return xx * yy - yx * xy;
    }

    private inline void
    get_affine (out double outXX, out double outYX, out double outXY, out double outYY, out double outX0, out double outY0)
    {
        outXX  = xx;
        outYX  = yx;

        outXY  = xy;
        outYY  = yy;

        outX0 = x0;
        outY0 = y0;
    }

    private inline void
    compute_adjoint ()
    {
        double a, b, c, d, tx, ty;

        get_affine (out a,  out b, out c,  out d, out tx, out ty);

        xx = d;
        yx = -b;
        xy = -c;
        yy = a;
        x0 = c * ty - d * tx;
        y0 = b * tx - a * ty;
    }

    private inline void
    scalar_multiply (double inScalar)
    {
        xx *= inScalar;
        yx *= inScalar;

        xy *= inScalar;
        yy *= inScalar;

        x0 *= inScalar;
        y0 *= inScalar;
    }

    public bool
    is_identity ()
    {
        return xx == 1 && yx == 0 && yy == 1 && xy == 0 && x0 == 0 && y0 == 0;
    }

    public void
    invert () throws Graphic.Error
    {
        if (xy == 0.0 && yx == 0.0)
        {
            x0 = -x0;
            y0 = -y0;

            if (xx != 1.0)
            {
                if (xx == 0.0)
                    throw new Graphic.Error.INVALID_MATRIX ("Cannot invert matrix");

                xx = 1.0 / xx;
                x0 *= xx;
            }

            if (yy != 1.0)
            {
                if (yy == 0.0)
                    throw new Graphic.Error.INVALID_MATRIX ("Cannot invert matrix");

                yy = 1.0 / yy;
                y0 *= yy;
            }
        }
        else
        {
            double det = compute_determinant ();

            if (!((det * det) >= 0.0))
                throw new Graphic.Error.INVALID_MATRIX ("Cannot invert matrix");

            if (det == 0.0)
                throw new Graphic.Error.INVALID_MATRIX ("Cannot invert matrix");

            compute_adjoint ();
            scalar_multiply (1.0 / det);
        }
    }

    public void
    multiply (Matrix inMatrix)
    {
        Matrix m = Matrix.identity ();

        m.xx = inMatrix.xx * xx + inMatrix.yx * xy;
        m.yx = inMatrix.xx * yx + inMatrix.yx * yy;

        m.xy = inMatrix.xy * xx + inMatrix.yy * xy;
        m.yy = inMatrix.xy * yx + inMatrix.yy * yy;

        m.x0 = inMatrix.x0 * xx + inMatrix.y0 * xy + x0;
        m.y0 = inMatrix.x0 * yx + inMatrix.y0 * yy + y0;

        xx = m.xx;
        yx = m.yx;
        xy = m.xy;
        yy = m.yy;
        x0 = m.x0;
        y0 = m.y0;
    }

    public string
    to_string ()
    {
        return "%g, %g, %g, %g, %g, %g".printf (xx, yx, xy, yy, x0, y0);
    }
}

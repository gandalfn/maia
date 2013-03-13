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

    public void
    multiply (Matrix inMatrix)
    {
        unowned Matrix m = this;

        xx = m.xx * inMatrix.xx + m.yx * inMatrix.xy;
        yx = m.xx * inMatrix.yx + m.yx * inMatrix.yy;

        xy = m.xy * inMatrix.xx + m.yy * inMatrix.xy;
        yy = m.xy * inMatrix.yx + m.yy * inMatrix.yy;

        x0 = m.x0 * inMatrix.xx + m.y0 * inMatrix.xy + inMatrix.x0;
        y0 = m.x0 * inMatrix.yx + m.y0 * inMatrix.yy + inMatrix.y0;
    }
}

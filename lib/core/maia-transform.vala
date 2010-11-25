/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-transform.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public struct Maia.Matrix
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

public class Maia.Transform : Object
{
    // Base matrix
    private Maia.Matrix? m_BaseMatrix = null;

    // Matrix with transform queue
    private Maia.Matrix? m_FinalMatrix = null;

    // Matrix queue
    private Map<uint32, Transform> m_Queue;

    public Maia.Matrix matrix {
        get {
            return m_FinalMatrix;
        }
    }

    public Notification<void> changed;

    /**
     * Create a new transform stack
     */
    public Transform (double inXx, double inYx, 
                      double inXy, double inYy,
                      double inX0, double inY0)
    {
        m_Queue = new Map<uint32, Transform> ();
        changed = new Notification<void> ("changed");
        m_BaseMatrix = Matrix (inXx, inXy, inYx, inYy, inY0, inY0);
        m_FinalMatrix = (owned)m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     */
    public Transform.identity ()
    {
        m_Queue = new Map<uint32, Transform> ();
        m_BaseMatrix = Matrix.identity ();
        m_FinalMatrix = (owned)m_BaseMatrix;
    }

    private void
    recalculate_final_matrix ()
    {
        m_FinalMatrix = (owned)m_BaseMatrix;
        foreach (Pair<uint32, Transform> pair in m_Queue)
            m_FinalMatrix.multiply (pair.second.m_FinalMatrix);
    }

    /**
     * Applies a translation by tx, ty to the transformation.
     *
     * @param inTx amount to translate in the X direction
     * @param inTy amount to translate in the Y direction
     */
    public void 
    translate (double inTx, double inTy)
    {
        // translate base matrix
        Matrix matrix = Matrix (1, 0, 0, 1, inTx, inTy);
        m_BaseMatrix.multiply (matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed.post (this);
    }

    /**
     * Applies scaling by sx, sy to the transformation.
     *
     * @param inSx scale factor in the X direction
     * @param inSy scale factor in the Y direction
     */
    public void 
    scale (double inSx, double inSy)
    {
        // translate base matrix
        Matrix matrix = Matrix (inSx, 0, 0, inSy, 0, 0);
        m_BaseMatrix.multiply (matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed.post (this);
    }

    /**
     * Applies rotation by radians to the transformation.
     *
     * @param inRadians angle of rotations, in radians.
     */
    public void 
    rotate (double inRadians)
    {
        // translate base matrix
        double s = Posix.sin(inRadians);
        double c = Posix.cos(inRadians);
        Matrix matrix = Matrix (c, s, -s, c, 0, 0);
        m_BaseMatrix.multiply (matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed.post (this);
    }

    /**
     * Post-multiplies a skewX transformation on the transformation.
     *
     * @param inRadians Skew angle.
     */
    public void 
    skew_x (double inRadians)
    {
        // translate base matrix
        Matrix matrix = Matrix (1, 0, Posix.tan(inRadians), 1, 0, 0);
        m_BaseMatrix.multiply (matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed.post (this);
    }

    /**
     * Post-multiplies a skewY transformation on the transformation.
     *
     * @param inRadians Skew angle.
     */
    public void 
    skew_y (double inRadians)
    {
        // translate base matrix
        Matrix matrix = Matrix (1, Posix.tan(inRadians), 0, 1, 0, 0);
        m_BaseMatrix.multiply (matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed.post (this);
    }

    /**
     * Push a transformation into the transformation
     *
     * @param inKey matrix key
     * @param inTransform to push
     */
    public void
    push (uint32 inKey, Transform inTransform)
    {
        if (!(inKey in m_Queue))
        {
            // append transform in queue replace if exist
            m_Queue.set(inKey, inTransform);

            // recalculate final matrix
            recalculate_final_matrix ();

            // connect on transform changed signal
            inTransform.changed.watch (Observer.fun<void> (recalculate_final_matrix));
        }
    }

    /**
     * Pop a transformation from the transformation queue
     *
     * @param inKey transform key queue
     */
    public void
    pop (uint32 inKey)
    {
        if (inKey in m_Queue)
        {
            // disconnect from transform changed
            m_Queue[inKey].changed.unwatch (Observer.fun<void> (recalculate_final_matrix));

            // remove transform in queue if exist
            m_Queue.unset (inKey);

            // recalculate final matrix
            recalculate_final_matrix ();
        }
    }
}

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
    double m_XX;
    double m_YX;
    double m_XY;
    double m_YY;
    double m_X0;
    double m_Y0;

    public Matrix (double inXX, double inYX,
                   double inXY, double inYY,
                   double inX0, double inY0)
    {
        m_XX = inXX;
        m_YX = inYX;
        m_XY = inXY;
        m_YY = inYY;
        m_X0 = inX0;
        m_Y0 = inY0;
    }

    public Matrix.identity ()
    {
        m_XX = 1;
        m_YX = 0;
        m_XY = 0;
        m_YY = 1;
        m_X0 = 0;
        m_Y0 = 0;
    }

    public void
    multiply (Matrix inMatrix)
    {
        Matrix m = this;

        m_XX = m.m_XX * inMatrix.m_XX + m.m_YX * inMatrix.m_XY;
        m_YX = m.m_XX * inMatrix.m_YX + m.m_YX * inMatrix.m_YY;

        m_XY = m.m_XY * inMatrix.m_XX + m.m_YY * inMatrix.m_XY;
        m_YY = m.m_XY * inMatrix.m_YX + m.m_YY * inMatrix.m_YY;

        m_X0 = m.m_X0 * inMatrix.m_XX + m.m_Y0 * inMatrix.m_XY + inMatrix.m_X0;
        m_Y0 = m.m_X0 * inMatrix.m_YX + m.m_Y0 * inMatrix.m_YY + inMatrix.m_Y0;
    }
}

public class Maia.Transform : Object
{
    // Base matrix
    private Maia.Matrix? m_BaseMatrix = null;

    // Matrix with transform queue
    private Maia.Matrix? m_FinalMatrix = null;

    // Matrix queue
    private Vala.HashMap<uint32, Transform> m_Queue;

    public Maia.Matrix matrix {
        get {
            return m_FinalMatrix;
        }
    }

    public signal void changed ();

    /**
     * Create a new transform stack
     */
    public Transform (double inXx, double inYx, 
                      double inXy, double inYy,
                      double inX0, double inY0)
    {
        m_Queue = new Vala.HashMap<uint32, Transform>();
        m_BaseMatrix = Matrix(inXx, inXy, inYx, inYy, inY0, inY0);
        m_FinalMatrix = m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     */
    public Transform.identity ()
    {
        m_Queue = new Vala.HashMap<uint32, Transform>();
        m_BaseMatrix = Matrix.identity ();
        m_FinalMatrix = m_BaseMatrix;
    }

    private void
    recalculate_final_matrix ()
    {
        m_FinalMatrix = m_BaseMatrix;
        foreach (uint32 k in m_Queue.get_keys ())
            m_FinalMatrix.multiply (m_Queue[k].m_FinalMatrix);
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
        changed ();
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
        changed ();
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
        changed ();
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
        changed ();
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
        changed ();
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
            inTransform.changed.connect (recalculate_final_matrix);
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
            m_Queue[inKey].changed.connect (recalculate_final_matrix);

            // remove transform in queue if exist
            m_Queue.remove(inKey);

            // recalculate final matrix
            recalculate_final_matrix ();
        }
    }
}

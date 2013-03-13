/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * transform.vala
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

public class Maia.Graphic.Transform : GLib.Object
{
    // Base matrix
    private Matrix? m_BaseMatrix = null;

    // Matrix with transform queue
    private Matrix? m_FinalMatrix = null;

    // Matrix queue
    private Map<uint32, Transform> m_Queue;

    // Accessors
    public Matrix? matrix {
        get {
            return m_FinalMatrix;
        }
    }

    // Signals
    public signal void changed ();

    /**
     * Create a new transform stack
     */
    public Transform (double inXx, double inYx,
                      double inXy, double inYy,
                      double inX0, double inY0)
    {
        m_Queue = new Map<uint32, Transform> ();
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
        double s = GLib.Math.sin(inRadians);
        double c = GLib.Math.cos(inRadians);
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
        Matrix matrix = Matrix (1, 0, GLib.Math.tan(inRadians), 1, 0, 0);
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
        Matrix matrix = Matrix (1, GLib.Math.tan(inRadians), 0, 1, 0, 0);
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
            changed.connect (recalculate_final_matrix);
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
            // connect to transform changed
            changed.connect (recalculate_final_matrix);

            // remove transform in queue if exist
            m_Queue.unset (inKey);

            // recalculate final matrix
            recalculate_final_matrix ();
        }
    }
}

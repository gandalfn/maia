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

public class Maia.Graphic.Transform : Core.Object
{
    // properties
    private Matrix m_BaseMatrix;
    private Matrix m_FinalMatrix;

    // accessors
    public Matrix matrix {
        get {
            return m_FinalMatrix;
        }
    }

    // signals
    public signal void changed ();

    // static methods
    static construct
    {
        Manifest.AttributeScanner.register_transform_func (typeof (Transform), attribute_to_transform);
        Manifest.Function.register_transform_func (typeof (Transform), "matrix",    attributes_to_transform);
        Manifest.Function.register_transform_func (typeof (Transform), "translate", attribute_to_translate_transform);
        Manifest.Function.register_transform_func (typeof (Transform), "scale",     attribute_to_scale_transform);
        Manifest.Function.register_transform_func (typeof (Transform), "rotate",    attribute_to_rotate_transform);
        Manifest.Function.register_transform_func (typeof (Transform), "skew",      attribute_to_skew_transform);

        GLib.Value.register_transform_func (typeof (Transform), typeof (string), transform_to_string);
    }

    static void
    transform_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Transform)))
    {
        Transform val = (Transform)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_transform (Manifest.AttributeScanner inScanner, ref GLib.Value outDest) throws Manifest.Error
    {
        double xx = 1, yx = 0, xy = 0, yy = 1, x0 = 0, y0 = 0;

        int cpt = 0;
        bool first = true;
        foreach (unowned Core.Object child in ((Core.Object)inScanner))
        {
            if (first && child is Manifest.Function)
            {
                outDest = (child as Manifest.Function).transform (typeof (Transform));
                return;
            }
            first = false;

            switch (cpt)
            {
                case 0:
                    xx = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 1:
                    yx = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 2:
                    xy = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 3:
                    yy = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 4:
                    x0 = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 5:
                    y0 = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s attribute", inScanner.to_string ());
            }
            cpt++;
        }

        if (cpt <= 5)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s attribute", inScanner.to_string ());
        }

        outDest = new Transform (xx, yx, xy, yy, x0, y0);
    }

    static void
    attributes_to_transform (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        double xx = 1, yx = 0, xy = 0, yy = 1, x0 = 0, y0 = 0;

        int cpt = 0;
        foreach (unowned Core.Object child in ((Core.Object)inFunction))
        {
            switch (cpt)
            {
                case 0:
                    xx = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 1:
                    yx = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 2:
                    xy = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 3:
                    yy = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 4:
                    x0 = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                case 5:
                    y0 = (double)(child as Manifest.Attribute).transform (typeof (double));
                    break;

                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt <= 5)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }

        outDest = new Transform (xx, yx, xy, yy, x0, y0);
    }

    static void
    attribute_to_translate_transform (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        double translate_x = 1.0, translate_y = 1.0;

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    translate_x = (double)arg.transform (typeof (double));
                    break;
                case 1:
                    translate_y = (double)arg.transform (typeof (double));
                    break;
                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt <= 1)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }

        outDest = new Transform (1, 0, 0, 1, translate_x, translate_y);
    }

    static void
    attribute_to_scale_transform (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        double scale_x = 1.0, scale_y = 1.0;

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    scale_x = (double)arg.transform (typeof (double));
                    break;
                case 1:
                    scale_y = (double)arg.transform (typeof (double));
                    break;
                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt <= 1)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }

        outDest = new Transform (scale_x, 0, 0, scale_y, 0, 0);
    }

    static void
    attribute_to_rotate_transform (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        double rotate = 0.0;

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    rotate = (double)arg.transform (typeof (double));
                    break;
                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt != 1)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }

        double s = GLib.Math.sin(rotate);
        double c = GLib.Math.cos(rotate);
        outDest = new Transform (c, s, -s, c, 0, 0);
    }

    static void
    attribute_to_skew_transform (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        double skew_x = 0.0, skew_y = 0.0;

        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    skew_x = (double)arg.transform (typeof (double));
                    break;
                case 1:
                    skew_y = (double)arg.transform (typeof (double));
                    break;
                default:
                    throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
            }
            cpt++;
        }

        if (cpt <= 1)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }

        outDest = new Transform (1, GLib.Math.tan(skew_y), GLib.Math.tan(skew_x), 1, 0, 0);
    }

    // methods
    /**
     * Create a new transform stack
     */
    public Transform (double inXx, double inYx,
                      double inXy, double inYy,
                      double inX0, double inY0)
    {
        m_BaseMatrix = Matrix (inXx, inXy, inYx, inYy, inX0, inY0);
        m_FinalMatrix = m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     *
     * @param inMatrix initial matrix of transform
     */
    public Transform.from_matrix (Matrix inMatrix)
    {
        m_BaseMatrix = inMatrix;
        m_FinalMatrix = m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     */
    public Transform.identity ()
    {
        m_BaseMatrix = Matrix.identity ();
        m_FinalMatrix = m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     *
     * @param inTx amount to translate in the X direction
     * @param inTy amount to translate in the Y direction
     */
    public Transform.init_translate (double inTx, double inTy)
    {
        m_BaseMatrix = Matrix (1, 0, 0, 1, inTx, inTy);
        m_FinalMatrix = m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     *
     * @param inSx scale factor in the X direction
     * @param inSy scale factor in the Y direction
     */
    public Transform.init_scale (double inSx, double inSy)
    {
        m_BaseMatrix = Matrix (inSx, 0, 0, inSy, 0, 0);
        m_FinalMatrix = m_BaseMatrix;
    }

    /**
     * Create a new transform stack
     *
     * @param inRadians angle of rotations, in radians;
     */
    public Transform.init_rotate (double inRadians)
    {
        double s = GLib.Math.sin (inRadians);
        double c = GLib.Math.cos (inRadians);
        m_BaseMatrix = Matrix (c, s, -s, c, 0, 0);
        m_FinalMatrix = m_BaseMatrix;
    }

    private void
    recalculate_final_matrix ()
    {
        m_FinalMatrix = m_BaseMatrix;
        foreach (unowned Core.Object child in this)
        {
            unowned Transform transform = (Transform)child;
            m_FinalMatrix.multiply (transform.m_FinalMatrix);
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Transform;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        ((Transform)inObject).changed.connect (recalculate_final_matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed ();
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        ((Transform)inObject).changed.disconnect (recalculate_final_matrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed ();
    }

    internal override string
    to_string ()
    {
        return m_FinalMatrix.to_string ();
    }

    internal override int
    compare (Core.Object inOther)
    {
        // do not sort transform
        return 0;
    }

    /**
     * Reset transform to identity matrix
     */
    public void
    init ()
    {
        // init base matrix
        m_BaseMatrix = Matrix.identity ();

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed ();
    }

    /**
     * Multiply a matrix to the transformation.
     *
     * @param inMatrix matrix to multiply with transformation
     */
    public void
    multiply (Matrix inMatrix)
    {
        // multiply base matrix
        m_BaseMatrix.multiply (inMatrix);

        // recalculate final matrix
        recalculate_final_matrix ();

        // send changed signal
        changed ();
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
        double s = GLib.Math.sin (inRadians);
        double c = GLib.Math.cos (inRadians);
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
}

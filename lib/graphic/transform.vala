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
    // types
    public class ChangedNotification : Core.Notification
    {
        private unowned Transform? m_Transform;

        [CCode (notify = false)]
        public Transform transform {
            get {
                return m_Transform;
            }
            set {
                m_Transform = value;
            }
        }

        internal ChangedNotification (string inName)
        {
            base (inName);
        }
    }

    // properties
    private Matrix m_BaseMatrix;
    private Matrix m_FinalMatrix;
    private Matrix m_BaseInvertMatrix;
    private Matrix m_FinalInvertMatrix;
    private int    m_Compare = 0;
    private bool   m_IsRotate = false;

    // accessors
    public Matrix matrix {
        get {
            return m_FinalMatrix;
        }
    }

    public Matrix matrix_invert {
        get {
            return m_FinalInvertMatrix;
        }
    }

    public bool is_rotate {
        get {
            return m_IsRotate;
        }
    }

    public bool have_rotate {
        get {
            bool ret = m_IsRotate;

            if (!ret)
            {
                foreach (unowned Core.Object child in this)
                {
                    ret |= ((Transform)child).have_rotate;
                    if (ret) break;
                }
            }

            return ret;
        }
    }

    // notifications
    public ChangedNotification changed {
        get {
            unowned ChangedNotification ret = notifications["changed"] as ChangedNotification;

            if (ret == null)
            {
                var notification = new ChangedNotification ("changed");
                notifications.add (notification);
                ret = notification;
            }

            return ret;
        }
    }

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

        outDest = new Transform.init_translate (translate_x, translate_y);
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

        outDest = new Transform.init_scale (scale_x, scale_y);
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

        outDest = new Transform.init_rotate (rotate);
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
        m_BaseInvertMatrix = m_BaseMatrix.to_invert ();
        m_FinalInvertMatrix = m_BaseInvertMatrix;
        m_IsRotate = m_FinalMatrix.xx == m_FinalMatrix.yy && m_FinalMatrix.xy == -m_FinalMatrix.yx && (m_FinalMatrix.xy != 0 || m_FinalMatrix.yx != 0);
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
        m_BaseInvertMatrix = m_BaseMatrix.to_invert ();
        m_FinalInvertMatrix = m_BaseInvertMatrix;
        m_IsRotate = m_FinalMatrix.xx == m_FinalMatrix.yy && m_FinalMatrix.xy == -m_FinalMatrix.yx && (m_FinalMatrix.xy != 0 || m_FinalMatrix.yx != 0);
    }

    /**
     * Create a new transform stack
     */
    public Transform.identity ()
    {
        m_BaseMatrix = Matrix.identity ();
        m_FinalMatrix = m_BaseMatrix;
        m_BaseInvertMatrix = m_BaseMatrix.to_invert ();
        m_FinalInvertMatrix = m_BaseInvertMatrix;
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
        m_BaseInvertMatrix = Matrix (1, 0, 0, 1, -inTx, -inTy);
        m_FinalInvertMatrix = m_BaseInvertMatrix;
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
        m_BaseInvertMatrix = Matrix (1 / inSx, 0, 0, 1 / inSy, 0, 0);
        m_FinalInvertMatrix = m_BaseInvertMatrix;
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

        double si = GLib.Math.sin (-inRadians);
        double ci = GLib.Math.cos (-inRadians);
        m_BaseInvertMatrix = Matrix (ci, si, -si, ci, 0, 0);
        m_FinalInvertMatrix = m_BaseInvertMatrix;

        m_IsRotate = true;
    }

    /**
     * Create a new transform has an invert of inTransform
     *
     * @param inTransform transform to invert
     *
     * @throws Graphic.Error if something goes wrong
     */
    public Transform.invert (Transform inTransform) throws Graphic.Error
    {
        m_BaseMatrix = inTransform.m_BaseInvertMatrix;
        m_FinalMatrix = inTransform.m_BaseInvertMatrix;
        m_BaseInvertMatrix = inTransform.m_BaseMatrix;
        m_FinalInvertMatrix = inTransform.m_BaseMatrix;

        foreach (unowned Core.Object child in inTransform)
        {
            add (new Transform.invert ((Transform)child));
        }
    }

    private void
    recalculate_final_matrix ()
    {
        var old = m_FinalMatrix;
        var old_invert = m_FinalInvertMatrix;

        m_FinalMatrix = m_BaseMatrix;
        m_FinalInvertMatrix = m_BaseInvertMatrix;
        foreach (unowned Core.Object child in this)
        {
            unowned Transform transform = (Transform)child;
            m_FinalMatrix.post_multiply (transform.m_FinalMatrix);
            m_FinalInvertMatrix.multiply (transform.m_FinalInvertMatrix);
        }

        if (!old.equal (m_FinalMatrix) || !old_invert.equal (m_FinalInvertMatrix))
        {
            unowned ChangedNotification notification = changed;
            notification.transform = this;
            notification.post ();
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

        ((Transform)inObject).changed.add_object_observer (recalculate_final_matrix);

        // recalculate final matrix
        recalculate_final_matrix ();
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        ((Transform)inObject).changed.remove_observer (recalculate_final_matrix);

        // recalculate final matrix
        recalculate_final_matrix ();
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
        return m_Compare;
    }

    /**
     * Append transform in child transforms
     *
     * @param inTransform transform to prepend to transform childs
     */
    public void
    append (Transform inTransform)
    {
        inTransform.parent = this;
    }

    /**
     * Prepend transform in child transforms
     *
     * @param inTransform transform to prepend to transform childs
     */
    public void
    prepend (Transform inTransform)
    {
        inTransform.m_Compare = -1;
        inTransform.parent = this;
        inTransform.m_Compare = 0;
    }

    /**
     * Copy transform
     */
    public Transform
    copy ()
    {
        Transform ret = new Transform.identity ();
        ret.m_BaseMatrix = m_BaseMatrix;
        ret.m_FinalMatrix = m_BaseMatrix;
        ret.m_BaseInvertMatrix = m_BaseInvertMatrix;
        ret.m_FinalInvertMatrix = m_BaseInvertMatrix;
        ret.m_Compare = m_Compare;
        ret.m_IsRotate = m_IsRotate;

        foreach (unowned Core.Object child in this)
        {
            ret.add (((Transform)child).copy ());
        }

        return ret;
    }

    /**
     * Create a transform which is linked of this transform
     */
    public Transform
    link ()
    {
        Transform ret = new Transform.identity ();
        ret.m_BaseMatrix = m_FinalMatrix;
        ret.m_FinalMatrix = m_FinalMatrix;
        ret.m_BaseInvertMatrix = m_FinalInvertMatrix;
        ret.m_FinalInvertMatrix = m_FinalInvertMatrix;

        changed.add_object_observer (ret.on_linked_changed);

        return ret;
    }

    private void
    on_linked_changed (Core.Notification inNotification)
    {
        unowned ChangedNotification? notification = (ChangedNotification)inNotification;

        m_BaseMatrix = notification.transform.m_FinalMatrix;
        m_BaseInvertMatrix = notification.transform.m_FinalInvertMatrix;

        recalculate_final_matrix ();
    }

    /**
     * Reset transform to identity matrix
     */
    public void
    init ()
    {
        // clear childs
        clear_childs ();

        // init base matrix
        m_BaseMatrix = Matrix.identity ();

        // init invert base matrix
        m_BaseInvertMatrix = m_BaseMatrix.to_invert ();

        // init rotate
        m_IsRotate = false;

        // recalculate final matrix
        recalculate_final_matrix ();
    }

    /**
     * Apply a matrix to the transformation.
     *
     * @param inMatrix matrix to multiply with transformation
     */
    public void
    apply (Matrix inMatrix)
    {
        add (new Transform.from_matrix (inMatrix));
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
        add (new Transform.init_translate (inTx, inTy));
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
        add (new Transform.init_scale (inSx, inSy));
    }

    /**
     * Applies rotation by radians to the transformation.
     *
     * @param inRadians angle of rotations, in radians.
     */
    public void
    rotate (double inRadians)
    {
        add (new Transform.init_rotate (inRadians));
    }

    /**
     * Post-multiplies a skewX transformation on the transformation.
     *
     * @param inRadians Skew angle.
     */
    public void
    skew_x (double inRadians)
    {
        add (new Transform (1, 0, GLib.Math.tan(inRadians), 1, 0, 0));
    }

    /**
     * Post-multiplies a skewY transformation on the transformation.
     *
     * @param inRadians Skew angle.
     */
    public void
    skew_y (double inRadians)
    {
        add (new Transform (1, GLib.Math.tan(inRadians), 0, 1, 0, 0));
    }

    /**
     * Apply center translate to rotate transform
     *
     * @param inCx X center of rotate
     * @param inCy Y center of rotate
     */
    public void
    apply_center_rotate (double inCx, double inCy)
    {
        if (m_IsRotate)
        {
            var m = m_BaseMatrix;
            m_BaseMatrix = Matrix (1, 0, 0, 1, -inCx, -inCy);
            m_BaseMatrix.post_multiply (m);
            m_BaseMatrix.post_multiply (Matrix (1, 0, 0, 1, inCx, inCy));
            m_FinalMatrix = m_BaseMatrix;

            m = m_BaseInvertMatrix;
            m_BaseInvertMatrix = Matrix (1, 0, 0, 1, inCx, inCy);
            m_BaseInvertMatrix.multiply (m);
            m_BaseInvertMatrix.multiply (Matrix (1, 0, 0, 1, -inCx, -inCy));
            m_FinalInvertMatrix = m_BaseInvertMatrix;
        }
        foreach (unowned Core.Object child in this)
        {
            ((Transform)child).apply_center_rotate (inCx, inCy);
        }

        recalculate_final_matrix ();
    }
}

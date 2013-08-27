/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * attribute.vala
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

public class Maia.Manifest.Attribute : Core.Object
{
    // Types
    public delegate void TransformFunc (Attribute inAttribute, ref GLib.Value outValue) throws Error;

    private class Transform : Core.Object
    {
        public GLib.Type     gtype;
        public TransformFunc func;

        public Transform (GLib.Type inType, owned TransformFunc inFunc)
        {
            gtype = inType;
            func = (owned)inFunc;
        }

        public override int
        compare (Core.Object inOther)
        {
            return (int)(gtype - (inOther as Transform).gtype);
        }

        public int
        compare_with_type (GLib.Type inType)
        {
            return (int)(gtype - inType);
        }
    }

    // Static properties
    private static bool                s_SimpleTypeRegistered = false;
    private static Core.Set<Transform> s_Transforms;

    // Properties
    private string  m_Value;
    private unowned Object? m_Owner = null;

    // Accessors
    public unowned Object owner {
        get {
            return m_Owner;
        }
    }

    // Static methods
    private static inline void
    register_simple_type ()
    {
        if (!s_SimpleTypeRegistered)
        {
            register_transform_func (typeof (bool),        attribute_to_bool);
            register_transform_func (typeof (int),         attribute_to_int);
            register_transform_func (typeof (uint),        attribute_to_uint);
            register_transform_func (typeof (long),        attribute_to_long);
            register_transform_func (typeof (ulong),       attribute_to_ulong);
            register_transform_func (typeof (double),      attribute_to_double);
            register_transform_func (typeof (Orientation), attribute_to_orientation);

            GLib.Value.register_transform_func (typeof (bool), typeof (string), bool_to_string);
            GLib.Value.register_transform_func (typeof (double), typeof (string), double_to_string);
            GLib.Value.register_transform_func (typeof (Orientation), typeof (string), orientation_to_string);

            s_SimpleTypeRegistered = true;
        }
    }

    private static void
    attribute_to_double (Attribute inAttribute, ref GLib.Value outValue)
    {
        string val = inAttribute.get ().down ().strip ();
        string locale = Os.setlocale (Os.LC_NUMERIC, "C");

        if (val.has_prefix ("pi"))
        {
            if ("/" in val)
            {
                string[] expr = val.split ("/");

                if (expr.length > 1)
                {
                    double div = double.parse (expr[1].strip ());
                    if (div != 0.0)
                    {
                        outValue = GLib.Math.PI / div;
                    }
                    else
                    {
                        Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "Cannot parse pi double value %s", val);
                        outValue = 0.0;
                    }
                }
                else
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "Cannot parse pi double value %s", val);
                    outValue = 0.0;
                }
            }
            else
                outValue = GLib.Math.PI;
        }
        else
        {
            outValue = double.parse (inAttribute.get ());
        }

        Os.setlocale (Os.LC_NUMERIC, locale);
    }

    private static void
    attribute_to_int (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = int.parse (inAttribute.get ());
    }

    private static void
    attribute_to_uint (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = (uint)int.parse (inAttribute.get ());
    }

    private static void
    attribute_to_long (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = long.parse (inAttribute.get ());
    }

    private static void
    attribute_to_ulong (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = (ulong)long.parse (inAttribute.get ());
    }

    private static void
    attribute_to_bool (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = bool.parse (inAttribute.get ());
    }

    private static void
    attribute_to_orientation (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Orientation.from_string (inAttribute.get ());
    }

    private static void
    bool_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (bool)))
    {
        bool val = (bool)inSrc;

        outDest = val.to_string ();
    }

    private static void
    double_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (double)))
    {
        double val = (double)inSrc;

        outDest = "%g".printf (val);
    }

    private static void
    orientation_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Orientation)))
    {
        Orientation val = (Orientation)inSrc;

        outDest = val.to_string ();
    }

    public static void
    register_transform_func (GLib.Type inType, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Core.Set<Transform> ();
        }
        Transform transform = new Transform (inType, (owned)inFunc);
        s_Transforms.insert (transform);
    }

    // Methods
    /**
     * Create a new attribute
     *
     * @param inOwner owner of attribute
     * @param inValue attribute value
     */
    internal Attribute (Object? inOwner, string inValue)
    {
        m_Owner = inOwner;
        m_Value = inValue;
    }

    internal virtual void
    on_transform (GLib.Type inType, ref GLib.Value outValue) throws Error
    {
        unowned Transform? transform = s_Transforms.search<GLib.Type> (inType, Transform.compare_with_type);
        if (transform != null)
        {
            transform.func (this, ref outValue);
        }
        else if (outValue.holds (typeof (string)))
        {
            outValue = m_Value;
        }
        else
        {
            throw new Error.INVALID_TYPE ("Unknown transform for value %s", inType.name ());
        }
    }

    /**
     * Get the attribute value
     *
     * @return attribute value
     */
    public new string
    get ()
    {
        return m_Value;
    }

    /**
     * Convert the attribute to Value inType
     *
     * @param inType value type
     *
     * @return Value of attribute
     */
    public GLib.Value
    transform (GLib.Type inType) throws Error
    {
        GLib.Value val = GLib.Value (inType);
        if (inType.is_classed () && inType.class_peek () == null)
            inType.class_ref ();
        else
            register_simple_type ();

        on_transform (inType, ref val);

        return val;
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    can_append_child (Core.Object inChild)
    {
        return inChild is Attribute;
    }

    /**
     * {@inheritDoc}
     */
    internal override int
    compare (Core.Object inObject)
    {
        // do not sort child attributes
        return 0;
    }

    internal override string
    to_string ()
    {
        return m_Value;
    }
}

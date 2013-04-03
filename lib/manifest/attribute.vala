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

public class Maia.Manifest.Attribute : Object
{
    // Types
    public delegate void TransformFunc (Attribute inAttribute, ref GLib.Value outValue);

    private class Transform : Object
    {
        public GLib.Type     gtype;
        public TransformFunc func;

        public Transform (GLib.Type inType, owned TransformFunc inFunc)
        {
            gtype = inType;
            func = (owned)inFunc;
        }

        public override int
        compare (Object inOther)
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
    private static bool           s_SimpleTypeRegistered = false;
    private static Set<Transform> s_Transforms;

    // Properties
    private string m_Value;
    private Object m_Owner = null;

    // Accessors
    public Object owner {
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
            register_transform_func (typeof (bool),   attribute_to_bool);
            register_transform_func (typeof (int),    attribute_to_int);
            register_transform_func (typeof (uint),   attribute_to_uint);
            register_transform_func (typeof (long),   attribute_to_long);
            register_transform_func (typeof (ulong),  attribute_to_ulong);
            register_transform_func (typeof (double), attribute_to_double);

            s_SimpleTypeRegistered = true;
        }
    }

    private static void
    attribute_to_double (Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = double.parse (inAttribute.get ());
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

    public static void
    register_transform_func (GLib.Type inType, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Set<Transform> ();
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
    public Attribute (Object inOwner, string inValue)
    {
        m_Owner = inOwner;
        m_Value = inValue;
    }

    protected virtual void
    on_transform (GLib.Type inType, ref GLib.Value outValue)
    {
        unowned Transform? transform = s_Transforms.search<GLib.Type> (inType, Transform.compare_with_type);
        if (transform != null)
        {
            transform.func (this, ref outValue);
        }
        else
        {
            outValue = m_Value;
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
    transform (GLib.Type inType)
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
    public override bool
    can_append_child (Object inChild)
    {
        return inChild is Attribute;
    }

    /**
     * {@inheritDoc}
     */
    public override int
    compare (Object inObject)
    {
        // do not sort child attributes
        return 0;
    }
}

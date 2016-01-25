/*
 * field.vala
 * Copyright (C) Nicolas Bruguier 2010-2015 <gandalfn@club-internet.fr>
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

internal abstract class Maia.Protocol.Field : Core.Object, BufferChild
{
    // types
    public enum Type
    {
        BOOLEAN,
        BYTE,
        UINT16,
        INT16,
        UINT32,
        INT32,
        UINT64,
        INT64,
        DOUBLE,
        STRING,
        MESSAGE;

        internal GLib.Type
        to_gtype ()
        {
            switch (this)
            {
                case BOOLEAN:
                    return typeof (bool);

                case BYTE:
                    return typeof (uint8);

                case UINT16:
                    return typeof (uint);

                case INT16:
                    return typeof (int);

                case UINT32:
                    return typeof (uint32);

                case INT32:
                    return typeof (int32);

                case UINT64:
                    return typeof (uint64);

                case INT64:
                    return typeof (int64);

                case DOUBLE:
                    return typeof (double);

                case STRING:
                    return typeof (string);

                case MESSAGE:
                    return typeof (Message);
            }

            return GLib.Type.INVALID;
        }

        internal GLib.Type
        to_field_gtype ()
        {
            switch (this)
            {
                case BOOLEAN:
                    return typeof (BoolField);

                case BYTE:
                    return typeof (ByteField);

                case UINT16:
                    return typeof (UInt16Field);

                case INT16:
                    return typeof (Int16Field);

                case UINT32:
                    return typeof (UInt32Field);

                case INT32:
                    return typeof (Int32Field);

                case UINT64:
                    return typeof (UInt64Field);

                case INT64:
                    return typeof (Int64Field);

                case DOUBLE:
                    return typeof (DoubleField);

                case STRING:
                    return typeof (StringField);

                case MESSAGE:
                    return typeof (MessageField);
            }

            return GLib.Type.INVALID;
        }

        internal GLib.VariantType
        to_variant_type ()
        {
            switch (this)
            {
                case BOOLEAN:
                    return GLib.VariantType.BOOLEAN;

                case BYTE:
                    return GLib.VariantType.BYTE;

                case UINT16:
                    return GLib.VariantType.UINT16;

                case INT16:
                    return GLib.VariantType.INT16;

                case UINT32:
                    return GLib.VariantType.UINT32;

                case INT32:
                    return GLib.VariantType.INT32;

                case UINT64:
                    return GLib.VariantType.UINT64;

                case INT64:
                    return GLib.VariantType.INT64;

                case DOUBLE:
                    return GLib.VariantType.DOUBLE;

                case STRING:
                    return GLib.VariantType.STRING;

                case MESSAGE:
                    return GLib.VariantType.TUPLE;
            }

            return GLib.VariantType.ANY;
        }

        internal string
        to_string ()
        {
            switch (this)
            {
                case BOOLEAN:
                    return "bool";

                case BYTE:
                    return "byte";

                case UINT16:
                    return "uint16";

                case INT16:
                    return "in16";

                case UINT32:
                    return "uint32";

                case INT32:
                    return "int32";

                case UINT64:
                    return "uint64";

                case INT64:
                    return "int64";

                case DOUBLE:
                    return "double";

                case STRING:
                    return "string";
            }

            return "";
        }

        internal static Type
        from_string (string inVal)
        {
            switch (inVal.down ())
            {
                case "bool":
                    return BOOLEAN;

                case "byte":
                    return BYTE;

                case "uint16":
                    return UINT16;

                case "int16":
                    return INT16;

                case "uint32":
                    return UINT32;

                case "int32":
                    return INT32;

                case "uint64":
                    return UINT64;

                case "int64":
                    return INT64;

                case "double":
                    return DOUBLE;

                case "string":
                    return STRING;
            }

            return MESSAGE;
        }
    }

    // properties
    protected GLib.Value[] m_Values = {};

    // accessors
    public bool repeated { get; construct; default = false; }

    public int length {
        get {
            return m_Values.length;
        }
    }

    public abstract Type field_type { get; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public GLib.Variant serialize {
        owned get {
            GLib.Variant ret;
            if (repeated)
            {
                GLib.Variant[] childs = {};

                for (int cpt = 0; cpt < m_Values.length; ++cpt)
                {
                    childs += get_variant (cpt);
                }

                ret = new GLib.Variant.array (null, childs);
            }
            else
            {
                ret = get_variant (0);
            }

            return ret;
        }
        set {
            if (repeated)
            {
                GLib.return_if_fail (value.get_type ().is_array ());
                m_Values = {};

                for (int cpt = 0; cpt < value.n_children (); ++cpt)
                {
                    var variant = value.get_child_value (cpt);
                    m_Values += create_value ();
                    set_variant (cpt, variant);
                }
            }
            else
            {
                GLib.return_if_fail (!value.get_type ().is_array ());

                m_Values = {};
                m_Values += create_value ();
                set_variant (0, value);
            }
        }
    }

    public virtual string @default {
        set {
            if (!repeated && m_Values.length > 0)
            {
                if (field_type != Type.STRING)
                {
                    GLib.Value default_value = value;
                    if (!default_value.transform (ref m_Values[0]))
                    {
                        Log.critical (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Invalid default value $value for $name");
                    }
                }
                else
                {
                    m_Values[0] = value;
                }
            }
        }
    }

    // methods
    construct
    {
        if (!repeated)
        {
            m_Values += create_value ();
        }
    }

    public Field (string inName, bool inRepeated, string? inDefault)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), repeated: inRepeated, default: inDefault);
    }

    public virtual BufferChild
    copy ()
    {
        Field field = GLib.Object.new (field_type.to_field_gtype (), id: id, repeated: repeated) as Field;
        field.m_Values = {};
        foreach (unowned GLib.Value? val in m_Values)
        {
            field.add_value (val);
        }
        return field;
    }

    protected virtual GLib.Value
    create_value ()
    {
        return GLib.Value (field_type.to_gtype ());
    }

    public new GLib.Value
    @get (int inIndex)
        requires (inIndex < m_Values.length)
    {
        GLib.Value ret = create_value ();
        m_Values[inIndex].copy (ref ret);
        return ret;
    }

    public new void
    @set (int inIndex, GLib.Value inValue)
        requires (inIndex < m_Values.length)
        requires (GLib.Value.type_compatible (inValue.type (), m_Values[inIndex].type ()))
    {
        inValue.copy (ref m_Values[inIndex]);
    }

    public void
    clear ()
    {
        m_Values = {};

        if (!repeated)
        {
            m_Values += create_value ();
        }
    }

    public void
    resize (uint inSize)
    {
        if (inSize > m_Values.length)
        {
            for (int cpt = m_Values.length; cpt < inSize; ++cpt)
            {
                m_Values += create_value ();
            }
        }
        else if (inSize < m_Values.length)
        {
            m_Values.resize ((int)inSize);
        }
    }

    public virtual int add_value (GLib.Value inValue)
        requires ((!repeated && m_Values.length == 0) || repeated)
    {
        int ret = m_Values.length;
        m_Values += create_value ();
        set(ret, inValue);

        return ret;
    }

    public abstract GLib.Variant get_variant (int inIndex);
    public abstract void set_variant (int inIndex, GLib.Variant inVariant);

    internal override string
    to_string ()
    {
        string ret = "";

        if (repeated) ret += "repeated ";
        ret += field_type.to_string () + " " + name + ";";

        return ret;
    }
}

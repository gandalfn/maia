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
                    return typeof (uchar);

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

    public class Iterator
    {
        private unowned Field m_Field;
        private int m_Index;

        internal Iterator (Field inField)
        {
            m_Field = inField;
            m_Index = -1;
        }

        public bool
        next ()
        {
            m_Index++;

            return m_Index < m_Field.m_Values.length;
        }

        public unowned GLib.Value?
        @get ()
            requires (m_Index < m_Field.m_Values.length)
        {
            return m_Field.m_Values[m_Index];
        }
    }

    // properties
    protected GLib.Value[] m_Values = {};

    // accessors
    public bool repeated { get; construct; default = false; }

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

                ret = new GLib.Variant.array (field_type.to_variant_type (), childs);
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

    // methods
    public Field (string inName, bool inRepeated, string? inDefault) throws ProtocolError
    {
        GLib.Object (id: GLib.Quark.from_string (inName), repeated: inRepeated);

        if (!repeated)
        {
            m_Values += create_value ();
        }

        set_default (inDefault);
    }

    public abstract BufferChild copy () throws ProtocolError;

    protected virtual GLib.Value
    create_value ()
    {
        return GLib.Value (field_type.to_gtype ());
    }

    protected virtual void
    set_default (string? inDefault)
    {
        if (!repeated && m_Values.length > 1)
        {
            if (field_type != Type.STRING)
            {
                GLib.Value default_value = inDefault;
                if (!default_value.transform (ref m_Values[0]))
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MAIN_EVENT, @"Invalid default value $inDefault for $name");
                }
            }
            else
            {
                m_Values[0] = inDefault;
            }
        }
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
        requires (inValue.holds (field_type.to_gtype ()))
    {
        inValue.copy (ref m_Values[inIndex]);
    }

    public abstract GLib.Variant get_variant (int inIndex);
    public abstract void set_variant (int inIndex, GLib.Variant inVariant);
}

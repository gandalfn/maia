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

public class Maia.Protocol.Field : Core.Object, BufferChild
{
    // types
    public enum Rule
    {
        INVALID,
        REQUIRED,
        REPEATED;

        internal static Rule
        from_string (string inVal)
        {
            switch (inVal.down ())
            {
                case "":
                    return REQUIRED;

                case "repeated":
                    return REPEATED;
            }

            return INVALID;
        }
    }

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

    // properties
    private Message?   m_Message;
    private GLib.Value m_Value;

    // accessors
    public Rule rule { get; construct; default = Rule.INVALID; }

    public Type field_type { get; construct; default = Type.MESSAGE; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    // static methods
    static construct
    {
        GLib.Value.register_transform_func (typeof (string), typeof (bool),   string_to_bool);
        GLib.Value.register_transform_func (typeof (string), typeof (uchar),  string_to_uchar);
        GLib.Value.register_transform_func (typeof (string), typeof (uint16), string_to_uint16);
        GLib.Value.register_transform_func (typeof (string), typeof (int16),  string_to_int16);
        GLib.Value.register_transform_func (typeof (string), typeof (uint32), string_to_uint32);
        GLib.Value.register_transform_func (typeof (string), typeof (int32),  string_to_int32);
        GLib.Value.register_transform_func (typeof (string), typeof (uint64), string_to_uint64);
        GLib.Value.register_transform_func (typeof (string), typeof (int64),  string_to_int64);
        GLib.Value.register_transform_func (typeof (string), typeof (double), string_to_double);
    }

    private static void
    string_to_bool (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = bool.parse (val);
    }

    private static void
    string_to_uchar (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = val.to_utf8()[0];
    }

    private static void
    string_to_uint16 (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = (uint)int.parse (val);
    }

    private static void
    string_to_int16 (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = (int)int.parse (val);
    }

    private static void
    string_to_uint32 (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = (uint32)int.parse (val);
    }

    private static void
    string_to_int32 (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = (int32)int.parse (val);
    }

    private static void
    string_to_uint64 (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = uint64.parse (val);
    }

    private static void
    string_to_int64 (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = int64.parse (val);
    }

    private static void
    string_to_double (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (string)))
    {
        string val = (string)inSrc;

        outDest = double.parse (val);
    }

    // methods
    public Field (Rule inRule, Type inType, string inName, string? inDefault, Message? inMessage = null) throws ProtocolError
    {
        GLib.Object (id: GLib.Quark.from_string (inName), rule: inRule, field_type: inType);

        m_Message = inMessage;
        if (rule != Rule.REPEATED)
        {
            m_Value = GLib.Value (field_type.to_gtype ());
            if (inType == Type.MESSAGE)
            {
                if (m_Message == null)
                {
                    throw new ProtocolError.MISSING_MESSAGE (@"Missing message for $inName");
                }

                m_Value = m_Message.copy ();
            }

            if (inDefault != null)
            {
                if (field_type != Type.STRING)
                {
                    GLib.Value default_value = inDefault;
                    if (!default_value.transform (ref m_Value))
                    {
                        throw new ProtocolError.INVALID_DEFAULT_VALUE (@"Invalid default value $inDefault for $inName");
                    }
                }
                else
                {
                    m_Value = inDefault;
                }
            }
        }
        else
        {
            m_Value = GLib.Value (typeof (Core.Array));
            if (inType == Type.MESSAGE)
            {
                if (m_Message == null)
                {
                    throw new ProtocolError.MISSING_MESSAGE (@"Missing message for $inName");
                }
            }

            switch (field_type)
            {
                case Type.BOOLEAN:
                    m_Value = new Core.Array<bool> ();
                    break;

                case Type.BYTE:
                    m_Value = new Core.Array<uchar> ();
                    break;

                case Type.UINT16:
                    m_Value = new Core.Array<uint> ();
                    break;

                case Type.INT16:
                    m_Value = new Core.Array<int> ();
                    break;

                case Type.UINT32:
                    m_Value = new Core.Array<uint32> ();
                    break;

                case Type.INT32:
                    m_Value = new Core.Array<int32> ();
                    break;

                case Type.UINT64:
                    m_Value = new Core.Array<uint64?> ();
                    break;

                case Type.INT64:
                    m_Value = new Core.Array<int64?> ();
                    break;

                case Type.DOUBLE:
                    m_Value = new Core.Array<double?> ();
                    break;

                case Type.STRING:
                    m_Value = new Core.Array<string> ();
                    break;

                case Type.MESSAGE:
                    m_Value = new Core.Array<Message> ();
                    break;
            }
        }
    }

    public Field
    copy ()
    {
        Field field = GLib.Object.new (typeof (Field), id: GLib.Quark.from_string (name), rule: rule, field_type: field_type) as Field;
        if (rule != Rule.REPEATED)
        {
            field.m_Value = GLib.Value (field_type.to_gtype ());
        }
        else
        {
            field.m_Value = GLib.Value (typeof (Core.Array));
        }
        field.m_Message = m_Message;
        m_Value.copy (ref field.m_Value);
        return field;
    }

    internal override string
    to_string ()
    {
        string ret = "";

        switch (rule)
        {
            case Rule.REPEATED:
                ret += "a";
                break;
        }

        switch (field_type)
        {
            case Type.BOOLEAN:
                ret += "b";
                break;

            case Type.BYTE:
                ret += "y";
                break;

            case Type.UINT16:
                ret += "q";
                break;

            case Type.INT16:
                ret += "n";
                break;

            case Type.UINT32:
                ret += "u";
                break;

            case Type.INT32:
                ret += "i";
                break;

            case Type.UINT64:
                ret += "t";
                break;

            case Type.INT64:
                ret += "x";
                break;

            case Type.DOUBLE:
                ret += "d";
                break;

            case Type.STRING:
                ret += "s";
                break;

            case Type.MESSAGE:
                unowned Message? msg = (Message?)m_Value;
                ret += @"$msg";
                break;
        }

        return ret;
    }

    internal void
    set_variant (GLib.Variant inVariant)
    {
        if (rule != Rule.REPEATED)
        {
            GLib.return_if_fail (!inVariant.get_type ().is_array ());

            switch (field_type)
            {
                case Type.BOOLEAN:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_boolean ();
                    break;

                case Type.BYTE:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_byte ();
                    break;

                case Type.UINT16:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = (uint)inVariant.get_uint16 ();
                    break;

                case Type.INT16:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = (int)inVariant.get_int16 ();
                    break;

                case Type.UINT32:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_uint32 ();
                    break;

                case Type.INT32:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_int32 ();
                    break;

                case Type.UINT64:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_uint64 ();
                    break;

                case Type.INT64:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_int64 ();
                    break;

                case Type.DOUBLE:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_double ();
                    break;

                case Type.STRING:
                    GLib.return_if_fail (inVariant.get_type ().equal (field_type.to_variant_type ()));
                    m_Value = inVariant.get_string ();
                    break;

                case Type.MESSAGE:
                    GLib.return_if_fail (inVariant.get_type ().is_tuple ());
                    unowned Message? msg = (Message?)m_Value;
                    if (msg != null)
                    {
                        msg.set_variant (inVariant);
                    }
                    break;
            }
        }
        else
        {
            GLib.return_if_fail (inVariant.get_type ().is_array ());

            if (field_type != Type.MESSAGE)
                GLib.return_if_fail (inVariant.get_type ().element ().equal (field_type.to_variant_type ()));
            else
                GLib.return_if_fail (inVariant.get_type ().element ().is_tuple ());

            ((Core.Array)m_Value).clear ();
            for (int cpt = 0; cpt < inVariant.n_children (); ++cpt)
            {
                var variant = inVariant.get_child_value (cpt);

                switch (field_type)
                {
                    case Type.BOOLEAN:
                        Core.Array<bool> val = (Core.Array<bool>)m_Value;
                        val.insert (variant.get_boolean ());
                        break;

                    case Type.BYTE:
                        Core.Array<uchar> val = (Core.Array<uchar>)m_Value;
                        val.insert (variant.get_byte ());
                        break;

                    case Type.UINT16:
                        Core.Array<uint> val = (Core.Array<uint>)m_Value;
                        val.insert ((uint)variant.get_uint16 ());
                        break;

                    case Type.INT16:
                        Core.Array<int> val = (Core.Array<int>)m_Value;
                        val.insert ((int)variant.get_int16 ());
                        break;

                    case Type.UINT32:
                        Core.Array<uint32> val = (Core.Array<uint32>)m_Value;
                        val.insert (variant.get_uint32 ());
                        break;

                    case Type.INT32:
                        Core.Array<int32> val = (Core.Array<int32>)m_Value;
                        val.insert (variant.get_int32 ());
                        break;

                    case Type.UINT64:
                        Core.Array<uint64?> val = (Core.Array<uint64?>)m_Value;
                        val.insert (variant.get_uint64 ());
                        break;

                    case Type.INT64:
                        Core.Array<int64?> val = (Core.Array<int64?>)m_Value;
                        val.insert (variant.get_int64 ());
                        break;

                    case Type.DOUBLE:
                        Core.Array<double?> val = (Core.Array<double?>)m_Value;
                        val.insert (variant.get_double ());
                        break;

                    case Type.STRING:
                        Core.Array<string> val = (Core.Array<string>)m_Value;
                        val.insert (variant.get_string ());
                        break;

                    case Type.MESSAGE:
                        Core.Array<Message> val = (Core.Array<Message>)m_Value;
                        Message msg = m_Message.copy ();
                        msg.set_variant (variant);
                        val.insert (msg);
                        break;
                }
            }
        }
    }

    internal GLib.Variant?
    to_variant ()
    {
        if (rule != Rule.REPEATED)
        {
            switch (field_type)
            {
                case Type.BOOLEAN:
                    return new GLib.Variant.boolean ((bool)m_Value);

                case Type.BYTE:
                    return new GLib.Variant.byte ((uchar)m_Value);

                case Type.UINT16:
                    return new GLib.Variant.uint16 ((uint16)(int)m_Value);

                case Type.INT16:
                    return new GLib.Variant.int16 ((int16)(int)m_Value);

                case Type.UINT32:
                    return new GLib.Variant.uint32 ((uint32)m_Value);

                case Type.INT32:
                    return new GLib.Variant.int32 ((int32)m_Value);

                case Type.UINT64:
                    return new GLib.Variant.uint64 ((uint64)m_Value);

                case Type.INT64:
                    return new GLib.Variant.int64 ((int64)m_Value);

                case Type.DOUBLE:
                    return new GLib.Variant.double ((double)m_Value);

                case Type.STRING:
                    return new GLib.Variant.string ((string)m_Value);

                case Type.MESSAGE:
                    unowned Message? msg = (Message?)m_Value;
                    if (msg != null)
                    {
                        return msg.to_variant ();
                    }
                    break;
            }
        }
        else
        {
            GLib.Variant[] childs = {};

            switch (field_type)
            {
                case Type.BOOLEAN:
                    foreach (bool val in (Core.Array<bool>)m_Value)
                    {
                        childs += new GLib.Variant.boolean (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.BYTE:
                    foreach (uchar val in (Core.Array<uchar>)m_Value)
                    {
                        childs += new GLib.Variant.byte (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.UINT16:
                    foreach (uint val in (Core.Array<uint>)m_Value)
                    {
                        childs += new GLib.Variant.uint16 ((uint16)val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.INT16:
                    foreach (int val in (Core.Array<int>)m_Value)
                    {
                        childs += new GLib.Variant.int16 ((int16)val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.UINT32:
                    foreach (uint32 val in (Core.Array<uint32>)m_Value)
                    {
                        childs += new GLib.Variant.uint32 (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.INT32:
                    foreach (int32 val in (Core.Array<int32>)m_Value)
                    {
                        childs += new GLib.Variant.int32 (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.UINT64:
                    foreach (uint64? val in (Core.Array<uint64?>)m_Value)
                    {
                        childs += new GLib.Variant.uint64 (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.INT64:
                    foreach (int64? val in (Core.Array<int64?>)m_Value)
                    {
                        childs += new GLib.Variant.int64 (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.DOUBLE:
                    foreach (double? val in (Core.Array<double?>)m_Value)
                    {
                        childs += new GLib.Variant.double (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.STRING:
                    foreach (unowned string val in (Core.Array<string>)m_Value)
                    {
                        childs += new GLib.Variant.string (val);
                    }
                    return new GLib.Variant.array (field_type.to_variant_type (), childs);

                case Type.MESSAGE:
                    foreach (unowned Message msg in (Core.Array<Message>)m_Value)
                    {
                        childs += msg.to_variant ();
                    }
                    return new GLib.Variant.array (GLib.VariantType.TUPLE, childs);
            }
        }

        return null;
    }

    public new GLib.Value
    @get ()
    {
        GLib.Value ret;
        if (rule != Rule.REPEATED)
        {
            ret = GLib.Value (field_type.to_gtype ());
        }
        else
        {
            ret = GLib.Value (typeof (Core.Array));
        }
        m_Value.copy (ref ret);
        return ret;
    }

    public new void
    @set (GLib.Value inValue)
    {
        if (rule != Rule.REPEATED)
        {
            GLib.return_if_fail (inValue.holds (field_type.to_gtype ()));
        }
        else
        {
            GLib.return_if_fail (inValue.holds (typeof (Core.Array)));
            {
                GLib.return_if_fail (((Core.Array)m_Value).item_type == field_type.to_gtype ());
            }
        }

        inValue.copy (ref m_Value);
    }
}

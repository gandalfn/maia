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
        OPTIONAL,
        REPEATED;

        internal static Rule
        from_string (string inVal)
        {
            switch (inVal.down ())
            {
                case "required":
                    return REQUIRED;

                case "optional":
                    return OPTIONAL;

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
                    return typeof (uint16);

                case INT16:
                    return typeof (int16);

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
    private GLib.Value m_Value;
    private string? m_DefaultValue = null;

    // accessors
    public Rule rule { get; construct; default = Rule.INVALID; }

    public Type field_type { get; construct; default = Type.MESSAGE; }

    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public string? default_value {
        get {
            return m_DefaultValue;
        }
    }

    // methods
    public Field (Rule inRule, Type inType, string inName, string? inDefault)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), rule: inRule, field_type: inType);
        m_DefaultValue = inDefault;
        m_Value = GLib.Value (field_type.to_gtype ());
    }

    internal override string
    to_string ()
    {
        string ret = "";

        switch (rule)
        {
            case Rule.OPTIONAL:
                ret += "m";
                break;

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

    public new GLib.Value
    @get ()
    {
        return m_Value;
    }

    public new void
    @set (GLib.Value inValue)
        requires (inValue.holds (field_type.to_gtype ()))
    {
        m_Value = inValue;
    }
}

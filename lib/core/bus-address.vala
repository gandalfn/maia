/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * bus-address.vala
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

public class Maia.Core.BusAddress : Object
{
    // types
    public enum Type
    {
        INVALID,
        UNIX,
        SOCKET;

        public string
        to_string ()
        {
            switch (this)
            {
                case UNIX:
                    return "unix";

                case SOCKET:
                    return "socket";
            }

            return "";
        }

        public static Type
        from_uri (string inUri)
        {
            switch (GLib.Uri.parse_scheme (inUri))
            {
                case "unix":
                    return UNIX;

                case "socket":
                    return SOCKET;
            }

            return INVALID;
        }
    }

    // accessors
    /**
     * Address type
     */
    public Type address_type { get; construct; default = Type.INVALID; }

    /**
     * Address hier
     */
    public string hier { get; set; default = ""; }

    /**
     * Address port
     */
    public uint port { get; set; default = 0; }

    // static methods
    private static string uuid_generate ()
    {
        var uuid_str = new char[37];
        var uuid = new uint8[16];

        UUID.generate (uuid);
        UUID.unparse (uuid, uuid_str);

        return (string)uuid_str;
    }

    // methods
    /**
     * Create a new bus address
     *
     * @param inUri bus address uri
     */
    public BusAddress (string inUri)
    {
        Type address_type = Type.from_uri (inUri);
        GLib.Object (address_type: address_type);

        switch (address_type)
        {
            case Type.UNIX:
                hier = @"$(uuid_generate ())";
                break;

            case Type.SOCKET:
                string hier_part = inUri.substring ("socket://".length);
                string[] split = hier_part.split(":");
                if (split.length > 0) hier = split[0];
                if (split.length > 1) port = int.parse (split[1]);
                break;
        }
    }

    internal override string
    to_string ()
    {
        string ret = @"$(address_type)://$(hier)";
        if (port > 0)
        {
            ret += @":$(port)";
        }
        return ret;
    }
}

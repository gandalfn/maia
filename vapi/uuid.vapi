/* -*- Mode: C; indent-tabs-mode: null; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * uuid.vapi
 * Copyright (C) Nicolas Bruguier 2009 <gandalfn@club-internet.fr>
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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "uuid.h")]
namespace libuuid
{
    [SimpleType, CCode (cname = "uuid_t")]
    public struct UUID
    {
        [CCode (cname = "uuid_generate")]
        public void generate ();

        [CCode (cname = "uuid_parse", instance_pos = -1)]
        public void parse (string inStr);

        [CCode (cname = "uuid_compare")]
        public int compare (UUID inOther);

        [CCode (cname = "uuid_is_null")]
        public bool is_null ();

        [CCode (cname = "uuid_unparse")]
        private void unparse ([CCode (array_length = "false")]uchar[] outStr);
        public string
        to_string ()
        {
            uchar[] str = new uchar[37];

            unparse (str);

            return (string)str;
        }
    }
}

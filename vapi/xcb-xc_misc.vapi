/*
 * Copyright (C) 2012  Nicolas Bruguier
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Nicolas Bruguier <gandalfn@club-internet.fr>
 */

using Xcb;

[CCode (cheader_filename="xcb/xcb.h,xcb/xc_misc.h")]
namespace Xcb.XCMisc
{
	[CCode (cname = "xcb_xc_misc_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xc_misc_get_version")]
		public GetVersionCookie get_version (uint16 client_major_version, uint16 client_minor_version);
		[CCode (cname = "xcb_xc_misc_get_xid_range")]
		public GetXidrangeCookie get_xid_range ();
		[CCode (cname = "xcb_xc_misc_get_xid_list")]
		public GetXidlistCookie get_xid_list (uint32 count);
	}

	[Compact, CCode (cname = "xcb_xc_misc_get_version_reply_t", free_function = "free")]
	public class GetVersionReply {
		public uint16 server_major_version;
		public uint16 server_minor_version;
	}

	[SimpleType, CCode (cname = "xcb_xc_misc_get_version_cookie_t")]
	public struct GetVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xc_misc_get_version_reply", instance_pos = 1.1)]
		public GetVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xc_misc_get_xid_range_reply_t", free_function = "free")]
	public class GetXidrangeReply {
		public uint32 start_id;
		public uint32 count;
	}

	[SimpleType, CCode (cname = "xcb_xc_misc_get_xid_range_cookie_t")]
	public struct GetXidrangeCookie : VoidCookie {
		[CCode (cname = "xcb_xc_misc_get_xid_range_reply", instance_pos = 1.1)]
		public GetXidrangeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xc_misc_get_xid_list_reply_t", free_function = "free")]
	public class GetXidlistReply {
		public uint32 ids_len;
		public int ids_length {
			[CCode (cname = "xcb_xc_misc_get_xid_list_ids_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] ids {
			[CCode (cname = "xcb_xc_misc_get_xid_list_ids")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xc_misc_get_xid_list_cookie_t")]
	public struct GetXidlistCookie : VoidCookie {
		[CCode (cname = "xcb_xc_misc_get_xid_list_reply", instance_pos = 1.1)]
		public GetXidlistReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}
}

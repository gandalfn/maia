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

[CCode (cheader_filename="xcb/xcb.h,xcb/bigreq.h")]
namespace Xcb.BigRequests
{
	[CCode (cname = "xcb_big_requests_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_big_requests_enable")]
		public EnableCookie enable ();
	}

	[Compact, CCode (cname = "xcb_big_requests_enable_reply_t", free_function = "free")]
	public class EnableReply {
		public uint32 maximum_request_length;
	}

	[SimpleType, CCode (cname = "xcb_big_requests_enable_cookie_t")]
	public struct EnableCookie : VoidCookie {
		[CCode (cname = "xcb_big_requests_enable_reply", instance_pos = 1.1)]
		public EnableReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}
}

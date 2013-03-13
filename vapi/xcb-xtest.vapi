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

[CCode (cheader_filename="xcb/xcb.h,xcb/xtest.h")]
namespace Xcb.Test
{
	[CCode (cname = "xcb_test_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_test_get_version")]
		public GetVersionCookie get_version (uint8 major_version, uint16 minor_version);
		[CCode (cname = "xcb_test_grab_control")]
		public VoidCookie grab_control (bool impervious);
		[CCode (cname = "xcb_test_grab_control_checked")]
		public VoidCookie grab_control_checked (bool impervious);
	}

	[Compact, CCode (cname = "xcb_test_get_version_reply_t", free_function = "free")]
	public class GetVersionReply {
		public uint8 major_version;
		public uint16 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_test_get_version_cookie_t")]
	public struct GetVersionCookie : VoidCookie {
		[CCode (cname = "xcb_test_get_version_reply", instance_pos = 1.1)]
		public GetVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_test_compare_cursor", instance_pos = 1.1)]
		public CompareCursorCookie compare_cursor (Xcb.Connection connection, Cursor cursor);
		[CCode (cname = "xcb_test_fake_input", instance_pos = 4.4)]
		public VoidCookie fake_input (Xcb.Connection connection, uint8 type, uint8 detail, uint32 time, int16 rootX, int16 rootY, uint8 deviceid);
		[CCode (cname = "xcb_test_fake_input_checked", instance_pos = 4.4)]
		public VoidCookie fake_input_checked (Xcb.Connection connection, uint8 type, uint8 detail, uint32 time, int16 rootX, int16 rootY, uint8 deviceid);
	}

	[Compact, CCode (cname = "xcb_test_compare_cursor_reply_t", free_function = "free")]
	public class CompareCursorReply {
		public bool same;
	}

	[SimpleType, CCode (cname = "xcb_test_compare_cursor_cookie_t")]
	public struct CompareCursorCookie : VoidCookie {
		[CCode (cname = "xcb_test_compare_cursor_reply", instance_pos = 1.1)]
		public CompareCursorReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_test_cursor_t", cprefix =  "XCB_TEST_CURSOR_", has_type_id = false)]
	public enum Cursor {
		NONE,
		CURRENT
	}
}

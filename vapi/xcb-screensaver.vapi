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

[CCode (cheader_filename="xcb/xcb.h,xcb/screensaver.h")]
namespace Xcb.ScreenSaver
{
	[CCode (cname = "xcb_screensaver_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_screensaver_query_version")]
		public QueryVersionCookie query_version (uint8 client_major_version, uint8 client_minor_version);
		[CCode (cname = "xcb_screensaver_suspend")]
		public VoidCookie suspend (bool suspend);
		[CCode (cname = "xcb_screensaver_suspend_checked")]
		public VoidCookie suspend_checked (bool suspend);
	}

	[Compact, CCode (cname = "xcb_screensaver_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 server_major_version;
		public uint16 server_minor_version;
	}

	[SimpleType, CCode (cname = "xcb_screensaver_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_screensaver_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		[CCode (cname = "xcb_screensaver_query_info", instance_pos = 1.1)]
		public QueryInfoCookie query_info (Xcb.Connection connection);
		[CCode (cname = "xcb_screensaver_select_input", instance_pos = 1.1)]
		public VoidCookie select_input (Xcb.Connection connection, uint32 event_mask);
		[CCode (cname = "xcb_screensaver_select_input_checked", instance_pos = 1.1)]
		public VoidCookie select_input_checked (Xcb.Connection connection, uint32 event_mask);
		[CCode (cname = "xcb_screensaver_set_attributes", instance_pos = 1.1)]
		public VoidCookie set_attributes (Xcb.Connection connection, int16 x, int16 y, uint16 width, uint16 height, uint16 border_width, uint8 class, uint8 depth, Visualid visual, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_screensaver_set_attributes_checked", instance_pos = 1.1)]
		public VoidCookie set_attributes_checked (Xcb.Connection connection, int16 x, int16 y, uint16 width, uint16 height, uint16 border_width, uint8 class, uint8 depth, Visualid visual, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_screensaver_unset_attributes", instance_pos = 1.1)]
		public VoidCookie unset_attributes (Xcb.Connection connection);
		[CCode (cname = "xcb_screensaver_unset_attributes_checked", instance_pos = 1.1)]
		public VoidCookie unset_attributes_checked (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_screensaver_query_info_reply_t", free_function = "free")]
	public class QueryInfoReply {
		public uint8 state;
		public Window saver_window;
		public uint32 ms_until_server;
		public uint32 ms_since_user_input;
		public uint32 event_mask;
		public uint8 kind;
	}

	[SimpleType, CCode (cname = "xcb_screensaver_query_info_cookie_t")]
	public struct QueryInfoCookie : VoidCookie {
		[CCode (cname = "xcb_screensaver_query_info_reply", instance_pos = 1.1)]
		public QueryInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_screensaver_kind_t", cprefix =  "XCB_SCREENSAVER_KIND_", has_type_id = false)]
	public enum Kind {
		BLANKED,
		INTERNAL,
		EXTERNAL
	}

	[CCode (cname = "xcb_screensaver_event_t", cprefix =  "XCB_SCREENSAVER_EVENT_", has_type_id = false)]
	public enum Event {
		NOTIFY_MASK,
		CYCLE_MASK
	}

	[CCode (cname = "xcb_screensaver_state_t", cprefix =  "XCB_SCREENSAVER_STATE_", has_type_id = false)]
	public enum State {
		OFF,
		ON,
		CYCLE,
		DISABLED
	}

	[Compact, CCode (cname = "xcb_screensaver_notify_event_t", has_type_id = false)]
	public class NotifyEvent : GenericEvent {
		public uint8 state;
		public Timestamp time;
		public Window root;
		public Window window;
		public uint8 kind;
		public bool forced;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_SCREENSAVER_", has_type_id = false)]
	public enum EventType {
		NOTIFY
	}
}

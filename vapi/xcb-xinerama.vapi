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

[CCode (cheader_filename="xcb/xcb.h,xcb/xinerama.h")]
namespace Xcb.Xinerama
{
	[CCode (cname = "xcb_xinerama_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xinerama_query_version")]
		public QueryVersionCookie query_version (uint8 major, uint8 minor);
		[CCode (cname = "xcb_xinerama_is_active")]
		public IsActiveCookie is_active ();
		[CCode (cname = "xcb_xinerama_query_screens")]
		public QueryScreensCookie query_screens ();
	}

	[Compact, CCode (cname = "xcb_xinerama_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 major;
		public uint16 minor;
	}

	[SimpleType, CCode (cname = "xcb_xinerama_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xinerama_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xinerama_is_active_reply_t", free_function = "free")]
	public class IsActiveReply {
		public uint32 state;
	}

	[SimpleType, CCode (cname = "xcb_xinerama_is_active_cookie_t")]
	public struct IsActiveCookie : VoidCookie {
		[CCode (cname = "xcb_xinerama_is_active_reply", instance_pos = 1.1)]
		public IsActiveReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xinerama_query_screens_reply_t", free_function = "free")]
	public class QueryScreensReply {
		public uint32 number;
		[CCode (cname = "xcb_xinerama_query_screens_screen_info_iterator")]
		_ScreenInfoIterator _iterator ();
		public ScreenInfoIterator iterator () {
			return (ScreenInfoIterator) _iterator ();
		}
		public int screen_info_length {
			[CCode (cname = "xcb_xinerama_query_screens_screen_info_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ScreenInfo[] screen_info {
			[CCode (cname = "xcb_xinerama_query_screens_screen_info")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xinerama_query_screens_cookie_t")]
	public struct QueryScreensCookie : VoidCookie {
		[CCode (cname = "xcb_xinerama_query_screens_reply", instance_pos = 1.1)]
		public QueryScreensReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_xinerama_get_state", instance_pos = 1.1)]
		public GetStateCookie get_state (Xcb.Connection connection);
		[CCode (cname = "xcb_xinerama_get_screen_count", instance_pos = 1.1)]
		public GetScreenCountCookie get_screen_count (Xcb.Connection connection);
		[CCode (cname = "xcb_xinerama_get_screen_size", instance_pos = 1.1)]
		public GetScreenSizeCookie get_screen_size (Xcb.Connection connection, uint32 screen);
	}

	[Compact, CCode (cname = "xcb_xinerama_get_state_reply_t", free_function = "free")]
	public class GetStateReply {
		public uint8 state;
		public Window window;
	}

	[SimpleType, CCode (cname = "xcb_xinerama_get_state_cookie_t")]
	public struct GetStateCookie : VoidCookie {
		[CCode (cname = "xcb_xinerama_get_state_reply", instance_pos = 1.1)]
		public GetStateReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xinerama_get_screen_count_reply_t", free_function = "free")]
	public class GetScreenCountReply {
		public uint8 screen_count;
		public Window window;
	}

	[SimpleType, CCode (cname = "xcb_xinerama_get_screen_count_cookie_t")]
	public struct GetScreenCountCookie : VoidCookie {
		[CCode (cname = "xcb_xinerama_get_screen_count_reply", instance_pos = 1.1)]
		public GetScreenCountReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xinerama_get_screen_size_reply_t", free_function = "free")]
	public class GetScreenSizeReply {
		public uint32 width;
		public uint32 height;
		public Window window;
		public uint32 screen;
	}

	[SimpleType, CCode (cname = "xcb_xinerama_get_screen_size_cookie_t")]
	public struct GetScreenSizeCookie : VoidCookie {
		[CCode (cname = "xcb_xinerama_get_screen_size_reply", instance_pos = 1.1)]
		public GetScreenSizeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xinerama_screen_info_iterator_t")]
	struct _ScreenInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned ScreenInfo? data;
	}

	[CCode (cname = "xcb_xinerama_screen_info_iterator_t")]
	public struct ScreenInfoIterator
	{
		[CCode (cname = "xcb_xinerama_screen_info_next")]
		internal void _next ();

		public inline unowned ScreenInfo?
		next_value ()
		{
			if (((_ScreenInfoIterator)this).rem > 0)
			{
				unowned ScreenInfo? d = ((_ScreenInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xinerama_screen_info_t", has_type_id = false)]
	public struct ScreenInfo {
		public int16 x_org;
		public int16 y_org;
		public uint16 width;
		public uint16 height;
	}
}

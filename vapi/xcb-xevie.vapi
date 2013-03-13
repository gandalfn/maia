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

[CCode (cheader_filename="xcb/xcb.h,xcb/xevie.h")]
namespace Xcb.Xevie
{
	[CCode (cname = "xcb_xevie_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xevie_query_version")]
		public QueryVersionCookie query_version (uint16 client_major_version, uint16 client_minor_version);
		[CCode (cname = "xcb_xevie_start")]
		public StartCookie start (uint32 screen);
		[CCode (cname = "xcb_xevie_end")]
		public EndCookie end (uint32 cmap);
		[CCode (cname = "xcb_xevie_send")]
		public SendCookie send (Event event, uint32 data_type);
		[CCode (cname = "xcb_xevie_select_input")]
		public SelectInputCookie select_input (uint32 event_mask);
	}

	[Compact, CCode (cname = "xcb_xevie_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 server_major_version;
		public uint16 server_minor_version;
	}

	[SimpleType, CCode (cname = "xcb_xevie_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xevie_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xevie_start_reply_t", free_function = "free")]
	public class StartReply {
	}

	[SimpleType, CCode (cname = "xcb_xevie_start_cookie_t")]
	public struct StartCookie : VoidCookie {
		[CCode (cname = "xcb_xevie_start_reply", instance_pos = 1.1)]
		public StartReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xevie_end_reply_t", free_function = "free")]
	public class EndReply {
	}

	[SimpleType, CCode (cname = "xcb_xevie_end_cookie_t")]
	public struct EndCookie : VoidCookie {
		[CCode (cname = "xcb_xevie_end_reply", instance_pos = 1.1)]
		public EndReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xevie_send_reply_t", free_function = "free")]
	public class SendReply {
	}

	[SimpleType, CCode (cname = "xcb_xevie_send_cookie_t")]
	public struct SendCookie : VoidCookie {
		[CCode (cname = "xcb_xevie_send_reply", instance_pos = 1.1)]
		public SendReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xevie_select_input_reply_t", free_function = "free")]
	public class SelectInputReply {
	}

	[SimpleType, CCode (cname = "xcb_xevie_select_input_cookie_t")]
	public struct SelectInputCookie : VoidCookie {
		[CCode (cname = "xcb_xevie_select_input_reply", instance_pos = 1.1)]
		public SelectInputReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_xevie_datatype_t", cprefix =  "XCB_XEVIE_DATATYPE_", has_type_id = false)]
	public enum Datatype {
		UNMODIFIED,
		MODIFIED
	}

	[SimpleType, CCode (cname = "xcb_xevie_event_iterator_t")]
	struct _EventIterator
	{
		internal int rem;
		internal int index;
		internal unowned Event? data;
	}

	[CCode (cname = "xcb_xevie_event_iterator_t")]
	public struct EventIterator
	{
		[CCode (cname = "xcb_xevie_event_next")]
		internal void _next ();

		public inline unowned Event?
		next_value ()
		{
			if (((_EventIterator)this).rem > 0)
			{
				unowned Event? d = ((_EventIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xevie_event_t", has_type_id = false)]
	public struct Event {
	}
}

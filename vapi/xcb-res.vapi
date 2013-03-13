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

[CCode (cheader_filename="xcb/xcb.h,xcb/res.h")]
namespace Xcb.Res
{
	[CCode (cname = "xcb_res_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_res_query_version")]
		public QueryVersionCookie query_version (uint8 client_major, uint8 client_minor);
		[CCode (cname = "xcb_res_query_clients")]
		public QueryClientsCookie query_clients ();
		[CCode (cname = "xcb_res_query_client_resources")]
		public QueryClientResourcesCookie query_client_resources (uint32 xid);
		[CCode (cname = "xcb_res_query_client_pixmap_bytes")]
		public QueryClientPixmapBytesCookie query_client_pixmap_bytes (uint32 xid);
	}

	[Compact, CCode (cname = "xcb_res_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 server_major;
		public uint16 server_minor;
	}

	[SimpleType, CCode (cname = "xcb_res_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_res_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_res_query_clients_reply_t", free_function = "free")]
	public class QueryClientsReply {
		public uint32 num_clients;
		[CCode (cname = "xcb_res_query_clients_clients_iterator")]
		_ClientIterator _iterator ();
		public ClientIterator iterator () {
			return (ClientIterator) _iterator ();
		}
		public int clients_length {
			[CCode (cname = "xcb_res_query_clients_clients_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Client[] clients {
			[CCode (cname = "xcb_res_query_clients_clients")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_res_query_clients_cookie_t")]
	public struct QueryClientsCookie : VoidCookie {
		[CCode (cname = "xcb_res_query_clients_reply", instance_pos = 1.1)]
		public QueryClientsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_res_query_client_resources_reply_t", free_function = "free")]
	public class QueryClientResourcesReply {
		public uint32 num_types;
		[CCode (cname = "xcb_res_query_client_resources_types_iterator")]
		_TypeIterator _iterator ();
		public TypeIterator iterator () {
			return (TypeIterator) _iterator ();
		}
		public int types_length {
			[CCode (cname = "xcb_res_query_client_resources_types_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Type[] types {
			[CCode (cname = "xcb_res_query_client_resources_types")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_res_query_client_resources_cookie_t")]
	public struct QueryClientResourcesCookie : VoidCookie {
		[CCode (cname = "xcb_res_query_client_resources_reply", instance_pos = 1.1)]
		public QueryClientResourcesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_res_query_client_pixmap_bytes_reply_t", free_function = "free")]
	public class QueryClientPixmapBytesReply {
		public uint32 bytes;
		public uint32 bytes_overflow;
	}

	[SimpleType, CCode (cname = "xcb_res_query_client_pixmap_bytes_cookie_t")]
	public struct QueryClientPixmapBytesCookie : VoidCookie {
		[CCode (cname = "xcb_res_query_client_pixmap_bytes_reply", instance_pos = 1.1)]
		public QueryClientPixmapBytesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_res_client_iterator_t")]
	struct _ClientIterator
	{
		internal int rem;
		internal int index;
		internal unowned Client? data;
	}

	[CCode (cname = "xcb_res_client_iterator_t")]
	public struct ClientIterator
	{
		[CCode (cname = "xcb_res_client_next")]
		internal void _next ();

		public inline unowned Client?
		next_value ()
		{
			if (((_ClientIterator)this).rem > 0)
			{
				unowned Client? d = ((_ClientIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_res_client_t", has_type_id = false)]
	public struct Client {
		public uint32 resource_base;
		public uint32 resource_mask;
	}

	[SimpleType, CCode (cname = "xcb_res_type_iterator_t")]
	struct _TypeIterator
	{
		internal int rem;
		internal int index;
		internal unowned Type? data;
	}

	[CCode (cname = "xcb_res_type_iterator_t")]
	public struct TypeIterator
	{
		[CCode (cname = "xcb_res_type_next")]
		internal void _next ();

		public inline unowned Type?
		next_value ()
		{
			if (((_TypeIterator)this).rem > 0)
			{
				unowned Type? d = ((_TypeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_res_type_t", has_type_id = false)]
	public struct Type {
		public Atom resource_type;
		public uint32 count;
	}
}

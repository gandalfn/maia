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

[CCode (cheader_filename="xcb/xcb.h,xcb/record.h")]
namespace Xcb.Record
{
	[CCode (cname = "xcb_record_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_record_query_version")]
		public QueryVersionCookie query_version (uint16 major_version, uint16 minor_version);
	}

	[Compact, CCode (cname = "xcb_record_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 major_version;
		public uint16 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_record_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_record_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_record_context_iterator_t")]
	struct _ContextIterator
	{
		internal int rem;
		internal int index;
		internal unowned Context? data;
	}

	[CCode (cname = "xcb_record_context_iterator_t")]
	public struct ContextIterator
	{
		[CCode (cname = "xcb_record_context_next")]
		internal void _next ();

		public inline unowned Context?
		next_value ()
		{
			if (((_ContextIterator)this).rem > 0)
			{
				unowned Context? d = ((_ContextIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_record_context_t", has_type_id = false)]
	public struct Context : uint32 {
		/**
		 * Allocates an XID for a new Context.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Context (Xcb.Connection connection);

		[CCode (cname = "xcb_record_create_context", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, ElementHeader element_header, [CCode (array_length_pos = 2.3)]ClientSpec[] client_specs, [CCode (array_length_pos = 3.4)]Range[] ranges);
		[CCode (cname = "xcb_record_create_context_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, ElementHeader element_header, [CCode (array_length_pos = 2.3)]ClientSpec[] client_specs, [CCode (array_length_pos = 3.4)]Range[] ranges);
		[CCode (cname = "xcb_record_register_clients", instance_pos = 1.1)]
		public VoidCookie register_clients (Xcb.Connection connection, ElementHeader element_header, [CCode (array_length_pos = 2.3)]ClientSpec[] client_specs, [CCode (array_length_pos = 3.4)]Range[] ranges);
		[CCode (cname = "xcb_record_register_clients_checked", instance_pos = 1.1)]
		public VoidCookie register_clients_checked (Xcb.Connection connection, ElementHeader element_header, [CCode (array_length_pos = 2.3)]ClientSpec[] client_specs, [CCode (array_length_pos = 3.4)]Range[] ranges);
		[CCode (cname = "xcb_record_unregister_clients", instance_pos = 1.1)]
		public VoidCookie unregister_clients (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]ClientSpec[] client_specs);
		[CCode (cname = "xcb_record_unregister_clients_checked", instance_pos = 1.1)]
		public VoidCookie unregister_clients_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]ClientSpec[] client_specs);
		[CCode (cname = "xcb_record_get_context", instance_pos = 1.1)]
		public GetContextCookie get (Xcb.Connection connection);
		[CCode (cname = "xcb_record_enable_context", instance_pos = 1.1)]
		public EnableContextCookie enable (Xcb.Connection connection);
		[CCode (cname = "xcb_record_disable_context", instance_pos = 1.1)]
		public VoidCookie disable (Xcb.Connection connection);
		[CCode (cname = "xcb_record_disable_context_checked", instance_pos = 1.1)]
		public VoidCookie disable_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_record_free_context", instance_pos = 1.1)]
		public VoidCookie free (Xcb.Connection connection);
		[CCode (cname = "xcb_record_free_context_checked", instance_pos = 1.1)]
		public VoidCookie free_checked (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_record_get_context_reply_t", free_function = "free")]
	public class GetContextReply {
		public bool enabled;
		public ElementHeader element_header;
		public uint32 num_intercepted_clients;
		[CCode (cname = "xcb_record_get_context_intercepted_clients_iterator")]
		_ClientInfoIterator _iterator ();
		public ClientInfoIterator iterator () {
			return (ClientInfoIterator) _iterator ();
		}
		public int intercepted_clients_length {
			[CCode (cname = "xcb_record_get_context_intercepted_clients_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ClientInfo[] intercepted_clients {
			[CCode (cname = "xcb_record_get_context_intercepted_clients")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_record_get_context_cookie_t")]
	public struct GetContextCookie : VoidCookie {
		[CCode (cname = "xcb_record_get_context_reply", instance_pos = 1.1)]
		public GetContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_record_enable_context_reply_t", free_function = "free")]
	public class EnableContextReply {
		public uint8 category;
		public ElementHeader element_header;
		public bool client_swapped;
		public uint32 xid_base;
		public uint32 server_time;
		public uint32 rec_sequence_num;
		public int data_length {
			[CCode (cname = "xcb_record_enable_context_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_record_enable_context_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_record_enable_context_cookie_t")]
	public struct EnableContextCookie : VoidCookie {
		[CCode (cname = "xcb_record_enable_context_reply", instance_pos = 1.1)]
		public EnableContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_record_range_8_iterator_t")]
	struct _Range8Iterator
	{
		internal int rem;
		internal int index;
		internal unowned Range8? data;
	}

	[CCode (cname = "xcb_record_range_8_iterator_t")]
	public struct Range8Iterator
	{
		[CCode (cname = "xcb_record_range_8_next")]
		internal void _next ();

		public inline unowned Range8?
		next_value ()
		{
			if (((_Range8Iterator)this).rem > 0)
			{
				unowned Range8? d = ((_Range8Iterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_record_range_8_t", has_type_id = false)]
	public struct Range8 {
		public uint8 first;
		public uint8 last;
	}

	[SimpleType, CCode (cname = "xcb_record_range_16_iterator_t")]
	struct _Range16Iterator
	{
		internal int rem;
		internal int index;
		internal unowned Range16? data;
	}

	[CCode (cname = "xcb_record_range_16_iterator_t")]
	public struct Range16Iterator
	{
		[CCode (cname = "xcb_record_range_16_next")]
		internal void _next ();

		public inline unowned Range16?
		next_value ()
		{
			if (((_Range16Iterator)this).rem > 0)
			{
				unowned Range16? d = ((_Range16Iterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_record_range_16_t", has_type_id = false)]
	public struct Range16 {
		public uint16 first;
		public uint16 last;
	}

	[SimpleType, CCode (cname = "xcb_record_ext_range_iterator_t")]
	struct _ExtRangeIterator
	{
		internal int rem;
		internal int index;
		internal unowned ExtRange? data;
	}

	[CCode (cname = "xcb_record_ext_range_iterator_t")]
	public struct ExtRangeIterator
	{
		[CCode (cname = "xcb_record_ext_range_next")]
		internal void _next ();

		public inline unowned ExtRange?
		next_value ()
		{
			if (((_ExtRangeIterator)this).rem > 0)
			{
				unowned ExtRange? d = ((_ExtRangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_record_ext_range_t", has_type_id = false)]
	public struct ExtRange {
		public Range8 major;
		public Range16 minor;
	}

	[SimpleType, CCode (cname = "xcb_record_range_iterator_t")]
	struct _RangeIterator
	{
		internal int rem;
		internal int index;
		internal unowned Range? data;
	}

	[CCode (cname = "xcb_record_range_iterator_t")]
	public struct RangeIterator
	{
		[CCode (cname = "xcb_record_range_next")]
		internal void _next ();

		public inline unowned Range?
		next_value ()
		{
			if (((_RangeIterator)this).rem > 0)
			{
				unowned Range? d = ((_RangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_record_range_t", has_type_id = false)]
	public struct Range {
		public Range8 core_requests;
		public Range8 core_replies;
		public ExtRange ext_requests;
		public ExtRange ext_replies;
		public Range8 delivered_events;
		public Range8 device_events;
		public Range8 errors;
		public bool client_started;
		public bool client_died;
	}

	[SimpleType, CCode (cname = "xcb_record_element_header_t", has_type_id = false)]
	public struct ElementHeader : uint8 {
	}

	[CCode (cname = "xcb_record_h_type_t", cprefix =  "XCB_RECORD_HTYPE_", has_type_id = false)]
	public enum Htype {
		FROM_SERVER_TIME,
		FROM_CLIENT_TIME,
		FROM_CLIENT_SEQUENCE
	}

	[SimpleType, CCode (cname = "xcb_record_client_spec_t", has_type_id = false)]
	public struct ClientSpec : uint32 {
	}

	[CCode (cname = "xcb_record_cs_t", cprefix =  "XCB_RECORD_CS_", has_type_id = false)]
	public enum Cs {
		CURRENT_CLIENTS,
		FUTURE_CLIENTS,
		ALL_CLIENTS
	}

	[SimpleType, CCode (cname = "xcb_record_client_info_iterator_t")]
	struct _ClientInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned ClientInfo? data;
	}

	[CCode (cname = "xcb_record_client_info_iterator_t")]
	public struct ClientInfoIterator
	{
		[CCode (cname = "xcb_record_client_info_next")]
		internal void _next ();

		public inline unowned ClientInfo?
		next_value ()
		{
			if (((_ClientInfoIterator)this).rem > 0)
			{
				unowned ClientInfo? d = ((_ClientInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_record_client_info_t", has_type_id = false)]
	public struct ClientInfo {
		public ClientSpec client_resource;
		public uint32 num_ranges;
		public int ranges_length {
			[CCode (cname = "xcb_record_client_info_ranges_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Range[] ranges {
			[CCode (cname = "xcb_record_client_info_ranges")]
			get;
		}
	}

	[Compact, CCode (cname = "xcb_record_bad_context_error_t", has_type_id = false)]
	public class BadContextError : Xcb.GenericError {
		public uint32 invalid_record;
	}
}

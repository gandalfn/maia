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

[CCode (cheader_filename="xcb/xcb.h,xcb/dri2.h")]
namespace Xcb.DRI2
{
	[CCode (cname = "xcb_dri2_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_dri2_query_version")]
		public QueryVersionCookie query_version (uint32 major_version, uint32 minor_version);
	}

	[Compact, CCode (cname = "xcb_dri2_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major_version;
		public uint32 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_dri2_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_dri2_connect", instance_pos = 1.1)]
		public ConnectCookie connect (Xcb.Connection connection, DriverType driver_type);
		[CCode (cname = "xcb_dri2_authenticate", instance_pos = 1.1)]
		public AuthenticateCookie authenticate (Xcb.Connection connection, uint32 magic);
	}

	[Compact, CCode (cname = "xcb_dri2_connect_reply_t", free_function = "free")]
	public class ConnectReply {
		public uint32 driver_name_length;
		public uint32 device_name_length;
		[CCode (cname = "xcb_dri2_connect_driver_name_length")]
		int _driver_name_length ();
		[CCode (cname = "xcb_dri2_connect_driver_name", array_length = false)]
		unowned char[] _driver_name ();
		public string driver_name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_driver_name (), _driver_name_length ());
				return ret.str;
			}
		}
		public int alignment_pad_length {
			[CCode (cname = "xcb_dri2_connect_alignment_pad_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned void[] alignment_pad {
			[CCode (cname = "xcb_dri2_connect_alignment_pad")]
			get;
		}
		[CCode (cname = "xcb_dri2_connect_device_name_length")]
		int _device_name_length ();
		[CCode (cname = "xcb_dri2_connect_device_name", array_length = false)]
		unowned char[] _device_name ();
		public string device_name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_device_name (), _device_name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_dri2_connect_cookie_t")]
	public struct ConnectCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_connect_reply", instance_pos = 1.1)]
		public ConnectReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_authenticate_reply_t", free_function = "free")]
	public class AuthenticateReply {
		public uint32 authenticated;
	}

	[SimpleType, CCode (cname = "xcb_dri2_authenticate_cookie_t")]
	public struct AuthenticateCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_authenticate_reply", instance_pos = 1.1)]
		public AuthenticateReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		/**
		 * Allocates an XID for a new Drawable.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Drawable (Xcb.Connection connection);

		[CCode (cname = "xcb_dri2_create_drawable", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection);
		[CCode (cname = "xcb_dri2_create_drawable_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_dri2_destroy_drawable", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_dri2_destroy_drawable_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_dri2_get_buffers", instance_pos = 1.1)]
		public GetBuffersCookie get_buffers (Xcb.Connection connection, uint32 count, [CCode (array_length_pos = 2.2)]uint32[] attachments);
		[CCode (cname = "xcb_dri2_copy_region", instance_pos = 1.1)]
		public CopyRegionCookie copy_region (Xcb.Connection connection, uint32 region, uint32 dest, uint32 src);
		[CCode (cname = "xcb_dri2_get_buffers_with_format", instance_pos = 1.1)]
		public GetBuffersWithFormatCookie get_buffers_with_format (Xcb.Connection connection, uint32 count, [CCode (array_length_pos = 2.2)]AttachFormat[] attachments);
		[CCode (cname = "xcb_dri2_swap_buffers", instance_pos = 1.1)]
		public SwapBuffersCookie swap_buffers (Xcb.Connection connection, uint32 target_msc_hi, uint32 target_msc_lo, uint32 divisor_hi, uint32 divisor_lo, uint32 remainder_hi, uint32 remainder_lo);
		[CCode (cname = "xcb_dri2_get_msc", instance_pos = 1.1)]
		public GetMscCookie get_msc (Xcb.Connection connection);
		[CCode (cname = "xcb_dri2_wait_msc", instance_pos = 1.1)]
		public WaitMscCookie wait_msc (Xcb.Connection connection, uint32 target_msc_hi, uint32 target_msc_lo, uint32 divisor_hi, uint32 divisor_lo, uint32 remainder_hi, uint32 remainder_lo);
		[CCode (cname = "xcb_dri2_wait_sbc", instance_pos = 1.1)]
		public WaitSbcCookie wait_sbc (Xcb.Connection connection, uint32 target_sbc_hi, uint32 target_sbc_lo);
		[CCode (cname = "xcb_dri2_swap_interval", instance_pos = 1.1)]
		public VoidCookie swap_interval (Xcb.Connection connection, uint32 interval);
		[CCode (cname = "xcb_dri2_swap_interval_checked", instance_pos = 1.1)]
		public VoidCookie swap_interval_checked (Xcb.Connection connection, uint32 interval);
		[CCode (cname = "xcb_dri2_get_param", instance_pos = 1.1)]
		public GetParamCookie get_param (Xcb.Connection connection, uint32 param);
	}

	[Compact, CCode (cname = "xcb_dri2_get_buffers_reply_t", free_function = "free")]
	public class GetBuffersReply {
		public uint32 width;
		public uint32 height;
		public uint32 count;
		[CCode (cname = "xcb_dri2_get_buffers_buffers_iterator")]
		_Dri2bufferIterator _iterator ();
		public Dri2bufferIterator iterator () {
			return (Dri2bufferIterator) _iterator ();
		}
		public int buffers_length {
			[CCode (cname = "xcb_dri2_get_buffers_buffers_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Dri2buffer[] buffers {
			[CCode (cname = "xcb_dri2_get_buffers_buffers")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_dri2_get_buffers_cookie_t")]
	public struct GetBuffersCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_get_buffers_reply", instance_pos = 1.1)]
		public GetBuffersReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_copy_region_reply_t", free_function = "free")]
	public class CopyRegionReply {
	}

	[SimpleType, CCode (cname = "xcb_dri2_copy_region_cookie_t")]
	public struct CopyRegionCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_copy_region_reply", instance_pos = 1.1)]
		public CopyRegionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_get_buffers_with_format_reply_t", free_function = "free")]
	public class GetBuffersWithFormatReply {
		public uint32 width;
		public uint32 height;
		public uint32 count;
		[CCode (cname = "xcb_dri2_get_buffers_with_format_buffers_iterator")]
		_Dri2bufferIterator _iterator ();
		public Dri2bufferIterator iterator () {
			return (Dri2bufferIterator) _iterator ();
		}
		public int buffers_length {
			[CCode (cname = "xcb_dri2_get_buffers_with_format_buffers_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Dri2buffer[] buffers {
			[CCode (cname = "xcb_dri2_get_buffers_with_format_buffers")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_dri2_get_buffers_with_format_cookie_t")]
	public struct GetBuffersWithFormatCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_get_buffers_with_format_reply", instance_pos = 1.1)]
		public GetBuffersWithFormatReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_swap_buffers_reply_t", free_function = "free")]
	public class SwapBuffersReply {
		public uint32 swap_hi;
		public uint32 swap_lo;
	}

	[SimpleType, CCode (cname = "xcb_dri2_swap_buffers_cookie_t")]
	public struct SwapBuffersCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_swap_buffers_reply", instance_pos = 1.1)]
		public SwapBuffersReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_get_msc_reply_t", free_function = "free")]
	public class GetMscReply {
		public uint32 ust_hi;
		public uint32 ust_lo;
		public uint32 msc_hi;
		public uint32 msc_lo;
		public uint32 sbc_hi;
		public uint32 sbc_lo;
	}

	[SimpleType, CCode (cname = "xcb_dri2_get_msc_cookie_t")]
	public struct GetMscCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_get_msc_reply", instance_pos = 1.1)]
		public GetMscReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_wait_msc_reply_t", free_function = "free")]
	public class WaitMscReply {
		public uint32 ust_hi;
		public uint32 ust_lo;
		public uint32 msc_hi;
		public uint32 msc_lo;
		public uint32 sbc_hi;
		public uint32 sbc_lo;
	}

	[SimpleType, CCode (cname = "xcb_dri2_wait_msc_cookie_t")]
	public struct WaitMscCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_wait_msc_reply", instance_pos = 1.1)]
		public WaitMscReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_wait_sbc_reply_t", free_function = "free")]
	public class WaitSbcReply {
		public uint32 ust_hi;
		public uint32 ust_lo;
		public uint32 msc_hi;
		public uint32 msc_lo;
		public uint32 sbc_hi;
		public uint32 sbc_lo;
	}

	[SimpleType, CCode (cname = "xcb_dri2_wait_sbc_cookie_t")]
	public struct WaitSbcCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_wait_sbc_reply", instance_pos = 1.1)]
		public WaitSbcReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dri2_get_param_reply_t", free_function = "free")]
	public class GetParamReply {
		public bool is_param_recognized;
		public uint32 value_hi;
		public uint32 value_lo;
	}

	[SimpleType, CCode (cname = "xcb_dri2_get_param_cookie_t")]
	public struct GetParamCookie : VoidCookie {
		[CCode (cname = "xcb_dri2_get_param_reply", instance_pos = 1.1)]
		public GetParamReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_dri2_attachment_t", cprefix =  "XCB_DRI2_ATTACHMENT_", has_type_id = false)]
	public enum Attachment {
		BUFFER_FRONT_LEFT,
		BUFFER_BACK_LEFT,
		BUFFER_FRONT_RIGHT,
		BUFFER_BACK_RIGHT,
		BUFFER_DEPTH,
		BUFFER_STENCIL,
		BUFFER_ACCUM,
		BUFFER_FAKE_FRONT_LEFT,
		BUFFER_FAKE_FRONT_RIGHT,
		BUFFER_DEPTH_STENCIL,
		BUFFER_HIZ
	}

	[CCode (cname = "xcb_dri2_driver_type_t", cprefix =  "XCB_DRI2_DRIVER_TYPE_", has_type_id = false)]
	public enum DriverType {
		DRI,
		VDPAU
	}

	[CCode (cname = "uint8", cprefix =  "XCB_DRI2_", has_type_id = false)]
	public enum EventType {
		EXCHANGE_COMPLETE,
		BLIT_COMPLETE,
		FLIP_COMPLETE
	}

	[SimpleType, CCode (cname = "xcb_dri2_dri2_buffer_iterator_t")]
	struct _Dri2bufferIterator
	{
		internal int rem;
		internal int index;
		internal unowned Dri2buffer? data;
	}

	[CCode (cname = "xcb_dri2_dri2_buffer_iterator_t")]
	public struct Dri2bufferIterator
	{
		[CCode (cname = "xcb_dri2_dri2_buffer_next")]
		internal void _next ();

		public inline unowned Dri2buffer?
		next_value ()
		{
			if (((_Dri2bufferIterator)this).rem > 0)
			{
				unowned Dri2buffer? d = ((_Dri2bufferIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_dri2_dri2_buffer_t", has_type_id = false)]
	public struct Dri2buffer {
		public Attachment attachment;
		public uint32 name;
		public uint32 pitch;
		public uint32 cpp;
		public uint32 flags;
	}

	[SimpleType, CCode (cname = "xcb_dri2_attach_format_iterator_t")]
	struct _AttachFormatIterator
	{
		internal int rem;
		internal int index;
		internal unowned AttachFormat? data;
	}

	[CCode (cname = "xcb_dri2_attach_format_iterator_t")]
	public struct AttachFormatIterator
	{
		[CCode (cname = "xcb_dri2_attach_format_next")]
		internal void _next ();

		public inline unowned AttachFormat?
		next_value ()
		{
			if (((_AttachFormatIterator)this).rem > 0)
			{
				unowned AttachFormat? d = ((_AttachFormatIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_dri2_attach_format_t", has_type_id = false)]
	public struct AttachFormat {
		public Attachment attachment;
		public uint32 format;
	}

	[Compact, CCode (cname = "xcb_dri2_buffer_swap_complete_event_t", has_type_id = false)]
	public class BufferSwapCompleteEvent : GenericEvent {
		public EventType event_type;
		public Drawable drawable;
		public uint32 ust_hi;
		public uint32 ust_lo;
		public uint32 msc_hi;
		public uint32 msc_lo;
		public uint32 sbc;
	}

	[Compact, CCode (cname = "xcb_dri2_invalidate_buffers_event_t", has_type_id = false)]
	public class InvalidateBuffersEvent : GenericEvent {
		public Drawable drawable;
	}
}

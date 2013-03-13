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

[CCode (cheader_filename="xcb/xcb.h,xcb/xf86dri.h")]
namespace Xcb.XF86Dri
{
	[CCode (cname = "xcb_xf86_dri_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xf86_dri_query_version")]
		public QueryVersionCookie query_version ();
		[CCode (cname = "xcb_xf86_dri_query_direct_rendering_capable")]
		public QueryDirectRenderingCapableCookie query_direct_rendering_capable (uint32 screen);
		[CCode (cname = "xcb_xf86_dri_open_connection")]
		public OpenConnectionCookie open_connection (uint32 screen);
		[CCode (cname = "xcb_xf86_dri_close_connection")]
		public VoidCookie close_connection (uint32 screen);
		[CCode (cname = "xcb_xf86_dri_close_connection_checked")]
		public VoidCookie close_connection_checked (uint32 screen);
		[CCode (cname = "xcb_xf86_dri_get_client_driver_name")]
		public GetClientDriverNameCookie get_client_driver_name (uint32 screen);
		[CCode (cname = "xcb_xf86_dri_create_context")]
		public CreateContextCookie create_context (uint32 screen, uint32 visual, uint32 context);
		[CCode (cname = "xcb_xf86_dri_destroy_context")]
		public VoidCookie destroy_context (uint32 screen, uint32 context);
		[CCode (cname = "xcb_xf86_dri_destroy_context_checked")]
		public VoidCookie destroy_context_checked (uint32 screen, uint32 context);
		[CCode (cname = "xcb_xf86_dri_create_drawable")]
		public CreateDrawableCookie create_drawable (uint32 screen, uint32 drawable);
		[CCode (cname = "xcb_xf86_dri_destroy_drawable")]
		public VoidCookie destroy_drawable (uint32 screen, uint32 drawable);
		[CCode (cname = "xcb_xf86_dri_destroy_drawable_checked")]
		public VoidCookie destroy_drawable_checked (uint32 screen, uint32 drawable);
		[CCode (cname = "xcb_xf86_dri_get_drawable_info")]
		public GetDrawableInfoCookie get_drawable_info (uint32 screen, uint32 drawable);
		[CCode (cname = "xcb_xf86_dri_get_device_info")]
		public GetDeviceInfoCookie get_device_info (uint32 screen);
		[CCode (cname = "xcb_xf86_dri_auth_connection")]
		public AuthConnectionCookie auth_connection (uint32 screen, uint32 magic);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 dri_major_version;
		public uint16 dri_minor_version;
		public uint32 dri_minor_patch;
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_query_direct_rendering_capable_reply_t", free_function = "free")]
	public class QueryDirectRenderingCapableReply {
		public bool is_capable;
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_query_direct_rendering_capable_cookie_t")]
	public struct QueryDirectRenderingCapableCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_query_direct_rendering_capable_reply", instance_pos = 1.1)]
		public QueryDirectRenderingCapableReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_open_connection_reply_t", free_function = "free")]
	public class OpenConnectionReply {
		public uint32 sarea_handle_low;
		public uint32 sarea_handle_high;
		public uint32 bus_id_len;
		[CCode (cname = "xcb_xf86_dri_open_connection_bus_id_length")]
		int _bus_id_length ();
		[CCode (cname = "xcb_xf86_dri_open_connection_bus_id", array_length = false)]
		unowned char[] _bus_id ();
		public string bus_id {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_bus_id (), _bus_id_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_open_connection_cookie_t")]
	public struct OpenConnectionCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_open_connection_reply", instance_pos = 1.1)]
		public OpenConnectionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_get_client_driver_name_reply_t", free_function = "free")]
	public class GetClientDriverNameReply {
		public uint32 client_driver_major_version;
		public uint32 client_driver_minor_version;
		public uint32 client_driver_patch_version;
		public uint32 client_driver_name_len;
		[CCode (cname = "xcb_xf86_dri_get_client_driver_name_client_driver_name_length")]
		int _client_driver_name_length ();
		[CCode (cname = "xcb_xf86_dri_get_client_driver_name_client_driver_name", array_length = false)]
		unowned char[] _client_driver_name ();
		public string client_driver_name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_client_driver_name (), _client_driver_name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_get_client_driver_name_cookie_t")]
	public struct GetClientDriverNameCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_get_client_driver_name_reply", instance_pos = 1.1)]
		public GetClientDriverNameReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_create_context_reply_t", free_function = "free")]
	public class CreateContextReply {
		public uint32 hw_context;
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_create_context_cookie_t")]
	public struct CreateContextCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_create_context_reply", instance_pos = 1.1)]
		public CreateContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_create_drawable_reply_t", free_function = "free")]
	public class CreateDrawableReply {
		public uint32 hw_drawable_handle;
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_create_drawable_cookie_t")]
	public struct CreateDrawableCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_create_drawable_reply", instance_pos = 1.1)]
		public CreateDrawableReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_get_drawable_info_reply_t", free_function = "free")]
	public class GetDrawableInfoReply {
		public uint32 drawable_table_index;
		public uint32 drawable_table_stamp;
		public int16 drawable_origin_X;
		public int16 drawable_origin_Y;
		public int16 drawable_size_W;
		public int16 drawable_size_H;
		public uint32 num_clip_rects;
		public int16 back_x;
		public int16 back_y;
		public uint32 num_back_clip_rects;
		public int clip_rects_length {
			[CCode (cname = "xcb_xf86_dri_get_drawable_info_clip_rects_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned DrmClipRect[] clip_rects {
			[CCode (cname = "xcb_xf86_dri_get_drawable_info_clip_rects")]
			get;
		}
		public int back_clip_rects_length {
			[CCode (cname = "xcb_xf86_dri_get_drawable_info_back_clip_rects_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned DrmClipRect[] back_clip_rects {
			[CCode (cname = "xcb_xf86_dri_get_drawable_info_back_clip_rects")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_get_drawable_info_cookie_t")]
	public struct GetDrawableInfoCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_get_drawable_info_reply", instance_pos = 1.1)]
		public GetDrawableInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_get_device_info_reply_t", free_function = "free")]
	public class GetDeviceInfoReply {
		public uint32 framebuffer_handle_low;
		public uint32 framebuffer_handle_high;
		public uint32 framebuffer_origin_offset;
		public uint32 framebuffer_size;
		public uint32 framebuffer_stride;
		public uint32 device_private_size;
		public int device_private_length {
			[CCode (cname = "xcb_xf86_dri_get_device_info_device_private_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] device_private {
			[CCode (cname = "xcb_xf86_dri_get_device_info_device_private")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_get_device_info_cookie_t")]
	public struct GetDeviceInfoCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_get_device_info_reply", instance_pos = 1.1)]
		public GetDeviceInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_dri_auth_connection_reply_t", free_function = "free")]
	public class AuthConnectionReply {
		public uint32 authenticated;
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_auth_connection_cookie_t")]
	public struct AuthConnectionCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_dri_auth_connection_reply", instance_pos = 1.1)]
		public AuthConnectionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xf86_dri_drm_clip_rect_iterator_t")]
	struct _DrmClipRectIterator
	{
		internal int rem;
		internal int index;
		internal unowned DrmClipRect? data;
	}

	[CCode (cname = "xcb_xf86_dri_drm_clip_rect_iterator_t")]
	public struct DrmClipRectIterator
	{
		[CCode (cname = "xcb_xf86_dri_drm_clip_rect_next")]
		internal void _next ();

		public inline unowned DrmClipRect?
		next_value ()
		{
			if (((_DrmClipRectIterator)this).rem > 0)
			{
				unowned DrmClipRect? d = ((_DrmClipRectIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xf86_dri_drm_clip_rect_t", has_type_id = false)]
	public struct DrmClipRect {
		public int16 x1;
		public int16 y1;
		public int16 x2;
		public int16 x3;
	}
}

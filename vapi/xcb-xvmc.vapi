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
using Xcb.Xv;

[CCode (cheader_filename="xcb/xcb.h,xcb/xvmc.h")]
namespace Xcb.XvMC
{
	[CCode (cname = "xcb_xvmc_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xvmc_query_version")]
		public QueryVersionCookie query_version ();
	}

	[Compact, CCode (cname = "xcb_xvmc_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major;
		public uint32 minor;
	}

	[SimpleType, CCode (cname = "xcb_xvmc_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xvmc_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_xv_port_t", has_type_id = false)]
	public struct Port : Xcb.Xv.Port {
		[CCode (cname = "xcb_xvmc_list_surface_types", instance_pos = 1.1)]
		public ListSurfaceTypesCookie list_surface_types (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_xvmc_list_surface_types_reply_t", free_function = "free")]
	public class ListSurfaceTypesReply {
		public uint32 num;
		[CCode (cname = "xcb_xvmc_list_surface_types_surfaces_iterator")]
		_SurfaceInfoIterator _iterator ();
		public SurfaceInfoIterator iterator () {
			return (SurfaceInfoIterator) _iterator ();
		}
		public int surfaces_length {
			[CCode (cname = "xcb_xvmc_list_surface_types_surfaces_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned SurfaceInfo[] surfaces {
			[CCode (cname = "xcb_xvmc_list_surface_types_surfaces")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xvmc_list_surface_types_cookie_t")]
	public struct ListSurfaceTypesCookie : VoidCookie {
		[CCode (cname = "xcb_xvmc_list_surface_types_reply", instance_pos = 1.1)]
		public ListSurfaceTypesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xvmc_context_iterator_t")]
	struct _ContextIterator
	{
		internal int rem;
		internal int index;
		internal unowned Context? data;
	}

	[CCode (cname = "xcb_xvmc_context_iterator_t")]
	public struct ContextIterator
	{
		[CCode (cname = "xcb_xvmc_context_next")]
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

	[CCode (cname = "xcb_xvmc_context_t", has_type_id = false)]
	public struct Context : uint32 {
		/**
		 * Allocates an XID for a new Context.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Context (Xcb.Connection connection);

		[CCode (cname = "xcb_xvmc_create_context", instance_pos = 1.1)]
		public CreateContextCookie create (Xcb.Connection connection, Port port_id, Surface surface_id, uint16 width, uint16 height, uint32 flags);
		[CCode (cname = "xcb_xvmc_destroy_context", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_xvmc_destroy_context_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_xvmc_create_context_reply_t", free_function = "free")]
	public class CreateContextReply {
		public uint16 width_actual;
		public uint16 height_actual;
		public uint32 flags_return;
		public int priv_data_length {
			[CCode (cname = "xcb_xvmc_create_context_priv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] priv_data {
			[CCode (cname = "xcb_xvmc_create_context_priv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xvmc_create_context_cookie_t")]
	public struct CreateContextCookie : VoidCookie {
		[CCode (cname = "xcb_xvmc_create_context_reply", instance_pos = 1.1)]
		public CreateContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xvmc_surface_iterator_t")]
	struct _SurfaceIterator
	{
		internal int rem;
		internal int index;
		internal unowned Surface? data;
	}

	[CCode (cname = "xcb_xvmc_surface_iterator_t")]
	public struct SurfaceIterator
	{
		[CCode (cname = "xcb_xvmc_surface_next")]
		internal void _next ();

		public inline unowned Surface?
		next_value ()
		{
			if (((_SurfaceIterator)this).rem > 0)
			{
				unowned Surface? d = ((_SurfaceIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xvmc_surface_t", has_type_id = false)]
	public struct Surface : uint32 {
		/**
		 * Allocates an XID for a new Surface.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Surface (Xcb.Connection connection);

		[CCode (cname = "xcb_xvmc_create_surface", instance_pos = 1.1)]
		public CreateSurfaceCookie create (Xcb.Connection connection, Context context_id);
		[CCode (cname = "xcb_xvmc_destroy_surface", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_xvmc_destroy_surface_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_xvmc_list_subpicture_types", instance_pos = 2.2)]
		public ListSubpictureTypesCookie list_subpicture_types (Xcb.Connection connection, Port port_id);
	}

	[Compact, CCode (cname = "xcb_xvmc_create_surface_reply_t", free_function = "free")]
	public class CreateSurfaceReply {
		public int priv_data_length {
			[CCode (cname = "xcb_xvmc_create_surface_priv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] priv_data {
			[CCode (cname = "xcb_xvmc_create_surface_priv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xvmc_create_surface_cookie_t")]
	public struct CreateSurfaceCookie : VoidCookie {
		[CCode (cname = "xcb_xvmc_create_surface_reply", instance_pos = 1.1)]
		public CreateSurfaceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xvmc_list_subpicture_types_reply_t", free_function = "free")]
	public class ListSubpictureTypesReply {
		public uint32 num;
		[CCode (cname = "xcb_xvmc_list_subpicture_types_types_iterator")]
		_ImageFormatInfoIterator _iterator ();
		public ImageFormatInfoIterator iterator () {
			return (ImageFormatInfoIterator) _iterator ();
		}
		public int types_length {
			[CCode (cname = "xcb_xvmc_list_subpicture_types_types_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ImageFormatInfo[] types {
			[CCode (cname = "xcb_xvmc_list_subpicture_types_types")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xvmc_list_subpicture_types_cookie_t")]
	public struct ListSubpictureTypesCookie : VoidCookie {
		[CCode (cname = "xcb_xvmc_list_subpicture_types_reply", instance_pos = 1.1)]
		public ListSubpictureTypesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xvmc_subpicture_iterator_t")]
	struct _SubpictureIterator
	{
		internal int rem;
		internal int index;
		internal unowned Subpicture? data;
	}

	[CCode (cname = "xcb_xvmc_subpicture_iterator_t")]
	public struct SubpictureIterator
	{
		[CCode (cname = "xcb_xvmc_subpicture_next")]
		internal void _next ();

		public inline unowned Subpicture?
		next_value ()
		{
			if (((_SubpictureIterator)this).rem > 0)
			{
				unowned Subpicture? d = ((_SubpictureIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xvmc_subpicture_t", has_type_id = false)]
	public struct Subpicture : uint32 {
		/**
		 * Allocates an XID for a new Subpicture.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Subpicture (Xcb.Connection connection);

		[CCode (cname = "xcb_xvmc_create_subpicture", instance_pos = 1.1)]
		public CreateSubpictureCookie create (Xcb.Connection connection, Context context, uint32 xvimage_id, uint16 width, uint16 height);
		[CCode (cname = "xcb_xvmc_destroy_subpicture", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_xvmc_destroy_subpicture_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_xvmc_create_subpicture_reply_t", free_function = "free")]
	public class CreateSubpictureReply {
		public uint16 width_actual;
		public uint16 height_actual;
		public uint16 num_palette_entries;
		public uint16 entry_bytes;
		public int component_order_length {
			[CCode (cname = "xcb_xvmc_create_subpicture_component_order_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] component_order {
			[CCode (cname = "xcb_xvmc_create_subpicture_component_order")]
			get;
		}
		public int priv_data_length {
			[CCode (cname = "xcb_xvmc_create_subpicture_priv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] priv_data {
			[CCode (cname = "xcb_xvmc_create_subpicture_priv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xvmc_create_subpicture_cookie_t")]
	public struct CreateSubpictureCookie : VoidCookie {
		[CCode (cname = "xcb_xvmc_create_subpicture_reply", instance_pos = 1.1)]
		public CreateSubpictureReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xvmc_surface_info_iterator_t")]
	struct _SurfaceInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned SurfaceInfo? data;
	}

	[CCode (cname = "xcb_xvmc_surface_info_iterator_t")]
	public struct SurfaceInfoIterator
	{
		[CCode (cname = "xcb_xvmc_surface_info_next")]
		internal void _next ();

		public inline unowned SurfaceInfo?
		next_value ()
		{
			if (((_SurfaceInfoIterator)this).rem > 0)
			{
				unowned SurfaceInfo? d = ((_SurfaceInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xvmc_surface_info_t", has_type_id = false)]
	public struct SurfaceInfo {
		public Surface id;
		public uint16 chroma_format;
		public uint16 pad0;
		public uint16 max_width;
		public uint16 max_height;
		public uint16 subpicture_max_width;
		public uint16 subpicture_max_height;
		public uint32 mc_type;
		public uint32 flags;
	}
}

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

[CCode (cheader_filename="xcb/xcb.h,xcb/shm.h")]
namespace Xcb.Shm
{
	[CCode (cname = "xcb_shm_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_shm_query_version")]
		public QueryVersionCookie query_version ();
	}

	[Compact, CCode (cname = "xcb_shm_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public bool shared_pixmaps;
		public uint16 major_version;
		public uint16 minor_version;
		public uint16 uid;
		public uint16 gid;
		public uint8 pixmap_format;
	}

	[SimpleType, CCode (cname = "xcb_shm_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_shm_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_shm_seg_iterator_t")]
	struct _SegIterator
	{
		internal int rem;
		internal int index;
		internal unowned Seg? data;
	}

	[CCode (cname = "xcb_shm_seg_iterator_t")]
	public struct SegIterator
	{
		[CCode (cname = "xcb_shm_seg_next")]
		internal void _next ();

		public inline unowned Seg?
		next_value ()
		{
			if (((_SegIterator)this).rem > 0)
			{
				unowned Seg? d = ((_SegIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_shm_seg_t", has_type_id = false)]
	public struct Seg : uint32 {
		[CCode (cname = "xcb_shm_attach", instance_pos = 1.1)]
		public VoidCookie attach (Xcb.Connection connection, uint32 shmid, bool read_only);
		[CCode (cname = "xcb_shm_attach_checked", instance_pos = 1.1)]
		public VoidCookie attach_checked (Xcb.Connection connection, uint32 shmid, bool read_only);
		[CCode (cname = "xcb_shm_detach", instance_pos = 1.1)]
		public VoidCookie detach (Xcb.Connection connection);
		[CCode (cname = "xcb_shm_detach_checked", instance_pos = 1.1)]
		public VoidCookie detach_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_shm_put_image", instance_pos = 14.14)]
		public VoidCookie put_image (Xcb.Connection connection, Drawable drawable, GContext gc, uint16 total_width, uint16 total_height, uint16 src_x, uint16 src_y, uint16 src_width, uint16 src_height, int16 dst_x, int16 dst_y, uint8 depth, uint8 format, uint8 send_event, uint32 offset);
		[CCode (cname = "xcb_shm_put_image_checked", instance_pos = 14.14)]
		public VoidCookie put_image_checked (Xcb.Connection connection, Drawable drawable, GContext gc, uint16 total_width, uint16 total_height, uint16 src_x, uint16 src_y, uint16 src_width, uint16 src_height, int16 dst_x, int16 dst_y, uint8 depth, uint8 format, uint8 send_event, uint32 offset);
		[CCode (cname = "xcb_shm_get_image", instance_pos = 8.8)]
		public GetImageCookie get_image (Xcb.Connection connection, Drawable drawable, int16 x, int16 y, uint16 width, uint16 height, uint32 plane_mask, uint8 format, uint32 offset);
		[CCode (cname = "xcb_shm_create_pixmap", instance_pos = 6.6)]
		public VoidCookie create_pixmap (Xcb.Connection connection, Pixmap pid, Drawable drawable, uint16 width, uint16 height, uint8 depth, uint32 offset);
		[CCode (cname = "xcb_shm_create_pixmap_checked", instance_pos = 6.6)]
		public VoidCookie create_pixmap_checked (Xcb.Connection connection, Pixmap pid, Drawable drawable, uint16 width, uint16 height, uint8 depth, uint32 offset);
	}

	[Compact, CCode (cname = "xcb_shm_get_image_reply_t", free_function = "free")]
	public class GetImageReply {
		public uint8 depth;
		public Visualid visual;
		public uint32 size;
	}

	[SimpleType, CCode (cname = "xcb_shm_get_image_cookie_t")]
	public struct GetImageCookie : VoidCookie {
		[CCode (cname = "xcb_shm_get_image_reply", instance_pos = 1.1)]
		public GetImageReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_shm_completion_event_t", has_type_id = false)]
	public class CompletionEvent : GenericEvent {
		public Drawable drawable;
		public uint16 minor_event;
		public uint8 major_event;
		public Seg shmseg;
		public uint32 offset;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_SHM_", has_type_id = false)]
	public enum EventType {
		COMPLETION
	}
}

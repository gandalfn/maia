/*
 * Copyright (C) 2012-2014  Nicolas Bruguier
 * All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the names of the authors or their
 * institutions shall not be used in advertising or otherwise to promote the
 * sale, use or other dealings in this Software without prior written
 * authorization from the authors.
 */

using Xcb;
using Xcb.Render;
using Xcb.Shape;

[CCode (cheader_filename="xcb/xcb.h,xcb/xfixes.h")]
namespace Xcb.XFixes
{
	[CCode (cname = "xcb_xfixes_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xfixes_query_version")]
		public QueryVersionCookie query_version (uint32 client_major_version, uint32 client_minor_version);
		[CCode (cname = "xcb_xfixes_get_cursor_image")]
		public GetCursorImageCookie get_cursor_image ();
		[CCode (cname = "xcb_xfixes_get_cursor_image_and_name")]
		public GetCursorImageAndNameCookie get_cursor_image_and_name ();
	}

	[Compact, CCode (cname = "xcb_xfixes_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major_version;
		public uint32 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_xfixes_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xfixes_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xfixes_get_cursor_image_reply_t", free_function = "free")]
	public class GetCursorImageReply {
		public int16 x;
		public int16 y;
		public uint16 width;
		public uint16 height;
		public uint16 xhot;
		public uint16 yhot;
		public uint32 cursor_serial;
		public int cursor_image_length {
			[CCode (cname = "xcb_xfixes_get_cursor_image_cursor_image_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] cursor_image {
			[CCode (cname = "xcb_xfixes_get_cursor_image_cursor_image")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xfixes_get_cursor_image_cookie_t")]
	public struct GetCursorImageCookie : VoidCookie {
		[CCode (cname = "xcb_xfixes_get_cursor_image_reply", instance_pos = 1.1)]
		public GetCursorImageReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xfixes_get_cursor_image_and_name_reply_t", free_function = "free")]
	public class GetCursorImageAndNameReply {
		public int16 x;
		public int16 y;
		public uint16 width;
		public uint16 height;
		public uint16 xhot;
		public uint16 yhot;
		public uint32 cursor_serial;
		public Atom cursor_atom;
		public uint16 nbytes;
		[CCode (cname = "xcb_xfixes_get_cursor_image_and_name_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_xfixes_get_cursor_image_and_name_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
		public int cursor_image_length {
			[CCode (cname = "xcb_xfixes_get_cursor_image_and_name_cursor_image_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] cursor_image {
			[CCode (cname = "xcb_xfixes_get_cursor_image_and_name_cursor_image")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xfixes_get_cursor_image_and_name_cookie_t")]
	public struct GetCursorImageAndNameCookie : VoidCookie {
		[CCode (cname = "xcb_xfixes_get_cursor_image_and_name_reply", instance_pos = 1.1)]
		public GetCursorImageAndNameReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_xfixes_select_selection_input", instance_pos = 1.1)]
		public VoidCookie select_selection_input (Xcb.Connection connection, Atom selection, SelectionEventMask event_mask);
		[CCode (cname = "xcb_xfixes_select_selection_input_checked", instance_pos = 1.1)]
		public VoidCookie select_selection_input_checked (Xcb.Connection connection, Atom selection, SelectionEventMask event_mask);
		[CCode (cname = "xcb_xfixes_select_cursor_input", instance_pos = 1.1)]
		public VoidCookie select_cursor_input (Xcb.Connection connection, CursorNotifyMask event_mask);
		[CCode (cname = "xcb_xfixes_select_cursor_input_checked", instance_pos = 1.1)]
		public VoidCookie select_cursor_input_checked (Xcb.Connection connection, CursorNotifyMask event_mask);
		[CCode (cname = "xcb_xfixes_hide_cursor", instance_pos = 1.1)]
		public VoidCookie hide_cursor (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_hide_cursor_checked", instance_pos = 1.1)]
		public VoidCookie hide_cursor_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_show_cursor", instance_pos = 1.1)]
		public VoidCookie show_cursor (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_show_cursor_checked", instance_pos = 1.1)]
		public VoidCookie show_cursor_checked (Xcb.Connection connection);
	}

	[CCode (cname = "xcb_cursor_t", has_type_id = false)]
	public struct Cursor : Xcb.Cursor {
		[CCode (cname = "xcb_xfixes_set_cursor_name", instance_pos = 1.1)]
		public VoidCookie set_name (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]char[]? name);
		[CCode (cname = "xcb_xfixes_set_cursor_name_checked", instance_pos = 1.1)]
		public VoidCookie set_name_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]char[]? name);
		[CCode (cname = "xcb_xfixes_get_cursor_name", instance_pos = 1.1)]
		public GetCursorNameCookie get_name (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_change_cursor", instance_pos = 1.1)]
		public VoidCookie change (Xcb.Connection connection, Cursor destination);
		[CCode (cname = "xcb_xfixes_change_cursor_checked", instance_pos = 1.1)]
		public VoidCookie change_checked (Xcb.Connection connection, Cursor destination);
		[CCode (cname = "xcb_xfixes_change_cursor_by_name", instance_pos = 1.1)]
		public VoidCookie change_by_name (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]char[]? name);
		[CCode (cname = "xcb_xfixes_change_cursor_by_name_checked", instance_pos = 1.1)]
		public VoidCookie change_by_name_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]char[]? name);
	}

	[Compact, CCode (cname = "xcb_xfixes_get_cursor_name_reply_t", free_function = "free")]
	public class GetCursorNameReply {
		public Atom atom;
		public uint16 nbytes;
		[CCode (cname = "xcb_xfixes_get_cursor_name_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_xfixes_get_cursor_name_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_xfixes_get_cursor_name_cookie_t")]
	public struct GetCursorNameCookie : VoidCookie {
		[CCode (cname = "xcb_xfixes_get_cursor_name_reply", instance_pos = 1.1)]
		public GetCursorNameReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_xfixes_save_set_mode_t", cprefix =  "XCB_XFIXES_SAVE_SET_MODE_", has_type_id = false)]
	public enum SaveSetMode {
		INSERT,
		DELETE
	}

	[CCode (cname = "xcb_xfixes_save_set_target_t", cprefix =  "XCB_XFIXES_SAVE_SET_TARGET_", has_type_id = false)]
	public enum SaveSetTarget {
		NEAREST,
		ROOT
	}

	[CCode (cname = "xcb_xfixes_save_set_mapping_t", cprefix =  "XCB_XFIXES_SAVE_SET_MAPPING_", has_type_id = false)]
	public enum SaveSetMapping {
		MAP,
		UNMAP
	}

	[CCode (cname = "xcb_xfixes_change_save_set", instance_pos = 4.4)]
	public VoidCookie change_save_set (Xcb.Connection connection, SaveSetMode mode, SaveSetTarget target, SaveSetMapping map);
	[CCode (cname = "xcb_xfixes_change_save_set_checked", instance_pos = 4.4)]
	public VoidCookie change_save_set_checked (Xcb.Connection connection, SaveSetMode mode, SaveSetTarget target, SaveSetMapping map);

	[CCode (cname = "xcb_xfixes_selection_event_t", cprefix =  "XCB_XFIXES_SELECTION_EVENT_", has_type_id = false)]
	public enum SelectionEvent {
		SET_SELECTION_OWNER,
		SELECTION_WINDOW_DESTROY,
		SELECTION_CLIENT_CLOSE
	}

	[Flags, CCode (cname = "xcb_xfixes_selection_event_mask_t", cprefix =  "XCB_XFIXES_SELECTION_EVENT_MASK_", has_type_id = false)]
	public enum SelectionEventMask {
		SET_SELECTION_OWNER,
		SELECTION_WINDOW_DESTROY,
		SELECTION_CLIENT_CLOSE
	}

	[Compact, CCode (cname = "xcb_xfixes_selection_notify_event_t", has_type_id = false)]
	public class SelectionNotifyEvent : Xcb.GenericEvent {
		public SelectionEvent subtype;
		public Window window;
		public Window owner;
		public Atom selection;
		public Timestamp timestamp;
		public Timestamp selection_timestamp;
	}

	[CCode (cname = "xcb_xfixes_cursor_notify_t", cprefix =  "XCB_XFIXES_CURSOR_NOTIFY_", has_type_id = false)]
	public enum CursorNotify {
		DISPLAY_CURSOR
	}

	[Flags, CCode (cname = "xcb_xfixes_cursor_notify_mask_t", cprefix =  "XCB_XFIXES_CURSOR_NOTIFY_MASK_", has_type_id = false)]
	public enum CursorNotifyMask {
		DISPLAY_CURSOR
	}

	[Compact, CCode (cname = "xcb_xfixes_cursor_notify_event_t", has_type_id = false)]
	public class CursorNotifyEvent : Xcb.GenericEvent {
		public CursorNotify subtype;
		public Window window;
		public uint32 cursor_serial;
		public Timestamp timestamp;
		public Atom name;
	}

	[SimpleType, CCode (cname = "xcb_xfixes_region_iterator_t")]
	struct _RegionIterator
	{
		internal int rem;
		internal int index;
		internal unowned Region? data;
	}

	[CCode (cname = "xcb_xfixes_region_iterator_t")]
	public struct RegionIterator
	{
		[CCode (cname = "xcb_xfixes_region_next")]
		internal void _next ();

		public inline unowned Region?
		next_value ()
		{
			if (((_RegionIterator)this).rem > 0)
			{
				unowned Region? d = ((_RegionIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xfixes_region_t", has_type_id = false)]
	public struct Region : uint32 {
		/**
		 * Allocates an XID for a new Region.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Region (Xcb.Connection connection);

		[CCode (cname = "xcb_xfixes_create_region", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Rectangle[]? rectangles);
		[CCode (cname = "xcb_xfixes_create_region_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Rectangle[]? rectangles);
		[CCode (cname = "xcb_xfixes_create_region_from_bitmap", instance_pos = 1.1)]
		public VoidCookie create_from_bitmap (Xcb.Connection connection, Pixmap bitmap);
		[CCode (cname = "xcb_xfixes_create_region_from_bitmap_checked", instance_pos = 1.1)]
		public VoidCookie create_from_bitmap_checked (Xcb.Connection connection, Pixmap bitmap);
		[CCode (cname = "xcb_xfixes_create_region_from_window", instance_pos = 1.1)]
		public VoidCookie create_from_window (Xcb.Connection connection, Window window, Kind kind);
		[CCode (cname = "xcb_xfixes_create_region_from_window_checked", instance_pos = 1.1)]
		public VoidCookie create_from_window_checked (Xcb.Connection connection, Window window, Kind kind);
		[CCode (cname = "xcb_xfixes_create_region_from_gc", instance_pos = 1.1)]
		public VoidCookie create_from_gc (Xcb.Connection connection, GContext gc);
		[CCode (cname = "xcb_xfixes_create_region_from_gc_checked", instance_pos = 1.1)]
		public VoidCookie create_from_gc_checked (Xcb.Connection connection, GContext gc);
		[CCode (cname = "xcb_xfixes_create_region_from_picture", instance_pos = 1.1)]
		public VoidCookie create_from_picture (Xcb.Connection connection, Picture picture);
		[CCode (cname = "xcb_xfixes_create_region_from_picture_checked", instance_pos = 1.1)]
		public VoidCookie create_from_picture_checked (Xcb.Connection connection, Picture picture);
		[CCode (cname = "xcb_xfixes_destroy_region", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_destroy_region_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_set_region", instance_pos = 1.1)]
		public VoidCookie set (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Rectangle[]? rectangles);
		[CCode (cname = "xcb_xfixes_set_region_checked", instance_pos = 1.1)]
		public VoidCookie set_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Rectangle[]? rectangles);
		[CCode (cname = "xcb_xfixes_copy_region", instance_pos = 1.1)]
		public VoidCookie copy (Xcb.Connection connection, Region destination);
		[CCode (cname = "xcb_xfixes_copy_region_checked", instance_pos = 1.1)]
		public VoidCookie copy_checked (Xcb.Connection connection, Region destination);
		[CCode (cname = "xcb_xfixes_union_region", instance_pos = 1.1)]
		public VoidCookie union (Xcb.Connection connection, Region source2, Region destination);
		[CCode (cname = "xcb_xfixes_union_region_checked", instance_pos = 1.1)]
		public VoidCookie union_checked (Xcb.Connection connection, Region source2, Region destination);
		[CCode (cname = "xcb_xfixes_intersect_region", instance_pos = 1.1)]
		public VoidCookie intersect (Xcb.Connection connection, Region source2, Region destination);
		[CCode (cname = "xcb_xfixes_intersect_region_checked", instance_pos = 1.1)]
		public VoidCookie intersect_checked (Xcb.Connection connection, Region source2, Region destination);
		[CCode (cname = "xcb_xfixes_subtract_region", instance_pos = 1.1)]
		public VoidCookie subtract (Xcb.Connection connection, Region source2, Region destination);
		[CCode (cname = "xcb_xfixes_subtract_region_checked", instance_pos = 1.1)]
		public VoidCookie subtract_checked (Xcb.Connection connection, Region source2, Region destination);
		[CCode (cname = "xcb_xfixes_invert_region", instance_pos = 1.1)]
		public VoidCookie invert (Xcb.Connection connection, Rectangle bounds, Region destination);
		[CCode (cname = "xcb_xfixes_invert_region_checked", instance_pos = 1.1)]
		public VoidCookie invert_checked (Xcb.Connection connection, Rectangle bounds, Region destination);
		[CCode (cname = "xcb_xfixes_translate_region", instance_pos = 1.1)]
		public VoidCookie translate (Xcb.Connection connection, int16 dx, int16 dy);
		[CCode (cname = "xcb_xfixes_translate_region_checked", instance_pos = 1.1)]
		public VoidCookie translate_checked (Xcb.Connection connection, int16 dx, int16 dy);
		[CCode (cname = "xcb_xfixes_region_extents", instance_pos = 1.1)]
		public VoidCookie extents (Xcb.Connection connection, Region destination);
		[CCode (cname = "xcb_xfixes_region_extents_checked", instance_pos = 1.1)]
		public VoidCookie extents_checked (Xcb.Connection connection, Region destination);
		[CCode (cname = "xcb_xfixes_fetch_region", instance_pos = 1.1)]
		public FetchRegionCookie fetch (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_set_gc_clip_region", instance_pos = 2.2)]
		public VoidCookie set_gc_clip (Xcb.Connection connection, GContext gc, int16 x_origin, int16 y_origin);
		[CCode (cname = "xcb_xfixes_set_gc_clip_region_checked", instance_pos = 2.2)]
		public VoidCookie set_gc_clip_checked (Xcb.Connection connection, GContext gc, int16 x_origin, int16 y_origin);
		[CCode (cname = "xcb_xfixes_set_window_shape_region", instance_pos = 5.5)]
		public VoidCookie set_window_shape (Xcb.Connection connection, Window dest, Kind dest_kind, int16 x_offset, int16 y_offset);
		[CCode (cname = "xcb_xfixes_set_window_shape_region_checked", instance_pos = 5.5)]
		public VoidCookie set_window_shape_checked (Xcb.Connection connection, Window dest, Kind dest_kind, int16 x_offset, int16 y_offset);
		[CCode (cname = "xcb_xfixes_set_picture_clip_region", instance_pos = 2.2)]
		public VoidCookie set_picture_clip (Xcb.Connection connection, Picture picture, int16 x_origin, int16 y_origin);
		[CCode (cname = "xcb_xfixes_set_picture_clip_region_checked", instance_pos = 2.2)]
		public VoidCookie set_picture_clip_checked (Xcb.Connection connection, Picture picture, int16 x_origin, int16 y_origin);
		[CCode (cname = "xcb_xfixes_expand_region", instance_pos = 1.1)]
		public VoidCookie expand (Xcb.Connection connection, Region destination, uint16 left, uint16 right, uint16 top, uint16 bottom);
		[CCode (cname = "xcb_xfixes_expand_region_checked", instance_pos = 1.1)]
		public VoidCookie expand_checked (Xcb.Connection connection, Region destination, uint16 left, uint16 right, uint16 top, uint16 bottom);
	}

	[Compact, CCode (cname = "xcb_xfixes_fetch_region_reply_t", free_function = "free")]
	public class FetchRegionReply {
		public Rectangle extents;
		[CCode (cname = "xcb_xfixes_fetch_region_rectangles_iterator")]
		_RectangleIterator _iterator ();
		public RectangleIterator iterator () {
			return (RectangleIterator) _iterator ();
		}
		public int rectangles_length {
			[CCode (cname = "xcb_xfixes_fetch_region_rectangles_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Rectangle[] rectangles {
			[CCode (cname = "xcb_xfixes_fetch_region_rectangles")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xfixes_fetch_region_cookie_t")]
	public struct FetchRegionCookie : VoidCookie {
		[CCode (cname = "xcb_xfixes_fetch_region_reply", instance_pos = 1.1)]
		public FetchRegionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xfixes_bad_region_error_t", has_type_id = false)]
	public class BadRegionError : Xcb.GenericError {
	}

	[CCode (cname = "xcb_xfixes_region_t", cprefix =  "XCB_XFIXES_REGION_", has_type_id = false)]
	public enum RegionType {
		NONE
	}

	[SimpleType, CCode (cname = "xcb_xfixes_barrier_iterator_t")]
	struct _BarrierIterator
	{
		internal int rem;
		internal int index;
		internal unowned Barrier? data;
	}

	[CCode (cname = "xcb_xfixes_barrier_iterator_t")]
	public struct BarrierIterator
	{
		[CCode (cname = "xcb_xfixes_barrier_next")]
		internal void _next ();

		public inline unowned Barrier?
		next_value ()
		{
			if (((_BarrierIterator)this).rem > 0)
			{
				unowned Barrier? d = ((_BarrierIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xfixes_barrier_t", has_type_id = false)]
	public struct Barrier : uint32 {
		[CCode (cname = "xcb_xfixes_create_pointer_barrier", instance_pos = 1.1)]
		public VoidCookie create_pointer (Xcb.Connection connection, Window window, uint16 x1, uint16 y1, uint16 x2, uint16 y2, BarrierDirections directions, [CCode (array_length_pos = 7.8)]uint16[]? devices);
		[CCode (cname = "xcb_xfixes_create_pointer_barrier_checked", instance_pos = 1.1)]
		public VoidCookie create_pointer_checked (Xcb.Connection connection, Window window, uint16 x1, uint16 y1, uint16 x2, uint16 y2, BarrierDirections directions, [CCode (array_length_pos = 7.8)]uint16[]? devices);
		[CCode (cname = "xcb_xfixes_delete_pointer_barrier", instance_pos = 1.1)]
		public VoidCookie delete_pointer (Xcb.Connection connection);
		[CCode (cname = "xcb_xfixes_delete_pointer_barrier_checked", instance_pos = 1.1)]
		public VoidCookie delete_pointer_checked (Xcb.Connection connection);
	}

	[Flags, CCode (cname = "xcb_xfixes_barrier_directions_t", cprefix =  "XCB_XFIXES_BARRIER_DIRECTIONS_", has_type_id = false)]
	public enum BarrierDirections {
		POSITIVE_X,
		POSITIVE_Y,
		NEGATIVE_X,
		NEGATIVE_Y
	}

	[CCode (cname = "uint8", cprefix =  "XCB_XFIXES_", has_type_id = false)]
	public enum EventType {
		SELECTION_NOTIFY,
		CURSOR_NOTIFY
	}
}

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

[CCode (cheader_filename="xcb/xcb.h,xcb/shape.h")]
namespace Xcb.Shape
{
	[CCode (cname = "xcb_shape_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_shape_query_version")]
		public QueryVersionCookie query_version ();
	}

	[Compact, CCode (cname = "xcb_shape_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 major_version;
		public uint16 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_shape_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_shape_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_shape_mask", instance_pos = 3.3)]
		public VoidCookie mask (Xcb.Connection connection, So operation, Sk destination_kind, int16 x_offset, int16 y_offset, Pixmap source_bitmap);
		[CCode (cname = "xcb_shape_mask_checked", instance_pos = 3.3)]
		public VoidCookie mask_checked (Xcb.Connection connection, So operation, Sk destination_kind, int16 x_offset, int16 y_offset, Pixmap source_bitmap);
		[CCode (cname = "xcb_shape_combine", instance_pos = 4.4)]
		public VoidCookie combine (Xcb.Connection connection, So operation, Sk destination_kind, Sk source_kind, int16 x_offset, int16 y_offset, Window source_window);
		[CCode (cname = "xcb_shape_combine_checked", instance_pos = 4.4)]
		public VoidCookie combine_checked (Xcb.Connection connection, So operation, Sk destination_kind, Sk source_kind, int16 x_offset, int16 y_offset, Window source_window);
		[CCode (cname = "xcb_shape_offset", instance_pos = 2.2)]
		public VoidCookie offset (Xcb.Connection connection, Sk destination_kind, int16 x_offset, int16 y_offset);
		[CCode (cname = "xcb_shape_offset_checked", instance_pos = 2.2)]
		public VoidCookie offset_checked (Xcb.Connection connection, Sk destination_kind, int16 x_offset, int16 y_offset);
		[CCode (cname = "xcb_shape_query_extents", instance_pos = 1.1)]
		public QueryExtentsCookie query_extents (Xcb.Connection connection);
		[CCode (cname = "xcb_shape_select_input", instance_pos = 1.1)]
		public VoidCookie select_input (Xcb.Connection connection, bool enable);
		[CCode (cname = "xcb_shape_select_input_checked", instance_pos = 1.1)]
		public VoidCookie select_input_checked (Xcb.Connection connection, bool enable);
		[CCode (cname = "xcb_shape_input_selected", instance_pos = 1.1)]
		public InputSelectedCookie input_selected (Xcb.Connection connection);
		[CCode (cname = "xcb_shape_get_rectangles", instance_pos = 1.1)]
		public GetRectanglesCookie get_rectangles (Xcb.Connection connection, Sk source_kind);
	}

	[Compact, CCode (cname = "xcb_shape_query_extents_reply_t", free_function = "free")]
	public class QueryExtentsReply {
		public bool bounding_shaped;
		public bool clip_shaped;
		public int16 bounding_shape_extents_x;
		public int16 bounding_shape_extents_y;
		public uint16 bounding_shape_extents_width;
		public uint16 bounding_shape_extents_height;
		public int16 clip_shape_extents_x;
		public int16 clip_shape_extents_y;
		public uint16 clip_shape_extents_width;
		public uint16 clip_shape_extents_height;
	}

	[SimpleType, CCode (cname = "xcb_shape_query_extents_cookie_t")]
	public struct QueryExtentsCookie : VoidCookie {
		[CCode (cname = "xcb_shape_query_extents_reply", instance_pos = 1.1)]
		public QueryExtentsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_shape_input_selected_reply_t", free_function = "free")]
	public class InputSelectedReply {
		public bool enabled;
	}

	[SimpleType, CCode (cname = "xcb_shape_input_selected_cookie_t")]
	public struct InputSelectedCookie : VoidCookie {
		[CCode (cname = "xcb_shape_input_selected_reply", instance_pos = 1.1)]
		public InputSelectedReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_shape_get_rectangles_reply_t", free_function = "free")]
	public class GetRectanglesReply {
		public uint8 ordering;
		public uint32 rectangles_len;
		[CCode (cname = "xcb_shape_get_rectangles_rectangles_iterator")]
		_RectangleIterator _iterator ();
		public RectangleIterator iterator () {
			return (RectangleIterator) _iterator ();
		}
		public int rectangles_length {
			[CCode (cname = "xcb_shape_get_rectangles_rectangles_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Rectangle[] rectangles {
			[CCode (cname = "xcb_shape_get_rectangles_rectangles")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_shape_get_rectangles_cookie_t")]
	public struct GetRectanglesCookie : VoidCookie {
		[CCode (cname = "xcb_shape_get_rectangles_reply", instance_pos = 1.1)]
		public GetRectanglesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_shape_op_t", has_type_id = false)]
	public struct Op : uint8 {
	}

	[SimpleType, CCode (cname = "xcb_shape_kind_t", has_type_id = false)]
	public struct Kind : uint8 {
	}

	[CCode (cname = "xcb_shape_so_t", cprefix =  "XCB_SHAPE_SO_", has_type_id = false)]
	public enum So {
		SET,
		UNION,
		INTERSECT,
		SUBTRACT,
		INVERT
	}

	[CCode (cname = "xcb_shape_sk_t", cprefix =  "XCB_SHAPE_SK_", has_type_id = false)]
	public enum Sk {
		BOUNDING,
		CLIP,
		INPUT
	}

	[Compact, CCode (cname = "xcb_shape_notify_event_t", has_type_id = false)]
	public class NotifyEvent : Xcb.GenericEvent {
		public Sk shape_kind;
		public Window affected_window;
		public int16 extents_x;
		public int16 extents_y;
		public uint16 extents_width;
		public uint16 extents_height;
		public Timestamp server_time;
		public bool shaped;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_SHAPE_", has_type_id = false)]
	public enum EventType {
		NOTIFY
	}
}

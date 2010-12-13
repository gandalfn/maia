/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/* xcb.vapi
 *
 * Copyright (C) 2009  Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 */

[CCode (lower_case_cprefix = "xcb_", cheader_filename = "xcb/xcb.h,xcb/xcbext.h")]
namespace Xcb {
	[Compact]
	[CCode (cname = "xcb_connection_t", cprefix = "xcb_", ref_function = "", unref_function = "", destroy_function = "xcb_disconnect")]
	public class Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? display = null, out int screen = null);

		public void disconnect ();
		public int get_file_descriptor ();

		public void flush ();
		public Setup get_setup ();

		public GenericEvent wait_for_event ();
		public GenericEvent poll_for_event ();

		public void* wait_for_reply (uint request, out GenericError? e = null);
		public bool poll_for_reply (uint request, out void* reply, out GenericError? e = null);

		[CCode (cname = "xcb_create_window")]
		public VoidCookie create_window (uint8 depth, Window wid, Window parent, 
		                                 int16 x, int16 y, uint16 width, uint16 height, uint16 border_width, 
		                                 WindowClass _class, VisualID visual, uint32 value_mask, 
		                                 [CCode (array_length = false)] uint32[]? value_list);

		[CCode (cname = "xcb_intern_atom")]
		public InternAtomCookie intern_atom (bool only_if_exist, uint16 name_len, string name);
	}

	[Compact]
	[CCode (cname = "xcb_setup_t", ref_function = "", unref_function = "")]
	public class Setup {
		public int roots_length ();
		public ScreenIterator roots_iterator ();
	}

	[Compact]
	[CCode (cname = "xcb_screen_t", ref_function = "", unref_function = "")]
	public class Screen {
		public Window root;
		public uint32 white_pixel;
		public uint32 black_pixel;
		public uint16 width_in_pixels;
		public uint16 height_in_pixels;
		public uint16 width_in_millimeters;
		public uint16 height_in_millimeters;
		public VisualID root_visual;
		public DepthIterator allowed_depths_iterator ();
	}

	[SimpleType]
	[CCode (cname = "xcb_screen_iterator_t")]
	public struct ScreenIterator {
		public unowned Screen data;
		public int rem;
		public int index;
		[CCode (cname = "xcb_screen_next")]
		public static void next(out ScreenIterator iter);
	}

	[SimpleType]
	[IntegerType (rank = 9)]
	[CCode (cname = "xcb_drawable_t", type_id = "G_TYPE_UINT",
	        marshaller_type_name = "UINT",
	        get_value_function = "g_value_get_uint",
	        set_value_function = "g_value_set_uint", default_value = "0",
	        type_signature = "u")]
	public struct Drawable : uint32 {
		[CCode (cname = "xcb_get_geometry", instance_pos = -1)]
		public GetGeometryCookie get_geometry (Connection connection);

		[CCode (cname = "xcb_generate_id")]
		public Drawable (Connection inConnection);
	}

	[SimpleType]
	[IntegerType (rank = 9)]
	[CCode (cname = "xcb_window_t", type_id = "G_TYPE_UINT",
	        marshaller_type_name = "UINT",
	        get_value_function = "g_value_get_uint",
	        set_value_function = "g_value_set_uint", default_value = "0",
	        type_signature = "u")]
 	public struct Window : Drawable {
		[CCode (cname = "xcb_generate_id")]
		public Window (Connection inConnection);

		[CCode (cname = "xcb_map_window", instance_pos = -1)]
		public VoidCookie map (Connection inConnection);

		[CCode (cname = "xcb_destroy_window", instance_pos = -1)]
		public VoidCookie destroy (Connection inConnection);

		[CCode (cname = "xcb_change_window_attributes", instance_pos = 1.1)]
		public VoidCookie change_attributes (Connection inConnection, uint32 value_mask, 
		                                     [CCode (array_length = false)] uint32[]? value_list);

		[CCode (cname = "xcb_change_property", instance_pos = 2.2)]
		public VoidCookie change_property (Connection inConnection, PropMode prop_mode, 
		                                   Atom property, Atom type, uint8 format,
		                                   uint32 data_len, void* data);
	}

	[SimpleType]
	[IntegerType (rank = 9)]
	[CCode (cname = "xcb_atom_t", type_id = "G_TYPE_UINT",
	        marshaller_type_name = "INT",
	        get_value_function = "g_value_get_uint",
	        set_value_function = "g_value_set_uint", default_value = "0",
	        type_signature = "u")]
	public struct Atom : uint32 {
	}

	[Compact]
	[CCode (cname = "xcb_depth_t", ref_function = "", unref_function = "")]
	public class Depth {
		public uint8 depth;
		public VisualTypeIterator visuals_iterator ();
	}

	[SimpleType]
	[CCode (cname = "xcb_depth_iterator_t")]
	public struct DepthIterator {
		public unowned Depth data;
		public int rem;
		[CCode (cname = "xcb_depth_next")]
		public static void next (out DepthIterator iter);
	}

	[SimpleType]
	[CCode (cname = "xcb_visualid_t")]
	public struct VisualID : uint32 {
	}

	[Compact]
	[CCode (cname = "xcb_visualtype_t", ref_function = "", unref_function = "")]
	public class VisualType {
		public VisualID visual_id;
		public uint8 _class;
		public uint8 bits_per_rgb_value;
	}

	[SimpleType]
	[CCode (cname = "xcb_visualtype_iterator_t")]
	public struct VisualTypeIterator {
		public unowned VisualType data;
		public int rem;
		[CCode (cname = "xcb_visualtype_next")]
		public static void next (out VisualTypeIterator iter);
	}

	[CCode (cname = "xcb_rectangle_t")]
	public struct Rectangle {
		public int16 x;
		public int16 y;
		public uint16 width;
		public uint16 height;
	}

	[Compact]
	[CCode (cname = "xcb_query_tree_reply_t", ref_function = "", unref_function = "")]
	public class QueryTreeReply {
		public Window root;
		public Window parent;
		public uint16 children_len;
		[CCode (cname = "xcb_query_tree_children", array_length = false)]
		public Window* children();
	}

	[SimpleType]
	[CCode (cname = "xcb_button_t")]
	public struct Button : uint8 {
	}

	[Compact]
	[CCode (cname = "xcb_generic_error_t", ref_function = "", unref_function = "")]
	public class GenericError {
		public uint8 response_type;
		public uint8 error_code;
		public uint16 sequence;
		public uint32 resource_id;
		public uint16 minor_code;
		public uint8 major_code;
	}

	[Compact]
	[CCode (cname = "xcb_generic_reply_t", ref_function = "", unref_function = "free")]
	public class GenericReply {
		public uint8 response_type;
		public uint16 sequence;
	}

	[Compact]
	[CCode (cname = "xcb_intern_atom_reply_t", ref_function = "", unref_function = "free")]
	public class InternAtomReply {
		public uint8 response_type;
		public uint16 sequence;
		public uint32 length;
		public Atom atom;
	}

	[Compact]
	[CCode (cname = "xcb_get_geometry_reply_t", ref_function = "", unref_function = "free")]
	public class GetGeometryReply {
		public uint8 response_type;
		public uint16 sequence;
		public uint32 length;
		public Window root;
		public int16 x;
		public int16 y;
		public uint16 width;
		public uint16 height;
		public uint16 border_width;
	}

	[Compact]
	[CCode (cname = "xcb_generic_event_t", ref_function = "", unref_function = "")]
	public class GenericEvent {
		public uint8 response_type;
		public uint16 sequence;
	}

	[CCode (cname = "xcb_button_press_event_t", ref_function = "", unref_function = "")]
	public class ButtonPressEvent : GenericEvent {
		public Button detail;
		public Window root;
		public Window event;
		public Window child;
		public uint16 root_x;
		public uint16 root_y;
		public uint16 event_x;
		public uint16 event_y;
	}

	[CCode (cname = "xcb_button_release_event_t", ref_function = "", unref_function = "")]
	public class ButtonReleaseEvent : GenericEvent {
		public Button detail;
		public Window root;
		public Window event;
		public Window child;
		public uint16 root_x;
		public uint16 root_y;
		public uint16 event_x;
		public uint16 event_y;
	}

	[CCode (cname = "xcb_motion_notify_event_t", ref_function = "", unref_function = "")]
	public class MotionNotifyEvent : GenericEvent {
		public Window root;
		public Window event;
		public Window child;
		public uint16 root_x;
		public uint16 root_y;
		public uint16 event_x;
		public uint16 event_y;
	}

	[CCode (cname = "xcb_expose_event_t", ref_function = "", unref_function = "")]
	public class ExposeEvent : GenericEvent {
		public Window window;
		public uint16 x;
		public uint16 y;
		public uint16 width;
		public uint16 height;
	}

	[CCode (cname = "xcb_configure_notify_event_t", ref_function = "", unref_function = "")]
	public class ConfigureNotifyEvent : GenericEvent {
		public Window event;
		public Window window;
		public Window above_sibling;
		public uint16 x;
		public uint16 y;
		public uint16 width;
		public uint16 height;
		public uint16 border_width;
		public uint8 override_redirect;
	}

	[CCode (cname = "xcb_reparent_notify_event_t", ref_function = "", unref_function = "")]
	public class ReparentNotifyEvent : GenericEvent {
		public Window event;
		public Window window;
		public Window parent;
	}

	[CCode (cname = "xcb_map_notify_event_t", ref_function = "", unref_function = "")]
	public class MapNotifyEvent : GenericEvent {
		public Window event;
		public Window window;
	}

	[CCode (cname = "xcb_unmap_notify_event_t", ref_function = "", unref_function = "")]
	public class UnmapNotifyEvent : GenericEvent {
		public Window event;
		public Window window;
	}

	[CCode (cname = "xcb_destroy_notify_event_t", ref_function = "", unref_function = "")]
	public class DestroyNotifyEvent : GenericEvent {
		public Window event;
		public Window window;
	}

	[SimpleType]
	[CCode (cname = "xcb_client_message_data_t", ref_function = "", unref_function = "")]
	public struct ClientMessageData {
		public uint8  data8[20];
		public uint16 data16[10];
		public uint32 data32[5];
	}

	[CCode (cname = "xcb_client_message_event_t", ref_function = "", unref_function = "")]
	public class ClientMessageEvent : GenericEvent {
		public Window window;
		public Atom type;
		public ClientMessageData data;
	}

	[CCode (cname = "xcb_cw_t")]
	public enum CW {
		BACK_PIXMAP,
		BACK_PIXEL,
		BORDER_PIXMAP,
		BORDER_PIXEL,
		BIT_GRAVITY,
		WIN_GRAVITY,
		BACKING_STORE,
		BACKING_PLANES,
		BACKING_PIXEL,
		OVERRIDE_REDIRECT,
		SAVE_UNDER,
		EVENT_MASK,
		DONT_PROPAGATE,
		COLORMAP,
		CURSOR
	}

	[CCode (cname = "xcb_event_mask_t")]
	public enum EventMask {
		NO_EVENT,
		KEY_PRESS,
		KEY_RELEASE,
		BUTTON_PRESS,
		BUTTON_RELEASE,
		ENTER_WINDOW,
		LEAVE_WINDOW,
		POINTER_MOTION,
		POINTER_MOTION_HINT,
		BUTTON_1MOTION,
		BUTTON_2MOTION,
		BUTTON_3MOTION,
		BUTTON_4MOTION,
		BUTTON_5MOTION,
		BUTTON_MOTION,
		KEYMAP_STATE,
		EXPOSURE,
		VISIBILITY_CHANGE,
		STRUCTURE_NOTIFY,
		RESIZE_REDIRECT,
		SUBSTRUCTURE_NOTIFY,
		SUBSTRUCTURE_REDIRECT,
		FOCUS_CHANGE,
		PROPERTY_CHANGE,
		COLOR_MAP_CHANGE,
		OWNER_GRAB_BUTTON
	}

	[CCode (cname = "xcb_prop_mode_t", cprefix = "XCB_PROP_MODE_")]
	public enum PropMode {
		REPLACE,
		PREPEND,
		APPEND
	}

	[CCode (cname = "xcb_atom_enum_t", cprefix = "XCB_ATOM_")]
	public enum AtomType {
		NONE,
		ANY,
		PRIMARY,
		SECONDARY,
		ARC,
		ATOM,
		BITMAP,
		CARDINAL,
		COLORMAP,
		CURSOR,
		CUT_BUFFER0,
		CUT_BUFFER1,
		CUT_BUFFER2,
		CUT_BUFFER3,
		CUT_BUFFER4,
		CUT_BUFFER5,
		CUT_BUFFER6,
		CUT_BUFFER7,
		DRAWABLE,
		FONT,
		INTEGER,
		PIXMAP,
		POINT,
		RECTANGLE,
		RESOURCE_MANAGER,
		RGB_COLOR_MAP,
		RGB_BEST_MAP,
		RGB_BLUE_MAP,
		RGB_DEFAULT_MAP,
		RGB_GRAY_MAP,
		RGB_GREEN_MAP,
		RGB_RED_MAP,
		STRING,
		VISUALID,
		WINDOW,
		WM_COMMAND,
		WM_HINTS,
		WM_CLIENT_MACHINE,
		WM_ICON_NAME,
		WM_ICON_SIZE,
		WM_NAME,
		WM_NORMAL_HINTS,
		WM_SIZE_HINTS,
		WM_ZOOM_HINTS,
		MIN_SPACE,
		NORM_SPACE,
		MAX_SPACE,
		END_SPACE,
		SUPERSCRIPT_X,
		SUPERSCRIPT_Y,
		SUBSCRIPT_X,
		SUBSCRIPT_Y,
		UNDERLINE_POSITION,
		UNDERLINE_THICKNESS,
		STRIKEOUT_ASCENT,
		STRIKEOUT_DESCENT,
		ITALIC_ANGLE,
		X_HEIGHT,
		QUAD_WIDTH,
		WEIGHT,
		POINT_SIZE,
		RESOLUTION,
		COPYRIGHT,
		NOTICE,
		FONT_NAME,
		FAMILY_NAME,
		FULL_NAME,
		CAP_HEIGHT,
		WM_CLASS,
		WM_TRANSIENT_FOR
	}

	[SimpleType]
	[CCode (cname = "xcb_void_cookie_t")]
	public struct VoidCookie {
		public uint sequence;
	}

	[SimpleType]
	[CCode (cname = "xcb_query_tree_cookie_t")]
	public struct QueryTreeCookie {
		public uint sequence;
	}

	[SimpleType]
	[CCode (cname = "xcb_get_geometry_cookie_t")]
	public struct GetGeometryCookie {
		public uint sequence;

		[CCode (cname = "xcb_get_geometry_reply", instance_pos = 1.1)]
		public GetGeometryReply reply (Connection connection, out GenericError? error = null);
	}

	[SimpleType]
	[CCode (cname = "xcb_intern_atom_cookie_t")]
	public struct InternAtomCookie {
		public uint sequence;

		[CCode (cname = "xcb_intern_atom_reply", instance_pos = 1.1)]
		public InternAtomReply reply (Connection connection, out GenericError? error = null);
	}

	[CCode (cname = "xcb_window_class_t", cprefix = "XCB_WINDOW_CLASS_", has_type_id = false)]
	public enum WindowClass {
		COPY_FROM_PARENT,
		INPUT_OUTPUT,
		INPUT_ONLY
	}

	public const uint8 BUTTON_PRESS;
	public const uint8 BUTTON_RELEASE;
	public const uint8 EXPOSE;
	public const uint8 MOTION_NOTIFY;
	public const uint8 ENTER_NOTIFY;
	public const uint8 LEAVE_NOTIFY;
	public const uint8 CONFIGURE_NOTIFY;
	public const uint8 DESTROY_NOTIFY;
	public const uint8 REPARENT_NOTIFY;
	public const uint8 MAP_NOTIFY;
	public const uint8 UNMAP_NOTIFY;
	public const uint8 CLIENT_MESSAGE;

	[CCode (cname = "XCB_NONE")]
	public const uint8 None;

	[CCode (cname = "XCB_COPY_FROM_PARENT")]
	public const uint8 CopyFromParent;

	[CCode (cname = "XCB_CURRENT_TIME")]
	public const uint8 CurrentTime;
}


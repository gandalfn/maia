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
using Xcb.Shm;

[CCode (cheader_filename="xcb/xcb.h,xcb/xv.h")]
namespace Xcb.Xv
{
	[CCode (cname = "xcb_xv_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xv_query_extension")]
		public QueryExtensionCookie query_extension ();
	}

	[Compact, CCode (cname = "xcb_xv_query_extension_reply_t", free_function = "free")]
	public class QueryExtensionReply {
		public uint16 major;
		public uint16 minor;
	}

	[SimpleType, CCode (cname = "xcb_xv_query_extension_cookie_t")]
	public struct QueryExtensionCookie : VoidCookie {
		[CCode (cname = "xcb_xv_query_extension_reply", instance_pos = 1.1)]
		public QueryExtensionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_xv_query_adaptors", instance_pos = 1.1)]
		public QueryAdaptorsCookie query_adaptors (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_xv_query_adaptors_reply_t", free_function = "free")]
	public class QueryAdaptorsReply {
		public uint16 num_adaptors;
		[CCode (cname = "xcb_xv_query_adaptors_info_iterator")]
		_AdaptorInfoIterator _iterator ();
		public AdaptorInfoIterator iterator () {
			return (AdaptorInfoIterator) _iterator ();
		}
		public int info_length {
			[CCode (cname = "xcb_xv_query_adaptors_info_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned AdaptorInfo[] info {
			[CCode (cname = "xcb_xv_query_adaptors_info")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_query_adaptors_cookie_t")]
	public struct QueryAdaptorsCookie : VoidCookie {
		[CCode (cname = "xcb_xv_query_adaptors_reply", instance_pos = 1.1)]
		public QueryAdaptorsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		[CCode (cname = "xcb_xv_select_video_notify", instance_pos = 1.1)]
		public VoidCookie select_video_notify (Xcb.Connection connection, bool onoff);
		[CCode (cname = "xcb_xv_select_video_notify_checked", instance_pos = 1.1)]
		public VoidCookie select_video_notify_checked (Xcb.Connection connection, bool onoff);
	}

	[SimpleType, CCode (cname = "xcb_xv_port_iterator_t")]
	struct _PortIterator
	{
		internal int rem;
		internal int index;
		internal unowned Port? data;
	}

	[CCode (cname = "xcb_xv_port_iterator_t")]
	public struct PortIterator
	{
		[CCode (cname = "xcb_xv_port_next")]
		internal void _next ();

		public inline unowned Port?
		next_value ()
		{
			if (((_PortIterator)this).rem > 0)
			{
				unowned Port? d = ((_PortIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_port_t", has_type_id = false)]
	public struct Port : uint32 {
		[CCode (cname = "xcb_xv_query_encodings", instance_pos = 1.1)]
		public QueryEncodingsCookie query_encodings (Xcb.Connection connection);
		[CCode (cname = "xcb_xv_grab_port", instance_pos = 1.1)]
		public GrabPortCookie grab (Xcb.Connection connection, Timestamp time);
		[CCode (cname = "xcb_xv_ungrab_port", instance_pos = 1.1)]
		public VoidCookie ungrab (Xcb.Connection connection, Timestamp time);
		[CCode (cname = "xcb_xv_ungrab_port_checked", instance_pos = 1.1)]
		public VoidCookie ungrab_checked (Xcb.Connection connection, Timestamp time);
		[CCode (cname = "xcb_xv_put_video", instance_pos = 1.1)]
		public VoidCookie put_video (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_put_video_checked", instance_pos = 1.1)]
		public VoidCookie put_video_checked (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_put_still", instance_pos = 1.1)]
		public VoidCookie put_still (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_put_still_checked", instance_pos = 1.1)]
		public VoidCookie put_still_checked (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_get_video", instance_pos = 1.1)]
		public VoidCookie get_video (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_get_video_checked", instance_pos = 1.1)]
		public VoidCookie get_video_checked (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_get_still", instance_pos = 1.1)]
		public VoidCookie get_still (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_get_still_checked", instance_pos = 1.1)]
		public VoidCookie get_still_checked (Xcb.Connection connection, Drawable drawable, GContext gc, int16 vid_x, int16 vid_y, uint16 vid_w, uint16 vid_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h);
		[CCode (cname = "xcb_xv_stop_video", instance_pos = 1.1)]
		public VoidCookie stop_video (Xcb.Connection connection, Drawable drawable);
		[CCode (cname = "xcb_xv_stop_video_checked", instance_pos = 1.1)]
		public VoidCookie stop_video_checked (Xcb.Connection connection, Drawable drawable);
		[CCode (cname = "xcb_xv_select_port_notify", instance_pos = 1.1)]
		public VoidCookie select_notify (Xcb.Connection connection, bool onoff);
		[CCode (cname = "xcb_xv_select_port_notify_checked", instance_pos = 1.1)]
		public VoidCookie select_notify_checked (Xcb.Connection connection, bool onoff);
		[CCode (cname = "xcb_xv_query_best_size", instance_pos = 1.1)]
		public QueryBestSizeCookie query_best_size (Xcb.Connection connection, uint16 vid_w, uint16 vid_h, uint16 drw_w, uint16 drw_h, bool motion);
		[CCode (cname = "xcb_xv_set_port_attribute", instance_pos = 1.1)]
		public VoidCookie set_attribute (Xcb.Connection connection, Atom attribute, int32 value);
		[CCode (cname = "xcb_xv_set_port_attribute_checked", instance_pos = 1.1)]
		public VoidCookie set_attribute_checked (Xcb.Connection connection, Atom attribute, int32 value);
		[CCode (cname = "xcb_xv_get_port_attribute", instance_pos = 1.1)]
		public GetPortAttributeCookie get_attribute (Xcb.Connection connection, Atom attribute);
		[CCode (cname = "xcb_xv_query_port_attributes", instance_pos = 1.1)]
		public QueryPortAttributesCookie query_attributes (Xcb.Connection connection);
		[CCode (cname = "xcb_xv_list_image_formats", instance_pos = 1.1)]
		public ListImageFormatsCookie list_image_formats (Xcb.Connection connection);
		[CCode (cname = "xcb_xv_query_image_attributes", instance_pos = 1.1)]
		public QueryImageAttributesCookie query_image_attributes (Xcb.Connection connection, uint32 id, uint16 width, uint16 height);
		[CCode (cname = "xcb_xv_put_image", instance_pos = 1.1)]
		public VoidCookie put_image (Xcb.Connection connection, Drawable drawable, GContext gc, uint32 id, int16 src_x, int16 src_y, uint16 src_w, uint16 src_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h, uint16 width, uint16 height, [CCode (array_length_pos = 14.14)]uint8[] data);
		[CCode (cname = "xcb_xv_put_image_checked", instance_pos = 1.1)]
		public VoidCookie put_image_checked (Xcb.Connection connection, Drawable drawable, GContext gc, uint32 id, int16 src_x, int16 src_y, uint16 src_w, uint16 src_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h, uint16 width, uint16 height, [CCode (array_length_pos = 14.14)]uint8[] data);
		[CCode (cname = "xcb_xv_shm_put_image", instance_pos = 1.1)]
		public VoidCookie shm_put_image (Xcb.Connection connection, Drawable drawable, GContext gc, Seg shmseg, uint32 id, uint32 offset, int16 src_x, int16 src_y, uint16 src_w, uint16 src_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h, uint16 width, uint16 height, uint8 send_event);
		[CCode (cname = "xcb_xv_shm_put_image_checked", instance_pos = 1.1)]
		public VoidCookie shm_put_image_checked (Xcb.Connection connection, Drawable drawable, GContext gc, Seg shmseg, uint32 id, uint32 offset, int16 src_x, int16 src_y, uint16 src_w, uint16 src_h, int16 drw_x, int16 drw_y, uint16 drw_w, uint16 drw_h, uint16 width, uint16 height, uint8 send_event);
	}

	[Compact, CCode (cname = "xcb_xv_query_encodings_reply_t", free_function = "free")]
	public class QueryEncodingsReply {
		public uint16 num_encodings;
		[CCode (cname = "xcb_xv_query_encodings_info_iterator")]
		_EncodingInfoIterator _iterator ();
		public EncodingInfoIterator iterator () {
			return (EncodingInfoIterator) _iterator ();
		}
		public int info_length {
			[CCode (cname = "xcb_xv_query_encodings_info_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned EncodingInfo[] info {
			[CCode (cname = "xcb_xv_query_encodings_info")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_query_encodings_cookie_t")]
	public struct QueryEncodingsCookie : VoidCookie {
		[CCode (cname = "xcb_xv_query_encodings_reply", instance_pos = 1.1)]
		public QueryEncodingsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xv_grab_port_reply_t", free_function = "free")]
	public class GrabPortReply {
		public GrabPortStatus result;
	}

	[SimpleType, CCode (cname = "xcb_xv_grab_port_cookie_t")]
	public struct GrabPortCookie : VoidCookie {
		[CCode (cname = "xcb_xv_grab_port_reply", instance_pos = 1.1)]
		public GrabPortReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xv_query_best_size_reply_t", free_function = "free")]
	public class QueryBestSizeReply {
		public uint16 actual_width;
		public uint16 actual_height;
	}

	[SimpleType, CCode (cname = "xcb_xv_query_best_size_cookie_t")]
	public struct QueryBestSizeCookie : VoidCookie {
		[CCode (cname = "xcb_xv_query_best_size_reply", instance_pos = 1.1)]
		public QueryBestSizeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xv_get_port_attribute_reply_t", free_function = "free")]
	public class GetPortAttributeReply {
		public int32 value;
	}

	[SimpleType, CCode (cname = "xcb_xv_get_port_attribute_cookie_t")]
	public struct GetPortAttributeCookie : VoidCookie {
		[CCode (cname = "xcb_xv_get_port_attribute_reply", instance_pos = 1.1)]
		public GetPortAttributeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xv_query_port_attributes_reply_t", free_function = "free")]
	public class QueryPortAttributesReply {
		public uint32 num_attributes;
		public uint32 text_size;
		[CCode (cname = "xcb_xv_query_port_attributes_attributes_iterator")]
		_AttributeInfoIterator _iterator ();
		public AttributeInfoIterator iterator () {
			return (AttributeInfoIterator) _iterator ();
		}
		public int attributes_length {
			[CCode (cname = "xcb_xv_query_port_attributes_attributes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned AttributeInfo[] attributes {
			[CCode (cname = "xcb_xv_query_port_attributes_attributes")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_query_port_attributes_cookie_t")]
	public struct QueryPortAttributesCookie : VoidCookie {
		[CCode (cname = "xcb_xv_query_port_attributes_reply", instance_pos = 1.1)]
		public QueryPortAttributesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xv_list_image_formats_reply_t", free_function = "free")]
	public class ListImageFormatsReply {
		public uint32 num_formats;
		[CCode (cname = "xcb_xv_list_image_formats_format_iterator")]
		_ImageFormatInfoIterator _iterator ();
		public ImageFormatInfoIterator iterator () {
			return (ImageFormatInfoIterator) _iterator ();
		}
		public int format_length {
			[CCode (cname = "xcb_xv_list_image_formats_format_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ImageFormatInfo[] format {
			[CCode (cname = "xcb_xv_list_image_formats_format")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_list_image_formats_cookie_t")]
	public struct ListImageFormatsCookie : VoidCookie {
		[CCode (cname = "xcb_xv_list_image_formats_reply", instance_pos = 1.1)]
		public ListImageFormatsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xv_query_image_attributes_reply_t", free_function = "free")]
	public class QueryImageAttributesReply {
		public uint32 num_planes;
		public uint32 data_size;
		public uint16 width;
		public uint16 height;
		public int pitches_length {
			[CCode (cname = "xcb_xv_query_image_attributes_pitches_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] pitches {
			[CCode (cname = "xcb_xv_query_image_attributes_pitches")]
			get;
		}
		public int offsets_length {
			[CCode (cname = "xcb_xv_query_image_attributes_offsets_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] offsets {
			[CCode (cname = "xcb_xv_query_image_attributes_offsets")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_query_image_attributes_cookie_t")]
	public struct QueryImageAttributesCookie : VoidCookie {
		[CCode (cname = "xcb_xv_query_image_attributes_reply", instance_pos = 1.1)]
		public QueryImageAttributesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xv_encoding_iterator_t")]
	struct _EncodingIterator
	{
		internal int rem;
		internal int index;
		internal unowned Encoding? data;
	}

	[CCode (cname = "xcb_xv_encoding_iterator_t")]
	public struct EncodingIterator
	{
		[CCode (cname = "xcb_xv_encoding_next")]
		internal void _next ();

		public inline unowned Encoding?
		next_value ()
		{
			if (((_EncodingIterator)this).rem > 0)
			{
				unowned Encoding? d = ((_EncodingIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_encoding_t", has_type_id = false)]
	public struct Encoding : uint32 {
	}

	[Flags, CCode (cname = "xcb_xv_type_t", cprefix =  "XCB_XV_TYPE_", has_type_id = false)]
	public enum Type {
		INPUT_MASK,
		OUTPUT_MASK,
		VIDEO_MASK,
		STILL_MASK,
		IMAGE_MASK
	}

	[CCode (cname = "xcb_xv_image_format_info_type_t", cprefix =  "XCB_XV_IMAGE_FORMAT_INFO_TYPE_", has_type_id = false)]
	public enum ImageFormatInfoType {
		RGB,
		YUV
	}

	[CCode (cname = "xcb_xv_image_format_info_format_t", cprefix =  "XCB_XV_IMAGE_FORMAT_INFO_FORMAT_", has_type_id = false)]
	public enum ImageFormatInfoFormat {
		PACKED,
		PLANAR
	}

	[Flags, CCode (cname = "xcb_xv_attribute_flag_t", cprefix =  "XCB_XV_ATTRIBUTE_FLAG_", has_type_id = false)]
	public enum AttributeFlag {
		GETTABLE,
		SETTABLE
	}

	[CCode (cname = "xcb_xv_video_notify_reason_t", cprefix =  "XCB_XV_VIDEO_NOTIFY_REASON_", has_type_id = false)]
	public enum VideoNotifyReason {
		STARTED,
		STOPPED,
		BUSY,
		PREEMPTED,
		HARD_ERROR
	}

	[CCode (cname = "xcb_xv_scanline_order_t", cprefix =  "XCB_XV_SCANLINE_ORDER_", has_type_id = false)]
	public enum ScanlineOrder {
		TOP_TO_BOTTOM,
		BOTTOM_TO_TOP
	}

	[CCode (cname = "xcb_xv_grab_port_status_t", cprefix =  "XCB_XV_GRAB_PORT_STATUS_", has_type_id = false)]
	public enum GrabPortStatus {
		SUCCESS,
		BAD_EXTENSION,
		ALREADY_GRABBED,
		INVALID_TIME,
		BAD_REPLY,
		BAD_ALLOC
	}

	[SimpleType, CCode (cname = "xcb_xv_rational_iterator_t")]
	struct _RationalIterator
	{
		internal int rem;
		internal int index;
		internal unowned Rational? data;
	}

	[CCode (cname = "xcb_xv_rational_iterator_t")]
	public struct RationalIterator
	{
		[CCode (cname = "xcb_xv_rational_next")]
		internal void _next ();

		public inline unowned Rational?
		next_value ()
		{
			if (((_RationalIterator)this).rem > 0)
			{
				unowned Rational? d = ((_RationalIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_rational_t", has_type_id = false)]
	public struct Rational {
		public int32 numerator;
		public int32 denominator;
	}

	[SimpleType, CCode (cname = "xcb_xv_format_iterator_t")]
	struct _FormatIterator
	{
		internal int rem;
		internal int index;
		internal unowned Format? data;
	}

	[CCode (cname = "xcb_xv_format_iterator_t")]
	public struct FormatIterator
	{
		[CCode (cname = "xcb_xv_format_next")]
		internal void _next ();

		public inline unowned Format?
		next_value ()
		{
			if (((_FormatIterator)this).rem > 0)
			{
				unowned Format? d = ((_FormatIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_format_t", has_type_id = false)]
	public struct Format {
		public Visualid visual;
		public uint8 depth;
	}

	[SimpleType, CCode (cname = "xcb_xv_adaptor_info_iterator_t")]
	struct _AdaptorInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned AdaptorInfo? data;
	}

	[CCode (cname = "xcb_xv_adaptor_info_iterator_t")]
	public struct AdaptorInfoIterator
	{
		[CCode (cname = "xcb_xv_adaptor_info_next")]
		internal void _next ();

		public inline unowned AdaptorInfo?
		next_value ()
		{
			if (((_AdaptorInfoIterator)this).rem > 0)
			{
				unowned AdaptorInfo? d = ((_AdaptorInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_adaptor_info_t", has_type_id = false)]
	public struct AdaptorInfo {
		public Port base_id;
		public uint16 name_size;
		public uint16 num_ports;
		public uint16 num_formats;
		public Type type;
		[CCode (cname = "xcb_xv_adaptor_info_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_xv_adaptor_info_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
		public int formats_length {
			[CCode (cname = "xcb_xv_adaptor_info_formats_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Format[] formats {
			[CCode (cname = "xcb_xv_adaptor_info_formats")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_encoding_info_iterator_t")]
	struct _EncodingInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned EncodingInfo? data;
	}

	[CCode (cname = "xcb_xv_encoding_info_iterator_t")]
	public struct EncodingInfoIterator
	{
		[CCode (cname = "xcb_xv_encoding_info_next")]
		internal void _next ();

		public inline unowned EncodingInfo?
		next_value ()
		{
			if (((_EncodingInfoIterator)this).rem > 0)
			{
				unowned EncodingInfo? d = ((_EncodingInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_encoding_info_t", has_type_id = false)]
	public struct EncodingInfo {
		public Encoding encoding;
		public uint16 name_size;
		public uint16 width;
		public uint16 height;
		public Rational rate;
		[CCode (cname = "xcb_xv_encoding_info_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_xv_encoding_info_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_image_iterator_t")]
	struct _ImageIterator
	{
		internal int rem;
		internal int index;
		internal unowned Image? data;
	}

	[CCode (cname = "xcb_xv_image_iterator_t")]
	public struct ImageIterator
	{
		[CCode (cname = "xcb_xv_image_next")]
		internal void _next ();

		public inline unowned Image?
		next_value ()
		{
			if (((_ImageIterator)this).rem > 0)
			{
				unowned Image? d = ((_ImageIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_image_t", has_type_id = false)]
	public struct Image {
		public uint32 id;
		public uint16 width;
		public uint16 height;
		public uint32 data_size;
		public uint32 num_planes;
		public int pitches_length {
			[CCode (cname = "xcb_xv_image_pitches_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] pitches {
			[CCode (cname = "xcb_xv_image_pitches")]
			get;
		}
		public int offsets_length {
			[CCode (cname = "xcb_xv_image_offsets_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] offsets {
			[CCode (cname = "xcb_xv_image_offsets")]
			get;
		}
		public int data_length {
			[CCode (cname = "xcb_xv_image_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_xv_image_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_attribute_info_iterator_t")]
	struct _AttributeInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned AttributeInfo? data;
	}

	[CCode (cname = "xcb_xv_attribute_info_iterator_t")]
	public struct AttributeInfoIterator
	{
		[CCode (cname = "xcb_xv_attribute_info_next")]
		internal void _next ();

		public inline unowned AttributeInfo?
		next_value ()
		{
			if (((_AttributeInfoIterator)this).rem > 0)
			{
				unowned AttributeInfo? d = ((_AttributeInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_attribute_info_t", has_type_id = false)]
	public struct AttributeInfo {
		public AttributeFlag flags;
		public int32 min;
		public int32 max;
		public uint32 size;
		[CCode (cname = "xcb_xv_attribute_info_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_xv_attribute_info_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_xv_image_format_info_iterator_t")]
	struct _ImageFormatInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned ImageFormatInfo? data;
	}

	[CCode (cname = "xcb_xv_image_format_info_iterator_t")]
	public struct ImageFormatInfoIterator
	{
		[CCode (cname = "xcb_xv_image_format_info_next")]
		internal void _next ();

		public inline unowned ImageFormatInfo?
		next_value ()
		{
			if (((_ImageFormatInfoIterator)this).rem > 0)
			{
				unowned ImageFormatInfo? d = ((_ImageFormatInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_xv_image_format_info_t", has_type_id = false)]
	public struct ImageFormatInfo {
		public uint32 id;
		public ImageFormatInfoType type;
		public uint8 byte_order;
		public uint8 guid[16];
		public uint8 bpp;
		public uint8 num_planes;
		public uint8 depth;
		public uint32 red_mask;
		public uint32 green_mask;
		public uint32 blue_mask;
		public ImageFormatInfoFormat format;
		public uint32 y_sample_bits;
		public uint32 u_sample_bits;
		public uint32 v_sample_bits;
		public uint32 vhorz_y_period;
		public uint32 vhorz_u_period;
		public uint32 vhorz_v_period;
		public uint32 vvert_y_period;
		public uint32 vvert_u_period;
		public uint32 vvert_v_period;
		public uint8 vcomp_order[32];
		public ScanlineOrder vscanline_order;
	}

	[Compact, CCode (cname = "xcb_xv_bad_port_error_t", has_type_id = false)]
	public class BadPortError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xv_bad_encoding_error_t", has_type_id = false)]
	public class BadEncodingError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xv_bad_control_error_t", has_type_id = false)]
	public class BadControlError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xv_video_notify_event_t", has_type_id = false)]
	public class VideoNotifyEvent : GenericEvent {
		public VideoNotifyReason reason;
		public Timestamp time;
		public Drawable drawable;
		public Port port;
	}

	[Compact, CCode (cname = "xcb_xv_port_notify_event_t", has_type_id = false)]
	public class PortNotifyEvent : GenericEvent {
		public Timestamp time;
		public Port port;
		public Atom attribute;
		public int32 value;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_XV_", has_type_id = false)]
	public enum EventType {
		VIDEO_NOTIFY,
		PORT_NOTIFY
	}
}

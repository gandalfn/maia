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
using Xcb.Render;

[CCode (cheader_filename="xcb/xcb.h,xcb/randr.h")]
namespace Xcb.RandR
{
	[CCode (cname = "xcb_randr_id")]
	public Xcb.Extension extension;

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_randr_set_screen_config", instance_pos = 1.1)]
		public SetScreenConfigCookie set_screen_config (Xcb.Connection connection, Timestamp timestamp, Timestamp config_timestamp, uint16 sizeID, Rotation rotation, uint16 rate);
		[CCode (cname = "xcb_randr_select_input", instance_pos = 1.1)]
		public VoidCookie select_input (Xcb.Connection connection, NotifyMask enable);
		[CCode (cname = "xcb_randr_select_input_checked", instance_pos = 1.1)]
		public VoidCookie select_input_checked (Xcb.Connection connection, NotifyMask enable);
		[CCode (cname = "xcb_randr_get_screen_info", instance_pos = 1.1)]
		public GetScreenInfoCookie get_screen_info (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_screen_size_range", instance_pos = 1.1)]
		public GetScreenSizeRangeCookie get_screen_size_range (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_set_screen_size", instance_pos = 1.1)]
		public VoidCookie set_screen_size (Xcb.Connection connection, uint16 width, uint16 height, uint32 mm_width, uint32 mm_height);
		[CCode (cname = "xcb_randr_set_screen_size_checked", instance_pos = 1.1)]
		public VoidCookie set_screen_size_checked (Xcb.Connection connection, uint16 width, uint16 height, uint32 mm_width, uint32 mm_height);
		[CCode (cname = "xcb_randr_get_screen_resources", instance_pos = 1.1)]
		public GetScreenResourcesCookie get_screen_resources (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_create_mode", instance_pos = 1.1)]
		public CreateModeCookie create_mode (Xcb.Connection connection, ModeInfo mode_info, [CCode (array_length_pos = 2.2)]char[] name);
		[CCode (cname = "xcb_randr_get_screen_resources_current", instance_pos = 1.1)]
		public GetScreenResourcesCurrentCookie get_screen_resources_current (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_output_primary", instance_pos = 1.1)]
		public GetOutputPrimaryCookie get_output_primary (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_randr_set_screen_config_reply_t", free_function = "free")]
	public class SetScreenConfigReply {
		public SetConfig status;
		public Timestamp new_timestamp;
		public Timestamp config_timestamp;
		public Window root;
		public uint16 subpixel_order;
	}

	[SimpleType, CCode (cname = "xcb_randr_set_screen_config_cookie_t")]
	public struct SetScreenConfigCookie : VoidCookie {
		[CCode (cname = "xcb_randr_set_screen_config_reply", instance_pos = 1.1)]
		public SetScreenConfigReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_screen_info_reply_t", free_function = "free")]
	public class GetScreenInfoReply {
		public Rotation rotations;
		public Window root;
		public Timestamp timestamp;
		public Timestamp config_timestamp;
		public uint16 nSizes;
		public uint16 sizeID;
		public Rotation rotation;
		public uint16 rate;
		public uint16 nInfo;
		public int sizes_length {
			[CCode (cname = "xcb_randr_get_screen_info_sizes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ScreenSize[] sizes {
			[CCode (cname = "xcb_randr_get_screen_info_sizes")]
			get;
		}
		public int rates_length {
			[CCode (cname = "xcb_randr_get_screen_info_rates_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned RefreshRates[] rates {
			[CCode (cname = "xcb_randr_get_screen_info_rates")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_screen_info_cookie_t")]
	public struct GetScreenInfoCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_screen_info_reply", instance_pos = 1.1)]
		public GetScreenInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_screen_size_range_reply_t", free_function = "free")]
	public class GetScreenSizeRangeReply {
		public uint16 min_width;
		public uint16 min_height;
		public uint16 max_width;
		public uint16 max_height;
	}

	[SimpleType, CCode (cname = "xcb_randr_get_screen_size_range_cookie_t")]
	public struct GetScreenSizeRangeCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_screen_size_range_reply", instance_pos = 1.1)]
		public GetScreenSizeRangeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_screen_resources_reply_t", free_function = "free")]
	public class GetScreenResourcesReply {
		public Timestamp timestamp;
		public Timestamp config_timestamp;
		public uint16 num_crtcs;
		public uint16 num_outputs;
		public uint16 num_modes;
		public uint16 names_len;
		public int crtcs_length {
			[CCode (cname = "xcb_randr_get_screen_resources_crtcs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Crtc[] crtcs {
			[CCode (cname = "xcb_randr_get_screen_resources_crtcs")]
			get;
		}
		public int outputs_length {
			[CCode (cname = "xcb_randr_get_screen_resources_outputs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Output[] outputs {
			[CCode (cname = "xcb_randr_get_screen_resources_outputs")]
			get;
		}
		public int modes_length {
			[CCode (cname = "xcb_randr_get_screen_resources_modes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ModeInfo[] modes {
			[CCode (cname = "xcb_randr_get_screen_resources_modes")]
			get;
		}
		public int names_length {
			[CCode (cname = "xcb_randr_get_screen_resources_names_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] names {
			[CCode (cname = "xcb_randr_get_screen_resources_names")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_screen_resources_cookie_t")]
	public struct GetScreenResourcesCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_screen_resources_reply", instance_pos = 1.1)]
		public GetScreenResourcesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_create_mode_reply_t", free_function = "free")]
	public class CreateModeReply {
		public Mode mode;
	}

	[SimpleType, CCode (cname = "xcb_randr_create_mode_cookie_t")]
	public struct CreateModeCookie : VoidCookie {
		[CCode (cname = "xcb_randr_create_mode_reply", instance_pos = 1.1)]
		public CreateModeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_screen_resources_current_reply_t", free_function = "free")]
	public class GetScreenResourcesCurrentReply {
		public Timestamp timestamp;
		public Timestamp config_timestamp;
		public uint16 num_crtcs;
		public uint16 num_outputs;
		public uint16 num_modes;
		public uint16 names_len;
		public int crtcs_length {
			[CCode (cname = "xcb_randr_get_screen_resources_current_crtcs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Crtc[] crtcs {
			[CCode (cname = "xcb_randr_get_screen_resources_current_crtcs")]
			get;
		}
		public int outputs_length {
			[CCode (cname = "xcb_randr_get_screen_resources_current_outputs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Output[] outputs {
			[CCode (cname = "xcb_randr_get_screen_resources_current_outputs")]
			get;
		}
		public int modes_length {
			[CCode (cname = "xcb_randr_get_screen_resources_current_modes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ModeInfo[] modes {
			[CCode (cname = "xcb_randr_get_screen_resources_current_modes")]
			get;
		}
		public int names_length {
			[CCode (cname = "xcb_randr_get_screen_resources_current_names_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] names {
			[CCode (cname = "xcb_randr_get_screen_resources_current_names")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_screen_resources_current_cookie_t")]
	public struct GetScreenResourcesCurrentCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_screen_resources_current_reply", instance_pos = 1.1)]
		public GetScreenResourcesCurrentReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_output_primary_reply_t", free_function = "free")]
	public class GetOutputPrimaryReply {
		public Output output;
	}

	[SimpleType, CCode (cname = "xcb_randr_get_output_primary_cookie_t")]
	public struct GetOutputPrimaryCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_output_primary_reply", instance_pos = 1.1)]
		public GetOutputPrimaryReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_randr_mode_iterator_t")]
	struct _ModeIterator
	{
		internal int rem;
		internal int index;
		internal unowned Mode? data;
	}

	[CCode (cname = "xcb_randr_mode_iterator_t")]
	public struct ModeIterator
	{
		[CCode (cname = "xcb_randr_mode_next")]
		internal void _next ();

		public inline unowned Mode?
		next_value ()
		{
			if (((_ModeIterator)this).rem > 0)
			{
				unowned Mode? d = ((_ModeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_mode_t", has_type_id = false)]
	public struct Mode : uint32 {
		[CCode (cname = "xcb_randr_destroy_mode", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_destroy_mode_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
	}

	[SimpleType, CCode (cname = "xcb_randr_crtc_iterator_t")]
	struct _CrtcIterator
	{
		internal int rem;
		internal int index;
		internal unowned Crtc? data;
	}

	[CCode (cname = "xcb_randr_crtc_iterator_t")]
	public struct CrtcIterator
	{
		[CCode (cname = "xcb_randr_crtc_next")]
		internal void _next ();

		public inline unowned Crtc?
		next_value ()
		{
			if (((_CrtcIterator)this).rem > 0)
			{
				unowned Crtc? d = ((_CrtcIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_crtc_t", has_type_id = false)]
	public struct Crtc : uint32 {
		[CCode (cname = "xcb_randr_get_crtc_info", instance_pos = 1.1)]
		public GetCrtcInfoCookie get_info (Xcb.Connection connection, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_set_crtc_config", instance_pos = 1.1)]
		public SetCrtcConfigCookie set_config (Xcb.Connection connection, Timestamp timestamp, Timestamp config_timestamp, int16 x, int16 y, Mode mode, Rotation rotation, [CCode (array_length_pos = 7.7)]Output[] outputs);
		[CCode (cname = "xcb_randr_get_crtc_gamma_size", instance_pos = 1.1)]
		public GetCrtcGammaSizeCookie get_gamma_size (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_crtc_gamma", instance_pos = 1.1)]
		public GetCrtcGammaCookie get_gamma (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_set_crtc_gamma", instance_pos = 1.1)]
		public VoidCookie set_gamma (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint16[] red, [CCode (array_length_pos = 1.2)]uint16[] green, [CCode (array_length_pos = 1.2)]uint16[] blue);
		[CCode (cname = "xcb_randr_set_crtc_gamma_checked", instance_pos = 1.1)]
		public VoidCookie set_gamma_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint16[] red, [CCode (array_length_pos = 1.2)]uint16[] green, [CCode (array_length_pos = 1.2)]uint16[] blue);
		[CCode (cname = "xcb_randr_set_crtc_transform", instance_pos = 1.1)]
		public VoidCookie set_transform (Xcb.Connection connection, Transform transform, [CCode (array_length_pos = 2.3)]char[] filter_name, [CCode (array_length_pos = 4.4)]Fixed[] filter_params);
		[CCode (cname = "xcb_randr_set_crtc_transform_checked", instance_pos = 1.1)]
		public VoidCookie set_transform_checked (Xcb.Connection connection, Transform transform, [CCode (array_length_pos = 2.3)]char[] filter_name, [CCode (array_length_pos = 4.4)]Fixed[] filter_params);
		[CCode (cname = "xcb_randr_get_crtc_transform", instance_pos = 1.1)]
		public GetCrtcTransformCookie get_transform (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_panning", instance_pos = 1.1)]
		public GetPanningCookie get_panning (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_set_panning", instance_pos = 1.1)]
		public SetPanningCookie set_panning (Xcb.Connection connection, Timestamp timestamp, uint16 left, uint16 top, uint16 width, uint16 height, uint16 track_left, uint16 track_top, uint16 track_width, uint16 track_height, int16 border_left, int16 border_top, int16 border_right, int16 border_bottom);
	}

	[Compact, CCode (cname = "xcb_randr_get_crtc_info_reply_t", free_function = "free")]
	public class GetCrtcInfoReply {
		public SetConfig status;
		public Timestamp timestamp;
		public int16 x;
		public int16 y;
		public uint16 width;
		public uint16 height;
		public Mode mode;
		public Rotation rotation;
		public Rotation rotations;
		public uint16 num_outputs;
		public uint16 num_possible_outputs;
		public int outputs_length {
			[CCode (cname = "xcb_randr_get_crtc_info_outputs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Output[] outputs {
			[CCode (cname = "xcb_randr_get_crtc_info_outputs")]
			get;
		}
		public int possible_length {
			[CCode (cname = "xcb_randr_get_crtc_info_possible_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Output[] possible {
			[CCode (cname = "xcb_randr_get_crtc_info_possible")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_crtc_info_cookie_t")]
	public struct GetCrtcInfoCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_crtc_info_reply", instance_pos = 1.1)]
		public GetCrtcInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_set_crtc_config_reply_t", free_function = "free")]
	public class SetCrtcConfigReply {
		public SetConfig status;
		public Timestamp timestamp;
	}

	[SimpleType, CCode (cname = "xcb_randr_set_crtc_config_cookie_t")]
	public struct SetCrtcConfigCookie : VoidCookie {
		[CCode (cname = "xcb_randr_set_crtc_config_reply", instance_pos = 1.1)]
		public SetCrtcConfigReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_crtc_gamma_size_reply_t", free_function = "free")]
	public class GetCrtcGammaSizeReply {
		public uint16 size;
	}

	[SimpleType, CCode (cname = "xcb_randr_get_crtc_gamma_size_cookie_t")]
	public struct GetCrtcGammaSizeCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_crtc_gamma_size_reply", instance_pos = 1.1)]
		public GetCrtcGammaSizeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_crtc_gamma_reply_t", free_function = "free")]
	public class GetCrtcGammaReply {
		public uint16 size;
		public int red_length {
			[CCode (cname = "xcb_randr_get_crtc_gamma_red_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] red {
			[CCode (cname = "xcb_randr_get_crtc_gamma_red")]
			get;
		}
		public int green_length {
			[CCode (cname = "xcb_randr_get_crtc_gamma_green_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] green {
			[CCode (cname = "xcb_randr_get_crtc_gamma_green")]
			get;
		}
		public int blue_length {
			[CCode (cname = "xcb_randr_get_crtc_gamma_blue_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] blue {
			[CCode (cname = "xcb_randr_get_crtc_gamma_blue")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_crtc_gamma_cookie_t")]
	public struct GetCrtcGammaCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_crtc_gamma_reply", instance_pos = 1.1)]
		public GetCrtcGammaReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_crtc_transform_reply_t", free_function = "free")]
	public class GetCrtcTransformReply {
		public Transform pending_transform;
		public bool has_transforms;
		public Transform current_transform;
		public uint16 pending_len;
		public uint16 pending_nparams;
		public uint16 current_len;
		public uint16 current_nparams;
		[CCode (cname = "xcb_randr_get_crtc_transform_pending_filter_name_length")]
		int _pending_filter_name_length ();
		[CCode (cname = "xcb_randr_get_crtc_transform_pending_filter_name", array_length = false)]
		unowned char[] _pending_filter_name ();
		public string pending_filter_name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_pending_filter_name (), _pending_filter_name_length ());
				return ret.str;
			}
		}
		public int pending_params_length {
			[CCode (cname = "xcb_randr_get_crtc_transform_pending_params_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Fixed[] pending_params {
			[CCode (cname = "xcb_randr_get_crtc_transform_pending_params")]
			get;
		}
		[CCode (cname = "xcb_randr_get_crtc_transform_current_filter_name_length")]
		int _current_filter_name_length ();
		[CCode (cname = "xcb_randr_get_crtc_transform_current_filter_name", array_length = false)]
		unowned char[] _current_filter_name ();
		public string current_filter_name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_current_filter_name (), _current_filter_name_length ());
				return ret.str;
			}
		}
		public int current_params_length {
			[CCode (cname = "xcb_randr_get_crtc_transform_current_params_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Fixed[] current_params {
			[CCode (cname = "xcb_randr_get_crtc_transform_current_params")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_crtc_transform_cookie_t")]
	public struct GetCrtcTransformCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_crtc_transform_reply", instance_pos = 1.1)]
		public GetCrtcTransformReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_panning_reply_t", free_function = "free")]
	public class GetPanningReply {
		public SetConfig status;
		public Timestamp timestamp;
		public uint16 left;
		public uint16 top;
		public uint16 width;
		public uint16 height;
		public uint16 track_left;
		public uint16 track_top;
		public uint16 track_width;
		public uint16 track_height;
		public int16 border_left;
		public int16 border_top;
		public int16 border_right;
		public int16 border_bottom;
	}

	[SimpleType, CCode (cname = "xcb_randr_get_panning_cookie_t")]
	public struct GetPanningCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_panning_reply", instance_pos = 1.1)]
		public GetPanningReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_set_panning_reply_t", free_function = "free")]
	public class SetPanningReply {
		public SetConfig status;
		public Timestamp timestamp;
	}

	[SimpleType, CCode (cname = "xcb_randr_set_panning_cookie_t")]
	public struct SetPanningCookie : VoidCookie {
		[CCode (cname = "xcb_randr_set_panning_reply", instance_pos = 1.1)]
		public SetPanningReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_randr_output_iterator_t")]
	struct _OutputIterator
	{
		internal int rem;
		internal int index;
		internal unowned Output? data;
	}

	[CCode (cname = "xcb_randr_output_iterator_t")]
	public struct OutputIterator
	{
		[CCode (cname = "xcb_randr_output_next")]
		internal void _next ();

		public inline unowned Output?
		next_value ()
		{
			if (((_OutputIterator)this).rem > 0)
			{
				unowned Output? d = ((_OutputIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_output_t", has_type_id = false)]
	public struct Output : uint32 {
		[CCode (cname = "xcb_randr_get_output_info", instance_pos = 1.1)]
		public GetOutputInfoCookie get_info (Xcb.Connection connection, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_list_output_properties", instance_pos = 1.1)]
		public ListOutputPropertiesCookie list_properties (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_query_output_property", instance_pos = 1.1)]
		public QueryOutputPropertyCookie query_property (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_configure_output_property", instance_pos = 1.1)]
		public VoidCookie configure_property (Xcb.Connection connection, Atom property, bool pending, bool range, [CCode (array_length_pos = 4.4)]int32[] values);
		[CCode (cname = "xcb_randr_configure_output_property_checked", instance_pos = 1.1)]
		public VoidCookie configure_property_checked (Xcb.Connection connection, Atom property, bool pending, bool range, [CCode (array_length_pos = 4.4)]int32[] values);
		[CCode (cname = "xcb_randr_change_output_property", instance_pos = 1.1)]
		public VoidCookie change_property (Xcb.Connection connection, Atom property, Atom type, uint8 format, uint8 mode, [CCode (array_length_pos = 5.6)]void[] data);
		[CCode (cname = "xcb_randr_change_output_property_checked", instance_pos = 1.1)]
		public VoidCookie change_property_checked (Xcb.Connection connection, Atom property, Atom type, uint8 format, uint8 mode, [CCode (array_length_pos = 5.6)]void[] data);
		[CCode (cname = "xcb_randr_delete_output_property", instance_pos = 1.1)]
		public VoidCookie delete_property (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_delete_output_property_checked", instance_pos = 1.1)]
		public VoidCookie delete_property_checked (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_get_output_property", instance_pos = 1.1)]
		public GetOutputPropertyCookie get_property (Xcb.Connection connection, Atom property, Atom type, uint32 long_offset, uint32 long_length, bool delete, bool pending);
		[CCode (cname = "xcb_randr_add_output_mode", instance_pos = 1.1)]
		public VoidCookie add_mode (Xcb.Connection connection, Mode mode);
		[CCode (cname = "xcb_randr_add_output_mode_checked", instance_pos = 1.1)]
		public VoidCookie add_mode_checked (Xcb.Connection connection, Mode mode);
		[CCode (cname = "xcb_randr_delete_output_mode", instance_pos = 1.1)]
		public VoidCookie delete_mode (Xcb.Connection connection, Mode mode);
		[CCode (cname = "xcb_randr_delete_output_mode_checked", instance_pos = 1.1)]
		public VoidCookie delete_mode_checked (Xcb.Connection connection, Mode mode);
		[CCode (cname = "xcb_randr_set_output_primary", instance_pos = 2.2)]
		public VoidCookie set_primary (Xcb.Connection connection, Window window);
		[CCode (cname = "xcb_randr_set_output_primary_checked", instance_pos = 2.2)]
		public VoidCookie set_primary_checked (Xcb.Connection connection, Window window);
	}

	[Compact, CCode (cname = "xcb_randr_get_output_info_reply_t", free_function = "free")]
	public class GetOutputInfoReply {
		public SetConfig status;
		public Timestamp timestamp;
		public Crtc crtc;
		public uint32 mm_width;
		public uint32 mm_height;
		public ConnectionType connection;
		public uint8 subpixel_order;
		public uint16 num_crtcs;
		public uint16 num_modes;
		public uint16 num_preferred;
		public uint16 num_clones;
		public uint16 name_len;
		public int crtcs_length {
			[CCode (cname = "xcb_randr_get_output_info_crtcs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Crtc[] crtcs {
			[CCode (cname = "xcb_randr_get_output_info_crtcs")]
			get;
		}
		public int modes_length {
			[CCode (cname = "xcb_randr_get_output_info_modes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Mode[] modes {
			[CCode (cname = "xcb_randr_get_output_info_modes")]
			get;
		}
		public int clones_length {
			[CCode (cname = "xcb_randr_get_output_info_clones_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Output[] clones {
			[CCode (cname = "xcb_randr_get_output_info_clones")]
			get;
		}
		[CCode (cname = "xcb_randr_get_output_info_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_randr_get_output_info_name", array_length = false)]
		unowned uint8[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_output_info_cookie_t")]
	public struct GetOutputInfoCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_output_info_reply", instance_pos = 1.1)]
		public GetOutputInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_list_output_properties_reply_t", free_function = "free")]
	public class ListOutputPropertiesReply {
		public uint16 num_atoms;
		[CCode (cname = "xcb_randr_list_output_properties_atoms_iterator")]
		_AtomIterator _iterator ();
		public AtomIterator iterator () {
			return (AtomIterator) _iterator ();
		}
		public int atoms_length {
			[CCode (cname = "xcb_randr_list_output_properties_atoms_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Atom[] atoms {
			[CCode (cname = "xcb_randr_list_output_properties_atoms")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_list_output_properties_cookie_t")]
	public struct ListOutputPropertiesCookie : VoidCookie {
		[CCode (cname = "xcb_randr_list_output_properties_reply", instance_pos = 1.1)]
		public ListOutputPropertiesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_query_output_property_reply_t", free_function = "free")]
	public class QueryOutputPropertyReply {
		public bool pending;
		public bool range;
		public bool immutable;
		public int valid_values_length {
			[CCode (cname = "xcb_randr_query_output_property_valid_values_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] valid_values {
			[CCode (cname = "xcb_randr_query_output_property_valid_values")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_query_output_property_cookie_t")]
	public struct QueryOutputPropertyCookie : VoidCookie {
		[CCode (cname = "xcb_randr_query_output_property_reply", instance_pos = 1.1)]
		public QueryOutputPropertyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_output_property_reply_t", free_function = "free")]
	public class GetOutputPropertyReply {
		public uint8 format;
		public Atom type;
		public uint32 bytes_after;
		public uint32 num_items;
		public int data_length {
			[CCode (cname = "xcb_randr_get_output_property_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_randr_get_output_property_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_output_property_cookie_t")]
	public struct GetOutputPropertyCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_output_property_reply", instance_pos = 1.1)]
		public GetOutputPropertyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_bad_output_error_t", has_type_id = false)]
	public class BadOutputError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_randr_bad_crtc_error_t", has_type_id = false)]
	public class BadCrtcError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_randr_bad_mode_error_t", has_type_id = false)]
	public class BadModeError : Xcb.GenericError {
	}

	[Flags, CCode (cname = "xcb_randr_rotation_t", cprefix =  "XCB_RANDR_ROTATION_", has_type_id = false)]
	public enum Rotation {
		ROTATE_0,
		ROTATE_90,
		ROTATE_180,
		ROTATE_270,
		REFLECT_X,
		REFLECT_Y
	}

	[SimpleType, CCode (cname = "xcb_randr_screen_size_iterator_t")]
	struct _ScreenSizeIterator
	{
		internal int rem;
		internal int index;
		internal unowned ScreenSize? data;
	}

	[CCode (cname = "xcb_randr_screen_size_iterator_t")]
	public struct ScreenSizeIterator
	{
		[CCode (cname = "xcb_randr_screen_size_next")]
		internal void _next ();

		public inline unowned ScreenSize?
		next_value ()
		{
			if (((_ScreenSizeIterator)this).rem > 0)
			{
				unowned ScreenSize? d = ((_ScreenSizeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_screen_size_t", has_type_id = false)]
	public struct ScreenSize {
		public uint16 width;
		public uint16 height;
		public uint16 mwidth;
		public uint16 mheight;
	}

	[SimpleType, CCode (cname = "xcb_randr_refresh_rates_iterator_t")]
	struct _RefreshRatesIterator
	{
		internal int rem;
		internal int index;
		internal unowned RefreshRates? data;
	}

	[CCode (cname = "xcb_randr_refresh_rates_iterator_t")]
	public struct RefreshRatesIterator
	{
		[CCode (cname = "xcb_randr_refresh_rates_next")]
		internal void _next ();

		public inline unowned RefreshRates?
		next_value ()
		{
			if (((_RefreshRatesIterator)this).rem > 0)
			{
				unowned RefreshRates? d = ((_RefreshRatesIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_refresh_rates_t", has_type_id = false)]
	public struct RefreshRates {
		public uint16 nRates;
		public int rates_length {
			[CCode (cname = "xcb_randr_refresh_rates_rates_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] rates {
			[CCode (cname = "xcb_randr_refresh_rates_rates")]
			get;
		}
	}

	[CCode (cname = "xcb_randr_set_config_t", cprefix =  "XCB_RANDR_SET_CONFIG_", has_type_id = false)]
	public enum SetConfig {
		SUCCESS,
		INVALID_CONFIG_TIME,
		INVALID_TIME,
		FAILED
	}

	[Flags, CCode (cname = "xcb_randr_notify_mask_t", cprefix =  "XCB_RANDR_NOTIFY_MASK_", has_type_id = false)]
	public enum NotifyMask {
		SCREEN_CHANGE,
		CRTC_CHANGE,
		OUTPUT_CHANGE,
		OUTPUT_PROPERTY
	}

	[Flags, CCode (cname = "xcb_randr_mode_flag_t", cprefix =  "XCB_RANDR_MODE_FLAG_", has_type_id = false)]
	public enum ModeFlag {
		HSYNC_POSITIVE,
		HSYNC_NEGATIVE,
		VSYNC_POSITIVE,
		VSYNC_NEGATIVE,
		INTERLACE,
		DOUBLE_SCAN,
		CSYNC,
		CSYNC_POSITIVE,
		CSYNC_NEGATIVE,
		HSKEW_PRESENT,
		BCAST,
		PIXEL_MULTIPLEX,
		DOUBLE_CLOCK,
		HALVE_CLOCK
	}

	[SimpleType, CCode (cname = "xcb_randr_mode_info_iterator_t")]
	struct _ModeInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned ModeInfo? data;
	}

	[CCode (cname = "xcb_randr_mode_info_iterator_t")]
	public struct ModeInfoIterator
	{
		[CCode (cname = "xcb_randr_mode_info_next")]
		internal void _next ();

		public inline unowned ModeInfo?
		next_value ()
		{
			if (((_ModeInfoIterator)this).rem > 0)
			{
				unowned ModeInfo? d = ((_ModeInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_mode_info_t", has_type_id = false)]
	public struct ModeInfo {
		public uint32 id;
		public uint16 width;
		public uint16 height;
		public uint32 dot_clock;
		public uint16 hsync_start;
		public uint16 hsync_end;
		public uint16 htotal;
		public uint16 hskew;
		public uint16 vsync_start;
		public uint16 vsync_end;
		public uint16 vtotal;
		public uint16 name_len;
		public ModeFlag mode_flags;
	}

	[CCode (cname = "xcb_randr_connection_t", cprefix =  "XCB_RANDR_CONNECTION_", has_type_id = false)]
	public enum ConnectionType {
		CONNECTED,
		DISCONNECTED,
		UNKNOWN
	}

	[Compact, CCode (cname = "xcb_randr_screen_change_notify_event_t", has_type_id = false)]
	public class ScreenChangeNotifyEvent : GenericEvent {
		public Rotation rotation;
		public Timestamp timestamp;
		public Timestamp config_timestamp;
		public Window root;
		public Window request_window;
		public uint16 sizeID;
		public uint16 subpixel_order;
		public uint16 width;
		public uint16 height;
		public uint16 mwidth;
		public uint16 mheight;
	}

	[CCode (cname = "xcb_randr_notify_t", cprefix =  "XCB_RANDR_NOTIFY_", has_type_id = false)]
	public enum Notify {
		CRTC_CHANGE,
		OUTPUT_CHANGE,
		OUTPUT_PROPERTY
	}

	[SimpleType, CCode (cname = "xcb_randr_crtc_change_iterator_t")]
	struct _CrtcChangeIterator
	{
		internal int rem;
		internal int index;
		internal unowned CrtcChange? data;
	}

	[CCode (cname = "xcb_randr_crtc_change_iterator_t")]
	public struct CrtcChangeIterator
	{
		[CCode (cname = "xcb_randr_crtc_change_next")]
		internal void _next ();

		public inline unowned CrtcChange?
		next_value ()
		{
			if (((_CrtcChangeIterator)this).rem > 0)
			{
				unowned CrtcChange? d = ((_CrtcChangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_crtc_change_t", has_type_id = false)]
	public struct CrtcChange {
		public Timestamp timestamp;
		public Window window;
		public Crtc crtc;
		public Mode mode;
		public Rotation rotation;
		public int16 x;
		public int16 y;
		public uint16 width;
		public uint16 height;
	}

	[SimpleType, CCode (cname = "xcb_randr_output_change_iterator_t")]
	struct _OutputChangeIterator
	{
		internal int rem;
		internal int index;
		internal unowned OutputChange? data;
	}

	[CCode (cname = "xcb_randr_output_change_iterator_t")]
	public struct OutputChangeIterator
	{
		[CCode (cname = "xcb_randr_output_change_next")]
		internal void _next ();

		public inline unowned OutputChange?
		next_value ()
		{
			if (((_OutputChangeIterator)this).rem > 0)
			{
				unowned OutputChange? d = ((_OutputChangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_output_change_t", has_type_id = false)]
	public struct OutputChange {
		public Timestamp timestamp;
		public Timestamp config_timestamp;
		public Window window;
		public Output output;
		public Crtc crtc;
		public Mode mode;
		public Rotation rotation;
		public ConnectionType connection;
		public uint8 subpixel_order;
	}

	[SimpleType, CCode (cname = "xcb_randr_output_property_iterator_t")]
	struct _OutputPropertyIterator
	{
		internal int rem;
		internal int index;
		internal unowned OutputProperty? data;
	}

	[CCode (cname = "xcb_randr_output_property_iterator_t")]
	public struct OutputPropertyIterator
	{
		[CCode (cname = "xcb_randr_output_property_next")]
		internal void _next ();

		public inline unowned OutputProperty?
		next_value ()
		{
			if (((_OutputPropertyIterator)this).rem > 0)
			{
				unowned OutputProperty? d = ((_OutputPropertyIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_output_property_t", has_type_id = false)]
	public struct OutputProperty {
		public Window window;
		public Output output;
		public Atom atom;
		public Timestamp timestamp;
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_randr_notify_data_t", has_type_id = false)]
	public struct NotifyData {
		public CrtcChange cc;
		public OutputChange oc;
		public OutputProperty op;
	}

	[Compact, CCode (cname = "xcb_randr_notify_event_t", has_type_id = false)]
	public class NotifyEvent : GenericEvent {
		public Notify subCode;
		public NotifyData u;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_RANDR_", has_type_id = false)]
	public enum EventType {
		SCREEN_CHANGE_NOTIFY,
		NOTIFY
	}
}

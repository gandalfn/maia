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
		public CreateModeCookie create_mode (Xcb.Connection connection, ModeInfo mode_info, [CCode (array_length_pos = 2.2)]char[]? name);
		[CCode (cname = "xcb_randr_get_screen_resources_current", instance_pos = 1.1)]
		public GetScreenResourcesCurrentCookie get_screen_resources_current (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_output_primary", instance_pos = 1.1)]
		public GetOutputPrimaryCookie get_output_primary (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_providers", instance_pos = 1.1)]
		public GetProvidersCookie get_providers (Xcb.Connection connection);
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
		[CCode (cname = "xcb_randr_get_screen_info_rates_iterator")]
		_RefreshRatesIterator _iterator ();
		public RefreshRatesIterator iterator () {
			return (RefreshRatesIterator) _iterator ();
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
		[CCode (cname = "xcb_randr_get_screen_resources_modes_iterator")]
		_ModeInfoIterator _iterator ();
		public ModeInfoIterator iterator () {
			return (ModeInfoIterator) _iterator ();
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
		[CCode (cname = "xcb_randr_get_screen_resources_names_length")]
		int _names_length ();
		[CCode (cname = "xcb_randr_get_screen_resources_names", array_length = false)]
		unowned uint8[] _names ();
		public string[] names {
			owned get {
				string[] ret = {};
				int pos = 0;
				for (int cpt = 0; cpt < _names_length (); ++cpt) {
					(string)((char*)_names () + pos);
					pos += ret[cpt].length + 1;
				}
				return ret;
			}
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
		[CCode (cname = "xcb_randr_get_screen_resources_current_modes_iterator")]
		_ModeInfoIterator _iterator ();
		public ModeInfoIterator iterator () {
			return (ModeInfoIterator) _iterator ();
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
		[CCode (cname = "xcb_randr_get_screen_resources_current_names_length")]
		int _names_length ();
		[CCode (cname = "xcb_randr_get_screen_resources_current_names", array_length = false)]
		unowned uint8[] _names ();
		public string[] names {
			owned get {
				string[] ret = {};
				int pos = 0;
				for (int cpt = 0; cpt < _names_length (); ++cpt) {
					(string)((char*)_names () + pos);
					pos += ret[cpt].length + 1;
				}
				return ret;
			}
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

	[Compact, CCode (cname = "xcb_randr_get_providers_reply_t", free_function = "free")]
	public class GetProvidersReply {
		public Timestamp timestamp;
		public uint16 num_providers;
		[CCode (cname = "xcb_randr_get_providers_providers_iterator")]
		_ProviderIterator _iterator ();
		public ProviderIterator iterator () {
			return (ProviderIterator) _iterator ();
		}
		public int providers_length {
			[CCode (cname = "xcb_randr_get_providers_providers_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Provider[] providers {
			[CCode (cname = "xcb_randr_get_providers_providers")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_providers_cookie_t")]
	public struct GetProvidersCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_providers_reply", instance_pos = 1.1)]
		public GetProvidersReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_randr_mode_iterator_t")]
	struct _ModeIterator
	{
		int rem;
		int index;
		unowned Mode? data;
	}

	[CCode (cname = "xcb_randr_mode_iterator_t")]
	public struct ModeIterator
	{
		[CCode (cname = "xcb_randr_mode_next")]
		void _next ();

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
		int rem;
		int index;
		unowned Crtc? data;
	}

	[CCode (cname = "xcb_randr_crtc_iterator_t")]
	public struct CrtcIterator
	{
		[CCode (cname = "xcb_randr_crtc_next")]
		void _next ();

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
		public SetCrtcConfigCookie set_config (Xcb.Connection connection, Timestamp timestamp, Timestamp config_timestamp, int16 x, int16 y, Mode mode, Rotation rotation, [CCode (array_length_pos = 7.7)]Output[]? outputs);
		[CCode (cname = "xcb_randr_get_crtc_gamma_size", instance_pos = 1.1)]
		public GetCrtcGammaSizeCookie get_gamma_size (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_get_crtc_gamma", instance_pos = 1.1)]
		public GetCrtcGammaCookie get_gamma (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_set_crtc_gamma", instance_pos = 1.1)]
		public VoidCookie set_gamma (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint16[]? red, [CCode (array_length_pos = 1.2)]uint16[]? green, [CCode (array_length_pos = 1.2)]uint16[]? blue);
		[CCode (cname = "xcb_randr_set_crtc_gamma_checked", instance_pos = 1.1)]
		public VoidCookie set_gamma_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint16[]? red, [CCode (array_length_pos = 1.2)]uint16[]? green, [CCode (array_length_pos = 1.2)]uint16[]? blue);
		[CCode (cname = "xcb_randr_set_crtc_transform", instance_pos = 1.1)]
		public VoidCookie set_transform (Xcb.Connection connection, Transform transform, [CCode (array_length_pos = 2.3)]char[]? filter_name, [CCode (array_length_pos = 4.4)]Fixed[]? filter_params);
		[CCode (cname = "xcb_randr_set_crtc_transform_checked", instance_pos = 1.1)]
		public VoidCookie set_transform_checked (Xcb.Connection connection, Transform transform, [CCode (array_length_pos = 2.3)]char[]? filter_name, [CCode (array_length_pos = 4.4)]Fixed[]? filter_params);
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
		[CCode (cname = "xcb_randr_get_crtc_info_possible_iterator")]
		_OutputIterator _iterator ();
		public OutputIterator iterator () {
			return (OutputIterator) _iterator ();
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
		int rem;
		int index;
		unowned Output? data;
	}

	[CCode (cname = "xcb_randr_output_iterator_t")]
	public struct OutputIterator
	{
		[CCode (cname = "xcb_randr_output_next")]
		void _next ();

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
		public VoidCookie configure_property (Xcb.Connection connection, Atom property, bool pending, bool range, [CCode (array_length_pos = 4.4)]int32[]? values);
		[CCode (cname = "xcb_randr_configure_output_property_checked", instance_pos = 1.1)]
		public VoidCookie configure_property_checked (Xcb.Connection connection, Atom property, bool pending, bool range, [CCode (array_length_pos = 4.4)]int32[]? values);
		[CCode (cname = "xcb_randr_change_output_property", instance_pos = 1.1)]
		public VoidCookie change_property (Xcb.Connection connection, Atom property, Atom type, uint8 format, uint8 mode, [CCode (array_length_pos = 5.6)]void[]? data);
		[CCode (cname = "xcb_randr_change_output_property_checked", instance_pos = 1.1)]
		public VoidCookie change_property_checked (Xcb.Connection connection, Atom property, Atom type, uint8 format, uint8 mode, [CCode (array_length_pos = 5.6)]void[]? data);
		[CCode (cname = "xcb_randr_delete_output_property", instance_pos = 1.1)]
		public VoidCookie delete_property (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_delete_output_property_checked", instance_pos = 1.1)]
		public VoidCookie delete_property_checked (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_get_output_property", instance_pos = 1.1)]
		public GetOutputPropertyCookie get_property (Xcb.Connection connection, Atom property, Atom type, uint32 long_offset, uint32 long_length, bool _delete, bool pending);
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
		[CCode (cname = "xcb_randr_get_output_info_clones_iterator")]
		_OutputIterator _iterator ();
		public OutputIterator iterator () {
			return (OutputIterator) _iterator ();
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

	[SimpleType, CCode (cname = "xcb_randr_provider_iterator_t")]
	struct _ProviderIterator
	{
		int rem;
		int index;
		unowned Provider? data;
	}

	[CCode (cname = "xcb_randr_provider_iterator_t")]
	public struct ProviderIterator
	{
		[CCode (cname = "xcb_randr_provider_next")]
		void _next ();

		public inline unowned Provider?
		next_value ()
		{
			if (((_ProviderIterator)this).rem > 0)
			{
				unowned Provider? d = ((_ProviderIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_randr_provider_t", has_type_id = false)]
	public struct Provider : uint32 {
		[CCode (cname = "xcb_randr_get_provider_info", instance_pos = 1.1)]
		public GetProviderInfoCookie get_info (Xcb.Connection connection, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_set_provider_offload_sink", instance_pos = 1.1)]
		public VoidCookie set_offload_sink (Xcb.Connection connection, Provider sink_provider, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_set_provider_offload_sink_checked", instance_pos = 1.1)]
		public VoidCookie set_offload_sink_checked (Xcb.Connection connection, Provider sink_provider, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_set_provider_output_source", instance_pos = 1.1)]
		public VoidCookie set_output_source (Xcb.Connection connection, Provider source_provider, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_set_provider_output_source_checked", instance_pos = 1.1)]
		public VoidCookie set_output_source_checked (Xcb.Connection connection, Provider source_provider, Timestamp config_timestamp);
		[CCode (cname = "xcb_randr_list_provider_properties", instance_pos = 1.1)]
		public ListProviderPropertiesCookie list_properties (Xcb.Connection connection);
		[CCode (cname = "xcb_randr_query_provider_property", instance_pos = 1.1)]
		public QueryProviderPropertyCookie query_property (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_configure_provider_property", instance_pos = 1.1)]
		public VoidCookie configure_property (Xcb.Connection connection, Atom property, bool pending, bool range, [CCode (array_length_pos = 4.4)]int32[]? values);
		[CCode (cname = "xcb_randr_configure_provider_property_checked", instance_pos = 1.1)]
		public VoidCookie configure_property_checked (Xcb.Connection connection, Atom property, bool pending, bool range, [CCode (array_length_pos = 4.4)]int32[]? values);
		[CCode (cname = "xcb_randr_change_provider_property", instance_pos = 1.1)]
		public VoidCookie change_property (Xcb.Connection connection, Atom property, Atom type, uint8 format, uint8 mode, [CCode (array_length_pos = 5.6)]void[]? data);
		[CCode (cname = "xcb_randr_change_provider_property_checked", instance_pos = 1.1)]
		public VoidCookie change_property_checked (Xcb.Connection connection, Atom property, Atom type, uint8 format, uint8 mode, [CCode (array_length_pos = 5.6)]void[]? data);
		[CCode (cname = "xcb_randr_delete_provider_property", instance_pos = 1.1)]
		public VoidCookie delete_property (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_delete_provider_property_checked", instance_pos = 1.1)]
		public VoidCookie delete_property_checked (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_randr_get_provider_property", instance_pos = 1.1)]
		public GetProviderPropertyCookie get_property (Xcb.Connection connection, Atom property, Atom type, uint32 long_offset, uint32 long_length, bool _delete, bool pending);
	}

	[Compact, CCode (cname = "xcb_randr_get_provider_info_reply_t", free_function = "free")]
	public class GetProviderInfoReply {
		public uint8 status;
		public Timestamp timestamp;
		public ProviderCapability capabilities;
		public uint16 num_crtcs;
		public uint16 num_outputs;
		public uint16 num_associated_providers;
		public uint16 name_len;
		public int crtcs_length {
			[CCode (cname = "xcb_randr_get_provider_info_crtcs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Crtc[] crtcs {
			[CCode (cname = "xcb_randr_get_provider_info_crtcs")]
			get;
		}
		public int outputs_length {
			[CCode (cname = "xcb_randr_get_provider_info_outputs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Output[] outputs {
			[CCode (cname = "xcb_randr_get_provider_info_outputs")]
			get;
		}
		public int associated_providers_length {
			[CCode (cname = "xcb_randr_get_provider_info_associated_providers_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Provider[] associated_providers {
			[CCode (cname = "xcb_randr_get_provider_info_associated_providers")]
			get;
		}
		public int associated_capability_length {
			[CCode (cname = "xcb_randr_get_provider_info_associated_capability_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] associated_capability {
			[CCode (cname = "xcb_randr_get_provider_info_associated_capability")]
			get;
		}
		[CCode (cname = "xcb_randr_get_provider_info_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_randr_get_provider_info_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_provider_info_cookie_t")]
	public struct GetProviderInfoCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_provider_info_reply", instance_pos = 1.1)]
		public GetProviderInfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_list_provider_properties_reply_t", free_function = "free")]
	public class ListProviderPropertiesReply {
		public uint16 num_atoms;
		[CCode (cname = "xcb_randr_list_provider_properties_atoms_iterator")]
		_AtomIterator _iterator ();
		public AtomIterator iterator () {
			return (AtomIterator) _iterator ();
		}
		public int atoms_length {
			[CCode (cname = "xcb_randr_list_provider_properties_atoms_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Atom[] atoms {
			[CCode (cname = "xcb_randr_list_provider_properties_atoms")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_list_provider_properties_cookie_t")]
	public struct ListProviderPropertiesCookie : VoidCookie {
		[CCode (cname = "xcb_randr_list_provider_properties_reply", instance_pos = 1.1)]
		public ListProviderPropertiesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_query_provider_property_reply_t", free_function = "free")]
	public class QueryProviderPropertyReply {
		public bool pending;
		public bool range;
		public bool immutable;
		public int valid_values_length {
			[CCode (cname = "xcb_randr_query_provider_property_valid_values_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] valid_values {
			[CCode (cname = "xcb_randr_query_provider_property_valid_values")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_query_provider_property_cookie_t")]
	public struct QueryProviderPropertyCookie : VoidCookie {
		[CCode (cname = "xcb_randr_query_provider_property_reply", instance_pos = 1.1)]
		public QueryProviderPropertyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_randr_get_provider_property_reply_t", free_function = "free")]
	public class GetProviderPropertyReply {
		public uint8 format;
		public Atom type;
		public uint32 bytes_after;
		public uint32 num_items;
		public int data_length {
			[CCode (cname = "xcb_randr_get_provider_property_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned void[] data {
			[CCode (cname = "xcb_randr_get_provider_property_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_get_provider_property_cookie_t")]
	public struct GetProviderPropertyCookie : VoidCookie {
		[CCode (cname = "xcb_randr_get_provider_property_reply", instance_pos = 1.1)]
		public GetProviderPropertyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
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

	[Compact, CCode (cname = "xcb_randr_bad_provider_error_t", has_type_id = false)]
	public class BadProviderError : Xcb.GenericError {
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
		int rem;
		int index;
		unowned ScreenSize? data;
	}

	[CCode (cname = "xcb_randr_screen_size_iterator_t")]
	public struct ScreenSizeIterator
	{
		[CCode (cname = "xcb_randr_screen_size_next")]
		void _next ();

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

	[SimpleType, CCode (cname = "xcb_randr_screen_size_t", has_type_id = false)]
	public struct ScreenSize {
		public uint16 width;
		public uint16 height;
		public uint16 mwidth;
		public uint16 mheight;
	}

	[SimpleType, CCode (cname = "xcb_randr_refresh_rates_iterator_t")]
	struct _RefreshRatesIterator
	{
		int rem;
		int index;
		unowned RefreshRates? data;
	}

	[CCode (cname = "xcb_randr_refresh_rates_iterator_t")]
	public struct RefreshRatesIterator
	{
		[CCode (cname = "xcb_randr_refresh_rates_next")]
		void _next ();

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

	[SimpleType, CCode (cname = "xcb_randr_refresh_rates_t", has_type_id = false)]
	public struct RefreshRates {
		public uint16 nRates;
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
		OUTPUT_PROPERTY,
		PROVIDER_CHANGE,
		PROVIDER_PROPERTY,
		RESOURCE_CHANGE
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
		int rem;
		int index;
		unowned ModeInfo? data;
	}

	[CCode (cname = "xcb_randr_mode_info_iterator_t")]
	public struct ModeInfoIterator
	{
		[CCode (cname = "xcb_randr_mode_info_next")]
		void _next ();

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

	[SimpleType, CCode (cname = "xcb_randr_mode_info_t", has_type_id = false)]
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

	[CCode (cname = "xcb_randr_transform_t", cprefix =  "XCB_RANDR_TRANSFORM_", has_type_id = false)]
	public enum Transform {
		UNIT,
		SCALE_UP,
		SCALE_DOWN,
		PROJECTIVE
	}

	[Flags, CCode (cname = "xcb_randr_provider_capability_t", cprefix =  "XCB_RANDR_PROVIDER_CAPABILITY_", has_type_id = false)]
	public enum ProviderCapability {
		SOURCE_OUTPUT,
		SINK_OUTPUT,
		SOURCE_OFFLOAD,
		SINK_OFFLOAD
	}

	[Compact, CCode (cname = "xcb_randr_screen_change_notify_event_t", has_type_id = false)]
	public class ScreenChangeNotifyEvent : Xcb.GenericEvent {
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
		OUTPUT_PROPERTY,
		PROVIDER_CHANGE,
		PROVIDER_PROPERTY,
		RESOURCE_CHANGE
	}

	[SimpleType, CCode (cname = "xcb_randr_crtc_change_iterator_t")]
	struct _CrtcChangeIterator
	{
		int rem;
		int index;
		unowned CrtcChange? data;
	}

	[CCode (cname = "xcb_randr_crtc_change_iterator_t")]
	public struct CrtcChangeIterator
	{
		[CCode (cname = "xcb_randr_crtc_change_next")]
		void _next ();

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

	[SimpleType, CCode (cname = "xcb_randr_crtc_change_t", has_type_id = false)]
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
		int rem;
		int index;
		unowned OutputChange? data;
	}

	[CCode (cname = "xcb_randr_output_change_iterator_t")]
	public struct OutputChangeIterator
	{
		[CCode (cname = "xcb_randr_output_change_next")]
		void _next ();

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

	[SimpleType, CCode (cname = "xcb_randr_output_change_t", has_type_id = false)]
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
		int rem;
		int index;
		unowned OutputProperty? data;
	}

	[CCode (cname = "xcb_randr_output_property_iterator_t")]
	public struct OutputPropertyIterator
	{
		[CCode (cname = "xcb_randr_output_property_next")]
		void _next ();

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

	[SimpleType, CCode (cname = "xcb_randr_output_property_t", has_type_id = false)]
	public struct OutputProperty {
		public Window window;
		public Output output;
		public Atom atom;
		public Timestamp timestamp;
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_randr_provider_change_iterator_t")]
	struct _ProviderChangeIterator
	{
		int rem;
		int index;
		unowned ProviderChange? data;
	}

	[CCode (cname = "xcb_randr_provider_change_iterator_t")]
	public struct ProviderChangeIterator
	{
		[CCode (cname = "xcb_randr_provider_change_next")]
		void _next ();

		public inline unowned ProviderChange?
		next_value ()
		{
			if (((_ProviderChangeIterator)this).rem > 0)
			{
				unowned ProviderChange? d = ((_ProviderChangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_provider_change_t", has_type_id = false)]
	public struct ProviderChange {
		public Timestamp timestamp;
		public Window window;
		public Provider provider;
	}

	[SimpleType, CCode (cname = "xcb_randr_provider_property_iterator_t")]
	struct _ProviderPropertyIterator
	{
		int rem;
		int index;
		unowned ProviderProperty? data;
	}

	[CCode (cname = "xcb_randr_provider_property_iterator_t")]
	public struct ProviderPropertyIterator
	{
		[CCode (cname = "xcb_randr_provider_property_next")]
		void _next ();

		public inline unowned ProviderProperty?
		next_value ()
		{
			if (((_ProviderPropertyIterator)this).rem > 0)
			{
				unowned ProviderProperty? d = ((_ProviderPropertyIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_provider_property_t", has_type_id = false)]
	public struct ProviderProperty {
		public Window window;
		public Provider provider;
		public Atom atom;
		public Timestamp timestamp;
		public uint8 state;
	}

	[SimpleType, CCode (cname = "xcb_randr_resource_change_iterator_t")]
	struct _ResourceChangeIterator
	{
		int rem;
		int index;
		unowned ResourceChange? data;
	}

	[CCode (cname = "xcb_randr_resource_change_iterator_t")]
	public struct ResourceChangeIterator
	{
		[CCode (cname = "xcb_randr_resource_change_next")]
		void _next ();

		public inline unowned ResourceChange?
		next_value ()
		{
			if (((_ResourceChangeIterator)this).rem > 0)
			{
				unowned ResourceChange? d = ((_ResourceChangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_randr_resource_change_t", has_type_id = false)]
	public struct ResourceChange {
		public Timestamp timestamp;
		public Window window;
	}

	[SimpleType, CCode (cname = "xcb_randr_notify_data_t", has_type_id = false)]
	public struct NotifyData {
		public CrtcChange cc;
		public OutputChange oc;
		public OutputProperty op;
		public ProviderChange pc;
		public ProviderProperty pp;
		public ResourceChange rc;
	}

	[Compact, CCode (cname = "xcb_randr_notify_event_t", has_type_id = false)]
	public class NotifyEvent : Xcb.GenericEvent {
		public Notify subCode;
		public NotifyData u;
	}

	[CCode (cname = "guint8", cprefix =  "XCB_RANDR_", has_type_id = false)]
	public enum EventType {
		SCREEN_CHANGE_NOTIFY,
		NOTIFY
	}
}

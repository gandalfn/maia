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

[CCode (cheader_filename="xcb/xcb.h,xcb/xf86vidmode.h")]
namespace Xcb.XF86VidMode
{
	[CCode (cname = "xcb_xf86_vid_mode_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_xf86_vid_mode_query_version")]
		public QueryVersionCookie query_version ();
		[CCode (cname = "xcb_xf86_vid_mode_get_mode_line")]
		public GetModeLineCookie get_mode_line (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_mod_mode_line")]
		public VoidCookie mod_mode_line (uint32 screen, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 11.12)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_mod_mode_line_checked")]
		public VoidCookie mod_mode_line_checked (uint32 screen, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 11.12)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_switch_mode")]
		public VoidCookie switch_mode (uint16 screen, uint16 zoom);
		[CCode (cname = "xcb_xf86_vid_mode_switch_mode_checked")]
		public VoidCookie switch_mode_checked (uint16 screen, uint16 zoom);
		[CCode (cname = "xcb_xf86_vid_mode_get_monitor")]
		public GetMonitorCookie get_monitor (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_lock_mode_switch")]
		public VoidCookie lock_mode_switch (uint16 screen, uint16 lock);
		[CCode (cname = "xcb_xf86_vid_mode_lock_mode_switch_checked")]
		public VoidCookie lock_mode_switch_checked (uint16 screen, uint16 lock);
		[CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines")]
		public GetAllModeLinesCookie get_all_mode_lines (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_add_mode_line")]
		public VoidCookie add_mode_line (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, Dotclock after_dotclock, uint16 after_hdisplay, uint16 after_hsyncstart, uint16 after_hsyncend, uint16 after_htotal, uint16 after_hskew, uint16 after_vdisplay, uint16 after_vsyncstart, uint16 after_vsyncend, uint16 after_vtotal, ModeFlag after_flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_add_mode_line_checked")]
		public VoidCookie add_mode_line_checked (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, Dotclock after_dotclock, uint16 after_hdisplay, uint16 after_hsyncstart, uint16 after_hsyncend, uint16 after_htotal, uint16 after_hskew, uint16 after_vdisplay, uint16 after_vsyncstart, uint16 after_vsyncend, uint16 after_vtotal, ModeFlag after_flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_delete_mode_line")]
		public VoidCookie delete_mode_line (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_delete_mode_line_checked")]
		public VoidCookie delete_mode_line_checked (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_validate_mode_line")]
		public ValidateModeLineCookie validate_mode_line (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_switch_to_mode")]
		public VoidCookie switch_to_mode (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_switch_to_mode_checked")]
		public VoidCookie switch_to_mode_checked (uint32 screen, Dotclock dotclock, uint16 hdisplay, uint16 hsyncstart, uint16 hsyncend, uint16 htotal, uint16 hskew, uint16 vdisplay, uint16 vsyncstart, uint16 vsyncend, uint16 vtotal, ModeFlag flags, [CCode (array_length_pos = 12.13)]uint8[] private);
		[CCode (cname = "xcb_xf86_vid_mode_get_view_port")]
		public GetViewPortCookie get_view_port (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_set_view_port")]
		public VoidCookie set_view_port (uint16 screen, uint32 x, uint32 y);
		[CCode (cname = "xcb_xf86_vid_mode_set_view_port_checked")]
		public VoidCookie set_view_port_checked (uint16 screen, uint32 x, uint32 y);
		[CCode (cname = "xcb_xf86_vid_mode_get_dot_clocks")]
		public GetDotClocksCookie get_dot_clocks (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_set_client_version")]
		public VoidCookie set_client_version (uint16 major, uint16 minor);
		[CCode (cname = "xcb_xf86_vid_mode_set_client_version_checked")]
		public VoidCookie set_client_version_checked (uint16 major, uint16 minor);
		[CCode (cname = "xcb_xf86_vid_mode_set_gamma")]
		public VoidCookie set_gamma (uint16 screen, uint32 red, uint32 green, uint32 blue);
		[CCode (cname = "xcb_xf86_vid_mode_set_gamma_checked")]
		public VoidCookie set_gamma_checked (uint16 screen, uint32 red, uint32 green, uint32 blue);
		[CCode (cname = "xcb_xf86_vid_mode_get_gamma")]
		public GetGammaCookie get_gamma (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp")]
		public GetGammaRampCookie get_gamma_ramp (uint16 screen, uint16 size);
		[CCode (cname = "xcb_xf86_vid_mode_set_gamma_ramp")]
		public VoidCookie set_gamma_ramp (uint16 screen, [CCode (array_length_pos = 1.2)]uint16[] red, [CCode (array_length_pos = 1.2)]uint16[] green, [CCode (array_length_pos = 1.2)]uint16[] blue);
		[CCode (cname = "xcb_xf86_vid_mode_set_gamma_ramp_checked")]
		public VoidCookie set_gamma_ramp_checked (uint16 screen, [CCode (array_length_pos = 1.2)]uint16[] red, [CCode (array_length_pos = 1.2)]uint16[] green, [CCode (array_length_pos = 1.2)]uint16[] blue);
		[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_size")]
		public GetGammaRampSizeCookie get_gamma_ramp_size (uint16 screen);
		[CCode (cname = "xcb_xf86_vid_mode_get_permissions")]
		public GetPermissionsCookie get_permissions (uint16 screen);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 major_version;
		public uint16 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_mode_line_reply_t", free_function = "free")]
	public class GetModeLineReply {
		public Dotclock dotclock;
		public uint16 hdisplay;
		public uint16 hsyncstart;
		public uint16 hsyncend;
		public uint16 htotal;
		public uint16 hskew;
		public uint16 vdisplay;
		public uint16 vsyncstart;
		public uint16 vsyncend;
		public uint16 vtotal;
		public ModeFlag flags;
		public uint32 privsize;
		public int private_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_mode_line_private_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] private {
			[CCode (cname = "xcb_xf86_vid_mode_get_mode_line_private")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_mode_line_cookie_t")]
	public struct GetModeLineCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_mode_line_reply", instance_pos = 1.1)]
		public GetModeLineReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_monitor_reply_t", free_function = "free")]
	public class GetMonitorReply {
		public uint8 vendor_length;
		public uint8 model_length;
		public uint8 num_hsync;
		public uint8 num_vsync;
		public int hsync_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_monitor_hsync_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Syncrange[] hsync {
			[CCode (cname = "xcb_xf86_vid_mode_get_monitor_hsync")]
			get;
		}
		public int vsync_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_monitor_vsync_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Syncrange[] vsync {
			[CCode (cname = "xcb_xf86_vid_mode_get_monitor_vsync")]
			get;
		}
		[CCode (cname = "xcb_xf86_vid_mode_get_monitor_vendor_length")]
		int _vendor_length ();
		[CCode (cname = "xcb_xf86_vid_mode_get_monitor_vendor", array_length = false)]
		unowned char[] _vendor ();
		public string vendor {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_vendor (), _vendor_length ());
				return ret.str;
			}
		}
		public int alignment_pad_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_monitor_alignment_pad_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned void[] alignment_pad {
			[CCode (cname = "xcb_xf86_vid_mode_get_monitor_alignment_pad")]
			get;
		}
		[CCode (cname = "xcb_xf86_vid_mode_get_monitor_model_length")]
		int _model_length ();
		[CCode (cname = "xcb_xf86_vid_mode_get_monitor_model", array_length = false)]
		unowned char[] _model ();
		public string model {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_model (), _model_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_monitor_cookie_t")]
	public struct GetMonitorCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_monitor_reply", instance_pos = 1.1)]
		public GetMonitorReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines_reply_t", free_function = "free")]
	public class GetAllModeLinesReply {
		public uint32 modecount;
		[CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines_modeinfo_iterator")]
		_ModeInfoIterator _iterator ();
		public ModeInfoIterator iterator () {
			return (ModeInfoIterator) _iterator ();
		}
		public int modeinfo_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines_modeinfo_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ModeInfo[] modeinfo {
			[CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines_modeinfo")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines_cookie_t")]
	public struct GetAllModeLinesCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_all_mode_lines_reply", instance_pos = 1.1)]
		public GetAllModeLinesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_validate_mode_line_reply_t", free_function = "free")]
	public class ValidateModeLineReply {
		public uint32 status;
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_validate_mode_line_cookie_t")]
	public struct ValidateModeLineCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_validate_mode_line_reply", instance_pos = 1.1)]
		public ValidateModeLineReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_view_port_reply_t", free_function = "free")]
	public class GetViewPortReply {
		public uint32 x;
		public uint32 y;
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_view_port_cookie_t")]
	public struct GetViewPortCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_view_port_reply", instance_pos = 1.1)]
		public GetViewPortReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_dot_clocks_reply_t", free_function = "free")]
	public class GetDotClocksReply {
		public ClockFlag flags;
		public uint32 clocks;
		public uint32 maxclocks;
		public int clock_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_dot_clocks_clock_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] clock {
			[CCode (cname = "xcb_xf86_vid_mode_get_dot_clocks_clock")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_dot_clocks_cookie_t")]
	public struct GetDotClocksCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_dot_clocks_reply", instance_pos = 1.1)]
		public GetDotClocksReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_gamma_reply_t", free_function = "free")]
	public class GetGammaReply {
		public uint32 red;
		public uint32 green;
		public uint32 blue;
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_gamma_cookie_t")]
	public struct GetGammaCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_gamma_reply", instance_pos = 1.1)]
		public GetGammaReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_reply_t", free_function = "free")]
	public class GetGammaRampReply {
		public uint16 size;
		public int red_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_red_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] red {
			[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_red")]
			get;
		}
		public int green_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_green_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] green {
			[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_green")]
			get;
		}
		public int blue_length {
			[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_blue_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] blue {
			[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_blue")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_cookie_t")]
	public struct GetGammaRampCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_reply", instance_pos = 1.1)]
		public GetGammaRampReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_size_reply_t", free_function = "free")]
	public class GetGammaRampSizeReply {
		public uint16 size;
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_size_cookie_t")]
	public struct GetGammaRampSizeCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_gamma_ramp_size_reply", instance_pos = 1.1)]
		public GetGammaRampSizeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_get_permissions_reply_t", free_function = "free")]
	public class GetPermissionsReply {
		public Permission permissions;
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_get_permissions_cookie_t")]
	public struct GetPermissionsCookie : VoidCookie {
		[CCode (cname = "xcb_xf86_vid_mode_get_permissions_reply", instance_pos = 1.1)]
		public GetPermissionsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_syncrange_t", has_type_id = false)]
	public struct Syncrange : uint32 {
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_dotclock_t", has_type_id = false)]
	public struct Dotclock : uint32 {
	}

	[Flags, CCode (cname = "xcb_xf86_vid_mode_mode_flag_t", cprefix =  "XCB_XF86VID_MODE_MODE_FLAG_", has_type_id = false)]
	public enum ModeFlag {
		POSITIVE_H_SYNC,
		NEGATIVE_H_SYNC,
		POSITIVE_V_SYNC,
		NEGATIVE_V_SYNC,
		INTERLACE,
		COMPOSITE_SYNC,
		POSITIVE_C_SYNC,
		NEGATIVE_C_SYNC,
		H_SKEW,
		BROADCAST,
		PIXMUX,
		DOUBLE_CLOCK,
		HALF_CLOCK
	}

	[Flags, CCode (cname = "xcb_xf86_vid_mode_clock_flag_t", cprefix =  "XCB_XF86VID_MODE_CLOCK_FLAG_", has_type_id = false)]
	public enum ClockFlag {
		PROGRAMABLE
	}

	[Flags, CCode (cname = "xcb_xf86_vid_mode_permission_t", cprefix =  "XCB_XF86VID_MODE_PERMISSION_", has_type_id = false)]
	public enum Permission {
		READ,
		WRITE
	}

	[SimpleType, CCode (cname = "xcb_xf86_vid_mode_mode_info_iterator_t")]
	struct _ModeInfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned ModeInfo? data;
	}

	[CCode (cname = "xcb_xf86_vid_mode_mode_info_iterator_t")]
	public struct ModeInfoIterator
	{
		[CCode (cname = "xcb_xf86_vid_mode_mode_info_next")]
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

	[CCode (cname = "xcb_xf86_vid_mode_mode_info_t", has_type_id = false)]
	public struct ModeInfo {
		public Dotclock dotclock;
		public uint16 hdisplay;
		public uint16 hsyncstart;
		public uint16 hsyncend;
		public uint16 htotal;
		public uint32 hskew;
		public uint16 vdisplay;
		public uint16 vsyncstart;
		public uint16 vsyncend;
		public uint16 vtotal;
		public ModeFlag flags;
		public uint32 privsize;
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_bad_clock_error_t", has_type_id = false)]
	public class BadClockError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_bad_h_timings_error_t", has_type_id = false)]
	public class BadHtimingsError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_bad_v_timings_error_t", has_type_id = false)]
	public class BadVtimingsError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_mode_unsuitable_error_t", has_type_id = false)]
	public class ModeUnsuitableError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_extension_disabled_error_t", has_type_id = false)]
	public class ExtensionDisabledError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_client_not_local_error_t", has_type_id = false)]
	public class ClientNotLocalError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_xf86_vid_mode_zoom_locked_error_t", has_type_id = false)]
	public class ZoomLockedError : Xcb.GenericError {
	}
}

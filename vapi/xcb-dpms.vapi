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

[CCode (cheader_filename="xcb/xcb.h,xcb/dpms.h")]
namespace Xcb.DPMS
{
	[CCode (cname = "xcb_dpms_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_dpms_get_version")]
		public GetVersionCookie get_version (uint16 client_major_version, uint16 client_minor_version);
		[CCode (cname = "xcb_dpms_capable")]
		public CapableCookie capable ();
		[CCode (cname = "xcb_dpms_get_timeouts")]
		public GetTimeoutsCookie get_timeouts ();
		[CCode (cname = "xcb_dpms_set_timeouts")]
		public VoidCookie set_timeouts (uint16 standby_timeout, uint16 suspend_timeout, uint16 off_timeout);
		[CCode (cname = "xcb_dpms_set_timeouts_checked")]
		public VoidCookie set_timeouts_checked (uint16 standby_timeout, uint16 suspend_timeout, uint16 off_timeout);
		[CCode (cname = "xcb_dpms_enable")]
		public VoidCookie enable ();
		[CCode (cname = "xcb_dpms_enable_checked")]
		public VoidCookie enable_checked ();
		[CCode (cname = "xcb_dpms_disable")]
		public VoidCookie disable ();
		[CCode (cname = "xcb_dpms_disable_checked")]
		public VoidCookie disable_checked ();
		[CCode (cname = "xcb_dpms_force_level")]
		public VoidCookie force_level (Dpmsmode power_level);
		[CCode (cname = "xcb_dpms_force_level_checked")]
		public VoidCookie force_level_checked (Dpmsmode power_level);
		[CCode (cname = "xcb_dpms_info")]
		public InfoCookie info ();
	}

	[Compact, CCode (cname = "xcb_dpms_get_version_reply_t", free_function = "free")]
	public class GetVersionReply {
		public uint16 server_major_version;
		public uint16 server_minor_version;
	}

	[SimpleType, CCode (cname = "xcb_dpms_get_version_cookie_t")]
	public struct GetVersionCookie : VoidCookie {
		[CCode (cname = "xcb_dpms_get_version_reply", instance_pos = 1.1)]
		public GetVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dpms_capable_reply_t", free_function = "free")]
	public class CapableReply {
		public bool capable;
	}

	[SimpleType, CCode (cname = "xcb_dpms_capable_cookie_t")]
	public struct CapableCookie : VoidCookie {
		[CCode (cname = "xcb_dpms_capable_reply", instance_pos = 1.1)]
		public CapableReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dpms_get_timeouts_reply_t", free_function = "free")]
	public class GetTimeoutsReply {
		public uint16 standby_timeout;
		public uint16 suspend_timeout;
		public uint16 off_timeout;
	}

	[SimpleType, CCode (cname = "xcb_dpms_get_timeouts_cookie_t")]
	public struct GetTimeoutsCookie : VoidCookie {
		[CCode (cname = "xcb_dpms_get_timeouts_reply", instance_pos = 1.1)]
		public GetTimeoutsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_dpms_info_reply_t", free_function = "free")]
	public class InfoReply {
		public Dpmsmode power_level;
		public bool state;
	}

	[SimpleType, CCode (cname = "xcb_dpms_info_cookie_t")]
	public struct InfoCookie : VoidCookie {
		[CCode (cname = "xcb_dpms_info_reply", instance_pos = 1.1)]
		public InfoReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_dpms_dpms_mode_t", cprefix =  "XCB_DPMS_DPMS_MODE_", has_type_id = false)]
	public enum Dpmsmode {
		ON,
		STANDBY,
		SUSPEND,
		OFF
	}
}

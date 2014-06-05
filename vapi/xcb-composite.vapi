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
using Xcb.XFixes;

[CCode (cheader_filename="xcb/xcb.h,xcb/composite.h")]
namespace Xcb.Composite
{
	[CCode (cname = "xcb_composite_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_composite_query_version")]
		public QueryVersionCookie query_version (uint32 client_major_version, uint32 client_minor_version);
	}

	[Compact, CCode (cname = "xcb_composite_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major_version;
		public uint32 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_composite_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_composite_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_composite_redirect_window", instance_pos = 1.1)]
		public VoidCookie redirect (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_redirect_window_checked", instance_pos = 1.1)]
		public VoidCookie redirect_checked (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_redirect_subwindows", instance_pos = 1.1)]
		public VoidCookie redirect_subwindows (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_redirect_subwindows_checked", instance_pos = 1.1)]
		public VoidCookie redirect_subwindows_checked (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_unredirect_window", instance_pos = 1.1)]
		public VoidCookie unredirect (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_unredirect_window_checked", instance_pos = 1.1)]
		public VoidCookie unredirect_checked (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_unredirect_subwindows", instance_pos = 1.1)]
		public VoidCookie unredirect_subwindows (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_unredirect_subwindows_checked", instance_pos = 1.1)]
		public VoidCookie unredirect_subwindows_checked (Xcb.Connection connection, Redirect update);
		[CCode (cname = "xcb_composite_create_region_from_border_clip", instance_pos = 2.2)]
		public VoidCookie create_region_from_border_clip (Xcb.Connection connection, Region region);
		[CCode (cname = "xcb_composite_create_region_from_border_clip_checked", instance_pos = 2.2)]
		public VoidCookie create_region_from_border_clip_checked (Xcb.Connection connection, Region region);
		[CCode (cname = "xcb_composite_name_window_pixmap", instance_pos = 1.1)]
		public VoidCookie name_pixmap (Xcb.Connection connection, Pixmap pixmap);
		[CCode (cname = "xcb_composite_name_window_pixmap_checked", instance_pos = 1.1)]
		public VoidCookie name_pixmap_checked (Xcb.Connection connection, Pixmap pixmap);
		[CCode (cname = "xcb_composite_get_overlay_window", instance_pos = 1.1)]
		public GetOverlayWindowCookie get_overlay (Xcb.Connection connection);
		[CCode (cname = "xcb_composite_release_overlay_window", instance_pos = 1.1)]
		public VoidCookie release_overlay (Xcb.Connection connection);
		[CCode (cname = "xcb_composite_release_overlay_window_checked", instance_pos = 1.1)]
		public VoidCookie release_overlay_checked (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_composite_get_overlay_window_reply_t", free_function = "free")]
	public class GetOverlayWindowReply {
		public Window overlay_win;
	}

	[SimpleType, CCode (cname = "xcb_composite_get_overlay_window_cookie_t")]
	public struct GetOverlayWindowCookie : VoidCookie {
		[CCode (cname = "xcb_composite_get_overlay_window_reply", instance_pos = 1.1)]
		public GetOverlayWindowReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_composite_redirect_t", cprefix =  "XCB_COMPOSITE_REDIRECT_", has_type_id = false)]
	public enum Redirect {
		AUTOMATIC,
		MANUAL
	}
}

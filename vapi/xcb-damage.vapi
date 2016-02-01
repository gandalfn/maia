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

[CCode (cheader_filename="xcb/xcb.h,xcb/damage.h")]
namespace Xcb.Damage
{
	[CCode (cname = "xcb_damage_id")]
	public Xcb.Extension extension;

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		[CCode (cname = "xcb_damage_add", instance_pos = 1.1)]
		public VoidCookie add (Xcb.Connection connection, Region region);
		[CCode (cname = "xcb_damage_add_checked", instance_pos = 1.1)]
		public VoidCookie add_checked (Xcb.Connection connection, Region region);
	}

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_damage_query_version")]
		public QueryVersionCookie query_version (uint32 client_major_version, uint32 client_minor_version);
	}

	[Compact, CCode (cname = "xcb_damage_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major_version;
		public uint32 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_damage_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_damage_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_damage_damage_iterator_t")]
	struct _DamageIterator
	{
		int rem;
		int index;
		unowned Damage? data;
	}

	[CCode (cname = "xcb_damage_damage_iterator_t")]
	public struct DamageIterator
	{
		[CCode (cname = "xcb_damage_damage_next")]
		void _next ();

		public inline unowned Damage?
		next_value ()
		{
			if (((_DamageIterator)this).rem > 0)
			{
				unowned Damage? d = ((_DamageIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_damage_damage_t", has_type_id = false)]
	public struct Damage : uint32 {
		/**
		 * Allocates an XID for a new Damage.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Damage (Xcb.Connection connection);

		[CCode (cname = "xcb_damage_create", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, Drawable drawable, ReportLevel level);
		[CCode (cname = "xcb_damage_create_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, Drawable drawable, ReportLevel level);
		[CCode (cname = "xcb_damage_destroy", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_damage_destroy_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_damage_subtract", instance_pos = 1.1)]
		public VoidCookie subtract (Xcb.Connection connection, Region repair, Region parts);
		[CCode (cname = "xcb_damage_subtract_checked", instance_pos = 1.1)]
		public VoidCookie subtract_checked (Xcb.Connection connection, Region repair, Region parts);
	}

	[CCode (cname = "xcb_damage_report_level_t", cprefix =  "XCB_DAMAGE_REPORT_LEVEL_", has_type_id = false)]
	public enum ReportLevel {
		RAW_RECTANGLES,
		DELTA_RECTANGLES,
		BOUNDING_BOX,
		NON_EMPTY
	}

	[Compact, CCode (cname = "xcb_damage_bad_damage_error_t", has_type_id = false)]
	public class BadDamageError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_damage_notify_event_t", has_type_id = false)]
	public class NotifyEvent : Xcb.GenericEvent {
		public ReportLevel level;
		public Drawable drawable;
		public Damage damage;
		public Timestamp timestamp;
		public Rectangle area;
		public Rectangle geometry;
	}

	[CCode (cname = "guint8", cprefix =  "XCB_DAMAGE_", has_type_id = false)]
	public enum EventType {
		NOTIFY
	}
}

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
using Xcb.XFixes;

[CCode (cheader_filename="xcb/xcb.h,xcb/damage.h")]
namespace Xcb.Damage
{
	[CCode (cname = "xcb_damage_id")]
	public Xcb.Extension extension;

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

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		[CCode (cname = "xcb_damage_add", instance_pos = 1.1)]
		public VoidCookie add (Xcb.Connection connection, Region region);
		[CCode (cname = "xcb_damage_add_checked", instance_pos = 1.1)]
		public VoidCookie add_checked (Xcb.Connection connection, Region region);
	}

	[SimpleType, CCode (cname = "xcb_damage_damage_iterator_t")]
	struct _DamageIterator
	{
		internal int rem;
		internal int index;
		internal unowned Damage? data;
	}

	[CCode (cname = "xcb_damage_damage_iterator_t")]
	public struct DamageIterator
	{
		[CCode (cname = "xcb_damage_damage_next")]
		internal void _next ();

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
	public class NotifyEvent : GenericEvent {
		public ReportLevel level;
		public Drawable drawable;
		public Damage damage;
		public Timestamp timestamp;
		public Rectangle area;
		public Rectangle geometry;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_DAMAGE_", has_type_id = false)]
	public enum EventType {
		NOTIFY
	}
}

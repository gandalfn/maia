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

[CCode (cheader_filename="xcb/xcb.h,xcb/xselinux.h")]
namespace Xcb.SELinux
{
	[CCode (cname = "xcb_se_linux_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_se_linux_query_version")]
		public QueryVersionCookie query_version (uint8 client_major, uint8 client_minor);
		[CCode (cname = "xcb_se_linux_set_device_create_context")]
		public VoidCookie set_device_create_context ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_set_device_create_context_checked")]
		public VoidCookie set_device_create_context_checked ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_get_device_create_context")]
		public GetDeviceCreateContextCookie get_device_create_context ();
		[CCode (cname = "xcb_se_linux_set_device_context")]
		public VoidCookie set_device_context (uint32 device, [CCode (array_length_pos = 1.2)]char[] context);
		[CCode (cname = "xcb_se_linux_set_device_context_checked")]
		public VoidCookie set_device_context_checked (uint32 device, [CCode (array_length_pos = 1.2)]char[] context);
		[CCode (cname = "xcb_se_linux_get_device_context")]
		public GetDeviceContextCookie get_device_context (uint32 device);
		[CCode (cname = "xcb_se_linux_set_window_create_context")]
		public VoidCookie set_window_create_context ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_set_window_create_context_checked")]
		public VoidCookie set_window_create_context_checked ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_get_window_create_context")]
		public GetWindowCreateContextCookie get_window_create_context ();
		[CCode (cname = "xcb_se_linux_set_property_create_context")]
		public VoidCookie set_property_create_context ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_set_property_create_context_checked")]
		public VoidCookie set_property_create_context_checked ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_get_property_create_context")]
		public GetPropertyCreateContextCookie get_property_create_context ();
		[CCode (cname = "xcb_se_linux_set_property_use_context")]
		public VoidCookie set_property_use_context ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_set_property_use_context_checked")]
		public VoidCookie set_property_use_context_checked ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_get_property_use_context")]
		public GetPropertyUseContextCookie get_property_use_context ();
		[CCode (cname = "xcb_se_linux_set_selection_create_context")]
		public VoidCookie set_selection_create_context ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_set_selection_create_context_checked")]
		public VoidCookie set_selection_create_context_checked ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_get_selection_create_context")]
		public GetSelectionCreateContextCookie get_selection_create_context ();
		[CCode (cname = "xcb_se_linux_set_selection_use_context")]
		public VoidCookie set_selection_use_context ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_set_selection_use_context_checked")]
		public VoidCookie set_selection_use_context_checked ([CCode (array_length_pos = 0.1)]char[] context);
		[CCode (cname = "xcb_se_linux_get_selection_use_context")]
		public GetSelectionUseContextCookie get_selection_use_context ();
		[CCode (cname = "xcb_se_linux_list_selections")]
		public ListSelectionsCookie list_selections ();
		[CCode (cname = "xcb_se_linux_get_client_context")]
		public GetClientContextCookie get_client_context (uint32 resource);
	}

	[Compact, CCode (cname = "xcb_se_linux_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint16 server_major;
		public uint16 server_minor;
	}

	[SimpleType, CCode (cname = "xcb_se_linux_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_device_create_context_reply_t", free_function = "free")]
	public class GetDeviceCreateContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_device_create_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_device_create_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_device_create_context_cookie_t")]
	public struct GetDeviceCreateContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_device_create_context_reply", instance_pos = 1.1)]
		public GetDeviceCreateContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_device_context_reply_t", free_function = "free")]
	public class GetDeviceContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_device_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_device_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_device_context_cookie_t")]
	public struct GetDeviceContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_device_context_reply", instance_pos = 1.1)]
		public GetDeviceContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_window_create_context_reply_t", free_function = "free")]
	public class GetWindowCreateContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_window_create_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_window_create_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_window_create_context_cookie_t")]
	public struct GetWindowCreateContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_window_create_context_reply", instance_pos = 1.1)]
		public GetWindowCreateContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_property_create_context_reply_t", free_function = "free")]
	public class GetPropertyCreateContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_property_create_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_property_create_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_property_create_context_cookie_t")]
	public struct GetPropertyCreateContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_property_create_context_reply", instance_pos = 1.1)]
		public GetPropertyCreateContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_property_use_context_reply_t", free_function = "free")]
	public class GetPropertyUseContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_property_use_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_property_use_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_property_use_context_cookie_t")]
	public struct GetPropertyUseContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_property_use_context_reply", instance_pos = 1.1)]
		public GetPropertyUseContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_selection_create_context_reply_t", free_function = "free")]
	public class GetSelectionCreateContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_selection_create_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_selection_create_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_selection_create_context_cookie_t")]
	public struct GetSelectionCreateContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_selection_create_context_reply", instance_pos = 1.1)]
		public GetSelectionCreateContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_selection_use_context_reply_t", free_function = "free")]
	public class GetSelectionUseContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_selection_use_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_selection_use_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_selection_use_context_cookie_t")]
	public struct GetSelectionUseContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_selection_use_context_reply", instance_pos = 1.1)]
		public GetSelectionUseContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_list_selections_reply_t", free_function = "free")]
	public class ListSelectionsReply {
		public uint32 selections_len;
		[CCode (cname = "xcb_se_linux_list_selections_selections_iterator")]
		_ListItemIterator _iterator ();
		public ListItemIterator iterator () {
			return (ListItemIterator) _iterator ();
		}
		public int selections_length {
			[CCode (cname = "xcb_se_linux_list_selections_selections_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ListItem[] selections {
			[CCode (cname = "xcb_se_linux_list_selections_selections")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_list_selections_cookie_t")]
	public struct ListSelectionsCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_list_selections_reply", instance_pos = 1.1)]
		public ListSelectionsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_client_context_reply_t", free_function = "free")]
	public class GetClientContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_client_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_client_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_client_context_cookie_t")]
	public struct GetClientContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_client_context_reply", instance_pos = 1.1)]
		public GetClientContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_se_linux_get_window_context", instance_pos = 1.1)]
		public GetWindowContextCookie get_context (Xcb.Connection connection);
		[CCode (cname = "xcb_se_linux_get_property_context", instance_pos = 1.1)]
		public GetPropertyContextCookie get_property_context (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_se_linux_get_property_data_context", instance_pos = 1.1)]
		public GetPropertyDataContextCookie get_property_data_context (Xcb.Connection connection, Atom property);
		[CCode (cname = "xcb_se_linux_list_properties", instance_pos = 1.1)]
		public ListPropertiesCookie list_properties (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_window_context_reply_t", free_function = "free")]
	public class GetWindowContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_window_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_window_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_window_context_cookie_t")]
	public struct GetWindowContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_window_context_reply", instance_pos = 1.1)]
		public GetWindowContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_property_context_reply_t", free_function = "free")]
	public class GetPropertyContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_property_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_property_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_property_context_cookie_t")]
	public struct GetPropertyContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_property_context_reply", instance_pos = 1.1)]
		public GetPropertyContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_property_data_context_reply_t", free_function = "free")]
	public class GetPropertyDataContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_property_data_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_property_data_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_property_data_context_cookie_t")]
	public struct GetPropertyDataContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_property_data_context_reply", instance_pos = 1.1)]
		public GetPropertyDataContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_list_properties_reply_t", free_function = "free")]
	public class ListPropertiesReply {
		public uint32 properties_len;
		[CCode (cname = "xcb_se_linux_list_properties_properties_iterator")]
		_ListItemIterator _iterator ();
		public ListItemIterator iterator () {
			return (ListItemIterator) _iterator ();
		}
		public int properties_length {
			[CCode (cname = "xcb_se_linux_list_properties_properties_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned ListItem[] properties {
			[CCode (cname = "xcb_se_linux_list_properties_properties")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_list_properties_cookie_t")]
	public struct ListPropertiesCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_list_properties_reply", instance_pos = 1.1)]
		public ListPropertiesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_atom_t", has_type_id = false)]
	public struct Atom : Xcb.Atom {
		[CCode (cname = "xcb_se_linux_get_selection_context", instance_pos = 1.1)]
		public GetSelectionContextCookie get_selection_context (Xcb.Connection connection);
		[CCode (cname = "xcb_se_linux_get_selection_data_context", instance_pos = 1.1)]
		public GetSelectionDataContextCookie get_selection_data_context (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_selection_context_reply_t", free_function = "free")]
	public class GetSelectionContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_selection_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_selection_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_selection_context_cookie_t")]
	public struct GetSelectionContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_selection_context_reply", instance_pos = 1.1)]
		public GetSelectionContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_se_linux_get_selection_data_context_reply_t", free_function = "free")]
	public class GetSelectionDataContextReply {
		public uint32 context_len;
		[CCode (cname = "xcb_se_linux_get_selection_data_context_context_length")]
		int _context_length ();
		[CCode (cname = "xcb_se_linux_get_selection_data_context_context", array_length = false)]
		unowned char[] _context ();
		public string context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_context (), _context_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_se_linux_get_selection_data_context_cookie_t")]
	public struct GetSelectionDataContextCookie : VoidCookie {
		[CCode (cname = "xcb_se_linux_get_selection_data_context_reply", instance_pos = 1.1)]
		public GetSelectionDataContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_se_linux_list_item_iterator_t")]
	struct _ListItemIterator
	{
		internal int rem;
		internal int index;
		internal unowned ListItem? data;
	}

	[CCode (cname = "xcb_se_linux_list_item_iterator_t")]
	public struct ListItemIterator
	{
		[CCode (cname = "xcb_se_linux_list_item_next")]
		internal void _next ();

		public inline unowned ListItem?
		next_value ()
		{
			if (((_ListItemIterator)this).rem > 0)
			{
				unowned ListItem? d = ((_ListItemIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_se_linux_list_item_t", has_type_id = false)]
	public struct ListItem {
		public Atom name;
		public uint32 object_context_len;
		public uint32 data_context_len;
		[CCode (cname = "xcb_se_linux_list_item_object_context_length")]
		int _object_context_length ();
		[CCode (cname = "xcb_se_linux_list_item_object_context", array_length = false)]
		unowned char[] _object_context ();
		public string object_context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_object_context (), _object_context_length ());
				return ret.str;
			}
		}
		[CCode (cname = "xcb_se_linux_list_item_data_context_length")]
		int _data_context_length ();
		[CCode (cname = "xcb_se_linux_list_item_data_context", array_length = false)]
		unowned char[] _data_context ();
		public string data_context {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_data_context (), _data_context_length ());
				return ret.str;
			}
		}
	}
}

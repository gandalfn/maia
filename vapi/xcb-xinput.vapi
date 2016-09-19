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

[CCode (cheader_filename="xcb/xcb.h,xcb/xinput.h")]
namespace Xcb.Input
{
	[CCode (cname = "xcb_input_id")]
	public Xcb.Extension extension;

	static void set_mask (void** ptr, uint8 event)
	{
		((uchar*)(*ptr))[(event)>>3] |=  (1 << ((event) & 7));
	}

	static void clear_mask(void** ptr, uint8 event)
	{
		((uchar*)(*ptr))[(event)>>3] &= ~(1 << ((event) & 7));
	}

	static void mask_is_set (void** ptr, uint8 event)
	{
		((uchar*)(*ptr))[(event)>>3] &   (1 << ((event) & 7));
	}

	static uint8 mask_len (uint8 event)
	{
		return ((event) >> 3) + 1;
	}

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_input_get_extension_version")]
		public GetExtensionVersionCookie get_extension_version ([CCode (array_length_pos = 0.1)]char[]? name);
		[CCode (cname = "xcb_input_list_input_devices")]
		public ListInputDevicesCookie list_input_devices ();
		[CCode (cname = "xcb_input_open_device")]
		public OpenDeviceCookie open_device (uint8 device_id);
		[CCode (cname = "xcb_input_close_device")]
		public VoidCookie close_device (uint8 device_id);
		[CCode (cname = "xcb_input_close_device_checked")]
		public VoidCookie close_device_checked (uint8 device_id);
		[CCode (cname = "xcb_input_set_device_mode")]
		public SetDeviceModeCookie set_device_mode (uint8 device_id, ValuatorMode mode);
		[CCode (cname = "xcb_input_get_device_motion_events")]
		public GetDeviceMotionEventsCookie get_device_motion_events (Timestamp start, Timestamp stop, uint8 device_id);
		[CCode (cname = "xcb_input_change_keyboard_device")]
		public ChangeKeyboardDeviceCookie change_keyboard_device (uint8 device_id);
		[CCode (cname = "xcb_input_change_pointer_device")]
		public ChangePointerDeviceCookie change_pointer_device (uint8 x_axis, uint8 y_axis, uint8 device_id);
		[CCode (cname = "xcb_input_ungrab_device")]
		public VoidCookie ungrab_device (Timestamp time, uint8 device_id);
		[CCode (cname = "xcb_input_ungrab_device_checked")]
		public VoidCookie ungrab_device_checked (Timestamp time, uint8 device_id);
		[CCode (cname = "xcb_input_allow_device_events")]
		public VoidCookie allow_device_events (Timestamp time, DeviceInputMode mode, uint8 device_id);
		[CCode (cname = "xcb_input_allow_device_events_checked")]
		public VoidCookie allow_device_events_checked (Timestamp time, DeviceInputMode mode, uint8 device_id);
		[CCode (cname = "xcb_input_get_device_focus")]
		public GetDeviceFocusCookie get_device_focus (uint8 device_id);
		[CCode (cname = "xcb_input_get_feedback_control")]
		public GetFeedbackControlCookie get_feedback_control (uint8 device_id);
		[CCode (cname = "xcb_input_change_feedback_control")]
		public VoidCookie change_feedback_control (uint32 mask, uint8 device_id, uint8 feedback_id, FeedbackCtl feedback);
		[CCode (cname = "xcb_input_change_feedback_control_checked")]
		public VoidCookie change_feedback_control_checked (uint32 mask, uint8 device_id, uint8 feedback_id, FeedbackCtl feedback);
		[CCode (cname = "xcb_input_get_device_key_mapping")]
		public GetDeviceKeyMappingCookie get_device_key_mapping (uint8 device_id, Keycode first_keycode, uint8 count);
		[CCode (cname = "xcb_input_change_device_key_mapping")]
		public VoidCookie change_device_key_mapping (uint8 device_id, Keycode first_keycode, uint8 keysyms_per_keycode, [CCode (array_length_pos = 3.4)]Keysym[]? keysyms);
		[CCode (cname = "xcb_input_change_device_key_mapping_checked")]
		public VoidCookie change_device_key_mapping_checked (uint8 device_id, Keycode first_keycode, uint8 keysyms_per_keycode, [CCode (array_length_pos = 3.4)]Keysym[]? keysyms);
		[CCode (cname = "xcb_input_get_device_modifier_mapping")]
		public GetDeviceModifierMappingCookie get_device_modifier_mapping (uint8 device_id);
		[CCode (cname = "xcb_input_set_device_modifier_mapping")]
		public SetDeviceModifierMappingCookie set_device_modifier_mapping (uint8 device_id, [CCode (array_length_pos = 1.2)]uint8[]? keymaps);
		[CCode (cname = "xcb_input_get_device_button_mapping")]
		public GetDeviceButtonMappingCookie get_device_button_mapping (uint8 device_id);
		[CCode (cname = "xcb_input_set_device_button_mapping")]
		public SetDeviceButtonMappingCookie set_device_button_mapping (uint8 device_id, [CCode (array_length_pos = 1.2)]uint8[]? map);
		[CCode (cname = "xcb_input_query_device_state")]
		public QueryDeviceStateCookie query_device_state (uint8 device_id);
		[CCode (cname = "xcb_input_device_bell")]
		public VoidCookie device_bell (uint8 device_id, uint8 feedback_id, uint8 feedback_class, int8 percent);
		[CCode (cname = "xcb_input_device_bell_checked")]
		public VoidCookie device_bell_checked (uint8 device_id, uint8 feedback_id, uint8 feedback_class, int8 percent);
		[CCode (cname = "xcb_input_set_device_valuators")]
		public SetDeviceValuatorsCookie set_device_valuators (uint8 device_id, uint8 first_valuator, [CCode (array_length_pos = 2.3)]int32[]? valuators);
		[CCode (cname = "xcb_input_get_device_control")]
		public GetDeviceControlCookie get_device_control (DeviceControl control_id, uint8 device_id);
		[CCode (cname = "xcb_input_change_device_control")]
		public ChangeDeviceControlCookie change_device_control (DeviceControl control_id, uint8 device_id, DeviceCtl control);
		[CCode (cname = "xcb_input_list_device_properties")]
		public ListDevicePropertiesCookie list_device_properties (uint8 device_id);
		[CCode (cname = "xcb_input_xi_change_hierarchy")]
		public VoidCookie xi_change_hierarchy ([CCode (array_length_pos = 0.1)]HierarchyChange[]? changes);
		[CCode (cname = "xcb_input_xi_change_hierarchy_checked")]
		public VoidCookie xi_change_hierarchy_checked ([CCode (array_length_pos = 0.1)]HierarchyChange[]? changes);
		[CCode (cname = "xcb_input_xi_query_version")]
		public XIQueryVersionCookie xi_query_version (uint16 major_version, uint16 minor_version);
		[CCode (cname = "xcb_input_xi_query_device")]
		public XIQueryDeviceCookie xi_query_device (DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_get_focus")]
		public XIGetFocusCookie xi_get_focus (DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_ungrab_device")]
		public VoidCookie xi_ungrab_device (Timestamp time, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_ungrab_device_checked")]
		public VoidCookie xi_ungrab_device_checked (Timestamp time, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_list_properties")]
		public XIListPropertiesCookie xi_list_properties (DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_barrier_release_pointer")]
		public VoidCookie xi_barrier_release_pointer ([CCode (array_length_pos = 0.1)]BarrierReleasePointerInfo[]? barriers);
		[CCode (cname = "xcb_input_xi_barrier_release_pointer_checked")]
		public VoidCookie xi_barrier_release_pointer_checked ([CCode (array_length_pos = 0.1)]BarrierReleasePointerInfo[]? barriers);
	}

	[Compact, CCode (cname = "xcb_input_get_extension_version_reply_t", free_function = "free")]
	public class GetExtensionVersionReply {
		public uint16 server_major;
		public uint16 server_minor;
		public bool present;
	}

	[SimpleType, CCode (cname = "xcb_input_get_extension_version_cookie_t")]
	public struct GetExtensionVersionCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_extension_version_reply", instance_pos = 1.1)]
		public GetExtensionVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_list_input_devices_reply_t", free_function = "free")]
	public class ListInputDevicesReply {
		public uint8 devices_len;
		[CCode (cname = "xcb_input_list_input_devices_devices_iterator")]
		_DeviceInfoIterator _iterator ();
		public DeviceInfoIterator iterator () {
			return (DeviceInfoIterator) _iterator ();
		}
		public int devices_length {
			[CCode (cname = "xcb_input_list_input_devices_devices_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned DeviceInfo[] devices {
			[CCode (cname = "xcb_input_list_input_devices_devices")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_list_input_devices_cookie_t")]
	public struct ListInputDevicesCookie : VoidCookie {
		[CCode (cname = "xcb_input_list_input_devices_reply", instance_pos = 1.1)]
		public ListInputDevicesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_open_device_reply_t", free_function = "free")]
	public class OpenDeviceReply {
		public uint8 num_classes;
		[CCode (cname = "xcb_input_open_device_class_info_iterator")]
		_InputClassInfoIterator _iterator ();
		public InputClassInfoIterator iterator () {
			return (InputClassInfoIterator) _iterator ();
		}
		public int class_info_length {
			[CCode (cname = "xcb_input_open_device_class_info_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned InputClassInfo[] class_info {
			[CCode (cname = "xcb_input_open_device_class_info")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_open_device_cookie_t")]
	public struct OpenDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_open_device_reply", instance_pos = 1.1)]
		public OpenDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_set_device_mode_reply_t", free_function = "free")]
	public class SetDeviceModeReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_set_device_mode_cookie_t")]
	public struct SetDeviceModeCookie : VoidCookie {
		[CCode (cname = "xcb_input_set_device_mode_reply", instance_pos = 1.1)]
		public SetDeviceModeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_motion_events_reply_t", free_function = "free")]
	public class GetDeviceMotionEventsReply {
		public uint32 num_events;
		public uint8 num_axes;
		public ValuatorMode device_mode;
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_motion_events_cookie_t")]
	public struct GetDeviceMotionEventsCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_motion_events_reply", instance_pos = 1.1)]
		public GetDeviceMotionEventsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_change_keyboard_device_reply_t", free_function = "free")]
	public class ChangeKeyboardDeviceReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_change_keyboard_device_cookie_t")]
	public struct ChangeKeyboardDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_change_keyboard_device_reply", instance_pos = 1.1)]
		public ChangeKeyboardDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_change_pointer_device_reply_t", free_function = "free")]
	public class ChangePointerDeviceReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_change_pointer_device_cookie_t")]
	public struct ChangePointerDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_change_pointer_device_reply", instance_pos = 1.1)]
		public ChangePointerDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_focus_reply_t", free_function = "free")]
	public class GetDeviceFocusReply {
		public Window focus;
		public Timestamp time;
		public uint8 revert_to;
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_focus_cookie_t")]
	public struct GetDeviceFocusCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_focus_reply", instance_pos = 1.1)]
		public GetDeviceFocusReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_feedback_control_reply_t", free_function = "free")]
	public class GetFeedbackControlReply {
		public uint16 num_feedbacks;
		[CCode (cname = "xcb_input_get_feedback_control_feedbacks_iterator")]
		_FeedbackStateIterator _iterator ();
		public FeedbackStateIterator iterator () {
			return (FeedbackStateIterator) _iterator ();
		}
		public int feedbacks_length {
			[CCode (cname = "xcb_input_get_feedback_control_feedbacks_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned FeedbackState[] feedbacks {
			[CCode (cname = "xcb_input_get_feedback_control_feedbacks")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_feedback_control_cookie_t")]
	public struct GetFeedbackControlCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_feedback_control_reply", instance_pos = 1.1)]
		public GetFeedbackControlReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_key_mapping_reply_t", free_function = "free")]
	public class GetDeviceKeyMappingReply {
		public uint8 keysyms_per_keycode;
		public int keysyms_length {
			[CCode (cname = "xcb_input_get_device_key_mapping_keysyms_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Keysym[] keysyms {
			[CCode (cname = "xcb_input_get_device_key_mapping_keysyms")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_key_mapping_cookie_t")]
	public struct GetDeviceKeyMappingCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_key_mapping_reply", instance_pos = 1.1)]
		public GetDeviceKeyMappingReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_modifier_mapping_reply_t", free_function = "free")]
	public class GetDeviceModifierMappingReply {
		public uint8 keycodes_per_modifier;
		public int keymaps_length {
			[CCode (cname = "xcb_input_get_device_modifier_mapping_keymaps_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] keymaps {
			[CCode (cname = "xcb_input_get_device_modifier_mapping_keymaps")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_modifier_mapping_cookie_t")]
	public struct GetDeviceModifierMappingCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_modifier_mapping_reply", instance_pos = 1.1)]
		public GetDeviceModifierMappingReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_set_device_modifier_mapping_reply_t", free_function = "free")]
	public class SetDeviceModifierMappingReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_set_device_modifier_mapping_cookie_t")]
	public struct SetDeviceModifierMappingCookie : VoidCookie {
		[CCode (cname = "xcb_input_set_device_modifier_mapping_reply", instance_pos = 1.1)]
		public SetDeviceModifierMappingReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_button_mapping_reply_t", free_function = "free")]
	public class GetDeviceButtonMappingReply {
		public uint8 map_size;
		public int map_length {
			[CCode (cname = "xcb_input_get_device_button_mapping_map_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] map {
			[CCode (cname = "xcb_input_get_device_button_mapping_map")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_button_mapping_cookie_t")]
	public struct GetDeviceButtonMappingCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_button_mapping_reply", instance_pos = 1.1)]
		public GetDeviceButtonMappingReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_set_device_button_mapping_reply_t", free_function = "free")]
	public class SetDeviceButtonMappingReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_set_device_button_mapping_cookie_t")]
	public struct SetDeviceButtonMappingCookie : VoidCookie {
		[CCode (cname = "xcb_input_set_device_button_mapping_reply", instance_pos = 1.1)]
		public SetDeviceButtonMappingReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_query_device_state_reply_t", free_function = "free")]
	public class QueryDeviceStateReply {
		public uint8 num_classes;
		[CCode (cname = "xcb_input_query_device_state_classes_iterator")]
		_InputStateIterator _iterator ();
		public InputStateIterator iterator () {
			return (InputStateIterator) _iterator ();
		}
		public int classes_length {
			[CCode (cname = "xcb_input_query_device_state_classes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned InputState[] classes {
			[CCode (cname = "xcb_input_query_device_state_classes")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_query_device_state_cookie_t")]
	public struct QueryDeviceStateCookie : VoidCookie {
		[CCode (cname = "xcb_input_query_device_state_reply", instance_pos = 1.1)]
		public QueryDeviceStateReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_set_device_valuators_reply_t", free_function = "free")]
	public class SetDeviceValuatorsReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_set_device_valuators_cookie_t")]
	public struct SetDeviceValuatorsCookie : VoidCookie {
		[CCode (cname = "xcb_input_set_device_valuators_reply", instance_pos = 1.1)]
		public SetDeviceValuatorsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_control_reply_t", free_function = "free")]
	public class GetDeviceControlReply {
		public uint8 status;
		public void* pad1;
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_control_cookie_t")]
	public struct GetDeviceControlCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_control_reply", instance_pos = 1.1)]
		public GetDeviceControlReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_change_device_control_reply_t", free_function = "free")]
	public class ChangeDeviceControlReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_change_device_control_cookie_t")]
	public struct ChangeDeviceControlCookie : VoidCookie {
		[CCode (cname = "xcb_input_change_device_control_reply", instance_pos = 1.1)]
		public ChangeDeviceControlReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_list_device_properties_reply_t", free_function = "free")]
	public class ListDevicePropertiesReply {
		public uint16 num_atoms;
		public int atoms_length {
			[CCode (cname = "xcb_input_list_device_properties_atoms_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Atom[] atoms {
			[CCode (cname = "xcb_input_list_device_properties_atoms")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_list_device_properties_cookie_t")]
	public struct ListDevicePropertiesCookie : VoidCookie {
		[CCode (cname = "xcb_input_list_device_properties_reply", instance_pos = 1.1)]
		public ListDevicePropertiesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_query_version_reply_t", free_function = "free")]
	public class XIQueryVersionReply {
		public uint16 major_version;
		public uint16 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_input_xi_query_version_cookie_t")]
	public struct XIQueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_query_version_reply", instance_pos = 1.1)]
		public XIQueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_query_device_reply_t", free_function = "free")]
	public class XIQueryDeviceReply {
		public uint16 num_infos;
		[CCode (cname = "xcb_input_xi_query_device_infos_iterator")]
		_XIDeviceInfoIterator _iterator ();
		public XIDeviceInfoIterator iterator () {
			return (XIDeviceInfoIterator) _iterator ();
		}
		public int infos_length {
			[CCode (cname = "xcb_input_xi_query_device_infos_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned XIDeviceInfo[] infos {
			[CCode (cname = "xcb_input_xi_query_device_infos")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_xi_query_device_cookie_t")]
	public struct XIQueryDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_query_device_reply", instance_pos = 1.1)]
		public XIQueryDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_get_focus_reply_t", free_function = "free")]
	public class XIGetFocusReply {
		public Window focus;
	}

	[SimpleType, CCode (cname = "xcb_input_xi_get_focus_cookie_t")]
	public struct XIGetFocusCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_get_focus_reply", instance_pos = 1.1)]
		public XIGetFocusReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_list_properties_reply_t", free_function = "free")]
	public class XIListPropertiesReply {
		public uint16 num_properties;
		public int properties_length {
			[CCode (cname = "xcb_input_xi_list_properties_properties_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Atom[] properties {
			[CCode (cname = "xcb_input_xi_list_properties_properties")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_xi_list_properties_cookie_t")]
	public struct XIListPropertiesCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_list_properties_reply", instance_pos = 1.1)]
		public XIListPropertiesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_input_select_extension_event", instance_pos = 1.1)]
		public VoidCookie select_extension_event (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]EventClass[]? classes);
		[CCode (cname = "xcb_input_select_extension_event_checked", instance_pos = 1.1)]
		public VoidCookie select_extension_event_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]EventClass[]? classes);
		[CCode (cname = "xcb_input_get_selected_extension_events", instance_pos = 1.1)]
		public GetSelectedExtensionEventsCookie get_selected_extension_events (Xcb.Connection connection);
		[CCode (cname = "xcb_input_change_device_dont_propagate_list", instance_pos = 1.1)]
		public VoidCookie change_device_dont_propagate_list (Xcb.Connection connection, PropagateMode mode, [CCode (array_length_pos = 1.2)]EventClass[]? classes);
		[CCode (cname = "xcb_input_change_device_dont_propagate_list_checked", instance_pos = 1.1)]
		public VoidCookie change_device_dont_propagate_list_checked (Xcb.Connection connection, PropagateMode mode, [CCode (array_length_pos = 1.2)]EventClass[]? classes);
		[CCode (cname = "xcb_input_get_device_dont_propagate_list", instance_pos = 1.1)]
		public GetDeviceDontPropagateListCookie get_device_dont_propagate_list (Xcb.Connection connection);
		[CCode (cname = "xcb_input_grab_device", instance_pos = 1.1)]
		public GrabDeviceCookie grab_device (Xcb.Connection connection, Timestamp time, uint8 this_device_mode, uint8 other_device_mode, bool owner_events, uint8 device_id, [CCode (array_length_pos = 2.3)]EventClass[]? classes);
		[CCode (cname = "xcb_input_grab_device_key", instance_pos = 1.1)]
		public VoidCookie grab_device_key (Xcb.Connection connection, uint16 modifiers, uint8 modifier_device, uint8 grabbed_device, uint8 key, uint8 this_device_mode, uint8 other_device_mode, bool owner_events, [CCode (array_length_pos = 1.2)]EventClass[]? classes);
		[CCode (cname = "xcb_input_grab_device_key_checked", instance_pos = 1.1)]
		public VoidCookie grab_device_key_checked (Xcb.Connection connection, uint16 modifiers, uint8 modifier_device, uint8 grabbed_device, uint8 key, uint8 this_device_mode, uint8 other_device_mode, bool owner_events, [CCode (array_length_pos = 1.2)]EventClass[]? classes);
		[CCode (cname = "xcb_input_ungrab_device_key", instance_pos = 1.1)]
		public VoidCookie ungrab_device_key (Xcb.Connection connection, uint16 modifiers, uint8 modifier_device, uint8 key, uint8 grabbed_device);
		[CCode (cname = "xcb_input_ungrab_device_key_checked", instance_pos = 1.1)]
		public VoidCookie ungrab_device_key_checked (Xcb.Connection connection, uint16 modifiers, uint8 modifier_device, uint8 key, uint8 grabbed_device);
		[CCode (cname = "xcb_input_grab_device_button", instance_pos = 1.1)]
		public VoidCookie grab_device_button (Xcb.Connection connection, uint8 grabbed_device, uint8 modifier_device, uint16 modifiers, uint8 this_device_mode, uint8 other_device_mode, uint8 button, uint8 owner_events, [CCode (array_length_pos = 3.4)]EventClass[]? classes);
		[CCode (cname = "xcb_input_grab_device_button_checked", instance_pos = 1.1)]
		public VoidCookie grab_device_button_checked (Xcb.Connection connection, uint8 grabbed_device, uint8 modifier_device, uint16 modifiers, uint8 this_device_mode, uint8 other_device_mode, uint8 button, uint8 owner_events, [CCode (array_length_pos = 3.4)]EventClass[]? classes);
		[CCode (cname = "xcb_input_ungrab_device_button", instance_pos = 1.1)]
		public VoidCookie ungrab_device_button (Xcb.Connection connection, uint16 modifiers, uint8 modifier_device, uint8 button, uint8 grabbed_device);
		[CCode (cname = "xcb_input_ungrab_device_button_checked", instance_pos = 1.1)]
		public VoidCookie ungrab_device_button_checked (Xcb.Connection connection, uint16 modifiers, uint8 modifier_device, uint8 button, uint8 grabbed_device);
		[CCode (cname = "xcb_input_set_device_focus", instance_pos = 1.1)]
		public VoidCookie set_device_focus (Xcb.Connection connection, Timestamp time, uint8 revert_to, uint8 device_id);
		[CCode (cname = "xcb_input_set_device_focus_checked", instance_pos = 1.1)]
		public VoidCookie set_device_focus_checked (Xcb.Connection connection, Timestamp time, uint8 revert_to, uint8 device_id);
		[CCode (cname = "xcb_input_send_extension_event", instance_pos = 1.1)]
		public VoidCookie send_extension_event (Xcb.Connection connection, uint8 device_id, bool propagate, [CCode (array_length_pos = 4.5)]uint8[]? events, [CCode (array_length_pos = 3.4)]EventClass[]? classes);
		[CCode (cname = "xcb_input_send_extension_event_checked", instance_pos = 1.1)]
		public VoidCookie send_extension_event_checked (Xcb.Connection connection, uint8 device_id, bool propagate, [CCode (array_length_pos = 4.5)]uint8[]? events, [CCode (array_length_pos = 3.4)]EventClass[]? classes);
		[CCode (cname = "xcb_input_xi_query_pointer", instance_pos = 1.1)]
		public XIQueryPointerCookie xi_query_pointer (Xcb.Connection connection, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_warp_pointer", instance_pos = 1.1)]
		public VoidCookie xi_warp_pointer (Xcb.Connection connection, Window dst_win, Fp1616 src_x, Fp1616 src_y, uint16 src_width, uint16 src_height, Fp1616 dst_x, Fp1616 dst_y, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_warp_pointer_checked", instance_pos = 1.1)]
		public VoidCookie xi_warp_pointer_checked (Xcb.Connection connection, Window dst_win, Fp1616 src_x, Fp1616 src_y, uint16 src_width, uint16 src_height, Fp1616 dst_x, Fp1616 dst_y, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_change_cursor", instance_pos = 1.1)]
		public VoidCookie xi_change_cursor (Xcb.Connection connection, Cursor cursor, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_change_cursor_checked", instance_pos = 1.1)]
		public VoidCookie xi_change_cursor_checked (Xcb.Connection connection, Cursor cursor, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_set_client_pointer", instance_pos = 1.1)]
		public VoidCookie xi_set_client_pointer (Xcb.Connection connection, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_set_client_pointer_checked", instance_pos = 1.1)]
		public VoidCookie xi_set_client_pointer_checked (Xcb.Connection connection, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_get_client_pointer", instance_pos = 1.1)]
		public XIGetClientPointerCookie xi_get_client_pointer (Xcb.Connection connection);
		[CCode (cname = "xcb_input_xi_select_events", instance_pos = 1.1)]
		public VoidCookie xi_select_events (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]EventMask[]? masks);
		[CCode (cname = "xcb_input_xi_select_events_checked", instance_pos = 1.1)]
		public VoidCookie xi_select_events_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]EventMask[]? masks);
		[CCode (cname = "xcb_input_xi_set_focus", instance_pos = 1.1)]
		public VoidCookie xi_set_focus (Xcb.Connection connection, Timestamp time, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_set_focus_checked", instance_pos = 1.1)]
		public VoidCookie xi_set_focus_checked (Xcb.Connection connection, Timestamp time, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_grab_device", instance_pos = 1.1)]
		public XIGrabDeviceCookie xi_grab_device (Xcb.Connection connection, Timestamp time, Cursor cursor, DeviceId deviceid, uint8 mode, uint8 paired_device_mode, GrabOwner owner_events, [CCode (array_length_pos = 7.8)]uint32[]? mask);
		[CCode (cname = "xcb_input_xi_allow_events", instance_pos = 5.5)]
		public VoidCookie xi_allow_events (Xcb.Connection connection, Timestamp time, DeviceId deviceid, EventMode event_mode, uint32 touchid);
		[CCode (cname = "xcb_input_xi_allow_events_checked", instance_pos = 5.5)]
		public VoidCookie xi_allow_events_checked (Xcb.Connection connection, Timestamp time, DeviceId deviceid, EventMode event_mode, uint32 touchid);
		[CCode (cname = "xcb_input_xi_passive_grab_device", instance_pos = 2.2)]
		public XIPassiveGrabDeviceCookie xi_passive_grab_device (Xcb.Connection connection, Timestamp time, Cursor cursor, uint32 detail, DeviceId deviceid, GrabType grab_type, GrabMode22 grab_mode, uint8 paired_device_mode, GrabOwner owner_events, [CCode (array_length_pos = 6.7)]uint32[]? mask, [CCode (array_length_pos = 5.6)]uint32[]? modifiers);
		[CCode (cname = "xcb_input_xi_passive_ungrab_device", instance_pos = 1.1)]
		public VoidCookie xi_passive_ungrab_device (Xcb.Connection connection, uint32 detail, DeviceId deviceid, GrabType grab_type, [CCode (array_length_pos = 3.4)]uint32[]? modifiers);
		[CCode (cname = "xcb_input_xi_passive_ungrab_device_checked", instance_pos = 1.1)]
		public VoidCookie xi_passive_ungrab_device_checked (Xcb.Connection connection, uint32 detail, DeviceId deviceid, GrabType grab_type, [CCode (array_length_pos = 3.4)]uint32[]? modifiers);
		[CCode (cname = "xcb_input_xi_get_selected_events", instance_pos = 1.1)]
		public XIGetSelectedEventsCookie xi_get_selected_events (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_input_get_selected_extension_events_reply_t", free_function = "free")]
	public class GetSelectedExtensionEventsReply {
		public uint16 num_this_classes;
		public uint16 num_all_classes;
		public int this_classes_length {
			[CCode (cname = "xcb_input_get_selected_extension_events_this_classes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned EventClass[] this_classes {
			[CCode (cname = "xcb_input_get_selected_extension_events_this_classes")]
			get;
		}
		public int all_classes_length {
			[CCode (cname = "xcb_input_get_selected_extension_events_all_classes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned EventClass[] all_classes {
			[CCode (cname = "xcb_input_get_selected_extension_events_all_classes")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_selected_extension_events_cookie_t")]
	public struct GetSelectedExtensionEventsCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_selected_extension_events_reply", instance_pos = 1.1)]
		public GetSelectedExtensionEventsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_get_device_dont_propagate_list_reply_t", free_function = "free")]
	public class GetDeviceDontPropagateListReply {
		public uint16 num_classes;
		public int classes_length {
			[CCode (cname = "xcb_input_get_device_dont_propagate_list_classes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned EventClass[] classes {
			[CCode (cname = "xcb_input_get_device_dont_propagate_list_classes")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_dont_propagate_list_cookie_t")]
	public struct GetDeviceDontPropagateListCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_dont_propagate_list_reply", instance_pos = 1.1)]
		public GetDeviceDontPropagateListReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_grab_device_reply_t", free_function = "free")]
	public class GrabDeviceReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_grab_device_cookie_t")]
	public struct GrabDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_grab_device_reply", instance_pos = 1.1)]
		public GrabDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_query_pointer_reply_t", free_function = "free")]
	public class XIQueryPointerReply {
		public Window root;
		public Window child;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public Fp1616 win_x;
		public Fp1616 win_y;
		public uint8 same_screen;
		public uint16 buttons_len;
		public ModifierInfo mods;
		public GroupInfo group;
		public int buttons_length {
			[CCode (cname = "xcb_input_xi_query_pointer_buttons_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] buttons {
			[CCode (cname = "xcb_input_xi_query_pointer_buttons")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_xi_query_pointer_cookie_t")]
	public struct XIQueryPointerCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_query_pointer_reply", instance_pos = 1.1)]
		public XIQueryPointerReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_get_client_pointer_reply_t", free_function = "free")]
	public class XIGetClientPointerReply {
		public bool set;
		public DeviceId deviceid;
	}

	[SimpleType, CCode (cname = "xcb_input_xi_get_client_pointer_cookie_t")]
	public struct XIGetClientPointerCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_get_client_pointer_reply", instance_pos = 1.1)]
		public XIGetClientPointerReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_grab_device_reply_t", free_function = "free")]
	public class XIGrabDeviceReply {
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_xi_grab_device_cookie_t")]
	public struct XIGrabDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_grab_device_reply", instance_pos = 1.1)]
		public XIGrabDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_passive_grab_device_reply_t", free_function = "free")]
	public class XIPassiveGrabDeviceReply {
		public uint16 num_modifiers;
		[CCode (cname = "xcb_input_xi_passive_grab_device_modifiers_iterator")]
		_GrabModifierInfoIterator _iterator ();
		public GrabModifierInfoIterator iterator () {
			return (GrabModifierInfoIterator) _iterator ();
		}
		public int modifiers_length {
			[CCode (cname = "xcb_input_xi_passive_grab_device_modifiers_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned GrabModifierInfo[] modifiers {
			[CCode (cname = "xcb_input_xi_passive_grab_device_modifiers")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_xi_passive_grab_device_cookie_t")]
	public struct XIPassiveGrabDeviceCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_passive_grab_device_reply", instance_pos = 1.1)]
		public XIPassiveGrabDeviceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_get_selected_events_reply_t", free_function = "free")]
	public class XIGetSelectedEventsReply {
		public uint16 num_masks;
		[CCode (cname = "xcb_input_xi_get_selected_events_masks_iterator")]
		_EventMaskIterator _iterator ();
		public EventMaskIterator iterator () {
			return (EventMaskIterator) _iterator ();
		}
		public int masks_length {
			[CCode (cname = "xcb_input_xi_get_selected_events_masks_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned EventMask[] masks {
			[CCode (cname = "xcb_input_xi_get_selected_events_masks")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_xi_get_selected_events_cookie_t")]
	public struct XIGetSelectedEventsCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_get_selected_events_reply", instance_pos = 1.1)]
		public XIGetSelectedEventsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_atom_t", has_type_id = false)]
	public struct Atom : Xcb.Atom {
		[CCode (cname = "xcb_input_change_device_property", instance_pos = 1.1, simple_generics = true)]
		public VoidCookie change_device_property<A> (Xcb.Connection connection, Atom type, uint8 device_id, PropertyFormat format, uint8 mode, [CCode (array_length_pos = 5.6)]A[]? items);
		[CCode (cname = "xcb_input_change_device_property_checked", instance_pos = 1.1, simple_generics = true)]
		public VoidCookie change_device_property_checked<A> (Xcb.Connection connection, Atom type, uint8 device_id, PropertyFormat format, uint8 mode, [CCode (array_length_pos = 5.6)]A[]? items);
		[CCode (cname = "xcb_input_delete_device_property", instance_pos = 1.1)]
		public VoidCookie delete_device_property (Xcb.Connection connection, uint8 device_id);
		[CCode (cname = "xcb_input_delete_device_property_checked", instance_pos = 1.1)]
		public VoidCookie delete_device_property_checked (Xcb.Connection connection, uint8 device_id);
		[CCode (cname = "xcb_input_get_device_property", instance_pos = 1.1)]
		public GetDevicePropertyCookie get_device_property (Xcb.Connection connection, Atom type, uint32 offset, uint32 len, uint8 device_id, bool _delete);
		[CCode (cname = "xcb_input_xi_change_property", instance_pos = 4.4, simple_generics = true)]
		public VoidCookie xi_change_property<A> (Xcb.Connection connection, DeviceId deviceid, uint8 mode, PropertyFormat format, Atom type, [CCode (array_length_pos = 5.6)]A[]? items);
		[CCode (cname = "xcb_input_xi_change_property_checked", instance_pos = 4.4, simple_generics = true)]
		public VoidCookie xi_change_property_checked<A> (Xcb.Connection connection, DeviceId deviceid, uint8 mode, PropertyFormat format, Atom type, [CCode (array_length_pos = 5.6)]A[]? items);
		[CCode (cname = "xcb_input_xi_delete_property", instance_pos = 2.2)]
		public VoidCookie xi_delete_property (Xcb.Connection connection, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_delete_property_checked", instance_pos = 2.2)]
		public VoidCookie xi_delete_property_checked (Xcb.Connection connection, DeviceId deviceid);
		[CCode (cname = "xcb_input_xi_get_property", instance_pos = 3.3)]
		public XIGetPropertyCookie xi_get_property (Xcb.Connection connection, DeviceId deviceid, bool _delete, Atom type, uint32 offset, uint32 len);
	}

	[Compact, CCode (cname = "xcb_input_get_device_property_reply_t", free_function = "free")]
	public class GetDevicePropertyReply {
		public Atom type;
		public uint32 bytes_after;
		public uint32 num_items;
		public PropertyFormat format;
		public uint8 device_id;
		[CCode (array_length = false)]
		public unowned void[] items {
			[CCode (cname = "xcb_input_get_device_property_items")]
			get;
		}
		[CCode (cname = "xcb_input_get_device_property_items_data_8_length")]
		public int items_data_8_length ([CCode (array_length = false)]void[] items);
		[CCode (array_length = false)]
		public unowned uint8[] items_data_8 {
			[CCode (cname = "xcb_input_get_device_property_items")]
			get;
		}
		[CCode (cname = "xcb_input_get_device_property_items_data_16_length")]
		public int items_data_16_length ([CCode (array_length = false)]void[] items);
		[CCode (array_length = false)]
		public unowned uint16[] items_data_16 {
			[CCode (cname = "xcb_input_get_device_property_items")]
			get;
		}
		[CCode (cname = "xcb_input_get_device_property_items_data_32_length")]
		public int items_data_32_length ([CCode (array_length = false)]void[] items);
		[CCode (array_length = false)]
		public unowned uint32[] items_data_32 {
			[CCode (cname = "xcb_input_get_device_property_items")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_get_device_property_cookie_t")]
	public struct GetDevicePropertyCookie : VoidCookie {
		[CCode (cname = "xcb_input_get_device_property_reply", instance_pos = 1.1)]
		public GetDevicePropertyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_input_xi_get_property_reply_t", free_function = "free")]
	public class XIGetPropertyReply {
		public Atom type;
		public uint32 bytes_after;
		public uint32 num_items;
		public PropertyFormat format;
		[CCode (array_length = false)]
		public unowned void[] items {
			[CCode (cname = "xcb_input_xi_get_property_items")]
			get;
		}
		[CCode (cname = "xcb_input_xi_get_property_items_data_8_length")]
		public int items_data_8_length ([CCode (array_length = false)]void[] items);
		[CCode (array_length = false)]
		public unowned uint8[] items_data_8 {
			[CCode (cname = "xcb_input_xi_get_property_items")]
			get;
		}
		[CCode (cname = "xcb_input_xi_get_property_items_data_16_length")]
		public int items_data_16_length ([CCode (array_length = false)]void[] items);
		[CCode (array_length = false)]
		public unowned uint16[] items_data_16 {
			[CCode (cname = "xcb_input_xi_get_property_items")]
			get;
		}
		[CCode (cname = "xcb_input_xi_get_property_items_data_32_length")]
		public int items_data_32_length ([CCode (array_length = false)]void[] items);
		[CCode (array_length = false)]
		public unowned uint32[] items_data_32 {
			[CCode (cname = "xcb_input_xi_get_property_items")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_xi_get_property_cookie_t")]
	public struct XIGetPropertyCookie : VoidCookie {
		[CCode (cname = "xcb_input_xi_get_property_reply", instance_pos = 1.1)]
		public XIGetPropertyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_input_event_class_t", has_type_id = false)]
	public struct EventClass : uint32 {
	}

	[SimpleType, CCode (cname = "xcb_input_key_code_t", has_type_id = false)]
	public struct KeyCode : uint8 {
	}

	[SimpleType, CCode (cname = "xcb_input_device_id_t", has_type_id = false)]
	public struct DeviceId : uint16 {
	}

	[SimpleType, CCode (cname = "xcb_input_fp1616_t", has_type_id = false)]
	public struct Fp1616 : int32 {
	}

	[SimpleType, CCode (cname = "xcb_input_fp3232_iterator_t")]
	struct _Fp3232Iterator
	{
		int rem;
		int index;
		unowned Fp3232? data;
	}

	[CCode (cname = "xcb_input_fp3232_iterator_t")]
	public struct Fp3232Iterator
	{
		[CCode (cname = "xcb_input_fp3232_next")]
		void _next ();

		public inline unowned Fp3232?
		next_value ()
		{
			if (((_Fp3232Iterator)this).rem > 0)
			{
				unowned Fp3232? d = ((_Fp3232Iterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_fp3232_t", has_type_id = false)]
	public struct Fp3232 {
		public int32 integral;
		public uint32 frac;
	}

	[CCode (cname = "xcb_input_device_use_t", cprefix =  "XCB_INPUT_DEVICE_USE_", has_type_id = false)]
	public enum DeviceUse {
		IS_X_POINTER,
		IS_X_KEYBOARD,
		IS_X_EXTENSION_DEVICE,
		IS_X_EXTENSION_KEYBOARD,
		IS_X_EXTENSION_POINTER
	}

	[CCode (cname = "xcb_input_input_class_t", cprefix =  "XCB_INPUT_INPUT_CLASS_", has_type_id = false)]
	public enum InputClass {
		KEY,
		BUTTON,
		VALUATOR,
		FEEDBACK,
		PROXIMITY,
		FOCUS,
		OTHER
	}

	[CCode (cname = "xcb_input_valuator_mode_t", cprefix =  "XCB_INPUT_VALUATOR_MODE_", has_type_id = false)]
	public enum ValuatorMode {
		RELATIVE,
		ABSOLUTE
	}

	[SimpleType, CCode (cname = "xcb_input_device_info_iterator_t")]
	struct _DeviceInfoIterator
	{
		int rem;
		int index;
		unowned DeviceInfo? data;
	}

	[CCode (cname = "xcb_input_device_info_iterator_t")]
	public struct DeviceInfoIterator
	{
		[CCode (cname = "xcb_input_device_info_next")]
		void _next ();

		public inline unowned DeviceInfo?
		next_value ()
		{
			if (((_DeviceInfoIterator)this).rem > 0)
			{
				unowned DeviceInfo? d = ((_DeviceInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_info_t", has_type_id = false)]
	public struct DeviceInfo {
		public Atom device_type;
		public uint8 device_id;
		public uint8 num_class_info;
		public DeviceUse device_use;
	}

	[SimpleType, CCode (cname = "xcb_input_key_info_iterator_t")]
	struct _KeyInfoIterator
	{
		int rem;
		int index;
		unowned KeyInfo? data;
	}

	[CCode (cname = "xcb_input_key_info_iterator_t")]
	public struct KeyInfoIterator
	{
		[CCode (cname = "xcb_input_key_info_next")]
		void _next ();

		public inline unowned KeyInfo?
		next_value ()
		{
			if (((_KeyInfoIterator)this).rem > 0)
			{
				unowned KeyInfo? d = ((_KeyInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_key_info_t", has_type_id = false)]
	public struct KeyInfo {
		public InputClass class_id;
		public uint8 len;
		public Keycode min_keycode;
		public Keycode max_keycode;
		public uint16 num_keys;
	}

	[SimpleType, CCode (cname = "xcb_input_button_info_iterator_t")]
	struct _ButtonInfoIterator
	{
		int rem;
		int index;
		unowned ButtonInfo? data;
	}

	[CCode (cname = "xcb_input_button_info_iterator_t")]
	public struct ButtonInfoIterator
	{
		[CCode (cname = "xcb_input_button_info_next")]
		void _next ();

		public inline unowned ButtonInfo?
		next_value ()
		{
			if (((_ButtonInfoIterator)this).rem > 0)
			{
				unowned ButtonInfo? d = ((_ButtonInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_button_info_t", has_type_id = false)]
	public struct ButtonInfo {
		public InputClass class_id;
		public uint8 len;
		public uint16 num_buttons;
	}

	[SimpleType, CCode (cname = "xcb_input_axis_info_iterator_t")]
	struct _AxisInfoIterator
	{
		int rem;
		int index;
		unowned AxisInfo? data;
	}

	[CCode (cname = "xcb_input_axis_info_iterator_t")]
	public struct AxisInfoIterator
	{
		[CCode (cname = "xcb_input_axis_info_next")]
		void _next ();

		public inline unowned AxisInfo?
		next_value ()
		{
			if (((_AxisInfoIterator)this).rem > 0)
			{
				unowned AxisInfo? d = ((_AxisInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_axis_info_t", has_type_id = false)]
	public struct AxisInfo {
		public uint32 resolution;
		public int32 minimum;
		public int32 maximum;
	}

	[SimpleType, CCode (cname = "xcb_input_valuator_info_iterator_t")]
	struct _ValuatorInfoIterator
	{
		int rem;
		int index;
		unowned ValuatorInfo? data;
	}

	[CCode (cname = "xcb_input_valuator_info_iterator_t")]
	public struct ValuatorInfoIterator
	{
		[CCode (cname = "xcb_input_valuator_info_next")]
		void _next ();

		public inline unowned ValuatorInfo?
		next_value ()
		{
			if (((_ValuatorInfoIterator)this).rem > 0)
			{
				unowned ValuatorInfo? d = ((_ValuatorInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_valuator_info_t", has_type_id = false)]
	public struct ValuatorInfo {
		public InputClass class_id;
		public uint8 len;
		public uint8 axes_len;
		public ValuatorMode mode;
		public uint32 motion_size;
		[CCode (cname = "xcb_input_valuator_info_axes_iterator")]
		_AxisInfoIterator _iterator ();
		public AxisInfoIterator iterator () {
			return (AxisInfoIterator) _iterator ();
		}
	}

	[SimpleType, CCode (cname = "xcb_input_input_info_iterator_t")]
	struct _InputInfoIterator
	{
		int rem;
		int index;
		unowned InputInfo? data;
	}

	[CCode (cname = "xcb_input_input_info_iterator_t")]
	public struct InputInfoIterator
	{
		[CCode (cname = "xcb_input_input_info_next")]
		void _next ();

		public inline unowned InputInfo?
		next_value ()
		{
			if (((_InputInfoIterator)this).rem > 0)
			{
				unowned InputInfo? d = ((_InputInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_input_info_t", has_type_id = false)]
	public struct InputInfo {
		public InputClass class_id;
		public uint8 len;
	}

	[SimpleType, CCode (cname = "xcb_input_device_name_iterator_t")]
	struct _DeviceNameIterator
	{
		int rem;
		int index;
		unowned DeviceName? data;
	}

	[CCode (cname = "xcb_input_device_name_iterator_t")]
	public struct DeviceNameIterator
	{
		[CCode (cname = "xcb_input_device_name_next")]
		void _next ();

		public inline unowned DeviceName?
		next_value ()
		{
			if (((_DeviceNameIterator)this).rem > 0)
			{
				unowned DeviceName? d = ((_DeviceNameIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_name_t", has_type_id = false)]
	public struct DeviceName {
		public uint8 len;
	}

	[SimpleType, CCode (cname = "xcb_input_input_class_info_iterator_t")]
	struct _InputClassInfoIterator
	{
		int rem;
		int index;
		unowned InputClassInfo? data;
	}

	[CCode (cname = "xcb_input_input_class_info_iterator_t")]
	public struct InputClassInfoIterator
	{
		[CCode (cname = "xcb_input_input_class_info_next")]
		void _next ();

		public inline unowned InputClassInfo?
		next_value ()
		{
			if (((_InputClassInfoIterator)this).rem > 0)
			{
				unowned InputClassInfo? d = ((_InputClassInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_input_class_info_t", has_type_id = false)]
	public struct InputClassInfo {
		public InputClass class_id;
		public uint8 event_type_base;
	}

	[CCode (cname = "xcb_input_propagate_mode_t", cprefix =  "XCB_INPUT_PROPAGATE_MODE_", has_type_id = false)]
	public enum PropagateMode {
		ADD_TO_LIST,
		DELETE_FROM_LIST
	}

	[SimpleType, CCode (cname = "xcb_input_device_time_coord_iterator_t")]
	struct _DeviceTimeCoordIterator
	{
		int rem;
		int index;
		unowned DeviceTimeCoord? data;
	}

	[CCode (cname = "xcb_input_device_time_coord_iterator_t")]
	public struct DeviceTimeCoordIterator
	{
		[CCode (cname = "xcb_input_device_time_coord_next")]
		void _next ();

		public inline unowned DeviceTimeCoord?
		next_value ()
		{
			if (((_DeviceTimeCoordIterator)this).rem > 0)
			{
				unowned DeviceTimeCoord? d = ((_DeviceTimeCoordIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_time_coord_t", has_type_id = false)]
	public struct DeviceTimeCoord {
		public Timestamp time;
	}

	[CCode (cname = "xcb_input_device_input_mode_t", cprefix =  "XCB_INPUT_DEVICE_INPUT_MODE_", has_type_id = false)]
	public enum DeviceInputMode {
		ASYNC_THIS_DEVICE,
		SYNC_THIS_DEVICE,
		REPLAY_THIS_DEVICE,
		ASYNC_OTHER_DEVICES,
		ASYNC_ALL,
		SYNC_ALL
	}

	[CCode (cname = "xcb_input_feedback_class_t", cprefix =  "XCB_INPUT_FEEDBACK_CLASS_", has_type_id = false)]
	public enum FeedbackClass {
		KEYBOARD,
		POINTER,
		STRING,
		INTEGER,
		LED,
		BELL
	}

	[SimpleType, CCode (cname = "xcb_input_kbd_feedback_state_iterator_t")]
	struct _KbdFeedbackStateIterator
	{
		int rem;
		int index;
		unowned KbdFeedbackState? data;
	}

	[CCode (cname = "xcb_input_kbd_feedback_state_iterator_t")]
	public struct KbdFeedbackStateIterator
	{
		[CCode (cname = "xcb_input_kbd_feedback_state_next")]
		void _next ();

		public inline unowned KbdFeedbackState?
		next_value ()
		{
			if (((_KbdFeedbackStateIterator)this).rem > 0)
			{
				unowned KbdFeedbackState? d = ((_KbdFeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_kbd_feedback_state_t", has_type_id = false)]
	public struct KbdFeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint16 pitch;
		public uint16 duration;
		public uint32 led_mask;
		public uint32 led_values;
		public bool global_auto_repeat;
		public uint8 click;
		public uint8 percent;
	}

	[SimpleType, CCode (cname = "xcb_input_ptr_feedback_state_iterator_t")]
	struct _PtrFeedbackStateIterator
	{
		int rem;
		int index;
		unowned PtrFeedbackState? data;
	}

	[CCode (cname = "xcb_input_ptr_feedback_state_iterator_t")]
	public struct PtrFeedbackStateIterator
	{
		[CCode (cname = "xcb_input_ptr_feedback_state_next")]
		void _next ();

		public inline unowned PtrFeedbackState?
		next_value ()
		{
			if (((_PtrFeedbackStateIterator)this).rem > 0)
			{
				unowned PtrFeedbackState? d = ((_PtrFeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_ptr_feedback_state_t", has_type_id = false)]
	public struct PtrFeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint16 accel_num;
		public uint16 accel_denom;
		public uint16 threshold;
	}

	[SimpleType, CCode (cname = "xcb_input_integer_feedback_state_iterator_t")]
	struct _IntegerFeedbackStateIterator
	{
		int rem;
		int index;
		unowned IntegerFeedbackState? data;
	}

	[CCode (cname = "xcb_input_integer_feedback_state_iterator_t")]
	public struct IntegerFeedbackStateIterator
	{
		[CCode (cname = "xcb_input_integer_feedback_state_next")]
		void _next ();

		public inline unowned IntegerFeedbackState?
		next_value ()
		{
			if (((_IntegerFeedbackStateIterator)this).rem > 0)
			{
				unowned IntegerFeedbackState? d = ((_IntegerFeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_integer_feedback_state_t", has_type_id = false)]
	public struct IntegerFeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint32 resolution;
		public int32 min_value;
		public int32 max_value;
	}

	[SimpleType, CCode (cname = "xcb_input_string_feedback_state_iterator_t")]
	struct _StringFeedbackStateIterator
	{
		int rem;
		int index;
		unowned StringFeedbackState? data;
	}

	[CCode (cname = "xcb_input_string_feedback_state_iterator_t")]
	public struct StringFeedbackStateIterator
	{
		[CCode (cname = "xcb_input_string_feedback_state_next")]
		void _next ();

		public inline unowned StringFeedbackState?
		next_value ()
		{
			if (((_StringFeedbackStateIterator)this).rem > 0)
			{
				unowned StringFeedbackState? d = ((_StringFeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_string_feedback_state_t", has_type_id = false)]
	public struct StringFeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint16 max_symbols;
		public uint16 num_keysyms;
	}

	[SimpleType, CCode (cname = "xcb_input_bell_feedback_state_iterator_t")]
	struct _BellFeedbackStateIterator
	{
		int rem;
		int index;
		unowned BellFeedbackState? data;
	}

	[CCode (cname = "xcb_input_bell_feedback_state_iterator_t")]
	public struct BellFeedbackStateIterator
	{
		[CCode (cname = "xcb_input_bell_feedback_state_next")]
		void _next ();

		public inline unowned BellFeedbackState?
		next_value ()
		{
			if (((_BellFeedbackStateIterator)this).rem > 0)
			{
				unowned BellFeedbackState? d = ((_BellFeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_bell_feedback_state_t", has_type_id = false)]
	public struct BellFeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint8 percent;
		public uint16 pitch;
		public uint16 duration;
	}

	[SimpleType, CCode (cname = "xcb_input_led_feedback_state_iterator_t")]
	struct _LedFeedbackStateIterator
	{
		int rem;
		int index;
		unowned LedFeedbackState? data;
	}

	[CCode (cname = "xcb_input_led_feedback_state_iterator_t")]
	public struct LedFeedbackStateIterator
	{
		[CCode (cname = "xcb_input_led_feedback_state_next")]
		void _next ();

		public inline unowned LedFeedbackState?
		next_value ()
		{
			if (((_LedFeedbackStateIterator)this).rem > 0)
			{
				unowned LedFeedbackState? d = ((_LedFeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_led_feedback_state_t", has_type_id = false)]
	public struct LedFeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint32 led_mask;
		public uint32 led_values;
	}

	[SimpleType, CCode (cname = "xcb_input_feedback_state_iterator_t")]
	struct _FeedbackStateIterator
	{
		int rem;
		int index;
		unowned FeedbackState? data;
	}

	[CCode (cname = "xcb_input_feedback_state_iterator_t")]
	public struct FeedbackStateIterator
	{
		[CCode (cname = "xcb_input_feedback_state_next")]
		void _next ();

		public inline unowned FeedbackState?
		next_value ()
		{
			if (((_FeedbackStateIterator)this).rem > 0)
			{
				unowned FeedbackState? d = ((_FeedbackStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_feedback_state_t", has_type_id = false)]
	public struct FeedbackState {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
	}

	[SimpleType, CCode (cname = "xcb_input_kbd_feedback_ctl_iterator_t")]
	struct _KbdFeedbackCtlIterator
	{
		int rem;
		int index;
		unowned KbdFeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_kbd_feedback_ctl_iterator_t")]
	public struct KbdFeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_kbd_feedback_ctl_next")]
		void _next ();

		public inline unowned KbdFeedbackCtl?
		next_value ()
		{
			if (((_KbdFeedbackCtlIterator)this).rem > 0)
			{
				unowned KbdFeedbackCtl? d = ((_KbdFeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_kbd_feedback_ctl_t", has_type_id = false)]
	public struct KbdFeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public Keycode key;
		public uint8 auto_repeat_mode;
		public int8 key_click_percent;
		public int8 bell_percent;
		public int16 bell_pitch;
		public int16 bell_duration;
		public uint32 led_mask;
		public uint32 led_values;
	}

	[SimpleType, CCode (cname = "xcb_input_ptr_feedback_ctl_iterator_t")]
	struct _PtrFeedbackCtlIterator
	{
		int rem;
		int index;
		unowned PtrFeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_ptr_feedback_ctl_iterator_t")]
	public struct PtrFeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_ptr_feedback_ctl_next")]
		void _next ();

		public inline unowned PtrFeedbackCtl?
		next_value ()
		{
			if (((_PtrFeedbackCtlIterator)this).rem > 0)
			{
				unowned PtrFeedbackCtl? d = ((_PtrFeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_ptr_feedback_ctl_t", has_type_id = false)]
	public struct PtrFeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public int16 num;
		public int16 denom;
		public int16 threshold;
	}

	[SimpleType, CCode (cname = "xcb_input_integer_feedback_ctl_iterator_t")]
	struct _IntegerFeedbackCtlIterator
	{
		int rem;
		int index;
		unowned IntegerFeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_integer_feedback_ctl_iterator_t")]
	public struct IntegerFeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_integer_feedback_ctl_next")]
		void _next ();

		public inline unowned IntegerFeedbackCtl?
		next_value ()
		{
			if (((_IntegerFeedbackCtlIterator)this).rem > 0)
			{
				unowned IntegerFeedbackCtl? d = ((_IntegerFeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_integer_feedback_ctl_t", has_type_id = false)]
	public struct IntegerFeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public int32 int_to_display;
	}

	[SimpleType, CCode (cname = "xcb_input_string_feedback_ctl_iterator_t")]
	struct _StringFeedbackCtlIterator
	{
		int rem;
		int index;
		unowned StringFeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_string_feedback_ctl_iterator_t")]
	public struct StringFeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_string_feedback_ctl_next")]
		void _next ();

		public inline unowned StringFeedbackCtl?
		next_value ()
		{
			if (((_StringFeedbackCtlIterator)this).rem > 0)
			{
				unowned StringFeedbackCtl? d = ((_StringFeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_string_feedback_ctl_t", has_type_id = false)]
	public struct StringFeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint16 num_keysyms;
	}

	[SimpleType, CCode (cname = "xcb_input_bell_feedback_ctl_iterator_t")]
	struct _BellFeedbackCtlIterator
	{
		int rem;
		int index;
		unowned BellFeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_bell_feedback_ctl_iterator_t")]
	public struct BellFeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_bell_feedback_ctl_next")]
		void _next ();

		public inline unowned BellFeedbackCtl?
		next_value ()
		{
			if (((_BellFeedbackCtlIterator)this).rem > 0)
			{
				unowned BellFeedbackCtl? d = ((_BellFeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_bell_feedback_ctl_t", has_type_id = false)]
	public struct BellFeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public int8 percent;
		public int16 pitch;
		public int16 duration;
	}

	[SimpleType, CCode (cname = "xcb_input_led_feedback_ctl_iterator_t")]
	struct _LedFeedbackCtlIterator
	{
		int rem;
		int index;
		unowned LedFeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_led_feedback_ctl_iterator_t")]
	public struct LedFeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_led_feedback_ctl_next")]
		void _next ();

		public inline unowned LedFeedbackCtl?
		next_value ()
		{
			if (((_LedFeedbackCtlIterator)this).rem > 0)
			{
				unowned LedFeedbackCtl? d = ((_LedFeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_led_feedback_ctl_t", has_type_id = false)]
	public struct LedFeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
		public uint32 led_mask;
		public uint32 led_values;
	}

	[SimpleType, CCode (cname = "xcb_input_feedback_ctl_iterator_t")]
	struct _FeedbackCtlIterator
	{
		int rem;
		int index;
		unowned FeedbackCtl? data;
	}

	[CCode (cname = "xcb_input_feedback_ctl_iterator_t")]
	public struct FeedbackCtlIterator
	{
		[CCode (cname = "xcb_input_feedback_ctl_next")]
		void _next ();

		public inline unowned FeedbackCtl?
		next_value ()
		{
			if (((_FeedbackCtlIterator)this).rem > 0)
			{
				unowned FeedbackCtl? d = ((_FeedbackCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_feedback_ctl_t", has_type_id = false)]
	public struct FeedbackCtl {
		public FeedbackClass class_id;
		public uint8 feedback_id;
		public uint16 len;
	}

	[SimpleType, CCode (cname = "xcb_input_key_state_iterator_t")]
	struct _KeyStateIterator
	{
		int rem;
		int index;
		unowned KeyState? data;
	}

	[CCode (cname = "xcb_input_key_state_iterator_t")]
	public struct KeyStateIterator
	{
		[CCode (cname = "xcb_input_key_state_next")]
		void _next ();

		public inline unowned KeyState?
		next_value ()
		{
			if (((_KeyStateIterator)this).rem > 0)
			{
				unowned KeyState? d = ((_KeyStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_key_state_t", has_type_id = false)]
	public struct KeyState {
		public InputClass class_id;
		public uint8 len;
		public uint8 num_keys;
	}

	[SimpleType, CCode (cname = "xcb_input_button_state_iterator_t")]
	struct _ButtonStateIterator
	{
		int rem;
		int index;
		unowned ButtonState? data;
	}

	[CCode (cname = "xcb_input_button_state_iterator_t")]
	public struct ButtonStateIterator
	{
		[CCode (cname = "xcb_input_button_state_next")]
		void _next ();

		public inline unowned ButtonState?
		next_value ()
		{
			if (((_ButtonStateIterator)this).rem > 0)
			{
				unowned ButtonState? d = ((_ButtonStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_button_state_t", has_type_id = false)]
	public struct ButtonState {
		public InputClass class_id;
		public uint8 len;
		public uint8 num_buttons;
	}

	[SimpleType, CCode (cname = "xcb_input_valuator_state_iterator_t")]
	struct _ValuatorStateIterator
	{
		int rem;
		int index;
		unowned ValuatorState? data;
	}

	[CCode (cname = "xcb_input_valuator_state_iterator_t")]
	public struct ValuatorStateIterator
	{
		[CCode (cname = "xcb_input_valuator_state_next")]
		void _next ();

		public inline unowned ValuatorState?
		next_value ()
		{
			if (((_ValuatorStateIterator)this).rem > 0)
			{
				unowned ValuatorState? d = ((_ValuatorStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_valuator_state_t", has_type_id = false)]
	public struct ValuatorState {
		public InputClass class_id;
		public uint8 len;
		public uint8 num_valuators;
		public uint8 mode;
	}

	[SimpleType, CCode (cname = "xcb_input_input_state_iterator_t")]
	struct _InputStateIterator
	{
		int rem;
		int index;
		unowned InputState? data;
	}

	[CCode (cname = "xcb_input_input_state_iterator_t")]
	public struct InputStateIterator
	{
		[CCode (cname = "xcb_input_input_state_next")]
		void _next ();

		public inline unowned InputState?
		next_value ()
		{
			if (((_InputStateIterator)this).rem > 0)
			{
				unowned InputState? d = ((_InputStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_input_state_t", has_type_id = false)]
	public struct InputState {
		public InputClass class_id;
		public uint8 len;
		public uint8 num_items;
	}

	[CCode (cname = "xcb_input_device_control_t", cprefix =  "XCB_INPUT_DEVICE_CONTROL_", has_type_id = false)]
	public enum DeviceControl {
		RESOLUTION,
		ABS_CALIB,
		CORE,
		ENABLE,
		ABS_AREA
	}

	[SimpleType, CCode (cname = "xcb_input_device_resolution_state_iterator_t")]
	struct _DeviceResolutionStateIterator
	{
		int rem;
		int index;
		unowned DeviceResolutionState? data;
	}

	[CCode (cname = "xcb_input_device_resolution_state_iterator_t")]
	public struct DeviceResolutionStateIterator
	{
		[CCode (cname = "xcb_input_device_resolution_state_next")]
		void _next ();

		public inline unowned DeviceResolutionState?
		next_value ()
		{
			if (((_DeviceResolutionStateIterator)this).rem > 0)
			{
				unowned DeviceResolutionState? d = ((_DeviceResolutionStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_resolution_state_t", has_type_id = false)]
	public struct DeviceResolutionState {
		public DeviceControl control_id;
		public uint16 len;
		public uint32 num_valuators;
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_calib_state_iterator_t")]
	struct _DeviceAbsCalibStateIterator
	{
		int rem;
		int index;
		unowned DeviceAbsCalibState? data;
	}

	[CCode (cname = "xcb_input_device_abs_calib_state_iterator_t")]
	public struct DeviceAbsCalibStateIterator
	{
		[CCode (cname = "xcb_input_device_abs_calib_state_next")]
		void _next ();

		public inline unowned DeviceAbsCalibState?
		next_value ()
		{
			if (((_DeviceAbsCalibStateIterator)this).rem > 0)
			{
				unowned DeviceAbsCalibState? d = ((_DeviceAbsCalibStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_calib_state_t", has_type_id = false)]
	public struct DeviceAbsCalibState {
		public DeviceControl control_id;
		public uint16 len;
		public int32 min_x;
		public int32 max_x;
		public int32 min_y;
		public int32 max_y;
		public uint32 flip_x;
		public uint32 flip_y;
		public uint32 rotation;
		public uint32 button_threshold;
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_area_state_iterator_t")]
	struct _DeviceAbsAreaStateIterator
	{
		int rem;
		int index;
		unowned DeviceAbsAreaState? data;
	}

	[CCode (cname = "xcb_input_device_abs_area_state_iterator_t")]
	public struct DeviceAbsAreaStateIterator
	{
		[CCode (cname = "xcb_input_device_abs_area_state_next")]
		void _next ();

		public inline unowned DeviceAbsAreaState?
		next_value ()
		{
			if (((_DeviceAbsAreaStateIterator)this).rem > 0)
			{
				unowned DeviceAbsAreaState? d = ((_DeviceAbsAreaStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_area_state_t", has_type_id = false)]
	public struct DeviceAbsAreaState {
		public DeviceControl control_id;
		public uint16 len;
		public uint32 offset_x;
		public uint32 offset_y;
		public uint32 width;
		public uint32 height;
		public uint32 screen;
		public uint32 following;
	}

	[SimpleType, CCode (cname = "xcb_input_device_core_state_iterator_t")]
	struct _DeviceCoreStateIterator
	{
		int rem;
		int index;
		unowned DeviceCoreState? data;
	}

	[CCode (cname = "xcb_input_device_core_state_iterator_t")]
	public struct DeviceCoreStateIterator
	{
		[CCode (cname = "xcb_input_device_core_state_next")]
		void _next ();

		public inline unowned DeviceCoreState?
		next_value ()
		{
			if (((_DeviceCoreStateIterator)this).rem > 0)
			{
				unowned DeviceCoreState? d = ((_DeviceCoreStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_core_state_t", has_type_id = false)]
	public struct DeviceCoreState {
		public DeviceControl control_id;
		public uint16 len;
		public uint8 status;
		public uint8 iscore;
	}

	[SimpleType, CCode (cname = "xcb_input_device_enable_state_iterator_t")]
	struct _DeviceEnableStateIterator
	{
		int rem;
		int index;
		unowned DeviceEnableState? data;
	}

	[CCode (cname = "xcb_input_device_enable_state_iterator_t")]
	public struct DeviceEnableStateIterator
	{
		[CCode (cname = "xcb_input_device_enable_state_next")]
		void _next ();

		public inline unowned DeviceEnableState?
		next_value ()
		{
			if (((_DeviceEnableStateIterator)this).rem > 0)
			{
				unowned DeviceEnableState? d = ((_DeviceEnableStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_enable_state_t", has_type_id = false)]
	public struct DeviceEnableState {
		public DeviceControl control_id;
		public uint16 len;
		public uint8 enable;
	}

	[SimpleType, CCode (cname = "xcb_input_device_state_iterator_t")]
	struct _DeviceStateIterator
	{
		int rem;
		int index;
		unowned DeviceState? data;
	}

	[CCode (cname = "xcb_input_device_state_iterator_t")]
	public struct DeviceStateIterator
	{
		[CCode (cname = "xcb_input_device_state_next")]
		void _next ();

		public inline unowned DeviceState?
		next_value ()
		{
			if (((_DeviceStateIterator)this).rem > 0)
			{
				unowned DeviceState? d = ((_DeviceStateIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_state_t", has_type_id = false)]
	public struct DeviceState {
		public DeviceControl control_id;
		public uint16 len;
	}

	[SimpleType, CCode (cname = "xcb_input_device_resolution_ctl_iterator_t")]
	struct _DeviceResolutionCtlIterator
	{
		int rem;
		int index;
		unowned DeviceResolutionCtl? data;
	}

	[CCode (cname = "xcb_input_device_resolution_ctl_iterator_t")]
	public struct DeviceResolutionCtlIterator
	{
		[CCode (cname = "xcb_input_device_resolution_ctl_next")]
		void _next ();

		public inline unowned DeviceResolutionCtl?
		next_value ()
		{
			if (((_DeviceResolutionCtlIterator)this).rem > 0)
			{
				unowned DeviceResolutionCtl? d = ((_DeviceResolutionCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_resolution_ctl_t", has_type_id = false)]
	public struct DeviceResolutionCtl {
		public DeviceControl control_id;
		public uint16 len;
		public uint8 first_valuator;
		public uint8 num_valuators;
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_calib_ctl_iterator_t")]
	struct _DeviceAbsCalibCtlIterator
	{
		int rem;
		int index;
		unowned DeviceAbsCalibCtl? data;
	}

	[CCode (cname = "xcb_input_device_abs_calib_ctl_iterator_t")]
	public struct DeviceAbsCalibCtlIterator
	{
		[CCode (cname = "xcb_input_device_abs_calib_ctl_next")]
		void _next ();

		public inline unowned DeviceAbsCalibCtl?
		next_value ()
		{
			if (((_DeviceAbsCalibCtlIterator)this).rem > 0)
			{
				unowned DeviceAbsCalibCtl? d = ((_DeviceAbsCalibCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_calib_ctl_t", has_type_id = false)]
	public struct DeviceAbsCalibCtl {
		public DeviceControl control_id;
		public uint16 len;
		public int32 min_x;
		public int32 max_x;
		public int32 min_y;
		public int32 max_y;
		public uint32 flip_x;
		public uint32 flip_y;
		public uint32 rotation;
		public uint32 button_threshold;
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_area_ctrl_iterator_t")]
	struct _DeviceAbsAreaCtrlIterator
	{
		int rem;
		int index;
		unowned DeviceAbsAreaCtrl? data;
	}

	[CCode (cname = "xcb_input_device_abs_area_ctrl_iterator_t")]
	public struct DeviceAbsAreaCtrlIterator
	{
		[CCode (cname = "xcb_input_device_abs_area_ctrl_next")]
		void _next ();

		public inline unowned DeviceAbsAreaCtrl?
		next_value ()
		{
			if (((_DeviceAbsAreaCtrlIterator)this).rem > 0)
			{
				unowned DeviceAbsAreaCtrl? d = ((_DeviceAbsAreaCtrlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_abs_area_ctrl_t", has_type_id = false)]
	public struct DeviceAbsAreaCtrl {
		public DeviceControl control_id;
		public uint16 len;
		public uint32 offset_x;
		public uint32 offset_y;
		public int32 width;
		public int32 height;
		public int32 screen;
		public uint32 following;
	}

	[SimpleType, CCode (cname = "xcb_input_device_core_ctrl_iterator_t")]
	struct _DeviceCoreCtrlIterator
	{
		int rem;
		int index;
		unowned DeviceCoreCtrl? data;
	}

	[CCode (cname = "xcb_input_device_core_ctrl_iterator_t")]
	public struct DeviceCoreCtrlIterator
	{
		[CCode (cname = "xcb_input_device_core_ctrl_next")]
		void _next ();

		public inline unowned DeviceCoreCtrl?
		next_value ()
		{
			if (((_DeviceCoreCtrlIterator)this).rem > 0)
			{
				unowned DeviceCoreCtrl? d = ((_DeviceCoreCtrlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_core_ctrl_t", has_type_id = false)]
	public struct DeviceCoreCtrl {
		public DeviceControl control_id;
		public uint16 len;
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_device_enable_ctrl_iterator_t")]
	struct _DeviceEnableCtrlIterator
	{
		int rem;
		int index;
		unowned DeviceEnableCtrl? data;
	}

	[CCode (cname = "xcb_input_device_enable_ctrl_iterator_t")]
	public struct DeviceEnableCtrlIterator
	{
		[CCode (cname = "xcb_input_device_enable_ctrl_next")]
		void _next ();

		public inline unowned DeviceEnableCtrl?
		next_value ()
		{
			if (((_DeviceEnableCtrlIterator)this).rem > 0)
			{
				unowned DeviceEnableCtrl? d = ((_DeviceEnableCtrlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_enable_ctrl_t", has_type_id = false)]
	public struct DeviceEnableCtrl {
		public DeviceControl control_id;
		public uint16 len;
		public uint8 enable;
	}

	[SimpleType, CCode (cname = "xcb_input_device_ctl_iterator_t")]
	struct _DeviceCtlIterator
	{
		int rem;
		int index;
		unowned DeviceCtl? data;
	}

	[CCode (cname = "xcb_input_device_ctl_iterator_t")]
	public struct DeviceCtlIterator
	{
		[CCode (cname = "xcb_input_device_ctl_next")]
		void _next ();

		public inline unowned DeviceCtl?
		next_value ()
		{
			if (((_DeviceCtlIterator)this).rem > 0)
			{
				unowned DeviceCtl? d = ((_DeviceCtlIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_ctl_t", has_type_id = false)]
	public struct DeviceCtl {
		public DeviceControl control_id;
		public uint16 len;
	}

	[CCode (cname = "xcb_input_property_format_t", cprefix =  "XCB_INPUT_PROPERTY_FORMAT_", has_type_id = false)]
	public enum PropertyFormat {
		8_BITS,
		16_BITS,
		32_BITS
	}

	[CCode (cname = "xcb_input_device_t", cprefix =  "XCB_INPUT_DEVICE_", has_type_id = false)]
	public enum Device {
		ALL,
		ALL_MASTER
	}

	[SimpleType, CCode (cname = "xcb_input_group_info_iterator_t")]
	struct _GroupInfoIterator
	{
		int rem;
		int index;
		unowned GroupInfo? data;
	}

	[CCode (cname = "xcb_input_group_info_iterator_t")]
	public struct GroupInfoIterator
	{
		[CCode (cname = "xcb_input_group_info_next")]
		void _next ();

		public inline unowned GroupInfo?
		next_value ()
		{
			if (((_GroupInfoIterator)this).rem > 0)
			{
				unowned GroupInfo? d = ((_GroupInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_group_info_t", has_type_id = false)]
	public struct GroupInfo {
		public uint8 base;
		public uint8 latched;
		public uint8 locked;
		public uint8 effective;
	}

	[SimpleType, CCode (cname = "xcb_input_modifier_info_iterator_t")]
	struct _ModifierInfoIterator
	{
		int rem;
		int index;
		unowned ModifierInfo? data;
	}

	[CCode (cname = "xcb_input_modifier_info_iterator_t")]
	public struct ModifierInfoIterator
	{
		[CCode (cname = "xcb_input_modifier_info_next")]
		void _next ();

		public inline unowned ModifierInfo?
		next_value ()
		{
			if (((_ModifierInfoIterator)this).rem > 0)
			{
				unowned ModifierInfo? d = ((_ModifierInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_modifier_info_t", has_type_id = false)]
	public struct ModifierInfo {
		public uint32 base;
		public uint32 latched;
		public uint32 locked;
		public uint32 effective;
	}

	[CCode (cname = "xcb_input_hierarchy_change_type_t", cprefix =  "XCB_INPUT_HIERARCHY_CHANGE_TYPE_", has_type_id = false)]
	public enum HierarchyChangeType {
		ADD_MASTER,
		REMOVE_MASTER,
		ATTACH_SLAVE,
		DETACH_SLAVE
	}

	[CCode (cname = "xcb_input_change_mode_t", cprefix =  "XCB_INPUT_CHANGE_MODE_", has_type_id = false)]
	public enum ChangeMode {
		ATTACH,
		FLOAT
	}

	[SimpleType, CCode (cname = "xcb_input_add_master_iterator_t")]
	struct _AddMasterIterator
	{
		int rem;
		int index;
		unowned AddMaster? data;
	}

	[CCode (cname = "xcb_input_add_master_iterator_t")]
	public struct AddMasterIterator
	{
		[CCode (cname = "xcb_input_add_master_next")]
		void _next ();

		public inline unowned AddMaster?
		next_value ()
		{
			if (((_AddMasterIterator)this).rem > 0)
			{
				unowned AddMaster? d = ((_AddMasterIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_add_master_t", has_type_id = false)]
	public struct AddMaster {
		public HierarchyChangeType type;
		public uint16 len;
		public uint16 name_len;
		public uint8 send_core;
		public uint8 enable;
	}

	[SimpleType, CCode (cname = "xcb_input_remove_master_iterator_t")]
	struct _RemoveMasterIterator
	{
		int rem;
		int index;
		unowned RemoveMaster? data;
	}

	[CCode (cname = "xcb_input_remove_master_iterator_t")]
	public struct RemoveMasterIterator
	{
		[CCode (cname = "xcb_input_remove_master_next")]
		void _next ();

		public inline unowned RemoveMaster?
		next_value ()
		{
			if (((_RemoveMasterIterator)this).rem > 0)
			{
				unowned RemoveMaster? d = ((_RemoveMasterIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_remove_master_t", has_type_id = false)]
	public struct RemoveMaster {
		public HierarchyChangeType type;
		public uint16 len;
		public DeviceId deviceid;
		public ChangeMode return_mode;
		public DeviceId return_pointer;
		public DeviceId return_keyboard;
	}

	[SimpleType, CCode (cname = "xcb_input_attach_slave_iterator_t")]
	struct _AttachSlaveIterator
	{
		int rem;
		int index;
		unowned AttachSlave? data;
	}

	[CCode (cname = "xcb_input_attach_slave_iterator_t")]
	public struct AttachSlaveIterator
	{
		[CCode (cname = "xcb_input_attach_slave_next")]
		void _next ();

		public inline unowned AttachSlave?
		next_value ()
		{
			if (((_AttachSlaveIterator)this).rem > 0)
			{
				unowned AttachSlave? d = ((_AttachSlaveIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_attach_slave_t", has_type_id = false)]
	public struct AttachSlave {
		public HierarchyChangeType type;
		public uint16 len;
		public DeviceId deviceid;
		public DeviceId master;
	}

	[SimpleType, CCode (cname = "xcb_input_detach_slave_iterator_t")]
	struct _DetachSlaveIterator
	{
		int rem;
		int index;
		unowned DetachSlave? data;
	}

	[CCode (cname = "xcb_input_detach_slave_iterator_t")]
	public struct DetachSlaveIterator
	{
		[CCode (cname = "xcb_input_detach_slave_next")]
		void _next ();

		public inline unowned DetachSlave?
		next_value ()
		{
			if (((_DetachSlaveIterator)this).rem > 0)
			{
				unowned DetachSlave? d = ((_DetachSlaveIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_detach_slave_t", has_type_id = false)]
	public struct DetachSlave {
		public HierarchyChangeType type;
		public uint16 len;
		public DeviceId deviceid;
	}

	[SimpleType, CCode (cname = "xcb_input_hierarchy_change_iterator_t")]
	struct _HierarchyChangeIterator
	{
		int rem;
		int index;
		unowned HierarchyChange? data;
	}

	[CCode (cname = "xcb_input_hierarchy_change_iterator_t")]
	public struct HierarchyChangeIterator
	{
		[CCode (cname = "xcb_input_hierarchy_change_next")]
		void _next ();

		public inline unowned HierarchyChange?
		next_value ()
		{
			if (((_HierarchyChangeIterator)this).rem > 0)
			{
				unowned HierarchyChange? d = ((_HierarchyChangeIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_hierarchy_change_t", has_type_id = false)]
	public struct HierarchyChange {
		public HierarchyChangeType type;
		public uint16 len;
		}

	[CCode (cname = "xcb_input_xi_event_mask_t", cprefix =  "XCB_INPUT_XI_EVENT_MASK_", has_type_id = false)]
	public enum XIEventMask {
		DEVICE_CHANGED,
		KEY_PRESS,
		KEY_RELEASE,
		BUTTON_PRESS,
		BUTTON_RELEASE,
		MOTION,
		ENTER,
		LEAVE,
		FOCUS_IN,
		FOCUS_OUT,
		HIERARCHY,
		PROPERTY,
		RAW_KEY_PRESS,
		RAW_KEY_RELEASE,
		RAW_BUTTON_PRESS,
		RAW_BUTTON_RELEASE,
		RAW_MOTION,
		TOUCH_BEGIN,
		TOUCH_UPDATE,
		TOUCH_END,
		TOUCH_OWNERSHIP,
		RAW_TOUCH_BEGIN,
		RAW_TOUCH_UPDATE,
		RAW_TOUCH_END,
		BARRIER_HIT,
		BARRIER_LEAVE
	}

	[SimpleType, CCode (cname = "xcb_input_event_mask_iterator_t")]
	struct _EventMaskIterator
	{
		int rem;
		int index;
		unowned EventMask? data;
	}

	[CCode (cname = "xcb_input_event_mask_iterator_t")]
	public struct EventMaskIterator
	{
		[CCode (cname = "xcb_input_event_mask_next")]
		void _next ();

		public inline unowned EventMask?
		next_value ()
		{
			if (((_EventMaskIterator)this).rem > 0)
			{
				unowned EventMask? d = ((_EventMaskIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_event_mask_t", has_type_id = false)]
	public struct EventMask {
		public DeviceId deviceid;
		public uint16 mask_len;
	}

	[CCode (cname = "xcb_input_device_class_type_t", cprefix =  "XCB_INPUT_DEVICE_CLASS_TYPE_", has_type_id = false)]
	public enum DeviceClassType {
		KEY,
		BUTTON,
		VALUATOR,
		SCROLL,
		TOUCH
	}

	[CCode (cname = "xcb_input_device_type_t", cprefix =  "XCB_INPUT_DEVICE_TYPE_", has_type_id = false)]
	public enum DeviceType {
		MASTER_POINTER,
		MASTER_KEYBOARD,
		SLAVE_POINTER,
		SLAVE_KEYBOARD,
		FLOATING_SLAVE
	}

	[CCode (cname = "xcb_input_scroll_flags_t", cprefix =  "XCB_INPUT_SCROLL_FLAGS_", has_type_id = false)]
	public enum ScrollFlags {
		NO_EMULATION,
		PREFERRED
	}

	[CCode (cname = "xcb_input_scroll_type_t", cprefix =  "XCB_INPUT_SCROLL_TYPE_", has_type_id = false)]
	public enum ScrollType {
		VERTICAL,
		HORIZONTAL
	}

	[CCode (cname = "xcb_input_touch_mode_t", cprefix =  "XCB_INPUT_TOUCH_MODE_", has_type_id = false)]
	public enum TouchMode {
		DIRECT,
		DEPENDENT
	}

	[SimpleType, CCode (cname = "xcb_input_button_class_iterator_t")]
	struct _ButtonClassIterator
	{
		int rem;
		int index;
		unowned ButtonClass? data;
	}

	[CCode (cname = "xcb_input_button_class_iterator_t")]
	public struct ButtonClassIterator
	{
		[CCode (cname = "xcb_input_button_class_next")]
		void _next ();

		public inline unowned ButtonClass?
		next_value ()
		{
			if (((_ButtonClassIterator)this).rem > 0)
			{
				unowned ButtonClass? d = ((_ButtonClassIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_button_class_t", has_type_id = false)]
	public struct ButtonClass {
		public DeviceClassType type;
		public uint16 len;
		public DeviceId sourceid;
		public uint16 num_buttons;
	}

	[SimpleType, CCode (cname = "xcb_input_key_class_iterator_t")]
	struct _KeyClassIterator
	{
		int rem;
		int index;
		unowned KeyClass? data;
	}

	[CCode (cname = "xcb_input_key_class_iterator_t")]
	public struct KeyClassIterator
	{
		[CCode (cname = "xcb_input_key_class_next")]
		void _next ();

		public inline unowned KeyClass?
		next_value ()
		{
			if (((_KeyClassIterator)this).rem > 0)
			{
				unowned KeyClass? d = ((_KeyClassIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_key_class_t", has_type_id = false)]
	public struct KeyClass {
		public DeviceClassType type;
		public uint16 len;
		public DeviceId sourceid;
		public uint16 num_keys;
	}

	[SimpleType, CCode (cname = "xcb_input_scroll_class_iterator_t")]
	struct _ScrollClassIterator
	{
		int rem;
		int index;
		unowned ScrollClass? data;
	}

	[CCode (cname = "xcb_input_scroll_class_iterator_t")]
	public struct ScrollClassIterator
	{
		[CCode (cname = "xcb_input_scroll_class_next")]
		void _next ();

		public inline unowned ScrollClass?
		next_value ()
		{
			if (((_ScrollClassIterator)this).rem > 0)
			{
				unowned ScrollClass? d = ((_ScrollClassIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_scroll_class_t", has_type_id = false)]
	public struct ScrollClass {
		public DeviceClassType type;
		public uint16 len;
		public DeviceId sourceid;
		public uint16 number;
		public ScrollType scroll_type;
		public ScrollFlags flags;
		public Fp3232 increment;
	}

	[SimpleType, CCode (cname = "xcb_input_touch_class_iterator_t")]
	struct _TouchClassIterator
	{
		int rem;
		int index;
		unowned TouchClass? data;
	}

	[CCode (cname = "xcb_input_touch_class_iterator_t")]
	public struct TouchClassIterator
	{
		[CCode (cname = "xcb_input_touch_class_next")]
		void _next ();

		public inline unowned TouchClass?
		next_value ()
		{
			if (((_TouchClassIterator)this).rem > 0)
			{
				unowned TouchClass? d = ((_TouchClassIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_touch_class_t", has_type_id = false)]
	public struct TouchClass {
		public DeviceClassType type;
		public uint16 len;
		public DeviceId sourceid;
		public TouchMode mode;
		public uint8 num_touches;
	}

	[SimpleType, CCode (cname = "xcb_input_valuator_class_iterator_t")]
	struct _ValuatorClassIterator
	{
		int rem;
		int index;
		unowned ValuatorClass? data;
	}

	[CCode (cname = "xcb_input_valuator_class_iterator_t")]
	public struct ValuatorClassIterator
	{
		[CCode (cname = "xcb_input_valuator_class_next")]
		void _next ();

		public inline unowned ValuatorClass?
		next_value ()
		{
			if (((_ValuatorClassIterator)this).rem > 0)
			{
				unowned ValuatorClass? d = ((_ValuatorClassIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_valuator_class_t", has_type_id = false)]
	public struct ValuatorClass {
		public DeviceClassType type;
		public uint16 len;
		public DeviceId sourceid;
		public uint16 number;
		public Atom label;
		public Fp3232 min;
		public Fp3232 max;
		public Fp3232 value;
		public uint32 resolution;
		public ValuatorMode mode;
	}

	[SimpleType, CCode (cname = "xcb_input_device_class_iterator_t")]
	struct _DeviceClassIterator
	{
		int rem;
		int index;
		unowned DeviceClass? data;
	}

	[CCode (cname = "xcb_input_device_class_iterator_t")]
	public struct DeviceClassIterator
	{
		[CCode (cname = "xcb_input_device_class_next")]
		void _next ();

		public inline unowned DeviceClass?
		next_value ()
		{
			if (((_DeviceClassIterator)this).rem > 0)
			{
				unowned DeviceClass? d = ((_DeviceClassIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_device_class_t", has_type_id = false)]
	public struct DeviceClass {
		public DeviceClassType type;
		public uint16 len;
		public DeviceId sourceid;
	}

	[SimpleType, CCode (cname = "xcb_input_xi_device_info_iterator_t")]
	struct _XIDeviceInfoIterator
	{
		int rem;
		int index;
		unowned XIDeviceInfo? data;
	}

	[CCode (cname = "xcb_input_xi_device_info_iterator_t")]
	public struct XIDeviceInfoIterator
	{
		[CCode (cname = "xcb_input_xi_device_info_next")]
		void _next ();

		public inline unowned XIDeviceInfo?
		next_value ()
		{
			if (((_XIDeviceInfoIterator)this).rem > 0)
			{
				unowned XIDeviceInfo? d = ((_XIDeviceInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_input_xi_device_info_t", has_type_id = false)]
	public struct XIDeviceInfo {
		public DeviceId deviceid;
		public uint16 type;
		public DeviceId attachment;
		public uint16 num_classes;
		public uint16 name_len;
		public bool enabled;
		[CCode (cname = "xcb_input_xi_device_info_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_input_xi_device_info_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
		[CCode (cname = "xcb_input_xi_device_info_classes_iterator")]
		_DeviceClassIterator _iterator ();
		public DeviceClassIterator iterator () {
			return (DeviceClassIterator) _iterator ();
		}
	}

	[CCode (cname = "xcb_input_grab_owner_t", cprefix =  "XCB_INPUT_GRAB_OWNER_", has_type_id = false)]
	public enum GrabOwner {
		NO_OWNER,
		OWNER
	}

	[CCode (cname = "xcb_input_event_mode_t", cprefix =  "XCB_INPUT_EVENT_MODE_", has_type_id = false)]
	public enum EventMode {
		ASYNC_DEVICE,
		SYNC_DEVICE,
		REPLAY_DEVICE,
		ASYNC_PAIRED_DEVICE,
		ASYNC_PAIR,
		SYNC_PAIR,
		ACCEPT_TOUCH,
		REJECT_TOUCH
	}

	[CCode (cname = "xcb_input_grab_mode_22_t", cprefix =  "XCB_INPUT_GRAB_MODE_22_", has_type_id = false)]
	public enum GrabMode22 {
		SYNC,
		ASYNC,
		TOUCH
	}

	[CCode (cname = "xcb_input_grab_type_t", cprefix =  "XCB_INPUT_GRAB_TYPE_", has_type_id = false)]
	public enum GrabType {
		BUTTON,
		KEYCODE,
		ENTER,
		FOCUS_IN,
		TOUCH_BEGIN
	}

	[CCode (cname = "xcb_input_modifier_mask_t", cprefix =  "XCB_INPUT_MODIFIER_MASK_", has_type_id = false)]
	public enum ModifierMask {
		ANY
	}

	[SimpleType, CCode (cname = "xcb_input_grab_modifier_info_iterator_t")]
	struct _GrabModifierInfoIterator
	{
		int rem;
		int index;
		unowned GrabModifierInfo? data;
	}

	[CCode (cname = "xcb_input_grab_modifier_info_iterator_t")]
	public struct GrabModifierInfoIterator
	{
		[CCode (cname = "xcb_input_grab_modifier_info_next")]
		void _next ();

		public inline unowned GrabModifierInfo?
		next_value ()
		{
			if (((_GrabModifierInfoIterator)this).rem > 0)
			{
				unowned GrabModifierInfo? d = ((_GrabModifierInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_grab_modifier_info_t", has_type_id = false)]
	public struct GrabModifierInfo {
		public uint32 modifiers;
		public uint8 status;
	}

	[SimpleType, CCode (cname = "xcb_input_barrier_release_pointer_info_iterator_t")]
	struct _BarrierReleasePointerInfoIterator
	{
		int rem;
		int index;
		unowned BarrierReleasePointerInfo? data;
	}

	[CCode (cname = "xcb_input_barrier_release_pointer_info_iterator_t")]
	public struct BarrierReleasePointerInfoIterator
	{
		[CCode (cname = "xcb_input_barrier_release_pointer_info_next")]
		void _next ();

		public inline unowned BarrierReleasePointerInfo?
		next_value ()
		{
			if (((_BarrierReleasePointerInfoIterator)this).rem > 0)
			{
				unowned BarrierReleasePointerInfo? d = ((_BarrierReleasePointerInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_barrier_release_pointer_info_t", has_type_id = false)]
	public struct BarrierReleasePointerInfo {
		public DeviceId deviceid;
		public uint32 eventid;
	}

	[Compact, CCode (cname = "xcb_input_device_valuator_event_t", has_type_id = false)]
	public class DeviceValuatorEvent : Xcb.GenericEvent {
		public uint8 device_id;
		public uint16 device_state;
		public uint8 num_valuators;
		public uint8 first_valuator;
		public int32 valuators[6];
	}

	[Compact, CCode (cname = "xcb_input_device_key_press_event_t", has_type_id = false)]
	public class DeviceKeyPressEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_device_focus_in_event_t", has_type_id = false)]
	public class DeviceFocusInEvent : Xcb.GenericEvent {
		public uint8 detail;
		public uint8 device_id;
		public uint8 mode;
		public Timestamp time;
		public Window window;
	}

	[Compact, CCode (cname = "xcb_input_device_state_notify_event_t", has_type_id = false)]
	public class DeviceStateNotifyEvent : Xcb.GenericEvent {
		public uint8 device_id;
		public Timestamp time;
		public uint8 num_keys;
		public uint8 num_buttons;
		public uint8 num_valuators;
		public uint8 classes_reported;
		public uint8 buttons[4];
		public uint8 keys[4];
		public uint32 valuators[3];
	}

	[Compact, CCode (cname = "xcb_input_device_mapping_notify_event_t", has_type_id = false)]
	public class DeviceMappingNotifyEvent : Xcb.GenericEvent {
		public uint8 device_id;
		public uint8 request;
		public Keycode first_keycode;
		public uint8 count;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_change_device_notify_event_t", has_type_id = false)]
	public class ChangeDeviceNotifyEvent : Xcb.GenericEvent {
		public uint8 device_id;
		public Timestamp time;
		public uint8 request;
	}

	[Compact, CCode (cname = "xcb_input_device_key_state_notify_event_t", has_type_id = false)]
	public class DeviceKeyStateNotifyEvent : Xcb.GenericEvent {
		public uint8 device_id;
		public uint8 keys[28];
	}

	[Compact, CCode (cname = "xcb_input_device_button_state_notify_event_t", has_type_id = false)]
	public class DeviceButtonStateNotifyEvent : Xcb.GenericEvent {
		public uint8 device_id;
		public uint8 buttons[28];
	}

	[CCode (cname = "xcb_input_device_change_t", cprefix =  "XCB_INPUT_DEVICE_CHANGE_", has_type_id = false)]
	public enum DeviceChange {
		ADDED,
		REMOVED,
		ENABLED,
		DISABLED,
		UNRECOVERABLE,
		CONTROL_CHANGED
	}

	[Compact, CCode (cname = "xcb_input_device_presence_notify_event_t", has_type_id = false)]
	public class DevicePresenceNotifyEvent : Xcb.GenericEvent {
		public Timestamp time;
		public DeviceChange devchange;
		public uint8 device_id;
		public uint16 control;
	}

	[Compact, CCode (cname = "xcb_input_device_property_notify_event_t", has_type_id = false)]
	public class DevicePropertyNotifyEvent : Xcb.GenericEvent {
		public uint8 state;
		public Timestamp time;
		public Atom property;
		public uint8 device_id;
	}

	[CCode (cname = "xcb_input_change_reason_t", cprefix =  "XCB_INPUT_CHANGE_REASON_", has_type_id = false)]
	public enum ChangeReason {
		SLAVE_SWITCH,
		DEVICE_CHANGE
	}

	[Compact, CCode (cname = "xcb_input_device_changed_event_t", has_type_id = false)]
	public class DeviceChangedEvent : Xcb.GenericEvent {
		public DeviceId deviceid;
		public Timestamp time;
		public uint16 num_classes;
		public DeviceId sourceid;
		public ChangeReason reason;
		public int classes_length {
			[CCode (cname = "xcb_input_device_changedevent_classes_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned DeviceClass[] classes {
			[CCode (cname = "xcb_input_device_changedevent_classes")]
			get;
		}
	}

	[Flags, CCode (cname = "xcb_input_key_event_flags_t", cprefix =  "XCB_INPUT_KEY_EVENT_FLAGS_", has_type_id = false)]
	public enum KeyEventFlags {
		KEY_REPEAT
	}

	[Compact, CCode (cname = "xcb_input_key_press_event_t", has_type_id = false)]
	public class KeyPressEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_key_releaseevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_key_releaseevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public KeyEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_key_releaseevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_key_releaseevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Flags, CCode (cname = "xcb_input_pointer_event_flags_t", cprefix =  "XCB_INPUT_POINTER_EVENT_FLAGS_", has_type_id = false)]
	public enum PointerEventFlags {
		POINTER_EMULATED
	}

	[Compact, CCode (cname = "xcb_input_button_press_event_t", has_type_id = false)]
	public class ButtonPressEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_motionevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_motionevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public PointerEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_motionevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_motionevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[CCode (cname = "xcb_input_notify_mode_t", cprefix =  "XCB_INPUT_NOTIFY_MODE_", has_type_id = false)]
	public enum NotifyMode {
		NORMAL,
		GRAB,
		UNGRAB,
		WHILE_GRABBED,
		PASSIVE_GRAB,
		PASSIVE_UNGRAB
	}

	[CCode (cname = "xcb_input_notify_detail_t", cprefix =  "XCB_INPUT_NOTIFY_DETAIL_", has_type_id = false)]
	public enum NotifyDetail {
		ANCESTOR,
		VIRTUAL,
		INFERIOR,
		NONLINEAR,
		NONLINEAR_VIRTUAL,
		POINTER,
		POINTER_ROOT,
		NONE
	}

	[Compact, CCode (cname = "xcb_input_enter_event_t", has_type_id = false)]
	public class EnterEvent : Xcb.GenericEvent {
		public int buttons_length {
			[CCode (cname = "xcb_input_focus_outevent_buttons_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] buttons {
			[CCode (cname = "xcb_input_focus_outevent_buttons")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint8 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public uint8 focus;
		public GroupInfo group;
		public uint8 mode;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public uint8 same_screen;
		public DeviceId sourceid;
		public Timestamp time;
	}

	[Flags, CCode (cname = "xcb_input_hierarchy_mask_t", cprefix =  "XCB_INPUT_HIERARCHY_MASK_", has_type_id = false)]
	public enum HierarchyMask {
		MASTER_ADDED,
		MASTER_REMOVED,
		SLAVE_ADDED,
		SLAVE_REMOVED,
		SLAVE_ATTACHED,
		SLAVE_DETACHED,
		DEVICE_ENABLED,
		DEVICE_DISABLED
	}

	[SimpleType, CCode (cname = "xcb_input_hierarchy_info_iterator_t")]
	struct _HierarchyInfoIterator
	{
		int rem;
		int index;
		unowned HierarchyInfo? data;
	}

	[CCode (cname = "xcb_input_hierarchy_info_iterator_t")]
	public struct HierarchyInfoIterator
	{
		[CCode (cname = "xcb_input_hierarchy_info_next")]
		void _next ();

		public inline unowned HierarchyInfo?
		next_value ()
		{
			if (((_HierarchyInfoIterator)this).rem > 0)
			{
				unowned HierarchyInfo? d = ((_HierarchyInfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_input_hierarchy_info_t", has_type_id = false)]
	public struct HierarchyInfo {
		public DeviceId deviceid;
		public DeviceId attachment;
		public DeviceType type;
		public bool enabled;
		public HierarchyMask flags;
	}

	[Compact, CCode (cname = "xcb_input_hierarchy_event_t", has_type_id = false)]
	public class HierarchyEvent : Xcb.GenericEvent {
		public DeviceId deviceid;
		public Timestamp time;
		public HierarchyMask flags;
		public uint16 num_infos;
		public int infos_length {
			[CCode (cname = "xcb_input_hierarchyevent_infos_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned HierarchyInfo[] infos {
			[CCode (cname = "xcb_input_hierarchyevent_infos")]
			get;
		}
	}

	[CCode (cname = "xcb_input_property_flag_t", cprefix =  "XCB_INPUT_PROPERTY_FLAG_", has_type_id = false)]
	public enum PropertyFlag {
		DELETED,
		CREATED,
		MODIFIED
	}

	[Compact, CCode (cname = "xcb_input_property_event_t", has_type_id = false)]
	public class PropertyEvent : Xcb.GenericEvent {
		public DeviceId deviceid;
		public Timestamp time;
		public Atom property;
		public PropertyFlag what;
	}

	[Compact, CCode (cname = "xcb_input_raw_key_press_event_t", has_type_id = false)]
	public class RawKeyPressEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public KeyEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_key_releaseevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_key_releaseevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_raw_button_press_event_t", has_type_id = false)]
	public class RawButtonPressEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public PointerEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_motionevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_motionevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Flags, CCode (cname = "xcb_input_touch_event_flags_t", cprefix =  "XCB_INPUT_TOUCH_EVENT_FLAGS_", has_type_id = false)]
	public enum TouchEventFlags {
		TOUCH_PENDING_END,
		TOUCH_EMULATING_POINTER
	}

	[Compact, CCode (cname = "xcb_input_touch_begin_event_t", has_type_id = false)]
	public class TouchBeginEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_touch_endevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_touch_endevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public TouchEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_touch_endevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_touch_endevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[CCode (cname = "xcb_input_touch_ownership_flags_t", cprefix =  "XCB_INPUT_TOUCH_OWNERSHIP_FLAGS_", has_type_id = false)]
	public enum TouchOwnershipFlags {
		NONE
	}

	[Compact, CCode (cname = "xcb_input_touch_ownership_event_t", has_type_id = false)]
	public class TouchOwnershipEvent : Xcb.GenericEvent {
		public DeviceId deviceid;
		public Timestamp time;
		public uint32 touchid;
		public Window root;
		public Window event;
		public Window child;
		public DeviceId sourceid;
		public TouchOwnershipFlags flags;
	}

	[Compact, CCode (cname = "xcb_input_raw_touch_begin_event_t", has_type_id = false)]
	public class RawTouchBeginEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public TouchEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_touch_endevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_touch_endevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_barrier_hit_event_t", has_type_id = false)]
	public class BarrierHitEvent : Xcb.GenericEvent {
		public DeviceId deviceid;
		public uint32 dtime;
		public Fp3232 dx;
		public Fp3232 dy;
		public Window event;
		public uint32 eventid;
		public uint32 flags;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_device_error_t", has_type_id = false)]
	public class DeviceError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_input_event_error_t", has_type_id = false)]
	public class EventError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_input_mode_error_t", has_type_id = false)]
	public class ModeError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_input_device_busy_error_t", has_type_id = false)]
	public class DeviceBusyError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_input_class_error_t", has_type_id = false)]
	public class ClassError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_input_device_key_release_event_t", has_type_id = false)]
	public class DeviceKeyReleaseEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_device_button_press_event_t", has_type_id = false)]
	public class DeviceButtonPressEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_device_button_release_event_t", has_type_id = false)]
	public class DeviceButtonReleaseEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_device_motion_notify_event_t", has_type_id = false)]
	public class DeviceMotionNotifyEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_device_focus_out_event_t", has_type_id = false)]
	public class DeviceFocusOutEvent : Xcb.GenericEvent {
		public uint8 detail;
		public uint8 device_id;
		public uint8 mode;
		public Timestamp time;
		public Window window;
	}

	[Compact, CCode (cname = "xcb_input_proximity_in_event_t", has_type_id = false)]
	public class ProximityInEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_proximity_out_event_t", has_type_id = false)]
	public class ProximityOutEvent : Xcb.GenericEvent {
		public Window child;
		public uint8 detail;
		public uint8 device_id;
		public Window event;
		public int16 event_x;
		public int16 event_y;
		public Window root;
		public int16 root_x;
		public int16 root_y;
		public bool same_screen;
		public uint16 state;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_key_release_event_t", has_type_id = false)]
	public class KeyReleaseEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_key_releaseevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_key_releaseevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public KeyEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_key_releaseevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_key_releaseevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_button_release_event_t", has_type_id = false)]
	public class ButtonReleaseEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_motionevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_motionevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public PointerEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_motionevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_motionevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_motion_event_t", has_type_id = false)]
	public class MotionEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_motionevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_motionevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public PointerEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_motionevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_motionevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_leave_event_t", has_type_id = false)]
	public class LeaveEvent : Xcb.GenericEvent {
		public int buttons_length {
			[CCode (cname = "xcb_input_focus_outevent_buttons_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] buttons {
			[CCode (cname = "xcb_input_focus_outevent_buttons")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint8 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public uint8 focus;
		public GroupInfo group;
		public uint8 mode;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public uint8 same_screen;
		public DeviceId sourceid;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_focus_in_event_t", has_type_id = false)]
	public class FocusInEvent : Xcb.GenericEvent {
		public int buttons_length {
			[CCode (cname = "xcb_input_focus_outevent_buttons_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] buttons {
			[CCode (cname = "xcb_input_focus_outevent_buttons")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint8 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public uint8 focus;
		public GroupInfo group;
		public uint8 mode;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public uint8 same_screen;
		public DeviceId sourceid;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_focus_out_event_t", has_type_id = false)]
	public class FocusOutEvent : Xcb.GenericEvent {
		public int buttons_length {
			[CCode (cname = "xcb_input_focus_outevent_buttons_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] buttons {
			[CCode (cname = "xcb_input_focus_outevent_buttons")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint8 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public uint8 focus;
		public GroupInfo group;
		public uint8 mode;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public uint8 same_screen;
		public DeviceId sourceid;
		public Timestamp time;
	}

	[Compact, CCode (cname = "xcb_input_raw_key_release_event_t", has_type_id = false)]
	public class RawKeyReleaseEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public KeyEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_key_releaseevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_key_releaseevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_raw_button_release_event_t", has_type_id = false)]
	public class RawButtonReleaseEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public PointerEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_motionevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_motionevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_raw_motion_event_t", has_type_id = false)]
	public class RawMotionEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public PointerEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_motionevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_motionevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_touch_update_event_t", has_type_id = false)]
	public class TouchUpdateEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_touch_endevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_touch_endevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public TouchEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_touch_endevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_touch_endevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_touch_end_event_t", has_type_id = false)]
	public class TouchEndEvent : Xcb.GenericEvent {
		public int button_mask_length {
			[CCode (cname = "xcb_input_touch_endevent_button_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] button_mask {
			[CCode (cname = "xcb_input_touch_endevent_button_mask")]
			get;
		}
		public uint16 buttons_len;
		public Window child;
		public uint32 detail;
		public DeviceId deviceid;
		public Window event;
		public Fp1616 event_x;
		public Fp1616 event_y;
		public TouchEventFlags flags;
		public GroupInfo group;
		public ModifierInfo mods;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_touch_endevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_touch_endevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_raw_touch_update_event_t", has_type_id = false)]
	public class RawTouchUpdateEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public TouchEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_touch_endevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_touch_endevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_raw_touch_end_event_t", has_type_id = false)]
	public class RawTouchEndEvent : Xcb.GenericEvent {
		public uint32 detail;
		public DeviceId deviceid;
		public TouchEventFlags flags;
		public DeviceId sourceid;
		public Timestamp time;
		public int valuator_mask_length {
			[CCode (cname = "xcb_input_raw_touch_endevent_valuator_mask_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] valuator_mask {
			[CCode (cname = "xcb_input_raw_touch_endevent_valuator_mask")]
			get;
		}
		public uint16 valuators_len;
	}

	[Compact, CCode (cname = "xcb_input_barrier_leave_event_t", has_type_id = false)]
	public class BarrierLeaveEvent : Xcb.GenericEvent {
		public DeviceId deviceid;
		public uint32 dtime;
		public Fp3232 dx;
		public Fp3232 dy;
		public Window event;
		public uint32 eventid;
		public uint32 flags;
		public Window root;
		public Fp1616 root_x;
		public Fp1616 root_y;
		public DeviceId sourceid;
		public Timestamp time;
	}

	[CCode (cname = "guint8", cprefix =  "XCB_INPUT_", has_type_id = false)]
	public enum EventType {
		DEVICE_VALUATOR,
		DEVICE_KEY_PRESS,
		DEVICE_CHANGED,
		KEY_PRESS,
		DEVICE_KEY_RELEASE,
		DEVICE_BUTTON_PRESS,
		KEY_RELEASE,
		BUTTON_PRESS,
		DEVICE_BUTTON_RELEASE,
		DEVICE_MOTION_NOTIFY,
		BUTTON_RELEASE,
		DEVICE_FOCUS_IN,
		MOTION,
		ENTER,
		DEVICE_FOCUS_OUT,
		PROXIMITY_IN,
		LEAVE,
		PROXIMITY_OUT,
		FOCUS_IN,
		DEVICE_STATE_NOTIFY,
		FOCUS_OUT,
		DEVICE_MAPPING_NOTIFY,
		HIERARCHY,
		CHANGE_DEVICE_NOTIFY,
		PROPERTY,
		DEVICE_KEY_STATE_NOTIFY,
		RAW_KEY_PRESS,
		DEVICE_BUTTON_STATE_NOTIFY,
		RAW_KEY_RELEASE,
		DEVICE_PRESENCE_NOTIFY,
		RAW_BUTTON_PRESS,
		DEVICE_PROPERTY_NOTIFY,
		RAW_BUTTON_RELEASE,
		RAW_MOTION,
		TOUCH_BEGIN,
		TOUCH_UPDATE,
		TOUCH_END,
		TOUCH_OWNERSHIP,
		RAW_TOUCH_BEGIN,
		RAW_TOUCH_UPDATE,
		RAW_TOUCH_END,
		BARRIER_HIT,
		BARRIER_LEAVE
	}
}

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

[CCode (cheader_filename="xcb/xcb.h,xcb/sync.h")]
namespace Xcb.Sync
{
	[CCode (cname = "xcb_sync_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_sync_initialize")]
		public InitializeCookie initialize (uint8 desired_major_version, uint8 desired_minor_version);
		[CCode (cname = "xcb_sync_list_system_counters")]
		public ListSystemCountersCookie list_system_counters ();
		[CCode (cname = "xcb_sync_await")]
		public VoidCookie await ([CCode (array_length_pos = 0.0)]Waitcondition[] wait_list);
		[CCode (cname = "xcb_sync_await_checked")]
		public VoidCookie await_checked ([CCode (array_length_pos = 0.0)]Waitcondition[] wait_list);
		[CCode (cname = "xcb_sync_set_priority")]
		public VoidCookie set_priority (uint32 id, int32 priority);
		[CCode (cname = "xcb_sync_set_priority_checked")]
		public VoidCookie set_priority_checked (uint32 id, int32 priority);
		[CCode (cname = "xcb_sync_get_priority")]
		public GetPriorityCookie get_priority (uint32 id);
		[CCode (cname = "xcb_sync_await_fence")]
		public VoidCookie await_fence ([CCode (array_length_pos = 0.0)]Fence[] fence_list);
		[CCode (cname = "xcb_sync_await_fence_checked")]
		public VoidCookie await_fence_checked ([CCode (array_length_pos = 0.0)]Fence[] fence_list);
	}

	[Compact, CCode (cname = "xcb_sync_initialize_reply_t", free_function = "free")]
	public class InitializeReply {
		public uint8 major_version;
		public uint8 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_sync_initialize_cookie_t")]
	public struct InitializeCookie : VoidCookie {
		[CCode (cname = "xcb_sync_initialize_reply", instance_pos = 1.1)]
		public InitializeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_sync_list_system_counters_reply_t", free_function = "free")]
	public class ListSystemCountersReply {
		public uint32 counters_len;
		[CCode (cname = "xcb_sync_list_system_counters_counters_iterator")]
		_SystemcounterIterator _iterator ();
		public SystemcounterIterator iterator () {
			return (SystemcounterIterator) _iterator ();
		}
		public int counters_length {
			[CCode (cname = "xcb_sync_list_system_counters_counters_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Systemcounter[] counters {
			[CCode (cname = "xcb_sync_list_system_counters_counters")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_sync_list_system_counters_cookie_t")]
	public struct ListSystemCountersCookie : VoidCookie {
		[CCode (cname = "xcb_sync_list_system_counters_reply", instance_pos = 1.1)]
		public ListSystemCountersReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_sync_get_priority_reply_t", free_function = "free")]
	public class GetPriorityReply {
		public int32 priority;
	}

	[SimpleType, CCode (cname = "xcb_sync_get_priority_cookie_t")]
	public struct GetPriorityCookie : VoidCookie {
		[CCode (cname = "xcb_sync_get_priority_reply", instance_pos = 1.1)]
		public GetPriorityReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_sync_alarm_iterator_t")]
	struct _AlarmIterator
	{
		internal int rem;
		internal int index;
		internal unowned Alarm? data;
	}

	[CCode (cname = "xcb_sync_alarm_iterator_t")]
	public struct AlarmIterator
	{
		[CCode (cname = "xcb_sync_alarm_next")]
		internal void _next ();

		public inline unowned Alarm?
		next_value ()
		{
			if (((_AlarmIterator)this).rem > 0)
			{
				unowned Alarm? d = ((_AlarmIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_alarm_t", has_type_id = false)]
	public struct Alarm : uint32 {
		/**
		 * Allocates an XID for a new Alarm.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Alarm (Xcb.Connection connection);

		[CCode (cname = "xcb_sync_create_alarm", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_sync_create_alarm_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_sync_change_alarm", instance_pos = 1.1)]
		public VoidCookie change (Xcb.Connection connection, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_sync_change_alarm_checked", instance_pos = 1.1)]
		public VoidCookie change_checked (Xcb.Connection connection, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_sync_destroy_alarm", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_destroy_alarm_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_query_alarm", instance_pos = 1.1)]
		public QueryAlarmCookie query (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_sync_query_alarm_reply_t", free_function = "free")]
	public class QueryAlarmReply {
		public Trigger trigger;
		public Int64 delta;
		public bool events;
		public Alarmstate state;
	}

	[SimpleType, CCode (cname = "xcb_sync_query_alarm_cookie_t")]
	public struct QueryAlarmCookie : VoidCookie {
		[CCode (cname = "xcb_sync_query_alarm_reply", instance_pos = 1.1)]
		public QueryAlarmReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_sync_alarmstate_t", cprefix =  "XCB_SYNC_ALARMSTATE_", has_type_id = false)]
	public enum Alarmstate {
		ACTIVE,
		INACTIVE,
		DESTROYED
	}

	[SimpleType, CCode (cname = "xcb_sync_counter_iterator_t")]
	struct _CounterIterator
	{
		internal int rem;
		internal int index;
		internal unowned Counter? data;
	}

	[CCode (cname = "xcb_sync_counter_iterator_t")]
	public struct CounterIterator
	{
		[CCode (cname = "xcb_sync_counter_next")]
		internal void _next ();

		public inline unowned Counter?
		next_value ()
		{
			if (((_CounterIterator)this).rem > 0)
			{
				unowned Counter? d = ((_CounterIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_counter_t", has_type_id = false)]
	public struct Counter : uint32 {
		/**
		 * Allocates an XID for a new Counter.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Counter (Xcb.Connection connection);

		[CCode (cname = "xcb_sync_create_counter", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, Int64 initial_value);
		[CCode (cname = "xcb_sync_create_counter_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, Int64 initial_value);
		[CCode (cname = "xcb_sync_destroy_counter", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_destroy_counter_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_query_counter", instance_pos = 1.1)]
		public QueryCounterCookie query (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_change_counter", instance_pos = 1.1)]
		public VoidCookie change (Xcb.Connection connection, Int64 amount);
		[CCode (cname = "xcb_sync_change_counter_checked", instance_pos = 1.1)]
		public VoidCookie change_checked (Xcb.Connection connection, Int64 amount);
		[CCode (cname = "xcb_sync_set_counter", instance_pos = 1.1)]
		public VoidCookie set (Xcb.Connection connection, Int64 value);
		[CCode (cname = "xcb_sync_set_counter_checked", instance_pos = 1.1)]
		public VoidCookie set_checked (Xcb.Connection connection, Int64 value);
	}

	[Compact, CCode (cname = "xcb_sync_query_counter_reply_t", free_function = "free")]
	public class QueryCounterReply {
		public Int64 counter_value;
	}

	[SimpleType, CCode (cname = "xcb_sync_query_counter_cookie_t")]
	public struct QueryCounterCookie : VoidCookie {
		[CCode (cname = "xcb_sync_query_counter_reply", instance_pos = 1.1)]
		public QueryCounterReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_sync_fence_iterator_t")]
	struct _FenceIterator
	{
		internal int rem;
		internal int index;
		internal unowned Fence? data;
	}

	[CCode (cname = "xcb_sync_fence_iterator_t")]
	public struct FenceIterator
	{
		[CCode (cname = "xcb_sync_fence_next")]
		internal void _next ();

		public inline unowned Fence?
		next_value ()
		{
			if (((_FenceIterator)this).rem > 0)
			{
				unowned Fence? d = ((_FenceIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_fence_t", has_type_id = false)]
	public struct Fence : uint32 {
		/**
		 * Allocates an XID for a new Fence.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Fence (Xcb.Connection connection);

		[CCode (cname = "xcb_sync_create_fence", instance_pos = 2.2)]
		public VoidCookie create (Xcb.Connection connection, Drawable drawable, bool initially_triggered);
		[CCode (cname = "xcb_sync_create_fence_checked", instance_pos = 2.2)]
		public VoidCookie create_checked (Xcb.Connection connection, Drawable drawable, bool initially_triggered);
		[CCode (cname = "xcb_sync_trigger_fence", instance_pos = 1.1)]
		public VoidCookie trigger (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_trigger_fence_checked", instance_pos = 1.1)]
		public VoidCookie trigger_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_reset_fence", instance_pos = 1.1)]
		public VoidCookie reset (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_reset_fence_checked", instance_pos = 1.1)]
		public VoidCookie reset_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_destroy_fence", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_destroy_fence_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_sync_query_fence", instance_pos = 1.1)]
		public QueryFenceCookie query (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_sync_query_fence_reply_t", free_function = "free")]
	public class QueryFenceReply {
		public bool triggered;
	}

	[SimpleType, CCode (cname = "xcb_sync_query_fence_cookie_t")]
	public struct QueryFenceCookie : VoidCookie {
		[CCode (cname = "xcb_sync_query_fence_reply", instance_pos = 1.1)]
		public QueryFenceReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_sync_testtype_t", cprefix =  "XCB_SYNC_TESTTYPE_", has_type_id = false)]
	public enum Testtype {
		POSITIVE_TRANSITION,
		NEGATIVE_TRANSITION,
		POSITIVE_COMPARISON,
		NEGATIVE_COMPARISON
	}

	[CCode (cname = "xcb_sync_valuetype_t", cprefix =  "XCB_SYNC_VALUETYPE_", has_type_id = false)]
	public enum Valuetype {
		ABSOLUTE,
		RELATIVE
	}

	[CCode (cname = "xcb_sync_ca_t", cprefix =  "XCB_SYNC_CA_", has_type_id = false)]
	public enum Ca {
		COUNTER,
		VALUE_TYPE,
		VALUE,
		TEST_TYPE,
		DELTA,
		EVENTS
	}

	[SimpleType, CCode (cname = "xcb_sync_int64_iterator_t")]
	struct _Int64Iterator
	{
		internal int rem;
		internal int index;
		internal unowned Int64? data;
	}

	[CCode (cname = "xcb_sync_int64_iterator_t")]
	public struct Int64Iterator
	{
		[CCode (cname = "xcb_sync_int64_next")]
		internal void _next ();

		public inline unowned Int64?
		next_value ()
		{
			if (((_Int64Iterator)this).rem > 0)
			{
				unowned Int64? d = ((_Int64Iterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_int64_t", has_type_id = false)]
	public struct Int64 {
		public int32 hi;
		public uint32 lo;
	}

	[SimpleType, CCode (cname = "xcb_sync_systemcounter_iterator_t")]
	struct _SystemcounterIterator
	{
		internal int rem;
		internal int index;
		internal unowned Systemcounter? data;
	}

	[CCode (cname = "xcb_sync_systemcounter_iterator_t")]
	public struct SystemcounterIterator
	{
		[CCode (cname = "xcb_sync_systemcounter_next")]
		internal void _next ();

		public inline unowned Systemcounter?
		next_value ()
		{
			if (((_SystemcounterIterator)this).rem > 0)
			{
				unowned Systemcounter? d = ((_SystemcounterIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_systemcounter_t", has_type_id = false)]
	public struct Systemcounter {
		public Counter counter;
		public Int64 resolution;
		public uint16 name_len;
		[CCode (cname = "xcb_sync_systemcounter_name_length")]
		int _name_length ();
		[CCode (cname = "xcb_sync_systemcounter_name", array_length = false)]
		unowned char[] _name ();
		public string name {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_name (), _name_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_sync_trigger_iterator_t")]
	struct _TriggerIterator
	{
		internal int rem;
		internal int index;
		internal unowned Trigger? data;
	}

	[CCode (cname = "xcb_sync_trigger_iterator_t")]
	public struct TriggerIterator
	{
		[CCode (cname = "xcb_sync_trigger_next")]
		internal void _next ();

		public inline unowned Trigger?
		next_value ()
		{
			if (((_TriggerIterator)this).rem > 0)
			{
				unowned Trigger? d = ((_TriggerIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_trigger_t", has_type_id = false)]
	public struct Trigger {
		public Counter counter;
		public Valuetype wait_type;
		public Int64 wait_value;
		public Testtype test_type;
	}

	[SimpleType, CCode (cname = "xcb_sync_waitcondition_iterator_t")]
	struct _WaitconditionIterator
	{
		internal int rem;
		internal int index;
		internal unowned Waitcondition? data;
	}

	[CCode (cname = "xcb_sync_waitcondition_iterator_t")]
	public struct WaitconditionIterator
	{
		[CCode (cname = "xcb_sync_waitcondition_next")]
		internal void _next ();

		public inline unowned Waitcondition?
		next_value ()
		{
			if (((_WaitconditionIterator)this).rem > 0)
			{
				unowned Waitcondition? d = ((_WaitconditionIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_sync_waitcondition_t", has_type_id = false)]
	public struct Waitcondition {
		public Trigger trigger;
		public Int64 event_threshold;
	}

	[Compact, CCode (cname = "xcb_sync_counter_error_t", has_type_id = false)]
	public class CounterError : Xcb.GenericError {
		public uint32 bad_counter;
		public uint16 minor_opcode;
		public uint8 major_opcode;
	}

	[Compact, CCode (cname = "xcb_sync_alarm_error_t", has_type_id = false)]
	public class AlarmError : Xcb.GenericError {
		public uint32 bad_alarm;
		public uint16 minor_opcode;
		public uint8 major_opcode;
	}

	[Compact, CCode (cname = "xcb_sync_counter_notify_event_t", has_type_id = false)]
	public class CounterNotifyEvent : GenericEvent {
		public uint8 kind;
		public Counter counter;
		public Int64 wait_value;
		public Int64 counter_value;
		public Timestamp timestamp;
		public uint16 count;
		public bool destroyed;
	}

	[Compact, CCode (cname = "xcb_sync_alarm_notify_event_t", has_type_id = false)]
	public class AlarmNotifyEvent : GenericEvent {
		public uint8 kind;
		public Alarm alarm;
		public Int64 counter_value;
		public Int64 alarm_value;
		public Timestamp timestamp;
		public Alarmstate state;
	}

	[CCode (cname = "uint8", cprefix =  "XCB_SYNC_", has_type_id = false)]
	public enum EventType {
		COUNTER_NOTIFY,
		ALARM_NOTIFY
	}
}

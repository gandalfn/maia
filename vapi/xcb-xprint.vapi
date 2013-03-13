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

[CCode (cheader_filename="xcb/xcb.h,xcb/xprint.h")]
namespace Xcb.XPrint
{
	[CCode (cname = "xcb_x_print_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_x_print_print_query_version")]
		public PrintQueryVersionCookie print_query_version ();
		[CCode (cname = "xcb_x_print_print_get_printer_list")]
		public PrintGetPrinterListCookie print_get_printer_list ([CCode (array_length_pos = 0.1)]String8[] printer_name, [CCode (array_length_pos = 1.2)]String8[] locale);
		[CCode (cname = "xcb_x_print_print_rehash_printer_list")]
		public VoidCookie print_rehash_printer_list ();
		[CCode (cname = "xcb_x_print_print_rehash_printer_list_checked")]
		public VoidCookie print_rehash_printer_list_checked ();
		[CCode (cname = "xcb_x_print_create_context")]
		public VoidCookie create_context (uint32 context_id, [CCode (array_length_pos = 1.2)]String8[] printerName, [CCode (array_length_pos = 2.3)]String8[] locale);
		[CCode (cname = "xcb_x_print_create_context_checked")]
		public VoidCookie create_context_checked (uint32 context_id, [CCode (array_length_pos = 1.2)]String8[] printerName, [CCode (array_length_pos = 2.3)]String8[] locale);
		[CCode (cname = "xcb_x_print_print_set_context")]
		public VoidCookie print_set_context (uint32 context);
		[CCode (cname = "xcb_x_print_print_set_context_checked")]
		public VoidCookie print_set_context_checked (uint32 context);
		[CCode (cname = "xcb_x_print_print_get_context")]
		public PrintGetContextCookie print_get_context ();
		[CCode (cname = "xcb_x_print_print_destroy_context")]
		public VoidCookie print_destroy_context (uint32 context);
		[CCode (cname = "xcb_x_print_print_destroy_context_checked")]
		public VoidCookie print_destroy_context_checked (uint32 context);
		[CCode (cname = "xcb_x_print_print_get_screen_of_context")]
		public PrintGetScreenOfContextCookie print_get_screen_of_context ();
		[CCode (cname = "xcb_x_print_print_start_job")]
		public VoidCookie print_start_job (uint8 output_mode);
		[CCode (cname = "xcb_x_print_print_start_job_checked")]
		public VoidCookie print_start_job_checked (uint8 output_mode);
		[CCode (cname = "xcb_x_print_print_end_job")]
		public VoidCookie print_end_job (bool cancel);
		[CCode (cname = "xcb_x_print_print_end_job_checked")]
		public VoidCookie print_end_job_checked (bool cancel);
		[CCode (cname = "xcb_x_print_print_start_doc")]
		public VoidCookie print_start_doc (uint8 driver_mode);
		[CCode (cname = "xcb_x_print_print_start_doc_checked")]
		public VoidCookie print_start_doc_checked (uint8 driver_mode);
		[CCode (cname = "xcb_x_print_print_end_doc")]
		public VoidCookie print_end_doc (bool cancel);
		[CCode (cname = "xcb_x_print_print_end_doc_checked")]
		public VoidCookie print_end_doc_checked (bool cancel);
		[CCode (cname = "xcb_x_print_print_end_page")]
		public VoidCookie print_end_page (bool cancel);
		[CCode (cname = "xcb_x_print_print_end_page_checked")]
		public VoidCookie print_end_page_checked (bool cancel);
		[CCode (cname = "xcb_x_print_print_query_screens")]
		public PrintQueryScreensCookie print_query_screens ();
	}

	[Compact, CCode (cname = "xcb_x_print_print_query_version_reply_t", free_function = "free")]
	public class PrintQueryVersionReply {
		public uint16 major_version;
		public uint16 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_query_version_cookie_t")]
	public struct PrintQueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_query_version_reply", instance_pos = 1.1)]
		public PrintQueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_printer_list_reply_t", free_function = "free")]
	public class PrintGetPrinterListReply {
		public uint32 listCount;
		[CCode (cname = "xcb_x_print_print_get_printer_list_printers_iterator")]
		_PrinterIterator _iterator ();
		public PrinterIterator iterator () {
			return (PrinterIterator) _iterator ();
		}
		public int printers_length {
			[CCode (cname = "xcb_x_print_print_get_printer_list_printers_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Printer[] printers {
			[CCode (cname = "xcb_x_print_print_get_printer_list_printers")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_printer_list_cookie_t")]
	public struct PrintGetPrinterListCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_printer_list_reply", instance_pos = 1.1)]
		public PrintGetPrinterListReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_context_reply_t", free_function = "free")]
	public class PrintGetContextReply {
		public uint32 context;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_context_cookie_t")]
	public struct PrintGetContextCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_context_reply", instance_pos = 1.1)]
		public PrintGetContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_screen_of_context_reply_t", free_function = "free")]
	public class PrintGetScreenOfContextReply {
		public Window root;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_screen_of_context_cookie_t")]
	public struct PrintGetScreenOfContextCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_screen_of_context_reply", instance_pos = 1.1)]
		public PrintGetScreenOfContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_query_screens_reply_t", free_function = "free")]
	public class PrintQueryScreensReply {
		public uint32 listCount;
		public int roots_length {
			[CCode (cname = "xcb_x_print_print_query_screens_roots_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Window[] roots {
			[CCode (cname = "xcb_x_print_print_query_screens_roots")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_query_screens_cookie_t")]
	public struct PrintQueryScreensCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_query_screens_reply", instance_pos = 1.1)]
		public PrintQueryScreensReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		[CCode (cname = "xcb_x_print_print_put_document_data", instance_pos = 1.1)]
		public VoidCookie print_put_document_data (Xcb.Connection connection, uint16 len_fmt, uint16 len_options, [CCode (array_length_pos = 1.2)]uint8[] data, [CCode (array_length_pos = 5.5)]String8[] doc_format, [CCode (array_length_pos = 6.6)]String8[] options);
		[CCode (cname = "xcb_x_print_print_put_document_data_checked", instance_pos = 1.1)]
		public VoidCookie print_put_document_data_checked (Xcb.Connection connection, uint16 len_fmt, uint16 len_options, [CCode (array_length_pos = 1.2)]uint8[] data, [CCode (array_length_pos = 5.5)]String8[] doc_format, [CCode (array_length_pos = 6.6)]String8[] options);
	}

	[CCode (cname = "xcb_window_t", has_type_id = false)]
	public struct Window : Xcb.Window {
		[CCode (cname = "xcb_x_print_print_start_page", instance_pos = 1.1)]
		public VoidCookie print_start_page (Xcb.Connection connection);
		[CCode (cname = "xcb_x_print_print_start_page_checked", instance_pos = 1.1)]
		public VoidCookie print_start_page_checked (Xcb.Connection connection);
	}

	[SimpleType, CCode (cname = "xcb_x_print_string8_t", has_type_id = false)]
	public struct String8 : char {
	}

	[SimpleType, CCode (cname = "xcb_x_print_printer_iterator_t")]
	struct _PrinterIterator
	{
		internal int rem;
		internal int index;
		internal unowned Printer? data;
	}

	[CCode (cname = "xcb_x_print_printer_iterator_t")]
	public struct PrinterIterator
	{
		[CCode (cname = "xcb_x_print_printer_next")]
		internal void _next ();

		public inline unowned Printer?
		next_value ()
		{
			if (((_PrinterIterator)this).rem > 0)
			{
				unowned Printer? d = ((_PrinterIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_x_print_printer_t", has_type_id = false)]
	public struct Printer {
		public uint32 nameLen;
		public int name_length {
			[CCode (cname = "xcb_x_print_printer_name_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned String8[] name {
			[CCode (cname = "xcb_x_print_printer_name")]
			get;
		}
		public uint32 descLen;
		public int description_length {
			[CCode (cname = "xcb_x_print_printer_description_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned String8[] description {
			[CCode (cname = "xcb_x_print_printer_description")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_x_print_pcontext_iterator_t")]
	struct _PcontextIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pcontext? data;
	}

	[CCode (cname = "xcb_x_print_pcontext_iterator_t")]
	public struct PcontextIterator
	{
		[CCode (cname = "xcb_x_print_pcontext_next")]
		internal void _next ();

		public inline unowned Pcontext?
		next_value ()
		{
			if (((_PcontextIterator)this).rem > 0)
			{
				unowned Pcontext? d = ((_PcontextIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_x_print_pcontext_t", has_type_id = false)]
	public struct Pcontext : uint32 {
		[CCode (cname = "xcb_x_print_print_get_document_data", instance_pos = 1.1)]
		public PrintGetDocumentDataCookie print_get_document_data (Xcb.Connection connection, uint32 max_bytes);
		[CCode (cname = "xcb_x_print_print_select_input", instance_pos = 1.1)]
		public VoidCookie print_select_input (Xcb.Connection connection, uint32 event_mask = 0, [CCode (array_length = false)]uint32[]? event_list = null);
		[CCode (cname = "xcb_x_print_print_select_input_checked", instance_pos = 1.1)]
		public VoidCookie print_select_input_checked (Xcb.Connection connection, uint32 event_mask = 0, [CCode (array_length = false)]uint32[]? event_list = null);
		[CCode (cname = "xcb_x_print_print_input_selected", instance_pos = 1.1)]
		public PrintInputSelectedCookie print_input_selected (Xcb.Connection connection);
		[CCode (cname = "xcb_x_print_print_get_attributes", instance_pos = 1.1)]
		public PrintGetAttributesCookie print_get_attributes (Xcb.Connection connection, uint8 pool);
		[CCode (cname = "xcb_x_print_print_get_one_attributes", instance_pos = 1.1)]
		public PrintGetOneAttributesCookie print_get_one_attributes (Xcb.Connection connection, uint8 pool, [CCode (array_length_pos = 1.2)]String8[] name);
		[CCode (cname = "xcb_x_print_print_set_attributes", instance_pos = 1.1)]
		public VoidCookie print_set_attributes (Xcb.Connection connection, uint32 stringLen, uint8 pool, uint8 rule, [CCode (array_length_pos = 4.4)]String8[] attributes);
		[CCode (cname = "xcb_x_print_print_set_attributes_checked", instance_pos = 1.1)]
		public VoidCookie print_set_attributes_checked (Xcb.Connection connection, uint32 stringLen, uint8 pool, uint8 rule, [CCode (array_length_pos = 4.4)]String8[] attributes);
		[CCode (cname = "xcb_x_print_print_get_page_dimensions", instance_pos = 1.1)]
		public PrintGetPageDimensionsCookie print_get_page_dimensions (Xcb.Connection connection);
		[CCode (cname = "xcb_x_print_print_set_image_resolution", instance_pos = 1.1)]
		public PrintSetImageResolutionCookie print_set_image_resolution (Xcb.Connection connection, uint16 image_resolution);
		[CCode (cname = "xcb_x_print_print_get_image_resolution", instance_pos = 1.1)]
		public PrintGetImageResolutionCookie print_get_image_resolution (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_document_data_reply_t", free_function = "free")]
	public class PrintGetDocumentDataReply {
		public uint32 status_code;
		public uint32 finished_flag;
		public uint32 dataLen;
		public int data_length {
			[CCode (cname = "xcb_x_print_print_get_document_data_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_x_print_print_get_document_data_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_document_data_cookie_t")]
	public struct PrintGetDocumentDataCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_document_data_reply", instance_pos = 1.1)]
		public PrintGetDocumentDataReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_input_selected_reply_t", free_function = "free")]
	public class PrintInputSelectedReply {
		public uint32 event_mask;
		[CCode (array_length = false)]
		public uint32[]? event_list;
		public uint32 all_events_mask;
		[CCode (array_length = false)]
		public uint32[]? all_events_list;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_input_selected_cookie_t")]
	public struct PrintInputSelectedCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_input_selected_reply", instance_pos = 1.1)]
		public PrintInputSelectedReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_attributes_reply_t", free_function = "free")]
	public class PrintGetAttributesReply {
		public uint32 stringLen;
		public String8 attributes;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_attributes_cookie_t")]
	public struct PrintGetAttributesCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_attributes_reply", instance_pos = 1.1)]
		public PrintGetAttributesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_one_attributes_reply_t", free_function = "free")]
	public class PrintGetOneAttributesReply {
		public uint32 valueLen;
		public int value_length {
			[CCode (cname = "xcb_x_print_print_get_one_attributes_value_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned String8[] value {
			[CCode (cname = "xcb_x_print_print_get_one_attributes_value")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_one_attributes_cookie_t")]
	public struct PrintGetOneAttributesCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_one_attributes_reply", instance_pos = 1.1)]
		public PrintGetOneAttributesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_page_dimensions_reply_t", free_function = "free")]
	public class PrintGetPageDimensionsReply {
		public uint16 width;
		public uint16 height;
		public uint16 offset_x;
		public uint16 offset_y;
		public uint16 reproducible_width;
		public uint16 reproducible_height;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_page_dimensions_cookie_t")]
	public struct PrintGetPageDimensionsCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_page_dimensions_reply", instance_pos = 1.1)]
		public PrintGetPageDimensionsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_set_image_resolution_reply_t", free_function = "free")]
	public class PrintSetImageResolutionReply {
		public bool status;
		public uint16 previous_resolutions;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_set_image_resolution_cookie_t")]
	public struct PrintSetImageResolutionCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_set_image_resolution_reply", instance_pos = 1.1)]
		public PrintSetImageResolutionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_x_print_print_get_image_resolution_reply_t", free_function = "free")]
	public class PrintGetImageResolutionReply {
		public uint16 image_resolution;
	}

	[SimpleType, CCode (cname = "xcb_x_print_print_get_image_resolution_cookie_t")]
	public struct PrintGetImageResolutionCookie : VoidCookie {
		[CCode (cname = "xcb_x_print_print_get_image_resolution_reply", instance_pos = 1.1)]
		public PrintGetImageResolutionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_x_print_get_doc_t", cprefix =  "XCB_XPRINT_GET_DOC_", has_type_id = false)]
	public enum GetDoc {
		FINISHED,
		SECOND_CONSUMER
	}

	[CCode (cname = "xcb_x_print_ev_mask_t", cprefix =  "XCB_XPRINT_EV_MASK_", has_type_id = false)]
	public enum EvMask {
		NO_EVENT_MASK,
		PRINT_MASK,
		ATTRIBUTE_MASK
	}

	[CCode (cname = "xcb_x_print_detail_t", cprefix =  "XCB_XPRINT_DETAIL_", has_type_id = false)]
	public enum Detail {
		START_JOB_NOTIFY,
		END_JOB_NOTIFY,
		START_DOC_NOTIFY,
		END_DOC_NOTIFY,
		START_PAGE_NOTIFY,
		END_PAGE_NOTIFY
	}

	[CCode (cname = "xcb_x_print_attr_t", cprefix =  "XCB_XPRINT_ATTR_", has_type_id = false)]
	public enum Attr {
		JOB_ATTR,
		DOC_ATTR,
		PAGE_ATTR,
		PRINTER_ATTR,
		SERVER_ATTR,
		MEDIUM_ATTR,
		SPOOLER_ATTR
	}

	[Compact, CCode (cname = "xcb_x_print_notify_event_t", has_type_id = false)]
	public class NotifyEvent : GenericEvent {
		public uint8 detail;
		public Pcontext context;
		public bool cancel;
	}

	[Compact, CCode (cname = "xcb_x_print_attribut_notify_event_t", has_type_id = false)]
	public class AttributNotifyEvent : GenericEvent {
		public uint8 detail;
		public Pcontext context;
	}

	[Compact, CCode (cname = "xcb_x_print_bad_context_error_t", has_type_id = false)]
	public class BadContextError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_x_print_bad_sequence_error_t", has_type_id = false)]
	public class BadSequenceError : Xcb.GenericError {
	}

	[CCode (cname = "uint8", cprefix =  "XCB_XPRINT_", has_type_id = false)]
	public enum EventType {
		NOTIFY,
		ATTRIBUT_NOTIFY
	}
}

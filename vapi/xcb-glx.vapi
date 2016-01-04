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

[CCode (cheader_filename="xcb/xcb.h,xcb/glx.h")]
namespace Xcb.Glx
{
	[CCode (cname = "xcb_glx_id")]
	public Xcb.Extension extension;

	[CCode (cname = "xcb_font_t", has_type_id = false)]
	public struct Font : Xcb.Font {
		/**
		 * Allocates an XID for a new Font.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Font (Xcb.Connection connection);

	}

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_glx_render")]
		public VoidCookie render (Context_tag context_tag, [CCode (array_length_pos = 1.1)]uint8[]? data);
		[CCode (cname = "xcb_glx_render_checked")]
		public VoidCookie render_checked (Context_tag context_tag, [CCode (array_length_pos = 1.1)]uint8[]? data);
		[CCode (cname = "xcb_glx_render_large")]
		public VoidCookie render_large (Context_tag context_tag, uint16 request_num, uint16 request_total, [CCode (array_length_pos = 3.4)]uint8[]? data);
		[CCode (cname = "xcb_glx_render_large_checked")]
		public VoidCookie render_large_checked (Context_tag context_tag, uint16 request_num, uint16 request_total, [CCode (array_length_pos = 3.4)]uint8[]? data);
		[CCode (cname = "xcb_glx_query_version")]
		public QueryVersionCookie query_version (uint32 major_version, uint32 minor_version);
		[CCode (cname = "xcb_glx_wait_gl")]
		public VoidCookie wait_gl (Context_tag context_tag);
		[CCode (cname = "xcb_glx_wait_gl_checked")]
		public VoidCookie wait_gl_checked (Context_tag context_tag);
		[CCode (cname = "xcb_glx_wait_x")]
		public VoidCookie wait_x (Context_tag context_tag);
		[CCode (cname = "xcb_glx_wait_x_checked")]
		public VoidCookie wait_x_checked (Context_tag context_tag);
		[CCode (cname = "xcb_glx_get_visual_configs")]
		public GetVisualConfigsCookie get_visual_configs (uint32 screen);
		[CCode (cname = "xcb_glx_vendor_private")]
		public VoidCookie vendor_private (uint32 vendor_code, Context_tag context_tag, [CCode (array_length_pos = 2.2)]uint8[]? data);
		[CCode (cname = "xcb_glx_vendor_private_checked")]
		public VoidCookie vendor_private_checked (uint32 vendor_code, Context_tag context_tag, [CCode (array_length_pos = 2.2)]uint8[]? data);
		[CCode (cname = "xcb_glx_vendor_private_with_reply")]
		public VendorPrivateWithReplyCookie vendor_private_with_reply (uint32 vendor_code, Context_tag context_tag, [CCode (array_length_pos = 2.2)]uint8[]? data);
		[CCode (cname = "xcb_glx_query_extensions_string")]
		public QueryExtensionsStringCookie query_extensions_string (uint32 screen);
		[CCode (cname = "xcb_glx_query_server_string")]
		public QueryServerStringCookie query_server_string (uint32 screen, uint32 name);
		[CCode (cname = "xcb_glx_client_info")]
		public VoidCookie client_info (uint32 major_version, uint32 minor_version, [CCode (array_length_pos = 2.3)]char[]? string);
		[CCode (cname = "xcb_glx_client_info_checked")]
		public VoidCookie client_info_checked (uint32 major_version, uint32 minor_version, [CCode (array_length_pos = 2.3)]char[]? string);
		[CCode (cname = "xcb_glx_get_fb_configs")]
		public GetFbconfigsCookie get_fb_configs (uint32 screen);
		[CCode (cname = "xcb_glx_set_client_info_arb")]
		public VoidCookie set_client_info_arb (uint32 major_version, uint32 minor_version, [CCode (array_length_pos = 2.3)]uint32[]? gl_versions, [CCode (array_length_pos = 3.4)]char[]? gl_extension_string, [CCode (array_length_pos = 4.5)]char[]? glx_extension_string);
		[CCode (cname = "xcb_glx_set_client_info_arb_checked")]
		public VoidCookie set_client_info_arb_checked (uint32 major_version, uint32 minor_version, [CCode (array_length_pos = 2.3)]uint32[]? gl_versions, [CCode (array_length_pos = 3.4)]char[]? gl_extension_string, [CCode (array_length_pos = 4.5)]char[]? glx_extension_string);
		[CCode (cname = "xcb_glx_set_client_info_2arb")]
		public VoidCookie set_client_info_2arb (uint32 major_version, uint32 minor_version, [CCode (array_length_pos = 2.3)]uint32[]? gl_versions, [CCode (array_length_pos = 3.4)]char[]? gl_extension_string, [CCode (array_length_pos = 4.5)]char[]? glx_extension_string);
		[CCode (cname = "xcb_glx_set_client_info_2arb_checked")]
		public VoidCookie set_client_info_2arb_checked (uint32 major_version, uint32 minor_version, [CCode (array_length_pos = 2.3)]uint32[]? gl_versions, [CCode (array_length_pos = 3.4)]char[]? gl_extension_string, [CCode (array_length_pos = 4.5)]char[]? glx_extension_string);
		[CCode (cname = "xcb_glx_new_list")]
		public VoidCookie new_list (Context_tag context_tag, uint32 list, uint32 mode);
		[CCode (cname = "xcb_glx_new_list_checked")]
		public VoidCookie new_list_checked (Context_tag context_tag, uint32 list, uint32 mode);
		[CCode (cname = "xcb_glx_end_list")]
		public VoidCookie end_list (Context_tag context_tag);
		[CCode (cname = "xcb_glx_end_list_checked")]
		public VoidCookie end_list_checked (Context_tag context_tag);
		[CCode (cname = "xcb_glx_delete_lists")]
		public VoidCookie delete_lists (Context_tag context_tag, uint32 list, int32 range);
		[CCode (cname = "xcb_glx_delete_lists_checked")]
		public VoidCookie delete_lists_checked (Context_tag context_tag, uint32 list, int32 range);
		[CCode (cname = "xcb_glx_gen_lists")]
		public GenListsCookie gen_lists (Context_tag context_tag, int32 range);
		[CCode (cname = "xcb_glx_feedback_buffer")]
		public VoidCookie feedback_buffer (Context_tag context_tag, int32 size, int32 type);
		[CCode (cname = "xcb_glx_feedback_buffer_checked")]
		public VoidCookie feedback_buffer_checked (Context_tag context_tag, int32 size, int32 type);
		[CCode (cname = "xcb_glx_select_buffer")]
		public VoidCookie select_buffer (Context_tag context_tag, int32 size);
		[CCode (cname = "xcb_glx_select_buffer_checked")]
		public VoidCookie select_buffer_checked (Context_tag context_tag, int32 size);
		[CCode (cname = "xcb_glx_render_mode")]
		public RenderModeCookie render_mode (Context_tag context_tag, uint32 mode);
		[CCode (cname = "xcb_glx_finish")]
		public FinishCookie finish (Context_tag context_tag);
		[CCode (cname = "xcb_glx_pixel_storef")]
		public VoidCookie pixel_storef (Context_tag context_tag, uint32 pname, Float32 datum);
		[CCode (cname = "xcb_glx_pixel_storef_checked")]
		public VoidCookie pixel_storef_checked (Context_tag context_tag, uint32 pname, Float32 datum);
		[CCode (cname = "xcb_glx_pixel_storei")]
		public VoidCookie pixel_storei (Context_tag context_tag, uint32 pname, int32 datum);
		[CCode (cname = "xcb_glx_pixel_storei_checked")]
		public VoidCookie pixel_storei_checked (Context_tag context_tag, uint32 pname, int32 datum);
		[CCode (cname = "xcb_glx_read_pixels")]
		public ReadPixelsCookie read_pixels (Context_tag context_tag, int32 x, int32 y, int32 width, int32 height, uint32 format, uint32 type, bool swap_bytes, bool lsb_first);
		[CCode (cname = "xcb_glx_get_booleanv")]
		public GetBooleanvCookie get_booleanv (Context_tag context_tag, int32 pname);
		[CCode (cname = "xcb_glx_get_clip_plane")]
		public GetClipPlaneCookie get_clip_plane (Context_tag context_tag, int32 plane);
		[CCode (cname = "xcb_glx_get_doublev")]
		public GetDoublevCookie get_doublev (Context_tag context_tag, uint32 pname);
		[CCode (cname = "xcb_glx_get_error")]
		public GetErrorCookie get_error (Context_tag context_tag);
		[CCode (cname = "xcb_glx_get_floatv")]
		public GetFloatvCookie get_floatv (Context_tag context_tag, uint32 pname);
		[CCode (cname = "xcb_glx_get_integerv")]
		public GetIntegervCookie get_integerv (Context_tag context_tag, uint32 pname);
		[CCode (cname = "xcb_glx_get_lightfv")]
		public GetLightfvCookie get_lightfv (Context_tag context_tag, uint32 light, uint32 pname);
		[CCode (cname = "xcb_glx_get_lightiv")]
		public GetLightivCookie get_lightiv (Context_tag context_tag, uint32 light, uint32 pname);
		[CCode (cname = "xcb_glx_get_mapdv")]
		public GetMapdvCookie get_mapdv (Context_tag context_tag, uint32 target, uint32 query);
		[CCode (cname = "xcb_glx_get_mapfv")]
		public GetMapfvCookie get_mapfv (Context_tag context_tag, uint32 target, uint32 query);
		[CCode (cname = "xcb_glx_get_mapiv")]
		public GetMapivCookie get_mapiv (Context_tag context_tag, uint32 target, uint32 query);
		[CCode (cname = "xcb_glx_get_materialfv")]
		public GetMaterialfvCookie get_materialfv (Context_tag context_tag, uint32 face, uint32 pname);
		[CCode (cname = "xcb_glx_get_materialiv")]
		public GetMaterialivCookie get_materialiv (Context_tag context_tag, uint32 face, uint32 pname);
		[CCode (cname = "xcb_glx_get_pixel_mapfv")]
		public GetPixelMapfvCookie get_pixel_mapfv (Context_tag context_tag, uint32 map);
		[CCode (cname = "xcb_glx_get_pixel_mapuiv")]
		public GetPixelMapuivCookie get_pixel_mapuiv (Context_tag context_tag, uint32 map);
		[CCode (cname = "xcb_glx_get_pixel_mapusv")]
		public GetPixelMapusvCookie get_pixel_mapusv (Context_tag context_tag, uint32 map);
		[CCode (cname = "xcb_glx_get_polygon_stipple")]
		public GetPolygonStippleCookie get_polygon_stipple (Context_tag context_tag, bool lsb_first);
		[CCode (cname = "xcb_glx_get_string")]
		public GetStringCookie get_string (Context_tag context_tag, uint32 name);
		[CCode (cname = "xcb_glx_get_tex_envfv")]
		public GetTexEnvfvCookie get_tex_envfv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_enviv")]
		public GetTexEnvivCookie get_tex_enviv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_gendv")]
		public GetTexGendvCookie get_tex_gendv (Context_tag context_tag, uint32 coord, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_genfv")]
		public GetTexGenfvCookie get_tex_genfv (Context_tag context_tag, uint32 coord, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_geniv")]
		public GetTexGenivCookie get_tex_geniv (Context_tag context_tag, uint32 coord, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_image")]
		public GetTexImageCookie get_tex_image (Context_tag context_tag, uint32 target, int32 level, uint32 format, uint32 type, bool swap_bytes);
		[CCode (cname = "xcb_glx_get_tex_parameterfv")]
		public GetTexParameterfvCookie get_tex_parameterfv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_parameteriv")]
		public GetTexParameterivCookie get_tex_parameteriv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_level_parameterfv")]
		public GetTexLevelParameterfvCookie get_tex_level_parameterfv (Context_tag context_tag, uint32 target, int32 level, uint32 pname);
		[CCode (cname = "xcb_glx_get_tex_level_parameteriv")]
		public GetTexLevelParameterivCookie get_tex_level_parameteriv (Context_tag context_tag, uint32 target, int32 level, uint32 pname);
		[CCode (cname = "xcb_glx_is_list")]
		public IsListCookie is_list (Context_tag context_tag, uint32 list);
		[CCode (cname = "xcb_glx_flush")]
		public VoidCookie flush (Context_tag context_tag);
		[CCode (cname = "xcb_glx_flush_checked")]
		public VoidCookie flush_checked (Context_tag context_tag);
		[CCode (cname = "xcb_glx_are_textures_resident")]
		public AreTexturesResidentCookie are_textures_resident (Context_tag context_tag, [CCode (array_length_pos = 1.2)]uint32[]? textures);
		[CCode (cname = "xcb_glx_delete_textures")]
		public VoidCookie delete_textures (Context_tag context_tag, [CCode (array_length_pos = 1.2)]uint32[]? textures);
		[CCode (cname = "xcb_glx_delete_textures_checked")]
		public VoidCookie delete_textures_checked (Context_tag context_tag, [CCode (array_length_pos = 1.2)]uint32[]? textures);
		[CCode (cname = "xcb_glx_gen_textures")]
		public GenTexturesCookie gen_textures (Context_tag context_tag, int32 n);
		[CCode (cname = "xcb_glx_is_texture")]
		public IsTextureCookie is_texture (Context_tag context_tag, uint32 texture);
		[CCode (cname = "xcb_glx_get_color_table")]
		public GetColorTableCookie get_color_table (Context_tag context_tag, uint32 target, uint32 format, uint32 type, bool swap_bytes);
		[CCode (cname = "xcb_glx_get_color_table_parameterfv")]
		public GetColorTableParameterfvCookie get_color_table_parameterfv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_color_table_parameteriv")]
		public GetColorTableParameterivCookie get_color_table_parameteriv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_convolution_filter")]
		public GetConvolutionFilterCookie get_convolution_filter (Context_tag context_tag, uint32 target, uint32 format, uint32 type, bool swap_bytes);
		[CCode (cname = "xcb_glx_get_convolution_parameterfv")]
		public GetConvolutionParameterfvCookie get_convolution_parameterfv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_convolution_parameteriv")]
		public GetConvolutionParameterivCookie get_convolution_parameteriv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_separable_filter")]
		public GetSeparableFilterCookie get_separable_filter (Context_tag context_tag, uint32 target, uint32 format, uint32 type, bool swap_bytes);
		[CCode (cname = "xcb_glx_get_histogram")]
		public GetHistogramCookie get_histogram (Context_tag context_tag, uint32 target, uint32 format, uint32 type, bool swap_bytes, bool reset);
		[CCode (cname = "xcb_glx_get_histogram_parameterfv")]
		public GetHistogramParameterfvCookie get_histogram_parameterfv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_histogram_parameteriv")]
		public GetHistogramParameterivCookie get_histogram_parameteriv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_minmax")]
		public GetMinmaxCookie get_minmax (Context_tag context_tag, uint32 target, uint32 format, uint32 type, bool swap_bytes, bool reset);
		[CCode (cname = "xcb_glx_get_minmax_parameterfv")]
		public GetMinmaxParameterfvCookie get_minmax_parameterfv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_minmax_parameteriv")]
		public GetMinmaxParameterivCookie get_minmax_parameteriv (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_compressed_tex_image_arb")]
		public GetCompressedTexImageArbCookie get_compressed_tex_image_arb (Context_tag context_tag, uint32 target, int32 level);
		[CCode (cname = "xcb_glx_delete_queries_arb")]
		public VoidCookie delete_queries_arb (Context_tag context_tag, [CCode (array_length_pos = 1.2)]uint32[]? ids);
		[CCode (cname = "xcb_glx_delete_queries_arb_checked")]
		public VoidCookie delete_queries_arb_checked (Context_tag context_tag, [CCode (array_length_pos = 1.2)]uint32[]? ids);
		[CCode (cname = "xcb_glx_gen_queries_arb")]
		public GenQueriesArbCookie gen_queries_arb (Context_tag context_tag, int32 n);
		[CCode (cname = "xcb_glx_is_query_arb")]
		public IsQueryArbCookie is_query_arb (Context_tag context_tag, uint32 id);
		[CCode (cname = "xcb_glx_get_queryiv_arb")]
		public GetQueryivArbCookie get_queryiv_arb (Context_tag context_tag, uint32 target, uint32 pname);
		[CCode (cname = "xcb_glx_get_query_objectiv_arb")]
		public GetQueryObjectivArbCookie get_query_objectiv_arb (Context_tag context_tag, uint32 id, uint32 pname);
		[CCode (cname = "xcb_glx_get_query_objectuiv_arb")]
		public GetQueryObjectuivArbCookie get_query_objectuiv_arb (Context_tag context_tag, uint32 id, uint32 pname);
	}

	[Compact, CCode (cname = "xcb_glx_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major_version;
		public uint32 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_glx_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_glx_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_visual_configs_reply_t", free_function = "free")]
	public class GetVisualConfigsReply {
		public uint32 num_visuals;
		public uint32 num_properties;
		public int property_list_length {
			[CCode (cname = "xcb_glx_get_visual_configs_property_list_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] property_list {
			[CCode (cname = "xcb_glx_get_visual_configs_property_list")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_visual_configs_cookie_t")]
	public struct GetVisualConfigsCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_visual_configs_reply", instance_pos = 1.1)]
		public GetVisualConfigsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_vendor_private_with_reply_reply_t", free_function = "free")]
	public class VendorPrivateWithReplyReply {
		public uint32 retval;
		public uint8 data1[24];
		public int data_2_length {
			[CCode (cname = "xcb_glx_vendor_private_with_reply_data_2_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data_2 {
			[CCode (cname = "xcb_glx_vendor_private_with_reply_data_2")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_vendor_private_with_reply_cookie_t")]
	public struct VendorPrivateWithReplyCookie : VoidCookie {
		[CCode (cname = "xcb_glx_vendor_private_with_reply_reply", instance_pos = 1.1)]
		public VendorPrivateWithReplyReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_query_extensions_string_reply_t", free_function = "free")]
	public class QueryExtensionsStringReply {
		public uint32 n;
	}

	[SimpleType, CCode (cname = "xcb_glx_query_extensions_string_cookie_t")]
	public struct QueryExtensionsStringCookie : VoidCookie {
		[CCode (cname = "xcb_glx_query_extensions_string_reply", instance_pos = 1.1)]
		public QueryExtensionsStringReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_query_server_string_reply_t", free_function = "free")]
	public class QueryServerStringReply {
		public uint32 str_len;
		[CCode (cname = "xcb_glx_query_server_string_string_length")]
		int _string_length ();
		[CCode (cname = "xcb_glx_query_server_string_string", array_length = false)]
		unowned char[] _string ();
		public string string {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_string (), _string_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_query_server_string_cookie_t")]
	public struct QueryServerStringCookie : VoidCookie {
		[CCode (cname = "xcb_glx_query_server_string_reply", instance_pos = 1.1)]
		public QueryServerStringReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_fb_configs_reply_t", free_function = "free")]
	public class GetFbconfigsReply {
		public uint32 num_FB_configs;
		public uint32 num_properties;
		public int property_list_length {
			[CCode (cname = "xcb_glx_get_fb_configs_property_list_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] property_list {
			[CCode (cname = "xcb_glx_get_fb_configs_property_list")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_fb_configs_cookie_t")]
	public struct GetFbconfigsCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_fb_configs_reply", instance_pos = 1.1)]
		public GetFbconfigsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_gen_lists_reply_t", free_function = "free")]
	public class GenListsReply {
		public uint32 ret_val;
	}

	[SimpleType, CCode (cname = "xcb_glx_gen_lists_cookie_t")]
	public struct GenListsCookie : VoidCookie {
		[CCode (cname = "xcb_glx_gen_lists_reply", instance_pos = 1.1)]
		public GenListsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_render_mode_reply_t", free_function = "free")]
	public class RenderModeReply {
		public uint32 ret_val;
		public uint32 n;
		public uint32 new_mode;
		public int data_length {
			[CCode (cname = "xcb_glx_render_mode_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] data {
			[CCode (cname = "xcb_glx_render_mode_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_render_mode_cookie_t")]
	public struct RenderModeCookie : VoidCookie {
		[CCode (cname = "xcb_glx_render_mode_reply", instance_pos = 1.1)]
		public RenderModeReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_finish_reply_t", free_function = "free")]
	public class FinishReply {
	}

	[SimpleType, CCode (cname = "xcb_glx_finish_cookie_t")]
	public struct FinishCookie : VoidCookie {
		[CCode (cname = "xcb_glx_finish_reply", instance_pos = 1.1)]
		public FinishReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_read_pixels_reply_t", free_function = "free")]
	public class ReadPixelsReply {
		public int data_length {
			[CCode (cname = "xcb_glx_read_pixels_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_read_pixels_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_read_pixels_cookie_t")]
	public struct ReadPixelsCookie : VoidCookie {
		[CCode (cname = "xcb_glx_read_pixels_reply", instance_pos = 1.1)]
		public ReadPixelsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_booleanv_reply_t", free_function = "free")]
	public class GetBooleanvReply {
		public uint32 n;
		public bool datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_booleanv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned bool[] data {
			[CCode (cname = "xcb_glx_get_booleanv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_booleanv_cookie_t")]
	public struct GetBooleanvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_booleanv_reply", instance_pos = 1.1)]
		public GetBooleanvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_clip_plane_reply_t", free_function = "free")]
	public class GetClipPlaneReply {
		public int data_length {
			[CCode (cname = "xcb_glx_get_clip_plane_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float64[] data {
			[CCode (cname = "xcb_glx_get_clip_plane_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_clip_plane_cookie_t")]
	public struct GetClipPlaneCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_clip_plane_reply", instance_pos = 1.1)]
		public GetClipPlaneReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_doublev_reply_t", free_function = "free")]
	public class GetDoublevReply {
		public uint32 n;
		public Float64 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_doublev_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float64[] data {
			[CCode (cname = "xcb_glx_get_doublev_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_doublev_cookie_t")]
	public struct GetDoublevCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_doublev_reply", instance_pos = 1.1)]
		public GetDoublevReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_error_reply_t", free_function = "free")]
	public class GetErrorReply {
		public int32 error;
	}

	[SimpleType, CCode (cname = "xcb_glx_get_error_cookie_t")]
	public struct GetErrorCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_error_reply", instance_pos = 1.1)]
		public GetErrorReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_floatv_reply_t", free_function = "free")]
	public class GetFloatvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_floatv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_floatv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_floatv_cookie_t")]
	public struct GetFloatvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_floatv_reply", instance_pos = 1.1)]
		public GetFloatvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_integerv_reply_t", free_function = "free")]
	public class GetIntegervReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_integerv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_integerv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_integerv_cookie_t")]
	public struct GetIntegervCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_integerv_reply", instance_pos = 1.1)]
		public GetIntegervReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_lightfv_reply_t", free_function = "free")]
	public class GetLightfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_lightfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_lightfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_lightfv_cookie_t")]
	public struct GetLightfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_lightfv_reply", instance_pos = 1.1)]
		public GetLightfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_lightiv_reply_t", free_function = "free")]
	public class GetLightivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_lightiv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_lightiv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_lightiv_cookie_t")]
	public struct GetLightivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_lightiv_reply", instance_pos = 1.1)]
		public GetLightivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_mapdv_reply_t", free_function = "free")]
	public class GetMapdvReply {
		public uint32 n;
		public Float64 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_mapdv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float64[] data {
			[CCode (cname = "xcb_glx_get_mapdv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_mapdv_cookie_t")]
	public struct GetMapdvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_mapdv_reply", instance_pos = 1.1)]
		public GetMapdvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_mapfv_reply_t", free_function = "free")]
	public class GetMapfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_mapfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_mapfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_mapfv_cookie_t")]
	public struct GetMapfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_mapfv_reply", instance_pos = 1.1)]
		public GetMapfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_mapiv_reply_t", free_function = "free")]
	public class GetMapivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_mapiv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_mapiv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_mapiv_cookie_t")]
	public struct GetMapivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_mapiv_reply", instance_pos = 1.1)]
		public GetMapivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_materialfv_reply_t", free_function = "free")]
	public class GetMaterialfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_materialfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_materialfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_materialfv_cookie_t")]
	public struct GetMaterialfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_materialfv_reply", instance_pos = 1.1)]
		public GetMaterialfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_materialiv_reply_t", free_function = "free")]
	public class GetMaterialivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_materialiv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_materialiv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_materialiv_cookie_t")]
	public struct GetMaterialivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_materialiv_reply", instance_pos = 1.1)]
		public GetMaterialivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_pixel_mapfv_reply_t", free_function = "free")]
	public class GetPixelMapfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_pixel_mapfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_pixel_mapfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_pixel_mapfv_cookie_t")]
	public struct GetPixelMapfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_pixel_mapfv_reply", instance_pos = 1.1)]
		public GetPixelMapfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_pixel_mapuiv_reply_t", free_function = "free")]
	public class GetPixelMapuivReply {
		public uint32 n;
		public uint32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_pixel_mapuiv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] data {
			[CCode (cname = "xcb_glx_get_pixel_mapuiv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_pixel_mapuiv_cookie_t")]
	public struct GetPixelMapuivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_pixel_mapuiv_reply", instance_pos = 1.1)]
		public GetPixelMapuivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_pixel_mapusv_reply_t", free_function = "free")]
	public class GetPixelMapusvReply {
		public uint32 n;
		public uint16 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_pixel_mapusv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] data {
			[CCode (cname = "xcb_glx_get_pixel_mapusv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_pixel_mapusv_cookie_t")]
	public struct GetPixelMapusvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_pixel_mapusv_reply", instance_pos = 1.1)]
		public GetPixelMapusvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_polygon_stipple_reply_t", free_function = "free")]
	public class GetPolygonStippleReply {
		public int data_length {
			[CCode (cname = "xcb_glx_get_polygon_stipple_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_polygon_stipple_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_polygon_stipple_cookie_t")]
	public struct GetPolygonStippleCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_polygon_stipple_reply", instance_pos = 1.1)]
		public GetPolygonStippleReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_string_reply_t", free_function = "free")]
	public class GetStringReply {
		public uint32 n;
		[CCode (cname = "xcb_glx_get_string_string_length")]
		int _string_length ();
		[CCode (cname = "xcb_glx_get_string_string", array_length = false)]
		unowned char[] _string ();
		public string string {
			owned get {
				GLib.StringBuilder ret = new GLib.StringBuilder ();
				ret.append_len ((string)_string (), _string_length ());
				return ret.str;
			}
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_string_cookie_t")]
	public struct GetStringCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_string_reply", instance_pos = 1.1)]
		public GetStringReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_envfv_reply_t", free_function = "free")]
	public class GetTexEnvfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_envfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_tex_envfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_envfv_cookie_t")]
	public struct GetTexEnvfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_envfv_reply", instance_pos = 1.1)]
		public GetTexEnvfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_enviv_reply_t", free_function = "free")]
	public class GetTexEnvivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_enviv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_tex_enviv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_enviv_cookie_t")]
	public struct GetTexEnvivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_enviv_reply", instance_pos = 1.1)]
		public GetTexEnvivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_gendv_reply_t", free_function = "free")]
	public class GetTexGendvReply {
		public uint32 n;
		public Float64 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_gendv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float64[] data {
			[CCode (cname = "xcb_glx_get_tex_gendv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_gendv_cookie_t")]
	public struct GetTexGendvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_gendv_reply", instance_pos = 1.1)]
		public GetTexGendvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_genfv_reply_t", free_function = "free")]
	public class GetTexGenfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_genfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_tex_genfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_genfv_cookie_t")]
	public struct GetTexGenfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_genfv_reply", instance_pos = 1.1)]
		public GetTexGenfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_geniv_reply_t", free_function = "free")]
	public class GetTexGenivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_geniv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_tex_geniv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_geniv_cookie_t")]
	public struct GetTexGenivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_geniv_reply", instance_pos = 1.1)]
		public GetTexGenivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_image_reply_t", free_function = "free")]
	public class GetTexImageReply {
		public int32 width;
		public int32 height;
		public int32 depth;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_image_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_tex_image_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_image_cookie_t")]
	public struct GetTexImageCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_image_reply", instance_pos = 1.1)]
		public GetTexImageReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_parameterfv_reply_t", free_function = "free")]
	public class GetTexParameterfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_parameterfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_tex_parameterfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_parameterfv_cookie_t")]
	public struct GetTexParameterfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_parameterfv_reply", instance_pos = 1.1)]
		public GetTexParameterfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_parameteriv_reply_t", free_function = "free")]
	public class GetTexParameterivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_parameteriv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_tex_parameteriv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_parameteriv_cookie_t")]
	public struct GetTexParameterivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_parameteriv_reply", instance_pos = 1.1)]
		public GetTexParameterivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_level_parameterfv_reply_t", free_function = "free")]
	public class GetTexLevelParameterfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_level_parameterfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_tex_level_parameterfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_level_parameterfv_cookie_t")]
	public struct GetTexLevelParameterfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_level_parameterfv_reply", instance_pos = 1.1)]
		public GetTexLevelParameterfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_tex_level_parameteriv_reply_t", free_function = "free")]
	public class GetTexLevelParameterivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_tex_level_parameteriv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_tex_level_parameteriv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_tex_level_parameteriv_cookie_t")]
	public struct GetTexLevelParameterivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_tex_level_parameteriv_reply", instance_pos = 1.1)]
		public GetTexLevelParameterivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_is_list_reply_t", free_function = "free")]
	public class IsListReply {
		public Bool32 ret_val;
	}

	[SimpleType, CCode (cname = "xcb_glx_is_list_cookie_t")]
	public struct IsListCookie : VoidCookie {
		[CCode (cname = "xcb_glx_is_list_reply", instance_pos = 1.1)]
		public IsListReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_are_textures_resident_reply_t", free_function = "free")]
	public class AreTexturesResidentReply {
		public Bool32 ret_val;
		public int data_length {
			[CCode (cname = "xcb_glx_are_textures_resident_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned bool[] data {
			[CCode (cname = "xcb_glx_are_textures_resident_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_are_textures_resident_cookie_t")]
	public struct AreTexturesResidentCookie : VoidCookie {
		[CCode (cname = "xcb_glx_are_textures_resident_reply", instance_pos = 1.1)]
		public AreTexturesResidentReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_gen_textures_reply_t", free_function = "free")]
	public class GenTexturesReply {
		public int data_length {
			[CCode (cname = "xcb_glx_gen_textures_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] data {
			[CCode (cname = "xcb_glx_gen_textures_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_gen_textures_cookie_t")]
	public struct GenTexturesCookie : VoidCookie {
		[CCode (cname = "xcb_glx_gen_textures_reply", instance_pos = 1.1)]
		public GenTexturesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_is_texture_reply_t", free_function = "free")]
	public class IsTextureReply {
		public Bool32 ret_val;
	}

	[SimpleType, CCode (cname = "xcb_glx_is_texture_cookie_t")]
	public struct IsTextureCookie : VoidCookie {
		[CCode (cname = "xcb_glx_is_texture_reply", instance_pos = 1.1)]
		public IsTextureReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_color_table_reply_t", free_function = "free")]
	public class GetColorTableReply {
		public int32 width;
		public int data_length {
			[CCode (cname = "xcb_glx_get_color_table_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_color_table_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_color_table_cookie_t")]
	public struct GetColorTableCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_color_table_reply", instance_pos = 1.1)]
		public GetColorTableReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_color_table_parameterfv_reply_t", free_function = "free")]
	public class GetColorTableParameterfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_color_table_parameterfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_color_table_parameterfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_color_table_parameterfv_cookie_t")]
	public struct GetColorTableParameterfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_color_table_parameterfv_reply", instance_pos = 1.1)]
		public GetColorTableParameterfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_color_table_parameteriv_reply_t", free_function = "free")]
	public class GetColorTableParameterivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_color_table_parameteriv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_color_table_parameteriv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_color_table_parameteriv_cookie_t")]
	public struct GetColorTableParameterivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_color_table_parameteriv_reply", instance_pos = 1.1)]
		public GetColorTableParameterivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_convolution_filter_reply_t", free_function = "free")]
	public class GetConvolutionFilterReply {
		public int32 width;
		public int32 height;
		public int data_length {
			[CCode (cname = "xcb_glx_get_convolution_filter_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_convolution_filter_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_convolution_filter_cookie_t")]
	public struct GetConvolutionFilterCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_convolution_filter_reply", instance_pos = 1.1)]
		public GetConvolutionFilterReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_convolution_parameterfv_reply_t", free_function = "free")]
	public class GetConvolutionParameterfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_convolution_parameterfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_convolution_parameterfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_convolution_parameterfv_cookie_t")]
	public struct GetConvolutionParameterfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_convolution_parameterfv_reply", instance_pos = 1.1)]
		public GetConvolutionParameterfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_convolution_parameteriv_reply_t", free_function = "free")]
	public class GetConvolutionParameterivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_convolution_parameteriv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_convolution_parameteriv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_convolution_parameteriv_cookie_t")]
	public struct GetConvolutionParameterivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_convolution_parameteriv_reply", instance_pos = 1.1)]
		public GetConvolutionParameterivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_separable_filter_reply_t", free_function = "free")]
	public class GetSeparableFilterReply {
		public int32 row_w;
		public int32 col_h;
		public int rows_and_cols_length {
			[CCode (cname = "xcb_glx_get_separable_filter_rows_and_cols_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] rows_and_cols {
			[CCode (cname = "xcb_glx_get_separable_filter_rows_and_cols")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_separable_filter_cookie_t")]
	public struct GetSeparableFilterCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_separable_filter_reply", instance_pos = 1.1)]
		public GetSeparableFilterReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_histogram_reply_t", free_function = "free")]
	public class GetHistogramReply {
		public int32 width;
		public int data_length {
			[CCode (cname = "xcb_glx_get_histogram_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_histogram_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_histogram_cookie_t")]
	public struct GetHistogramCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_histogram_reply", instance_pos = 1.1)]
		public GetHistogramReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_histogram_parameterfv_reply_t", free_function = "free")]
	public class GetHistogramParameterfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_histogram_parameterfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_histogram_parameterfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_histogram_parameterfv_cookie_t")]
	public struct GetHistogramParameterfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_histogram_parameterfv_reply", instance_pos = 1.1)]
		public GetHistogramParameterfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_histogram_parameteriv_reply_t", free_function = "free")]
	public class GetHistogramParameterivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_histogram_parameteriv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_histogram_parameteriv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_histogram_parameteriv_cookie_t")]
	public struct GetHistogramParameterivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_histogram_parameteriv_reply", instance_pos = 1.1)]
		public GetHistogramParameterivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_minmax_reply_t", free_function = "free")]
	public class GetMinmaxReply {
		public int data_length {
			[CCode (cname = "xcb_glx_get_minmax_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_minmax_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_minmax_cookie_t")]
	public struct GetMinmaxCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_minmax_reply", instance_pos = 1.1)]
		public GetMinmaxReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_minmax_parameterfv_reply_t", free_function = "free")]
	public class GetMinmaxParameterfvReply {
		public uint32 n;
		public Float32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_minmax_parameterfv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Float32[] data {
			[CCode (cname = "xcb_glx_get_minmax_parameterfv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_minmax_parameterfv_cookie_t")]
	public struct GetMinmaxParameterfvCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_minmax_parameterfv_reply", instance_pos = 1.1)]
		public GetMinmaxParameterfvReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_minmax_parameteriv_reply_t", free_function = "free")]
	public class GetMinmaxParameterivReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_minmax_parameteriv_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_minmax_parameteriv_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_minmax_parameteriv_cookie_t")]
	public struct GetMinmaxParameterivCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_minmax_parameteriv_reply", instance_pos = 1.1)]
		public GetMinmaxParameterivReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_compressed_tex_image_arb_reply_t", free_function = "free")]
	public class GetCompressedTexImageArbReply {
		public int32 size;
		public int data_length {
			[CCode (cname = "xcb_glx_get_compressed_tex_image_arb_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint8[] data {
			[CCode (cname = "xcb_glx_get_compressed_tex_image_arb_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_compressed_tex_image_arb_cookie_t")]
	public struct GetCompressedTexImageArbCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_compressed_tex_image_arb_reply", instance_pos = 1.1)]
		public GetCompressedTexImageArbReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_gen_queries_arb_reply_t", free_function = "free")]
	public class GenQueriesArbReply {
		public int data_length {
			[CCode (cname = "xcb_glx_gen_queries_arb_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] data {
			[CCode (cname = "xcb_glx_gen_queries_arb_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_gen_queries_arb_cookie_t")]
	public struct GenQueriesArbCookie : VoidCookie {
		[CCode (cname = "xcb_glx_gen_queries_arb_reply", instance_pos = 1.1)]
		public GenQueriesArbReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_is_query_arb_reply_t", free_function = "free")]
	public class IsQueryArbReply {
		public Bool32 ret_val;
	}

	[SimpleType, CCode (cname = "xcb_glx_is_query_arb_cookie_t")]
	public struct IsQueryArbCookie : VoidCookie {
		[CCode (cname = "xcb_glx_is_query_arb_reply", instance_pos = 1.1)]
		public IsQueryArbReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_queryiv_arb_reply_t", free_function = "free")]
	public class GetQueryivArbReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_queryiv_arb_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_queryiv_arb_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_queryiv_arb_cookie_t")]
	public struct GetQueryivArbCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_queryiv_arb_reply", instance_pos = 1.1)]
		public GetQueryivArbReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_query_objectiv_arb_reply_t", free_function = "free")]
	public class GetQueryObjectivArbReply {
		public uint32 n;
		public int32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_query_objectiv_arb_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned int32[] data {
			[CCode (cname = "xcb_glx_get_query_objectiv_arb_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_query_objectiv_arb_cookie_t")]
	public struct GetQueryObjectivArbCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_query_objectiv_arb_reply", instance_pos = 1.1)]
		public GetQueryObjectivArbReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_query_objectuiv_arb_reply_t", free_function = "free")]
	public class GetQueryObjectuivArbReply {
		public uint32 n;
		public uint32 datum;
		public int data_length {
			[CCode (cname = "xcb_glx_get_query_objectuiv_arb_data_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] data {
			[CCode (cname = "xcb_glx_get_query_objectuiv_arb_data")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_query_objectuiv_arb_cookie_t")]
	public struct GetQueryObjectuivArbCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_query_objectuiv_arb_reply", instance_pos = 1.1)]
		public GetQueryObjectuivArbReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_glx_pixmap_iterator_t")]
	struct _PixmapIterator
	{
		int rem;
		int index;
		unowned Pixmap? data;
	}

	[CCode (cname = "xcb_glx_pixmap_iterator_t")]
	public struct PixmapIterator
	{
		[CCode (cname = "xcb_glx_pixmap_next")]
		void _next ();

		public inline unowned Pixmap?
		next_value ()
		{
			if (((_PixmapIterator)this).rem > 0)
			{
				unowned Pixmap? d = ((_PixmapIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_glx_pixmap_t", has_type_id = false)]
	public struct Pixmap : uint32 {
		[CCode (cname = "xcb_glx_create_glx_pixmap", instance_pos = 3.3)]
		public VoidCookie create_glx (Xcb.Connection connection, uint32 screen, Visualid visual, Pixmap glx_pixmap);
		[CCode (cname = "xcb_glx_create_glx_pixmap_checked", instance_pos = 3.3)]
		public VoidCookie create_glx_checked (Xcb.Connection connection, uint32 screen, Visualid visual, Pixmap glx_pixmap);
		[CCode (cname = "xcb_glx_destroy_glx_pixmap", instance_pos = 1.1)]
		public VoidCookie destroy_glx (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_destroy_glx_pixmap_checked", instance_pos = 1.1)]
		public VoidCookie destroy_glx_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_destroy_pixmap", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_destroy_pixmap_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
	}

	[SimpleType, CCode (cname = "xcb_glx_context_iterator_t")]
	struct _ContextIterator
	{
		int rem;
		int index;
		unowned Context? data;
	}

	[CCode (cname = "xcb_glx_context_iterator_t")]
	public struct ContextIterator
	{
		[CCode (cname = "xcb_glx_context_next")]
		void _next ();

		public inline unowned Context?
		next_value ()
		{
			if (((_ContextIterator)this).rem > 0)
			{
				unowned Context? d = ((_ContextIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_glx_context_t", has_type_id = false)]
	public struct Context : uint32 {
		/**
		 * Allocates an XID for a new Context.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Context (Xcb.Connection connection);

		[CCode (cname = "xcb_glx_create_context", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, Visualid visual, uint32 screen, Context share_list, bool is_direct);
		[CCode (cname = "xcb_glx_create_context_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, Visualid visual, uint32 screen, Context share_list, bool is_direct);
		[CCode (cname = "xcb_glx_destroy_context", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_destroy_context_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_is_direct", instance_pos = 1.1)]
		public IsDirectCookie is_direct (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_copy_context", instance_pos = 1.1)]
		public VoidCookie copy (Xcb.Connection connection, Context dest, uint32 mask, Context_tag src_context_tag);
		[CCode (cname = "xcb_glx_copy_context_checked", instance_pos = 1.1)]
		public VoidCookie copy_checked (Xcb.Connection connection, Context dest, uint32 mask, Context_tag src_context_tag);
		[CCode (cname = "xcb_glx_create_new_context", instance_pos = 1.1)]
		public VoidCookie create_new (Xcb.Connection connection, Fbconfig fbconfig, uint32 screen, uint32 render_type, Context share_list, bool is_direct);
		[CCode (cname = "xcb_glx_create_new_context_checked", instance_pos = 1.1)]
		public VoidCookie create_new_checked (Xcb.Connection connection, Fbconfig fbconfig, uint32 screen, uint32 render_type, Context share_list, bool is_direct);
		[CCode (cname = "xcb_glx_query_context", instance_pos = 1.1)]
		public QueryContextCookie query (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_create_context_attribs_arb", instance_pos = 1.1)]
		public VoidCookie create_attribs_arb (Xcb.Connection connection, Fbconfig fbconfig, uint32 screen, Context share_list, bool is_direct, [CCode (array_length_pos = 5.6)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_create_context_attribs_arb_checked", instance_pos = 1.1)]
		public VoidCookie create_attribs_arb_checked (Xcb.Connection connection, Fbconfig fbconfig, uint32 screen, Context share_list, bool is_direct, [CCode (array_length_pos = 5.6)]uint32[]? attribs);
	}

	[Compact, CCode (cname = "xcb_glx_is_direct_reply_t", free_function = "free")]
	public class IsDirectReply {
		public bool is_direct;
	}

	[SimpleType, CCode (cname = "xcb_glx_is_direct_cookie_t")]
	public struct IsDirectCookie : VoidCookie {
		[CCode (cname = "xcb_glx_is_direct_reply", instance_pos = 1.1)]
		public IsDirectReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_query_context_reply_t", free_function = "free")]
	public class QueryContextReply {
		public uint32 num_attribs;
		public int attribs_length {
			[CCode (cname = "xcb_glx_query_context_attribs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] attribs {
			[CCode (cname = "xcb_glx_query_context_attribs")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_query_context_cookie_t")]
	public struct QueryContextCookie : VoidCookie {
		[CCode (cname = "xcb_glx_query_context_reply", instance_pos = 1.1)]
		public QueryContextReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_glx_pbuffer_iterator_t")]
	struct _PbufferIterator
	{
		int rem;
		int index;
		unowned Pbuffer? data;
	}

	[CCode (cname = "xcb_glx_pbuffer_iterator_t")]
	public struct PbufferIterator
	{
		[CCode (cname = "xcb_glx_pbuffer_next")]
		void _next ();

		public inline unowned Pbuffer?
		next_value ()
		{
			if (((_PbufferIterator)this).rem > 0)
			{
				unowned Pbuffer? d = ((_PbufferIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_glx_pbuffer_t", has_type_id = false)]
	public struct Pbuffer : Drawable {
		[CCode (cname = "xcb_glx_destroy_pbuffer", instance_pos = 1.1)]
		public VoidCookie destroy (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_destroy_pbuffer_checked", instance_pos = 1.1)]
		public VoidCookie destroy_checked (Xcb.Connection connection);
	}

	[SimpleType, CCode (cname = "xcb_glx_window_iterator_t")]
	struct _WindowIterator
	{
		int rem;
		int index;
		unowned Window? data;
	}

	[CCode (cname = "xcb_glx_window_iterator_t")]
	public struct WindowIterator
	{
		[CCode (cname = "xcb_glx_window_next")]
		void _next ();

		public inline unowned Window?
		next_value ()
		{
			if (((_WindowIterator)this).rem > 0)
			{
				unowned Window? d = ((_WindowIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_glx_window_t", has_type_id = false)]
	public struct Window : uint32 {
		[CCode (cname = "xcb_glx_delete_window", instance_pos = 1.1)]
		public VoidCookie delete (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_delete_window_checked", instance_pos = 1.1)]
		public VoidCookie delete_checked (Xcb.Connection connection);
	}

	[SimpleType, CCode (cname = "xcb_glx_fbconfig_iterator_t")]
	struct _FbconfigIterator
	{
		int rem;
		int index;
		unowned Fbconfig? data;
	}

	[CCode (cname = "xcb_glx_fbconfig_iterator_t")]
	public struct FbconfigIterator
	{
		[CCode (cname = "xcb_glx_fbconfig_next")]
		void _next ();

		public inline unowned Fbconfig?
		next_value ()
		{
			if (((_FbconfigIterator)this).rem > 0)
			{
				unowned Fbconfig? d = ((_FbconfigIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_glx_fbconfig_t", has_type_id = false)]
	public struct Fbconfig : uint32 {
		[CCode (cname = "xcb_glx_create_pixmap", instance_pos = 2.2)]
		public VoidCookie create_pixmap (Xcb.Connection connection, uint32 screen, Pixmap pixmap, Pixmap glx_pixmap, [CCode (array_length_pos = 4.5)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_create_pixmap_checked", instance_pos = 2.2)]
		public VoidCookie create_pixmap_checked (Xcb.Connection connection, uint32 screen, Pixmap pixmap, Pixmap glx_pixmap, [CCode (array_length_pos = 4.5)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_create_pbuffer", instance_pos = 2.2)]
		public VoidCookie create_pbuffer (Xcb.Connection connection, uint32 screen, Pbuffer pbuffer, [CCode (array_length_pos = 3.4)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_create_pbuffer_checked", instance_pos = 2.2)]
		public VoidCookie create_pbuffer_checked (Xcb.Connection connection, uint32 screen, Pbuffer pbuffer, [CCode (array_length_pos = 3.4)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_create_window", instance_pos = 2.2)]
		public VoidCookie create_window (Xcb.Connection connection, uint32 screen, Window window, Window glx_window, [CCode (array_length_pos = 4.5)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_create_window_checked", instance_pos = 2.2)]
		public VoidCookie create_window_checked (Xcb.Connection connection, uint32 screen, Window window, Window glx_window, [CCode (array_length_pos = 4.5)]uint32[]? attribs);
	}

	[CCode (cname = "xcb_glx_drawable_t", has_type_id = false)]
	public struct Drawable : uint32 {
		[CCode (cname = "xcb_glx_make_current", instance_pos = 1.1)]
		public MakeCurrentCookie make_current (Xcb.Connection connection, Context context, Context_tag old_context_tag);
		[CCode (cname = "xcb_glx_swap_buffers", instance_pos = 2.2)]
		public VoidCookie swap_buffers (Xcb.Connection connection, Context_tag context_tag);
		[CCode (cname = "xcb_glx_swap_buffers_checked", instance_pos = 2.2)]
		public VoidCookie swap_buffers_checked (Xcb.Connection connection, Context_tag context_tag);
		[CCode (cname = "xcb_glx_make_context_current", instance_pos = 2.2)]
		public MakeContextCurrentCookie make_context_current (Xcb.Connection connection, Context_tag old_context_tag, Drawable read_drawable, Context context);
		[CCode (cname = "xcb_glx_get_drawable_attributes", instance_pos = 1.1)]
		public GetDrawableAttributesCookie get_attributes (Xcb.Connection connection);
		[CCode (cname = "xcb_glx_change_drawable_attributes", instance_pos = 1.1)]
		public VoidCookie change_attributes (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint32[]? attribs);
		[CCode (cname = "xcb_glx_change_drawable_attributes_checked", instance_pos = 1.1)]
		public VoidCookie change_attributes_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint32[]? attribs);
	}

	[Compact, CCode (cname = "xcb_glx_make_current_reply_t", free_function = "free")]
	public class MakeCurrentReply {
		public Context_tag context_tag;
	}

	[SimpleType, CCode (cname = "xcb_glx_make_current_cookie_t")]
	public struct MakeCurrentCookie : VoidCookie {
		[CCode (cname = "xcb_glx_make_current_reply", instance_pos = 1.1)]
		public MakeCurrentReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_make_context_current_reply_t", free_function = "free")]
	public class MakeContextCurrentReply {
		public Context_tag context_tag;
	}

	[SimpleType, CCode (cname = "xcb_glx_make_context_current_cookie_t")]
	public struct MakeContextCurrentCookie : VoidCookie {
		[CCode (cname = "xcb_glx_make_context_current_reply", instance_pos = 1.1)]
		public MakeContextCurrentReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_glx_get_drawable_attributes_reply_t", free_function = "free")]
	public class GetDrawableAttributesReply {
		public uint32 num_attribs;
		public int attribs_length {
			[CCode (cname = "xcb_glx_get_drawable_attributes_attribs_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] attribs {
			[CCode (cname = "xcb_glx_get_drawable_attributes_attribs")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_glx_get_drawable_attributes_cookie_t")]
	public struct GetDrawableAttributesCookie : VoidCookie {
		[CCode (cname = "xcb_glx_get_drawable_attributes_reply", instance_pos = 1.1)]
		public GetDrawableAttributesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_glx_float32_t", has_type_id = false)]
	public struct Float32 : float {
	}

	[SimpleType, CCode (cname = "xcb_glx_float64_t", has_type_id = false)]
	public struct Float64 : double {
	}

	[SimpleType, CCode (cname = "xcb_glx_bool32_t", has_type_id = false)]
	public struct Bool32 : uint32 {
	}

	[SimpleType, CCode (cname = "xcb_glx_context_tag_t", has_type_id = false)]
	public struct Context_tag : uint32 {
	}

	[Compact, CCode (cname = "xcb_glx_generic_error_t", has_type_id = false)]
	public class GenericError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_pbuffer_clobber_event_t", has_type_id = false)]
	public class PbufferClobberEvent : Xcb.GenericEvent {
		public uint16 event_type;
		public uint16 draw_type;
		public Drawable drawable;
		public uint32 b_mask;
		public uint16 aux_buffer;
		public uint16 x;
		public uint16 y;
		public uint16 width;
		public uint16 height;
		public uint16 count;
	}

	[Compact, CCode (cname = "xcb_glx_buffer_swap_complete_event_t", has_type_id = false)]
	public class BufferSwapCompleteEvent : Xcb.GenericEvent {
		public uint16 event_type;
		public Drawable drawable;
		public uint32 ust_hi;
		public uint32 ust_lo;
		public uint32 msc_hi;
		public uint32 msc_lo;
		public uint32 sbc;
	}

	[CCode (cname = "xcb_glx_pbcet_t", cprefix =  "XCB_GLX_PBCET_", has_type_id = false)]
	public enum Pbcet {
		DAMAGED,
		SAVED
	}

	[CCode (cname = "xcb_glx_pbcdt_t", cprefix =  "XCB_GLX_PBCDT_", has_type_id = false)]
	public enum Pbcdt {
		WINDOW,
		PBUFFER
	}

	[CCode (cname = "xcb_glx_gc_t", cprefix =  "XCB_GLX_GC_", has_type_id = false)]
	public enum GC {
		GL_CURRENT_BIT,
		GL_POINT_BIT,
		GL_LINE_BIT,
		GL_POLYGON_BIT,
		GL_POLYGON_STIPPLE_BIT,
		GL_PIXEL_MODE_BIT,
		GL_LIGHTING_BIT,
		GL_FOG_BIT,
		GL_DEPTH_BUFFER_BIT,
		GL_ACCUM_BUFFER_BIT,
		GL_STENCIL_BUFFER_BIT,
		GL_VIEWPORT_BIT,
		GL_TRANSFORM_BIT,
		GL_ENABLE_BIT,
		GL_COLOR_BUFFER_BIT,
		GL_HINT_BIT,
		GL_EVAL_BIT,
		GL_LIST_BIT,
		GL_TEXTURE_BIT,
		GL_SCISSOR_BIT,
		GL_ALL_ATTRIB_BITS
	}

	[CCode (cname = "xcb_glx_rm_t", cprefix =  "XCB_GLX_RM_", has_type_id = false)]
	public enum Rm {
		GL_RENDER,
		GL_FEEDBACK,
		GL_SELECT
	}

	[Compact, CCode (cname = "xcb_glx_bad_context_error_t", has_type_id = false)]
	public class BadContextError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_context_state_error_t", has_type_id = false)]
	public class BadContextStateError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_drawable_error_t", has_type_id = false)]
	public class BadDrawableError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_pixmap_error_t", has_type_id = false)]
	public class BadPixmapError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_context_tag_error_t", has_type_id = false)]
	public class BadContextTagError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_current_window_error_t", has_type_id = false)]
	public class BadCurrentWindowError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_render_request_error_t", has_type_id = false)]
	public class BadRenderRequestError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_large_request_error_t", has_type_id = false)]
	public class BadLargeRequestError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_unsupported_private_request_error_t", has_type_id = false)]
	public class UnsupportedPrivateRequestError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_fb_config_error_t", has_type_id = false)]
	public class BadFbconfigError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_pbuffer_error_t", has_type_id = false)]
	public class BadPbufferError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_current_drawable_error_t", has_type_id = false)]
	public class BadCurrentDrawableError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_bad_window_error_t", has_type_id = false)]
	public class BadWindowError : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[Compact, CCode (cname = "xcb_glx_glx_bad_profile_arb_error_t", has_type_id = false)]
	public class GlxbadProfileArberror : Xcb.GenericError {
		public uint32 bad_value;
		public uint8 major_opcode;
		public uint16 minor_opcode;
	}

	[CCode (cname = "guint8", cprefix =  "XCB_GLX_", has_type_id = false)]
	public enum EventType {
		PBUFFER_CLOBBER,
		BUFFER_SWAP_COMPLETE
	}
}

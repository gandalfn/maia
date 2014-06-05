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

[CCode (cheader_filename="xcb/xcb.h,xcb/render.h")]
namespace Xcb.Render
{
	[CCode (cname = "xcb_render_id")]
	public Xcb.Extension extension;

	[Compact, CCode (cname = "xcb_connection_t", free_function = "xcb_disconnect")]
	public class Connection : Xcb.Connection {
		[CCode (cname = "xcb_connect")]
		public Connection (string? displayname = null, out int screen = null);

		[CCode (cname = "xcb_render_query_version")]
		public QueryVersionCookie query_version (uint32 client_major_version, uint32 client_minor_version);
		[CCode (cname = "xcb_render_query_pict_formats")]
		public QueryPictFormatsCookie query_pict_formats ();
	}

	[Compact, CCode (cname = "xcb_render_query_version_reply_t", free_function = "free")]
	public class QueryVersionReply {
		public uint32 major_version;
		public uint32 minor_version;
	}

	[SimpleType, CCode (cname = "xcb_render_query_version_cookie_t")]
	public struct QueryVersionCookie : VoidCookie {
		[CCode (cname = "xcb_render_query_version_reply", instance_pos = 1.1)]
		public QueryVersionReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[Compact, CCode (cname = "xcb_render_query_pict_formats_reply_t", free_function = "free")]
	public class QueryPictFormatsReply {
		public uint32 num_formats;
		public uint32 num_screens;
		public uint32 num_depths;
		public uint32 num_visuals;
		public uint32 num_subpixel;
		public int formats_length {
			[CCode (cname = "xcb_render_query_pict_formats_formats_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Pictforminfo[] formats {
			[CCode (cname = "xcb_render_query_pict_formats_formats")]
			get;
		}
		public int screens_length {
			[CCode (cname = "xcb_render_query_pict_formats_screens_length")]
			get;
		}
		[CCode (cname = "xcb_render_query_pict_formats_screens_iterator")]
		_PictscreenIterator _iterator ();
		public PictscreenIterator iterator () {
			return (PictscreenIterator) _iterator ();
		}

		public int subpixels_length {
			[CCode (cname = "xcb_render_query_pict_formats_subpixels_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint32[] subpixels {
			[CCode (cname = "xcb_render_query_pict_formats_subpixels")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_render_query_pict_formats_cookie_t")]
	public struct QueryPictFormatsCookie : VoidCookie {
		[CCode (cname = "xcb_render_query_pict_formats_reply", instance_pos = 1.1)]
		public QueryPictFormatsReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_drawable_t", has_type_id = false)]
	public struct Drawable : Xcb.Drawable {
		[CCode (cname = "xcb_render_query_filters", instance_pos = 1.1)]
		public QueryFiltersCookie query_filters (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_render_query_filters_reply_t", free_function = "free")]
	public class QueryFiltersReply {
		public uint32 num_aliases;
		public uint32 num_filters;
		public int aliases_length {
			[CCode (cname = "xcb_render_query_filters_aliases_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned uint16[] aliases {
			[CCode (cname = "xcb_render_query_filters_aliases")]
			get;
		}
		[CCode (cname = "xcb_render_query_filters_filters_iterator")]
		_StrIterator _iterator ();
		public StrIterator iterator () {
			return (StrIterator) _iterator ();
		}
		public int filters_length {
			[CCode (cname = "xcb_render_query_filters_filters_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Str[] filters {
			[CCode (cname = "xcb_render_query_filters_filters")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_render_query_filters_cookie_t")]
	public struct QueryFiltersCookie : VoidCookie {
		[CCode (cname = "xcb_render_query_filters_reply", instance_pos = 1.1)]
		public QueryFiltersReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[CCode (cname = "xcb_cursor_t", has_type_id = false)]
	public struct Cursor : Xcb.Cursor {
		[CCode (cname = "xcb_render_create_anim_cursor", instance_pos = 1.1)]
		public VoidCookie create_anim (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Animcursorelt[]? cursors);
		[CCode (cname = "xcb_render_create_anim_cursor_checked", instance_pos = 1.1)]
		public VoidCookie create_anim_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Animcursorelt[]? cursors);
	}

	[CCode (cname = "xcb_render_pict_type_t", cprefix =  "XCB_RENDER_PICT_TYPE_", has_type_id = false)]
	public enum PictType {
		INDEXED,
		DIRECT
	}

	[CCode (cname = "xcb_render_picture_t", cprefix =  "XCB_RENDER_PICTURE_", has_type_id = false)]
	public enum PictureType {
		NONE
	}

	[CCode (cname = "xcb_render_pict_op_t", cprefix =  "XCB_RENDER_PICT_OP_", has_type_id = false)]
	public enum PictOp {
		CLEAR,
		SRC,
		DST,
		OVER,
		OVER_REVERSE,
		IN,
		IN_REVERSE,
		OUT,
		OUT_REVERSE,
		ATOP,
		ATOP_REVERSE,
		XOR,
		ADD,
		SATURATE,
		DISJOINT_CLEAR,
		DISJOINT_SRC,
		DISJOINT_DST,
		DISJOINT_OVER,
		DISJOINT_OVER_REVERSE,
		DISJOINT_IN,
		DISJOINT_IN_REVERSE,
		DISJOINT_OUT,
		DISJOINT_OUT_REVERSE,
		DISJOINT_ATOP,
		DISJOINT_ATOP_REVERSE,
		DISJOINT_XOR,
		CONJOINT_CLEAR,
		CONJOINT_SRC,
		CONJOINT_DST,
		CONJOINT_OVER,
		CONJOINT_OVER_REVERSE,
		CONJOINT_IN,
		CONJOINT_IN_REVERSE,
		CONJOINT_OUT,
		CONJOINT_OUT_REVERSE,
		CONJOINT_ATOP,
		CONJOINT_ATOP_REVERSE,
		CONJOINT_XOR,
		MULTIPLY,
		SCREEN,
		OVERLAY,
		DARKEN,
		LIGHTEN,
		COLOR_DODGE,
		COLOR_BURN,
		HARD_LIGHT,
		SOFT_LIGHT,
		DIFFERENCE,
		EXCLUSION,
		HSL_HUE,
		HSL_SATURATION,
		HSL_COLOR,
		HSL_LUMINOSITY
	}

	[CCode (cname = "xcb_render_poly_edge_t", cprefix =  "XCB_RENDER_POLY_EDGE_", has_type_id = false)]
	public enum PolyEdge {
		SHARP,
		SMOOTH
	}

	[CCode (cname = "xcb_render_poly_mode_t", cprefix =  "XCB_RENDER_POLY_MODE_", has_type_id = false)]
	public enum PolyMode {
		PRECISE,
		IMPRECISE
	}

	[CCode (cname = "xcb_render_cp_t", cprefix =  "XCB_RENDER_CP_", has_type_id = false)]
	public enum Cp {
		REPEAT,
		ALPHA_MAP,
		ALPHA_X_ORIGIN,
		ALPHA_Y_ORIGIN,
		CLIP_X_ORIGIN,
		CLIP_Y_ORIGIN,
		CLIP_MASK,
		GRAPHICS_EXPOSURE,
		SUBWINDOW_MODE,
		POLY_EDGE,
		POLY_MODE,
		DITHER,
		COMPONENT_ALPHA
	}

	[CCode (cname = "xcb_render_sub_pixel_t", cprefix =  "XCB_RENDER_SUB_PIXEL_", has_type_id = false)]
	public enum SubPixel {
		UNKNOWN,
		HORIZONTAL_RGB,
		HORIZONTAL_BGR,
		VERTICAL_RGB,
		VERTICAL_BGR,
		NONE
	}

	[CCode (cname = "xcb_render_repeat_t", cprefix =  "XCB_RENDER_REPEAT_", has_type_id = false)]
	public enum Repeat {
		NONE,
		NORMAL,
		PAD,
		REFLECT
	}

	[SimpleType, CCode (cname = "xcb_render_glyph_t", has_type_id = false)]
	public struct Glyph : uint32 {
	}

	[SimpleType, CCode (cname = "xcb_render_glyphset_iterator_t")]
	struct _GlyphsetIterator
	{
		internal int rem;
		internal int index;
		internal unowned Glyphset? data;
	}

	[CCode (cname = "xcb_render_glyphset_iterator_t")]
	public struct GlyphsetIterator
	{
		[CCode (cname = "xcb_render_glyphset_next")]
		internal void _next ();

		public inline unowned Glyphset?
		next_value ()
		{
			if (((_GlyphsetIterator)this).rem > 0)
			{
				unowned Glyphset? d = ((_GlyphsetIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_glyphset_t", has_type_id = false)]
	public struct Glyphset : uint32 {
		/**
		 * Allocates an XID for a new Glyphset.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Glyphset (Xcb.Connection connection);

		[CCode (cname = "xcb_render_create_glyph_set", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, Pictformat format);
		[CCode (cname = "xcb_render_create_glyph_set_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, Pictformat format);
		[CCode (cname = "xcb_render_reference_glyph_set", instance_pos = 1.1)]
		public VoidCookie reference (Xcb.Connection connection, Glyphset existing);
		[CCode (cname = "xcb_render_reference_glyph_set_checked", instance_pos = 1.1)]
		public VoidCookie reference_checked (Xcb.Connection connection, Glyphset existing);
		[CCode (cname = "xcb_render_free_glyph_set", instance_pos = 1.1)]
		public VoidCookie free (Xcb.Connection connection);
		[CCode (cname = "xcb_render_free_glyph_set_checked", instance_pos = 1.1)]
		public VoidCookie free_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_render_add_glyphs", instance_pos = 1.1)]
		public VoidCookie add_glyphs (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint32[]? glyphids, [CCode (array_length_pos = 1.2)]Glyphinfo[]? glyphs, [CCode (array_length_pos = 4.4)]uint8[]? data);
		[CCode (cname = "xcb_render_add_glyphs_checked", instance_pos = 1.1)]
		public VoidCookie add_glyphs_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]uint32[]? glyphids, [CCode (array_length_pos = 1.2)]Glyphinfo[]? glyphs, [CCode (array_length_pos = 4.4)]uint8[]? data);
		[CCode (cname = "xcb_render_free_glyphs", instance_pos = 1.1)]
		public VoidCookie free_glyphs (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Glyph[]? glyphs);
		[CCode (cname = "xcb_render_free_glyphs_checked", instance_pos = 1.1)]
		public VoidCookie free_glyphs_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.1)]Glyph[]? glyphs);
	}

	[SimpleType, CCode (cname = "xcb_render_picture_iterator_t")]
	struct _PictureIterator
	{
		internal int rem;
		internal int index;
		internal unowned Picture? data;
	}

	[CCode (cname = "xcb_render_picture_iterator_t")]
	public struct PictureIterator
	{
		[CCode (cname = "xcb_render_picture_next")]
		internal void _next ();

		public inline unowned Picture?
		next_value ()
		{
			if (((_PictureIterator)this).rem > 0)
			{
				unowned Picture? d = ((_PictureIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_picture_t", has_type_id = false)]
	public struct Picture : uint32 {
		/**
		 * Allocates an XID for a new Picture.
		 *
		 * @param connection The connection.
		 */
		[CCode (cname = "xcb_generate_id")]
		public Picture (Xcb.Connection connection);

		[CCode (cname = "xcb_render_create_picture", instance_pos = 1.1)]
		public VoidCookie create (Xcb.Connection connection, Drawable drawable, Pictformat format, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_render_create_picture_checked", instance_pos = 1.1)]
		public VoidCookie create_checked (Xcb.Connection connection, Drawable drawable, Pictformat format, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_render_change_picture", instance_pos = 1.1)]
		public VoidCookie change (Xcb.Connection connection, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_render_change_picture_checked", instance_pos = 1.1)]
		public VoidCookie change_checked (Xcb.Connection connection, uint32 value_mask = 0, [CCode (array_length = false)]uint32[]? value_list = null);
		[CCode (cname = "xcb_render_set_picture_clip_rectangles", instance_pos = 1.1)]
		public VoidCookie set_clip_rectangles (Xcb.Connection connection, int16 clip_x_origin, int16 clip_y_origin, [CCode (array_length_pos = 3.3)]Rectangle[]? rectangles);
		[CCode (cname = "xcb_render_set_picture_clip_rectangles_checked", instance_pos = 1.1)]
		public VoidCookie set_clip_rectangles_checked (Xcb.Connection connection, int16 clip_x_origin, int16 clip_y_origin, [CCode (array_length_pos = 3.3)]Rectangle[]? rectangles);
		[CCode (cname = "xcb_render_free_picture", instance_pos = 1.1)]
		public VoidCookie free (Xcb.Connection connection);
		[CCode (cname = "xcb_render_free_picture_checked", instance_pos = 1.1)]
		public VoidCookie free_checked (Xcb.Connection connection);
		[CCode (cname = "xcb_render_composite", instance_pos = 2.2)]
		public VoidCookie composite (Xcb.Connection connection, PictOp op, Picture mask, Picture dst, int16 src_x, int16 src_y, int16 mask_x, int16 mask_y, int16 dst_x, int16 dst_y, uint16 width, uint16 height);
		[CCode (cname = "xcb_render_composite_checked", instance_pos = 2.2)]
		public VoidCookie composite_checked (Xcb.Connection connection, PictOp op, Picture mask, Picture dst, int16 src_x, int16 src_y, int16 mask_x, int16 mask_y, int16 dst_x, int16 dst_y, uint16 width, uint16 height);
		[CCode (cname = "xcb_render_trapezoids", instance_pos = 1.2)]
		public VoidCookie trapezoids (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Trapezoid[]? traps);
		[CCode (cname = "xcb_render_trapezoids_checked", instance_pos = 1.2)]
		public VoidCookie trapezoids_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Trapezoid[]? traps);
		[CCode (cname = "xcb_render_triangles", instance_pos = 1.2)]
		public VoidCookie triangles (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Triangle[]? triangles);
		[CCode (cname = "xcb_render_triangles_checked", instance_pos = 1.2)]
		public VoidCookie triangles_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Triangle[]? triangles);
		[CCode (cname = "xcb_render_tri_strip", instance_pos = 1.2)]
		public VoidCookie tri_strip (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Pointfix[]? points);
		[CCode (cname = "xcb_render_tri_strip_checked", instance_pos = 1.2)]
		public VoidCookie tri_strip_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Pointfix[]? points);
		[CCode (cname = "xcb_render_tri_fan", instance_pos = 1.2)]
		public VoidCookie tri_fan (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Pointfix[]? points);
		[CCode (cname = "xcb_render_tri_fan_checked", instance_pos = 1.2)]
		public VoidCookie tri_fan_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, int16 src_x, int16 src_y, [CCode (array_length_pos = 6.6)]Pointfix[]? points);
		[CCode (cname = "xcb_render_composite_glyphs_8", instance_pos = 1.2)]
		public VoidCookie composite_glyphs_8 (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, Glyphset glyphset, int16 src_x, int16 src_y, [CCode (array_length_pos = 7.7)]uint8[]? glyphcmds);
		[CCode (cname = "xcb_render_composite_glyphs_8_checked", instance_pos = 1.2)]
		public VoidCookie composite_glyphs_8_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, Glyphset glyphset, int16 src_x, int16 src_y, [CCode (array_length_pos = 7.7)]uint8[]? glyphcmds);
		[CCode (cname = "xcb_render_composite_glyphs_16", instance_pos = 1.2)]
		public VoidCookie composite_glyphs_16 (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, Glyphset glyphset, int16 src_x, int16 src_y, [CCode (array_length_pos = 7.7)]uint8[]? glyphcmds);
		[CCode (cname = "xcb_render_composite_glyphs_16_checked", instance_pos = 1.2)]
		public VoidCookie composite_glyphs_16_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, Glyphset glyphset, int16 src_x, int16 src_y, [CCode (array_length_pos = 7.7)]uint8[]? glyphcmds);
		[CCode (cname = "xcb_render_composite_glyphs_32", instance_pos = 1.2)]
		public VoidCookie composite_glyphs_32 (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, Glyphset glyphset, int16 src_x, int16 src_y, [CCode (array_length_pos = 7.7)]uint8[]? glyphcmds);
		[CCode (cname = "xcb_render_composite_glyphs_32_checked", instance_pos = 1.2)]
		public VoidCookie composite_glyphs_32_checked (Xcb.Connection connection, PictOp op, Picture dst, Pictformat mask_format, Glyphset glyphset, int16 src_x, int16 src_y, [CCode (array_length_pos = 7.7)]uint8[]? glyphcmds);
		[CCode (cname = "xcb_render_fill_rectangles", instance_pos = 2.3)]
		public VoidCookie fill_rectangles (Xcb.Connection connection, PictOp op, Color color, [CCode (array_length_pos = 3.3)]Rectangle[]? rects);
		[CCode (cname = "xcb_render_fill_rectangles_checked", instance_pos = 1.2)]
		public VoidCookie fill_rectangles_checked (Xcb.Connection connection, PictOp op, Color color, [CCode (array_length_pos = 3.3)]Rectangle[]? rects);
		[CCode (cname = "xcb_render_create_cursor", instance_pos = 2.2)]
		public VoidCookie create_cursor (Xcb.Connection connection, Cursor cid, uint16 x, uint16 y);
		[CCode (cname = "xcb_render_create_cursor_checked", instance_pos = 2.2)]
		public VoidCookie create_cursor_checked (Xcb.Connection connection, Cursor cid, uint16 x, uint16 y);
		[CCode (cname = "xcb_render_set_picture_transform", instance_pos = 1.1)]
		public VoidCookie set_transform (Xcb.Connection connection, Transform transform);
		[CCode (cname = "xcb_render_set_picture_transform_checked", instance_pos = 1.1)]
		public VoidCookie set_transform_checked (Xcb.Connection connection, Transform transform);
		[CCode (cname = "xcb_render_set_picture_filter", instance_pos = 1.1)]
		public VoidCookie set_filter (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]char[]? filter, [CCode (array_length_pos = 3.3)]Fixed[]? values);
		[CCode (cname = "xcb_render_set_picture_filter_checked", instance_pos = 1.1)]
		public VoidCookie set_filter_checked (Xcb.Connection connection, [CCode (array_length_pos = 1.2)]char[]? filter, [CCode (array_length_pos = 3.3)]Fixed[]? values);
		[CCode (cname = "xcb_render_add_traps", instance_pos = 1.1)]
		public VoidCookie add_traps (Xcb.Connection connection, int16 x_off, int16 y_off, [CCode (array_length_pos = 3.3)]Trap[]? traps);
		[CCode (cname = "xcb_render_add_traps_checked", instance_pos = 1.1)]
		public VoidCookie add_traps_checked (Xcb.Connection connection, int16 x_off, int16 y_off, [CCode (array_length_pos = 3.3)]Trap[]? traps);
		[CCode (cname = "xcb_render_create_solid_fill", instance_pos = 1.1)]
		public VoidCookie create_solid_fill (Xcb.Connection connection, Color color);
		[CCode (cname = "xcb_render_create_solid_fill_checked", instance_pos = 1.1)]
		public VoidCookie create_solid_fill_checked (Xcb.Connection connection, Color color);
		[CCode (cname = "xcb_render_create_linear_gradient", instance_pos = 1.1)]
		public VoidCookie create_linear_gradient (Xcb.Connection connection, Pointfix p1, Pointfix p2, [CCode (array_length_pos = 3.4)]Fixed[]? stops, [CCode (array_length_pos = 3.4)]Color[]? colors);
		[CCode (cname = "xcb_render_create_linear_gradient_checked", instance_pos = 1.1)]
		public VoidCookie create_linear_gradient_checked (Xcb.Connection connection, Pointfix p1, Pointfix p2, [CCode (array_length_pos = 3.4)]Fixed[]? stops, [CCode (array_length_pos = 3.4)]Color[]? colors);
		[CCode (cname = "xcb_render_create_radial_gradient", instance_pos = 1.1)]
		public VoidCookie create_radial_gradient (Xcb.Connection connection, Pointfix inner, Pointfix outer, Fixed inner_radius, Fixed outer_radius, [CCode (array_length_pos = 5.6)]Fixed[]? stops, [CCode (array_length_pos = 5.6)]Color[]? colors);
		[CCode (cname = "xcb_render_create_radial_gradient_checked", instance_pos = 1.1)]
		public VoidCookie create_radial_gradient_checked (Xcb.Connection connection, Pointfix inner, Pointfix outer, Fixed inner_radius, Fixed outer_radius, [CCode (array_length_pos = 5.6)]Fixed[]? stops, [CCode (array_length_pos = 5.6)]Color[]? colors);
		[CCode (cname = "xcb_render_create_conical_gradient", instance_pos = 1.1)]
		public VoidCookie create_conical_gradient (Xcb.Connection connection, Pointfix center, Fixed angle, [CCode (array_length_pos = 3.4)]Fixed[]? stops, [CCode (array_length_pos = 3.4)]Color[]? colors);
		[CCode (cname = "xcb_render_create_conical_gradient_checked", instance_pos = 1.1)]
		public VoidCookie create_conical_gradient_checked (Xcb.Connection connection, Pointfix center, Fixed angle, [CCode (array_length_pos = 3.4)]Fixed[]? stops, [CCode (array_length_pos = 3.4)]Color[]? colors);
	}

	[SimpleType, CCode (cname = "xcb_render_pictformat_iterator_t")]
	struct _PictformatIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pictformat? data;
	}

	[CCode (cname = "xcb_render_pictformat_iterator_t")]
	public struct PictformatIterator
	{
		[CCode (cname = "xcb_render_pictformat_next")]
		internal void _next ();

		public inline unowned Pictformat?
		next_value ()
		{
			if (((_PictformatIterator)this).rem > 0)
			{
				unowned Pictformat? d = ((_PictformatIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_pictformat_t", has_type_id = false)]
	public struct Pictformat : uint32 {
		[CCode (cname = "xcb_render_query_pict_index_values", instance_pos = 1.1)]
		public QueryPictIndexValuesCookie query_pict_index_values (Xcb.Connection connection);
	}

	[Compact, CCode (cname = "xcb_render_query_pict_index_values_reply_t", free_function = "free")]
	public class QueryPictIndexValuesReply {
		public uint32 num_values;
		[CCode (cname = "xcb_render_query_pict_index_values_values_iterator")]
		_IndexvalueIterator _iterator ();
		public IndexvalueIterator iterator () {
			return (IndexvalueIterator) _iterator ();
		}
		public int values_length {
			[CCode (cname = "xcb_render_query_pict_index_values_values_length")]
			get;
		}
		[CCode (array_length = false)]
		public unowned Indexvalue[] values {
			[CCode (cname = "xcb_render_query_pict_index_values_values")]
			get;
		}
	}

	[SimpleType, CCode (cname = "xcb_render_query_pict_index_values_cookie_t")]
	public struct QueryPictIndexValuesCookie : VoidCookie {
		[CCode (cname = "xcb_render_query_pict_index_values_reply", instance_pos = 1.1)]
		public QueryPictIndexValuesReply reply (Xcb.Connection connection, out Xcb.GenericError? error = null);
	}

	[SimpleType, CCode (cname = "xcb_render_fixed_t", has_type_id = false)]
	public struct Fixed : int32 {
	}

	[Compact, CCode (cname = "xcb_render_pict_format_error_t", has_type_id = false)]
	public class PictFormatError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_render_picture_error_t", has_type_id = false)]
	public class PictureError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_render_pict_op_error_t", has_type_id = false)]
	public class PictOpError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_render_glyph_set_error_t", has_type_id = false)]
	public class GlyphSetError : Xcb.GenericError {
	}

	[Compact, CCode (cname = "xcb_render_glyph_error_t", has_type_id = false)]
	public class GlyphError : Xcb.GenericError {
	}

	[SimpleType, CCode (cname = "xcb_render_directformat_iterator_t")]
	struct _DirectformatIterator
	{
		internal int rem;
		internal int index;
		internal unowned Directformat? data;
	}

	[CCode (cname = "xcb_render_directformat_iterator_t")]
	public struct DirectformatIterator
	{
		[CCode (cname = "xcb_render_directformat_next")]
		internal void _next ();

		public inline unowned Directformat?
		next_value ()
		{
			if (((_DirectformatIterator)this).rem > 0)
			{
				unowned Directformat? d = ((_DirectformatIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_directformat_t", has_type_id = false)]
	public struct Directformat {
		public uint16 red_shift;
		public uint16 red_mask;
		public uint16 green_shift;
		public uint16 green_mask;
		public uint16 blue_shift;
		public uint16 blue_mask;
		public uint16 alpha_shift;
		public uint16 alpha_mask;
	}

	[SimpleType, CCode (cname = "xcb_render_pictforminfo_iterator_t")]
	struct _PictforminfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pictforminfo? data;
	}

	[CCode (cname = "xcb_render_pictforminfo_iterator_t")]
	public struct PictforminfoIterator
	{
		[CCode (cname = "xcb_render_pictforminfo_next")]
		internal void _next ();

		public inline unowned Pictforminfo?
		next_value ()
		{
			if (((_PictforminfoIterator)this).rem > 0)
			{
				unowned Pictforminfo? d = ((_PictforminfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_pictforminfo_t", has_type_id = false)]
	public struct Pictforminfo {
		public Pictformat id;
		public PictType type;
		public uint8 depth;
		public Directformat direct;
		public Colormap colormap;
	}

	[SimpleType, CCode (cname = "xcb_render_pictvisual_iterator_t")]
	struct _PictvisualIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pictvisual? data;
	}

	[CCode (cname = "xcb_render_pictvisual_iterator_t")]
	public struct PictvisualIterator
	{
		[CCode (cname = "xcb_render_pictvisual_next")]
		internal void _next ();

		public inline unowned Pictvisual?
		next_value ()
		{
			if (((_PictvisualIterator)this).rem > 0)
			{
				unowned Pictvisual? d = ((_PictvisualIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_pictvisual_t", has_type_id = false)]
	public struct Pictvisual {
		public Visualid visual;
		public Pictformat format;
	}

	[SimpleType, CCode (cname = "xcb_render_pictdepth_iterator_t")]
	struct _PictdepthIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pictdepth? data;
	}

	[CCode (cname = "xcb_render_pictdepth_iterator_t")]
	public struct PictdepthIterator
	{
		[CCode (cname = "xcb_render_pictdepth_next")]
		internal void _next ();

		public inline unowned Pictdepth?
		next_value ()
		{
			if (((_PictdepthIterator)this).rem > 0)
			{
				unowned Pictdepth? d = ((_PictdepthIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_pictdepth_t", has_type_id = false)]
	public struct Pictdepth {
		public uint8 depth;
		public uint16 num_visuals;
		[CCode (cname = "xcb_render_pictdepth_visuals_iterator")]
		_PictvisualIterator _iterator ();
		public PictvisualIterator iterator () {
			return (PictvisualIterator) _iterator ();
		}
	}

	[SimpleType, CCode (cname = "xcb_render_pictscreen_iterator_t")]
	struct _PictscreenIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pictscreen? data;
	}

	[CCode (cname = "xcb_render_pictscreen_iterator_t")]
	public struct PictscreenIterator
	{
		[CCode (cname = "xcb_render_pictscreen_next")]
		internal void _next ();

		public inline unowned Pictscreen?
		next_value ()
		{
			if (((_PictscreenIterator)this).rem > 0)
			{
				unowned Pictscreen? d = ((_PictscreenIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_pictscreen_t", has_type_id = false)]
	public struct Pictscreen {
		public uint32 num_depths;
		public Pictformat fallback;
		[CCode (cname = "xcb_render_pictscreen_depths_iterator")]
		_PictdepthIterator _iterator ();
		public PictdepthIterator iterator () {
			return (PictdepthIterator) _iterator ();
		}
	}

	[SimpleType, CCode (cname = "xcb_render_indexvalue_iterator_t")]
	struct _IndexvalueIterator
	{
		internal int rem;
		internal int index;
		internal unowned Indexvalue? data;
	}

	[CCode (cname = "xcb_render_indexvalue_iterator_t")]
	public struct IndexvalueIterator
	{
		[CCode (cname = "xcb_render_indexvalue_next")]
		internal void _next ();

		public inline unowned Indexvalue?
		next_value ()
		{
			if (((_IndexvalueIterator)this).rem > 0)
			{
				unowned Indexvalue? d = ((_IndexvalueIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_indexvalue_t", has_type_id = false)]
	public struct Indexvalue {
		public uint32 pixel;
		public uint16 red;
		public uint16 green;
		public uint16 blue;
		public uint16 alpha;
	}

	[SimpleType, CCode (cname = "xcb_render_color_iterator_t")]
	struct _ColorIterator
	{
		internal int rem;
		internal int index;
		internal unowned Color? data;
	}

	[CCode (cname = "xcb_render_color_iterator_t")]
	public struct ColorIterator
	{
		[CCode (cname = "xcb_render_color_next")]
		internal void _next ();

		public inline unowned Color?
		next_value ()
		{
			if (((_ColorIterator)this).rem > 0)
			{
				unowned Color? d = ((_ColorIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[SimpleType, CCode (cname = "xcb_render_color_t", has_type_id = false)]
	public struct Color {
		public uint16 red;
		public uint16 green;
		public uint16 blue;
		public uint16 alpha;
	}

	[SimpleType, CCode (cname = "xcb_render_pointfix_iterator_t")]
	struct _PointfixIterator
	{
		internal int rem;
		internal int index;
		internal unowned Pointfix? data;
	}

	[CCode (cname = "xcb_render_pointfix_iterator_t")]
	public struct PointfixIterator
	{
		[CCode (cname = "xcb_render_pointfix_next")]
		internal void _next ();

		public inline unowned Pointfix?
		next_value ()
		{
			if (((_PointfixIterator)this).rem > 0)
			{
				unowned Pointfix? d = ((_PointfixIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_pointfix_t", has_type_id = false)]
	public struct Pointfix {
		public Fixed x;
		public Fixed y;
	}

	[SimpleType, CCode (cname = "xcb_render_linefix_iterator_t")]
	struct _LinefixIterator
	{
		internal int rem;
		internal int index;
		internal unowned Linefix? data;
	}

	[CCode (cname = "xcb_render_linefix_iterator_t")]
	public struct LinefixIterator
	{
		[CCode (cname = "xcb_render_linefix_next")]
		internal void _next ();

		public inline unowned Linefix?
		next_value ()
		{
			if (((_LinefixIterator)this).rem > 0)
			{
				unowned Linefix? d = ((_LinefixIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_linefix_t", has_type_id = false)]
	public struct Linefix {
		public Pointfix p1;
		public Pointfix p2;
	}

	[SimpleType, CCode (cname = "xcb_render_triangle_iterator_t")]
	struct _TriangleIterator
	{
		internal int rem;
		internal int index;
		internal unowned Triangle? data;
	}

	[CCode (cname = "xcb_render_triangle_iterator_t")]
	public struct TriangleIterator
	{
		[CCode (cname = "xcb_render_triangle_next")]
		internal void _next ();

		public inline unowned Triangle?
		next_value ()
		{
			if (((_TriangleIterator)this).rem > 0)
			{
				unowned Triangle? d = ((_TriangleIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_triangle_t", has_type_id = false)]
	public struct Triangle {
		public Pointfix p1;
		public Pointfix p2;
		public Pointfix p3;
	}

	[SimpleType, CCode (cname = "xcb_render_trapezoid_iterator_t")]
	struct _TrapezoidIterator
	{
		internal int rem;
		internal int index;
		internal unowned Trapezoid? data;
	}

	[CCode (cname = "xcb_render_trapezoid_iterator_t")]
	public struct TrapezoidIterator
	{
		[CCode (cname = "xcb_render_trapezoid_next")]
		internal void _next ();

		public inline unowned Trapezoid?
		next_value ()
		{
			if (((_TrapezoidIterator)this).rem > 0)
			{
				unowned Trapezoid? d = ((_TrapezoidIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_trapezoid_t", has_type_id = false)]
	public struct Trapezoid {
		public Fixed top;
		public Fixed bottom;
		public Linefix left;
		public Linefix right;
	}

	[SimpleType, CCode (cname = "xcb_render_glyphinfo_iterator_t")]
	struct _GlyphinfoIterator
	{
		internal int rem;
		internal int index;
		internal unowned Glyphinfo? data;
	}

	[CCode (cname = "xcb_render_glyphinfo_iterator_t")]
	public struct GlyphinfoIterator
	{
		[CCode (cname = "xcb_render_glyphinfo_next")]
		internal void _next ();

		public inline unowned Glyphinfo?
		next_value ()
		{
			if (((_GlyphinfoIterator)this).rem > 0)
			{
				unowned Glyphinfo? d = ((_GlyphinfoIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_glyphinfo_t", has_type_id = false)]
	public struct Glyphinfo {
		public uint16 width;
		public uint16 height;
		public int16 x;
		public int16 y;
		public int16 x_off;
		public int16 y_off;
	}

	[SimpleType, CCode (cname = "xcb_render_transform_iterator_t")]
	struct _TransformIterator
	{
		internal int rem;
		internal int index;
		internal unowned Transform? data;
	}

	[CCode (cname = "xcb_render_transform_iterator_t")]
	public struct TransformIterator
	{
		[CCode (cname = "xcb_render_transform_next")]
		internal void _next ();

		public inline unowned Transform?
		next_value ()
		{
			if (((_TransformIterator)this).rem > 0)
			{
				unowned Transform? d = ((_TransformIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_transform_t", has_type_id = false)]
	public struct Transform {
		public Fixed matrix11;
		public Fixed matrix12;
		public Fixed matrix13;
		public Fixed matrix21;
		public Fixed matrix22;
		public Fixed matrix23;
		public Fixed matrix31;
		public Fixed matrix32;
		public Fixed matrix33;
	}

	[SimpleType, CCode (cname = "xcb_render_animcursorelt_iterator_t")]
	struct _AnimcursoreltIterator
	{
		internal int rem;
		internal int index;
		internal unowned Animcursorelt? data;
	}

	[CCode (cname = "xcb_render_animcursorelt_iterator_t")]
	public struct AnimcursoreltIterator
	{
		[CCode (cname = "xcb_render_animcursorelt_next")]
		internal void _next ();

		public inline unowned Animcursorelt?
		next_value ()
		{
			if (((_AnimcursoreltIterator)this).rem > 0)
			{
				unowned Animcursorelt? d = ((_AnimcursoreltIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_animcursorelt_t", has_type_id = false)]
	public struct Animcursorelt {
		public Cursor cursor;
		public uint32 delay;
	}

	[SimpleType, CCode (cname = "xcb_render_spanfix_iterator_t")]
	struct _SpanfixIterator
	{
		internal int rem;
		internal int index;
		internal unowned Spanfix? data;
	}

	[CCode (cname = "xcb_render_spanfix_iterator_t")]
	public struct SpanfixIterator
	{
		[CCode (cname = "xcb_render_spanfix_next")]
		internal void _next ();

		public inline unowned Spanfix?
		next_value ()
		{
			if (((_SpanfixIterator)this).rem > 0)
			{
				unowned Spanfix? d = ((_SpanfixIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_spanfix_t", has_type_id = false)]
	public struct Spanfix {
		public Fixed l;
		public Fixed r;
		public Fixed y;
	}

	[SimpleType, CCode (cname = "xcb_render_trap_iterator_t")]
	struct _TrapIterator
	{
		internal int rem;
		internal int index;
		internal unowned Trap? data;
	}

	[CCode (cname = "xcb_render_trap_iterator_t")]
	public struct TrapIterator
	{
		[CCode (cname = "xcb_render_trap_next")]
		internal void _next ();

		public inline unowned Trap?
		next_value ()
		{
			if (((_TrapIterator)this).rem > 0)
			{
				unowned Trap? d = ((_TrapIterator)this).data;
				_next ();
				return d;
			}
			return null;
		}
	}

	[CCode (cname = "xcb_render_trap_t", has_type_id = false)]
	public struct Trap {
		public Spanfix top;
		public Spanfix bot;
	}
}

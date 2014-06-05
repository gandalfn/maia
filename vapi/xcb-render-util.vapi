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

[CCode (cheader_filename="xcb/xcb_renderutil.h")]
namespace Xcb.Render.Util
{
	[Flags, CCode (cname = "xcb_pict_format_t", cprefix =  "XCB_PICT_FORMAT_", has_type_id = false)]
	public enum PictFormat
	{
		ID,
		TYPE,
		DEPTH,
		RED,
		RED_MASK,
		GREEN,
		GREEN_MASK,
		BLUE,
		BLUE_MASK,
		ALPHA,
		ALPHA_MASK,
		COLORMAP
	}

	[CCode (cname = "xcb_pict_standard_t", cprefix =  "XCB_PICT_STANDARD_", has_type_id = false)]
	public enum PictStandard
	{
		ARGB_32,
		RGB_24,
		A_8,
		A_4,
		A_1
	}

	[CCode (cname = "xcb_render_util_find_visual_format")]
	public static unowned Xcb.Render.Pictvisual? find_visual_format (Xcb.Render.QueryPictFormatsReply formats, Xcb.Visualid visual);

	[CCode (cname = "xcb_render_util_find_format")]
	public static unowned Xcb.Render.Pictforminfo? find_format (Xcb.Render.QueryPictFormatsReply formats, ulong mask, Xcb.Render.Pictforminfo[] templates);

	[CCode (cname = "xcb_render_util_find_standard_format")]
	public static unowned Xcb.Render.Pictforminfo? find_standard_format (Xcb.Render.QueryPictFormatsReply formats, PictStandard format);
}

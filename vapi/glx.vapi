/* glx.vapi
 *
 * Copyright (C) 2008  Matias De la Puente
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Matias De la Puente <mfpuente.ar@gmail.com>
 */

[CCode (lower_case_cprefix ="", cheader_filename="GL/glx.h")]
namespace GLX
{
	[CCode (cname = "GLX_BUFFER_SIZE")]
	public const int BUFFER_SIZE;
	[CCode (cname = "GLX_RGBA")]
	public const int RGBA;
	[CCode (cname = "GLX_DOUBLEBUFFER")]
	public const int DOUBLEBUFFER;
	[CCode (cname = "GLX_STEREO")]
	public const int STEREO;
	[CCode (cname = "GLX_AUX_BUFFERS")]
	public const int AUX_BUFFERS;
	[CCode (cname = "GLX_RED_SIZE")]
	public const int RED_SIZE;
	[CCode (cname = "GLX_GREEN_SIZE")]
	public const int GREEN_SIZE;
	[CCode (cname = "GLX_BLUE_SIZE")]
	public const int BLUE_SIZE;
	[CCode (cname = "GLX_ALPHA_SIZE")]
	public const int ALPHA_SIZE;
	[CCode (cname = "GLX_DEPTH_SIZE")]
	public const int DEPTH_SIZE;
	[CCode (cname = "GLX_STENCIL_SIZE")]
	public const int STENCIL_SIZE;
	[CCode (cname = "GLX_ACCUM_RED_SIZE")]
	public const int ACCUM_RED_SIZE;
	[CCode (cname = "GLX_ACCUM_GREEN_SIZE")]
	public const int ACCUM_GREEN_SIZE;
	[CCode (cname = "GLX_ACCUM_BLUE_SIZE")]
	public const int ACCUM_BLUE_SIZE;
	[CCode (cname = "GLX_ACCUM_ALPHA_SIZE")]
	public const int ACCUM_ALPHA_SIZE;
	[CCode (cname = "GLX_DRAWABLE_TYPE")]
	public const int DRAWABLE_TYPE;
	[CCode (cname = "GLX_RENDER_TYPE")]
	public const int RENDER_TYPE;
	[CCode (cname = "GLX_X_RENDERABLE")]
	public const int X_RENDERABLE;
	[CCode (cname = "GLX_FBCONFIG_ID")]
	public const int FBCONFIG_ID;
	[CCode (cname = "GLX_VISUAL_ID")]
	public const int VISUAL_ID;
	[CCode (cname = "GLX_RGBA_TYPE")]
	public const int RGBA_TYPE;
	[CCode (cname = "GLX_RGBA_BIT")]
	public const int RGBA_BIT;
	[CCode (cname = "GLX_WINDOW_BIT")]
	public const int WINDOW_BIT;
	[CCode (cname = "GLX_PIXMAP_BIT")]
	public const int PIXMAP_BIT;
	[CCode (cname = "GLX_PBUFFER_BIT")]
	public const int PBUFFER_BIT;
	[CCode (cname = "GLX_X_VISUAL_TYPE")]
	public const int X_VISUAL_TYPE;
	[CCode (cname = "GLX_TRUE_COLOR")]
	public const int TRUE_COLOR;

	[SimpleType]
	public struct Context { }
	[SimpleType]
	[IntegerType (rank=9)]
	public struct Pixmap { }
	[SimpleType]
	[IntegerType (rank=9)]
	public struct Drawable { }
	[SimpleType]
	[IntegerType (rank=9)]
	public struct Window { }

	[Compact]
	[CCode (cname="XVisualInfo", free_function="XFree")]
	public class VisualInfo
	{
		public uint32 visualid;
		public int screen;
		public int depth;
		public int @class;
		public ulong red_mask;
		public ulong green_mask;
		public ulong blue_mask;
		public int colormap_size;
		public int bits_per_rgb;
	}

	[CCode (cname = "glXChooseVisual")]
	public static VisualInfo choose_visual (X.Display dpy, int screen, [CCode (array_length = false)] int[] attribList);
	[CCode (cname = "glXCreateContext")]
	public static Context create_context (X.Display dpy, VisualInfo vis, Context? shareList, bool direct);
	[CCode (cname = "glXCreateNewContext")]
	public static Context create_new_context (void* dpy, Xcb.Glx.Fbconfig config, int renderType, Context? shareList, bool direct);
	[CCode (cname = "glXDestroyContext")]
	public static void destroy_context (X.Display dpy, Context ctx);
	[CCode (cname = "glXMakeCurrent")]
	public static bool make_current (X.Display dpy, Drawable drawable, Context ctx);
	[CCode (cname = "glXSwapBuffers")]
	public static void swap_buffers (X.Display dpy, Drawable drawable);
	[CCode (cname = "glXGetVisualFromFBConfig")]
	public static VisualInfo get_visual_from_fbconfig (X.Display dpy, Xcb.Glx.Fbconfig config);
	[CCode (cname = "glXCreateWindow")]
	public static Window create_window (X.Display dpy, Xcb.Glx.Fbconfig config, Window win, [CCode (array_length = false)] int[]? attribList);
	[CCode (cname = "glXDestroyWindow")]
	public static void destroy_window (X.Display dpy, Window window);
	[CCode (cname = "glXCreatePixmap")]
	public static Pixmap create_pixmap (X.Display dpy, Xcb.Glx.Fbconfig config, Pixmap pixmap, [CCode (array_length = false)] int[]? attribList);
	[CCode (cname = "glXDestroyPixmap")]
	public static void destroy_pixmap (X.Display dpy, Pixmap pixmap);

	[CCode (cname = "glXWaitGL")]
	public static void wait_gl ();
	[CCode (cname = "glXWaitX")]
	public static void wait_x ();
}

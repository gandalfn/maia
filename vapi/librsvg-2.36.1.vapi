namespace Rsvg {
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public class Handle : GLib.Object {
		[CCode (has_construct_function = false)]
		public Handle ();
		public bool close () throws GLib.Error;
		public void free ();
		[CCode (has_construct_function = false)]
		public Handle.from_data ([CCode (array_length = false)] uchar[] data, size_t data_len) throws GLib.Error;
		[CCode (has_construct_function = false)]
		public Handle.from_file (string file_name) throws GLib.Error;
		public unowned string get_base_uri ();
		public unowned string get_desc ();
		public void get_dimensions (Rsvg.DimensionData dimension_data);
		public bool get_dimensions_sub (ref Rsvg.DimensionData dimension_data, string id);
		public unowned string get_metadata ();
		public unowned Gdk.Pixbuf get_pixbuf ();
		public unowned Gdk.Pixbuf get_pixbuf_sub (string id);
		public bool get_position_sub (ref Rsvg.PositionData position_data, string id);
		public unowned string get_title ();
		public bool has_sub (string id);
		[CCode (cheader_filename = "librsvg/rsvg-cairo.h")]
		public bool render_cairo (Cairo.Context cr);
		[CCode (cheader_filename = "librsvg/rsvg-cairo.h")]
		public bool render_cairo_sub (Cairo.Context cr, string id);
		public void set_base_uri (string base_uri);
		public void set_dpi (double dpi);
		public void set_dpi_x_y (double dpi_x, double dpi_y);
		public void set_size_callback (owned Rsvg.SizeFunc size_func);
		public bool write (uchar[] buf, size_t count) throws GLib.Error;
		public string base_uri { get; set construct; }
		public string desc { get; }
		[NoAccessorMethod]
		public double dpi_x { get; set construct; }
		[NoAccessorMethod]
		public double dpi_y { get; set construct; }
		[NoAccessorMethod]
		public double em { get; }
		[NoAccessorMethod]
		public double ex { get; }
		[NoAccessorMethod]
		public int height { get; }
		public string metadata { get; }
		public string title { get; }
		[NoAccessorMethod]
		public int width { get; }
	}
	[CCode (cheader_filename = "librsvg/rsvg.h", has_type_id = false)]
	public struct DimensionData {
		public int width;
		public int height;
		public double em;
		public double ex;
	}
	[CCode (cheader_filename = "librsvg/rsvg.h", has_type_id = false)]
	public struct PositionData {
		public int x;
		public int y;
	}
	[CCode (cheader_filename = "librsvg/rsvg.h", cprefix = "RSVG_ERROR_")]
	public enum Error {
		FAILED
	}
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public delegate void SizeFunc (ref int width, ref int height);
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const int LIBRSVG_FEATURES_H;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const int LIBRSVG_HAVE_CSS;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const int LIBRSVG_HAVE_SVGZ;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const int LIBRSVG_MAJOR_VERSION;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const int LIBRSVG_MICRO_VERSION;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const int LIBRSVG_MINOR_VERSION;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public const string LIBRSVG_VERSION;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static GLib.Quark error_quark ();
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static void init ();
	[CCode (cheader_filename = "librsvg/rsvg.h", cname = "librsvg_postinit")]
	public static void librsvg_postinit (void* app, void* modinfo);
	[CCode (cheader_filename = "librsvg/rsvg.h", cname = "librsvg_preinit")]
	public static void librsvg_preinit (void* app, void* modinfo);
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static unowned Gdk.Pixbuf pixbuf_from_file (string file_name) throws GLib.Error;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static unowned Gdk.Pixbuf pixbuf_from_file_at_max_size (string file_name, int max_width, int max_height) throws GLib.Error;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static unowned Gdk.Pixbuf pixbuf_from_file_at_size (string file_name, int width, int height) throws GLib.Error;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static unowned Gdk.Pixbuf pixbuf_from_file_at_zoom (string file_name, double x_zoom, double y_zoom) throws GLib.Error;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static unowned Gdk.Pixbuf pixbuf_from_file_at_zoom_with_max (string file_name, double x_zoom, double y_zoom, int max_width, int max_height) throws GLib.Error;
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static void set_default_dpi (double dpi);
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static void set_default_dpi_x_y (double dpi_x, double dpi_y);
	[CCode (cheader_filename = "librsvg/rsvg.h")]
	public static void term ();
}

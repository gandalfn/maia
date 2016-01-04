[CCode (cprefix = "X", cheader_filename = "X11/Xlib-xcb.h")]
namespace X
{
    [CCode (cname = "XInitThreads")]
    public void init_threads ();

    [CCode (cname = "XEventQueueOwner")]
    public enum EventQueueOwner
    {
        [CCode (cname = "XlibOwnsEventQueue")]
        XLIB,
        [CCode (cname = "XCBOwnsEventQueue")]
        XCB
    }
    [Compact]
    [CCode (cname = "Display", free_function = "XCloseDisplay")]
    public class Display {
        public Xcb.Connection connection {
            [CCode (cname = "XGetXCBConnection")]
            get;
        }
        [CCode (cname = "XOpenDisplay")]
        public Display(string? name = null);
        [CCode (cname = "XSetEventQueueOwner")]
        public void set_event_queue_owner(EventQueueOwner owner);

        [CCode (cname = "XDefaultScreenOfDisplay")]
        public unowned Screen default_screen ();
    }

    [Compact]
    [CCode (cname = "Screen")]
    public class Screen {
        public int num {
            [CCode (cname = "XScreenNumberOfScreen")]
            get;
        }
    }
}

[CCode (cprefix = "Maia", lower_case_cprefix = "maia_")]
namespace Maia 
{
    [CCode (cheader_filename = "maia-object.h")]
    public abstract class Object : GLib.Object
    {
        public Object ();

        public static bool register (GLib.Type inObjectType, GLib.Type inType);
        public static bool unregister (GLib.Type inObjectType);
    }
}

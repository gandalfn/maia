[CCode (cprefix = "", lower_case_cprefix = "")]
namespace LibIntl
{
    [CCode (cname = "dgettext", cheader_filename = "libintl.h")]
    public static unowned string? dgettext(string package, string str);
    [CCode (cname = "gettext_noop", cheader_filename = "libintl.h")]
    public static unowned string? gettext_noop(string package, string str);
    [CCode (cname = "dngettext", cheader_filename = "libintl.h")]
    public static unowned string? dngettext(string package, string str, string plural, ulong n);
    [CCode (cname = "setlocale", cheader_filename = "libintl.h")]
    public unowned string? setlocale (int category, string? locale);
    [CCode (cname = "bindtextdomain", cheader_filename = "libintl.h")]
    public static unowned string? bindtextdomain (string domainname, string? dirname);
    [CCode (cname = "textdomain", cheader_filename = "libintl.h")]
    public static unowned string? textdomain (string? domainname);
    [CCode (cname = "bind_textdomain_codeset", cheader_filename = "libintl.h")]
    public unowned string? bind_textdomain_codeset (string domainname, string? codeset);

    [CCode (cname = "LC_ALL", cheader_filename = "libintl.h")]
    public const int LC_ALL;
}

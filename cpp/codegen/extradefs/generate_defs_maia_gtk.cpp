#include <iostream>
#include <glibmm_generate_extra_defs/generate_extra_defs.h>
#include "maia-gtk.h"

int main (int argc, char** argv)
{
    g_type_init ();

    std::cout << get_defs (MAIA_GTK_TYPE_CANVAS);
    std::cout << get_defs (MAIA_GTK_TYPE_IMAGE);
    std::cout << get_defs (MAIA_GTK_TYPE_BUTTON);
    std::cout << get_defs (MAIA_GTK_TYPE_TOOL);
    std::cout << get_defs (MAIA_GTK_TYPE_MODEL);
    std::cout << get_defs (MAIA_GTK_MODEL_TYPE_COLUMN);
    std::cout << get_defs (MAIA_GTK_TYPE_SHORTCUT);

    return 0;
}

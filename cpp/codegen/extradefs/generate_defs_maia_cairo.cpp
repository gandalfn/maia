#include <iostream>
#include <glibmm_generate_extra_defs/generate_extra_defs.h>
#include "maia-cairo-graphic.h"

int main (int argc, char** argv)
{
    g_type_init ();

    std::cout << get_defs (MAIA_CAIRO_TYPE_CONTEXT);
    std::cout << get_defs (MAIA_CAIRO_TYPE_SURFACE);

    return 0;
}

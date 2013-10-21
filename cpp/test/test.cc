/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test.cc
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
 *
 * maia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * maia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <maia-gtkmm.h>

#include "test-case.h"
#include "test-manifest.h"
#include "test-canvas.h"
#include "test-derived.h"

int
main (int argc, char** argv)
{
    Maia::Gtk::init ();

    // Init test units
    g_test_init (&argc, &argv, 0);

    if (g_test_thorough ())
    {
        Glib::ustring domain ("test");
        Maia::Log::set_default_logger (Maia::Log::Stderr::create (Maia::Log::LOG_LEVEL_DEBUG, Maia::Log::LOG_CATEGORY_ALL, domain));
    }
    // Get root suite
    Maia::TestSuite root;

    // Create test suite
    Maia::TestManifest manifest;
    Maia::TestCanvas canvas;
    Maia::TestDerived derived;

    root.add_suite (manifest.get_suite ());
    root.add_suite (canvas.get_suite ());
    root.add_suite (derived.get_suite ());

    g_test_run ();

    return 0;
}
/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-manifest.cc
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

#include <maiamm.h>

#include "test-manifest.h"

using namespace Maia;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestManifest::TestManifest () :
    TestCase ("manifest")
{
    add_test ("create", sigc::mem_fun (this, &TestManifest::test_create));
    add_test ("parse",  sigc::mem_fun (this, &TestManifest::test_parse));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestManifest::~TestManifest ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestManifest::set_up ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestManifest::tear_down ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestManifest::test_create ()
{
    Glib::ustring manifest ("Document.document {"
                            "   Label.label {"
                            "       text: 'test';"
                            "   }"
                            "   CheckButton.checkbutton {"
                            "       label: 'checkbutton';"
                            "   }"
                            "   Entry {"
                            "       text: '';"
                            "   }"
                            "}");
    try
    {
        Glib::RefPtr<Manifest::Document> pDocument = Manifest::Document::create_from_buffer (manifest);
    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestManifest::test_parse ()
{
    Glib::ustring manifest ("Document.document {"
                            "   Label.label {"
                            "       text: 'test';"
                            "   }"
                            "   CheckButton.checkbutton {"
                            "       label: 'checkbutton';"
                            "   }"
                            "   Entry {"
                            "       text: '';"
                            "   }"
                            "}");
    try
    {
        Glib::RefPtr<Manifest::Document> pDocument = Manifest::Document::create_from_buffer (manifest);

        for (Core::Parser::iterator iter = pDocument->begin (); iter != pDocument->end (); ++iter)
        {
            Core::ParserToken token = *iter;

            switch (token)
            {
                case Core::CORE_PARSER_TOKEN_START_ELEMENT:
                    {
                        Glib::ustring element = pDocument->get_element ();
                        g_test_message ("Start token = %s", element.c_str ());
                    }
                    break;

                default:
                    break;
            }
        }
    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }
}

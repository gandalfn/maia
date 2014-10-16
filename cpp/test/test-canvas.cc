/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-canvas.cc
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

#include "test-canvas.h"

using namespace Maia;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestCanvas::TestCanvas () :
    TestCase ("canvas")
{
    add_test ("create", sigc::mem_fun (this, &TestCanvas::test_create));
    add_test ("parse-child", sigc::mem_fun (this, &TestCanvas::test_parse_child));
    add_test ("find", sigc::mem_fun (this, &TestCanvas::test_find));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestCanvas::~TestCanvas ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCanvas::set_up ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCanvas::tear_down ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCanvas::test_create ()
{
    Glib::ustring manifest ("Document.document {"
                            "   Label.label {"
                            "       text: 'test';"
                            "   }"
                            "   CheckButton.checkbutton {"
                            "       label: 'checkbutton';"
                            "   }"
                            "   Entry.entry {"
                            "       text: '';"
                            "   }"
                            "}");
    try
    {
        Maia::Canvas* pCanvas = Maia::Canvas::create ();
        pCanvas->load (manifest, Glib::ustring ("document"));

        g_assert (pCanvas->get_root ());

        delete pCanvas;
    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCanvas::test_parse_child ()
{
    Glib::ustring manifest ("Document.document {"
                            "   Label.label {"
                            "       text: 'test';"
                            "   }"
                            "   CheckButton.checkbutton {"
                            "       label: 'checkbutton';"
                            "   }"
                            "   Entry.entry {"
                            "       text: '';"
                            "   }"
                            "}");
    try
    {
        Maia::Canvas* pCanvas = Maia::Canvas::create ();
        pCanvas->load (manifest, Glib::ustring ("document"));

        Glib::RefPtr<Item> pRoot = pCanvas->get_root ();
        g_assert (pRoot);

        for (Core::Object::iterator iter = pRoot->begin (); iter != pRoot->end (); ++iter)
        {
            Glib::RefPtr<Core::Object> pObject = *iter;
            g_assert (pObject);

            g_test_message ("obj ref_count %u", G_OBJECT (pObject->gobj ())->ref_count);
        }

        delete pCanvas;
    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCanvas::test_find ()
{
    Glib::ustring manifest ("Document.document {"
                            "   Label.label {"
                            "       text: 'test';"
                            "   }"
                            "   CheckButton.checkbutton {"
                            "       label: 'checkbutton';"
                            "   }"
                            "   Entry.entry {"
                            "       text: '';"
                            "   }"
                            "}");
    Maia::Canvas* pCanvas = Maia::Canvas::create ();
    try
    {
        pCanvas->load (manifest, Glib::ustring ("document"));

        Glib::RefPtr<Item> pRoot = pCanvas->get_root ();
        g_assert (pRoot);

        Glib::RefPtr<Label> pLabel = pRoot->find ("label");
        g_assert (pLabel);
        g_test_message ("obj ref_count %u", G_OBJECT (pLabel->gobj ())->ref_count);

        Glib::RefPtr<CheckButton> pCheckButton = pRoot->find ("checkbutton");
        g_assert (pCheckButton);
        g_test_message ("obj ref_count %u", G_OBJECT (pCheckButton->gobj ())->ref_count);

        Glib::RefPtr<Entry> pEntry = pRoot->find ("entry");
        g_assert (pEntry);
        g_test_message ("obj ref_count %u", G_OBJECT (pEntry->gobj ())->ref_count);

    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }
    delete pCanvas;
}

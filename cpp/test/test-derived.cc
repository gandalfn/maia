/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-derived.cc
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

#include "test-derived.h"

using namespace Maia;

static bool destroyed = false;

class ItemDerived : public Item
{
    public:
        virtual ~ItemDerived ()
        {
            destroyed = true;
        }

        // accessors
        Glib::PropertyProxy<Glib::ustring> property_test ()
        {
            return m_Test.get_proxy ();
        }

        // static methods
        static Glib::RefPtr<Element> create (const Glib::ustring& inId)
        {
            return Glib::RefPtr<Element> (new ItemDerived (inId));
        }

    protected:
        ItemDerived (const Glib::ustring& inId) :
            Glib::ObjectBase ("ItemDerived"),
            m_Test (*this, "test", "")
        {
            set_id (Glib::Quark (inId));
        }

        // overrides
        virtual Glib::ustring
        get_tag_vfunc ()
        {
            return "Derived";
        }

        virtual void
        size_request_vfunc (const Graphic::Size& inSize, Graphic::Size& outSize)
        {
            outSize = Graphic::Size (200, 200);
        }

        virtual void
        paint_vfunc (const Glib::RefPtr< Graphic::Context >& inContext, const Glib::RefPtr< Graphic::Region >& inArea)
        {
            inContext->save ();
            {
                inContext->translate (Graphic::Point (50, 50));
                Glib::RefPtr<Graphic::Path> path = Graphic::Path::create ();
                path->rectangle (0, 0, 100, 100, 5, 5);
                inContext->set_pattern (get_fill_pattern ());
                inContext->fill (path);

                Glib::RefPtr<Graphic::Glyph> pGlyph = Graphic::Glyph::create ("Sans 12");
                pGlyph->set_text ((Glib::ustring)m_Test);
                pGlyph->set_origin (Graphic::Point (30, 30));
                inContext->set_pattern (get_stroke_pattern ());
                inContext->render (pGlyph);
            }
            inContext->restore ();
        }

    private:
        // properties
        Glib::Property<Glib::ustring> m_Test;
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestDerived::TestDerived () :
    TestCase ("derived"),
    m_pKit (0),
    m_pWindow (0)
{
    m_pKit = new ::Gtk::Main (0, 0);
    add_test ("item", sigc::mem_fun (this, &TestDerived::test_item_derived));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestDerived::~TestDerived ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestDerived::set_up ()
{
    m_pWindow = new ::Gtk::Window ();
    m_pWindow->show ();
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestDerived::tear_down ()
{
    delete m_pWindow; m_pWindow = 0;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestDerived::test_item_derived ()
{
    Glib::ustring manifest ("Group.document {"
                            "   Derived.derived {"
                            "       test: 'test';"
                            "       fill-pattern: #0000ff;"
                            "       stroke-pattern: #000000;"
                            "   }"
                            "}");

    Gtk::Canvas* pCanvas = new Gtk::Canvas ();
    pCanvas->show ();
    m_pWindow->add (*pCanvas);

    Manifest::Element::register_create_func ("Derived", sigc::ptr_fun (&ItemDerived::create));
    try
    {
        pCanvas->load (manifest, "document");

        Glib::RefPtr<Item> pRoot = pCanvas->get_root ();
        g_assert (pRoot);

        Glib::RefPtr<ItemDerived> pDerived = pRoot->find ("derived");
        g_assert (pDerived);
        g_test_message ("obj ref_count %u", G_OBJECT (pDerived->gobj ())->ref_count);

    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }

    destroyed = false;

    m_pKit->run (*m_pWindow);

    g_test_message ("to string: %s", pCanvas->get_root ()->to_string ().c_str ());

    delete pCanvas;

    g_assert (destroyed);
}

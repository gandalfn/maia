/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-event.cc
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

#include "test-event.h"

using namespace Maia;

class TestEventArgs : public Core::EventArgs
{
    public:
        // methods
        unsigned long get_data  () const { return m_Data;  }
        Glib::ustring get_foo   () const { return m_Foo;   }
        int           get_count () const { return m_Count; }

        // static methods
        static Glib::RefPtr<TestEventArgs> create (unsigned long inData, const Glib::ustring& inFoo, int inCount)
        {
            return Glib::RefPtr<TestEventArgs> (new TestEventArgs (inData, inFoo, inCount));
        }

    protected:
        MAIA_CORE_EVENT_ARGS_DEFINE("(tsi)", TestEventArgs)

        TestEventArgs (unsigned long inData, const Glib::ustring& inFoo, int inCount) :
            TestEventArgs ()
        {
            m_Data = inData;
            m_Foo  = inFoo;
            m_Count = inCount;
        }


        // overrides
        virtual Glib::VariantBase
        serialize_vfunc ()
        {
            return serialize (m_Data, m_Foo, m_Count);
        }

        virtual void
        unserialize_vfunc (const Glib::VariantBase& inData)
        {
            unserialize (inData, m_Data, m_Foo, m_Count);
        }

    private:
        // properties
        unsigned long m_Data;
        Glib::ustring m_Foo;
        int           m_Count;
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestEvent::TestEvent () :
    TestCase ("event"),
    m_pEvent (0),
    m_Data (0),
    m_Foo (""),
    m_Count (0)
{
    add_test ("publish", sigc::mem_fun (this, &TestEvent::test_event_publish));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestEvent::~TestEvent ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::test_event_publish ()
{
    m_Data = 0;
    m_Foo = "";
    m_Count = 0;

    m_pEvent = Core::Event::create ("test-event");
    Glib::RefPtr<Core::EventListener> pListener = Core::EventListener::create (m_pEvent, this, &TestEvent::on_event);
    Core::EventBus::get_default ()->subscribe (pListener);

    {
        Glib::RefPtr<Glib::TimeoutSource> pTimeout = Glib::TimeoutSource::create (1000);
        pTimeout->connect (sigc::mem_fun (this, &TestEvent::on_publish));
        pTimeout->attach (Glib::MainContext::get_default ());

        Glib::RefPtr<Glib::TimeoutSource> pEnd = Glib::TimeoutSource::create (5000);
        pEnd->connect (sigc::mem_fun (this, &TestEvent::on_quit));
        pEnd->attach (Glib::MainContext::get_default ());
    }

    Application::get_default ()->run ();

    g_assert (m_Data == 1245);
    g_assert (m_Foo == "toto");
    g_assert (m_Count == 3);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::on_event (const Glib::RefPtr<Core::EventArgs>& inpArgs)
{
    g_test_message ("Receive test-event");
    Glib::RefPtr<TestEventArgs> pArgs = Glib::RefPtr<TestEventArgs>::cast_static (inpArgs);
    if (pArgs)
    {
        m_Data = pArgs->get_data ();
        m_Foo = pArgs->get_foo ();
        m_Count = pArgs->get_count ();
        g_test_message ("Receive test-event \"%s\" %lu %i", m_Foo.c_str (), m_Data, m_Count);
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool
TestEvent::on_publish ()
{
    static int cpt = 0;

    Glib::RefPtr<TestEventArgs> pArgs = TestEventArgs::create (1245, "toto", ++cpt);
    g_test_message ("Send test-event \"toto\" 1245 %i %u", cpt, G_OBJECT (Core::EventBus::get_default ()->gobj ())->ref_count);

    Core::EventBus::get_default ()->publish ("test-event", pArgs);

    return cpt < 3;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool
TestEvent::on_quit ()
{
    Application::get_default ()->quit ();

    return false;
}

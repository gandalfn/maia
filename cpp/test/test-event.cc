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

MAIA_CORE_EVENT_ARGS_DEFINE(TestProtobufEventArgs)

MAIA_CORE_EVENT_ARGS_REGISTER("message TestProtobuf {"
                              "     uint64 data;"
                              "     string foo;"
                              "     repeated int32 array;"
                              "}",
                              "TestProtobuf",
                              TestProtobufEventArgs)

MAIA_CORE_EVENT_ARGS_DEFINE(TestReplyEventArgs)

MAIA_CORE_EVENT_ARGS_REGISTER("message TestReply {"
                              "     uint32 cpt;"
                              "}",
                              "TestReply",
                              TestReplyEventArgs)


class TestEventArgs : public Core::EventArgs
{
    public:
        using RefPtr = Glib::RefPtr<TestEventArgs>;

        // methods
        unsigned long get_data  () const { return m_Data;  }
        Glib::ustring get_foo   () const { return m_Foo;   }
        int           get_count () const { return m_Count; }

        // static methods
        static TestEventArgs::RefPtr create (unsigned long inData, const Glib::ustring& inFoo, int inCount)
        {
            return TestEventArgs::RefPtr (new TestEventArgs (inData, inFoo, inCount));
        }

    protected:
        MAIA_CORE_EVENT_ARGS_CONSTRUCTOR("(tsi)", TestEventArgs)

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
    add_test ("publish-reply", sigc::mem_fun (this, &TestEvent::test_event_publish_with_reply));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestEvent::~TestEvent ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::set_up ()
{
    m_pLoop = Glib::MainLoop::create ();
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::tear_down ()
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
    Core::EventListener::RefPtr pListener = Core::EventListener::create (m_pEvent, this, &TestEvent::on_event);
    Core::EventBus::get_default ()->subscribe (pListener);

    {
        Glib::RefPtr<Glib::TimeoutSource> pTimeout = Glib::TimeoutSource::create (1000);
        pTimeout->connect (sigc::mem_fun (this, &TestEvent::on_publish));
        pTimeout->attach (Glib::MainContext::get_default ());

        Glib::RefPtr<Glib::TimeoutSource> pEnd = Glib::TimeoutSource::create (5000);
        pEnd->connect (sigc::mem_fun (this, &TestEvent::on_quit));
        pEnd->attach (Glib::MainContext::get_default ());
    }

    m_pLoop->run ();

    g_assert (m_Data == 1245);
    g_assert (m_Foo == "toto");
    g_assert (m_Count == 3);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::test_event_publish_with_reply ()
{

    m_pEvent = Core::Event::create ("test-event-reply");
    Core::EventBus::get_default ()->subscribe ("test-event-reply", this, &TestEvent::on_event_reply);

    {
        Glib::RefPtr<Glib::TimeoutSource> pTimeout = Glib::TimeoutSource::create (1000);
        pTimeout->connect (sigc::mem_fun (this, &TestEvent::on_publish_with_reply));
        pTimeout->attach (Glib::MainContext::get_default ());

        Glib::RefPtr<Glib::TimeoutSource> pEnd = Glib::TimeoutSource::create (5000);
        pEnd->connect (sigc::mem_fun (this, &TestEvent::on_quit));
        pEnd->attach (Glib::MainContext::get_default ());
    }

    m_pLoop->run ();
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::on_event (const Core::EventArgs::RefPtr& inpArgs)
{
    g_test_message ("Receive test-event");
    TestEventArgs::RefPtr pArgs = TestEventArgs::RefPtr::cast_static (inpArgs);
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
void
TestEvent::on_event_reply (const Core::EventArgs::RefPtr& inpArgs)
{
    uint32_t val = inpArgs->fields ()["cpt"];
    g_test_message ("Receive test-event-reply recv %u", val);
    inpArgs->fields ()["cpt"] = (uint32_t)g_test_rand_int_range (0, 100);
    val = inpArgs->fields ()["cpt"];
    g_test_message ("Receive test-event-reply send %u", val);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool
TestEvent::on_publish_with_reply ()
{
    static int cpt = 0;

    TestReplyEventArgs::RefPtr pArgs = TestReplyEventArgs::create ("cpt", (uint32_t)g_test_rand_int_range (0, 100));

    Maia::Core::EventBus::get_default ()->publish_with_reply ("test-event-reply", pArgs, this, &TestEvent::on_reply);
    ++cpt;
    return cpt < 3;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestEvent::on_reply (const Core::EventArgs::RefPtr& inpArgs)
{
    g_test_message ("Receive reply test-event-reply");
    uint32_t val = inpArgs->fields ()["cpt"];
    g_test_message ("reply val = %u", val);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool
TestEvent::on_publish ()
{
    static int cpt = 0;

    TestProtobufEventArgs::RefPtr pProtobufArgs = TestProtobufEventArgs::create ();
    Core::EventArgs::Fields fields = pProtobufArgs->fields ();
    fields["data"] = (unsigned long long)1234;
    fields["foo"] = (Glib::ustring)"toto";
    fields["array"].push_back (23);
    fields["array"].push_back (45);
    fields["array"].push_back (67);

    unsigned long long data = fields["data"];
    Glib::ustring foo = fields["foo"];

    g_assert (data == 1234);
    g_assert (foo == "toto");
    g_assert ((int)fields["array"][0] == 23);
    g_assert ((int)fields["array"][1] == 45);
    g_assert ((int)fields["array"][2] == 67);

    std::vector<int> array = fields["array"];
    g_assert (array[0] == 23);
    g_assert (array[1] == 45);
    g_assert (array[2] == 67);

    std::vector<int> val;
    val.push_back (98);
    val.push_back (76);
    val.push_back (54);
    fields["array"] = val;

    g_assert ((int)fields["array"][0] == 98);
    g_assert ((int)fields["array"][1] == 76);
    g_assert ((int)fields["array"][2] == 54);

    TestProtobufEventArgs::RefPtr pProtobufArgs2 = TestProtobufEventArgs::create ("data", 1234ULL, "foo", "toto", "array", val);
    Core::EventArgs::Fields fields2 = pProtobufArgs2->fields ();
    unsigned long long data2 = fields2["data"];
    Glib::ustring foo2 = fields2["foo"];
    std::vector<int> array2 = fields2["array"];

    g_assert (data2 == 1234);
    g_assert (foo2 == "toto");
    g_assert (array2[0] == 98);
    g_assert (array2[1] == 76);
    g_assert (array2[2] == 54);

    TestEventArgs::RefPtr pArgs = TestEventArgs::create (1245, "toto", ++cpt);
    g_test_message ("Send test-event \"toto\" 1245 %i %u", cpt, G_OBJECT (Core::EventBus::get_default ()->gobj ())->ref_count);

    Core::EventBus::get_default ()->publish ("test-event", pArgs);

    return cpt < 3;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool
TestEvent::on_quit ()
{
    m_pLoop->quit ();

    return false;
}

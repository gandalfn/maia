/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-protocol.cc
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

#include "test-protocol.h"

using namespace Maia;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestProtocol::TestProtocol () :
    TestCase ("protocol")
{
    add_test ("simple", sigc::mem_fun (this, &TestProtocol::test_buffer_simple));
    add_test ("sub", sigc::mem_fun (this, &TestProtocol::test_buffer_sub));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestProtocol::~TestProtocol ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestProtocol::test_buffer_simple ()
{
    Glib::RefPtr<Maia::Protocol::Buffer> pBuffer = Maia::Protocol::Buffer::create ("message Simple {"
                                                                                   "    uint32 val;"
                                                                                   "    string str;"
                                                                                   "}");
    g_assert (pBuffer);

    Glib::RefPtr<Maia::Protocol::Message> pMessage = pBuffer->get ("Simple");

    g_assert (pMessage);

    Maia::Protocol::Message::Fields fields = pMessage->fields ();
    fields["val"] = (uint32_t)1234;
    fields["str"] = (Glib::ustring)"Test simple string";

    uint32_t val = fields["val"];
    Glib::ustring str = fields["str"];
    g_assert (val == 1234);
    g_assert (str == "Test simple string");

    Glib::VariantBase variant = pMessage->serialize ();

    g_test_message ("message: %s", variant.print ().c_str ());
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestProtocol::test_buffer_sub ()
{
    Glib::RefPtr<Maia::Protocol::Buffer> pBuffer = Maia::Protocol::Buffer::create ("message Sub {"
                                                                                   "    uint32 val;"
                                                                                   "    string str;"
                                                                                   "}"
                                                                                   "message Test {"
                                                                                   "    Sub sub;"
                                                                                   "}");
    g_assert (pBuffer);

    Glib::RefPtr<Maia::Protocol::Message> pMessage = pBuffer->get ("Test");

    g_assert (pMessage);

    Maia::Protocol::Message::Fields fields = pMessage->fields ();
    fields["sub"]["val"] = (uint32_t)1234;
    fields["sub"]["str"] = (Glib::ustring)"Test simple string";

    uint32_t val = fields["sub"]["val"];
    Glib::ustring str = fields["sub"]["str"];
    g_assert (val == 1234);
    g_assert (str == "Test simple string");

    Glib::VariantBase variant = pMessage->serialize ();

    g_test_message ("message: %s", variant.print ().c_str ());
}

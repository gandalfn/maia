/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-case.cc
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

#include "test-case.h"

#include <cstring>
#include <iomanip>

using namespace Maia;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestAdaptor::TestAdaptor (const std::string& inName, const TestMethod& inTestSlot, TestCase* inpTestCase) :
    m_Name (inName),
    m_pTestSlot (0),
    m_pTestCase (inpTestCase)
{
    m_pTestSlot = new TestMethod (inTestSlot);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestAdaptor::~TestAdaptor ()
{
    delete m_pTestSlot; m_pTestSlot = 0;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestAdaptor::set_up (void*)
{
    m_pTestCase->set_up ();
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestAdaptor::run (void*)
{
    (*m_pTestSlot) ();
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestAdaptor::tear_down (void*)
{
    m_pTestCase->tear_down ();
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestAdaptor::_set_up_adaptor (void* inFixture, TestAdaptor* inpAdaptor)
{
    inpAdaptor->set_up (inFixture);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestAdaptor::_run_adaptor (void* inFixture, TestAdaptor* inpAdaptor)
{
    inpAdaptor->run (inFixture);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestAdaptor::_tear_down_adaptor (void* inFixture, TestAdaptor* inpAdaptor)
{
    inpAdaptor->tear_down (inFixture);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestCase::TestCase (const std::string& inName) :
    m_Name (inName),
    m_Suite (inName)
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestCase::~TestCase ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCase::set_up ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCase::tear_down ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestCase::add_test (const std::string& inName, const TestMethod& inTestSlot)
{
    TestAdaptor* pAdaptor = new TestAdaptor(inName, inTestSlot, this);
    m_Adaptors.push_back (pAdaptor);
    m_Suite.add (pAdaptor);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestSuite::TestSuite () :
    m_Name (""),
    m_pSuite (g_test_get_root ())
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestSuite::TestSuite (std::string inName) :
    m_Name (inName),
    m_pSuite (g_test_create_suite (inName.c_str ()))
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestSuite::~TestSuite ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestSuite::add_suite (const TestSuite& inSuite)
{
    g_test_suite_add_suite (m_pSuite, inSuite.m_pSuite);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestSuite::add (TestAdaptor* inpAdaptor)
{
    GTestCase* pCase = g_test_create_case (inpAdaptor->get_name ().c_str (), 0, inpAdaptor,
                                           (GTestFixtureFunc)&TestAdaptor::_set_up_adaptor,
                                           (GTestFixtureFunc)&TestAdaptor::_run_adaptor,
                                           (GTestFixtureFunc)&TestAdaptor::_tear_down_adaptor);

    g_test_suite_add (m_pSuite, pCase);
}

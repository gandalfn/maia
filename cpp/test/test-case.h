/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-case.h
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

#ifndef _MAIA_TEST_CASE_H
#define _MAIA_TEST_CASE_H

#include <vector>

#include <glibmm.h>

namespace Maia
{
    typedef sigc::slot<void> TestMethod;

    class TestCase;
    class TestSuite;

    class TestAdaptor
    {
        public:
            TestAdaptor (const std::string& inName, const TestMethod& inTestSlot, TestCase* inpTest);
            virtual ~TestAdaptor ();

            // accessors
            const std::string& get_name () const { return m_Name; }

            // methods
            void set_up (void* inFixture);
            void run (void* inFixture);
            void tear_down (void* inFixture);

        private:
            // properties
            std::string       m_Name;
            TestMethod*       m_pTestSlot;
            TestCase*        m_pTestCase;

            // static methods
            static void _set_up_adaptor (void* inFixture, TestAdaptor* inAdaptor);
            static void _run_adaptor (void* inFixture, TestAdaptor* inAdaptor);
            static void _tear_down_adaptor (void* inFixture, TestAdaptor* inAdaptor);

            friend class TestSuite;
    };

    class TestSuite
    {
        public:
            TestSuite ();
            TestSuite (std::string inName);
            virtual ~TestSuite ();

            // methods
            void add_suite (const TestSuite& inSuite);
            void add (TestAdaptor* inpAdaptor);

        private:
            std::string m_Name;
            GTestSuite* m_pSuite;
    };

    class TestCase
    {
        public:
            TestCase (const std::string& inName);
            virtual ~TestCase ();

            // accessors
            const TestSuite&         get_suite () { return m_Suite; }

            // methods
            virtual void set_up ();
            virtual void tear_down ();

            void add_test (const std::string& inName, const TestMethod& inTestSlot);

        private:
            std::string                m_Name;
            std::vector<TestAdaptor*> m_Adaptors;
            TestSuite                 m_Suite;
    };
}

#endif // _MAIA_TEST_CASE_H

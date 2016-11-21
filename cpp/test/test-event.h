/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-event.h
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

#ifndef _MAIA_TEST_EVENT_H
#define _MAIA_TEST_EVENT_H

namespace Maia
{
    class TestEvent : public TestCase
    {
        public:
            TestEvent ();
            virtual ~TestEvent ();

            // override
            virtual void set_up ();
            virtual void tear_down ();

        private:
            // properties
            Glib::RefPtr<Glib::MainLoop> m_pLoop;
            Core::Event::RefPtr m_pEvent;
            unsigned long m_Data;
            Glib::ustring m_Foo;
            int m_Count;

            // methods
            void test_event_publish ();
            void test_event_publish_with_reply ();
            void on_event_reply (const Core::EventArgs::RefPtr& inpArgs);
            void on_event (const Core::EventArgs::RefPtr& inpArgs);
            bool on_publish ();
            bool on_publish_with_reply ();
            void on_reply (const Core::EventArgs::RefPtr& inpArgs);
            bool on_quit ();
    };
}

#endif

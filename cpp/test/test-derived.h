/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-derived.h
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

#ifndef _MAIA_TEST_DERIVED_H
#define _MAIA_TEST_DERIVED_H

namespace Maia
{
    class TestDerived : public TestCase
    {
        public:
            TestDerived ();
            virtual ~TestDerived ();

            // override
            virtual void set_up ();
            virtual void tear_down ();

        private:
            // properties
            ::Gtk::Main*   m_pKit;
            ::Gtk::Window* m_pWindow;

            // methods
            void test_item_derived ();
    };
}

#endif

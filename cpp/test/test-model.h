/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-model.h
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

#ifndef _MAIA_TEST_MODEL_H
#define _MAIA_TEST_MODEL_H

namespace Maia
{
    class TestModel : public TestCase
    {
        public:
            TestModel ();
            virtual ~TestModel ();

            // override
            virtual void set_up ();
            virtual void tear_down ();

        private:
            // methods
            void test_model_create ();
            void test_model_create_with_columns ();
            void test_model_append ();
            void test_model_remove ();
            void test_model_clear ();
            void test_model_set_values ();
            void test_model_filter ();
            void test_model_parse ();
            bool on_filter_func (const Glib::RefPtr<Maia::Model>& inpModel, const Maia::Model::iterator& inIter);
    };
}

#endif

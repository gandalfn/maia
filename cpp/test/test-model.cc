/* -*- Mode: C++; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-model.cc
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

#include "test-model.h"

using namespace Maia;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestModel::TestModel () :
    TestCase ("model")
{
    add_test ("create", sigc::mem_fun (this, &TestModel::test_model_create));
    add_test ("create-with-columns", sigc::mem_fun (this, &TestModel::test_model_create_with_columns));
    add_test ("append", sigc::mem_fun (this, &TestModel::test_model_append));
    add_test ("remove", sigc::mem_fun (this, &TestModel::test_model_remove));
    add_test ("clear", sigc::mem_fun (this, &TestModel::test_model_clear));
    add_test ("set-values", sigc::mem_fun (this, &TestModel::test_model_set_values));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
TestModel::~TestModel ()
{
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::set_up ()
{

}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::tear_down ()
{

}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_create ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test");
    g_assert (pModel);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_create_with_columns ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test", { Maia::Model::Column::create<int> ("column1"), Maia::Model::Column::create<Glib::ustring> ("column2") });
    g_assert (pModel);

    int cpt = 0;
    for (Maia::Core::Object::iterator iter = pModel->begin (); iter != pModel->end (); ++iter, ++cpt)
    {
        Glib::RefPtr<Maia::Model::Column> column = Glib::RefPtr<Maia::Model::Column>::cast_dynamic (*iter);
        g_assert (column);
    }

    g_assert (cpt == 2);

    Glib::RefPtr<Maia::Model::Column> pColumn1 = pModel->find ("column1");
    g_assert (pColumn1);

    Glib::RefPtr<Maia::Model::Column> pColumn2 = pModel->find ("column2");
    g_assert (pColumn2);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_append ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test", { Maia::Model::Column::create<int> ("column1"), Maia::Model::Column::create<Glib::ustring> ("column2") });
    g_assert (pModel);

    int cpt = 0;
    for (Maia::Core::Object::iterator iter = pModel->begin (); iter != pModel->end (); ++iter, ++cpt)
    {
        Glib::RefPtr<Maia::Model::Column> column = Glib::RefPtr<Maia::Model::Column>::cast_dynamic (*iter);
        g_assert (column);
    }

    g_assert (cpt == 2);

    Maia::Model::iterator iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    Maia::Model::Row row = *iter;
    row["column1"] =  1;
    row["column2"] = Glib::ustring ("test 1");

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row["column1"] = 2;
    row["column2"] = Glib::ustring ("test 2");

    g_assert (pModel->get_nb_rows () == 2);

    cpt = 0;
    for (iter = pModel->rows ().begin (); iter != pModel->rows ().end (); ++iter, ++cpt)
    {
        row = *iter;
        int val = row["column1"];
        Glib::ustring str = row["column2"];

        g_assert (val == cpt + 1);
        g_assert (str == Glib::ustring::compose ("test %1", val));
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_remove ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test", { Maia::Model::Column::create<int> ("column1"), Maia::Model::Column::create<Glib::ustring> ("column2") });
    g_assert (pModel);

    int cpt = 0;
    for (Maia::Core::Object::iterator iter = pModel->begin (); iter != pModel->end (); ++iter, ++cpt)
    {
        Glib::RefPtr<Maia::Model::Column> column = Glib::RefPtr<Maia::Model::Column>::cast_dynamic (*iter);
        g_assert (column);
    }

    g_assert (cpt == 2);

    Maia::Model::iterator iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    Maia::Model::Row row = *iter;
    row["column1"] =  1;
    row["column2"] = Glib::ustring ("test 1");

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row["column1"] = 2;
    row["column2"] = Glib::ustring ("test 2");

    g_assert (pModel->get_nb_rows () == 2);

    cpt = 0;
    for (iter = pModel->rows ().begin (); iter != pModel->rows ().end (); ++iter, ++cpt)
    {
        row = *iter;
        int val = row["column1"];
        Glib::ustring str = row["column2"];

        g_assert (val == cpt + 1);
        g_assert (str == Glib::ustring::compose ("test %1", val));
    }

    pModel->remove_row (pModel->rows ().begin ());
    g_assert (pModel->get_nb_rows () == 1);

    pModel->remove_row (pModel->rows ().begin ());
    g_assert (pModel->get_nb_rows () == 0);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_clear ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test", { Maia::Model::Column::create<int> ("column1"), Maia::Model::Column::create<Glib::ustring> ("column2") });
    g_assert (pModel);

    int cpt = 0;
    for (Maia::Core::Object::iterator iter = pModel->begin (); iter != pModel->end (); ++iter, ++cpt)
    {
        Glib::RefPtr<Maia::Model::Column> column = Glib::RefPtr<Maia::Model::Column>::cast_dynamic (*iter);
        g_assert (column);
    }

    g_assert (cpt == 2);

    Maia::Model::iterator iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    Maia::Model::Row row = *iter;
    row["column1"] =  1;
    row["column2"] = Glib::ustring ("test 1");

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row["column1"] = 2;
    row["column2"] = Glib::ustring ("test 2");

    g_assert (pModel->get_nb_rows () == 2);

    cpt = 0;
    for (iter = pModel->rows ().begin (); iter != pModel->rows ().end (); ++iter, ++cpt)
    {
        row = *iter;
        int val = row["column1"];
        Glib::ustring str = row["column2"];

        g_assert (val == cpt + 1);
        g_assert (str == Glib::ustring::compose ("test %1", val));
    }

    pModel->clear ();
    g_assert (pModel->get_nb_rows () == 0);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_set_values ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test", { Maia::Model::Column::create<int> ("column1"), Maia::Model::Column::create<Glib::ustring> ("column2") });
    g_assert (pModel);

    int cpt = 0;
    for (Maia::Core::Object::iterator iter = pModel->begin (); iter != pModel->end (); ++iter, ++cpt)
    {
        Glib::RefPtr<Maia::Model::Column> column = Glib::RefPtr<Maia::Model::Column>::cast_dynamic (*iter);
        g_assert (column);
    }

    g_assert (cpt == 2);

    Maia::Model::iterator iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    Maia::Model::Row row = *iter;
    row.set_values ("column1", 1, "column2", "test 1", 0);

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row.set_values ("column1", 2, "column2", "test 2", 0);

    g_assert (pModel->get_nb_rows () == 2);

    cpt = 0;
    for (iter = pModel->rows ().begin (); iter != pModel->rows ().end (); ++iter, ++cpt)
    {
        row = *iter;
        int val = row["column1"];
        Glib::ustring str = row["column2"];

        g_assert (val == cpt + 1);
        g_assert (str == Glib::ustring::compose ("test %1", val));
    }
}

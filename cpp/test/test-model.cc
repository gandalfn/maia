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

#include <maiamm.h>

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
    add_test ("filter", sigc::mem_fun (this, &TestModel::test_model_filter));
    add_test ("parse", sigc::mem_fun (this, &TestModel::test_model_parse));
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
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test",
                                                            {
                                                                Maia::Model::Column::create<int> ("column1"),
                                                                Maia::Model::Column::create<Glib::ustring> ("column2")
                                                            });
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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool
TestModel::on_filter_func (const Glib::RefPtr<Maia::Model>& inpModel, const Maia::Model::iterator& inIter)
{
    const Maia::Model::Row& row = *inIter;

    int val = row["column1"];

    return val > 5;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_filter ()
{
    Glib::RefPtr<Maia::Model> pModel = Maia::Model::create ("test",
                                                            {
                                                                Maia::Model::Column::create<int> ("column1"),
                                                                Maia::Model::Column::create<Glib::ustring> ("column2")
                                                            });
    g_assert (pModel);


    Glib::RefPtr<Maia::Model> pFilterModel = Maia::Model::create ("filter", pModel, sigc::mem_fun (this, &TestModel::on_filter_func));
    g_assert (pFilterModel);

    Maia::Model::iterator iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    Maia::Model::Row row = *iter;
    row["column1"] =  1;
    row["column2"] = Glib::ustring ("test 1");

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row["column1"] = 15;
    row["column2"] = Glib::ustring ("test 2");

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row["column1"] = 3;
    row["column2"] = Glib::ustring ("test 3");

    iter = pModel->append_row ();
    g_assert (iter != pModel->rows ().end ());
    row = *iter;
    row["column1"] = 8;
    row["column2"] = Glib::ustring ("test 4");

    g_assert (pModel->get_nb_rows () == 4);
    g_assert (pFilterModel->get_nb_rows () == 2);

    for (iter = pFilterModel->rows ().begin (); iter != pFilterModel->rows ().end (); ++iter)
    {
        row = *iter;
        int val = row["column1"];
        Glib::ustring str = row["column2"];

        g_assert (val == 15 || val == 8);
        g_assert (str == "test 2" || str == "test 4");
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void
TestModel::test_model_parse ()
{
    Glib::ustring data = "Model.test {"
                         "  Column.bool_column {"
                         "      column-type: bool;"
                         "  }"
                         "  Column.int_column {"
                         "      column-type: int;"
                         "  }"
                         "  Column.double_column {"
                         "      column-type: double;"
                         "  }"
                         "  Column.string_column {"
                         "      column-type: string;"
                         "  }"
                         "  ["
                         "      Row.0 {"
                         "          bool_column: true;"
                         "          int_column: 3214;"
                         "          double_column: 23.456;"
                         "          string_column: 'row num 1';"
                         "      }"
                         "      Row.1 {"
                         "          bool_column: false;"
                         "          int_column: 641;"
                         "          double_column: 92.329;"
                         "          string_column: 'row num 2';"
                         "      }"
                         "      Row.2 {"
                         "          bool_column: true;"
                         "          int_column: 854;"
                         "          double_column: 5452.32;"
                         "          string_column: 'row num 3';"
                         "      }"
                         "  ]"
                         "}";

    try
    {
        Glib::RefPtr<Manifest::Document> pDocument = Manifest::Document::create_from_buffer (data);
        Glib::RefPtr<Maia::Model> pModel = Glib::RefPtr<Maia::Model>::cast_dynamic (pDocument->get("test"));

        g_assert (pModel->get_nb_rows () == 3);

        int cpt = 0;
        for (Maia::Model::iterator iter = pModel->rows ().begin (); iter != pModel->rows ().end (); ++iter, ++cpt)
        {
            const Maia::Model::Row& row = *iter;
            bool bool_val = row["bool_column"];
            int int_val = row["int_column"];
            double double_val = row["double_column"];
            Glib::ustring string_val = row["string_column"];

            switch (cpt)
            {
                case 0:
                    g_assert (bool_val == true);
                    g_assert (int_val == 3214);
                    g_assert (double_val == 23.456);
                    g_assert (string_val == "row num 1");
                    break;

                case 1:
                    g_assert (bool_val == false);
                    g_assert (int_val == 641);
                    g_assert (double_val == 92.329);
                    g_assert (string_val == "row num 2");
                    break;

                case 2:
                    g_assert (bool_val == true);
                    g_assert (int_val == 854);
                    g_assert (double_val == 5452.32);
                    g_assert (string_val == "row num 3");
                    break;

                default: break;
            }
        }
    }
    catch (Glib::Error& err)
    {
        g_assert (false);
    }
}

/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test.vala
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

void main (string[] args)
{
    Test.init (ref args);

    var application = new Maia.Application ("test", 60, { "gtk" } );

    if (Test.verbose ())
    {
        //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.MAIN_EVENT, "test"));
    }

    TestSuite.get_root ().add_suite (new Maia.TestCore ().suite);
    TestSuite.get_root ().add_suite (new Maia.TestGraphic ().suite);
    TestSuite.get_root ().add_suite (new Maia.TestManifest ().suite);
    TestSuite.get_root ().add_suite (new Maia.TestCassowary ().suite);

    Test.run ();
}

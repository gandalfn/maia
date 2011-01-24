/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-application.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public class Maia.TestApplication : Maia.TestCase
{
    public TestApplication ()
    {
        base ("application");

        add_test ("create", test_create);
    }

    public void
    test_create ()
    {
        Maia.Application application = Maia.XcbBackend.create_application ();

        Maia.Desktop desktop = application.desktop;

        assert (desktop != null);
        assert (desktop.nb_workspaces > 0);

        Test.message ("workspace geometry %s", desktop.default_workspace.geometry.to_string ());
    }
}
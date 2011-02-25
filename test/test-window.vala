/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-window.vala
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

static void
on_damage_event (Maia.DamageEventArgs inArgs)
{
    Maia.audit (GLib.Log.METHOD, "%s", inArgs.area.to_string ());
}

static int
main (string[] args)
{
    Maia.log_set_level (Maia.Level.DEBUG);

    Maia.Application application = Maia.XcbBackend.create_application ();

    Maia.Window window = application.desktop.default_workspace.create_window (new Maia.Region.raw_rectangle (0, 0, 200, 200));

    window.damage_event.listen (on_damage_event, application.dispatcher);

    window.show ();

    Maia.audit (GLib.Log.METHOD, "%s", application.desktop.default_workspace.root.geometry.to_string ());

    application.run ();

    return 0;
}
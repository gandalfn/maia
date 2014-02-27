/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * canvas-editor.vala
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

static int
main (string[] inArgs)
{
    Gtk.init (ref inArgs);

    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "canvas-editor"));
    var window = new CanvasEditor.Window ();
    window.show ();

    var application = new Maia.Application ("canvas-editor", 60, { "gtk" });

    application.run ();

    return 0;
}

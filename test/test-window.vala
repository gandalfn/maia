/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-window.vala
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
main (string[] args)
{
    Maia.Log.set_default_logger (new Maia.Log.File ("test-window.log", Maia.Log.Level.DEBUG, "test-window"));
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, "test-window"));

    Maia.Application.init (args);

    Maia.Manifest.Document manifest = new Maia.Manifest.Document ("test.manifest");
    Maia.Label label = manifest["Label", "test-label"] as Maia.Label;

    /*TestWindow window = new TestWindow ();*/
    Maia.Window window = new Maia.Window ("toto", 250, 150);
    window.visible = true;
    window.add (label);
    message ("Label: %s %s %s", label.font_description, label.text, label.geometry.extents.to_string ());

    Maia.Application.run ();

    return 0;
}

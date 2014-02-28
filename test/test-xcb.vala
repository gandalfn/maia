/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-xcb.vala
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

// Window.test-xcb {
//    background_pattern: rgb (1, 1, 1);
//    visible: true;
//    size: 640, 480;
//
//    Label.label {
//        text: "Youpi !!!!!\nvive la karioka";
//        font_description: "Liberation Sans 48";
//        stroke_pattern: rgb (0, 0, 0);
//    }
//}

void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "test-xcb"));

    var application = new Maia.Application ("test-xcb", 60, { "xcb" });

    var window = new Maia.Window ("test-xcb", 640, 480);
    application.add (window);
    window.visible = true;
    window.background_pattern = new Maia.Graphic.Color (1, 1, 1);

    var label = new Maia.Label ("label", "Youpi !!!!!\nvive la karioka");
    label.font_description = "Liberation Sans 48";
    label.stroke_pattern = new Maia.Graphic.Color (0, 0, 0);
    window.add (label);

    application.run ();
}

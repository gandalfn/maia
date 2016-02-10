/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-surface.vala
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

public class Maia.TestSurface : Maia.TestCase
{
    public TestSurface ()
    {
        base ("surface");

        add_test ("serialize", test_surface_serialize);
    }

    public void
    test_surface_serialize ()
    {
        Graphic.ImagePng image = new Graphic.ImagePng ("test.png");

        Graphic.Surface surface = new Graphic.Surface ((uint)image.size.width, (uint)image.size.height);
        Test.timer_start ();
        surface.serialize = image.surface.serialize;
        Test.message (@"size: $((4 * image.size.width * image.size.height) / (1024 * 1024)) Mb elapsed: $(Test.timer_elapsed () * 1000)ms");

        surface.dump("output.png");
    }
}
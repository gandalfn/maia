/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * init.vala
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

namespace Maia.GdkPixbuf
{
    [CCode (cname = "backend_load")]
    public void backend_load ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Loading Gdk-Pixbuf backend");

        Core.Any.delegate (typeof (Maia.Graphic.ImagePng), typeof (ImagePng));
        Core.Any.delegate (typeof (Maia.Graphic.ImageJpg), typeof (ImageJpg));
        Core.Any.delegate (typeof (Maia.Graphic.ImageSvg), typeof (ImageSvg));
        Core.Any.delegate (typeof (Maia.Graphic.ImageGif), typeof (ImageGif));
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Unloading Gdk-Pixbuf backend");

        Core.Any.undelegate (typeof (Maia.Graphic.ImagePng));
        Core.Any.undelegate (typeof (Maia.Graphic.ImageJpg));
        Core.Any.undelegate (typeof (Maia.Graphic.ImageSvg));
        Core.Any.undelegate (typeof (Maia.Graphic.ImageGif));
    }
}

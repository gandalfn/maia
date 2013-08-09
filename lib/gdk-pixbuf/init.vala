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
    static bool s_Initialized = false;

    public static void
    init ()
    {
        if (!s_Initialized)
        {
            Core.Any.delegate (typeof (Graphic.ImagePng),  typeof (ImagePng));
            Core.Any.delegate (typeof (Graphic.ImageJpg),  typeof (ImageJpg));
            Core.Any.delegate (typeof (Graphic.ImageSvg),  typeof (ImageSvg));
            Core.Any.delegate (typeof (Graphic.ImageGif),  typeof (ImageGif));

            s_Initialized = true;
        }
    }
}
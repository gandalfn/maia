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

namespace Maia.Cairo
{
    [CCode (cname = "backend_load")]
    public void backend_load ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Loading Cairo backend");

        Maia.Core.Any.delegate (typeof (Maia.Graphic.Region),   typeof (Maia.Cairo.Region));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.Glyph),    typeof (Maia.Cairo.Glyph));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.Surface),  typeof (Maia.Cairo.Surface));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.Context),  typeof (Maia.Cairo.Context));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.ImagePng), typeof (Maia.Cairo.ImagePng));
        Maia.Core.Any.delegate (typeof (Maia.Document),         typeof (Maia.Cairo.Document));
        Maia.Core.Any.delegate (typeof (Maia.Report),           typeof (Maia.Cairo.Report));
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Unloading Cairo backend");

        Maia.Core.Any.undelegate (typeof (Maia.Graphic.Region));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.Glyph));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.Surface));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.Context));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.ImagePng));
        Maia.Core.Any.undelegate (typeof (Maia.Document));
        Maia.Core.Any.undelegate (typeof (Maia.Report));
    }
}

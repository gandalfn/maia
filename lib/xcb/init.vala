/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * init.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

namespace Maia.Xcb
{
    internal static Application application = null;

    [CCode (cname = "backend_load")]
    public void backend_load ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Loading XCB backend");

        Maia.Core.Any.delegate (typeof (Maia.Window), typeof (Maia.Xcb.Window));

        Maia.Xcb.application = new Maia.Xcb.Application ();
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Unloading XCB backend");

        Maia.Core.Any.undelegate (typeof (Maia.Window));

        Maia.Xcb.application = null;
    }
}

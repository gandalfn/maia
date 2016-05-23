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

        Graphic.Device.register ("xcb/window", typeof (View));
        Graphic.Device.register ("xcb/pixmap", typeof (Pixmap));

        Maia.Core.Any.delegate (typeof (Maia.Window), typeof (Maia.Xcb.Window));
        Maia.Core.Any.delegate (typeof (Maia.Viewport), typeof (Maia.Xcb.Viewport));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.Renderer), typeof (Maia.Xcb.Renderer));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.GLRenderer), typeof (Maia.Xcb.GLRenderer));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.CloneRenderer), typeof (Maia.Xcb.CloneRenderer));
        Maia.Core.Any.delegate (typeof (Maia.Graphic.CloneRenderer.Looper), typeof (Maia.Xcb.CloneRenderer.Looper));
        Maia.Core.Any.delegate (typeof (Maia.InputDevices), typeof (Maia.Xcb.InputDevices));
        Maia.Core.Any.delegate (typeof (Maia.InputDevice), typeof (Maia.Xcb.InputDevice));

        Maia.Core.Any.delegate (GLib.Type.from_name ("gtkmm__MaiaGraphicRenderer"), typeof (Maia.Xcb.Renderer));
        Maia.Core.Any.delegate (GLib.Type.from_name ("gtkmm__MaiaGraphicGLRenderer"), typeof (Maia.Xcb.GLRenderer));
        Maia.Core.Any.delegate (GLib.Type.from_name ("gtkmm__MaiaGraphicCloneRenderer"), typeof (Maia.Xcb.CloneRenderer));
        Maia.Core.Any.delegate (GLib.Type.from_name ("gtkmm__MaiaGraphicCloneRendererLooper"), typeof (Maia.Xcb.CloneRenderer.Looper));

        Maia.Xcb.application = new Maia.Xcb.Application ();
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Log.info (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Unloading XCB backend");

        Graphic.Device.unregister ("xcb/window");
        Graphic.Device.unregister ("xcb/pixmap");

        Maia.Core.Any.undelegate (typeof (Maia.Window));
        Maia.Core.Any.undelegate (typeof (Maia.Viewport));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.Renderer));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.GLRenderer));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.CloneRenderer));
        Maia.Core.Any.undelegate (typeof (Maia.Graphic.CloneRenderer.Looper));
        Maia.Core.Any.undelegate (typeof (Maia.InputDevices));
        Maia.Core.Any.undelegate (typeof (Maia.InputDevice));

        Maia.Core.Any.undelegate (GLib.Type.from_name ("gtkmm__MaiaGraphicRenderer"));
        Maia.Core.Any.undelegate (GLib.Type.from_name ("gtkmm__MaiaGraphicGLRenderer"));
        Maia.Core.Any.undelegate (GLib.Type.from_name ("gtkmm__MaiaGraphicCloneRenderer"));
        Maia.Core.Any.undelegate (GLib.Type.from_name ("gtkmm__MaiaGraphicCloneRendererLooper"));

        Maia.Xcb.application = null;
    }
}

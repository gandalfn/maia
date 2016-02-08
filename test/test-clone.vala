/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-clone.vala
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

const string manifest = "Window.test {" +
                        "    background_pattern: #CECECE;" +
                        "    border: 5;" +
                        "    size: 800,600;" +
                        "    RendererView.renderer {" +
                        "   }" +
                        "}";

static void main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.CANVAS_GEOMETRY, "test-glx"));

    var application = new Maia.Application ("test-clone", 60, { "gtk" });

    try
    {
        uint32 xid;
        uint8 depth = 24;
        args[1].scanf ("0x%x", out xid);
        var device = Maia.Graphic.Device.new ("xcb/window", "xid", xid, "depth", depth);

        var document = new Maia.Manifest.Document.from_buffer (manifest, manifest.length);

        // Get window item
        var window = document["test"] as Maia.Window;
        application.add (window);
        window.visible = true;

        window.destroy_event.subscribe (() => { application.quit (); });

        var renderer_view = window.find (GLib.Quark.from_string ("renderer")) as Maia.RendererView;
        var renderer = new Maia.Graphic.CloneRenderer (Maia.Graphic.Size (1000, 800), device);
        renderer_view.looper = new Maia.Graphic.CloneRenderer.Looper (device);
        renderer_view.renderer = renderer;

        // Run application
        application.run ();
    }
    catch (GLib.Error err)
    {
        Maia.Log.error (GLib.Log.METHOD, Maia.Log.Category.MANIFEST_PARSING, "error on parsing: %s", err.message);
    }
}

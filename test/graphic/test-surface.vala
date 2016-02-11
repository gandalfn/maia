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

public class Maia.TestSurfaceEventArgs : Maia.Core.EventArgs
{
    private Graphic.Surface m_Surface;

    public Graphic.Surface surface {
        get {
            return m_Surface;
        }
        set {
            m_Surface = value;
        }
    }

    internal override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(v)", m_Surface.serialize);
        }
        set {
            GLib.Variant data;
            value.get ("(v)", out data);
            m_Surface = new Graphic.Surface (1, 1);
            m_Surface.serialize = data;
        }
    }

    public TestSurfaceEventArgs (Graphic.Surface inSurface)
    {
        m_Surface = inSurface;
    }
}


public class Maia.TestSurface : Maia.TestCase
{
    public TestSurface ()
    {
        base ("surface");

        add_test ("serialize", test_surface_serialize);
        add_test ("event", test_surface_event);
    }

    public void
    test_surface_serialize ()
    {
        Graphic.ImagePng image = new Graphic.ImagePng ("test.png");

        Graphic.Surface surface = new Graphic.Surface ((uint)image.size.width, (uint)image.size.height);
        Test.timer_start ();
        var data = image.surface.serialize;
        Test.message (@"size: $((4 * image.size.width * image.size.height) / (1024 * 1024)) Mb elapsed: $(Test.timer_elapsed () * 1000)ms");
        Test.timer_start ();
        surface.serialize = data;
        Test.message (@"size: $((4 * image.size.width * image.size.height) / (1024 * 1024)) Mb elapsed: $(Test.timer_elapsed () * 1000)ms");
        surface.dump("output-serialize.png");
    }

    public void
    test_surface_event ()
    {
        var loop = new GLib.MainLoop (null);
        Core.Event event = new Core.Event ("test-surface-event", null);

        new GLib.Thread<void*> (null, () => {
            GLib.MainContext ctx = new GLib.MainContext ();
            ctx.push_thread_default ();
            GLib.MainLoop loop_thread = new GLib.MainLoop (ctx);

            event.subscribe ((args) => {
                if (args is TestSurfaceEventArgs)
                {
                    unowned TestSurfaceEventArgs event_args = (TestSurfaceEventArgs)args;
                    Test.message (@"received elapsed: $(Test.timer_elapsed () * 1000)ms");

                    event_args.surface.dump("output-event.png");

                    loop.quit ();
                }
            });

            loop_thread.run ();

            return null;
        });

        new GLib.Thread<void*> (null, () => {
            Posix.sleep (1);

            Graphic.ImagePng image = new Graphic.ImagePng ("test.png");

            Test.timer_start ();

            event.publish (new TestSurfaceEventArgs (image.surface));

            Test.message (@"publish elapsed: $(Test.timer_elapsed () * 1000)ms");

            return null;
        });

        loop.run ();
    }
}

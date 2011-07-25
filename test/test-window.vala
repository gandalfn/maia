/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-window.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public class TestWindow : Maia.Window
{
    private int count = 0;

    public TestWindow ()
    {
        base ("test-window", 200, 200);
        workspace.create_window_event.listen (on_new_window, Maia.Application.self);
        workspace.reparent_window_event.listen (on_window_reparented, Maia.Application.self);
        workspace.destroy_window_event.listen (on_destroy_window, Maia.Application.self);
    }

    private void
    on_new_window (Maia.CreateWindowEventArgs inArgs)
    {
        Maia.Window window = inArgs.window;
        window.property_changed.watch ((o, n) => {
            message ("property changed %s", ((Maia.Window)o).to_string ());
        });
        message ("new window: %s", window.to_string ());
        ++count;
    }

    private void
    on_window_reparented (Maia.ReparentWindowEventArgs inArgs)
    {
        unowned Maia.Window? window = inArgs.window;
        unowned Maia.Window? parent = inArgs.parent;
        message ("reparent window 0x%x into 0x%x", window.id, parent.id);
        message ("%s", parent.to_string ());
    }

    private void
    on_destroy_window (Maia.DestroyWindowEventArgs inArgs)
    {
        Maia.Window window = inArgs.window;
        message ("destroy window 0x%x: name = %s, ref = %u", window.id, window.name, window.ref_count);
        --count;
    }

    public override void
    on_paint (Maia.Region inArea)
    {
        Maia.audit (GLib.Log.METHOD, "%s", inArea.to_string ());
    }

    public override void
    on_destroy ()
    {
        base.on_destroy ();
        Maia.Application.quit ();
    }
}

static int
main (string[] args)
{
    Maia.log_set_level (Maia.Level.DEBUG);
    //Maia.backtrace_on_crash ();

    Maia.Application application = Maia.Application.create ();

    TestWindow window = new TestWindow ();
    window.show ();

    application.run ();

    return 0;
}
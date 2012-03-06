/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    private Maia.Timeline timeline;

    public TestWindow ()
    {
        base ("test-window", 400, 400);

        workspace.create_window_event.listen (on_new_window, Maia.Application.self);
        workspace.reparent_window_event.listen (on_window_reparented, Maia.Application.self);
        workspace.destroy_window_event.listen (on_destroy_window, Maia.Application.self);

        timeline = new Maia.Timeline (30, 100, Maia.Application.self);
        timeline.loop = true;
        timeline.new_frame.connect (on_new_frame);
        timeline.start ();
    }

    private void
    on_new_frame (int inFrame)
    {
        queue_draw ();
    }

    private void
    on_new_window (Maia.CreateWindowEventArgs inArgs)
    {
        Maia.Window window = inArgs.window;
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
    on_move_resize (Maia.Region inNewGeometry)
    {
        message ("Move resize %s", inNewGeometry.to_string ());
    }

    public override void
    on_paint (Maia.Region inArea)
    {
        //message ("Paint %s", inArea.to_string ());
        try
        {
            Maia.GraphicContext ctx = back_buffer.create_context ();

            ctx.pattern.color = new Maia.GraphicColor (0.0, 0.0, 0.0, 1.0);
            ctx.paint.paint ();
            ctx.pattern.color = new Maia.GraphicColor (1.0, 0.0, 0.0, 1.0);
            ctx.shape.rectangle (20, 20, inArea.clipbox.size.width - 40, inArea.clipbox.size.height - 40, 5, 5);
            ctx.paint.line_width = 5;
            ctx.paint.stroke ();
            ctx.pattern.color = new Maia.GraphicColor (0.0, 0.0, 1.0, 1.0);
            ctx.shape.arc (inArea.clipbox.size.width * timeline.progress, inArea.clipbox.size.height / 2.0,
                           20, 20, 0, 2 * GLib.Math.PI);
            ctx.paint.fill ();
        }
        catch (Maia.GraphicError err)
        {
            message ("Error on paint %s", err.message);
        }
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
    Maia.Log.set_default_logger (new Maia.Log.File ("out.log", Maia.Log.Level.AUDIT, "test-window"));
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.INFO, "test-window"));

    Maia.Application application = Maia.Application.create ();

    TestWindow window = new TestWindow ();
    window.show ();

    application.run ();

    return 0;
}

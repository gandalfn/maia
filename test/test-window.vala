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

/*public class TestWindow : Maia.Window
{
    private int count = 0;
    private Maia.Timeline timeline;

    public TestWindow ()
    {
        base ("test-window", 400, 400);

        double_buffered = false;

        workspace.create_window_event.listen (on_new_window, Maia.Application.self);
        workspace.reparent_window_event.listen (on_window_reparented, Maia.Application.self);
        workspace.destroy_window_event.listen (on_destroy_window, Maia.Application.self);

        timeline = new Maia.Timeline (60, 100, Maia.Application.self);
        timeline.loop = true;
        timeline.new_frame.connect (on_new_frame);
        timeline.start ();
    }

    private void
    on_new_frame (int inFrame)
    {
        //message ("new frame %i", inFrame);
        damage ();
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
    on_move ()
    {
        message ("Move %s", geometry.extents.to_string ());
    }

    public override void
    on_resize ()
    {
        message ("Resize %s", geometry.extents.to_string ());
    }

    public override void
    on_paint (Maia.Graphic.Context inContext, Maia.Graphic.Region inArea)
    {
        //message ("Paint %s", inArea.extents.to_string ());
        try
        {
            inContext.pattern = new Maia.Graphic.Color (0.0, 0.0, 0.0, 1.0);
            inContext.paint ();

            inContext.pattern = new Maia.Graphic.Color (1.0, 0.0, 0.0, 1.0);
            inContext.rectangle (20, 20, inArea.extents.size.width - 40, inArea.extents.size.height - 40, 5, 5);
            //inContext.paint.line_width = 5;
            inContext.stroke ();
            inContext.pattern = new Maia.Graphic.Color (0.0, 0.0, 1.0, 1.0);
            inContext.arc (inArea.extents.size.width * timeline.progress, inArea.extents.size.height / 2.0,
                           20, 20, 0, 2 * GLib.Math.PI);
            inContext.fill ();
        }
        catch (Maia.Graphic.Error err)
        {
            message ("Error on paint %s", err.message);
        }

        base.on_paint (inContext, inArea);
    }

    public override void
    on_destroy ()
    {
        message ("Destroy");
        base.on_destroy ();
        Maia.Application.quit ();
    }
}*/

static int
main (string[] args)
{
    //Maia.Log.set_default_logger (new Maia.Log.File ("out.log", Maia.Log.Level.DEBUG, "test-window"));
    Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, "test-window"));

    Maia.Manifest manifest = new Maia.Manifest ("test.manifest");

    foreach (Maia.Parser.Token token in manifest)
    {
        switch (token)
        {
            case Maia.Parser.Token.START_ELEMENT:
                message ("Element: %s", manifest.element);
                break;

            case Maia.Parser.Token.ATTRIBUTE:
                message ("Attribute: %s = %s", manifest.attribute, manifest.val);
                break;

            case Maia.Parser.Token.END_ELEMENT:
                message ("End element: %s", manifest.element);
                break;
        }
    }

    Maia.Label label = manifest["Label"] as Maia.Label;
    message ("Label: %s %s", label.font_description, label.text);

    Maia.Application.init (args);

    /*TestWindow window = new TestWindow ();*/
    Maia.Window window = new Maia.Window ("toto", 400, 200);
    window.visible = true;
    window.add (label);
    Maia.Graphic.Size size;
    label.get_requested_size (out size);
    window.draw ();

    window.swap_buffer ();

    Maia.Application.run ();

    return 0;
}

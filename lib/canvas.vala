/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * canvas.vala
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

public interface Maia.Canvas : Drawable
{
    // static properties
    static bool s_ElementsRegister = false;

    // accessors
    protected abstract Core.Timeline timeline           { get; set; default = null; }
    protected abstract unowned Item? focus_item         { get; set; default = null; }
    protected abstract unowned Item? grab_pointer_item  { get; set; default = null; }
    protected abstract unowned Item? grab_keyboard_item { get; set; default = null; }

    public abstract Item root { get; set; default = null; }
    public abstract Graphic.Surface surface { get; }

    [CCode (notify = false)]
    public uint refresh_rate {
        get {
            return timeline.speed;
        }
        set {
            bool restart = false;
            if (timeline.is_playing)
            {
                timeline.stop ();
            }
            timeline.speed = value;
            timeline.n_frames = value;
            if (restart)
            {
                timeline.rewind ();
                timeline.start ();
            }
        }
    }

    public uint width {
        get {
            return surface != null ? (uint)surface.size.width : 0;
        }
    }

    public uint height {
        get {
            return surface != null ? (uint)surface.size.height : 0;
        }
    }

    // static methods
    private static void
    register_manifest_elements ()
    {
        if (!s_ElementsRegister)
        {
            Manifest.Element.register ("Group",       typeof (Group));
            Manifest.Element.register ("Rectangle",   typeof (Rectangle));
            Manifest.Element.register ("Path",        typeof (Path));
            Manifest.Element.register ("Image",       typeof (Image));
            Manifest.Element.register ("Label",       typeof (Label));
            Manifest.Element.register ("Entry",       typeof (Entry));
            Manifest.Element.register ("Grid",        typeof (Grid));
            Manifest.Element.register ("ToggleGroup", typeof (ToggleGroup));
            Manifest.Element.register ("Button",      typeof (Button));
            Manifest.Element.register ("CheckButton", typeof (CheckButton));
            Manifest.Element.register ("Highlight",   typeof (Highlight));
            Manifest.Element.register ("Document",    typeof (Document));
            Manifest.Element.register ("Model",       typeof (Model));
            Manifest.Element.register ("Column",      typeof (Model.Column));
            Manifest.Element.register ("View",        typeof (View));
            Manifest.Element.register ("DrawingArea", typeof (DrawingArea));

            s_ElementsRegister = true;
        }
    }

    // methods
    private void
    on_new_frame (int inFrameNum)
    {
        if (root != null && surface != null && geometry != null)
        {
            try
            {
                var area = geometry.copy ();

                root.update (surface.context, area);

                if (root.damaged != null && !root.damaged.is_empty ())
                {
                    draw (surface.context);
                }
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_DRAW, err.message);
            }
        }
    }

    protected void
    register ()
    {
        // Register manifest elements
        register_manifest_elements ();

        // Create refresh timeline
        timeline = new Core.Timeline (60, 60);
        timeline.loop = true;
        timeline.new_frame.connect (on_new_frame);

        // Connect on geometry changed to resize canvas
        notify["geometry"].connect (() => {
            resize ();
            damage ();
        });

        // On damage damage also root item
        damage.connect ((a) => {
            if (root != null)
            {
                root.damage (a);
            }
        });
    }

    protected virtual void
    on_set_pointer_cursor (Cursor inCursor)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"set pointer cursor $inCursor");
    }

    protected virtual void
    on_move_pointer (Graphic.Point inPosition)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, @"move pointer to $inPosition");
    }

    protected virtual void
    on_grab_focus (Item? inItem)
    {
        if (inItem == null)
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab focus");
        else
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);

        // Unset item have focus
        if (focus_item != null)
        {
            focus_item.have_focus = false;
        }

        // Set focused item
        focus_item = inItem;

        // Set item have focus
        if (inItem != null)
        {
            focus_item.have_focus = true;
        }
    }

    protected virtual bool
    on_grab_pointer (Item inItem)
    {
        bool ret = false;

        // Can grab only nobody have already grab
        if (grab_pointer_item == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", inItem.name);
            grab_pointer_item = inItem;
            ret = true;
        }

        return ret;
    }

    protected virtual void
    on_ungrab_pointer (Item inItem)
    {
        if (grab_pointer_item == inItem)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", grab_pointer_item.name);
            grab_pointer_item = null;
        }
    }

    protected virtual bool
    on_grab_keyboard (Item inItem)
    {
        bool ret = false;

        // Only focused item can grab keyboard
        if (grab_keyboard_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab keyboard %s", inItem.name);
            grab_keyboard_item = inItem;
            ret = true;
        }

        return ret;
    }

    protected virtual void
    on_ungrab_keyboard (Item inItem)
    {
        if (grab_keyboard_item == inItem)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab keyboard %s", grab_keyboard_item.name);
            grab_keyboard_item = null;
        }
    }

    protected abstract void resize ();

    /**
     * Clear canvas
     */
    public void
    clear ()
    {
        // we have already root item disconnect from grab signals
        if (root != null)
        {
            root.set_pointer_cursor.disconnect (on_set_pointer_cursor);
            root.move_pointer.disconnect (on_move_pointer);
            root.grab_focus.disconnect (on_grab_focus);
            root.grab_pointer.disconnect (on_grab_pointer);
            root.ungrab_pointer.disconnect (on_ungrab_pointer);
            root.grab_keyboard.disconnect (on_grab_keyboard);
            root.ungrab_keyboard.disconnect (on_ungrab_keyboard);
        }

        root = null;
    }

    /**
     * Load canvas mainfest
     *
     * @param inManifest manifest content buffer
     * @param inRoot root id in manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    load (string inManifest, string? inRoot = null) throws Core.ParseError
    {
        // clear canvas
        clear ();

        // Load manifest
        Manifest.Document manifest = new Manifest.Document.from_buffer (inManifest, inManifest.length);

        // Get root item
        root = manifest[inRoot] as Item;

        // Connect under root grab signals
        if (root != null)
        {
            root.set_pointer_cursor.connect (on_set_pointer_cursor);
            root.move_pointer.connect (on_move_pointer);
            root.grab_focus.connect (on_grab_focus);
            root.grab_pointer.connect (on_grab_pointer);
            root.ungrab_pointer.connect (on_ungrab_pointer);
            root.grab_keyboard.connect (on_grab_keyboard);
            root.ungrab_keyboard.connect (on_ungrab_keyboard);
        }
    }

    /**
     * Load canvas mainfest
     *
     * @param inFilename manifest filename
     * @param inRoot root id in manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    load_from_file (string inFilename, string? inRoot = null) throws Core.ParseError
    {
        // clear canvas
        clear ();

        // Load manifest
        Manifest.Document manifest = new Manifest.Document (inFilename);

        // Get root item
        root = manifest[inRoot] as Item;

        // Connect under root grab signals
        if (root != null)
        {
            root.set_pointer_cursor.connect (on_set_pointer_cursor);
            root.move_pointer.connect (on_move_pointer);
            root.grab_focus.connect (on_grab_focus);
            root.grab_pointer.connect (on_grab_pointer);
            root.ungrab_pointer.connect (on_ungrab_pointer);
            root.grab_keyboard.connect (on_grab_keyboard);
            root.ungrab_keyboard.connect (on_ungrab_keyboard);
        }
    }
}

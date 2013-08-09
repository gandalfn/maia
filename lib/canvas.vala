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
    internal abstract Core.Timeline timeline  { get; set; default = null; }
    internal abstract Item? focus_item        { get; set; default = null; }

    public abstract Item root { get; set; default = null; }
    public abstract Graphic.Surface surface { get; }

    [CCode (notify = false)]
    public uint refresh_rate {
        get {
            return timeline.duration;
        }
        set {
            timeline.duration = value;
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
            Manifest.Element.register ("CheckButton", typeof (CheckButton));
            Manifest.Element.register ("Highlight",   typeof (Highlight));
            Manifest.Element.register ("Document",    typeof (Document));

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
        timeline = new Core.Timeline.for_duration ((uint)(1000.0 / 60.0));
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
    on_grab_focus (Item? inItem)
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab focus %s", inItem.name);

        // Unset item have focus
        if (focus_item != null)
        {
            focus_item.have_focus = false;
            focus_item.grab_pointer.disconnect (on_grab_pointer);
            focus_item.ungrab_pointer.disconnect (on_ungrab_pointer);
            focus_item.grab_keyboard.disconnect (on_grab_keyboard);
            focus_item.ungrab_keyboard.disconnect (on_ungrab_keyboard);
        }

        // Set focused item
        focus_item = inItem;

        // Set item have focus
        if (inItem != null)
        {
            focus_item.have_focus = true;
            focus_item.grab_pointer.connect (on_grab_pointer);
            focus_item.ungrab_pointer.connect (on_ungrab_pointer);
            focus_item.grab_keyboard.connect (on_grab_keyboard);
            focus_item.ungrab_keyboard.connect (on_ungrab_keyboard);
        }
    }

    protected virtual bool
    on_grab_pointer ()
    {
        bool ret = false;

        // Only focused item can grab pointer
        if (focus_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab pointer %s", focus_item.name);
            ret = true;
        }

        return ret;
    }

    protected virtual void
    on_ungrab_pointer ()
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab pointer %s", focus_item.name);
    }

    protected virtual bool
    on_grab_keyboard ()
    {
        bool ret = false;

        // Only focused item can grab keyboard
        if (focus_item != null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "grab keyboard %s", focus_item.name);
            ret = true;
        }

        return ret;
    }

    protected virtual void
    on_ungrab_keyboard ()
    {
        Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_INPUT, "ungrab keyboard %s", focus_item.name);
    }

    protected abstract void resize ();

    /**
     * Load canvas mainfest
     *
     * @param inManifest manifest content buffer
     * @param inRoot root id in manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    load (string inManifest, string inRoot) throws Core.ParseError
    {
        // we have already root item disconnect from grab signals
        if (root != null)
        {
            root.grab_focus.disconnect (on_grab_focus);
            root.grab_pointer.disconnect (on_grab_pointer);
            root.ungrab_pointer.disconnect (on_ungrab_pointer);
            root.grab_keyboard.disconnect (on_grab_keyboard);
            root.ungrab_keyboard.disconnect (on_ungrab_keyboard);
        }

        // Load manifest
        Manifest.Document manifest = new Manifest.Document.from_buffer (inManifest, inManifest.length);

        // Get root item
        root = manifest[inRoot] as Item;

        // Connect under root grab signals
        if (root != null)
        {
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
     * @param inManifest manifest file
     * @param inRoot root id in manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    load_from_file (string inFilename, string inRoot) throws Core.ParseError
    {
        // we have already root item disconnect from grab signals
        if (root != null)
        {
            root.grab_focus.disconnect (on_grab_focus);
            root.grab_pointer.disconnect (on_grab_pointer);
            root.ungrab_pointer.disconnect (on_ungrab_pointer);
            root.grab_keyboard.disconnect (on_grab_keyboard);
            root.ungrab_keyboard.disconnect (on_ungrab_keyboard);
        }

        // Load manifest
        Manifest.Document manifest = new Manifest.Document (inFilename);

        // Get root item
        root = manifest[inRoot] as Item;

        // Connect under root grab signals
        if (root != null)
        {
            root.grab_focus.connect (on_grab_focus);
            root.grab_pointer.connect (on_grab_pointer);
            root.ungrab_pointer.connect (on_ungrab_pointer);
            root.grab_keyboard.connect (on_grab_keyboard);
            root.ungrab_keyboard.connect (on_ungrab_keyboard);
        }
    }
}

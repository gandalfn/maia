/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * application.vala
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

public class Maia.Application : Maia.Core.Object
{
    // constants
    const GLib.OptionEntry[] cOptionEntries =
    {
        { "backends",     'b', 0, GLib.OptionArg.NONE, ref s_Backends, "List of backends", null },
        { "refresh-rate", 'r', 0, GLib.OptionArg.INT,  ref s_Fps,      "Refresh rate",     null },
        { null }
    };

    // static properties
    private static unowned Application? s_Default = null;
    private static string               s_Backends = null;
    private static int                  s_Fps = 60;

    // static accessors
    public static Application @default {
        get {
            return s_Default;
        }
        set {
            s_Default = value;
        }
    }

    // properties
    private Backends      m_Backends;
    private Core.Timeline m_Timeline;
    private GLib.MainLoop m_Loop;

    // accessors
    [CCode (notify = false)]
    public uint refresh_rate {
        get {
            return m_Timeline.speed;
        }
        set {
            bool restart = false;
            if (m_Timeline.is_playing)
            {
                m_Timeline.stop ();
            }
            m_Timeline.speed = value;
            m_Timeline.n_frames = value;
            if (restart)
            {
                m_Timeline.rewind ();
                m_Timeline.start ();
            }
        }
    }

    // signals
    [Signal (run = "first")]
    public virtual signal void
    new_frame (int inNumFrame)
    {
        foreach (unowned Core.Object child in this)
        {
            unowned Window window = child as Window;
            if (window != null)
            {
                if (window.visible && window.surface != null)
                {
                    try
                    {
                        Graphic.Context ctx = window.surface.context;
                        window.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, window.size.width, window.size.height)));
                        window.draw (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, window.size.width, window.size.height)));
                    }
                    catch (GLib.Error err)
                    {
                        Log.critical (GLib.Log.METHOD, Log.Category.MAIN, "Error on window refresh: %s", err.message);
                    }
                }
            }
        }
    }

    // methods
    construct
    {
        m_Backends = new Backends ();
    }

    /**
     * Create maia application
     *
     * @param inFps refresh rate in frame per seconds
     * @param inBackends list of backends
     */
    public Application (int inFps, string[]? inBackends = null)
    {
        // Load backends
        if (inBackends != null)
        {
            foreach (unowned string backend in inBackends)
            {
                load_backend (backend);
            }
        }

        // Create refresh timeline
        m_Timeline = new Core.Timeline(inFps, inFps);
        m_Timeline.loop = true;
        m_Timeline.new_frame.connect (on_new_frame);

        // First application is the default application
        if (s_Default == null)
        {
            s_Default = this;
        }
    }

    /**
     * Create maia application
     *
     * @param inArgs command line arguments
     */
    public Application.from_args (ref unowned string[] inArgs)
    {
        try
        {
            GLib.OptionContext opt_context = new OptionContext("- Maia library");
            opt_context.set_help_enabled(true);
            opt_context.add_main_entries(cOptionEntries, "maia");
            opt_context.parse(ref inArgs);
        }
        catch (GLib.OptionError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MAIN, "option parsing failed: %s", err.message);
        }

        string[]? backends = null;
        if (s_Backends != null)
        {
            backends = s_Backends.split (",");
        }

        this (s_Fps, backends);
    }

    ~Application ()
    {
        if (this == s_Default)
        {
            s_Default = null;
        }
    }

    private void
    on_new_frame (int inFrameNum)
    {
        new_frame (inFrameNum);
    }

    private void
    on_window_visible_changed ()
    {
        m_Timeline.stop ();

        foreach (unowned Core.Object child in this)
        {
            if (((Window)child).visible)
            {
                m_Timeline.start ();
                break;
            }
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Window || inObject is Canvas;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (can_append_child (inObject))
        {
            base.insert_child (inObject);

            inObject.notify["visible"].connect (on_window_visible_changed);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        ((Window)inObject).notify["visible"].disconnect (on_window_visible_changed);
    }

    /**
     * Load a backend
     *
     * @param inBackend backend to load
     *
     * @return ``true`` if backend is loaded ``false`` otherwise
     */
    public bool
    load_backend (string inBackend)
    {
        bool ret = false;
        try
        {
            m_Backends.load (inBackend);
            ret = true;
        }
        catch (Core.ExtensionError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MAIN, "Error on loading backend %s: %s", inBackend, err.message);
        }

        return ret;
    }

    /**
     * Unload a backend
     *
     * @param inBackend backend to unload
     *
     * @return ``true`` if backend is unloaded ``false`` otherwise
     */
    public bool
    unload_backend (string inBackend)
    {
        bool ret = false;
        try
        {
            m_Backends.unload (inBackend);
            ret = true;
        }
        catch (Core.ExtensionError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MAIN, "Error on unloading backend %s: %s", inBackend, err.message);
        }

        return ret;
    }

    /**
     * Get backend name which provide inProvide
     *
     * @param inProvide backend provide module
     *
     * @return backend name which provide inProvide else ``null``
     */
    public string?
    get_backend (string inProvide)
    {
        unowned Backend? backend = m_Backends[inProvide];
        return backend == null ? null : backend.name;
    }

    /**
     * Run application
     */
    public void
    run ()
    {
        if (m_Loop == null)
        {
            m_Loop = new GLib.MainLoop (null, false);
        }

        m_Loop.run ();
    }

    /**
     * Quit application
     */
    public void
    quit ()
    {
        if (m_Loop != null)
        {
            m_Loop.quit ();
        }
    }
}

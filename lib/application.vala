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
        { "backends",     'b', 0, GLib.OptionArg.NONE,   ref s_Backends, "List of backends",  null },
        { "refresh-rate", 'r', 0, GLib.OptionArg.INT,    ref s_Fps,      "Refresh rate",      null },
        { "address",      'a', 0, GLib.OptionArg.STRING, ref s_Fps,      "Event bus address", null },
        { null }
    };

    // static properties
    private static unowned Application? s_Default = null;
    private static string               s_Backends = null;
    private static int                  s_Fps = 60;
    private static string               s_Uri = "unix://";

    // static accessors
    public static Application @default {
        get {
            return s_Default;
        }
        set {
            s_Default = value;
            if (s_Default != null)
            {
                Core.EventBus.default = s_Default.m_EventBus;
            }
        }
    }

    // properties
    private Backends      m_Backends;
    private Core.Timeline m_Timeline;
    private Core.EventBus m_EventBus;
    private GLib.MainLoop m_Loop;
    private bool          m_Pause = false;

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
                restart = true;
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

    [CCode (notify = false)]
    public bool pause {
        get {
            return m_Pause;
        }
        set {
            if (m_Pause != value)
            {
                m_Pause = value;

                if (m_Pause && m_Timeline.is_playing)
                {
                    m_Timeline.pause ();
                }
                else if (!m_Pause)
                {
                    on_window_visible_changed ();
                }
            }
        }
        default = false;
    }

    // static methods
    static construct
    {
        Manifest.Element.register ("Group",          typeof (Group));
        Manifest.Element.register ("Rectangle",      typeof (Rectangle));
        Manifest.Element.register ("Line",           typeof (Line));
        Manifest.Element.register ("Path",           typeof (Path));
        Manifest.Element.register ("Image",          typeof (Image));
        Manifest.Element.register ("Label",          typeof (Label));
        Manifest.Element.register ("Entry",          typeof (Entry));
        Manifest.Element.register ("Grid",           typeof (Grid));
        Manifest.Element.register ("CassoGrid",      typeof (CassoGrid));
        Manifest.Element.register ("ToggleGroup",    typeof (ToggleGroup));
        Manifest.Element.register ("Button",         typeof (Button));
        Manifest.Element.register ("ToggleButton",   typeof (ToggleButton));
        Manifest.Element.register ("ButtonTab",      typeof (ButtonTab));
        Manifest.Element.register ("CheckButton",    typeof (CheckButton));
        Manifest.Element.register ("Highlight",      typeof (Highlight));
        Manifest.Element.register ("Document",       typeof (Document));
        Manifest.Element.register ("DocumentView",   typeof (DocumentView));
        Manifest.Element.register ("Model",          typeof (Model));
        Manifest.Element.register ("Column",         typeof (Model.Column));
        Manifest.Element.register ("View",           typeof (View));
        Manifest.Element.register ("DrawingArea",    typeof (DrawingArea));
        Manifest.Element.register ("Shortcut",       typeof (Shortcut));
        Manifest.Element.register ("Combo",          typeof (Combo));
        Manifest.Element.register ("Tool",           typeof (Tool));
        Manifest.Element.register ("Toolbox",        typeof (Toolbox));
        Manifest.Element.register ("Arrow",          typeof (Arrow));
        Manifest.Element.register ("ScrollView",     typeof (ScrollView));
        Manifest.Element.register ("Window",         typeof (Window));
        Manifest.Element.register ("Popup",          typeof (Popup));
        Manifest.Element.register ("ProgressBar",    typeof (ProgressBar));
        Manifest.Element.register ("SeekBar",        typeof (SeekBar));
        Manifest.Element.register ("PopupButton",    typeof (PopupButton));
        Manifest.Element.register ("Chart",          typeof (Chart));
        Manifest.Element.register ("ChartView",      typeof (ChartView));
        Manifest.Element.register ("ChartIntersect", typeof (ChartIntersect));
        Manifest.Element.register ("ChartPoint",     typeof (ChartPoint));
        Manifest.Element.register ("Viewport",       typeof (Viewport));
        Manifest.Element.register ("RendererView",   typeof (RendererView));
        Manifest.Element.register ("ScaleBar",       typeof (ScaleBar));
        Manifest.Element.register ("SwitchButton",   typeof (SwitchButton));
        Manifest.Element.register ("StepButton",     typeof (StepButton));
        Manifest.Element.register ("Notebook",       typeof (Notebook));
        Manifest.Element.register ("NotebookPage",   typeof (NotebookPage));
    }

    // methods
    construct
    {
        m_Backends = new Backends ();
    }

    /**
     * Create maia application
     *
     * @param inName name of application
     * @param inFps refresh rate in frame per seconds
     * @param inBackends list of backends
     * @param inUri event bus address
     */
    public Application (string inName, int inFps, string[]? inBackends = null, string inUri = "unix://")
    {
        GLib.Object (id: GLib.Quark.from_string (inName));

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
        m_Timeline.new_frame.add_object_observer (on_new_frame);

        // Create event bus
        m_EventBus = new Core.EventBus (inUri);

        // First application is the default application
        if (s_Default == null)
        {
            s_Default = this;
            Core.EventBus.default = m_EventBus;
        }
    }

    /**
     * Create maia application
     *
     * @param inName name of application
     * @param inArgs command line arguments
     */
    public Application.from_args (string inName, ref unowned string[] inArgs)
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

        this (inName, s_Fps, backends, s_Uri);
    }

    ~Application ()
    {
        clear_childs ();

        if (this == s_Default)
        {
            Core.EventBus.default = null;
            s_Default = null;
        }
    }

    private void
    on_new_frame (Core.Notification inNotification)
    {
        foreach (unowned Core.Object child in this)
        {
            unowned Window window = child as Window;
            if (window != null)
            {
                if (window.visible)
                {
                    if (window.geometry == null || window.need_update)
                    {
                        var window_position = window.position;
                        var window_size = window.size;

                        var geometry = new Graphic.Region (Graphic.Rectangle (window_position.x,
                                                                              window_position.y,
                                                                              window_size.width,
                                                                              window_size.height));

                        // set window geometry from its size requested
                        Log.audit (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, @"window set geometry $(geometry.extents)");

                        try
                        {
                            // Create fake for window update
                            var surface = new Graphic.Surface (1, 1);

                            // update geometry of window
                            window.update (surface.context, geometry);
                        }
                        catch (GLib.Error err)
                        {
                            Log.critical (GLib.Log.METHOD, Log.Category.MAIN, @"Error on window refresh: $(err.message)");
                        }
                    }

                    // window is damaged
                    if (window.geometry != null && !window.geometry.is_empty () && window.surface != null && window.damaged != null && !window.damaged.is_empty ())
                    {
                        try
                        {
                            // draw window
                            window.draw (window.surface.context, window.damaged);
                        }
                        catch (GLib.Error err)
                        {
                            Log.critical (GLib.Log.METHOD, Log.Category.MAIN, @"Error on window refresh: $(err.message)");
                        }

                        // finally swap buffer
                        window.swap_buffer ();
                    }
                }
            }
        }
    }

    private void
    on_window_visible_changed ()
    {
        bool have_visible = false;

        foreach (unowned Core.Object child in this)
        {
            if (((Window)child).visible)
            {
                have_visible = true;
                break;
            }
        }

        if (!have_visible && m_Timeline.is_playing)
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN, "Stop timeline");
#endif
            m_Timeline.pause ();
        }
        else if (have_visible && !m_Timeline.is_playing && !m_Pause)
        {
#if MAIA_DEBUG
            Log.debug (GLib.Log.METHOD, Log.Category.MAIN, "Start timeline");
#endif
            m_Timeline.start ();
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Window;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (can_append_child (inObject))
        {
            base.insert_child (inObject);

            on_window_visible_changed ();

            inObject.notify["visible"].connect (on_window_visible_changed);
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        on_window_visible_changed ();

        ((Window)inObject).notify["visible"].disconnect (on_window_visible_changed);
    }

    internal unowned Backend?
    get_backend (string inProvide)
    {
        return m_Backends[inProvide];
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
            m_Loop = null;
        }
    }
}

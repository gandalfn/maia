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
        { "backends", 'b', 0, GLib.OptionArg.NONE, ref s_Backends, "List of backends", null },
        { "refresh-rate", 'r', 0, GLib.OptionArg.INT, ref s_Fps, "Refresh rate", null },
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
        if (inBackends != null)
        {
            foreach (unowned string backend in inBackends)
            {
                try
                {
                    m_Backends.load (backend);
                }
                catch (Core.ExtensionError err)
                {
                    Log.critical (GLib.Log.METHOD, Log.Category.MAIN, "Error on loading backend %s: %s", backend, err.message);
                }
            }
        }

        m_Timeline = new Core.Timeline(inFps, inFps);

        //
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

        string[] backends = s_Backends.split (",");

        this (s_Fps, backends);
    }

    ~Application ()
    {
        if (this == s_Default)
        {
            s_Default = null;
        }
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
        }
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
}

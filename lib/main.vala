/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * main.vala
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

public class Maia.Main : Maia.Core.Object
{
    // constants
    const GLib.OptionEntry[] cOptionEntries =
    {
        { "backends", 'b', 0, GLib.OptionArg.NONE, ref sBackends, "List of backends", null },
        { "refresh-rate", 'r', 0, GLib.OptionArg.INT, ref sFps, "Refresh rate", null },
        { null }
    };

    // static properties
    private static string sBackends = null;
    private static int    sFps = 60;

    // properties
    private Backends      m_Backends;
    private Core.Timeline m_Timeline;

    // methods
    construct
    {
        m_Backends = new Backends ();
    }

    /**
     * Create main loop for maia
     *
     * @param inFps refresh rate in frame per seconds
     * @param inBackends list of backends
     */
    public Main (int inFps, string[]? inBackends = null)
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
    }

    /**
     * Create main loop for maia
     *
     * @param inArgs command line arguments
     */
    public Main.from_args (ref unowned string[] inArgs)
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

        string[] backends = sBackends.split (",");

        this (sFps, backends);
    }


}

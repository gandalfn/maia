/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * backend.vala
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

internal class Maia.Backend : Maia.Core.Extension
{
    // types
    private delegate void LoadFunc ();
    private delegate void UnloadFunc ();

    // properties
    private bool m_Loaded;

    // accessors
    public bool loaded {
        get {
            return m_Loaded;
        }
    }

    public string[] require {
        owned get {
            return m_Config.get_string_list_with_default("Backend", "Require", {});
        }
    }

    public string[] provide {
        owned get {
            return m_Config.get_string_list_with_default("Backend", "Provide", {});
        }
    }

    // methods
    public Backend (string inFilename)
    {
        base (inFilename);
    }

    public void
    load () throws Core.ExtensionError
    {
        open ();

        unowned LoadFunc func = (LoadFunc)this["backend_load"];

        func ();

        m_Loaded = true;
    }

    public void
    unload () throws Core.ExtensionError
    {
        unowned UnloadFunc func = (UnloadFunc)this["backend_unload"];

        func ();

        close ();

        m_Loaded = false;
    }
}

internal class Maia.Backends : Maia.Core.ExtensionLoader<Maia.Backend>
{
    // methods
    public Backends ()
    {
        string[] paths = {}; 

        string? backend_paths = GLib.Environment.get_variable("MAIA_BACKEND_PATH");
        if (backend_paths != null)
        {
            string[] bp = backend_paths.split(":");
            foreach (unowned string p in bp)
            {
                paths += p;
            }
        }
        else
        {
            paths += global::Config.MAIA_BACKEND_PATH;
        }

        base ("backend", paths);
    }

    public void
    load (string inBackend) throws Core.ExtensionError
    {
        foreach (unowned Core.Object child in this)
        {
            unowned Backend backend = child as Backend;

            if (backend != null && backend.name == inBackend && !backend.loaded)
            {
                foreach (string req in backend.require)
                {
                    load (req);
                }
                backend.load ();
            }
        }
    }

    public void
    unload (string inBackend) throws Core.ExtensionError
    {
        foreach (unowned Core.Object child in this)
        {
            unowned Backend backend = child as Backend;

            if (backend != null && backend.name == inBackend && backend.loaded)
            {
                backend.unload ();
            }
        }
    }

    public new unowned Backend?
    @get(string inProvide)
    {
        unowned Backend? ret = null;

        foreach (unowned Core.Object child in this)
        {
            unowned Backend backend = child as Backend;

            if (inProvide in backend.provide)
            {
                ret = backend;
            }
        }

        return ret;
    }
}

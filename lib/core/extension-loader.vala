/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * extension-loader.vala
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

/**
 * This class manage a list of extension loading
 */
public class Maia.Core.ExtensionLoader<T> : Object
{
    // methods
    /**
     * This class provides the loading of extension module
     *
     * @param inSuffix suffix of extension configuration file
     * @param inSearchPaths list of search path
     */
    public ExtensionLoader (string inSuffix, string[] inSearchPaths)
    {
        string pattern = "*." + inSuffix;

        foreach (unowned string path in inSearchPaths)
        {
            try
            {
                GLib.Dir dir = GLib.Dir.open (path);
                if (dir == null)
                {
                    continue;
                }

                for (unowned string file = dir.read_name (); file != null; file = dir.read_name ())
                {
                    if (GLib.PatternSpec.match_simple (pattern, file))
                    {
                        Extension extension = GLib.Object.new (typeof(T), configuration_filename: path + "/" + file) as Extension;
                        if (extension != null)
                        {
                            add (extension);
                        }
                        else
                        {
                            Log.error (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Error on loading extension %s", file);
                        }
                    }
                }
            }
            catch (GLib.FileError err)
            {
                Log.error (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Error on open extension directory %s: %s", path, err.message);
            }
        }
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Extension;
    }
}

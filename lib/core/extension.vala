/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * extension.vala
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

public errordomain Maia.Core.ExtensionError
{
    CREATE,
    LOADING,
    NOT_LOADED,
    CREATE_PLUGIN
}

/**
 * This class provides extension creation and description
 */
public class Maia.Core.Extension : Object
{
    // properties
    private GLib.Module m_Module;
    protected Config    m_Config;

    // accessors
    /**
     * Extension configuration filename
     */
    public string configuration_filename {
        get {
            return m_Config == null ? null : m_Config.filename;
        }
        set {
            try
            {
                // Get plugin config file
                m_Config = new Config.load (value);

                // Get plugin name
                string name = m_Config.get_string ("Extension", "Name");

                // Set id
                id = GLib.Quark.from_string (name);

                // Get plugin description
                description = m_Config.get_string ("Extension", "Description");

                // Get plugin module filename
                module_filename = m_Config.get_string ("Extension", "Module");
                
                // Module is relative to config file
                if (GLib.Path.get_dirname (module_filename) == ".")
                {
                    var tmp = GLib.Module.build_path (GLib.Path.get_dirname (value), module_filename);
                    if (!GLib.FileUtils.test (tmp, FileTest.EXISTS))
                    {
                        tmp = GLib.Module.build_path (GLib.Path.get_dirname (value) + "/.libs", module_filename);
                        if (!GLib.FileUtils.test (tmp, FileTest.EXISTS))
                        {
                            Log.error ("Extension.configuration_filename.set", Log.Category.CORE_EXTENSION, @"Error does not found $module_filename module in $(GLib.Path.get_dirname (value))");
                        }
                        else
                        {
                            module_filename = tmp;
                        }
                    }
                    else
                    {
                        module_filename = tmp;
                    }
                }
            }
            catch (ConfigError err)
            {
                Log.error ("Extension.configuration_filename.set", Log.Category.CORE_EXTENSION, @"Error on open $value: $(err.message)");
            }
        }
    }

    /**
     * The name of the extension
     */
    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    /**
     * The description of the extension
     */
    public string description { get; private set; default = null; }

    /**
     * The module filename
     */
    public string module_filename { get; private set; default = null; }


    // methods
    /**
     * This class provides extension creation and description
     *
     * @param inFilename the extension description filename
     */
    public Extension (string inFilename)
    {
        print(@"extension: $inFilename\n");
        GLib.Object (configuration_filename: inFilename);
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return false;
    }

    /**
     * Open the corresponding extension
     *
     * @throws ExtensionError raised when something went wrong
     */
    public void
    open () throws ExtensionError
    {
        if (m_Module == null)
        {
            m_Module = GLib.Module.open (module_filename, GLib.ModuleFlags.BIND_LAZY);
            if (m_Module == null)
            {
                throw new ExtensionError.LOADING ("Error on loading %s: %s", module_filename, GLib.Module.error ());
            }

            Log.debug (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Open module %s for extension %s", module_filename, name);
        }
    }

    /**
     * Close the corresponding extension
     */
    public void
    close ()
    {
        if (m_Module != null)
        {
            m_Module = null;

            Log.debug (GLib.Log.METHOD, Log.Category.CORE_EXTENSION, "Close module %s for extension %s", module_filename, name);
        }
    }

    /**
     * Create a object extension
     *
     * @return Object module
     */
    public new void*
    get (string inFunction) throws ExtensionError
    {
        if (m_Module == null)
        {
            throw new ExtensionError.LOADING ("Error on loading %s: module is not open", module_filename);
        }

        void* ret = null;
        if (!m_Module.symbol (inFunction, out ret))
        {
            throw new ExtensionError.LOADING ("Error on loading %s: %s", inFunction, GLib.Module.error ());
        }

        return ret;
    }
}
